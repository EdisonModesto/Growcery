import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:growcery/constants/AppColors.dart';
import 'package:growcery/services/AuthService.dart';
import 'package:growcery/services/FirestoreService.dart';


class SplashView extends ConsumerStatefulWidget {
  const SplashView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {

  void startTimer(){
    Future.delayed(const Duration(seconds: 3), () async {
      if(FirebaseAuth.instance.currentUser?.uid != null){
        var userType = await FirestoreService().checkUserType(AuthService().getID());
        if(userType == "Buyer"){
          context.go('/user');
        } else if(userType == "Seller"){
          context.go('/seller');
        } else if(userType == "Admin"){
          context.go('/seller');
        } else {
          context.go('/auth');
        }
      } else {
        context.go('/auth');

      }
    });
  }

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/landingPage.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 55,
                  backgroundImage: AssetImage('assets/images/growceryLogo.jpg'),
                ),
                const SizedBox(height: 20),
                Text(
                  'Growcery',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}
