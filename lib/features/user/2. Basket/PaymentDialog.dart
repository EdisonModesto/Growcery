import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constants/AppColors.dart';
import '../../../services/FirestoreService.dart';

class PaymentDialog extends ConsumerWidget {
  const PaymentDialog({
    @required this.items,
    @required this.name,
    @required this.contact,
    @required this.address,
    @required this.sellerID,
    Key? key,
  }) : super(key: key);

  final items, name, contact, address, sellerID;

  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: SizedBox(
            height: 400,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payment",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors().primaryColor,
                    ),
                  ),
                  const SizedBox(height: 25,),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Total Amount: ",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25,),
                  Text(
                    "Please pay the amount to the following Gcash Number: ",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 25,),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Gcash: 09491824020\nName: Wendell R.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20,),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            FirestoreService().createOrder(items, name, contact, address, sellerID);

                            Fluttertoast.showToast(msg: "Order placed successfully");
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Confirm",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppColors().primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        )
    );
  }
}