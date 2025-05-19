import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_notes_app/bloc/notes_bloc.dart';
import 'package:flutter_notes_app/di/service_locator.dart';
import 'package:flutter_notes_app/models/note_model.dart';
import 'package:flutter_notes_app/services/notes_service.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'dart:convert';

class NoteEditScreen extends StatefulWidget {
  final Note? note;

  const NoteEditScreen({Key? key, this.note}) : super(key: key);

  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final _notesService = getIt<NotesService>();
  late FormGroup _form;
  late QuillController _quillController;
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  List<String?> _categories = [];
  bool _isRichTextEnabled = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _initializeQuillController();
    _loadCategories();
  }

  void _initializeForm() {
    _form = FormGroup({
      'title': FormControl<String>(
        value: widget.note?.title ?? '',
        validators: [
          Validators.required,
          Validators.minLength(5),
          Validators.maxLength(100),
        ],
      ),
      'content': FormControl<String>(
        value: widget.note?.content ?? '',
        validators: [Validators.required, Validators.minLength(10)],
      ),
      'category': FormControl<String>(value: widget.note?.category),
      'newCategory': FormControl<String>(),
    });
  }

  void _initializeQuillController() {
    _quillController = QuillController.basic();

    if (widget.note != null) {
      try {
        final dynamic jsonData = jsonDecode(widget.note!.content);
        if (jsonData is List) {
          _quillController = QuillController(
            document: Document.fromJson(jsonData),
            selection: const TextSelection.collapsed(offset: 0),
          );
          _isRichTextEnabled = true;
        }
      } catch (e) {
        _quillController.clear();
        _quillController.document.insert(0, widget.note!.content);
      }
    }
  }

  void _loadCategories() {
    _categories = _notesService.getAllCategories();

    const predefinedCategories = ['Work', 'Personal', 'Ideas', 'Archive'];
    for (final category in predefinedCategories) {
      if (!_categories.contains(category)) {
        _categories.add(category);
      }
    }

    _categories.sort((a, b) {
      if (a == null) return 1;
      if (b == null) return -1;
      return a.compareTo(b);
    });
  }

  @override
  void dispose() {
    _form.dispose();
    _quillController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          widget.note == null ? 'Add Note' : 'Edit Note',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: [
          // Rich text toggle button
          IconButton(
            icon: Icon(
              _isRichTextEnabled ? Icons.text_format : Icons.format_shapes,
              color: Colors.white,
            ),
            onPressed: _toggleRichText,
            tooltip: 'Toggle rich text editing',
          ),

          // Save button
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: ReactiveFormBuilder(
        form: () => _form,
        builder: (context, form, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title field
                    _buildTitleField(),

                    const SizedBox(height: 16.0),

                    // Category section
                    _buildCategorySection(),

                    const SizedBox(height: 16.0),

                    // Content field
                    _buildContentField(),

                    const SizedBox(height: 24.0),

                    // Save button
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleField() {
    return ReactiveTextField<String>(
      formControlName: 'title',
      decoration: InputDecoration(
        labelText: 'Title',
        hintText: 'Enter note title (5-100 characters)',
        prefixIcon: const Icon(Icons.title, color: Colors.deepPurple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.deepPurple.shade300, width: 2),
        ),
      ),
      validationMessages: {
        ValidationMessage.required: (_) => 'Title is required',
        ValidationMessage.minLength:
            (_) => 'Title must be at least 5 characters',
        ValidationMessage.maxLength:
            (_) => 'Title must be at most 100 characters',
      },
    );
  }

  Widget _buildCategorySection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ReactiveDropdownField<String>(
            formControlName: 'category',
            decoration: InputDecoration(
              labelText: 'Category',
              hintText: 'Select a category',
              prefixIcon: const Icon(Icons.category, color: Colors.deepPurple),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.deepPurple.shade300,
                  width: 2,
                ),
              ),
            ),
            items: [
              ..._categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category ?? 'Uncategorized'),
                );
              }),
              const DropdownMenuItem(
                value: 'new_category',
                child: Text('+ Create new category'),
              ),
            ],
            onChanged: (control) {
              if (control.value == 'new_category') {
                setState(() {});
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContentField() {
    return _isRichTextEnabled
        ? _buildRichTextEditor()
        : ReactiveTextField<String>(
          formControlName: 'content',
          decoration: InputDecoration(
            labelText: 'Content',
            hintText: 'Enter note content (min 10 characters)',
            prefixIcon: const Icon(Icons.description, color: Colors.deepPurple),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.deepPurple.shade300,
                width: 2,
              ),
            ),
            alignLabelWithHint: true,
          ),
          maxLines: 10,
          minLines: 5,
          validationMessages: {
            ValidationMessage.required: (_) => 'Content is required',
            ValidationMessage.minLength:
                (_) => 'Content must be at least 10 characters',
          },
        );
  }

  Widget _buildRichTextEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Content',
          style: TextStyle(
            color: Colors.deepPurple,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),

        // Quill toolbar
        QuillSimpleToolbar(
          controller: _quillController,
          config: QuillSimpleToolbarConfig(
            showClipboardPaste: true,
            embedButtons: FlutterQuillEmbeds.toolbarButtons(),
            buttonOptions: QuillSimpleToolbarButtonOptions(
              base: QuillToolbarBaseButtonOptions(
                afterButtonPressed: () {
                  _editorFocusNode.requestFocus();
                },
              ),
            ),
          ),
        ),

        const SizedBox(height: 8.0),

        // Quill editor
        Container(
          height: 300.0,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.deepPurple.shade100),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: QuillEditor(
            controller: _quillController,
            focusNode: _editorFocusNode,
            scrollController: _editorScrollController,
            config: QuillEditorConfig(
              placeholder: 'Enter note content (min 10 characters)',
              padding: const EdgeInsets.all(8.0),
              embedBuilders: FlutterQuillEmbeds.editorBuilders(),
              autoFocus: false,
            ),
          ),
        ),

        // Error message for validation
        ReactiveFormConsumer(
          builder: (context, form, child) {
            final contentControl = form.control('content');
            if (contentControl.invalid && contentControl.touched) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Content must be at least 10 characters',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12.0,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          if (_form.valid) {
            _saveNote();
          } else {
            _form.markAllAsTouched();
          }
        },
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text('SAVE NOTE'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  void _toggleRichText() {
    // Convert content between rich text and plain text
    if (_isRichTextEnabled) {
      // Get plain text from quill
      final plainText = _quillController.document.toPlainText();
      _form.control('content').value = plainText;
    } else {
      // Set quill document from plain text
      final plainText = _form.control('content').value as String;
      _quillController.clear();
      _quillController.document.insert(0, plainText);
    }

    setState(() {
      _isRichTextEnabled = !_isRichTextEnabled;
    });
  }

  void _saveNote() {
    if (_form.valid) {
      // Get form values
      final title = _form.control('title').value as String;
      String content;
      String? category = _form.control('category').value as String?;

      // Handle new category creation
      if (category == 'new_category') {
        final newCategory = _form.control('newCategory').value as String?;
        if (newCategory != null && newCategory.isNotEmpty) {
          category = newCategory;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a new category name')),
          );
          return;
        }
      }

      // Handle rich text if enabled
      if (_isRichTextEnabled) {
        // Check if quill content is too short
        final plainText = _quillController.document.toPlainText();
        if (plainText.trim().length < 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Content must be at least 10 characters'),
            ),
          );
          return;
        }

        // Convert quill document to JSON string
        final jsonContent = jsonEncode(
          _quillController.document.toDelta().toJson(),
        );
        content = jsonContent;
      } else {
        content = _form.control('content').value as String;
      }

      // Add or update note
      if (widget.note == null) {
        // Create new note
        context.read<NotesBloc>().add(
          AddNote(title: title, content: content, category: category),
        );
      } else {
        // Update existing note
        final updatedNote = widget.note!.copyWith(
          title: title,
          content: content,
          category: category,
        );
        context.read<NotesBloc>().add(UpdateNote(note: updatedNote));
      }

      // Go back to previous screen
      Navigator.pop(context);
    } else {
      // Mark all fields as touched to show validation errors
      _form.markAllAsTouched();
    }
  }
}
