import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hive/hive.dart';

part 'note_model.freezed.dart';
part 'note_model.g.dart';

@freezed
@freezed
abstract class Note with _$Note {
  const factory Note({
    required String id,
    required String title,
    required String content,
    String? category,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}

@HiveType(typeId: 0)
class HiveNote {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final String? category;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  HiveNote({
    required this.id,
    required this.title,
    required this.content,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HiveNote.fromNote(Note note) {
    return HiveNote(
      id: note.id,
      title: note.title,
      content: note.content,
      category: note.category,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }

  Note toNote() {
    return Note(
      id: id,
      title: title,
      content: content,
      category: category,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
