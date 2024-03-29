import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:growcery/features/ViewModels/UserViewModel.dart';
import 'package:growcery/features/user/2.%20Basket/PaymentDialog.dart';
import 'package:growcery/features/user/2.%20Basket/summaryDialog.dart';
import 'package:growcery/services/FirestoreService.dart';

import '../../../common/ViewItemSheet.dart';
import '../../../constants/AppColors.dart';
import '../../ViewModels/AuthViewModels.dart';

class UBasketView extends ConsumerStatefulWidget {
  const UBasketView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _UBasketViewState();
}

class _UBasketViewState extends ConsumerState<UBasketView> {
  // double total = 0.0;

  List<int> itemQuantity = List.filled(100, 1);
  List<double> itemPrice = List.filled(100, 0);
  List<bool> checkValues = List.filled(100, false);


  List<int> selectedQuantity = [];
  List<double> selectedPrice = [];
  List<String> selecteditems = [];



  @override
  void initState() {
    super.initState();
  }

  Future<List<String>> getSellers(basket)async{
    List<String> sellers = [];
    for(int index = 0; index < basket.length; index++){
      var itemSnapshot = await FirebaseFirestore.instance.collection("Items").doc(basket[index].toString().split(",")[0]).get();
      if(!sellers.contains(itemSnapshot.data()!["SellerID"])){
        sellers.add(itemSnapshot.data()!["SellerID"]);
      }
    }
    return sellers;
  }

