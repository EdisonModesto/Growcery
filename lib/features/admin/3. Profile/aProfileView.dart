import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/AuthService.dart';
import '../../ViewModels/AuthViewModels.dart';

class AProfileView extends ConsumerStatefulWidget {
  const AProfileView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _AProfileViewState();
}

class _AProfileViewState extends ConsumerState<AProfileView> {
  @override
  Widget build(BuildContext context) {
    var authState = ref.watch(authStateProvider);

    return authState.when(
        data: (data){
          return DefaultTabController(
            length: 4,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Profile",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CircleAvatar(
                          radius: 35,
                          backgroundImage: AssetImage("assets/images/growceryLogo.jpg"),
                        ),
                        const SizedBox(width: 20,),
                        Text(
                          "Growcery Admin",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                          ),
                        ),
                        IconButton(
                          onPressed: (){
                            AuthService().signOut();
                          },
                          icon: const Icon(Icons.logout),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),


                  ],
                ),
              ),
            ),
          );
        },
        error: (error, stack){
          return Scaffold(
            body: Center(
              child: Text(error.toString()),
            ),
          );
        },
        loading: (){
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
    );
  }
}
