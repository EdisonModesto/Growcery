import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:growcery/constants/AppColors.dart';


class SplashView extends ConsumerStatefulWidget {
  const SplashView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {

  void startTimer(){
    Future.delayed(const Duration(seconds: 3), () {
      context.go('/user');
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
        child: ColoredBox(
          color: AppColors().primaryColor,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 55,
                  backgroundImage: AssetImage('assets/images/growceryLogo.jpg'),
                ),
                const SizedBox(height: 10),
                Text(
                  'Growcery',
                  style: GoogleFonts.poppins(
                    fontSize: 30,
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
