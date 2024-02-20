import 'dart:ui';
import 'package:notesapp/firebase_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomePageState();
}

class _HomePageState extends State<Homescreen> {
  TextEditingController controller = TextEditingController();
  FirestoreServices firestoreServices = FirestoreServices();
  void showNoteBox(String? textToedit, String? docId, Timestamp? time) {
    showDialog(
      context: context,
      builder: (context) {
        if (textToedit != null) {
          controller.text = textToedit;
        }
        return AlertDialog(
          backgroundColor: Colors.green[50],
          title: Text(
            "Add notes",
            style: GoogleFonts.alexandria(fontSize: 16),
          ),
          content: TextField(
            decoration: const InputDecoration(hintText: 'Start Typing...',
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.green), // Change underline color here
              ),
            ),

            style: GoogleFonts.alexandria(),
            cursorColor: Colors.green, // Change cursor color here
            controller: controller,
          ),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.green[400]!; // Change pressed state color here
                  } else if (states.contains(MaterialState.hovered)) {
                    return Colors.green[100]!; // Change hover state color here
                  }
                  return Colors.white; // Default button color
                }),
                elevation: MaterialStateProperty.all<double>(2), // Change elevation here
                overlayColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                  if (states.contains(MaterialState.hovered)) {
                    return Colors.green[200]!; // Change overlay color here
                  }
                  return Colors.green.shade400;
                }),
              ),
              onPressed: () {
                if (docId == null) {
                  firestoreServices.addNote(controller.text);
                } else {
                  firestoreServices.updateNotes(docId, controller.text, time!);
                }
                controller.clear();
                Navigator.pop(context);
              },
              child: Text(
                'add',
                style: GoogleFonts.alexandria(color: Colors.green[800]),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.green[50],
        title: Text(
          "Notes",
          style: GoogleFonts.alexandria(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green[100],
        label: Text(
          'add',
          style: GoogleFonts.alexandria(fontSize: 18,color: Colors.green[800]),
        ),
        icon: Icon(Icons.add,color:Colors.green[800] ),
        onPressed: () async {
          showNoteBox(null, null, null);
        },
      ),
      body: StreamBuilder(
        stream: FirestoreServices().showNotes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List noteList = snapshot.data!.docs;
            return ListView.builder(
              itemCount: noteList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = noteList[index];
                String docId = document.id;
                Map<String, dynamic> data =
                document.data() as Map<String, dynamic>;
                String note = data['note'];
                Timestamp time = data['timestamp'];
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        tileColor: Colors.green[100],
                        title: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            note,
                            style: GoogleFonts.alexandria(
                                textStyle: TextStyle(
                                    color: Colors.green[800], fontSize: 19)),
                          ),
                        ),
                        trailing: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  color: Colors.green[400],
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    showNoteBox(note, docId, time);
                                  },
                                ),
                                IconButton(
                                    color: Colors.green[400],
                                    onPressed: () {
                                      firestoreServices.deleteNote(docId);
                                    },
                                    icon: Icon(Icons.delete))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            time.toDate().hour.toString(),
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(":"),
                          Text(
                            time.toDate().minute.toString(),
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              },
            );
          } else {
            return Center(
              child: Text("Nothing..."),
            );
          }
        },
      ),
    );
  }
}