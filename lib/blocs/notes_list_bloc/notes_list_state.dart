import 'package:equatable/equatable.dart';
import 'package:notes_apk/models/notes_list_model.dart';

abstract class NotesListState extends Equatable{
  @override
  List<Object?> get props => [];
}

class NoteInitialState extends NotesListState {}

class NoteLoadingState extends NotesListState {}

class NoteLoadedState extends NotesListState {
  final List<NotesListModel> notes;

  NoteLoadedState(this.notes);

  @override
  List<Object?> get props => [notes];
}

class NoteErrorState extends NotesListState {
  final String message;

  NoteErrorState(this.message);

  @override
  List<Object?> get props => [message];
}