import 'package:flutter_notes_app/models/note_model.dart';
import 'package:hive/hive.dart';

// Hive Type Adapter for Note
class HiveNoteAdapter extends TypeAdapter<HiveNote> {
  @override
  final typeId = 0;

  @override
  HiveNote read(BinaryReader reader) {
    return HiveNote(
      id: reader.read(),
      title: reader.read(),
      content: reader.read(),
      category: reader.read(),
      createdAt: reader.read(),
      updatedAt: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, HiveNote obj) {
    writer.write(obj.id);
    writer.write(obj.title);
    writer.write(obj.content);
    writer.write(obj.category);
    writer.write(obj.createdAt);
    writer.write(obj.updatedAt);
  }
}
