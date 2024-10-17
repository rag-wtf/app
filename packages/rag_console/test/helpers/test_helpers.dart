import 'package:mockito/annotations.dart';
import 'package:rag_console/src/services/rag_console_api_service.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

// @stacked-import
import 'test_helpers.mocks.dart';

final locator = StackedLocator.instance;

@GenerateMocks(
  [],
  customMocks: [
    MockSpec<NavigationService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<RagConsoleApiService>(onMissingStub: OnMissingStub.returnDefault),
// @stacked-mock-spec
  ],
)
void registerServices() {
  getAndRegisterNavigationService();
  getAndRegisterRagConsoleApiService();
// @stacked-mock-register
}

MockNavigationService getAndRegisterNavigationService() {
  _removeRegistrationIfExists<NavigationService>();
  final service = MockNavigationService();
  locator.registerSingleton<NavigationService>(service);
  return service;
}

MockRagConsoleApiService getAndRegisterRagConsoleApiService() {
  _removeRegistrationIfExists<RagConsoleApiService>();
  final service = MockRagConsoleApiService();
  locator.registerSingleton<RagConsoleApiService>(service);
  return service;
}
// @stacked-mock-create

void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}
