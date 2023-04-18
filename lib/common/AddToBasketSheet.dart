import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/AppColors.dart';
import '../features/ViewModels/UserViewModel.dart';
import '../features/user/2. Basket/PaymentDialog.dart';
import '../services/FirestoreService.dart';

class AddToBasketSheet extends ConsumerStatefulWidget {
  const AddToBasketSheet({
    required this.id,
    required this.minimum,
    required this.isNow,
    required this.sellerID,
    Key? key,
  }) : super(key: key);

  final String id;
  final minimum;
  final isNow;
  final sellerID;

  @override
  ConsumerState createState() => _AddToBasketSheetState();
}

class _AddToBasketSheetState extends ConsumerState<AddToBasketSheet> {

  int value = 1;

  @override
  void initState() {
    value = int.parse(widget.minimum);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    var user = ref.watch(userProvider);

    return user.when(
      data: (data){

        return SizedBox(
          height: 250,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add to Basket",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        "Quantity",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          setState(() {
                            if(value > 1 && value > int.parse(widget.minimum)){
                              value--;
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Minimum quantity is ${widget.minimum}",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );
                            }
                          });
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              "-",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "$value",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          setState(() {
                            value++;
                          });
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              "+",
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      if(widget.isNow == true){
                        if (data.data()!["Name"] != "" &&  data.data()!["Contact"] != "" &&  data.data()!["Address"].toString().split("%")[0] != "No Data") {
                          showDialog(context: context, builder: (builder){
                            return AlertDialog(
                              title: const Text("Payment Method"),
                              content: const Text("Please select your payment method"),
                              actions: [
                                TextButton(onPressed: (){
                                  FirestoreService().createOrder(["${widget.id},$value"],  data.data()!["Name"], data.data()!["Contact"], data.data()!["Address"], widget.sellerID);
                                  Fluttertoast.showToast(msg: "Order has been placed");
                                  Navigator.pop(builder);
                                }, child: const Text("COD")),
                                TextButton(onPressed: (){
                                  showDialog(context: context, builder: (builder){
                                    return PaymentDialog(items: ["${widget.id},$value"], name:  data.data()!["Name"], contact: data.data()!["Contact"], address: data.data()!["Address"], sellerID: widget.sellerID,);
                                  });
                                }, child: const Text("Gcash")),
                              ],
                            );
                          });
                        } else {
                          Fluttertoast.showToast(msg: "No items in basket or you have not filled up your profile yet");
                        }
                      } else {
                        FirestoreService().addToBasket(widget.id, value);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      fixedSize: Size(MediaQuery.of(context).size.width, 50),
                      backgroundColor: AppColors().primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      widget.isNow ? "Buy Now" : "Add to Basket",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
      error: (error, stackTrace){
        return const Center(child: Text("Something went wrong"));
      },
      loading: (){
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
