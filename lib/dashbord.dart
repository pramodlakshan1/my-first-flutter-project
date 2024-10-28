import 'package:flutter/material.dart';
import 'notepad.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  List<String> notes = []; // Stores note titles
  List<String> filteredNotes = []; // Notes filtered by search
  TextEditingController searchController = TextEditingController();

  void addOrEditNote({String? initialTitle, String? initialContent, int? index}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Notepad(
          initialTitle: initialTitle,
          initialContent: initialContent,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        if (index != null) {
          notes[index] = result; // Update existing note
        } else {
          notes.add(result); // Add new note
        }
        filteredNotes = notes; // Update filtered list
      });
    }
  }

  void deleteNoteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Note"),
          content: const Text("Are you sure you want to delete this note?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  notes.removeAt(index);
                  filteredNotes = notes;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Yes, delete it"),
            ),
          ],
        );
      },
    );
  }

  void searchNotes(String query) {
    final results = notes.where((note) => note.toLowerCase().contains(query.toLowerCase())).toList();
    setState(() {
      filteredNotes = results;
    });
  }

  @override
  void initState() {
    super.initState();
    filteredNotes = notes;
    searchController.addListener(() {
      searchNotes(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.black26,
        title: const Text('Note List', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(style: const TextStyle(color: Colors.white),
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                filled: true,
                fillColor: Colors.black12,

                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2,
                ),
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => addOrEditNote(
                      initialTitle: filteredNotes[index],
                      index: index,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 5,
                            right: 5,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                  onPressed: () => addOrEditNote(
                                    initialTitle: filteredNotes[index],
                                    index: index,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.white),
                                  onPressed: () => deleteNoteConfirmation(index),
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: Text(
                              filteredNotes[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addOrEditNote(), // Open Notepad for new note
        child: const Icon(Icons.add),
      ),
    );
  }
}
