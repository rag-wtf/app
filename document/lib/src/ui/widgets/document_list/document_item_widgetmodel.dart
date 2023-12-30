import 'package:dio/dio.dart';
import 'package:document/src/services/document.dart';
import 'package:stacked/stacked.dart';

class DocumentItemWidgetModel extends BaseViewModel {
  DocumentItemWidgetModel(this.item) {
    _documentStatus = item.status;
  }
  final Document item;
  late DocumentStatus _documentStatus;
  double _progress = 0;
  final _cancelToken = CancelToken();

  void cancel() {
    _cancelToken.cancel();
  }

  CancelToken get cancelToken => _cancelToken;

  set documentStatus(DocumentStatus status) {
    _documentStatus = status;
    notifyListeners();
  }

  DocumentStatus get documentStatus => _documentStatus;

  set progress(double progress) {
    _progress = progress;
    notifyListeners();
  }

  double get progress => _progress;

  void onUploadCompleted(Map<String, dynamic>? responseData) {
    print('responseData $responseData');
  }
}
