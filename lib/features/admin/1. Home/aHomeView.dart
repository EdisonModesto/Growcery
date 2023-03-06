import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:growcery/services/FirestoreService.dart';

import '../../../common/ViewItemSheet.dart';
import '../../../constants/AppColors.dart';
import '../../ViewModels/ItemViewModel.dart';
import 'addItemSheet.dart';

class AHomeView extends ConsumerStatefulWidget {
  const AHomeView({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _AHomeViewState();
}

class _AHomeViewState extends ConsumerState<AHomeView> {
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
                    return GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.8,
                        children: List.generate(data.docs.length, (index){
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
                                    builder: (context) => ViewItemSheet(
                                      name: data.docs[index].data()["Name"],
                                      price: data.docs[index].data()["Price"],
                                      stock: data.docs[index].data()["Stocks"],
                                      image: data.docs[index].data()["Url"],
                                      description: "description",
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
                                            data.docs[index].data()["Url"],
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
                                                  data.docs[index].data()["Name"],
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  "Stocks: ${data.docs[index].data()["Stocks"]}",
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
                                child: IconButton(
                                  onPressed: (){
                                    FirestoreService().removeItem(data.docs[index].id);
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
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
