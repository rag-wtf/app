import 'dart:async';

import 'package:dio/dio.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:document/src/app/app.logger.dart';
import 'package:document/src/services/api_service.dart';
import 'package:document/src/services/document.dart';
import 'package:document/src/services/document_repository.dart';
import 'package:document/src/services/document_service.dart';
import 'package:document/src/ui/views/document_list/document_list_viewmodel.dart';
import 'package:settings/settings.dart';
import 'package:stacked/stacked.dart';

class DocumentItemWidgetModel extends FutureViewModel<void> {
  DocumentItemWidgetModel(this._parentViewModel, this._itemIndex);
  double _progress = 0;
  final _cancelToken = CancelToken();
  final _documentService = locator<DocumentService>();
  final _documentRepository = locator<DocumentRepository>();
  final _apiService = locator<ApiService>();
  final _settingService = locator<SettingService>();
  final _log = getLogger('DocumentItemWidgetModel');
  final DocumentListViewModel _parentViewModel;
  final int _itemIndex;

  Document get item => _parentViewModel.items[_itemIndex];

  @override
  Future<void> futureToRun() async {
    if (item.status == DocumentStatus.created) {
      await setDocumentStatus(DocumentStatus.pending);
    }
    if (item.status == DocumentStatus.pending) {
      _log.d(item.id);
      _parentViewModel.setItem(
        _itemIndex,
        (await _documentService.getDocumentById(item.id!))!,
      );
      _apiService.upload(
        _settingService.get(dataIngestionApiUrlKey).value,
        item,
        this,
      );
    }
  }

  void cancel() {
    _cancelToken.cancel();
  }

  CancelToken get cancelToken => _cancelToken;

  Future<void> setDocumentStatus(DocumentStatus status) async {
    _parentViewModel.setItem(
      _itemIndex,
      (await _documentRepository.updateDocument(
        item.copyWith(status: status),
      ))!,
    );
    notifyListeners();
  }

  Future<void> handleError(String? errorMessage) async {
    _log.e(errorMessage);
    _parentViewModel.setItem(
      _itemIndex,
      (await _documentRepository.updateDocument(
        item.copyWith(
          status: DocumentStatus.failed,
          errorMessage: errorMessage,
          done: DateTime.now(),
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

  Future<void> onUploadCompleted(Map<String, dynamic>? responseData) async {
    _log.d('responseData $responseData');

    final documentItems =
        List<Map<String, dynamic>>.from(responseData?['items'] as List);
    if (documentItems.isEmpty) {
      final document = await _documentService.getDocumentById(item.id!);
      documentItems.add({
        'content': await _documentService.convertByteDataToString(
          document!.byteData!,
        ),
      });
    }
    //TODO: create embedding instances and store it.
    final chunkedTexts = List<String>.from(
      documentItems.map((item) => item['content']).toList(),
    );
  }

  @override
  // ignore: prefer_void_to_null
  FutureOr<Null> onError(dynamic error) async {
    _log.e(error);
    // Handle the error in here
    if (error is DioException) {
      if (error.type == DioExceptionType.cancel) {
        _parentViewModel.setItem(
          _itemIndex,
          (await _documentRepository.updateDocument(
            item.copyWith(
              status: DocumentStatus.canceled,
              done: DateTime.now(),
            ),
          ))!,
        );
      } else {
        await handleError(error.message);
      }
    } else {
      await handleError(error.toString());
    }
  }
}
