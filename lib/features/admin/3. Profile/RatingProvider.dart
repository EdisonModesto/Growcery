
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

var ratingsProvider = StreamProvider((ref){
  return FirebaseFirestore.instance.collection("Ratings").snapshots();
});