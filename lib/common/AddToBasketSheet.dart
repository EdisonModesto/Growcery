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
    required this.variations,
    required this.stocks,
    Key? key,
  }) : super(key: key);

  final String id;
  final minimum;
  final isNow;
  final sellerID;
  final List<dynamic> variations;
  final stocks;

  @override
  ConsumerState createState() => _AddToBasketSheetState();
}

class _AddToBasketSheetState extends ConsumerState<AddToBasketSheet> {

  int value = 1;
  double height = 350;
  TextEditingController controller = TextEditingController();
  int _selectedVariationIndex = 0;



  @override
  void initState() {
    value = int.parse(widget.minimum);
    controller.text = value.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    var user = ref.watch(userProvider);
    return user.when(
      data: (data){

        return SizedBox(
          height: height,
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
                  Wrap(
                    children: List.generate(widget.variations.length, (index){
                      return ChoiceChip(
                        label: Text(widget.variations[index]),
                        selected: _selectedVariationIndex == index,
                        onSelected: (isSelected) {
                          setState(() {
                            _selectedVariationIndex = isSelected ? index : 0;
                          });
                        },
                      );
                    }),
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
                              controller.text = value.toString();
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
                      SizedBox(
                        width: 50,
                        child: TextField(
                          controller: controller,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          onChanged: (val)async{
                            await Future.delayed(Duration(seconds: 2));
                            if(int.parse(controller.text) > 1 && int.parse(controller.text) > int.parse(widget.minimum)){
                              setState(() {
                                value = int.parse(controller.text);
                              });
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
                              controller.text = widget.minimum.toString();
                            }

                          },
                          onEditingComplete: (){
                            setState(() {
                              height = 350;
                            });
                          },
                          onSubmitted: (val){
                            setState(() {
                              height = 350;
                            });
                          },
                          onTapOutside: (v){
                            setState(() {
                              height = 350;
                            });
                          },
                          onTap: (){
                            setState(() {
                              height = 500;
                            });
                          },
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "0",
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                     /* Text(
                        "$value",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),*/
                      SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          setState(() {
                            value++;
                            controller.text = value.toString();
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
                      if(int.parse(controller.text) >= int.parse(widget.minimum) && int.parse(controller.text) <= int.parse(widget.stocks)){
                        if(widget.isNow == true){
                          if (data.data()!["Name"] != "" &&  data.data()!["Contact"] != "" &&  data.data()!["Address"].toString().split("%")[0] != "No Data") {
                            showDialog(context: context, builder: (builder){
                              return AlertDialog(
                                title: const Text("Payment Method"),
                                content: const Text("Please select your payment method"),
                                actions: [
                                  TextButton(onPressed: (){
                                    FirestoreService().createOrder(
                                        ["${widget.id},$value,${widget.variations[_selectedVariationIndex]}"],
                                        data..data()!["Name"],
                                        data.data()!["Contact"],
                                        data.data()!["Address"],
                                        widget.sellerID);
                                    Fluttertoast.showToast(msg: "Order has been placed");
                                    Navigator.pop(builder);
                                  }, child: const Text("COD")),
                                  TextButton(onPressed: (){
                                    showDialog(context: context, builder: (builder){
                                      return PaymentDialog(items: ["${widget.id},$value,${widget.variations[_selectedVariationIndex]}"], name:  data.data()!["Name"], contact: data.data()!["Contact"], address: data.data()!["Address"], sellerID: widget.sellerID,);
                                    });
                                  }, child: const Text("Gcash")),
                                ],
                              );
                            });
                          } else {
                            Fluttertoast.showToast(msg: "No items in basket or you have not filled up your profile yet");
                          }
                        } else {
                          FirestoreService().addToBasket(widget.id, value, widget.variations[_selectedVariationIndex]);
                        }
                      } else {
                        Fluttertoast.showToast(
                          msg: "Minimum quantity is ${widget.minimum} and maximum is ${widget.stocks}",
                        );
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
