import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rag/app/app.bottomsheets.dart';
import 'package:rag/app/app.locator.dart';
import 'package:rag/ui/common/app_strings.dart';
import 'package:rag/ui/views/home/home_viewmodel.dart';

import '../helpers/test_helpers.dart';

void main() {
  HomeViewModel getModel() => HomeViewModel();

  group('HomeViewmodelTest -', () {
    setUp(registerServices);
    tearDown(locator.reset);

    group('incrementCounter -', () {
      test('When called once should return  Counter is: 1', () {
        final model = getModel();
        model.incrementCounter();
        expect(model.counterLabel, 'Counter is: 1');
      });
    });

    group('showBottomSheet -', () {
      test('When called, should show custom bottom sheet using notice variant',
          () {
        final bottomSheetService = getAndRegisterBottomSheetService<Variant, Title, Description>()();

        final model = getModel();
        getModel().showBottomSheet();
        verify(
          bottomSheetService.showCustomSheet(
            variant: BottomSheetType.notice,
            title: ksHomeBottomSheetTitle,
            description: ksHomeBottomSheetDescription,
          ),
        );
      });
    });
  });
}
