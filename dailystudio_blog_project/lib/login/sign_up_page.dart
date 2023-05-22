import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[

            SizedBox(height: 42.0),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    onTapOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    controller: _usernameController,
                    autofocus: true,
                    validator: (_usernameController) {
                      String number = _usernameController!.replaceAll(RegExp('[^0-9]'), "");
                      String character = _usernameController!.replaceAll(RegExp('[^a-zA-z]'), "");

                      if((character.length < 3) || (number.length < 3))
                      {
                        return "Username is invalid";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'UserName',
                    ),
                    obscureText: false,
                  ),
                  SizedBox(height: 12.0),
                  TextFormField(
                    onTapOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    controller: _passwordController,
                    validator: (value) {
                      if (_passwordController.text.length < 1) {
                        return "Please enter the Password";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'Password',
                    ),
                    obscureText: true,
                  ),

                  SizedBox(height: 12.0),
                  TextFormField(
                    onTapOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    controller: _confirmpasswordController,
                    validator: (value) {
                      if(_confirmpasswordController.text.length < 1) {
                        return "Please enter the Confirm Password";
                      }
                      else if(_passwordController.text != _confirmpasswordController.text) {
                        return "Confirm Password doesn't match Password";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'Confirm Password',
                    ),
                    obscureText: true,
                  ),

                  SizedBox(height: 12.0),
                  TextFormField(
                    onTapOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    controller: _emailController,
                    validator: (value) {
                      if(_emailController.text.length < 1) {
                        return "Please enter Email Address";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'Email Address',
                    ),
                    obscureText: false,
                  ),

                  SizedBox(height: 12.0),
                  Container(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      child: const Text(
                        'SIGN UP',
                        style: TextStyle(
                            color: Colors.black
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.white60,
                          minimumSize: const Size(100, 34)
                      ),
                      onPressed: () {
                        if(_formKey.currentState!.validate()) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

      ),
    );
  }
}
