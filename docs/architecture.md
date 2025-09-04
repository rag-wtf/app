# RAG.WTF App Brownfield Architecture Document

## Executive Summary
This document provides a comprehensive analysis of the existing `rag-wtf/app`, a Flutter-based web application designed for Retrieval-Augmented Generation (RAG). It details the current monorepo architecture, Flutter/Stacked framework, SurrealDB database, and key feature modules including chat, document management, and system settings. The primary purpose of this documentation is to serve as a foundational blueprint for a strategic re-implementation, with key goals of achieving full cross-platform compatibility (iOS, Android, etc.), enhancing core features, and addressing known technical debt.

## Introduction
This document captures the CURRENT STATE of the `rag-wtf/app` codebase, including its monorepo structure, technology stack, real-world patterns, and known technical debt. It serves as a foundational reference for AI and human developers to support the primary goal of re-implementing the existing system with new features, extending it to be fully cross-platform, and addressing current limitations.

### Change Log
| Date | Version | Description | Author |
| :--- | :--- | :--- | :--- |
| 2025-09-04 | 2.0 | Finalized architecture with detailed deployment/security. | Winston (Architect) |
| 2025-09-04 | 1.2 | Added cross-platform database strategy. | Winston (Architect) |
| 2025-09-03 | 1.1 | Added Executive Summary, Guiding Principles, User Context, and prioritized Tech Debt. | Mary (Business Analyst) |
| 2025-09-03 | 1.0 | Initial brownfield analysis | Mary (Business Analyst) |

## Quick Reference - Key Files and Entry Points
### Critical Files for Understanding the System
* [cite_start]**Main Entry Points**: `lib/main_development.dart`, `lib/main_staging.dart`, `lib/main_production.dart` [cite: 15]
* [cite_start]**Configuration**: `pubspec.yaml` [cite: 196][cite_start], `melos.yaml` [cite: 118][cite_start], `.env.example` [cite: 211][cite_start], `firebase.json` [cite: 105][cite_start], `stacked.json` [cite: 197]
* **Core Business Logic**: Logic is modularized within packages, primarily in:
    * [cite_start]`packages/chat/lib/src/services/` [cite: 30, 617-695, 1293-1322]
    * [cite_start]`packages/document/lib/src/services/` [cite: 55, 988-1077, 1105-1144]
    * [cite_start]`packages/settings/lib/src/services/` [cite: 77, 1327-1430, 1441-1541]
* [cite_start]**API Definitions (Consumed)**: External API configurations are defined in `packages/settings/assets/json/llm_providers.json`[cite: 1330].
* **Database Models**: Core data models are defined within their respective packages:
    * [cite_start]`packages/chat/lib/src/services/chat.dart` [cite: 623]
    * [cite_start]`packages/chat/lib/src/services/message.dart` [cite: 695]
    * [cite_start]`packages/document/lib/src/services/document.dart` [cite: 1081]
    * [cite_start]`packages/document/lib/src/services/embedding.dart` [cite: 1144]
    * [cite_start]`packages/database/lib/src/services/connection_setting.dart` [cite: 882]

## High Level Architecture
### Technical Summary
The `rag-wtf/app` is a cross-platform application built with Flutter and Dart, architected as a monorepo managed by Melos. It utilizes the Stacked architecture for state management and UI structure. The application's core functionality is a Retrieval-Augmented Generation (RAG) system, with distinct modules for chat, document processing, database connectivity, and extensive settings management. It uses SurrealDB for its database layer, with configurations for both local (WASM/IndexedDB) and remote instances. Backend services like Firebase and Mixpanel are integrated for analytics and multi-environment configuration.

