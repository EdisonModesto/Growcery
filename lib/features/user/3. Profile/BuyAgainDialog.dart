import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numberpicker/numberpicker.dart';

import '../../../constants/AppColors.dart';
import '../../../services/FirestoreService.dart';
import '../2. Basket/PaymentDialog.dart';

class BuyAgainDialog extends ConsumerStatefulWidget {
  const BuyAgainDialog({
    Key? key,

    required this.summaryItems,
    required this.address,
    required this.name,
    required this.contact,
    required this.sellerID,

  }) : super(key: key);

  final summaryItems;
  final address;
  final name;
  final contact;
  final sellerID;
  @override
  ConsumerState createState() => _BuyAgainDialogState();
}

class _BuyAgainDialogState extends ConsumerState<BuyAgainDialog> {

  Future<double> calculateTotal(items) async{
    var total = 0.0;
    for(var item in items){
      var itemData = await FirebaseFirestore.instance.collection("Items").doc(item.toString().split(",")[0]).get();
      total += double.parse(itemData.data()!["Price"]) * double.parse(item.toString().split(",")[1]);
    }

    var brgy = widget.address.toString().split("%")[1];

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
    }

    return total;
  }

  int getDelivery(){
    var brgy = widget.address.toString().split("%")[1];

    if (brgy == "San Isidro") {
      return 200;
    } else if (brgy == "San Jose") {
      return 400;
    } else if (brgy == "Burgos") {
      return 400;
    } else if (brgy == "Manggahan") {
      return 400;
    } else if (brgy == "Rosario") {
      return 350;
    } else if (brgy == "Balite") {
      return 350;
    } else if (brgy == "Geronimo") {
      return 350;
    } else if (brgy == "San Rafael") {
      return 300;
    } else if (brgy == "Mascap") {
      return 200;
    } else if (brgy == "Macabud") {
      return 350;
    } else if (brgy == "Puray") {
      return 250;
    } else {
      return 0;
    }
  }

  var values = List.filled(999, 101);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 500,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Buy Again",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Items:",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                    child: ListView.builder(
                      itemCount: widget.summaryItems.length,
                      itemBuilder: (context, index){
                        return FutureBuilder(
                            future: FirebaseFirestore.instance.collection('Items').doc(widget.summaryItems[index].toString().split(",")[0]).get(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                             /*   if(int.parse(snapshot.data!['Minimum']) < int.parse(snapshot.data!['Stocks'])){
                                  widget.summaryItems.removeAt(index);
                                }*/
                                return  ListTile(
                                  contentPadding: const EdgeInsets.all(0),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: SizedBox(
                                      child: Image.network(
                                        snapshot.data!['Url'],
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    "${snapshot.data!['Name']} (${widget.summaryItems[index].toString().split(",")[2]})",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "PHP${snapshot.data!['Price']}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                    ),
                                  ),
                                  trailing: NumberPicker(
                                    value: values[index],
                                    itemCount: 1,
                                    itemHeight: 30,
                                    itemWidth: 30,
                                    selectedTextStyle: GoogleFonts.poppins(
                                      fontSize: 16,
                                    ),
                                    minValue: int.parse(snapshot.data!['Minimum']),
                                    maxValue: int.parse(snapshot.data!['Stocks']),
                                    onChanged: (value){
                                      setState(() {
                                        values[index] = value;
                                      });
                                      widget.summaryItems[index] = "${widget.summaryItems[index].toString().split(",")[0]},${value},${widget.summaryItems[index].toString().split(",")[2]}";
                                    },
                                  ),

                              /*    Column(
                                    children: [
                                      IconButton(
                                        onPressed: (){

                                        },
                                        icon: const Icon(Icons.add_circle_outline)
                                      ),
                                      Text(
                                        "x${widget.summaryItems[index].toString().split(",")[1]}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                        ),
                                      ),
                                      IconButton(
                                          onPressed: (){

                                          },
                                          icon: const Icon(Icons.remove_circle_outline)
                                      )
                                    ],
                                  ),*/
                                );
                              }
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                        );

                      },
                    )
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      "Delivery Fee:",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "PHP${getDelivery().toString()}",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Total:",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    FutureBuilder(
                        future: calculateTotal(widget.summaryItems),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            print(widget.summaryItems);
                            return Text(
                              "PHP${snapshot.data}",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                              ),
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: (){
                        FirestoreService().createOrder(widget.summaryItems, widget.name, widget.contact, widget.address, widget.sellerID, "");
                        Fluttertoast.showToast(msg: "Order has been placed");
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors().primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fixedSize: const Size(100, 40),
                      ),
                      child: Text(
                        "COD",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: (){
                        Navigator.pop(context);
                        showDialog(context: context, builder: (builder){
                          return PaymentDialog(items: widget.summaryItems, name: widget.name, contact: widget.contact, address: widget.address, sellerID: widget.sellerID,);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors().primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fixedSize: const Size(100, 40),
                      ),
                      child: Text(
                        "GCASH",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
