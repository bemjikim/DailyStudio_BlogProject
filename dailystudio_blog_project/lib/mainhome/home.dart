import 'package:dailystudio_blog_project/archive/add_post.dart';
import 'package:dailystudio_blog_project/archive/archive_main.dart';
import 'package:dailystudio_blog_project/favorite/favorite.dart';
import 'package:dailystudio_blog_project/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../mypage/setting.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if(_selectedIndex == 3)
      {
        Navigator.push( context, MaterialPageRoute(
            builder: (context){
              return SettingPage();
            }
        ));
      }
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
          backgroundColor:Color (0xFFFEF5ED),
          automaticallyImplyLeading: false,
          title: Center(
            child: Padding(
              padding:  EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              child:  Text("Daily Studio",
                style: TextStyle(
                    fontFamily: 'gangwon',
                    color: Color(0xFF443C34),
                    fontWeight: FontWeight.w900,
                    fontSize: 30),
              ),
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
                  SizedBox(height: 420,),
                  Container(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      child: const Text(
                        '사진 찍으러 왔어요! (기록 남기기)',
                        style: TextStyle(
                            fontFamily: 'gangwon',
                            color: Color(0xFF72614E),
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary:  Color(0xFFF0E7DC),
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
                  SizedBox(height: 10),
                  Container(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      child: const Text(
                        '사진 찾으러 왔어요! (기록 보관소)',
                        style: TextStyle(
                            fontFamily: 'gangwon',
                            color: Color(0xFF72614E),
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary:  Color(0xFFF0E7DC),
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
                  SizedBox(height: 8,)
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
          backgroundColor: Color(0xFFFEF5ED),
          selectedItemColor: Color(0xFF685F53),

          unselectedItemColor: Colors.grey,
          unselectedLabelStyle: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey),
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
