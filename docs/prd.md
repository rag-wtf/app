# RAG.WTF App Brownfield Enhancement PRD

## Intro Project Analysis and Context

### Existing Project Overview

*   **Analysis Source**: The analysis is based on the existing document `docs/architecture.md`.
*   **Current Project State**: The `rag-wtf/app` is a cross-platform application built with Flutter and Dart, architected as a monorepo. It utilizes the Stacked architecture for state management. The application's core functionality is a Retrieval-Augmented Generation (RAG) system, with modules for chat, document processing, and settings. It uses SurrealDB for its database layer.

### Available Documentation Analysis

The `docs/architecture.md` document provides a good overview. Based on it, here's a summary of available documentation:

*   [x] Tech Stack Documentation
*   [x] Source Tree/Architecture
*   [x] API Documentation
*   [ ] UX/UI Guidelines
*   [x] Technical Debt Documentation
*   [ ] Other:

### Enhancement Scope Definition

*   **Enhancement Type**:
    *   [x] New Feature Addition
    *   [x] Integration with New Systems
    *   [x] Bug Fix and Stability Improvements
*   **Enhancement Description**: The project will be enhanced to support cross-platform functionality (iOS, Android). It will integrate with additional external APIs to create a full-featured RAG system, and a key part of this enhancement is the introduction of an evaluation metrics framework to measure the performance of different RAG techniques.
*   **Impact Assessment**:
    *   [ ] Minimal Impact (isolated additions)
    *   [ ] Moderate Impact (some existing code changes)
    *   [x] Significant Impact (substantial existing code changes)
    *   [x] Major Impact (architectural changes required)

### Goals and Background Context

*   **Goals**:
    *   To showcase the improvements in performance of the RAG system when applying the improvement techniques.
    *   To implement a RAG pipeline evolution roadmap, from a simple bypass to advanced techniques.
    *   To provide a framework to quickly test and evaluate different RAG improvement techniques.
*   **Background**: This enhancement is needed to systematically evaluate and improve the RAG system's performance. The current system lacks a structured way to test and compare different RAG techniques. This project will implement a roadmap of improvements, backed by a robust evaluation framework, to guide the development and demonstrate the value of each enhancement.

## Requirements (Prioritized with MoSCoW)

### Must Have
*These are critical for the initial delivery.*
*   **FR2 (Revised)**: The application's RAG pipeline MUST be implemented in stages, starting from a "Short-Document Bypass" and progressively adding complexity.
*   **FR3**: Implement a "Short-Document Bypass (No RAG)".
*   **FR4**: Implement a "Simplest RAG (Lexical Search)".
*   **FR5**: Implement a "Standard RAG (Semantic Search)".
*   **FR9**: Calculate and display evaluation metrics for each RAG pipeline level.
*   **NFR2**: Evaluation metric calculations SHOULD NOT significantly degrade performance.
*   **NFR3**: Maintain the existing modular monorepo structure.
*   **NFR4 (Revised)**: All new, major features MUST be placed behind feature flags managed through a `.env` file.
*   **CR1**: Maintain compatibility with the existing SurrealDB database schema.
*   **CR3**: Maintain compatibility with the existing external APIs.

### Should Have
*Important, but can be addressed after the initial "Must Have" features are complete.*
*   **FR6**: Implement an "Advanced RAG" pipeline with modular improvements (like Hybrid Search and Re-ranking).
*   **FR7**: Implement "Moonshot" RAG techniques.
*   **FR8**: Implement a "Personalized Knowledge Base".

### Could Have
*Desirable features that can be addressed in the future.*
*   **FR1 (Low Priority)**: The application MUST be able to run on iOS and Android platforms.
*   **NFR1**: The cross-platform implementation MUST reuse as much code as possible.
*   **CR2**: Maintain UI/UX consistency when ported to mobile platforms.

## User Interface Enhancement Goals

### Integration with Existing UI
The new `EvaluationView` will be a new, top-level view in the application, likely accessible from the main navigation. It will be designed to be visually consistent with the rest of the application.

### Modified/New Screens and Views
*   **New `EvaluationView`**: A new, dedicated view will be created to display the evaluation metrics for the different RAG pipeline levels. This view will be designed to allow users to easily compare the performance of different techniques, potentially using charts and tables.
*   **New "RAG Pipeline Level" Selector**: A mechanism (e.g., a dropdown or a slider) will be added to the `SettingsView` to allow developers to select and configure the active RAG pipeline level (from Level 0 to Level 4).
*   **Modifications to `SettingsView`**: The `SettingsView` will be updated to dynamically show or hide settings that are only relevant to the selected RAG pipeline level.

### UI Consistency Requirements
*   **Visual Consistency**: All new UI components MUST adhere to the existing visual design of the application, using the same color palette, typography, and spacing.
*   **Interaction Consistency**: New interactive elements should behave consistently with existing elements.
*   **Responsive Design**: All new UI components must be fully responsive and work well on different screen sizes.

## Technical Constraints and Integration Requirements

