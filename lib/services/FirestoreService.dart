import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:growcery/services/AuthService.dart';

class FirestoreService{

  void createUser(userType, name, contact, gcash, address){
    FirebaseFirestore.instance.collection("Users").doc(AuthService().getID()).set({
      "Name": name,
      "Image": "",
      "GCash": gcash,
      "Contact":contact,
      "Address": address,
      "Basket" : [],
      "userType" : userType
    });
  }

  void updateUser(name, address, image, contact, gcash){
    FirebaseFirestore.instance.collection("Users").doc(AuthService().getID()).update({
      "Name": name,
      "Image": image,
      "GCash": gcash,
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

  Future<String> checkUserType(id) async {
    var doc = await FirebaseFirestore.instance.collection("Users").doc(id).get();
    if(doc["userType"] == "Buyer") {
      print("Buyer");
      return "Buyer";
    } else if(doc["userType"] == "Seller"){
      print("Seller");
      return "Seller";
    } else if(doc["userType"] == "Admin"){
      print("Admin");
      return "Admin";
    }
    return "Unknown";
  }

  void addItem(url, name, price, stocks, description, category, minimum, sellerID){
    FirebaseFirestore.instance.collection("Items").doc().set({
      "Url": url,
      "SellerID": sellerID,
      "Name": name,
      "Price": price,
      "Stocks": stocks,
      "Description": description,
      "Category": category,
      "Minimum": minimum,
    });
  }

  void updateItem(url, name, price, stocks, description,id, category, minimum, sellerID){
    FirebaseFirestore.instance.collection("Items").doc(id).update({
      "Url": url,
      "SellerID": sellerID,
      "Name": name,
      "Price": price,
      "Stocks": stocks,
      "Description": description,
      "Category": category,
      "Minimum": minimum,
    });
  }

  void removeItem(id){
    FirebaseFirestore.instance.collection("Items").doc(id).delete();
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

  void removeFromBasket(data){
    FirebaseFirestore.instance.collection("Users").doc(AuthService().getID()).update({
      "Basket": FieldValue.arrayRemove(["$data"]),
    });
  }

  Future<void> createOrder(items, name, contact, address, sellerID) async {

    FirebaseFirestore.instance.collection("Users").doc(AuthService().getID()).update({
      "Basket": FieldValue.arrayRemove(items),
    });

    FirebaseFirestore.instance.collection("Orders").doc().set({
      "User": AuthService().getID(),
      "Items": items,
      "Status": "0",
      "Name": name,
      "Contact": contact,
      "Address": address,
      "SellerID": sellerID,
      "Date": DateTime.now(),
      "Date Completed": "No Record",
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
      "Date Completed": status == "3" ? DateTime.now().toString() : "",
    });
  }

  void refundOrder(id, refundImage, refundComment, marketContact){
    FirebaseFirestore.instance.collection("Orders").doc(id).update({
      "Status": "5",
      "RefundImage" : refundImage,
      "RefundComment" : refundComment,
      "MarketContact" : marketContact,
    });
  }

  void saveRating(rating, sellerID, marketName){

    FirebaseFirestore.instance.collection("Users").doc(sellerID).collection("Ratings").doc().set({
      "Rating": rating,
      "MarketName": marketName,
    });
  }

  Future<void> restoreStock(id, quantity) async {

    final doc = await FirebaseFirestore.instance.collection("Items").doc(id).get();
    var stocks = doc.data()!["Stocks"];

    FirebaseFirestore.instance.collection("Items").doc(id).update({
      "Stocks": (int.parse(stocks) + int.parse(quantity)).toString(),
    });
  }



}