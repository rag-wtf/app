# Document

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

## Overview

The "database" package is a comprehensive solution for managing and interacting with a SurrealDB database in a Flutter application. It is designed to simplify the process of setting up, configuring, and using SurrealDB for data storage and retrieval.

### Key Features

1. **SurrealDB Integration**: The package provides a seamless integration with SurrealDB, allowing developers to easily connect to the database, perform CRUD operations, and manage data schemas.

2. **Schema Management**: It includes functionality to define and manage database schemas, ensuring that the database structure aligns with the application's requirements.

3. **Transaction Support**: The package supports database transactions, enabling developers to perform multiple database operations atomically, which is crucial for maintaining data integrity.

4. **CI/CD Integration**: It comes with built-in GitHub Actions workflows, making it easy to set up continuous integration and continuous deployment pipelines for the project.

5. **Testing Framework**: The package includes a robust testing framework that leverages the "very_good_cli" tool for running unit tests, generating coverage reports, and ensuring code quality.

6. **Documentation and Examples**: The package provides detailed documentation and examples to help developers understand and utilize its features effectively.

### Getting Started

To start using the "database" package in your Flutter project, follow these steps:

1. **Installation**: Add the package to your `pubspec.yaml` file and run `dart pub get` to install it.

2. **Configuration**: Configure the database connection settings, including the SurrealDB endpoint, namespace, database, and authentication credentials.

3. **Schema Definition**: Define the database schemas for your application's data models using the provided schema management tools.

4. **Data Operations**: Use the repository classes to perform create, read, update, and delete operations on the database.

5. **Testing**: Set up and run tests using the provided testing framework to ensure the correctness and reliability of your database operations.

By following these steps, you can effectively integrate the "database" package into your Flutter project and leverage its features to manage your application's data efficiently.

## Usage

### Connecting to the Database

To connect to the SurrealDB database, use the following code:

```dart
final db = locator<Surreal>();
await db.connect(surrealHttpEndpoint);
await db.use(namespace: surrealNamespace, database: surrealDatabase);
await db.signin({'username': surrealUsername, 'password': surrealPassword});
```

### Creating and Managing Schemas

Define and create database schemas using the repository classes:

```dart
if (!await documentRepository.isSchemaCreated(tablePrefix)) {
  await documentRepository.createSchema(tablePrefix, txn);
}
if (!await embeddingRepository.isSchemaCreated(tablePrefix)) {
  await embeddingRepository.createSchema(tablePrefix, '384', txn);
}
if (!await documentEmbeddingRepository.isSchemaCreated(tablePrefix)) {
  await documentEmbeddingRepository.createSchema(tablePrefix, txn);
}
```

### Performing CRUD Operations

Use the repository classes to perform CRUD operations:

```dart
// Create a document
final document = Document(
  id: '${tablePrefix}_${Document.tableName}:$ulid',
  compressedFileSize: 100,
  fileMimeType: 'text/plain',
  contentMimeType: 'text/plain',
  errorMessage: '',
  name: 'Test Document',
  originFileSize: 200,
  status: DocumentStatus.created,
);
await documentRepository.createDocument(tablePrefix, document, txn);

// Read documents
final documents = await documentRepository.getAllDocuments(tablePrefix);

// Update a document
final updatedDocument = document.copyWith(status: DocumentStatus.pending);
await documentRepository.updateDocument(updatedDocument, txn);

// Delete a document
await documentRepository.deleteDocument(document.id!, txn);
```


## Installation 💻

**❗ In order to start using Document you must have the [Flutter SDK][flutter_install_link] installed on your machine.**

Install via `flutter pub add`:

```sh
dart pub add document
```

---

## Continuous Integration 🤖

Document comes with a built-in [GitHub Actions workflow][github_actions_link] powered by [Very Good Workflows][very_good_workflows_link] but you can also add your preferred CI/CD solution.

Out of the box, on each pull request and push, the CI `formats`, `lints`, and `tests` the code. This ensures the code remains consistent and behaves correctly as you add functionality or make changes. The project uses [Very Good Analysis][very_good_analysis_link] for a strict set of analysis options used by our team. Code coverage is enforced using the [Very Good Workflows][very_good_coverage_link].

---

## Running Tests 🧪

For first time users, install the [very_good_cli][very_good_cli_link]:

```sh
dart pub global activate very_good_cli
```

To run all unit tests:

```sh
very_good test --coverage
```

To view the generated coverage report you can use [lcov](https://github.com/linux-test-project/lcov).

```sh
# Generate Coverage Report
genhtml coverage/lcov.info -o coverage/

# Open Coverage Report
open coverage/index.html
```

## Contributing

Contributions to the "database" package are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request on the project's GitHub repository.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [SurrealDB](https://surrealdb.com/) for providing a powerful and flexible database solution.
- [Very Good Ventures](https://verygood.ventures/) for their contributions to the Flutter ecosystem through tools like "very_good_cli" and "very_good_analysis".

[flutter_install_link]: https://docs.flutter.dev/get-started/install
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_white.png#gh-dark-mode-only
[mason_link]: https://github.com/felangel/mason
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://pub.dev/packages/very_good_cli
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_ventures_link]: https://verygood.ventures
[very_good_ventures_link_light]: https://verygood.ventures#gh-light-mode-only
[very_good_ventures_link_dark]: https://verygood.ventures#gh-dark-mode-only
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
