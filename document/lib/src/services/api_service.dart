import 'package:dio/dio.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:document/src/app/app.logger.dart';
import 'package:document/src/services/document.dart';
import 'package:document/src/ui/widgets/document_list/document_item_widgetmodel.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  final _dio = locator<Dio>();
  final _log = getLogger('ApiService');

  void split(
    String url,
    DocumentItemWidgetModel widgetModel,
  ) {
    final multipartFile = MultipartFile.fromStream(
      () => Stream.fromIterable(widgetModel.item.byteData!),
      widgetModel.item.byteData!.length,
      filename: widgetModel.item.name,
      contentType: MediaType.parse(widgetModel.item.fileMimeType),
    );

    final formData = FormData.fromMap({
      'file': multipartFile,
    });

    _dio.post<Map<String, dynamic>>(
      url,
      data: formData,
      cancelToken: widgetModel.cancelToken,
      onSendProgress: (int sent, int total) async {
        if (widgetModel.item.status == DocumentStatus.pending) {
          _log.d('updateDocumentStatus(DocumentStatus.splitting)');
          await widgetModel.updateDocumentStatus(DocumentStatus.splitting);
        }

        final progress = sent / total;
        widgetModel.progress = progress;
      },
      onReceiveProgress: (int count, int total) async {
        /* The same code above works but not the following code?
        if (total == 0 && widgetModel.item.status == DocumentStatus.pending) {
          await widgetModel.updateDocumentStatus(DocumentStatus.splitting);
        }
        */
        final progress = count * 0.01;
        widgetModel.progress = progress;
      },
    ).then((response) async {
      await widgetModel.onUploadCompleted(response.data);
    }).catchError(
      widgetModel.onError,
    );
  }
}
