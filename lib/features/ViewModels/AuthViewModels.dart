
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final authStateProvider = StreamProvider((ref){
  var instance = FirebaseAuth.instance;
  return instance.authStateChanges();
});