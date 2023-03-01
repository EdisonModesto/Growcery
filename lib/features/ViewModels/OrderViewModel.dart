
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

var orderProvider = StreamProvider((ref){
  return FirebaseFirestore.instance.collection("Orders").snapshots();
});