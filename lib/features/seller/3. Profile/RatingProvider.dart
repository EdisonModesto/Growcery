
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growcery/services/AuthService.dart';

var ratingsProvider = StreamProvider((ref){
  return FirebaseFirestore.instance.collection("Users").doc(AuthService().getID()).collection("Ratings").snapshots();
});