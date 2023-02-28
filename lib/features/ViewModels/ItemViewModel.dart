
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

var itemProvider = StreamProvider((ref){
  return FirebaseFirestore.instance.collection("Items").snapshots();
});