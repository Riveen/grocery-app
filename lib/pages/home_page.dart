import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_app/SQLite/sqlite.dart';
import 'package:grocery_app/components/grocery_item_tile.dart';
import 'package:grocery_app/models/cart_model.dart';
import 'package:provider/provider.dart';
import '../models/item_model.dart';
import 'cart_page.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<ItemModel>> items;
  late DatabaseHelper handler;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (context) {
          return CartPage();
        })),
        backgroundColor: Colors.black,
        child: const Icon(Icons.shopping_bag, color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 48.0),
          // good morning
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: SafeArea(
                child: Text(
              "Good Morning",
            )),
          ),

          const SizedBox(height: 4.0),
          // let's order fresh items for you
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text("Let's order fresh items for you",
                style: GoogleFonts.notoSerif(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                )),
          ),
          const SizedBox(
            height: 24.0,
          ),
          // divider
          const Divider(
            thickness: 4.0,
          ),
          const SizedBox(
            height: 24,
          ),
          // grid containing fresh items
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "Fresh Items",
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
              child: FutureBuilder<List<ItemModel>>(
                  future: items,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<ItemModel>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                      return const Center(child: Text("No data"));
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    } else {
                      final items = snapshot.data ?? <ItemModel>[];
                      return GridView.builder(
                          itemCount: items.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, childAspectRatio: 1 / 1.2),
                          itemBuilder: (context, index) {
                            return GroceryItemTile(
                              itemName: items[index].itemTitle.toString(),
                              itemPrice: items[index].itemPrice,
                              imagePath: items[index].itemImage.toString(),
                              color: items[index].colorValue!,
                              onPressed: () =>
                                  Provider.of<CartModel>(context, listen: false)
                                      .addItemToCart(index),
                            );
                          });
                    }
                  }))
        ],
      ),
    );
  }
}
