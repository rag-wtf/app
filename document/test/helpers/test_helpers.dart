import 'package:document/src/services/batch_service.dart';
import 'package:document/src/services/document_api_service.dart';
import 'package:mockito/annotations.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

// @stacked-import
import 'test_helpers.mocks.dart';

final locator = StackedLocator.instance;

@GenerateMocks(
  [],
  customMocks: [
    MockSpec<NavigationService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<DocumentApiService>(onMissingStub: OnMissingStub.returnDefault),

    MockSpec<BatchService>(onMissingStub: OnMissingStub.returnDefault),
// @stacked-mock-spec
  ],
)
void registerServices() {
  getAndRegisterNavigationService();
  getAndRegisterApiService();
  getAndRegisterBatchService();
// @stacked-mock-register
}

MockNavigationService getAndRegisterNavigationService() {
  _removeRegistrationIfExists<NavigationService>();
  final service = MockNavigationService();
  locator.registerSingleton<NavigationService>(service);
  return service;
}

MockDocumentApiService getAndRegisterApiService() {
  _removeRegistrationIfExists<DocumentApiService>();
  final service = MockDocumentApiService();
  locator.registerSingleton<DocumentApiService>(service);
  return service;
}

MockBatchService getAndRegisterBatchService() {
  _removeRegistrationIfExists<BatchService>();
  final service = MockBatchService();
  locator.registerSingleton<BatchService>(service);
  return service;
}
// @stacked-mock-create

void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}
