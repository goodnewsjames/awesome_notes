# Awesome Notes Project Documentation

## Introduction
Awesome Notes is a high-performance, offline-first productivity application built with Flutter. The project is engineered to provide an instantaneous user experience by leveraging local persistence as the primary data source, coupled with a robust real-time synchronization engine powered by Firebase.

## Technical Architecture
The application employs a layered modular architecture to ensure separation of concerns, testability, and scalability.

### Core Architectural Layers
*   Presentation Layer: Flutter widgets and pages optimized for reactive UI updates.
*   Logic Layer (Controllers): ChangeNotifiers that manage business logic and UI state while remaining independent of widgets.
*   Infrastructure Layer (Services): Low-level services for data persistence, authentication, and network synchronization.

## Tech Stack and Dependencies
The project utilizes a curated selection of industry-standard packages to provide specific functionality.

### Core Framework and State
*   Flutter/Dart: Cross-platform development framework.
*   Provider: Facilitates dependency injection and state management.
*   UUID: Generates unique identifiers for notes to ensure consistency across synchronized devices.

### Data Persistence
*   Hive and Hive Flutter: A lightweight, high-performance NoSQL key-value store used for local-first persistence.
*   Cloud Firestore: NoSQL document database used for real-time cloud storage and cross-device data mirroring.
*   Hive Generator and Build Runner: Automates the creation of TypeAdapters for model serialization.

### User Authentication
*   Firebase Core and Auth: Scalable authentication backend.
*   Google Sign In: Integration for Google OAuth authentication.
*   Flutter Facebook Auth: Integration for Facebook OAuth authentication.

### UI and Content
*   Flutter Quill: A rich-text editor supporting the Delta format for structured content storage.
*   Google Fonts: Integration for modern typography.
*   Font Awesome Flutter: Enhanced iconography system.

### Connectivity
*   Connectivity Plus: Monitors the device network state to trigger background synchronization.

## Service Infrastructure (Logic Engine)
The following infrastructure services handle the core "behind the scenes" operations of the application.

### AuthService
*   Manages user lifecycles, including sign-up, login, logout, and password resets.
*   Handles multi-provider authentication (Email, Google, Facebook).
*   Provides a persistent authentication stream for the application to react to session changes.

### HiveService
*   Interfaces directly with the local Hive database.
*   Manages note indexing for high-speed retrieval of large datasets.
*   Handles type-safe storage of Note objects using custom TypeAdapters.

### CloudService
*   Abstracts interaction with Firestore collections.
*   Uses User UID-based path isolation to ensure data security and privacy.
*   Provides reactive streams for real-time cloud data monitoring.

### SyncService
*   The coordination hub of the application.
*   Implements the "Last-Write-Wins" conflict resolution logic based on timestamps.
*   Monitors local changes via Hive box watchers.
*   Triggers automated "Push" operations when transitioning from offline to online states.

## State Management and Controllers (UI Engine)
These components translate business logic into reactive UI updates.

### NotesProvider
*   Manages the primary local list of active notes.
*   Implements deep-search algorithms for filtering titles, content, and tags.
*   Handles sorting logic (Date Created, Date Modified) and view toggling (Grid vs List).

### TrashController
*   Manages "Soft-Deleted" notes.
*   Handles restoration logic and permanent "Hard-Delete" triggers for cloud and local storage.

### NewNoteController
*   Manages the state of the active rich-text editor instance.
*   Handles formatting logic and content serialization to the Delta format.

### RegistrationController
*   Coordinates the onboarding and authentication UI flows.
*   Implements a critical safety mechanism that clears all local data before new session initialization.

## Key Feature Implementation

### Offline-First Philosophy
Every user action is committed to Hive immediately. This ensures that the UI never lags due to network latency. The SyncService works in the background to mirror these changes to the cloud once a connection is verified.

### Robust Synchronization
The synchronization engine handles complex scenarios:
*   Real-time Remote Updates: Remote changes are processed immediately via Firestore snapshots.
*   Hard Delete Synchronization: Physical deletions on the server are mirrored to the local storage.
*   Conflict Resolution: If a note is edited on multiple devices, the version with the most recent `dateModified` timestamp is retained.

### Data Privacy and Security
*   Multi-layered authentication prevents unauthorized access.
*   Explicit data-clearing protocols ensure that local Hive storage is wiped during logout and login sessions to protect user privacy.

## Setup and Development

### Configuration
1.  Establish a Firebase project in the Google Cloud Console.
2.  Generate the [firebase_options.dart](cci:7://file:///home/devgoodnews/Resources/awesome_notes/lib/firebase_options.dart:0:0-0:0) file using the FlutterFire CLI and place it in the `lib/` directory.
3.  Configure Facebook and Google credentials in their respective developer portals.
4.  Run `dart run build_runner build` to generate the necessary Hive TypeAdapters.

### Execution
*   Ensure a compatible Flutter SDK version (>= 3.9.2) is installed.
*   Execute `flutter pub get` to install dependencies.
*   Launch the application using `flutter run`.

## 🛠 First-Time App Setup

This project uses Firebase for authentication and sync. For security, API keys are not included in the repository.

1. **Install Flutterfire CLI**: `dart pub global activate flutterfire_cli`
2. **Project Configuration**:
   - Run `flutterfire configure` in the project root.
   - Select your Firebase project.
   - This will automatically generate your local `lib/firebase_options.dart`.
3. **Alternative**: Rename `lib/firebase_options_example.dart` to `lib/firebase_options.dart` and manually paste your keys.
4. **Finalize**: Run `flutter pub get` and `flutter run`.
**TODO**

Clean hive storage after logout 
Log user in immediately after sign up 
Whole pages scrolls
Reduce toolbar white space 
Increase the line spacing 
<!-- Remove save button and add save on exit -->
<!-- Add tag not working  -->
<!-- Optimize typing experience  -->
<!-- Change font to a more typing friendly fonts -->
Reduce fonts size and adjust text align
<!-- Adjust text editing focus to match page focus -->
Ability to move cursor around page
<!-- Show more of the contents in the main page -->
<!-- Remove Facebook auth  -->
add guest mode 
fix poping on back button

where is the best place to log user in immediately after signup , in my registration controller or my auth services and where is 