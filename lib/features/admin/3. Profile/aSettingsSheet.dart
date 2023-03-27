import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:growcery/constants/AppColors.dart';

class ASettingsSheet extends ConsumerStatefulWidget {
  const ASettingsSheet({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _ASettingsSheetState();
}

class _ASettingsSheetState extends ConsumerState<ASettingsSheet> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Settings",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors().primaryColor,
                  fixedSize: Size(MediaQuery.of(context).size.width, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  String email = FirebaseAuth.instance.currentUser!.email.toString();
                  FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                  Fluttertoast.showToast(msg: "Please check your email to reset your password.");
                },
                child: Text(
                  "Reset Password",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
