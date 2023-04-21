import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:growcery/services/AuthService.dart';
import 'package:growcery/services/FirestoreService.dart';
import 'package:philippines/city.dart';
import 'package:philippines/philippines.dart';
import 'package:philippines/province.dart';
import 'package:philippines/region.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants/AppColors.dart';

class AuthView extends ConsumerStatefulWidget {
  const AuthView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _AuthDialogState();
}

class _AuthDialogState extends ConsumerState<AuthView> {
  var key = GlobalKey<FormState>();
  var key2 = GlobalKey<FormState>();
  late WebViewController controller;

  String _selectedOption = "";
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController contactCtrl = TextEditingController();
  TextEditingController streetCtrl = TextEditingController();
  TextEditingController cityCtrl = TextEditingController();
  TextEditingController brgyCtrl = TextEditingController();
  TextEditingController gcashCtrl = TextEditingController();

  var reg = "San Isidro";
  var url = "";

  List<City> cities = getCities();
  List<Province> provinces = getProvinces();
  List<Region> regions = getRegions();
  var obscure = true;
  bool ppc = false;

  List<String> brgy = [
    "San Isidro",
    "San Jose",
    "Burgos",
    "Manggahan",
    "Rosario",
    "Balite",
    "Geronimo",
    "San Rafael",
    "Mascap",
    "Macabud",
    "Puray"
  ];


  @override
  void initState() {
    cityCtrl.text = "Montalban";
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://doc-hosting.flycricket.io/growcery-terms-of-use/a2197822-7196-4fa8-b3ba-d3c7ddb791a4/terms'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 75,),

                    const CircleAvatar(
                      backgroundImage: AssetImage("assets/images/growceryLogo.jpg"),
                      radius: 50,
                    ),
                    const SizedBox(height: 50,),
                    TabBar(
                      isScrollable: true,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.black,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: AppColors().primaryColor,
                      ),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 30),
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
                    SizedBox(
                      height: 300,
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
                                      obscureText: obscure,
                                      decoration: InputDecoration(
                                        labelText: "Password",
                                        labelStyle: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              obscure = !obscure;
                                            });
                                          },
                                          icon: Icon(
                                            obscure ? Icons.visibility_off : Icons.visibility,
                                            color: Colors.grey,
                                          ),
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
                                  ElevatedButton(
                                    onPressed: () {
                                      if (key.currentState!.validate()){
                                        AuthService().signIn(emailController.text, passwordController.text, context);
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
                                  const SizedBox(height: 15,),
                                  TextButton(
                                    onPressed: () {
                                      if(emailController.text.isNotEmpty){
                                        AuthService().resetPassword(emailController.text);
                                      } else {
                                        Fluttertoast.showToast(msg: "Email field is empty, cannot reset password");
                                      }
                                    },
                                    child: Text(
                                      "Forgot Password?",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  )

                                ],
                              ),
                            ),
                            Form(
                              key: key2,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      child: TextFormField(
                                        controller: emailController,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "";
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          labelText: "Email",
                                          errorStyle: const TextStyle(height: 0),
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
                                    const SizedBox(height: 10,),
                                    SizedBox(
                                      height: 50,
                                      child: TextFormField(
                                        controller: passwordController,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "";
                                          }
                                          return null;
                                        },
                                        obscureText: obscure,
                                        decoration: InputDecoration(
                                          labelText: "Password",
                                          errorStyle: const TextStyle(height: 0),

                                          labelStyle: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                obscure = !obscure;
                                              });
                                            },
                                            icon: Icon(
                                              obscure ? Icons.visibility_off : Icons.visibility,
                                              color: Colors.grey,
                                            ),
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
                                    const SizedBox(height: 10,),
                                    SizedBox(
                                      height: 50,
                                      child: TextFormField(
                                        controller: nameCtrl,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "";
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          labelText: "Name",
                                          errorStyle: const TextStyle(height: 0),

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
                                    const SizedBox(height: 10,),
                                    SizedBox(
                                      height: 50,
                                      child: TextFormField(
                                        controller: contactCtrl,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "";
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          labelText: "Contact",
                                          errorStyle: const TextStyle(height: 0),

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
                                    const SizedBox(height: 10,),
                                    SizedBox(
                                      height: 50,
                                      child: TextFormField(
                                        controller: gcashCtrl,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "";
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          labelText: "GCash",
                                          errorStyle: const TextStyle(height: 0),

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
                                    const SizedBox(height: 10,),
                                    SizedBox(
                                      height: 50,
                                      child: TextFormField(
                                        controller: streetCtrl,
                                        style: const TextStyle(
                                            fontSize: 14
                                        ),
                                        decoration: const InputDecoration(
                                          errorStyle: TextStyle(height: 0),
                                          label: Text("House Number & Street Name"),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8),
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),

                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8),
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.red,
                                              width: 6.0,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          "Barangay: ",
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                        const Spacer(),
                                        DropdownButton(
                                          value: reg,
                                          items: List.generate(brgy.length, (index){
                                            return DropdownMenuItem(
                                              value: brgy[index],
                                              child: Text(
                                                  brgy[index]
                                              ),
                                            );
                                          }),
                                          onChanged: (value) {
                                            setState(() {
                                              brgyCtrl.text = value!;
                                              reg = value;
                                              //goal = value.toString();
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 50,
                                      child: TextFormField(
                                        enabled: false,
                                        controller: cityCtrl,
                                        style: const TextStyle(
                                            fontSize: 14
                                        ),
                                        decoration: const InputDecoration(
                                          errorStyle: TextStyle(height: 0),
                                          label: Text("City"),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8),
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),

                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8),
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.red,
                                              width: 6.0,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return "";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: ppc,
                                          onChanged: (val){
                                            setState(() {
                                              ppc = val!;
                                            });
                                          },
                                        ),
                                        RichText(
                                          text: TextSpan(
                                              text: "I agree to the  ",
                                              style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: "Privacy Policy",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColors().primaryColor,
                                                  ),
                                                  recognizer: TapGestureRecognizer()
                                                    ..onTap = () {
                                                      Navigator.push(context, MaterialPageRoute(builder: (context){
                                                        return Center(
                                                          child: Card(
                                                            child: SizedBox(
                                                              child: WebViewWidget(controller: controller),
                                                            ),
                                                          ),
                                                        );
                                                      }));
                                                    },
                                                ),
                                              ]
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        RadioListTile(

                                          title: const Text('Market'),
                                          value: 'Buyer',
                                          groupValue: _selectedOption,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedOption = value!;
                                            });
                                          },
                                        ),
                                        RadioListTile(
                                          title: const Text('Farm'),
                                          value: 'Seller',
                                          groupValue: _selectedOption,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedOption = value!;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (key2.currentState!.validate() && ppc){
                                          AuthService().signUp(emailController.text, passwordController.text,_selectedOption , context, nameCtrl.text, contactCtrl.text, gcashCtrl.text, "${streetCtrl.text}%${brgyCtrl.text}%${cityCtrl.text}");
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
      ),
    );
  }
}
