import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:grocery_app/SQLite/sqlite.dart';
import 'package:grocery_app/models/item_model.dart';
import 'package:grocery_app/pages/create_item.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';

class Items extends StatefulWidget {
  const Items({super.key});

  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  late DatabaseHelper handler;
  late Future<List<ItemModel>> items;
  final db = DatabaseHelper();
  final title = TextEditingController();
  final price = TextEditingController();
  String? imageString = "";
  File? _image;
  final picker = ImagePicker();
  int colorValue = 0;

  Future getImageFromGallery() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 6);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }

    List<int> imageBytes = File(pickedFile!.path).readAsBytesSync();
    imageString = base64Encode(imageBytes);
    print(imageString);
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
          child: BlockPicker(
            pickerColor: currentColor,
            onColorChanged: changeColor,
          ),
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

  @override
  void initState() {
    handler = DatabaseHelper();
    items = handler.getItems();

    handler.initDB().whenComplete(() {
      items = getAllItems();
    });
    super.initState();
  }

  Future<List<ItemModel>> getAllItems() {
    return handler.getItems();
  }

  // reload method
  Future<void> _refresh() async {
    setState(() {
      items = getAllItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Grocery Items"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //db.deleteAll();
          // calls the refresh method after new item has been added
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CreateItem()))
              .then((value) {
            if (value) {
              _refresh();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
      //show items
      body: FutureBuilder<List<ItemModel>>(
        future: items,
        builder:
            (BuildContext context, AsyncSnapshot<List<ItemModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text("No data"));
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            final items = snapshot.data ?? <ItemModel>[];
            return ListView.builder(
                padding: const EdgeInsets.all(12.0),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color:
                              Color(items[index].colorValue!).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: items[index].itemImage.isEmpty
                            ? Image.asset(
                                "lib/images/no-image.png",
                                height: 46,
                              )
                            : Image.memory(
                                base64Decode(items[index].itemImage),
                                height: 46,
                              ),
                        subtitle: Text(
                          "\$" + items[index].itemPrice,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        title: Text(
                          items[index].itemTitle,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                            onPressed: () {
                              db
                                  .deleteItems(items[index].itemId!)
                                  .whenComplete(() {
                                // when successfuly deleted, call refresh
                                _refresh();
                              });
                            },
                            icon: const Icon(Icons.delete)),
                        // onTap method for update
                        onTap: () {
                          // when clicked retreive already available info for the item
                          setState(() {
                            title.text = items[index].itemTitle;
                            price.text = items[index].itemPrice;
                            colorValue = items[index].colorValue!;
                            imageString = items[index].itemImage;
                          });
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  actions: [
                                    Row(
                                      children: [
                                        TextButton(
                                            onPressed: () {
                                              // save button method
                                              db
                                                  .updateItems(
                                                      title.text,
                                                      price.text,
                                                      imageString.toString(),
                                                      colorValue,
                                                      items[index].itemId)
                                                  .whenComplete(() {
                                                // refresh the items view and pop the current view
                                                _refresh();
                                                Navigator.pop(context);
                                              });
                                            },
                                            child: const Text("Save")),
                                        TextButton(
                                            onPressed: () {
                                              //Navigator.of(context).pop(true);
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Cancel"))
                                      ],
                                    )
                                  ],
                                  title: const Text("Modify Item"),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // render form here also
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
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue),
                                          child: const Text(
                                            "Pick Color",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                      ),
                    ),
                  );
                });
          }
        },
      ),
    );
  }
}