### Actual Tech Stack
| Category | Technology | Version / Details |
| :--- | :--- | :--- |
| Runtime | Dart, Flutter | [cite_start]SDK: `^3.8.1`, Flutter: `>=3.27.0` [cite: 196] |
| Framework | [cite_start]Stacked Architecture | v3.4.4 [cite: 179] |
| Web Database | SurrealDB (Web) | [cite_start]`surrealdb_wasm` (`^1.1.0+16`) [cite: 196] |
| Native Database | SurrealDB (Native) | `surrealdb` (to be added for mobile/desktop) |
| Build/Tooling| Melos, Docker | [cite_start]Melos (`^6.3.3`) [cite: 196] for monorepo management. [cite_start]Docker for local SurrealDB instance. [cite: 121] |
| Backend Services| Firebase, Mixpanel | [cite_start]Used for analytics and environment configuration. [cite: 105, 179, 500-531] |
| API Style | REST API (Consumed) | [cite_start]Consumes external REST APIs for LLM and embedding services. [cite: 1330] |

### Repository Structure Reality Check
* [cite_start]**Type**: Monorepo [cite: 118]
* **Package Manager**: Dart Pub
* [cite_start]**Notable**: The project is cleanly divided into feature-based packages within the `packages/` directory, promoting modularity and code reuse. [cite: 19]

### Component-to-User Value Mapping
| Module (`packages/`) | User Problem / Value Proposition |
| :--- | :--- |
| [cite_start]**chat** [cite: 27] | Enables users to have conversational interactions with an AI assistant that leverages the knowledge from their documents. |
| [cite_start]**document** [cite: 52] | Allows users to upload, process, and manage the knowledge base (documents) that the RAG system uses to provide answers. |
| [cite_start]**settings** [cite: 74] | Gives users fine-grained control over the entire RAG pipeline, from choosing AI models to tuning retrieval parameters, enabling customization and optimization. |
| [cite_start]**database** [cite: 43] | Provides the underlying data storage and connectivity, allowing users to manage how and where their application data is stored. |

## Guiding Principles for Re-Implementation
* **Cross-Platform Architecture**: All new and refactored components must be architected for full cross-platform compatibility (Web, iOS, Android, Desktop).
* **Platform-Specific Abstraction**: The data layer must abstract the database implementation. A factory or dependency injection will provide the correct implementation at runtime: `surrealdb_wasm` for Web and the native `surrealdb` package for all other platforms.
* **Modular Localization**: Localization logic must be implemented at the package level to be self-contained. The initial supported languages will be English and Chinese.
* **Address Core Technical Debt**: The re-implementation must provide a robust solution for the known concurrency issue in parallel file uploads.
* **Maintain Modularity**: The existing monorepo package structure should be maintained and reinforced, ensuring clear separation of concerns.

Here is the updated version of the "Component Architecture" section with your requested refinements incorporated.

## Component Architecture

The existing modular component architecture, organized as packages within the Melos monorepo, is sound and will be maintained. The re-implementation will focus on refactoring the internals of these components to be platform-agnostic and to incorporate our new database strategy.

### Key Components and Refactoring Strategy

  * [cite\_start]**`database` Package**[cite: 43]: This component will undergo the most significant architectural change. It will provide the concrete, platform-aware implementations for the various repository interfaces defined in the feature packages.
      * **Implementations**: Two sets of concrete repository implementations will be created: one for Web (using `surrealdb_wasm`) and one for native platforms (using the `surrealdb` package).
      * [cite\_start]**Dependency Injection**: The project's Stacked `app.locator.dart` will be modified to conditionally register the correct repository implementations based on Flutter's `kIsWeb` constant[cite: 14, 15, 197].
      * **Configuration**: The Connection Settings UI will save a single, logical connection profile. The platform-specific service implementation will be responsible for translating this profile into the correct connection string (e.g., `indxdb://...` for web, `http://...` for native).
  * [cite\_start]**`chat`** [cite: 27][cite\_start], **`document`** [cite: 52][cite\_start], **`settings`** [cite: 74] Packages: To promote decoupling, each feature package will define its own abstract repository interface (e.g., `IChatRepository`, `IDocumentRepository`). They will depend on these abstract interfaces, removing any direct knowledge of the database implementation.
  * [cite\_start]**`ui` Package**[cite: 93]: This package will be reviewed to ensure all shared widgets are fully responsive and compatible with mobile/desktop paradigms.

### Inter-Package Communication

