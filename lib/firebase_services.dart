import 'package:cloud_firestore/cloud_firestore.dart';


class FirestoreServices {
  final CollectionReference? notes =
  FirebaseFirestore.instance.collection('notes');

  Future<void> addNote(String note) {
    return notes!.add(
      {'note': note, 'timestamp': Timestamp.now()},
    );
  }

  Stream<QuerySnapshot> showNotes() {
    final notesStream =
    notes!.orderBy('timestamp', descending: true).snapshots();

    return notesStream;
  }

  Future<void> updateNotes(String docId, String newNote, Timestamp time) {
    return notes!.doc(docId).update({'note': newNote, 'timestamp': time});
  }

  Future<void> deleteNote(String docId) {
    return notes!.doc(docId).delete();
  }
}