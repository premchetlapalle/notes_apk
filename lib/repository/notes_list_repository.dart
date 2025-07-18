import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_apk/models/notes_list_model.dart';

class NotesListRepository{
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //fetch all the items from Firestore
  Future<List<NotesListModel>> fetchNote() async{
    try {
      QuerySnapshot snapshot = await firestore.collection("notes").get();
      return snapshot.docs
          .map((doc) =>
            NotesListModel.fromMap(doc.data() as Map<String,dynamic>, doc.id))
          .toList();
    } catch (e){
      throw Exception("Error Fetching the List");
    }
  }

  //Add a new Note
  Future<void> addNote(String title, String message) async {
    try {
      await firestore.collection("notes").add({
        'title': title,
        'message': message,
      });
    } catch (e) {
      throw Exception("Error Adding Note: $e");
    }
  }

  // Update an existing note
  Future<void> updateNote(String id, String title, String message) async {
    try {
      await firestore.collection('notes').doc(id).update({
        'title': title,
        'message': message,
      });
    } catch (e) {
      throw Exception("Error updating Note: $e");
    }
  }


  //delete an note
  Future<void> deleteNote(String noteId) async{
    try {
      await firestore.collection('notes').doc(noteId).delete();
    } catch (e){
      throw Exception("Error deleting Note");
    }
  }
}