import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../common/ViewItemSheet.dart';
import '../../../constants/AppColors.dart';
import '../../ViewModels/ItemViewModel.dart';

class UHomeView extends ConsumerStatefulWidget {
  const UHomeView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _UHomeViewState();
}

class _UHomeViewState extends ConsumerState<UHomeView> {

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    var feed = ref.watch(itemProvider);

    return SafeArea(
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
              height: 60,
              child: TextField(
                controller: searchController,
                onChanged: (value){
                  setState(() {

                  });
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
                  var searchResult = data.docs.where((element) => element.data()["Name"].toString().toLowerCase().contains(searchController.text.toLowerCase()) && int.parse(element.data()['Stocks']) > 0).toList();

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
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "PHP ${searchResult[index].data()['Price']}",
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
                                            "PHP ${data.docs[index].data()['Price']}",
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
                                              "PHP ${data.docs[index].data()['Price']}",
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
                                    "Sold Out",
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
            )
          ],
        ),
      ),
    );
  }
}
