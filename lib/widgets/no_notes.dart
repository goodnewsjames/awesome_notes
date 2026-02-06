import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NoNotes extends StatelessWidget {
  const NoNotes({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/person.png",
                width: MediaQuery.of(context).size.width * 0.75,
              ),
              SizedBox(height: 32),
              Text(
                "You have no notes yet\nStart creating by pressing the button below",
                style: GoogleFonts.fredoka(
                  fontSize: 18,
          
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
