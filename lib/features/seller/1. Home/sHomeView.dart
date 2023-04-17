import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:growcery/services/FirestoreService.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../common/ViewItemAdmin.dart';
import '../../../common/ViewItemSheet.dart';
import '../../../constants/AppColors.dart';
import '../../../services/AuthService.dart';
import '../../ViewModels/ItemViewModel.dart';
import 'addItemSheet.dart';
import 'editItemSheet.dart';

class SHomeView extends ConsumerStatefulWidget {
  const SHomeView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _AHomeViewState();
}

class _AHomeViewState extends ConsumerState<SHomeView> {
  TextEditingController searchCtrl = TextEditingController();


  @override
  Widget build(BuildContext context) {

    var feed = ref.watch(itemProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Text(
                  "Your Stocks",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: (){
                    showModalBottomSheet(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      isScrollControlled: true,
                      context: context,
                      builder: (context){
                        return const AddItemSheet();
                      },
                    );
                  },
                  icon: Icon(
                    Icons.add,
                    color: AppColors().primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: TextField(
                controller: searchCtrl,
                onChanged: (val){
                  setState(() {});
                },
                decoration: InputDecoration(
                  contentPadding:  const EdgeInsets.symmetric(horizontal: 20),
                  hintText: "Search",
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors().primaryColor,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey[200]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey[200]!,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: feed.when(
                  data: (data){
                    var myData = data.docs.where((element) => AuthService().getID() == element.data()["SellerID"]).toList();
                    var searchResult = data.docs.where((element) => element.data()["Name"].toString().toLowerCase().contains(searchCtrl.text.toLowerCase()) && AuthService().getID() == element.data()["SellerID"]).toList();
                    return searchCtrl.text != "" ?
                    GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.8,
                        children: List.generate(searchResult.length, (index){
                          return Stack(
                            children: [
                              InkWell(
                                onTap: (){
                                  showModalBottomSheet(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                    ),
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) => ViewItemAdmin(
                                      name: searchResult[index].data()["Name"],
                                      price: searchResult[index].data()["Price"],
                                      stock: searchResult[index].data()["Stocks"],
                                      image: searchResult[index].data()["Url"],
                                      description: searchResult[index].data()["Description"],
                                      id: searchResult[index].id,
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Image.network(
                                            searchResult[index].data()["Url"],
                                            width: double.infinity,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  searchResult[index].data()["Name"],
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  "Stocks: ${searchResult[index].data()["Stocks"]}",
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: (){
                                        showMaterialModalBottomSheet(context: context, builder: (builder){
                                          return EditItemSheet(
                                            url: searchResult[index].data()["Url"],
                                            name: searchResult[index].data()["Name"],
                                            price: searchResult[index].data()["Price"],
                                            quantity: searchResult[index].data()["Stocks"],
                                            description: searchResult[index].data()["Description"],
                                            id: searchResult[index].id,
                                            category: searchResult[index].data()["Category"],
                                            mini: searchResult[index].data()["Minimum"],
                                          );
                                        });
                                      },
                                      icon: Icon(
                                        Icons.edit,
                                        color: AppColors().primaryColor,
                                      ),
                                    ),
                                   /* IconButton(
                                      onPressed: (){
                                        FirestoreService().removeItem(searchResult[index].id);
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                    ),*/
                                  ],
                                ),
                              )
                            ],
                          );
                        })
                    ) :
                    GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.8,
                        children: List.generate(myData.length, (index){
                          return Stack(
                            children: [
                              InkWell(
                                onTap: (){
                                  showModalBottomSheet(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                    ),
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) => ViewItemAdmin(
                                      name: myData[index].data()["Name"],
                                      price: myData[index].data()["Price"],
                                      stock: myData[index].data()["Stocks"],
                                      image:myData[index].data()["Url"],
                                      description: myData[index].data()["Description"],
                                      id: myData[index].id,
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Image.network(
                                            myData[index].data()["Url"],
                                            width: double.infinity,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  myData[index].data()["Name"],
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  "Stocks: ${myData[index].data()["Stocks"]}KG",
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: (){
                                        showMaterialModalBottomSheet(context: context, builder: (builder){
                                          return EditItemSheet(
                                            url:myData[index].data()["Url"],
                                            name: myData[index].data()["Name"],
                                            price: myData[index].data()["Price"],
                                            quantity: myData[index].data()["Stocks"],
                                            description: myData[index].data()["Description"],
                                            id: myData[index].id,
                                            category: myData[index].data()["Category"],
                                            mini:  myData[index].data()["Minimum"],

                                          );
                                        });
                                      },
                                      icon: Icon(
                                        Icons.edit,
                                        color:  AppColors().primaryColor,
                                      ),
                                    ),
                                   /* IconButton(
                                      onPressed: (){
                                        FirestoreService().removeItem(data.docs[index].id);
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                    ),*/
                                  ],
                                ),
                              )
                            ],
                          );
                        })
                    );
                  },
                  error: (error, stack){
                    return Center(
                      child: Text(
                        error.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                  loading: (){
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
              ),
            )
          ],
        ),
      ),
    );
  }
}
