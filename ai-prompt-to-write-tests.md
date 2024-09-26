Analyse the content of `document.md` for codebase of the `document` package. 

Write code to improve unit testing and integration testing coverage for the `document` package. The application is written in Flutter and uses `mockito` package.

Provide a detailed plan for increasing unit testing coverage, including:

* Identifying critical functions and modules that require testing
* Writing unit tests for each function, including edge cases and error handling
* Using mocking and stubbing to isolate dependencies
* Follow the "Practical Guide to Unit Testing in Flutter" below to write unit tests

Also, provide a plan for improving integration testing coverage, including:

* Identifying key integration points between modules and systems
* Writing integration tests to verify data flow and functionality
* Using testing frameworks and tools to automate integration testing
* Implementing continuous integration and continuous deployment (CI/CD) pipelines to ensure testing is integrated into the development workflow


---


# Practical Guide to Unit Testing in Flutter
One of the most important things in a mobile application is the ability to navigate your user based on their previous session. This helps keep engagement high and make sure your user starts at the correct place. Today we’ll be writing some code that obeys the following rules.

1.  When a user doesn’t have a session on disk we go to the LoginView
2.  When a user does have a session on disk:
    1.  We try to sync that users information
        1.  if the user doesn’t have a default address we take them to Address Selection
        2.  if they do then we take them to the Home / Main view

That’s all that we’re doing today, but we’re going to do it in a way that I find very beneficial. Not only for code quality reasons but also for productivity reasons. We’ll be writing this in a TDD manner. I don’t practice strict TDD but it does help me implement some of the more intimidating features that I have to tackle. It does so by providing my immediate feedback as well as providing a safety net during development to refactor if I have a better idea in mind. With that said lets get started.

Setting up for Unit tests
-------------------------

