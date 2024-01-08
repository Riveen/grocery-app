import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:grocery_app/models/cart_model.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class CartPage extends StatelessWidget {
  Map<String, dynamic>? paymentIntent;

  Future<bool> makePayment(
      {required String amount, required BuildContext context}) async {
    try {
      paymentIntent = await createPaymentIntent(amount);

      var gPay = const PaymentSheetGooglePay(
        merchantCountryCode: "US",
        currencyCode: "USD",
        testEnv: true,
      );
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntent!["client_secret"],
        style: ThemeMode.dark,
        merchantDisplayName: "Riveen",
        googlePay: gPay,
      ));

      if (await displayPaymentSheet(context)) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
      print(e.toString());
    }
  }

  Future<bool> displayPaymentSheet(BuildContext context) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Payment Sucessfull")));
      return true;
      print("done.");
    } catch (e) {
      return false;
      print("failed.");
    }
  }

  createPaymentIntent(String amount) async {
    try {
      Map<String, dynamic> body = {"amount": amount, "currency": "USD"};

      http.Response response = await http.post(
          Uri.parse("https://api.stripe.com/v1/payment_intents"),
          body: body,
          headers: {
            "Authorization": "Bearer sk_test_4eC39HqLyjWDarjtT1zdp7dc",
            "Content-Type": "application/x-www-form-urlencoded",
          });

      final jsonResponse = json.decode(response.body);
      print(json.decode(response.body).toString());
      return jsonResponse;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Stripe.publishableKey = "pk_test_TYooMQauvdEDq54NiTphI7jx";
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<CartModel>(
        builder: (context, value, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text("My Cart",
                    style: GoogleFonts.notoSerif(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: value.cartItems.length,
                  itemBuilder: ((context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Image.asset(
                            value.cartItems[index][2],
                            height: 46,
                          ),
                          title: Text(value.cartItems[index][0]),
                          subtitle: Text("\$" + value.cartItems[index][1]),
                          trailing: IconButton(
                              onPressed: () =>
                                  Provider.of<CartModel>(context, listen: false)
                                      .removeItemFromCart(index),
                              icon: const Icon(Icons.cancel)),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              value.cartItems.length > 0
                  ?
                  // total & pay now
                  Padding(
                      padding: const EdgeInsets.all(36.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8.0)),
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total Price",
                                  style: TextStyle(color: Colors.green[100]),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  "\$" + value.calculateTotal().toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            // Pay now button
                            Container(
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.green.shade100),
                                  borderRadius: BorderRadius.circular(12.0)),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  const Text(
                                    "Pay Now",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward_ios),
                                    iconSize: 16.0,
                                    color: Colors.white,
                                    onPressed: () async {
                                      bool paid = await makePayment(
                                          amount: (value.calculateTotal() * 100)
                                              .toString(),
                                          context: context);
                                      if (paid) {
                                        value.clearCart();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8.0)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 18.0, horizontal: 30.0),
                        child: Text(
                          "No cart is available at the moment!",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}
