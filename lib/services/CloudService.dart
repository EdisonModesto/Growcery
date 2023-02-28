import 'package:firebase_storage/firebase_storage.dart';

class CloudService{

  Future<String> uploadImage(file,String filename) async {
    // Upload image to cloud
    var ref = FirebaseStorage.instance.ref("images/$filename");

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }
}