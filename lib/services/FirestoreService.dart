import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:growcery/services/AuthService.dart';

class FirestoreService{

  void createUser(){
    FirebaseFirestore.instance.collection("Users").doc(AuthService().getID()).set({
      "Name": "No Name",
      "Image": "",
      "Contact":"",
      "Address": "No Data%NCR%Caloocan",
      "Basket" : [],
      "Orders" : [],

    });
  }

  void updateUser(name, address, image, contact){
    FirebaseFirestore.instance.collection("Users").doc(AuthService().getID()).update({
      "Name": name,
      "Image": image,
      "Contact": contact,
      "Address": address,
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


  Future<void> createOrder(items) async {

    FirebaseFirestore.instance.collection("Users").doc(AuthService().getID()).update({
      "Basket": [],
    });

    FirebaseFirestore.instance.collection("Orders").doc().set({
      "User": AuthService().getID(),
      "Items": items,
      "Status": "0",
      //"Date": DateTime.now().toString(),
    });
    
    for(var item in items){
      var itemInstance = FirebaseFirestore.instance.collection("Items").doc(item.toString().split(",")[0]);
      var itemData = await itemInstance.get();
      var itemStocks = itemData.data()!["Stocks"];
     FirebaseFirestore.instance.collection("Items").doc(item.toString().split(",")[0]).update({
       "Stocks" : (int.parse(itemStocks) - int.parse(item.toString().split(",")[1])).toString(),
     });
    }
    
  }

  void updateOrderStatus(id, status){
    FirebaseFirestore.instance.collection("Orders").doc(id).update({
      "Status": status,
    });
  }
}