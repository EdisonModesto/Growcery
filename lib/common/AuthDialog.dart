import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:growcery/services/AuthService.dart';

import '../constants/AppColors.dart';

class AuthDialog extends ConsumerStatefulWidget {
  const AuthDialog({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _AuthDialogState();
}

class _AuthDialogState extends ConsumerState<AuthDialog> {
  var key = GlobalKey<FormState>();
  var key2 = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: SizedBox(
            height: 325,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15,),
                  TabBar(
                    isScrollable: true,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: AppColors().primaryColor,
                    ),
                    splashBorderRadius: BorderRadius.circular(50),
                    tabs: [
                      Tab(
                        child: Text(
                          "Login",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "Signup",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15,),
                  Expanded(
                    child: TabBarView(
                      children: [
                        Form(
                          key: key,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 50,
                                child: TextFormField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    labelText: "Email",
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
                              ),
                              const SizedBox(height: 15,),
                              SizedBox(
                                height: 50,
                                child: TextFormField(
                                  controller: passwordController,
                                  decoration: InputDecoration(
                                    labelText: "Password",
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
                              ),
                              const SizedBox(height: 25,),
                              ElevatedButton(
                                onPressed: () {
                                  if (key.currentState!.validate()){
                                    AuthService().signIn(emailController.text, passwordController.text);
                                    Navigator.of(context).pop();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(MediaQuery.of(context).size.width, 50),
                                  elevation: 0,
                                  backgroundColor: AppColors().primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                ),
                                child: const Text("Login"),
                              ),

                            ],
                          ),
                        ),
                        Form(
                          key: key2,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 50,
                                child: TextFormField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    labelText: "Email",
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
                              ),
                              const SizedBox(height: 15,),
                              SizedBox(
                                height: 50,
                                child: TextFormField(
                                  controller: passwordController,
                                  decoration: InputDecoration(
                                    labelText: "Password",
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
                              ),
                              const SizedBox(height: 25,),
                              ElevatedButton(
                                onPressed: () {
                                  if (key2.currentState!.validate()){
                                    AuthService().signUp(emailController.text, passwordController.text);
                                    Navigator.of(context).pop();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(MediaQuery.of(context).size.width, 50),
                                  elevation: 0,
                                  backgroundColor: AppColors().primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                ),
                                child: const Text("Signup"),
                              ),

                            ],
                          ),
                        ),
                      ],
                    )
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
