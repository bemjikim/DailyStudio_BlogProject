import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailystudio_blog_project/login/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../mainhome/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<bool> _handleSubmitted(
      String uid, String password) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('Userid', isEqualTo: uid)
        .where('Password', isEqualTo: password)
        .limit(1)
        .get();

    return querySnapshot.size == 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            const SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                Image.asset('assets/diamond.png'),
                const SizedBox(height: 16.0),
                const Text('SHRINE'),
              ],
            ),
            const SizedBox(height: 120.0),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                filled: true,
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                filled: true,
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            OverflowBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  child: const Text('Sign Up'),
                  style: TextButton.styleFrom(
                      primary: Colors.black
                  ),
                  onPressed: () {
                    Navigator.push( context, MaterialPageRoute(
                        builder: (context){
                          return SignUpPage();
                        }
                    ));
                  },
                ),
                ElevatedButton(
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                        color: Colors.black
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white60,
                      minimumSize: const Size(80, 34)
                  ),
                  onPressed: () async {
                    final uid = _usernameController.text;
                    final password = _passwordController.text;
                    var currentUserProvider = Provider.of<CurrentUserModel>(context, listen: false);
                    var name = CurrentUser(name: uid);
                    currentUserProvider.adduser(name);
                    final isMatched = await _handleSubmitted(uid, password);
                    if (isMatched) {
                      Navigator.push( context, MaterialPageRoute(
                          builder: (context){
                            return HomePage();
                          }
                      ));
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('알림'),
                            content: Text('아이디 혹은 비밀번호가 일치하지 않습니다.'),
                            actions: [
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  setState(() {
                                    _passwordController.clear();
                                    _usernameController.clear();
                                    Navigator.pop(context);
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
