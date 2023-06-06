import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../archive/archive_main.dart';
import '../favorite/favorite.dart';
import '../main.dart';
import '../mainhome/home.dart';



class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  int _selectedIndex = 3;
  var data;
  bool isLoading = true;
  int i = 0;
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
    if(i==0)
    {
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
          backgroundColor: Color(0xFFFEF5ED),
          elevation: 1,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_sharp,
              semanticLabel: 'proile',
              color: Color(0xFF72614E),
              size: 28,
            ),
            onPressed: () {
              Navigator.pop(context);
              i=0;
            },
          ),
          title: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 55.0, 0.0),
              child: Text(
                "계정",
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF72614E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          actions: <Widget>[
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.png'), // Replace 'assets/a.png' with the path to your image
              fit: BoxFit.cover,
            ),
          ),


          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : Container(
            child: Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  SizedBox(height: 120,),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFE5C49C),
                      borderRadius: BorderRadius.circular(90),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                    child: Text(
                      "User id",
                      style: TextStyle(
                          color: Color(0xFF72614E),
                          fontSize: 20,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    child: Text(
                      data['Userid'],
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF72614E),
                      ),
                    ),
                  ),
                  SizedBox(height: 60,),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFE5C49C),
                      borderRadius: BorderRadius.circular(90),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                    child: Text(
                      "NickName",
                      style: TextStyle(
                          color: Color(0xFF72614E),
                          fontSize: 20,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    child: Text(
                      data['Nickname'],
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF72614E),
                      ),
                    ),
                  ),
                  SizedBox(height: 60),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFE5C49C),
                      borderRadius: BorderRadius.circular(90),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                    child: Text(
                      "Email",
                      style: TextStyle(
                          color: Color(0xFF72614E),
                          fontSize: 20,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    child: Text(
                      data['Email'],
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF72614E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}