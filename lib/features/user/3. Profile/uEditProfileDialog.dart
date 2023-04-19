import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:growcery/services/FirestoreService.dart';
import 'package:philippines/city.dart';
import 'package:philippines/philippines.dart';
import 'package:philippines/province.dart';
import 'package:philippines/region.dart';

import '../../../constants/AppColors.dart';
import '../../../services/AuthService.dart';
import '../../../services/CloudService.dart';
import '../../../services/FilePickerService.dart';

class UEditProfileDialog extends ConsumerStatefulWidget {
  const UEditProfileDialog({
    required this.data,
    Key? key,
  }) : super(key: key);

  final DocumentSnapshot<Map<String, dynamic>> data;

  @override
  ConsumerState createState() => _UEditProfileDialogState();
}

class _UEditProfileDialogState extends ConsumerState<UEditProfileDialog> {
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController contactCtrl = TextEditingController();
  TextEditingController streetCtrl = TextEditingController();
  TextEditingController cityCtrl = TextEditingController();
  TextEditingController brgyCtrl = TextEditingController();
  TextEditingController gcashCtrl = TextEditingController();

  var key = GlobalKey<FormState>();
  var reg = "San Isidro";
  var url = "";

  List<City> cities = getCities();
  List<Province> provinces = getProvinces();
  List<Region> regions = getRegions();


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
    nameCtrl.text = widget.data.data()!["Name"];
    contactCtrl.text = widget.data.data()!["Contact"];

    List<String> formattedAddress = widget.data.data()!["Address"].toString().split("%");

    streetCtrl.text = formattedAddress[0];

    brgyCtrl.text = formattedAddress[1];
    reg = formattedAddress[1];
    cityCtrl.text = "Montalban";

    url = widget.data.data()!["Image"];
    gcashCtrl.text = widget.data.data()!["GCash"];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SizedBox(
          height: 500,
          width: MediaQuery.of(context).size.width * 0.8,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Form(
              key: key,
              child: SingleChildScrollView(
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        url == "" ?
                        const CircleAvatar(
                          radius: 45,
                          child: Icon(Icons.person),
                        ) : CircleAvatar(
                          radius: 45,
                          backgroundImage: NetworkImage(url),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            File? image = await FilePickerService().pickImage();
                            if(image != null){
                              url = await CloudService().uploadImage(image, AuthService().getID()!);
                              setState(() {});
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors().primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Change Profile Picture"),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: 50,
                      child: TextFormField(
                        controller: nameCtrl,
                        style: const TextStyle(
                            fontSize: 14
                        ),
                        decoration: const InputDecoration(
                          errorStyle: TextStyle(height: 0),
                          label: Text("Name"),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 2.0,
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
                    SizedBox(
                      height: 50,
                      child: TextFormField(
                        controller: contactCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            fontSize: 14
                        ),
                        decoration: const InputDecoration(
                          errorStyle: TextStyle(height: 0),
                          label: Text("Contact Number"),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 2.0,
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
                    SizedBox(
                      height: 50,
                      child: TextFormField(
                        controller: gcashCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                            fontSize: 14
                        ),
                        decoration: const InputDecoration(
                          errorStyle: TextStyle(height: 0),
                          label: Text("GCash"),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 2.0,
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
                              width: 2.0,
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
                        controller: cityCtrl,
                        enabled: false,
                        style: const TextStyle(
                            fontSize: 14
                        ),
                        decoration: const InputDecoration(
                          errorStyle: TextStyle(height: 0),
                          label: Text("Municipality"),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(8),
                            ),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 2.0,
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
                      height: 15,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (key.currentState!.validate()){
                          FirestoreService().updateUser(
                              nameCtrl.text,
                              "${streetCtrl.text}%${brgyCtrl.text}%${cityCtrl.text}",
                              url,
                              contactCtrl.text,
                            gcashCtrl.text,
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        fixedSize: Size(MediaQuery.of(context).size.width, 50),
                        backgroundColor: AppColors().primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Save"),
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
