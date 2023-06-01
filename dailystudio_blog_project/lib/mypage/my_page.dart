import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../archive/archive_main.dart';
import '../favorite/favorite.dart';
import '../main.dart';
import '../mainhome/home.dart';


bool isLoading = true;
int i = 0;
class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  int _selectedIndex = 3;
  var data;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if(_selectedIndex == 2)
      {
        Navigator.push( context, MaterialPageRoute(
            builder: (context){
              return ArchiveMain();
            }
        ));
      }
      if(_selectedIndex == 1)
      {
        Navigator.push( context, MaterialPageRoute(
            builder: (context){
              return FavoritePage();
            }
        ));
      }
      if (_selectedIndex == 0) {
        Navigator.push( context, MaterialPageRoute(
            builder: (context){
              return HomePage();
            }
        ));
      }
      _selectedIndex = 3;
    });
  }
  @override
  void initState() {
    super.initState();
  }

  Future<void>_getdata(String cn) async {
    if(i == 0) {
      final post = await FirebaseFirestore.instance
          .collection('user')
          .doc(cn)
          .get();
      setState(() {
        isLoading = false;
      });
      if (post.exists) {
        data = post.data(); // post 컬렉션의 필드값을 가져옵니다
        isLoading = false;
        // 가져온 필드 값을 사용하여 원하는 작업 수행
      }
    }
    i++;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserProvider = Provider.of<CurrentUserModel>(context);
    final currentUsers = currentUserProvider.currentUsers;
    var cn = currentUsers.isNotEmpty ? currentUsers[0] : null;
    _getdata(cn!.name);
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.grey,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_sharp,
                semanticLabel: 'proile',
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 55.0, 0.0),
                child: Text(
                  "계정",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ),
            actions: <Widget>[
            ],
          ),
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : Container(
            child: Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  SizedBox(height: 40,),
                  Text(
                    "[User id]",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 20,
                    ),
                  ),
                  Container(
                    child: Text(
                      data['Userid'],
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                      width: 252,
                      child: Divider(thickness: 1, height: 1, color: Colors.white)
                  ),
                  SizedBox(height: 25,),
                  Text(
                    "[NickName]",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 20,
                    ),
                  ),
                  Container(
                    child: Text(
                      data['Nickname'],
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                  SizedBox(height: 25,),
                  Text(
                    "[Email]",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 20,
                    ),
                  ),
                  Container(
                    child: Text(
                      data['Email'],
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}