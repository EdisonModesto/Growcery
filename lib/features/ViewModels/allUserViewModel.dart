

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growcery/services/AuthService.dart';

final AutoDisposeStreamProvider allUserProvider = StreamProvider.autoDispose((ref){
  return FirebaseFirestore.instance.collection("Users").snapshots();
});


//MODEL VIEW VIEWMODEL