// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoItem extends StatelessWidget {
  const InfoItem({
    Key? key,
    required this.title,
    required this.description,
    this.child,
    this.isDarkStyle = false,
    this.onTap,
  }) : super(key: key);

  final String title;

  final String description;

  final Widget? child;

  final bool isDarkStyle;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 16.0, right: 16.0),
        child: Card(
          color: isDarkStyle ? Theme.of(context).primaryColor : null,
          child: InkWell(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.robotoMono(
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      description,
                      style: isDarkStyle
                          ? Theme.of(context).textTheme.bodyText1!.copyWith(
                                color: Colors.white,
                              )
                          : null,
                    ),
                  ),
                  if (child != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: child!,
                    ),
                ],
              ),
            ),
            onTap: onTap,
          ),
        ));
  }
}
