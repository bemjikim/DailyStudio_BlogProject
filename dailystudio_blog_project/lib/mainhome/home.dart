import 'package:dailystudio_blog_project/archive/add_post.dart';
import 'package:dailystudio_blog_project/archive/archive_main.dart';
import 'package:dailystudio_blog_project/favorite/favorite.dart';
import 'package:dailystudio_blog_project/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

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
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserProvider = Provider.of<CurrentUserModel>(context);
    final currentUsers = currentUserProvider.currentUsers;
    var cn = currentUsers.isNotEmpty ? currentUsers[0] : null;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          automaticallyImplyLeading: false,
          title: Center(
            child: Padding(
              padding:  EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              child:  Text("Daily Studio"),
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/main.png',
                fit: BoxFit.cover,
              ),
            ),


            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 380,),
                  Container(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      child: const Text(
                        '사진 찍으러 왔어요! (기록 남기기)',
                        style: TextStyle(
                            color: Color(0xFF443C34),
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary:  Color(0xFFE3CFB8),
                        minimumSize: const Size(360, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // Set the desired border radius here
                        ),
                      ),
                      onPressed: () {
                        Navigator.push( context, MaterialPageRoute(
                            builder: (context){
                              return AddPost();
                            }
                        ));
                      },
                    ),
                  ),
                  SizedBox(height: 8,),
                  Container(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      child: const Text(
                        '사진 찾으러 왔어요! (기록 보관소)',
                        style: TextStyle(
                            color: Color(0xFF443C34),
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary:  Color(0xFFE3CFB8),
                        minimumSize: const Size(360, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // Set the desired border radius here
                        ),
                      ),
                      onPressed: () {
                        Navigator.push( context, MaterialPageRoute(
                            builder: (context){
                              return ArchiveMain();
                            }
                        ));
                      },
                    ),
                  ),
                  SizedBox(height: 8,),
                  Container(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      child: Text(
                        "로그아웃", // 인덱스 0에 해당하는 요소가 없을 경우 빈 문자열 반환
                        style: TextStyle(
                            color: Color(0xFF443C34),
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary:  Color(0xFFE3CFB8),
                        minimumSize: const Size(360, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // Set the desired border radius here
                        ),
                      ),
                      onPressed: () {
                        currentUserProvider.removeUser(cn!);
                        Navigator.push( context, MaterialPageRoute(
                            builder: (context){
                              return LoginPage();
                            }
                        ));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: 'Like',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_copy),
              label: 'Archive',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Setting',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          unselectedItemColor: Colors.grey,
          unselectedLabelStyle: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey),
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
