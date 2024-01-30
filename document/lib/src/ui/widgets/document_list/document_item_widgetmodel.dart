import 'dart:async';

import 'package:dio/dio.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:document/src/app/app.logger.dart';
import 'package:document/src/services/document.dart';
import 'package:document/src/services/document_api_service.dart';
import 'package:document/src/services/document_repository.dart';
import 'package:document/src/services/document_service.dart';
import 'package:document/src/services/embedding.dart';
import 'package:document/src/ui/views/document_list/document_list_viewmodel.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';
import 'package:ulid/ulid.dart';

class DocumentItemWidgetModel extends BaseViewModel {
  DocumentItemWidgetModel(this._parentViewModel, this._itemIndex);
  double _progress = 0;
  final _cancelToken = CancelToken();
  final _documentService = locator<DocumentService>();
  final _documentRepository = locator<DocumentRepository>();
  final _apiService = locator<DocumentApiService>();
  final _settingService = locator<SettingService>();
  final _dio = locator<Dio>();
  final _log = getLogger('DocumentItemWidgetModel');
  final DocumentListViewModel _parentViewModel;
  final int _itemIndex;

  Document get item => _parentViewModel.items[_itemIndex];

  Future<void> initialise() async {
    if (item.status == DocumentStatus.created) {
      await updateDocumentStatus(DocumentStatus.pending);
    }
    if (item.status == DocumentStatus.pending) {
      _log.d(item.id);
      _parentViewModel.setItem(
        _itemIndex,
        (await _documentService.getDocumentById(item.id!))!,
      );
      _apiService.split(
        _dio,
        _settingService.get(dataIngestionApiUrlKey).value,
        this,
      );
    }
  }

  void cancel() {
    _cancelToken.cancel();
  }

  CancelToken get cancelToken => _cancelToken;

  Future<void> updateDocumentStatus(DocumentStatus status) async {
    _log.d('item.name ${item.name}, status $status');
    _parentViewModel.setItem(
      _itemIndex,
      (await _documentRepository.updateDocument(
        item.copyWith(
          status: status,
          updated: DateTime.now(),
        ),
      ))!,
    );
    notifyListeners();
  }

  Future<void> handleError(String? errorMessage) async {
    _log.e(errorMessage);
    final now = DateTime.now();
    _parentViewModel.setItem(
      _itemIndex,
      (await _documentRepository.updateDocument(
        item.copyWith(
          status: DocumentStatus.failed,
          errorMessage: errorMessage,
          done: now,
          updated: now,
        ),
      ))!,
    );
    notifyListeners();
  }

  set progress(double progress) {
    _progress = progress;
    notifyListeners();
  }

  double get progress => _progress;

  Future<void> onSplitCompleted(Map<String, dynamic>? responseData) async {
    _log.d('responseData $responseData');
    final embeddings = await _splitted(responseData);
    await indexing(embeddings);
  }

  Future<List<Embedding>> _splitted(Map<String, dynamic>? responseData) async {
    final documentItems =
        List<Map<String, dynamic>>.from(responseData?['items'] as List);
    if (documentItems.isEmpty) {
      final document = await _documentService.getDocumentById(item.id!);
      documentItems.add({
        'content': await _documentService.convertByteDataToString(
          document!.byteData!,
        ),
        'tokens_count': responseData?['tokens_count'],
      });
    }

    final now = DateTime.now();
    final fullTableName =
        '${_parentViewModel.tablePrefix}_${Embedding.tableName}';
    final embeddings = List<Embedding>.from(
      documentItems
          .map(
            (item) => Embedding(
              id: '$fullTableName:${Ulid()}',
              content: item['content'] as String,
              metadata: item['metadata'],
              tokensCount: item['tokens_count'] as int,
              created: now,
              updated: now,
            ),
          )
          .toList(),
    );
    final document = item.copyWith(
      content: responseData?['content'] != null
          ? responseData!['content'] as String
          : null,
      contentMimeType: responseData?['mime_type'] as String,
      tokensCount: responseData?['tokens_count'] as int,
      status: DocumentStatus.indexing,
      splitted: now,
      updated: now,
    );
    final txnResults = await _documentService.updateDocumentAndCreateEmbeddings(
      _parentViewModel.tablePrefix,
      document,
      embeddings,
    );
    final results = List<List<dynamic>>.from(txnResults! as List);
    assert(
      results[1].length == embeddings.length,
      'Length of the document embeddings result should equals to embeddings',
    );
    _parentViewModel.setItem(_itemIndex, document);
    notifyListeners();
    return embeddings;
  }

  Future<void> indexing(List<Embedding> embeddings) async {
    final chunkedTexts = embeddings
        .map(
          (embedding) => embedding.content,
        )
        .toList();
    final vectors = await _apiService.index(
      _dio,
      _settingService.get(embeddingsApiUrlKey).value,
      _settingService.get(embeddingsApiKey).value,
      chunkedTexts,
    );

    await _documentService.updateEmbeddings(
      _parentViewModel.tablePrefix,
      embeddings,
      vectors,
    );

    await updateDocumentStatus(DocumentStatus.completed);
    notifyListeners();
  }

  @override
  // ignore: prefer_void_to_null
  FutureOr<Null> onError(dynamic error) async {
    _log.e(error);
    // Handle the error in here
    if (error is DioException) {
      if (error.type == DioExceptionType.cancel) {
        final now = DateTime.now();
        _parentViewModel.setItem(
          _itemIndex,
          (await _documentRepository.updateDocument(
            item.copyWith(
              status: DocumentStatus.canceled,
              done: now,
              updated: now,
            ),
          ))!,
        );
        notifyListeners();
      } else {
        await handleError(error.message);
      }
    } else {
      await handleError(error.toString());
    }
  }
}
