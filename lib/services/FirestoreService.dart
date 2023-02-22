import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:growcery/services/AuthService.dart';

class FirestoreService{

  void createUser(){
    FirebaseFirestore.instance.collection("Users").doc(AuthService().getID()).set({
      "name": "Username",
      "address": "1234 Main Street",
    });
  }

  Future<bool> checkUserExist(id) async {

    bool exist = await FirebaseFirestore.instance.collection("Users").doc(id).get().then((value) {
      if(value.exists){
        return true;
      }else{
        return false;
      }
    });

    return exist;
  }
}