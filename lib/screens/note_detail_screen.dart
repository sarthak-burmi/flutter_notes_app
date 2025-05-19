import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_notes_app/bloc/notes_bloc.dart';
import 'package:flutter_notes_app/di/service_locator.dart';
import 'package:flutter_notes_app/models/note_model.dart';
import 'package:flutter_notes_app/screens/add_edit_note_screen.dart';
import 'package:flutter_notes_app/services/notes_service.dart';
import 'package:intl/intl.dart';

class NoteDetailScreen extends StatefulWidget {
  final String noteId;

  const NoteDetailScreen({Key? key, required this.noteId}) : super(key: key);

  @override
  _NoteDetailScreenState createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final _notesService = getIt<NotesService>();
  final _dateFormat = DateFormat('MMM dd, yyyy HH:mm');
  late Note? _note;

  @override
  void initState() {
    super.initState();
    _note = _notesService.getNoteById(widget.noteId);
  }

  @override
  Widget build(BuildContext context) {
    if (_note == null) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text('Note not found'),
          backgroundColor: Colors.deepPurple,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.deepPurple.withOpacity(0.6),
              ),
              const SizedBox(height: 16),
              Text(
                'The requested note was not found',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // Modern SliverAppBar
          _buildSliverAppBar(),

          // Note metadata
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: _buildNoteMetadata(),
            ),
          ),

          // Note content
          SliverToBoxAdapter(child: _buildNoteContent()),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.0,
      pinned: true,
      backgroundColor: Colors.deepPurple,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _note!.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black38,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.deepPurple, Colors.deepPurple.shade700],
            ),
          ),
        ),
      ),
      actions: [
        // Edit button
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteEditScreen(note: _note),
              ),
            ).then((_) {
              // Refresh note data when returning from edit screen
              setState(() {
                _note = _notesService.getNoteById(widget.noteId);
              });
            });
          },
        ),
        // Delete button
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.white),
          onPressed: _showDeleteConfirmation,
        ),
      ],
    );
  }

  Widget _buildNoteMetadata() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category chip
          if (_note!.category != null)
            Chip(
              label: Text(
                _note!.category!,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.deepPurple,
            ),

          const SizedBox(height: 16.0),

          // Timestamps
          _buildTimestampRow(
            icon: Icons.calendar_today,
            label: 'Created',
            timestamp: _note!.createdAt,
          ),

          const SizedBox(height: 8.0),

          _buildTimestampRow(
            icon: Icons.update,
            label: 'Updated',
            timestamp: _note!.updatedAt,
          ),
        ],
      ),
    );
  }

  Widget _buildTimestampRow({
    required IconData icon,
    required String label,
    required DateTime timestamp,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16.0, color: Colors.deepPurple),
        const SizedBox(width: 8.0),
        Text(
          '$label: ${_dateFormat.format(timestamp)}',
          style: TextStyle(color: Colors.grey[800], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildNoteContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          _note!.content,
          style: TextStyle(fontSize: 16, color: Colors.grey[900], height: 1.5),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              'Delete Note',
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to delete "${_note!.title}"?',
              style: TextStyle(color: Colors.grey[800]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog

                  // Delete the note
                  context.read<NotesBloc>().add(DeleteNote(id: widget.noteId));

                  // Go back to home screen
                  Navigator.pop(context);
                },
                child: const Text(
                  'DELETE',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