This enhancement will adhere to the existing technical foundation of the project as documented in `docs/architecture.md`. Key considerations include:
*   **Technology Stack**: The enhancement will be built using Flutter/Dart and the Stacked architecture.
*   **Monorepo Structure**: All new code will be organized within the existing Melos-managed monorepo, likely in new or existing packages.
*   **Database Integration**: The system will continue to use SurrealDB. Any new data models will be designed to be compatible with the existing schema.
*   **API Integration**:
    *   **Existing Integrated APIs**: The enhancement will continue to use the existing integrations for Split, Embeddings, and Chat Completion APIs.
    *   **New APIs to be Integrated**: The project will require new integrations for the Docling Serve, Audio Transcription, Text-to-Speech (TTS), and Reranker APIs.

## Epic and Story Structure

This enhancement will be managed as a single, comprehensive epic.

### Epic 1: RAG Pipeline Evolution and Evaluation Framework

**Epic Goal**: To systematically enhance the application's RAG capabilities through a multi-level implementation roadmap and to introduce a comprehensive evaluation framework to measure and validate the performance of each enhancement.

**Integration Requirements**: All new components must integrate with the existing Stacked architecture and Melos monorepo structure. The system must maintain compatibility with the existing SurrealDB schema and external APIs. All new features should be introduced with feature flags in the `.env` file.

### User Stories

#### Part 1: Must-Haves (Core Framework and Baseline)

*   **Story 1.1: Foundational Setup**
    *   **As a** developer, **I want** to set up the basic structure for the evaluation framework and implement a feature flag system using `.env` files, **so that** I have the foundational tools needed for the subsequent enhancements.
    *   **Acceptance Criteria**:
        1.  A new `EvaluationView` is created and accessible from the main navigation.
        2.  A feature flag system reading from a `.env` file is implemented.
        3.  The `SettingsView` has a new selector for the RAG pipeline level, controlled by a feature flag.
    *   **Integration Verification**:
        1.  The application still runs without errors with the new view and feature flag system.
        2.  Existing settings in `SettingsView` are not affected.

*   **Story 1.2: Level 0 - Short-Document Bypass**
    *   **As a** user, **I want** the system to bypass the RAG pipeline for short documents that fit in the context window, **so that** I can get faster answers for small documents.
    *   **Acceptance Criteria**:
        1.  When a document's length is below a configurable threshold, the entire document is "stuffed" into the prompt.
        2.  The evaluation framework can measure and display metrics for this level (Correctness, Speed, etc.).
    *   **Integration Verification**:
        1.  The standard RAG pipeline is not affected when the bypass is not triggered.

*   **Story 1.3: Level 1 - Lexical Search**
    *   **As a** user, **I want** the system to be able to use a simple keyword-based search for retrieval, **so that** I have a baseline RAG implementation.
    *   **Acceptance Criteria**:
        1.  The system can use a full-text search index for retrieval instead of vector search.
        2.  This pipeline can be selected via the RAG pipeline level selector.
        3.  The evaluation framework can measure and display metrics for this level (Hit Rate, MRR, etc.).
    *   **Integration Verification**:
        1.  The existing vector search functionality is not affected.

*   **Story 1.4: Level 2 - Standard RAG (Baseline)**
    *   **As a** developer, **I want** to ensure the existing Standard RAG (semantic search) is established as the baseline for comparison, **so that** I can measure the impact of other techniques against it.
    *   **Acceptance Criteria**:
        1.  The existing semantic search pipeline is designated as Level 2.
        2.  The evaluation framework is fully integrated with this level and can display all relevant metrics.
    *   **Integration Verification**:
        1.  The existing RAG functionality continues to work as expected.

#### Part 2: Should-Haves (Advanced Features)

*   **Story 1.5: Level 3 - Advanced RAG**
    *   **As a** user, **I want** the system to use advanced techniques like Hybrid Search and a Re-ranker, **so that** I get more accurate and relevant answers.
    *   **Acceptance Criteria**:
        1.  A Hybrid Search (combining vector and metadata filtering) is implemented.
        2.  A Re-ranker is added to the retrieval process to improve context quality.
        3.  The evaluation framework can measure the impact of these techniques on metrics like nDCG and Context Precision.
    *   **Integration Verification**:
        1.  The Standard RAG pipeline can still be used for comparison.

*   **Story 1.6: Level 4 - "Moonshot" Techniques**
    *   **As a** user, **I want** the system to use state-of-the-art techniques like Contextual Enrichment and HyDE, **so that** the answers are even more precise and contextually aware.
    *   **Acceptance Criteria**:
        1.  Contextual Enrichment is added to the ingestion process.
        2.  Hypothetical Answer Search (HyDE) is implemented as a retrieval strategy.
        3.  The evaluation framework can A/B test these techniques against the Advanced RAG pipeline.
    *   **Integration Verification**:
        1.  The Advanced RAG pipeline is not negatively affected.

*   **Story 1.7: Personalized Knowledge Base**
    *   **As a** user, **I want** the system to learn from my interactions, **so that** it can provide faster and more tailored answers over time.
    *   **Acceptance Criteria**:
        1.  A mechanism to store and retrieve user interaction data is implemented.
        2.  The retrieval process is enhanced to use this personalized data.
        3.  The evaluation framework can track query latency and user satisfaction over time.
    *   **Integration Verification**:
        1.  The core RAG functionality works correctly for new users with no interaction history.
