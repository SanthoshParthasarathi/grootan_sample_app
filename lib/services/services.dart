import 'package:cloud_firestore/cloud_firestore.dart';

class Services {
   final FirebaseFirestore firestore = FirebaseFirestore.instance;


   Stream<QuerySnapshot> getItems() {
     return firestore
         .collection('user_details')
         .orderBy('datetime', descending: true)
         .snapshots();
   }

   Future<String?> getLastDatetime() async {
     final itemsStream = getItems();
     final itemsList = await itemsStream.first;

     if (itemsList.docs.isNotEmpty) {
       // Retrieve the last document from the stream
       final lastDocument = itemsList.docs.first;
       // Extract the 'datetime' field from the last document
       return lastDocument['datetime'] as String;
     } else {
       return null; // No documents found
     }
   }
}