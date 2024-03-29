import 'package:filter_profanity/filter_profanity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../../constants/AppColors.dart';
import '../../../services/AuthService.dart';
import '../../../services/CloudService.dart';
import '../../../services/FilePickerService.dart';
import '../../../services/FirestoreService.dart';

class EditItemSheet extends ConsumerStatefulWidget {
  const EditItemSheet({
    required this.url,
    required this.name,
    required this.price,
    required this.quantity,
    required this.description,
    required this.id,
    required this.category,
    required this.mini,
    required this.variations,
    Key? key,
  }) : super(key: key);

  final url, name, price, quantity, description, id, category, mini, variations;

  @override
  ConsumerState createState() => _EditItemSheetState();
}

class _EditItemSheetState extends ConsumerState<EditItemSheet> {
  var _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController minimumController = TextEditingController();
  TextEditingController variationController = TextEditingController();

  List<dynamic> variations = [];

  String url = "";

  var popUpItems = [

    PopupMenuItem(
      value: "Vegetables",
      child: Text(
        "Vegetables",
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
    PopupMenuItem(
      value: "Fruits",
      child: Text(
        "Fruits",
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
  ];

  var measurementItems = [

    PopupMenuItem(
      value: "Kg",
      child: Text(
        "Kg",
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
    PopupMenuItem(
      value: "Sack",
      child: Text(
        "Sack",
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
    PopupMenuItem(
      value: "Bundle",
      child: Text(
        "Bundle",
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
  ];
  var measurementValue = "Kg";

  var value = "Vegetables";

  @override
  void initState() {
    url = widget.url;
    nameController.text = widget.name;
    priceController.text = widget.price;
    quantityController.text = widget.quantity;
    descriptionController.text = widget.description;
    minimumController.text = widget.mini;
    value = widget.category;
    variations = widget.variations;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: SizedBox(
            height: 1000,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: nameController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "";
                              } else if (hasProfanity(value,
                                  offensiveWords: filipinoOffensiveWords +
                                      englishOffensiveWords)) {
                                Fluttertoast.showToast(
                                    msg: "Profanity not allowed!");
                                return "";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              errorStyle: GoogleFonts.poppins(
                                height: 0,
                              ),
                              labelText: "Name",
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
                        const SizedBox(
                          width: 10,
                        ),
                        PopupMenuButton(
                          icon: Icon(
                            Icons.filter_list,
                            color: AppColors().primaryColor,
                          ),
                          onSelected: (val) {
                            value = val.toString();
                            setState(() {});
                          },
                          itemBuilder: (context) => popUpItems,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
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
                        labelText: "Price",
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
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: quantityController,
                            keyboardType: TextInputType.number,
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
                              labelText: "Stocks",
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
                        const SizedBox(
                          width: 10,
                        ),
                        PopupMenuButton(
                          icon: Icon(
                            Icons.monitor_weight_outlined,
                            color: AppColors().primaryColor,
                          ),
                          onSelected: (val) {
                            measurementValue = val.toString();
                            setState(() {});
                          },
                          itemBuilder: (context) => measurementItems,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: TextFormField(
                      controller: minimumController,
                      keyboardType: TextInputType.number,
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
                        labelText: "Minimum Order (KG)",
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
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 150,
                    child: TextFormField(
                      controller: descriptionController,
                      maxLines: 10,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "";
                        } else if (hasProfanity(value,
                            offensiveWords: filipinoOffensiveWords +
                                englishOffensiveWords)) {
                          Fluttertoast.showToast(msg: "Profanity not allowed!");
                          return "";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        errorStyle: GoogleFonts.poppins(
                          height: 0,
                        ),
                        labelText: "Description",
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
                  Row(
                      children: List.generate(variations.length, (index) => Chip(
                        onDeleted: () {
                          setState(() {
                            variations.removeAt(index);
                          });
                        },
                        label: Text(
                          variations[index],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ))
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: variationController,
                            decoration: InputDecoration(
                              errorStyle: GoogleFonts.poppins(
                                height: 0,
                              ),
                              labelText: "Add Variation",
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
                        const SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          onPressed: () {
                            if (variationController.text != "") {
                              variations.add(variationController.text);
                              variationController.clear();
                              setState(() {});
                            }
                          },
                          icon: Icon(
                            Icons.add,
                            color: AppColors().primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && url != "" && variations.isNotEmpty) {
                        FirestoreService().updateItem(
                            url,
                            nameController.text,
                            priceController.text,
                            quantityController.text,
                            descriptionController.text,
                            widget.id,
                            value,
                            minimumController.text,
                            AuthService().getID(),
                          variations,
                          measurementValue
                        );
                        Navigator.pop(context);
                      } else {
                        Fluttertoast.showToast(
                            msg:
                                "Please make sure to fill up all the fields and upload an image");
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
                      "Save",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
