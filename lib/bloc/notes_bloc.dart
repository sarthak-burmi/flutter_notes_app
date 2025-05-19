import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_notes_app/di/service_locator.dart';
import 'package:flutter_notes_app/models/note_model.dart';
import 'package:flutter_notes_app/services/notes_service.dart';

import 'package:rxdart/rxdart.dart';

// Events
abstract class NotesEvent {}

class LoadNotes extends NotesEvent {}

class SearchNotes extends NotesEvent {
  final String query;
  final String? categoryFilter;

  SearchNotes({required this.query, this.categoryFilter});
}

class AddNote extends NotesEvent {
  final String title;
  final String content;
  final String? category;

  AddNote({required this.title, required this.content, this.category});
}

class UpdateNote extends NotesEvent {
  final Note note;

  UpdateNote({required this.note});
}

class DeleteNote extends NotesEvent {
  final String id;

  DeleteNote({required this.id});
}

abstract class NotesState {}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<Note> notes;
  final List<String?> categories;
  final String? selectedCategory;

  NotesLoaded({
    required this.notes,
    required this.categories,
    this.selectedCategory,
  });
}

class NotesError extends NotesState {
  final String message;

  NotesError({required this.message});
}

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesService _notesService = getIt<NotesService>();
  StreamSubscription? _notesSubscription;

  final _searchController = BehaviorSubject<Map<String, dynamic>>();

  NotesBloc() : super(NotesInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<SearchNotes>(_onSearchNotes);
    on<AddNote>(_onAddNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);

    _searchController.debounceTime(const Duration(milliseconds: 300)).listen((
      searchParams,
    ) {
      final query = searchParams['query'] as String;
      final categoryFilter = searchParams['categoryFilter'] as String?;

      add(SearchNotes(query: query, categoryFilter: categoryFilter));
    });

    _notesSubscription = _notesService.notesStream.listen((_) {
      add(LoadNotes());
    });
  }

  void _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) {
    try {
      emit(NotesLoading());
      final notes = _notesService.getAllNotes();
      final categories = _notesService.getAllCategories();

      String? selectedCategory;
      if (state is NotesLoaded) {
        selectedCategory = (state as NotesLoaded).selectedCategory;
      }

      emit(
        NotesLoaded(
          notes: notes,
          categories: categories,
          selectedCategory: selectedCategory,
        ),
      );
    } catch (e) {
      emit(NotesError(message: 'Failed to load notes: ${e.toString()}'));
    }
  }

  void _onSearchNotes(SearchNotes event, Emitter<NotesState> emit) {
    try {
      final notes = _notesService.searchNotes(
        event.query,
        categoryFilter: event.categoryFilter,
      );
      final categories = _notesService.getAllCategories();

      emit(
        NotesLoaded(
          notes: notes,
          categories: categories,
          selectedCategory: event.categoryFilter,
        ),
      );
    } catch (e) {
      emit(NotesError(message: 'Search failed: ${e.toString()}'));
    }
  }

  void _onAddNote(AddNote event, Emitter<NotesState> emit) async {
    try {
      await _notesService.createNote(
        title: event.title,
        content: event.content,
        category: event.category,
      );
    } catch (e) {
      emit(NotesError(message: 'Failed to add note: ${e.toString()}'));
    }
  }

  void _onUpdateNote(UpdateNote event, Emitter<NotesState> emit) async {
    try {
      await _notesService.updateNote(event.note);
    } catch (e) {
      emit(NotesError(message: 'Failed to update note: ${e.toString()}'));
    }
  }

  void _onDeleteNote(DeleteNote event, Emitter<NotesState> emit) async {
    try {
      await _notesService.deleteNote(event.id);
      // The notes stream will trigger a reload
    } catch (e) {
      emit(NotesError(message: 'Failed to delete note: ${e.toString()}'));
    }
  }

  void search(String query, {String? categoryFilter}) {
    _searchController.add({'query': query, 'categoryFilter': categoryFilter});
  }

  @override
  Future<void> close() {
    _searchController.close();
    _notesSubscription?.cancel();
    return super.close();
  }
}