If you open the [Customer Application](https://github.com/FilledStacks/boxtout/tree/main/src/clients/customer) you’ll see that we have no tests setup. We’ll start by adding the mocking library that we’ll use called mockito. You can add this package into your `pubspec.yaml` file under `dev_dependencies`

```
dev_dependencies:
	...
	# Testing
	mockito:
```


After adding this we can start with our test setup. In the test folder create a new folder called `helpers`. Inside that folder create a new file called `test_helpers.dart`. Given the code base we know we’re writing tests for the `StartupViewModel` and the service that will be in use, based on the cases above is the `UserService` and the `NavigationService`. If you want a full explanation of unit testing you can watch my [How to Unit Test](https://youtu.be/n21w5T3jdWE) video followed by the [How to Mock](https://youtu.be/Kq-YMAE1ssA) video. I will not go into depth around that now.

### Setting up Testing Mocks

In the `test_helpers.dart` file you can add the `GenerateMocks` annotation and supply the MockSpec for UserService and NavigationService

```
@GenerateMocks([], customMocks: [
  // If we don't supply returnNullOnMissingStub then we'll get an exception when
  // a non-stubbed method is called.
  MockSpec<UserService>(returnNullOnMissingStub: true),
  MockSpec<NavigationService>(returnNullOnMissingStub: true),
])
```


After adding this you can run `flutter pub run build_runner build --delete-conflicting-outputs`. If you don’t have that command then also add `build_runner` to your dev\_devendencies. This will generate the mocks for you in a file called `test_helpers.mocks.dart`. The next step is to create the helper functions that create the mock and registers it with our locator. We’ll first create a helper function to remove a registration from a locator if it already exists. This is to ensure we don’t have duplicate registrations of a service in the locator.

```
void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}
```


I have added some new snippets to the [Stacked Snippets](https://gist.github.com/FilledStacks/b57b77da10fdcb2d4d95a28de4a4ced4) which will help with the following bit of setup. First one we’ll use is `testr` which is the function we use to register our mock with our locator to use in the unit tests. We’ll create the mocks for `UserService` and `NavigationService`

```
UserService getAndRegisterUserService() {
  _removeRegistrationIfExists<UserService>();
  final service = MockUserService();
  locator.registerSingleton<UserService>(service);
  return service;
}

NavigationService getAndRegisterNavigationService() {
  _removeRegistrationIfExists<NavigationService>();
  final service = MockNavigationService();
  locator.registerSingleton<NavigationService>(service);
  return service;
}
```


When we have those we want to create the helper functions that will reigster all services or unregister all services. These are functions we use in the main test group to ensure that we don’t have to manually register services that we don’t need to use in the active unit test.

```
void registerServices() {
  getAndRegisterUserService();
  getAndRegisterNavigationService();
}

void unregisterService() {
  locator.unregister<UserService>();
  locator.unregister<NavigationService>();
}
```


With that we are ready to write a unit test.

### Writing a Unit test

We’ll start with the first step in the business logic we mentioned above. When a user doesn’t have a session on disk, we go to the login view. In the test folder create a new folder called `viewmodel_tests` and inside create a new file called `startup_viewmodel_test.dart`. Then we’ll use another fancy new snippet. This snippet will create the expected main unit test setup and call the register and unregisterServices helper functions. You’ll type `testmr` and you’ll get the following.

```
import 'package:flutter_test/flutter_test.dart';

void main() {
 group('StartupViewmodelTest -', (){
  setUp(() => registerServices());
  tearDown(() => unregisterService());
 });
}
```


Then under the tearDown function you can type `testg` and create the `runStartupLogic` test suite.

```
...
tearDown(() => unregisterService());

group('runStartupLogic -', () {
 test('', () {

 });
});
```


The first test we want is to make sure that we’re checking if a user is logged in using the userService’s `hasLoggedInUser` property. Every test going forward will be written in the `runStartupLogic` suite for this tutorial. So we’ll have a test like this.

```
test(
    'When called should check if we have a logged in user on UserService',
    () async {
  final userService = getAndRegisterUserService();
  var model = StartUpViewModel();
  await model.runStartupLogic();
  verify(userService.hasLoggedInUser);
});
```


But as you notice that doesn’t exist yet, in strict TDD that’s considered a failing test as well. So we’ll add the new property. Open the `UserService` and add

```
/// Returns true if this device has a user that is logged into the BoxtOut backend
bool get hasLoggedInUser => _firebaseAuthenticationService.hasUser;
```


After adding this property we need to **re-generate our mocks by running the build\_runner build command**. When you run this it will fail, because we haven’t done anything yet. To run tests easily type ctrl+shift+p and type “Dart: Run All Tests” and press enter. To speed things up, type Dart: Run All Tests, and click on the configure icon on the far right. Then you can assign a key board binding to it. For me that’s ctrl+k, ctrl+r for run. Now that we have the failing unit test, lets make it pass.

Open the `StartUpViewModel` and we’ll make this test pass.

```
class StartUpViewModel extends BaseViewModel {
  final log = getLogger('StartUpViewModel');

	final _userService = locator<UserService>();

	Future<void> runStartupLogic() async {
		if (_userService.hasLoggedInUser) {
			// Do logged in stuff
		} else {
			// Do logged out stuff
  }
}
```


We’re simply just getting the userService from the locator and then checking if `hasLoggedInUser` is true or false.

Now if you press ctrl+k,r then you’ll see it still fails. The reason for that is because that property is returning null from the mock. So lets stub that property and make it so that we can set it to whatever we want for that unit test. Open the `test_helpers.dart` file and update the `UserService` mock function

```
UserService getAndRegisterUserService({
  bool hasLoggedInUser = false,
}) {
  _removeRegistrationIfExists<UserService>();
  final service = MockUserService();

  when(service.hasLoggedInUser).thenReturn(hasLoggedInUser);

  locator.registerSingleton<UserService>(service);
  return service;
}
```


Here we simply allow you to now pass in the `hadLoggedInUser` value and when a test calls `.hasLoggedInUser` we return that value. If you run your tests now it should pass. Next test, still related to 1, is to check if `hasLoggedInUser` is false, then we navigate to the `LoginView`.

```
test('When we have no logged in user, should navigate to the LoginView',
    () async {
  final navigationService = getAndRegisterNavigationService();
  getAndRegisterUserService(hasLoggedInUser: false);
  var model = StartUpViewModel();
  await model.runStartupLogic();
  verify(navigationService.replaceWith(Routes.loginView));
});
```


Run the test to confirm the behaviour doesn’t exist. This is a good practice because I’ve found that when working in a large code base, sometimes the behaviour that you want to implement exists through an unintentional manner. So it’s good to check that the test is failing before writing any code. This also ensures the code you write actually fixes the problem. Lets add the code for this.

```
class StartUpViewModel extends BaseViewModel {

...
final _navigationService = locator<NavigationService>();

Future<void> runStartupLogic() async {
	if (_userService.hasLoggedInUser) {
		// Do logged in stuff
	} else {
		log.v('No user on disk, navigate to the login view');
		_navigationService.replaceWith(Routes.loginView);
  }
}
```


We import the `NavigationService` and in the else view we call `replaceWith` on the navigation service and pass in the `loginView`. If you run the tests now you should see both of the tests passing. At this point I like to refactor a bit more to ensure no maintenance hassles down the line.

### Unit Test Maintenance

The first thing I like to do, especially with ViewModel testing is to create a helper function that does the construction of the ViewModel. This way if the constructor every changes then you don’t have to go update 10’s of unit tests manually and can just update it in one place. So we’ll create a new function called `_getModel` that constructs and returns the viewmodel to us.

```
StartUpViewModel _getModel() => StartUpViewModel();
```


Then you can replace the two manual constructions in the tests with `_getModel()`.

Startup Logic Implementation
----------------------------

To wrap this up we can complete the last 3 parts of the business logic. We’ll write a test that checks that if we have a loggedInUser we call `syncUserAccount` on the user service.

```
test(
    'When hasLoggedInUser is true, should call syncUserAccount on the userService',
    () async {
  final userService = getAndRegisterUserService(hasLoggedInUser: true);
  var model = _getModel();
  await model.runStartupLogic();
  verify(userService.syncUserAccount());
});
```


Running this fails, but then adding the following code makes it pass.

```
Future<void> runStartupLogic() async {
	if (_userService.hasLoggedInUser) {
		log.v('We have a user session on disk. Sync the user profile ... ');
    await _userService.syncUserAccount();

	} else {
		log.v('No user on disk, navigate to the login view');
		_navigationService.replaceWith(Routes.loginView);
  }
}
```


Then we want to get the `currentUser` from the `UserService` , which will only be done if we have a loggedIn User.

```
test('When hasLoggedInUser is true, should get currentUser from userService',
    () async {
  final userService = getAndRegisterUserService(hasLoggedInUser: true);
  var model = _getModel();
  await model.runStartupLogic();
  verify(userService.currentUser);
});
```


If you run this test it’ll fail. In the `runStartupLogic` function we can then get that currentUser for use down the line.

```

...
log.v('We have a user session on disk. Sync the user profile ... ');
await _userService.syncUserAccount();

final currentUser = _userService.currentUser;
log.v('User sync complete. User Profile: $currentUser');

```


Even if you run this test now it’ll still fail. What you need to do is setup the mock to return a value for the currentUser.

```
UserService getAndRegisterUserService({
  bool hasLoggedInUser = false,
  User? currentUser,
}) {
  _removeRegistrationIfExists<UserService>();
  final service = MockUserService();

  when(service.hasLoggedInUser).thenReturn(hasLoggedInUser);
  when(service.currentUser).thenReturn(currentUser ??
      User(
        id: 'default_user',
        email: 'no@email.com',
      ));

  locator.registerSingleton<UserService>(service);
  return service;
}
```


Now this test will pass. The final step is to determine where to navigate based on if the user has a default address set.

```
test(
    'When currentUser does not have an address, navigate to the AddressSelectionView',
    () async {
  final navigationService = getAndRegisterNavigationService();
  getAndRegisterUserService(hasLoggedInUser: true);
  var model = _getModel();
  await model.runStartupLogic();
  verify(navigationService.navigateTo(Routes.addressSelectionView));
});
```


In the startup viewmodel you can now add

```
if (currentUser.hasAddress) {
  log.v('We\'re ready to go! User has all the details to use the app');
  // navigate to the home view
} else {
  log.v('User still needs to select an address for delivery.');
  _navigationService.navigateTo(Routes.addressSelectionView);
}
```


We have to add the `defaultAddress` to the User model in `application_models.dart` and also the new `hasAddress` property.

```
@freezed
class User with _$User {
  User._();

  factory User({
    required String id,
    String? email,
    String? defaultAddress,
  }) = _User;

  bool get hasAddress => defaultAddress?.isNotEmpty ?? false;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```
