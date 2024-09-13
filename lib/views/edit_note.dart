import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';


class EditNotePage extends StatefulWidget {
  const EditNotePage(this.noteId, {super.key});

  final String? noteId;

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  User? _currentUser;

  @override  
  void initState() {
    super.initState();

    _currentUser = FirebaseAuth.instance.currentUser;

    if (widget.noteId != null) {
      // lay du lieu 
      FirebaseFirestore.instance
        .collection('notes')
        .doc(widget.noteId)
        .get()
        .then((note) {
          setState(() {
            _title.text = note['title'];
            _desc.text = note['description'];
          });
        });
    }
  }


  void _saveNote() {
    final noteData = {
      'title': _title.text,
      'description': _desc.text,
      'created_at': DateTime.now(),
      'uid': _currentUser?.uid,
    };

    if (widget.noteId == null) {
      FirebaseFirestore.instance.collection('notes')
        .add(noteData);
    } else {
      FirebaseFirestore.instance.collection('notes')
        .doc(widget.noteId)
        .update(noteData);
    }

    // navigation 
    context.push('/notes');
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.noteId == null ? 'Add note' : 'Edit note', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            color: Colors.white,
            onPressed: _saveNote,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _desc,
              decoration: const InputDecoration(hintText: 'Description', border: OutlineInputBorder()),
              minLines: 7,
              maxLines: 10,
            ),
          ],
        ),
      ),
    );
  }
}
