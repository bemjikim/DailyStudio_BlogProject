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
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/login.png'),
              fit:BoxFit.cover,
            ),
          ),




          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: <Widget>[


                const SizedBox(height: 450.0),
                Container(
                  height: 54,
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: 'Username',
                      labelStyle: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                      ),
                      fillColor: Color(0xFFF4EBE4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,// Set the desired circular radius here
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6.0),
                Container(
                  height: 54,
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      filled: true,
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                      ),
                      fillColor: Color(0xFFF4EBE4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,// Set the desired circular radius here
                      ),
                    ),
                    obscureText: true,
                  ),
                ),

                SizedBox(height: 18),
                ElevatedButton(
                  child: const Text(
                    '로그인',
                    style: TextStyle(
                        color: Color(0xFF60544B),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary:  Color(0xFFE3CFB8),
                      minimumSize: const Size(360, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // Set the desired border radius here
                      ),

                  ),
                  onPressed: () async {
                    final uid = _usernameController.text;
                    final password = _passwordController.text;
                    final isMatched = await _handleSubmitted(uid, password);
                    if (isMatched) {
                      var currentUserProvider = Provider.of<CurrentUserModel>(context, listen: false);
                      var name = CurrentUser(name: uid);
                      currentUserProvider.adduser(name);
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            backgroundColor: Color(0xFfF8ECE2),
                            title: Text('알림',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 19,
                                  //color: Color(0xFF746553),
                                  color: Color(0xFF3C3731)

                              ),),
                            content: Text('아이디 혹은 비밀번호가 잘못 입력된 것 같아요. 다시 입력해 주세요!',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B5F51),
                                  fontSize: 17

                              ),),
                            actions: [
                              TextButton(
                                child: Text('OK',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF746553),
                                        fontSize: 16

                                    ),),
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('계정이 없으신가요?   '),
                    TextButton(
                      child: const Text('회원가입',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, // Set the desired font weight here
                        ),
                      ),
                      style: TextButton.styleFrom(
                          primary: Color(0xFFED9B21),
                      ),
                      onPressed: () {
                        Navigator.push( context, MaterialPageRoute(
                            builder: (context){
                              return SignUpPage();
                            }
                        ));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
