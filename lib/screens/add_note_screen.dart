import 'package:flutter/material.dart';
import 'package:notes_apk/core/themes/app_colors.dart';
import 'package:share_plus/share_plus.dart';

class AddNoteScreen extends StatefulWidget {
  final bool isEditing;
  final String? noteId;
  final String? existingTitle;
  final String? existingMessage;

  const AddNoteScreen({
    super.key,
    this.isEditing = false,
    this.noteId,
    this.existingTitle,
    this.existingMessage,
  });

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  late TextEditingController _messageController;
  late TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingTitle ?? '');
    _messageController = TextEditingController(text: widget.existingMessage ?? '');
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    if (title.isNotEmpty || message.isNotEmpty) {
      Navigator.pop(context, {
        'title': title.isEmpty ? 'Untitled' : title,
        'message': message,
      });
    } else {
      Navigator.pop(context); // No data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        elevation: 1,
        title: TextField(
          controller: _titleController,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.appIconColor,
          ),
          decoration: const InputDecoration(
            hintText: 'Title',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: AppColors.appIconColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
              fontSize: 24,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.appIconColor),
            onPressed: _shareNote,
            tooltip: 'Share Note',
          ),
          IconButton(
            icon: const Icon(Icons.check, color:AppColors.appIconColor),
            onPressed: _saveNote,
            tooltip: 'Save Note',
          ),
        ],
        iconTheme: const IconThemeData(color:AppColors.appIconColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.appBarColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.shade200,
                spreadRadius: 2,
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            controller: _messageController,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            expands: true,
            style: const TextStyle(fontSize: 18, color: AppColors.appIconColor),
            decoration: const InputDecoration.collapsed(
              hintText: "Write your note here...",
              hintStyle: TextStyle(color: AppColors.appIconColor,fontFamily: 'Poppins' ,fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  void _shareNote() {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty && message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nothing to share")),
      );
      return;
    }

    final shareContent = 'Title: ${title.isEmpty ? 'Untitled' : title}\n\n$message';
    Share.share(shareContent, subject: title.isEmpty ? 'Note' : title);
  }
}
