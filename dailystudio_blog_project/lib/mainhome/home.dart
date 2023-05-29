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
          Navigator.pushNamed(context, '/main_archive');
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserProvider = Provider.of<CurrentUserModel>(context);
    final currentUsers = currentUserProvider.currentUsers;
    var cn = currentUsers.isNotEmpty ? currentUsers[0] : null;

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                  child: const Text(
                    '사진 찍으러 왔어요! (기록 남기기)',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white60,
                    minimumSize: const Size(360, 38),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/addpost');
                  },
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                  child: const Text(
                    '사진 찾으러 왔어요! (기록 보관소)',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white60,
                    minimumSize: const Size(360, 38),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/main_archive');
                  },
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: ElevatedButton(
                  child: Text(
                    "로그아웃", // 인덱스 0에 해당하는 요소가 없을 경우 빈 문자열 반환
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white60,
                    minimumSize: const Size(360, 38),
                  ),
                  onPressed: () {
                    currentUserProvider.removeUser(cn!);
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ),
            ],
          ),
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
