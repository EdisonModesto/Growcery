import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewItemAdmin extends ConsumerStatefulWidget {
  const ViewItemAdmin({
    required this.name,
    required this.price,
    required this.description,
    required this.stock,
    required this.image,
    required this.id,
    Key? key,
  }) : super(key: key);

  final String name;
  final String price;
  final String description;
  final String stock;
  final String image;
  final String id;

  @override
  ConsumerState createState() => _ViewItemAdminState();
}

class _ViewItemAdminState extends ConsumerState<ViewItemAdmin> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 200,
                width: double.infinity,
                child: Image.network(
                  widget.image,
                  fit: BoxFit.fitWidth,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                "PHP ${widget.price}/Kilogram",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.lightGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Description",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Stocks: ${widget.stock}KG",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                widget.description,
                textAlign: TextAlign.justify,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
