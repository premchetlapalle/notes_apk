import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_apk/blocs/auth_bloc/auth_bloc.dart';
import 'package:notes_apk/blocs/auth_bloc/auth_event.dart';
import 'package:notes_apk/blocs/notes_list_bloc/notes_list_bloc.dart';
import 'package:notes_apk/blocs/notes_list_bloc/notes_list_event.dart';
import 'package:notes_apk/blocs/notes_list_bloc/notes_list_state.dart';
import 'package:notes_apk/core/themes/app_colors.dart';
import 'package:notes_apk/screens/add_note_screen.dart';
import 'package:notes_apk/screens/login_screen.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  final User? user;
  const HomeScreen({super.key, this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isGridView = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.of(context).size.width;
    _isGridView = width > 600;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        title: Row(
          children: [
            SizedBox(width: 10,),
            const Text(
              "Notes",
              style: TextStyle(color: AppColors.appIconColor , fontFamily: 'Poppins', fontWeight: FontWeight.bold),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: AppColors.appIconColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.appIconColor),
            tooltip: 'Refresh Notes',
            onPressed: () {
              BlocProvider.of<NotesListBloc>(context).add(FetchNoteListEvent());
            },
          ),
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: AppColors.appIconColor,
            ),
            tooltip: _isGridView ? 'Switch to List View' : 'Switch to Grid View',
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: AppColors.appIconColor),
            tooltip: 'Sign Out',
            onPressed: () {
              BlocProvider.of<AuthBloc>(context).add(SignOutEvent());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotesListBloc, NotesListState>(
        builder: (context, state) {
          if (state is NoteLoadingState) {
            return _isGridView ? _buildShimmerGrid() : _buildShimmerList();
          } else if (state is NoteLoadedState) {
            if (state.notes.isEmpty) {
              return const Center(child: Text("No items found"));
            } else {
              return _isGridView
                  ? _buildGridView(state.notes)
                  : _buildListView(state.notes);
            }
          } else {
            return const Center(child: Text("No items found"));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        tooltip: 'Add Note',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNoteScreen()),
          );

          if (result != null && result is Map<String, String>) {
            final title = result['title'] ?? '';
            final message = result['message'] ?? '';

            if (title.isNotEmpty || message.isNotEmpty) {
              BlocProvider.of<NotesListBloc>(context).add(
                AddNoteListEvent(title, message),
              );
            }
          }
        },
        child: const Icon(Icons.note_alt, color: Colors.white),
      ),
    );
  }

  Widget _buildListView(List notes) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNoteScreen(
                  isEditing: true,
                  noteId: note.id,
                  existingTitle: note.title,
                  existingMessage: note.message,
                ),
              ),
            );
            if (result != null && result is Map<String, String>) {
              final title = result['title'] ?? '';
              final message = result['message'] ?? '';
              if (title.isNotEmpty || message.isNotEmpty) {
                BlocProvider.of<NotesListBloc>(context).add(UpdateNoteListEvent(note.id, title, message));
              }
            }
          },
          child: Container(
            height: 65,
            margin: const EdgeInsets.only(left: 12 , right: 12 , top:12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.appBarColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.appIconColor,
                        ),
                      ),
                      Text(
                        note.message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    BlocProvider.of<NotesListBloc>(context).add(DeleteNoteListEvent(note.id));
                  },
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView(List notes) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNoteScreen(
                  isEditing: true,
                  noteId: note.id,
                  existingTitle: note.title,
                  existingMessage: note.message,
                ),
              ),
            );
            if (result != null && result is Map<String, String>) {
              final title = result['title'] ?? '';
              final message = result['message'] ?? '';
              if (title.isNotEmpty || message.isNotEmpty) {
                BlocProvider.of<NotesListBloc>(context)
                    .add(UpdateNoteListEvent(note.id, title, message));
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12 , vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.appBarColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.appIconColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        BlocProvider.of<NotesListBloc>(context)
                            .add(DeleteNoteListEvent(note.id));
                      },
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height:4),
                Expanded(
                  child: Text(
                    note.message,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 0),
        child: Shimmer.fromColors(
          baseColor: AppColors.appBarColor,
          highlightColor: Colors.amber.shade50,
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: AppColors.appBarColor,
        highlightColor: Colors.amber.shade50,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
