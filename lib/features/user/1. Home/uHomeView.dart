import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:growcery/features/ViewModels/UserViewModel.dart';

import '../../../common/ViewItemSheet.dart';
import '../../../constants/AppColors.dart';
import '../../ViewModels/ItemViewModel.dart';
import '../../ViewModels/allUserViewModel.dart';

class UHomeView extends ConsumerStatefulWidget {
  const UHomeView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _UHomeViewState();
}

class _UHomeViewState extends ConsumerState<UHomeView> {

  TextEditingController searchController = TextEditingController();

  var popUpItems = [
    PopupMenuItem(
      value: "All",
      child: Text(
        "All",
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
    PopupMenuItem(
      value: "Leafy Green",
      child: Text(
        "Leafy Green",
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
    PopupMenuItem(
      value: "Allium",
      child: Text(
        "Allium",
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
    PopupMenuItem(
      value: "Marrow",
      child: Text(
        "Marrow",
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
  ];

  var value = "All";

  @override
  Widget build(BuildContext context) {

    var feed = ref.watch(itemProvider);
    var users = ref.watch(allUserProvider);

    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Discover New Stocks",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: TextField(
                  controller: searchController,
                  onChanged: (value){
                    setState(() {

                    });
                  },
                  decoration: InputDecoration(
                    contentPadding:  const EdgeInsets.symmetric(horizontal: 10),
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
              const SizedBox(height: 5),
              TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors().primaryColor,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 2,
                labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors().primaryColor,
                ),
                isScrollable: true,
                tabs: [
                  Tab(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Farms",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Product",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Categories",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
/*            Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton(
                    icon: Icon(
                      Icons.filter_list,
                      color: AppColors().primaryColor,
                    ),
                    onSelected: (val){
                      searchController.text = val.toString();
                      setState(() {});
                    },
                    itemBuilder: (context) => popUpItems,
                  ),
                ],
              ),*/
              const SizedBox(height: 5),
              Expanded(
                child: TabBarView(
                  children: [
                    users.when(
                      data: (data){
                        var sellers = data.docs.where((element) => element.data()["userType"] == "Seller").toList();
                        return ListView.builder(
                          itemCount: sellers.length,
                          itemBuilder: (context, index){
                            return ListTile(
                              onTap: (){
                                context.pushNamed("sellerStore", params: {"sellerID": sellers[index].id});
                              },
                              title: Text(
                                sellers[index].data()["Name"],
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sellers[index].data()["Address"].toString().replaceAll("%", ", "),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  StreamBuilder(
                                    stream: FirebaseFirestore.instance.collection("Items").where("SellerID", isEqualTo: sellers[index].id).snapshots(),
                                    builder: (context, snapshot) {
                                      if(snapshot.hasData){
                                        return Text(
                                          "Total Items: ${snapshot.data!.docs.length}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        );
                                      }
                                      return SizedBox();
                                    }
                                  ),
                                  StreamBuilder(
                                    stream: FirebaseFirestore.instance.collection("Users").doc(sellers[index].id).collection("Ratings").snapshots(),
                                    builder: (context, snapshot) {
                                      if(snapshot.hasData){
                                        double totalRating = 0;

                                        snapshot.data!.docs.forEach((element) {
                                          totalRating += element.data()["Rating"];
                                        });

                                        totalRating = totalRating == 0 ? 0.0 : totalRating / snapshot.data!.docs.length;
                                        return RatingBar.builder(
                                          initialRating: totalRating,
                                          minRating: 0,
                                          direction: Axis.horizontal,
                                          ignoreGestures: true,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemPadding: const EdgeInsets.symmetric(horizontal:0),
                                          itemSize: 25,
                                          itemBuilder: (context, _) => const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          onRatingUpdate: (rating) {
                                            print(rating);
                                          },
                                        );
                                      }
                                      return SizedBox();
                                    }
                                  ),
                                ],
                              ),
                              trailing: Text(
                                ">",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      error: (error, stackTrace){
                        return Center(
                          child: Text(
                            error.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      },
                      loading: (){
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors().primaryColor,
                          ),
                        );
                      },
                    ),
                    feed.when(
                      data: (data){
                        var searchResult = data.docs.where((element) => element.data()["Name"].toString().toLowerCase().contains(searchController.text.toLowerCase()) && int.parse(element.data()['Stocks']) > 0).toList();

                        if (searchController.text == "Leafy Green") {
                          searchResult = data.docs.where((element) => element.data()["Category"].toString().toLowerCase().contains(searchController.text.toLowerCase()) && int.parse(element.data()['Stocks']) > 0).toList();
                        } else if (searchController.text == "Allium"){
                          searchResult = data.docs.where((element) => element.data()["Category"].toString().toLowerCase().contains(searchController.text.toLowerCase()) && int.parse(element.data()['Stocks']) > 0).toList();
                        } else if (searchController.text == "Marrow"){
                          searchResult = data.docs.where((element) => element.data()["Category"].toString().toLowerCase().contains(searchController.text.toLowerCase()) && int.parse(element.data()['Stocks']) > 0).toList();
                        } else if(searchController.text == "All"){
                          searchResult = data.docs.where((element) => int.parse(element.data()['Stocks']) > 0).toList();
                        } else {
                          searchResult = data.docs.where((element) => element.data()["Name"].toString().toLowerCase().contains(searchController.text.toLowerCase()) && int.parse(element.data()['Stocks']) > 0).toList();
                        }

                        //var withStocks = data.docs.where((element) => int.parse(element.data()['Stocks']) > 0).toList();
                        return searchController.text != "" ?
                        GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.8,
                            children: List.generate(searchResult.length, (index){
                              return InkWell(
                                onTap: (){
                                  showModalBottomSheet(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                    ),
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) => ViewItemSheet(
                                      name: searchResult[index].data()['Name'],
                                      price: searchResult[index].data()['Price'],
                                      description: searchResult[index].data()['Description'],
                                      stock: searchResult[index].data()['Stocks'],
                                      image: searchResult[index].data()['Url'],
                                      id: searchResult[index].id,
                                      min: searchResult[index].data()['Minimum'],
                                      sellerID: searchResult[index].data()['SellerID'],
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
                                            searchResult[index].data()['Url'],
                                            width: double.infinity,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            color: AppColors().primaryColor,
                                            child: Padding(
                                              padding: const EdgeInsets.all(20.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    searchResult[index].data()['Name'],
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    "PHP ${searchResult[index].data()['Price']}/KG",
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            })
                        ) :
                        GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.8,
                            children: List.generate(data.docs.length, (index){
                              return int.parse(data.docs[index].data()["Stocks"]) > 0 ? InkWell(
                                onTap: (){
                                  showModalBottomSheet(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                    ),
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) => ViewItemSheet(
                                      name: data.docs[index].data()['Name'],
                                      price: data.docs[index].data()['Price'],
                                      description: data.docs[index].data()['Description'],
                                      stock: data.docs[index].data()['Stocks'],
                                      image: data.docs[index].data()['Url'],
                                      id: data.docs[index].id,
                                      min: data.docs[index].data()['Minimum'],
                                      sellerID: data.docs[index].data()['SellerID'],
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
                                            data.docs[index].data()['Url'],
                                            width: double.infinity,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            color: AppColors().primaryColor,
                                            width: double.infinity,
                                            child: Padding(
                                              padding: const EdgeInsets.all(20.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    data.docs[index].data()['Name'],
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    "PHP ${data.docs[index].data()['Price']}/KG",
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ) : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Stack(
                                  children: [
                                    Container(
                                      color: Colors.grey[200],
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Image.network(
                                              data.docs[index].data()['Url'],
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
                                                    data.docs[index].data()['Name'],
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    "PHP ${data.docs[index].data()['Price']}/KG",
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
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.height,
                                      color: Colors.grey.withOpacity(0.8),
                                      child: Center(
                                        child: Text(
                                          "Out of Stock",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      },
                      loading: (){
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                    feed.when(
                      data: (data){

                        var vegies = data.docs.where((element) => element.data()['Category'] == "Vegetables").toList();
                        var frutis = data.docs.where((element) => element.data()['Category'] == "Fruits").toList();
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              ExpansionTile(
                                title: Text(
                                  "Vegetables (${vegies.length})",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                children: List.generate(vegies.length, (index) => ListTile(
                                  onTap: (){
                                    showModalBottomSheet(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(12),
                                        ),
                                      ),
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) => ViewItemSheet(
                                        name: vegies[index].data()['Name'],
                                        price: vegies[index].data()['Price'],
                                        description: vegies[index].data()['Description'],
                                        stock: vegies[index].data()['Stocks'],
                                        image: vegies[index].data()['Url'],
                                        id: vegies[index].id,
                                        min: vegies[index].data()['Minimum'],
                                        sellerID: vegies[index].data()['SellerID'],
                                      ),
                                    );
                                  },
                                  leading: Image.network(
                                    vegies[index].data()['Url'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                  title: Text(
                                    vegies[index].data()['Name'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Stocks: ${vegies[index].data()['Stocks'].toString()}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),

                                  trailing: Text(
                                    "PHP ${vegies[index].data()['Price']}/KG",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ))
                              ),
                              ExpansionTile(
                                title: Text(
                                  "Fruits (${frutis.length})",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                  children: List.generate(frutis.length, (index) => ListTile(
                                    onTap: (){
                                      showModalBottomSheet(
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                        ),
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) => ViewItemSheet(
                                          name: frutis[index].data()['Name'],
                                          price: frutis[index].data()['Price'],
                                          description: frutis[index].data()['Description'],
                                          stock: frutis[index].data()['Stocks'],
                                          image: frutis[index].data()['Url'],
                                          id: frutis[index].id,
                                          min: frutis[index].data()['Minimum'],
                                          sellerID: frutis[index].data()['SellerID'],
                                        ),
                                      );
                                    },
                                    leading: Image.network(
                                      frutis[index].data()['Url'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                    title: Text(
                                      frutis[index].data()['Name'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "Stocks: ${frutis[index].data()['Stocks'].toString()}",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),

                                    trailing: Text(
                                      "PHP ${frutis[index].data()['Price']}/KG",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ))

                              )
                            ],
                          ),
                        );
                      },
                      error: (error, stack){
                        return Center(
                          child: Text(
                            error.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        );
                      },
                      loading: (){
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
