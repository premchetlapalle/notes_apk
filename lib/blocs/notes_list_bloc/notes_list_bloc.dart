import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_apk/blocs/notes_list_bloc/notes_list_event.dart';
import 'package:notes_apk/blocs/notes_list_bloc/notes_list_state.dart';
import 'package:notes_apk/models/notes_list_model.dart';
import 'package:notes_apk/repository/notes_list_repository.dart';

class NotesListBloc extends Bloc<NotesListEvent , NotesListState>{
  final NotesListRepository notesListRepository;

  NotesListBloc(this.notesListRepository) : super(NoteInitialState()){
    on<FetchNoteListEvent>(_onFetchNoteListEvent);
    on<AddNoteListEvent>(_onAddNoteListEvent);
    on<DeleteNoteListEvent>(_onDeleteNoteListEvent);
    on<UpdateNoteListEvent>(_onUpdateNoteListEvent);
  }

  Future<void> _onFetchNoteListEvent(
      FetchNoteListEvent event, Emitter<NotesListState> emit) async{
    emit(NoteLoadingState());
    try{
      List<NotesListModel> notes = await notesListRepository.fetchNote();
      emit(NoteLoadedState(notes));
    }catch (e) {
      emit(NoteErrorState("Failed to load Notes"));
    }
  }

  Future<void> _onAddNoteListEvent(AddNoteListEvent event, Emitter<NotesListState> emit) async{
    try{
      await notesListRepository.addNote(event.title , event.message);
      add(FetchNoteListEvent());
    }catch (e) {
      emit(NoteErrorState("Failed to add Notes"));
    }
  }

  Future<void> _onDeleteNoteListEvent(DeleteNoteListEvent event, Emitter<NotesListState> emit) async{
    try{
     await notesListRepository.deleteNote(event.noteId);
     add(FetchNoteListEvent()); // to refresh the list after deleting
    }catch (e) {
      emit(NoteErrorState("Failed to delete Notes"));
    }
  }

  Future<void> _onUpdateNoteListEvent(
      UpdateNoteListEvent event, Emitter<NotesListState> emit) async {
    try {
      await notesListRepository.updateNote(event.id, event.title, event.message);
      add(FetchNoteListEvent()); // Refresh after update
    } catch (e) {
      emit(NoteErrorState("Failed to update Note"));
    }
  }

}

