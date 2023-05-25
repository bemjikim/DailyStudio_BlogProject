import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordHide = true;
  bool _isUserIdExists = false;
  bool _uidinvalid = false;
  Future<void> _handleSubmitted(
      String uid, String nickname, String password, String email) async {
    setState(() {
      FocusScope.of(context).unfocus();
    });

      await FirebaseFirestore.instance
          .collection('user')
          .doc(uid)
          .set({
        'Userid': uid,
        'Nickname': nickname,
        'Password': password,
        'Email': email,
      }).then((onValue) {
        //정보 인서트후, 상위페이지로 이동
        Navigator.pop(context);
      });
    }

  Future<bool> _checkuserid(String uid) async{
    setState(() {
      FocusScope.of(context).unfocus();
    });
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('Userid', isEqualTo: uid)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title:  Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 50.0, 0.0),
            child: const Text(
              'Sign Up',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),

      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 42.0),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          onTapOutside: (event) =>
                              FocusManager.instance.primaryFocus?.unfocus(),
                          controller: _usernameController,
                          autofocus: true,
                          validator: (value) {
                            if (_usernameController.text.length == 0 || _uidinvalid == false) {
                              return "Username is invalid";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            filled: true,
                            labelText: 'UserName',
                          ),
                        ),
                      ),
                      SizedBox(width: 20,),
                      ElevatedButton(
                        child: const Text(
                          '중복확인',
                          style: TextStyle(
                              color: Colors.black
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white60,
                          minimumSize: const Size(20, 60),
                        ),
                        onPressed: () async{
                          if(_usernameController.text.length > 0)
                          {
                            _isUserIdExists = await _checkuserid(_usernameController.text);
                            if (_isUserIdExists) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('ID already exists'),
                                    content: Text('Please choose a different ID.'),
                                    actions: [
                                      TextButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                            else
                            {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('사용가능!'),
                                    content: Text('아이디를 사용가능합니다!'),
                                    actions: [
                                      TextButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          setState(() {
                                            _uidinvalid = true;
                                          });
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 12.0),
                  TextFormField(
                    onTapOutside: (event) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    controller: _nicknameController,
                    validator: (value) {
                      if (_nicknameController.text.length < 1) {
                        return "Please enter the Nickname";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'NickName',
                    ),
                  ),

                  SizedBox(height: 12.0),
                  Stack(
                    children: [
                      TextFormField(
                        onTapOutside: (event) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        controller: _passwordController,
                        validator: (value) {
                          if (_passwordController.text.length < 1) {
                            return "Please enter the Password";
                          } else if (_passwordController.text !=
                              _confirmpasswordController.text) {
                            return "Confirm Password doesn't match Password";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          filled: true,
                          labelText: 'Password',
                        ),
                        obscureText: _passwordHide,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(310.0, 5.0, 0.0, 0.0),
                        child: IconButton(
                          onPressed: () async{
                            setState(() {
                              _passwordHide = !_passwordHide;
                            });
                          },
                          icon: Icon(Icons.remove_red_eye),
                        ),
                      ),
                    ]
                  ),

                  SizedBox(height: 12.0),
                  Stack(
                    children:[
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
                        obscureText: _passwordHide,
                      ),
                    ]
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
                  Row(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          child: const Text(
                            'SIGN UP',
                            style: TextStyle(
                                color: Colors.black
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.white60,
                              minimumSize: const Size(360, 38),
                          ),
                          onPressed: () {
                            if(_formKey.currentState!.validate()) {
                              _handleSubmitted(_usernameController.text, _nicknameController.text, _passwordController.text, _emailController.text);
                              Navigator.pop(context);
                            }
                            else{
                              setState(() {
                                _uidinvalid = false;
                              });
                            }

                          },
                        ),
                      ),

                    ],
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

