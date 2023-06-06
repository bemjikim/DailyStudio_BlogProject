import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../login/login_page.dart';

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
        backgroundColor: Color(0xffFEF5ED),
        elevation: 1,
        title:  Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 50.0, 0.0),
            child: const Text(
              'Sign Up',
              style: TextStyle(
                  color: Color(0xFF72614E),
                  fontWeight: FontWeight.w600,
                  fontSize: 20),

            ),
          ),
        ),
        iconTheme: IconThemeData(
          color: Color(0xFF72614E),
          size: 26// 원하는 색상으로 변경하세요
        ),

      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'), // Replace 'assets/a.png' with the path to your image
            fit: BoxFit.cover,
          ),
        ),

        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              SizedBox(height: 20.0),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:  CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                    '   아이디*',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 16,)
                    ),
                    SizedBox(height: 5.0),
                    Row(
                      children: [
                        Expanded(
                          child:Container(
                            height:45,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color:Color(0xffEDE5DF),

                            ),
                            child: TextFormField(
                              onTapOutside: (event) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                              controller: _usernameController,
                              autofocus: true,
                              validator: (value) {
                                if (_usernameController.text.length == 0 || _uidinvalid == false) {
                                  return "아이디를 올바르게 입력해주세요.";
                                }
                                return null;
                              },

                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Colors.transparent,
                                labelText: '아이디를 입력해 주세요.',
                                labelStyle: TextStyle(
                                  color: Color(0xFFC0B8B1),
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20,),
                        ElevatedButton(
                          child: const Text(
                            '중복확인',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              fontSize: 16
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFFE6CCAD),
                            minimumSize: const Size(18, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // 버튼의 모서리를 둥글게 설정
                            ),
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
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                      ),
                                      backgroundColor: Color(0xFfF8ECE2),
                                      title: Text('Dailystudio',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 19,
                                          //color: Color(0xFF746553),
                                          color: Color(0xFF3C3731)

                                      ),),
                                      content: Text('이미 존재하는 아이디입니다.',
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
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                      ),
                                      backgroundColor: Color(0xFfF8ECE2),
                                      title: Text(' Dailystudio',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 19,
                                            //color: Color(0xFF746553),
                                            color: Color(0xFF3C3731)

                                        ),),
                                      content: Text('사용가능한 아이디입니다.',
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

                    SizedBox(height: 14.0),
                    Text(
                        '   닉네임*',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 16,)
                    ),
                    SizedBox(height: 5.0),
                    Container(
                      height:45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12), // 모서리를 둥글게 설정
                        color:Color(0xffEDE5DF),
                      ),
                      child: TextFormField(
                        onTapOutside: (event) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        controller: _nicknameController,
                        validator: (value) {
                          if (_nicknameController.text.length < 1) {
                            return "닉네임을 올바르게 입력해주세요.";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          labelText: '사용할 닉네임을 입력해 주세요.',
                          labelStyle: TextStyle(
                            color: Color(0xFFC0B8B1),
                          ),
                          border: InputBorder.none,
                        ),

                      ),
                    ),
                    SizedBox(height: 14.0),
                    Text(
                        '   비밀번호*',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 16,)
                    ),
                    SizedBox(height: 5.0),
                    Stack(
                      children: [
                        Container(
                          height: 45,
                          decoration:BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color:Color(0xffEDE5DF),
                          ),
                          child: TextFormField(
                            onTapOutside: (event) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            controller: _passwordController,
                            validator: (value) {
                              if (_passwordController.text.length < 1) {
                                return "비밀번호를 올바르게 입력해주세요.";
                              } else if (_passwordController.text !=
                                  _confirmpasswordController.text) {
                                return "비밀번호가 일치하지 않습니다.";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.transparent,
                              labelText: '비밀번호를 입력해 주세요.',
                              labelStyle: TextStyle(
                                color: Color(0xFFC0B8B1),
                              ),
                              border: InputBorder.none,
                            ),
                            obscureText: _passwordHide,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(310.0, 0.0, 0.0, 0.0),
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

                    SizedBox(height: 14.0),
                    Text(
                        '   비밀번호 확인*',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 16,)
                    ),
                    SizedBox(height: 5.0),
                    Stack(
                      children:[
                        Container(
                          height: 45,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color:Color(0xffEDE5DF),
                          ),
                          child: TextFormField(
                            onTapOutside: (event) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            controller: _confirmpasswordController,
                            validator: (value) {
                              if(_confirmpasswordController.text.length < 1) {
                                return "비밀번호를 올바르게 입력해주세요.";
                              }
                              else if(_passwordController.text != _confirmpasswordController.text) {
                                return "비밀번호가 일치하지 않습니다.";
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.transparent,
                              labelText: '비밀번호를 입력해 주세요.',
                              labelStyle: TextStyle(
                                color: Color(0xFFC0B8B1),
                              ),
                              border: InputBorder.none,
                            ),
                            obscureText: _passwordHide,
                          ),
                        ),
                      ]
                    ),

                    SizedBox(height: 14.0),
                    Text(
                        '   이메일*',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 16,)
                    ),
                    SizedBox(height: 5.0),
                    Container(
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius:BorderRadius.circular(12),
                        color:Color(0xffEDE5DF),
                      ),
                      child:TextFormField(
                        onTapOutside: (event) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        controller: _emailController,
                        validator: (value) {
                          if(_emailController.text.length < 1) {
                            return "이메일을 올바르게 입력해주세요.";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          labelText: '이메일을 입력해 주세요.',
                          labelStyle: TextStyle(
                            color: Color(0xFFC0B8B1),
                          ),
                          border: InputBorder.none,
                        ),
                        obscureText: false,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                        '   이메일이 없을 시, 계정을 찾기 힘들 수 있습니다.',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 14,)
                    ),
                    SizedBox(height: 76.0),
                    Row(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: ElevatedButton(
                            child: const Text(
                              '회원가입',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                fontSize: 18
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                                primary: Color(0xFFE6CCAD),
                                minimumSize: const Size(360, 45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12), // 버튼의 모서리를 둥글게 설정
                                ),
                            ),
                            onPressed: () {
                              if(_formKey.currentState!.validate()) {
                                _handleSubmitted(
                                    _usernameController.text,
                                    _nicknameController.text,
                                    _passwordController.text,
                                    _emailController.text);
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
      ),
    );
  }
}

