import 'package:awesome_notes/core/constants.dart';
import 'package:flutter/material.dart';

class DialogCard extends StatelessWidget {
  const DialogCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          margin: MediaQuery.viewInsetsOf(context),
          decoration: BoxDecoration(
            color: white,
            border: Border.all(color: black, width: 2),
            boxShadow: [BoxShadow(offset: Offset(4, 4))],
            borderRadius: BorderRadius.circular(12),
          ),
          width: MediaQuery.of(context).size.width * 0.75,
          padding: const EdgeInsets.all(24.0),
          child: child,
        ),
      ),
    );
  }
}
