import 'package:equatable/equatable.dart';

abstract class NotesListEvent extends Equatable{
  @override
  List<Object?> get props => [];
}

// fetch note from firestore
class FetchNoteListEvent extends NotesListEvent {}

// add a new note
class AddNoteListEvent extends NotesListEvent {
  final String title;
  final String message;

  AddNoteListEvent(this.title, this.message);

  @override
  List<Object?> get props => [title];
}

class UpdateNoteListEvent extends NotesListEvent {
  final String id;
  final String title;
  final String message;

  UpdateNoteListEvent(this.id, this.title, this.message);
}
// fetch item from firestore
class DeleteNoteListEvent extends NotesListEvent {
  final String noteId;

  DeleteNoteListEvent(this.noteId);
  @override
  List<Object?> get props => [noteId];
}