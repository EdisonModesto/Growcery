import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:growcery/services/AuthService.dart';

class FirestoreService{

  void createUser(){
    FirebaseFirestore.instance.collection("Users").doc(AuthService().getID()).set({
      "Name": "No Name",
      "Image": "",
      "Address": "1234 Main Street",
      "Basket" : [],
      "Orders" : [],

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

  void addItem(url, name, price, stocks, description){
    FirebaseFirestore.instance.collection("Items").doc().set({
      "Url": url,
      "Name": name,
      "Price": price,
      "Stocks": stocks,
      "Description": description,
    });
  }

  Future<void> addToBasket(id, quantity) async {

    var ref = await FirebaseFirestore.instance.collection("Users").doc(AuthService().getID()).get();
    List<dynamic> cart = ref.data()!["Basket"] as List<dynamic>;
    bool exist = false;
    for(var i = 0; i < cart.length; i++){
      if(cart[i].toString().split(",")[0] == id){
        exist = true;
        break;
      }
    }
    if(exist){
      Fluttertoast.showToast(msg: "Item already in cart");
    } else{
      Fluttertoast.showToast(msg: "Item added to cart");
      FirebaseFirestore.instance.collection("Users").doc(AuthService().getID()).update({
        "Basket": FieldValue.arrayUnion(["$id,$quantity"])
      });
    }
  }

  void updateBasketQuantity(id, quantity, old){
    FirebaseFirestore.instance.collection("Users").doc(AuthService().getID()).update({
      "Basket": FieldValue.arrayRemove([old])
    });
    if(quantity == 0){

    } else {
      FirebaseFirestore.instance.collection("Users").doc(AuthService().getID()).update({
        "Basket": FieldValue.arrayUnion(["$id,$quantity"])
      });
    }
  }


  void createOrder(items){

    FirebaseFirestore.instance.collection("Users").doc(AuthService().getID()).update({
      "Basket": [],
    });

    FirebaseFirestore.instance.collection("Orders").doc().set({
      "User": AuthService().getID(),
      "Items": items,
      "Status": "0",
      //"Date": DateTime.now().toString(),
    });
  }
}