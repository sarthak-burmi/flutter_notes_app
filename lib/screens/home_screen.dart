import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_notes_app/bloc/notes_bloc.dart';
import 'package:flutter_notes_app/models/note_model.dart';
import 'package:flutter_notes_app/screens/add_edit_note_screen.dart';
import 'package:flutter_notes_app/screens/note_detail_screen.dart';
import 'package:intl/intl.dart';

import 'package:rxdart/rxdart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _dateFormat = DateFormat('MMM dd, yyyy HH:mm');
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Load notes when the screen initializes
    context.read<NotesBloc>().add(LoadNotes());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          if (state is NotesInitial || state is NotesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotesError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is NotesLoaded) {
            final notes = state.notes;
            final categories = state.categories;

            // Update the local selected category if it changes in the state
            if (_selectedCategory != state.selectedCategory) {
              _selectedCategory = state.selectedCategory;
            }

            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(categories),

                // Notes list or empty state
                notes.isEmpty
                    ? SliverFillRemaining(child: _buildEmptyState())
                    : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final note = notes[index];
                        return _buildNoteItem(note);
                      }, childCount: notes.length),
                    ),
              ],
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NoteEditScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSliverAppBar(List<String?> categories) {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      title: const Text(
        'Advanced Notes',
      ), // Move title here instead of in FlexibleSpaceBar
      flexibleSpace: FlexibleSpaceBar(
        // Remove title from here
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(
          100.0,
        ), // Increase height to accommodate content
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            mainAxisSize:
                MainAxisSize
                    .min, // Add this to prevent column from trying to be as tall as possible
            children: [
              // Search TextField
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: const Icon(Icons.search),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  // Log search query for debugging
                  print('Searching for: $value | Category: $_selectedCategory');

                  context.read<NotesBloc>().search(
                    value,
                    categoryFilter: _selectedCategory,
                  );
                },
              ),

              const SizedBox(height: 8.0),

              // Category filter
              Container(
                height: 40.0,
                margin: const EdgeInsets.only(bottom: 4.0), // Add bottom margin
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length + 1, // +1 for "All" option
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildCategoryChip('All', null);
                    } else {
                      final category = categories[index - 1];
                      return _buildCategoryChip(
                        category ?? 'Uncategorized',
                        category,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });

          // Log category selection for debugging
          print(
            'Category selected: ${selected ? category : "All"} | Current search: ${_searchController.text}',
          );

          // Trigger search with selected category
          context.read<NotesBloc>().search(
            _searchController.text,
            categoryFilter: selected ? category : null,
          );
        },
      ),
    );
  }

  Widget _buildNoteItem(Note note) {
    // Extract first two lines of content
    final contentLines = note.content.split('\n');
    final previewContent =
        contentLines.length > 2
            ? '${contentLines[0]}\n${contentLines[1]}...'
            : note.content;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteDetailScreen(noteId: note.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.category != null)
                    Chip(
                      label: Text(
                        note.category!,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                previewContent,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created: ${_dateFormat.format(note.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    'Updated: ${_dateFormat.format(note.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add,
            size: 80.0,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16.0),
          Text(
            'No notes yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8.0),
          Text(
            'Create your first note by tapping the + button',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