  Future<List> loadItems(sellerID, basket) async {

    var items = [];
    for(int i = 0; i < basket.length; i++){

      var itemSnapshot = await FirebaseFirestore.instance.collection("Items").doc(basket[i].toString().split(",")[0]).get();
      if(itemSnapshot.data()!["SellerID"] == sellerID){
        items.add(i);
      }
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {


    var authState = ref.watch(authStateProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
        child: authState.when(
          data: (data2) {
            if (data2?.uid == null) {
              return Center(
                child: Text(
                  "Please Login to view your basket",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
            var basket = ref.watch(userProvider);
            return basket.when(
                data: (data){
                  List<String> basketList = List<String>.from(data.data()!["Basket"]);
                  basketList.sort();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "My Basket",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: FutureBuilder(
                          future: getSellers(basketList),
                          builder: (context, sellerSnapshot){
                            if(sellerSnapshot.hasData){
                              return ListView.separated(
                                itemCount: sellerSnapshot.data!.length,
                                itemBuilder: (context, i) {
                                  return FutureBuilder(
                                    future: loadItems(sellerSnapshot.data![i], basketList),
                                    builder: (context, itemList) {
                                      if(itemList.hasData){
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                FutureBuilder(
                                                    future: FirebaseFirestore.instance.collection("Users").doc(sellerSnapshot.data![i]).get(),
                                                    builder: (context, sellerDetails) {
                                                      if(sellerDetails.hasData){
                                                        return Text(
                                                          sellerDetails.data!.data()!["Name"],
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        );
                                                      }
                                                      return const SizedBox();
                                                    }
                                                ),
                                                const Spacer(),
                                                TextButton(
                                                  onPressed: () {
                                                    if(!selecteditems.any((element) => List.generate(itemList.data!.length, (index) => basketList[itemList.data![index]]).contains(element))) {
                                                      selecteditems.clear();
                                                      selectedQuantity.clear();
                                                      selectedPrice.clear();
                                                      checkValues = List.filled(100, false);
                                                      print(basketList);
                                                      print(itemList.data);
                                                      for (int index = 0; index < itemList.data!.length; index++) {
                                                        checkValues[itemList.data![index]] = true;
                                                        selecteditems.add(basketList[itemList.data![index]].toString());
                                                        selectedQuantity.add(itemQuantity[itemList.data![index]]);
                                                        selectedPrice.add(itemPrice[itemList.data![index]]);
                                                      }
                                                      setState(() {});
                                                    } else {
                                                      selecteditems.clear();
                                                      selectedQuantity.clear();
                                                      selectedPrice.clear();
                                                      checkValues = List.filled(100, false);
                                                      for (int index = 0; index < itemList.data!.length; index++) {
                                                        checkValues[itemList.data![index]] = false;
                                                      }
                                                      setState(() {});
                                                    }
                                                    print(selecteditems);
                                                  },
                                                  child: Text(
                                                    
                                                    //ListEquality().equals(selecteditems, List.generate(itemList.data!.length, (index) => basketList[itemList.data![index]]) .sublist(0, selecteditems.length)) 
                                                    selecteditems.any((element) => List.generate(itemList.data!.length, (index) => basketList[itemList.data![index]]).contains(element)) ? "Unselect All" : "Select All",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppColors().primaryColor,
                                                    ),
                                                  ),
                                                ),

                                              ],
                                            ),
                                            Column(
                                              children: List.generate(itemList.data!.length, (index){
                                                return StreamBuilder(
                                                  stream: FirebaseFirestore.instance.collection("Items").doc(basketList[itemList.data![index]].toString().split(",")[0]).snapshots(),
                                                  builder: (context, snapshot) {

                                                    if (snapshot.hasData) {
                                                      if(snapshot.data!.exists == false){
                                                        FirestoreService().removeItem(basketList[itemList.data![index]].toString());
                                                      } else {
                                                        itemQuantity[itemList.data![index]] = int.parse(basketList[itemList.data![index]].toString().split(",")[1]);
                                                        itemPrice[itemList.data![index]] = double.parse(snapshot.data!.data()!["Price"].toString());

                                                        return Dismissible(
                                                          key: UniqueKey(),
                                                          onDismissed: (direction) {
                                                            FirestoreService().updateBasketQuantity(basketList[itemList.data![index]].toString().split(",")[0], 0, basketList[itemList.data![index]], basketList[itemList.data![index]].toString().split(",")[2]);
                                                          },
                                                          child: Container(
                                                            height: 100,
                                                            margin: const EdgeInsets.only(bottom: 10),
                                                            decoration: BoxDecoration(
                                                              color: Colors.grey[200],
                                                              borderRadius: BorderRadius.circular(10),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  width: 100,
                                                                  decoration: BoxDecoration(
                                                                    image: DecorationImage(
                                                                      image: NetworkImage(
                                                                          snapshot.data!.data()!["Url"]),
                                                                      fit: BoxFit.cover,
                                                                    ),
                                                                    color: Colors.grey[300],
                                                                    borderRadius: BorderRadius
                                                                        .circular(10),
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 20),
                                                                Expanded(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                    MainAxisAlignment.center,
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment.start,
                                                                    children: [
                                                                      Text(
                                                                        "${snapshot.data!.data()!["Name"]} (${basketList[itemList.data![index]].toString().split(",")[2]})",
                                                                        maxLines: 1,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style: GoogleFonts.poppins(
                                                                          fontSize: 16,
                                                                          fontWeight: FontWeight.w600,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(height: 5),
                                                                      Text(
                                                                        "PHP ${snapshot.data!.data()!["Price"]}",
                                                                        maxLines: 1,
                                                                        overflow: TextOverflow
                                                                            .ellipsis,
                                                                        style: GoogleFonts.poppins(
                                                                          fontSize: 14,
                                                                          fontWeight: FontWeight.w400,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(height: 5),
                                                                      Row(
                                                                        children: [
                                                                          InkWell(
                                                                            onTap: () {
                                                                              if (int.parse(snapshot.data!.data()!["Minimum"]) <=
                                                                                  itemQuantity[itemList.data![index]] - 1) {
                                                                                checkValues[itemList.data![index]] = false;
                                                                                selecteditems.remove(basketList[itemList.data![index]].toString());
                                                                                selectedQuantity.remove(itemQuantity[itemList.data![index]]);
                                                                                selectedPrice.remove(itemPrice[itemList.data![index]]);
                                                                                setState(() {});
                                                                                FirestoreService().updateBasketQuantity(basketList[itemList.data![index]].toString().split(",")[0], itemQuantity[itemList.data![index]] - 1, basketList[itemList.data![index]],  basketList[itemList.data![index]].toString().split(",")[2]);
                                                                                itemQuantity[itemList.data![index]] = itemQuantity[itemList.data![index]] - 1;
                                                                                setState(() {});
                                                                              } else {
                                                                                Fluttertoast.showToast(
                                                                                    msg:
                                                                                    "Minimum quantity is ${snapshot.data!.data()!["Minimum"]}");
                                                                              }
                                                                            },
                                                                            child: Container(
                                                                              width: 25,
                                                                              height: 25,
                                                                              decoration: BoxDecoration(
                                                                                color: AppColors()
                                                                                    .primaryColor,
                                                                                borderRadius:
                                                                                BorderRadius.circular(
                                                                                    8),
                                                                              ),
                                                                              child: const Icon(
                                                                                Icons.remove,
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(width: 10),
                                                                          Text(
                                                                            "${itemQuantity[itemList.data![index]]}",
                                                                            style: GoogleFonts
                                                                                .poppins(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight
                                                                                  .w600,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(width: 10),
                                                                          InkWell(
                                                                            onTap: () {
                                                                              checkValues[itemList.data![index]] = false;
                                                                              selecteditems.remove(basketList[itemList.data![index]].toString());
                                                                              selectedQuantity.remove(itemQuantity[itemList.data![index]]);
                                                                              selectedPrice.remove(itemPrice[itemList.data![index]]);
                                                                              setState(() {});
                                                                              FirestoreService().updateBasketQuantity(basketList[itemList.data![index]].toString().split(",")[0], itemQuantity[itemList.data![index]] + 1, basketList[itemList.data![index]],  basketList[itemList.data![index]].toString().split(",")[2]);
                                                                              itemQuantity[itemList.data![index]] = itemQuantity[itemList.data![index]] + 1;
                                                                              setState(() {});
                                                                            },
                                                                            child: Container(
                                                                              width: 25,
                                                                              height: 25,
                                                                              decoration: BoxDecoration(
                                                                                color: AppColors()
                                                                                    .primaryColor,
                                                                                borderRadius:
                                                                                BorderRadius.circular(
                                                                                    10),
                                                                              ),
                                                                              child: const Icon(
                                                                                Icons.add,
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(width: 10),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),

                                                                Checkbox(
                                                                  value: checkValues[itemList.data![index]],
                                                                  onChanged: (value) {
                                                                    if (value!) {
                                                                      selecteditems.add(data
                                                                          .data()!["Basket"][itemList.data![index]]
                                                                          .toString());
                                                                      selectedQuantity.add(
                                                                          itemQuantity[itemList.data![index]]);
                                                                      selectedPrice.add(
                                                                          itemPrice[itemList.data![index]]);
                                                                    } else {
                                                                      selecteditems.remove(data
                                                                          .data()!["Basket"][itemList.data![index]]
                                                                          .toString()
                                                                      );
                                                                      selectedQuantity.remove(
                                                                          itemQuantity[itemList.data![index]]);
                                                                      selectedPrice.remove(
                                                                          itemPrice[itemList.data![index]]);
                                                                    }
                                                                    setState(() {
                                                                      checkValues[itemList.data![index]] = value!;
                                                                    });
                                                                  },
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    }

                                                    return const SizedBox();
                                                  },
                                                );
                                              }),
                                            ),
                                          ],
                                        );

                                      }
                                      return const SizedBox();
                                    }
                                  );
                                },
                                separatorBuilder: (context, index) =>
                                Column(
                                  children: const [
                                    SizedBox(height: 5),
                                    Divider(thickness: 1,),
                                    SizedBox(height: 5),
                                  ],
                                ),
                              );

                            }
                            return const SizedBox();
                          }

                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                          ),
                          child: selecteditems.length == 0
                              ? const SizedBox()
                              :
                  StreamBuilder(
                            stream: FirebaseFirestore.instance.collection("Items").doc(selecteditems[0].toString().split(",")[0]).snapshots(),
                            builder: (context, snapshot2) {
                              if(snapshot2.hasData){
                                return PriceLabel(
                                  prices: selectedPrice,
                                  quantity: selectedQuantity,
                                  items: selecteditems,
                                  name: data.data()?["Name"] ?? "",
                                  address: data.data()?["Address"] ?? "",
                                  contact: data.data()?["Contact"] ?? "",
                                  sellerID: snapshot2.data?["SellerID"] ?? "",
                                );
                              }
                              return const SizedBox();
                            }
                          ),
                        ),
                      )
                    ],
                  );
                },
                error: (error, stack) {
                  return Center(
                    child: Text(
                      error.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }, loading: () {
              return const Center(
                child: CircularProgressIndicator(),
              );
            });
          },
          error: (error, stack) {
            return Center(
              child: Text(
                error.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
          loading: () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}





class PriceLabel extends ConsumerStatefulWidget {
  const PriceLabel({
    required this.prices,
    required this.quantity,
    required this.items,
    required this.name,
    required this.contact,
    required this.address,
    required this.sellerID,
    Key? key,
  }) : super(key: key);

  final List<double> prices;
  final List<int> quantity;
  final List<dynamic> items;
  final name;
  final contact;
  final address;
  final sellerID;



  @override
  ConsumerState createState() => _PriceLabelState();
}

class _PriceLabelState extends ConsumerState<PriceLabel> {

  double total = 0;


  Future<double> computeTotal(dummy) async {
    total = 0;
    setState(() {});
    print("Widget Prices: ");
    print(widget.prices);


    for (int i = 0; i < widget.prices.length; i++) {
      print(widget.quantity[i]);
      total = total + (widget.prices[i] * widget.quantity[i]);
    }

    /*var brgy = widget.address.toString().split("%")[1];

    if (brgy == "San Isidro") {
      total += 200;
    } else if (brgy == "San Jose") {
      total += 400;
    } else if (brgy == "Burgos") {
      total += 400;
    } else if (brgy == "Manggahan") {
      total += 400;
    } else if (brgy == "Rosario") {
      total += 350;
    } else if (brgy == "Balite") {
      total += 350;
    } else if (brgy == "Geronimo") {
      total += 350;
    } else if (brgy == "San Rafael") {
      total += 300;
    } else if (brgy == "Mascap") {
      total += 200;
    } else if (brgy == "Macabud") {
      total += 350;
    } else if (brgy == "Puray") {
      total += 250;
    } else {
      total += 0;
    }*/
    return total;
  }

  bool isSame = true;

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              //var sellerID = widget.items[0].toString().split(",")[0];
              print(widget.items);

              for (int i = 0; i < widget.items.length; i++) {
                var data = await FirebaseFirestore.instance.collection("Items").doc(widget.items[i].toString().split(",")[0]).get();
                //data.data()!["SellerID"];
                if( data.data()!["SellerID"] != widget.sellerID ){
                  isSame = false;
                  Fluttertoast.showToast(msg: "You can only checkout items from one seller per batch");
                  return;
                }
              }

              if (widget.items.isNotEmpty && widget.name != "" && widget.contact != "" && widget.address.toString().split("%")[0] != "No Data" && isSame) {

                showDialog(context: context, builder: (builder){
                  return SummartyDialog(
                    summaryItems: widget.items,
                    address: widget.address,
                    contact: widget.contact,
                    name: widget.name,
                    sellerID: widget.sellerID,
                  );
                });

               /* showDialog(context: context, builder: (builder){
                  return AlertDialog(
                    title: const Text("Payment Method"),
                    content: const Text("Please select your payment method"),
                    actions: [
                      TextButton(onPressed: (){
                        FirestoreService().createOrder(widget.items, widget.name, widget.contact, widget.address, widget.sellerID);
                        Fluttertoast.showToast(msg: "Order has been placed");
                        Navigator.pop(builder);
                      }, child: const Text("COD")),
                      TextButton(onPressed: (){
                        showDialog(context: context, builder: (builder){
                          return PaymentDialog(items: widget.items, name: widget.name, contact: widget.contact, address: widget.address, sellerID: widget.sellerID,);
                        });
                      }, child: const Text("Gcash")),
                    ],
                  );
                });*/
              } else {
                Fluttertoast.showToast(msg: "No items in basket or you have not filled up your profile yet");
              }
            },
            child: Container(
              height: 55,
              color: AppColors().primaryColor,
              child: Center(
                child: Text(
                  "Checkout",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          width: 1,
          color: Colors.white,
        ),
        Expanded(
          child: FutureBuilder(
              future: computeTotal(total),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    "Total: PHP ${snapshot.data}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  );
                }
                return const SizedBox();
              }),
        ),
      ],
    );
  }
}
