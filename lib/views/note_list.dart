import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  final TextEditingController _search = TextEditingController();
  User? _currentUser;

  // id: auto created 
  // uid: user id 
  // title 
  // description 
  // created_at 

  @override  
  void initState() {
    super.initState();

    _currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                hintText: 'Search for note...',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
                suffixIconColor: Colors.white, 
              ),
              onChanged: (value) {
                setState(() {

                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('notes')
          .orderBy('created_at')
          .where('uid', isEqualTo: _currentUser?.uid)
          .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notes found.'));
          }

          var notes = snapshot.data!.docs.where((note) {
            var title = note['title'].toString().toLowerCase();
            var searchTerm = _search.text.toLowerCase();
            return title.contains(searchTerm);
          }).toList();

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              var note = notes[index];

              return Padding(
                padding: const EdgeInsets.only(top: 16, left: 26, right: 26),
                child: ListTile(
                  title: Text(note['title'], style: const TextStyle(color: Colors.white),),
                  onTap: () {

                  },
                  tileColor: Colors.deepPurple[200],
                  selectedTileColor: Colors.deepPurple[500],
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: Colors.white,
                        onPressed: () {
                          context.push('/notes/edit/${note.id}');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.white,
                        onPressed: () {
                          print('Deleted $index');
                          FirebaseFirestore.instance.collection('notes')
                            .doc(note.id)
                            .delete();
                        },
                      )
                    ],
                  ),
                ),
              );
            },
          );
          
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/notes/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

