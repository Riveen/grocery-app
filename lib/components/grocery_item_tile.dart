import 'dart:convert';

import 'package:flutter/material.dart';

class GroceryItemTile extends StatelessWidget {
  final String itemName;
  final String itemPrice;
  final String imagePath;
  final int color;
  final void Function()? onPressed;

  GroceryItemTile(
      {super.key,
      required this.itemName,
      required this.itemPrice,
      required this.imagePath,
      required this.color,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
            color: Color(color).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12)),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          // image
          imagePath.isEmpty
              ? Image.asset(
                  "lib/images/no-image.png",
                  height: 50,
                )
              : Image.memory(
                  base64Decode(imagePath),
                  height: 50,
                ),
          // item name
          Text(
            itemName,
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
          ),
          // button with price on it
          MaterialButton(
            onPressed: onPressed,
            color: Color(color),
            child: Text(
              "\$" + itemPrice,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ]),
      ),
    );
  }
}
