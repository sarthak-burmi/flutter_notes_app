# 📓 Advanced Notes App

A feature-rich notes application built with Flutter, featuring category organization, powerful search functionality, and a beautiful Material Design interface.

![Advanced Notes App]([https://github.com/yourusername/flutter_notes_app/raw/main/screenshots/app_preview.png](https://github.com/sarthak-burmi/flutter_notes_app/blob/main/Screenshot_1747663705.png))

---

## ✨ Features

- ✏️ Create, view, edit, and delete notes  
- 🔍 Real-time search functionality with debouncing  
- 📂 Categorize notes for better organization  
- 🏷️ Filter notes by category  
- 💾 Persistent storage using Hive database  
- 🌓 Material Design UI with customizable themes  
- 📱 Responsive layout that works on various screen sizes  

---

## 🏗️ Architecture

This app follows the **BLoC (Business Logic Component)** pattern for state management, providing a clean separation of concerns and enhancing maintainability.

### 🔧 Key Components

- **Models**: Defines the data structures for notes and categories  
- **BLoC**: Handles business logic and state management  
- **Services**: Manages data operations and storage  
- **UI**: Presents the user interface and handles user interactions  

### 📚 Libraries Used

- [`flutter_bloc`](https://pub.dev/packages/flutter_bloc): BLoC pattern for state management  
- [`hive`](https://pub.dev/packages/hive): Lightweight, fast NoSQL database  
- [`freezed`](https://pub.dev/packages/freezed): Code generation for immutable classes  
- [`uuid`](https://pub.dev/packages/uuid): Generates unique identifiers  
- [`rxdart`](https://pub.dev/packages/rxdart): Advanced stream operations  
- [`intl`](https://pub.dev/packages/intl): Internationalization and formatting  

---

## 📁 Project Structure

```
lib/
├── bloc/
│   └── notes_bloc.dart
├── di/
│   └── service_locator.dart
├── models/
│   └── note_model.dart
├── screens/
│   ├── add_edit_note_screen.dart
│   ├── home_screen.dart
│   └── note_detail_screen.dart
├── services/
│   └── notes_service.dart
└── main.dart
```

---

## 🚀 Setup and Installation

### ✅ Prerequisites

- Flutter SDK (version 3.0.0 or higher)  
- Dart SDK (version 2.17.0 or higher)  
- IDE (VS Code, Android Studio, IntelliJ IDEA)

### 🛠 Getting Started

1. **Clone the repository**

```bash
git clone https://github.com/yourusername/flutter_notes_app.git
cd flutter_notes_app
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Run code generation (Freezed and Hive Adapters)**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Run the app**

```bash
flutter run
```

---

## 📱 Usage Guide

### 📝 Creating a Note

- Tap the **`+`** floating action button on the home screen  
- Enter a title, content, and optionally select a category  
- Tap **Save** to create the note  

### 🔍 Searching Notes

- Use the search bar at the top of the home screen  
- Start typing to see matching results in real-time  
- Filter search results by selecting a category chip  

### ✏️ Editing a Note

- Tap on a note from the home screen  
- View the note details  
- Tap the **Edit** button to modify  
- Make your changes and tap **Save**  

### 🗑️ Deleting a Note

- Open a note  
- Tap the **delete** icon in the app bar  
- Confirm deletion in the dialog  

---

## 🧠 Code Highlights

### 📦 Notes BLoC

Manages app state and handles events like loading, searching, adding, updating, and deleting notes.

```dart
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  // Implementation details...

  // Helper method for search with debounce
  void search(String query, {String? categoryFilter}) {
    _searchController.add({
      'query': query,
      'categoryFilter': categoryFilter,
    });
  }
}
```

### 🛠 Notes Service

Provides abstraction for data operations, making it easier to change the storage mechanism.

```dart
class NotesService {
  // Implementation details...

  // Search notes by query and category
  List<Note> searchNotes(String query, {String? categoryFilter}) {
    // Search implementation...
  }
}
```

### 🏠 Home Screen

Displays list of notes and search/filter functionality.

```dart
class HomeScreen extends StatefulWidget {
  // Implementation details...
}
```

---

## 🤝 Contributing

Contributions are welcome!  
Please feel free to submit a Pull Request.

1. Fork the repository  
2. Create your feature branch  
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. Commit your changes  
   ```bash
   git commit -m 'Add some amazing feature'
   ```
4. Push to the branch  
   ```bash
   git push origin feature/amazing-feature
   ```
5. Open a Pull Request

---

## 🙏 Acknowledgments

- The Flutter team for the amazing framework  
- Open-source community for the libraries used  
- Everyone who contributed to the development and testing of this app  
