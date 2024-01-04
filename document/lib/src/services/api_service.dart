import 'package:dio/dio.dart';
import 'package:document/src/app/app.locator.dart';
import 'package:document/src/services/document.dart';
import 'package:document/src/ui/widgets/document_list/document_item_widgetmodel.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  final dio = locator<Dio>();

  void upload(
      String url, Document document, DocumentItemWidgetModel widgetModel) {
    final multipartFile = MultipartFile.fromStream(
      () => Stream.fromIterable(document.byteData!),
      document.byteData!.length,
      filename: document.name,
      contentType: MediaType.parse(document.fileMimeType),
    );

    final formData = FormData.fromMap({
      'file': multipartFile,
    });

    dio.post<Map<String, dynamic>>(
      url,
      data: formData,
      cancelToken: widgetModel.cancelToken,
      onSendProgress: (int sent, int total) async {
        if (widgetModel.item.status == DocumentStatus.pending) {
          await widgetModel.updateDocumentStatus(DocumentStatus.uploading);
        }
        final progress = sent / total;
        widgetModel.progress = progress;
      },
      onReceiveProgress: (int count, int total) async {
        if (widgetModel.item.status == DocumentStatus.uploading) {
          await widgetModel.updateDocumentStatus(DocumentStatus.splitting);
        }
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
