import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:growcery/features/user/3.%20Profile/uEditProfileDialog.dart';

import '../../../constants/AppColors.dart';
import '../../../services/AuthService.dart';
import '../../ViewModels/UserViewModel.dart';

class USettingsSheet extends ConsumerStatefulWidget {
  const USettingsSheet({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _USettingsSheetState();
}

class _USettingsSheetState extends ConsumerState<USettingsSheet> {

  @override
  Widget build(BuildContext context) {

    var user = ref.watch(userProvider);

    return user.when(
      data: (data){
        return SizedBox(
          height: 300,
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
                      backgroundColor: Colors.white,
                      fixedSize: Size(MediaQuery.of(context).size.width, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      showDialog(context: context, builder: (builder){
                        return UEditProfileDialog(data: data);
                      });
                    },
                    child: Text(
                      "Edit Profile",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff414141),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      fixedSize: Size(MediaQuery.of(context).size.width, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      AuthService().signOut();
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Logout",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff414141),
                      ),
                    ),
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
      },
      error: (error, stack){
        return Center(
          child: Text(error.toString()),
        );
      },
      loading: (){
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
