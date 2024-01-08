import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:grocery_app/SQLite/sqlite.dart';
import 'package:grocery_app/models/item_model.dart';
import 'package:image_picker/image_picker.dart';

class CreateItem extends StatefulWidget {
  const CreateItem({super.key});

  @override
  State<CreateItem> createState() => _CreateItemState();
}

class _CreateItemState extends State<CreateItem> {
  final title = TextEditingController();
  final price = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? imageString = "";
  File? _image;
  final picker = ImagePicker();
  int colorValue = 0;
  final db = DatabaseHelper();

  Future getImageFromGallery() async {
    var maxFileSizeInBytes = 2 * 1048576;
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 6);

    var imagePath = await pickedFile!.readAsBytes();

    var fileSize = imagePath.length; // Get the file size in bytes

    if (fileSize <= maxFileSizeInBytes) {
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }

      List<int> imageBytes = File(pickedFile!.path).readAsBytesSync();
      imageString = base64Encode(imageBytes);
      print(imageString);
    } else {
      showFlashError(context,
          " File is too large, please try uploading again!"); // File is too large, ask user to upload a smaller file, or compress the file
      print("File too large!");
    }
  }

  // create some values
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

// ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
    colorValue = pickerColor.value;
    print("color: $colorValue");
  }

  Future showPicker() {
    // raise the [showDialog] widget
    return showDialog(
      builder: (context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          // child: ColorPicker(
          //   pickerColor: pickerColor,
          //   onColorChanged: changeColor,
          // ),
          // Use Material color picker:
          //
          // child: MaterialPicker(
          //   pickerColor: pickerColor,
          //   onColorChanged: changeColor,
          // ),
          //
          // Use Block color picker:
          //
          child: BlockPicker(
            pickerColor: currentColor,
            onColorChanged: changeColor,
          ),
          //
          // child: MultipleChoiceBlockPicker(
          //   pickerColors: currentColor,
          //   onColorsChanged: changeColors,
          // ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const Text('Got it'),
            onPressed: () {
              setState(() => currentColor = pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      context: context,
    );
  }

  void showFlashError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Item"),
        actions: [
          IconButton(
              onPressed: () {
                // add item check button
                // validate to not allow empty values
                if (formKey.currentState!.validate()) {
                  db
                      .createItem(ItemModel(
                          itemTitle: title.text,
                          itemPrice: price.text,
                          itemImage: imageString.toString(),
                          colorValue: colorValue))
                      .whenComplete(() {
                    Navigator.of(context).pop(true);
                  });
                }
                // print(title.text);
                // print(price.text);
                // print(imageString.toString());
                // print(colorValue);
              },
              icon: const Icon(Icons.check))
        ],
      ),
      body: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: title,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Item name is required";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      label: Text("Name"),
                    ),
                  ),
                  TextFormField(
                    controller: price,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Item price is required";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      label: Text("Price"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: MaterialButton(
                      color: Colors.grey,
                      child: const Text(
                        "Pick an image",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      onPressed: () {
                        getImageFromGallery();
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => showPicker(),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text(
                      "Pick Color",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }
}
