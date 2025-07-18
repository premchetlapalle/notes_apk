class NotesListModel{
  final String id;
  final String title;
  final String message;

  NotesListModel({required this.id, required this.title , required this.message});

  //Convert Firestore document to Model
  factory NotesListModel.fromMap(Map<String, dynamic> map , String id){
    return NotesListModel(
      id: id,
      title: map['title'] ?? "",
      message: map['message'] ?? "",
    );
  }

  //Convert model to Firestore formate
  Map<String,dynamic> toMap() {
    return {
      'title':title,
      'message':message,
    };
  }
}
