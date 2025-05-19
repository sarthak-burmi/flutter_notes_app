import 'package:flutter_notes_app/services/notes_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Register the NotesService as a singleton
  final notesService = NotesService();
  await notesService.initialize();
  getIt.registerSingleton<NotesService>(notesService);
}
