import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../constants/AppColors.dart';
import '../../../services/FirestoreService.dart';
import 'RefundSheet.dart';

class RatingSheet extends ConsumerStatefulWidget {
  const RatingSheet({
    Key? key,
    required this.orderData,
  }) : super(key: key);

  final QueryDocumentSnapshot<Map<String, dynamic>> orderData;
  @override
  ConsumerState createState() => _RatingSheetState();
}

class _RatingSheetState extends ConsumerState<RatingSheet> {

  double rating = 0;

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.only(left: 40, right: 40, top: 20, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Rate Us!",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 40,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (ratingC) {
                  rating = ratingC;
                },
              ),
            ),
            Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(MediaQuery.of(context).size.width, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: AppColors().primaryColor,
                  ),
                  onPressed: (){
                    print(widget.orderData.data()!["SellerID"]);
                    FirestoreService().saveRating(
                        rating,
                        widget.orderData.data()!["SellerID"],
                        widget.orderData.data()!["User"],
                        widget.orderData.id,
                    );
                    Fluttertoast.showToast(
                        msg: "Thank You!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                    FirestoreService().updateOrderStatus(widget.orderData.id, "3");
                    Navigator.pop(context);
                  },
                  child: const Text("Submit"),
                ),
                const SizedBox(height: 10,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(MediaQuery.of(context).size.width, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  onPressed: (){

                    Navigator.pop(context);
                    showMaterialModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      builder: (context) => RefundSheet(
                        orderData: widget.orderData,
                      ),
                    );
                  },
                  child:  Text(
                    "Refund",
                    style: GoogleFonts.poppins(
                      color: const Color(0xff414141),
                    ),
                  ),
                ),

              ],
            ),

          ],
        ),
      ),
    );
  }
}
