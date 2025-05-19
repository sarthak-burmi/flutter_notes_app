import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Add this import
import 'package:flutter_notes_app/bloc/notes_bloc.dart';
import 'package:flutter_notes_app/di/service_locator.dart';
import 'package:flutter_notes_app/models/note_adapter.dart';
import 'package:flutter_notes_app/screens/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_quill/flutter_quill.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive
  await Hive.initFlutter();
  // Register Hive adapters
  Hive.registerAdapter(HiveNoteAdapter());
  // Setup service locator
  await setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotesBloc(),
      child: MaterialApp(
        title: 'Advanced Notes App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        // Add these localization delegates
        localizationsDelegates: const [
          // Add FlutterQuillLocalizations delegate
          FlutterQuillLocalizations.delegate,
          // Standard Flutter delegates
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          // Add other locales you want to support
        ],
        home: const HomeScreen(),
      ),
    );
  }
}
