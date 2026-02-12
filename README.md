# 📝 Awesome Notes

A modern, offline-first notes application built with Flutter. Awesome Notes provides a seamless experience for capturing thoughts, featuring rich-text editing, real-time cloud synchronization, and robust local persistence.

## Tech Stack

-   **Frontend**: [Flutter](https://flutter.dev) (Dart)
-   **State Management**: [Provider](https://pub.dev/packages/provider) with `ChangeNotifier`
-   **Local Database**: [Hive](https://pub.dev/packages/hive) (NoSQL, fast persistence)
-   **Backend**: [Firebase](https://firebase.google.com)
    -   **Authentication**: Email/Password, Google Sign-In, and Facebook Auth.
    -   **Cloud Database**: Firestore (Real-time synchronization).
-   **Rich Text Editor**: [Flutter Quill](https://pub.dev/packages/flutter_quill)
-   **Connectivity**: [Connectivity Plus](https://pub.dev/packages/connectivity_plus) for handling offline states.

---

## Architecture & Folder Structure

The project follows a clean, modular structure that separates UI, logic, and data. This promotes maintainability and scalability.

```text
lib/
├── change_notifiers/  # State management logic (ViewModels/Controllers)
├── core/             # App-wide constants, platform-specific dialogs, and utilities
│   ├── utils/        # Helper extensions and formatting tools
├── enums/            # Typed definitions (e.g., sort orders)
├── models/           # Data entities and Hive adapters
├── pages/            # Feature-specific screens (UI)
├── services/         # Infrastructure layers (Auth, Storage, Sync)
└── widgets/          # Reusable UI components and custom dialogs
```

### Why this architecture?

1.  **Separation of Concerns**: By isolating business logic in `change_notifiers` and infrastructure in `services`, the UI remains lean and focused on presentation.
2.  **Offline-First Strategy**: Data is always saved locally to `Hive` first. This ensures high performance and full functionality even without an internet connection.
3.  **Reactive UI**: We use the `Provider` pattern. When data changes in the `NotesProvider`, the UI updates automatically and efficiently.
4.  **Abstracted Sync Logic**: The `SyncService` manages the complex interaction between local `Hive` boxes and remote `Firestore` collections, handling conflict resolution and pending uploads automatically.

---

##  Core Features

###  Advanced Authentication
-   **Multi-Provider Support**: Securely sign in using Email/Password, Google, or Facebook.
-   **Verification Flow**: Built-in email verification to ensure account security.

### Note Management
-   **Rich Text Editing**: Full markdown-style editing powered by Flutter Quill.
-   **Tagging System**: Organize notes with custom tags for quick filtering.
-   **Dynamic Search**: Instant search across titles, content, and tags using custom deep-search algorithms.
-   **Sorting & View Options**: Toggle between Grid/List views and sort by creation or modification date.

###  Reliable Synchronization
-   **Real-time Updates**: Changes on one device reflect instantly on others when online.
-   **Background Sync**: Automatically pushes local changes to the cloud once connectivity is restored.
-   **Soft-Deletes (Trash)**: Notes aren't immediately purged. They move to a "Trash" state, allowing for recovery or permanent deletion.

---

## Setup & Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/your-repo/awesome_notes.git
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the application**:
    ```bash
    flutter run
    ```

> [!NOTE]
> Ensure you have a valid `firebase_options.dart` file configured for your Firebase project to enable authentication and cloud sync.

---

## Project Evolution
From its inception, the project aimed to solve the "input lag" typical of cloud-dependent note apps. By prioritizing local-first storage and leveraging Dart's asynchronous streams for synchronization, Awesome Notes offers a "zero-latency" feel while maintaining data safety across devices.
