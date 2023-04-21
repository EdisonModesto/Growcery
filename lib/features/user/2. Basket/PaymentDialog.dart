import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../../constants/AppColors.dart';
import '../../../services/CloudService.dart';
import '../../../services/FilePickerService.dart';
import '../../../services/FirestoreService.dart';

class PaymentDialog extends ConsumerStatefulWidget {
  const PaymentDialog({
    @required this.items,
    @required this.name,
    @required this.contact,
    @required this.address,
    @required this.sellerID,
    Key? key,
  }) : super(key: key);

  final items, name, contact, address, sellerID;

  @override
  ConsumerState createState() => _PaymentDialogState();
}

class _PaymentDialogState extends ConsumerState<PaymentDialog> {

  String url = "";


  @override
  Widget build(BuildContext context) {
    return Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: SizedBox(
            height: 550,
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
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance.collection('Users').doc(widget.sellerID).snapshots(),
                        builder: (context, snapshot) {
                          return Text(
                            "Gcash: ${snapshot.data!.data()!["GCash"]}\nName: ${snapshot.data!.data()!["Name"]}",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          );
                        }
                    ),
                  ),
                  const SizedBox(height: 25,),

                  SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Image.network(
                            url == ""
                                ? "https://via.placeholder.com/500 "
                                : url,
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                          ),
                          Center(
                            child: IconButton(
                              onPressed: () async {
                                var image =
                                await FilePickerService().pickImage();

                                if (image != null) {
                                  var uuid = const Uuid();
                                  var id = uuid.v4();

                                  url = await CloudService().uploadImage(image, id);
                                  setState(() {});
                                  print("url updated");
                                }
                              },
                              icon: Icon(
                                Icons.upload_file,
                                size: 40,
                                color: AppColors().primaryColor,
                              ),
                            ),
                          ),
                        ],
                      )
                  ),
                  Spacer(),

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
                            if(url != ""){
                              FirestoreService().createOrder(widget.items, widget.name, widget.contact, widget.address, widget.sellerID, url);

                              Fluttertoast.showToast(msg: "Order placed successfully");
                              Navigator.pop(context);
                            } else {
                              Fluttertoast.showToast(msg: "Please upload your proof of payment");
                            }
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

