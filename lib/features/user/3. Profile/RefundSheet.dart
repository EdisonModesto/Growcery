import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:google_fonts/google_fonts.dart";
import "package:growcery/services/AuthService.dart";
import "package:growcery/services/FirestoreService.dart";
import "package:uuid/uuid.dart";

import "../../../constants/AppColors.dart";
import "../../../services/CloudService.dart";
import "../../../services/FilePickerService.dart";

class RefundSheet extends ConsumerStatefulWidget {
  const RefundSheet({
    Key? key,
    required this.orderData,
  }) : super(key: key);

  final QueryDocumentSnapshot<Map<String, dynamic>> orderData;

  @override
  ConsumerState createState() => _RefundSheetState();
}

class _RefundSheetState extends ConsumerState<RefundSheet> {
  final _formKey = GlobalKey<FormState>();

  String url = "";
  TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 550,
      child: Padding(
        padding: const EdgeInsets.only(left: 40, right: 40, top: 20, bottom: 20),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("Users").doc(AuthService().getID()).snapshots(),
          builder: (context, snapshot) {
            if(snapshot.hasData){
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Refund",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

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

                                    url = await CloudService()
                                        .uploadImage(image, id);
                                    setState(() {});
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
                        )),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: commentController,
                      maxLines: 5,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        errorStyle: GoogleFonts.poppins(
                          height: 0,
                        ),
                        labelText: "Comment",
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Contact number: ${snapshot.data!["Contact"]}",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate() && url != "") {
                          FirestoreService().refundOrder(
                            widget.orderData.id,
                            url,
                            commentController.text,
                            snapshot.data!["Contact"],
                          );
                          Fluttertoast.showToast(msg: "Refund sent successfully");
                          Navigator.pop(context);
                        } else {
                          Fluttertoast.showToast(
                              msg: "Please make sure to fill up all the fields and upload an image");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(MediaQuery.of(context).size.width, 50),
                        backgroundColor: AppColors().primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Submit Refund",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }
        ),
      ),
    );
  }
}