To make the communication pattern more concrete, a `SharedStateService` managed by Stacked's locator will be implemented. This service will use `Streams` or `ReplaySubjects` to broadcast key application-wide events (e.g., `documentProcessingComplete`, `newChatStarted`). This provides a clear, reactive pattern for packages to communicate state changes without being directly coupled.

### Testing Strategy for Abstraction

A shared suite of integration tests must be created for each of the abstract **repository interfaces**. Both the `DatabaseServiceWeb` and `DatabaseServiceNative` implementations for each interface must pass this entire test suite to guarantee behavioral consistency across all platforms.

### Component Interaction Diagram

This diagram illustrates the core architectural change, with all feature packages communicating through their repository interfaces, which are implemented by the database package.

```mermaid
graph TD
    subgraph Feature Packages
        A[chat (defines IChatRepository)]
        B[document (defines IDocumentRepository)]
        C[settings (defines ISettingsRepository)]
    end

    subgraph Core Services
        D{database (Implements Feature Repositories)}
    end

    subgraph Platform Implementations
        E[surrealdb_wasm (Web)]
        F[surrealdb (Native)]
    end

    A --> D
    B --> D
    C --> D
    D -- conditionally uses --> E
    D -- conditionally uses --> F
```

## External API Integration
### Docling Serve API
* **Purpose**: To provide robust, specialized document loading and data extraction.
* **Documentation**: [https://github.com/docling-project/docling-serve](https://github.com/docling-project/docling-serve)
* **Base URL**: `https://docling.rag.wtf/v1`
* **Authentication**: Conditional API Key in `X-Api-Key` header.
* **Key Endpoints Used**: `POST /convert/file`
* **Integration Method**: The `DocumentApiService` in `packages/document` will first send the file to Docling for content extraction. The clean text is then sent to the existing `/split` endpoint for chunking.

### Split API
* **Purpose**: To provide text chunking with different chunking strategies.
* **Documentation**: [https://github.com/rag-wtf/split](https://github.com/rag-wtf/split)
* **Base URL**: `https://split.rag.wtf`
* **Authentication**: API Key
* **Key Endpoints Used**: `POST /split`
* **Integration Method**: The `DocumentApiService` in `packages/document` will send the clean text to the existing `/split` endpoint for chunking.

### Embedding API
* **Purpose**: To generate vector embeddings for text chunks.
* **Documentation**: [https://platform.openai.com/docs/api-reference/embeddings](https://platform.openai.com/docs/api-reference/embeddings)
* **Base URL**: Defaults to `https://api.openai.com/v1`, user-configurable.
* **Authentication**: API Key.
* **Key Endpoints Used**: `POST /v1/embeddings`
* **Integration Method**: Integrated into the `document` and `chat` packages.

### Chat Completion API
* **Purpose**: To generate final, context-aware answers based on user queries and relevant document chunks.
* **Documentation**: [https://platform.openai.com/docs/api-reference/chat](https://platform.openai.com/docs/api-reference/chat)
* **Base URL**: Defaults to `https://api.openai.com/v1`, user-configurable.
* **Authentication**: API Key.
* **Key Endpoints Used**: `POST /v1/chat/completions`
* **Integration Method**: Integrated into the `chat` package.

### Audio Transcription API
* **Purpose**: To transcribe audio files into text.
* **Documentation**: [https://platform.openai.com/docs/api-reference/audio/createTranscription](https://platform.openai.com/docs/api-reference/audio/createTranscription)
* **Base URL**: Defaults to `https://api.openai.com/v1`, user-configurable.
* **Authentication**: API Key.
* **Key Endpoints Used**: `POST /v1/audio/transcriptions`
* **Integration Method**: Integrated into `document` and `chat` packages.

### Text-to-Speech (TTS) API
* **Purpose**: To convert text into spoken audio.
* **Documentation**: [https://platform.openai.com/docs/api-reference/audio/createSpeech](https://platform.openai.com/docs/api-reference/audio/createSpeech)
* **Base URL**: Defaults to `https://api.openai.com/v1`, user-configurable.
* **Authentication**: API Key.
* **Key Endpoints Used**: `POST /v1/audio/speech`
* **Integration Method**: Integrated into `chat` and `document` packages.

### Reranker API
* **Purpose**: To improve search relevance by re-ranking retrieved document chunks.
* **Documentation**: [https://docs.cohere.com/v1/reference/rerank](https://docs.cohere.com/v1/reference/rerank)
* **Base URL**: Defaults to `https://api.cohere.com/v1`, user-configurable.
* **Authentication**: API Key.
* **Key Endpoints Used**: `POST /v1/rerank`
* **Integration Method**: Integrated into the `chat` service's core RAG workflow.

## Source Tree Integration

### Existing Project Structure

The current project follows a clean, package-based monorepo structure. New code will be added within this existing pattern. For context, key service areas currently look like this:

```plaintext
packages/
├── chat/
│   └── lib/src/services/
│       ├── chat_api_service.dart
│       └── chat_service.dart
├── database/
│   └── lib/src/services/
│       └── connection_setting_service.dart
├── document/
│   └── lib/src/services/
│       └── document_api_service.dart
└── settings/
    └── lib/src/services/
        └── setting_service.dart
```

### New File Organization

To integrate the new features, the following files will be added, respecting the existing structure. This is not an exhaustive list but shows the intended placement of key new logic:

```plaintext
packages/
├── chat/
│   └── lib/src/services/
│       ├── ... (existing files)
│       ├── reranker_api_service.dart    # New: Handles Cohere Reranker API
│       └── tts_api_service.dart         # New: Handles OpenAI TTS API
├── database/
│   └── lib/src/services/
│       ├── ... (existing files)
│       ├── database_service.dart        # New: Abstract interface
│       ├── database_service_native.dart # New: Mobile/Desktop implementation
│       └── database_service_web.dart    # New: Web implementation (WASM)
└── document/
    └── lib/src/services/
        ├── ... (existing files)
        ├── audio_transcription_service.dart # New: Handles OpenAI Audio API
        └── docling_api_service.dart         # New: Handles Docling Serve API
```

### Key Components and Refactoring Strategy

  * **`database` Package**: This component will undergo the most significant architectural change to implement the **Platform-Specific Abstraction** pattern.
  * **`chat`, `document` Packages**: These components will be refactored to be platform-agnostic and integrate the new API services for their respective domains.
  * **`settings` Package (UPDATED)**: This component will be updated to manage the new configurations for the Docling, Audio Transcription, TTS, and Reranker APIs. [cite\_start]This includes potentially updating the UI in the `SettingsView` [cite: 81] [cite\_start]and ensuring the `SettingService` [cite: 78] can store and retrieve these new configurations.
  * **`ui` Package**: This package containing shared widgets will be reviewed to ensure all components are fully responsive and compatible with mobile/desktop interaction patterns.

## Infrastructure and Deployment Integration

### Existing Infrastructure
* [cite_start]**Current Deployment**: CI/CD pipeline managed by GitHub Actions (`.github/workflows/deploy.yaml`) deploys the web application to GitHub Pages and Netlify [cite: 1918-1922].
* **Infrastructure Tools**: GitHub Actions, Melos, Docker.

### Enhancement Deployment Strategy
* **Deployment Approach**: The existing web deployment pipeline will be maintained. New, separate GitHub Actions workflows will be created for native platforms.
* **Infrastructure Changes**: This will require setting up deployment pipelines for the Apple App Store and Google Play Store.
* **Environment Parity**: Native applications will be built with distinct flavors/schemes (dev/stg/prod) to mirror the existing web environments.

### Secure Credential Management
* **Strategy**: All sensitive credentials for native builds (Apple Developer certificates, Google Play Store service account keys, etc.) **must** be stored as encrypted **GitHub Secrets**.

### Rollback Strategy & Risk Mitigation
* **Rollback Method**:
    * **Web**: Re-deploying a previous successful commit/tag.
    * **Mobile/Desktop**: Submitting a previous stable version to the respective app stores.
* [cite_start]**Risk Mitigation**: A feature flag system will be implemented using **Firebase Remote Config** [cite: 105-117]. All new, major features must be placed behind feature flags.