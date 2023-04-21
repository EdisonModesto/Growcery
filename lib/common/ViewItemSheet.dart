import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:growcery/services/FirestoreService.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../constants/AppColors.dart';
import 'AddToBasketSheet.dart';

class ViewItemSheet extends ConsumerStatefulWidget {
  const ViewItemSheet({
    required this.name,
    required this.price,
    required this.description,
    required this.stock,
    required this.image,
    required this.id,
    required this.min,
    required this.sellerID,
    required this.measurement,
    Key? key,
  }) : super(key: key);

  final String name;
  final String price;
  final String description;
  final String stock;
  final String image;
  final String id;
  final min;
  final sellerID;
  final measurement;

  @override
  ConsumerState createState() => _ViewItemSheetState();
}

class _ViewItemSheetState extends ConsumerState<ViewItemSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      color: AppColors().primaryColor,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Image.network(
                        widget.image,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "${widget.name} - MINIMUM OF ${widget.min}/${widget.measurement}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "PHP ${widget.price}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(thickness: 1, color: Colors.white),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Description",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Stocks: ${widget.stock}/${widget.measurement}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.description,
                    textAlign: TextAlign.justify,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 7),

                  const Divider(thickness: 1, color: Colors.white),

                  const SizedBox(height: 7),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance.collection("Users").doc(widget.sellerID).snapshots(),
                      builder: (context, snapshot) {
                        if(snapshot.hasData){
                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(snapshot.data!["Image"]),
                              ),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data!["Name"],
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  StreamBuilder(
                                      stream: FirebaseFirestore.instance.collection("Users").doc(widget.sellerID).collection("Ratings").snapshots(),
                                      builder: (context, snapshot1) {
                                        if(snapshot1.hasData){
                                          double totalRating = 0;

                                          snapshot1.data!.docs.forEach((element) {
                                            totalRating += element.data()["Rating"];
                                          });

                                          totalRating = totalRating == 0 ? 0.0 : totalRating / snapshot1.data!.docs.length;
                                          return RatingBar.builder(
                                            initialRating: totalRating,
                                            minRating: 0,
                                            unratedColor: Colors.grey[200],
                                            direction: Axis.horizontal,
                                            ignoreGestures: true,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemPadding: const EdgeInsets.symmetric(horizontal:0),
                                            itemSize: 20,
                                            itemBuilder: (context, _) => const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            onRatingUpdate: (rating) {
                                              print(rating);
                                            },
                                          );
                                        }
                                        return const SizedBox();
                                      }
                                  ),

                                ],
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: (){
                                  context.pushNamed("sellerStore", params: {"sellerID": widget.sellerID});
                                },
                                child: const Text(
                                  "View Shop",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          );
                        }
                        return const SizedBox();
                      }
                  ),
                  const Divider(thickness: 1, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 50,
            padding: const EdgeInsets.only(left: 20, right: 20,),
            margin: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("Items").doc(widget.id).snapshots(),
                    builder: (context, snapshot) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        fixedSize: const Size(120, 40),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                      child: Text(
                        "Buy Now",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppColors().primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      onPressed: (){
                        if (int.parse(widget.stock) >=int.parse(widget.min)) {
                          showMaterialModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            builder: (context) => AddToBasketSheet(id: widget.id, minimum: widget.min, isNow: true, sellerID: snapshot.data?["SellerID"], variations: snapshot.data?["Variations"], stocks: snapshot.data?["Stocks"],),
                          );
                        } else {
                          Fluttertoast.showToast(
                            msg: "Insufficient Stocks for minimum order",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                        //FirestoreService().addToBasket(widget.id);
                      },
                    );
                  }
                ),
                const SizedBox(width: 20,),
                StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("Items").doc(widget.id).snapshots(),
                    builder: (context, snapshot) {
                    if(snapshot.hasData){
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          fixedSize: const Size(150, 40),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                        child: Text(
                          "Add to Basket",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color:AppColors().primaryColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        onPressed: (){
                          if (int.parse(widget.stock) >=int.parse(widget.min)) {
                            showMaterialModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              builder: (context) => AddToBasketSheet(id: widget.id, minimum: widget.min, isNow: false, sellerID: widget.sellerID, variations: snapshot.data?["Variations"], stocks: snapshot.data?["Stocks"],),
                            );
                          } else {
                            Fluttertoast.showToast(
                              msg: "Insufficient Stocks for minimum order",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          }
                          //FirestoreService().addToBasket(widget.id);
                        },
                      );
                    }
                    return const SizedBox();
                  }
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
