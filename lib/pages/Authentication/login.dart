import 'package:flutter/material.dart';
import 'package:grocery_app/SQLite/sqlite.dart';
import 'package:grocery_app/models/users.dart';
import 'package:grocery_app/pages/Authentication/signup.dart';
import 'package:grocery_app/pages/home_page.dart';
import 'package:grocery_app/pages/items.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // text editing controllers
  final username = TextEditingController();
  final password = TextEditingController();

  // a variable to control the visibilty of the password
  bool isVisible = false;

  // global key for the form
  final formKey = GlobalKey<FormState>();

  // error msg
  String errorMsg = "This field is required.";

  // db
  final db = DatabaseHelper();

  // login variable to check if login is true
  bool isLoginTrue = false;

  // admin credentials for test purposes
  String defaultCredentials = "admin";

  // login method
  login() async {
    var response = await db
        .login(Users(usrName: username.text, usrPassword: password.text));
    if (response == true) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else if (username.text == defaultCredentials &&
        password.text == defaultCredentials) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Items()),
      );
    } else {
      // set isLoginTrue to true to show the error msg
      setState(() {
        isLoginTrue = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            // form
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Image.asset(
                    "lib/images/grocery.png",
                    width: 250,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  //  username field
                  Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.green.withOpacity(0.2),
                    ),
                    child: TextFormField(
                      controller: username,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return errorMsg;
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        border: InputBorder.none,
                        label: Text("Username"),
                      ),
                    ),
                  ),

                  // password field
                  Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.green.withOpacity(0.2),
                    ),
                    child: TextFormField(
                      controller: password,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return errorMsg;
                        }
                        return null;
                      },
                      obscureText: !isVisible,
                      decoration: InputDecoration(
                          icon: const Icon(Icons.lock),
                          border: InputBorder.none,
                          label: const Text("Password"),
                          suffixIcon: IconButton(
                              onPressed: () {
                                // a toggle button to hide anf show password
                                setState(() {
                                  // for toggle
                                  isVisible = !isVisible;
                                });
                              },
                              icon: Icon(isVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off))),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  // login button
                  Container(
                    height: 58,
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9.0),
                        color: const Color.fromARGB(255, 5, 82, 95)),
                    child: TextButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          // login method
                          login();
                        }
                      },
                      child: const Text(
                        "LOGIN",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  // sign up button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          // navigate to sign up screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpScreen()),
                          );
                        },
                        child: const Text(
                          "SIGN UP",
                          style: TextStyle(
                            color: Color.fromARGB(255, 15, 85, 97),
                          ),
                        ),
                      ),
                    ],
                  ),

                  isLoginTrue
                      ? const Text(
                          "Username or Password is incorrect!",
                          style: TextStyle(color: Colors.red),
                        )
                      : const SizedBox()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
