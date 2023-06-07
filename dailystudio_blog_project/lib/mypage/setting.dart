import 'package:dailystudio_blog_project/archive/add_post.dart';
import 'package:dailystudio_blog_project/archive/archive_main.dart';
import 'package:dailystudio_blog_project/favorite/favorite.dart';
import 'package:dailystudio_blog_project/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../mainhome/home.dart';
import 'my_page.dart';

class SettingPage extends StatefulWidget {
  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  int _selectedIndex = 3;
  bool light1 = true;

  final MaterialStateProperty<Icon?> thumbIcon =
  MaterialStateProperty.resolveWith<Icon?>(
        (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );

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
  Widget build(BuildContext context) {
    final currentUserProvider = Provider.of<CurrentUserModel>(context);
    final currentUsers = currentUserProvider.currentUsers;
    var cn = currentUsers.isNotEmpty ? currentUsers[0] : null;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFFEF5ED),
          elevation: 1,
          leading: Expanded(
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new,
                    color: Color(0xFF72614E)),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
          ),
          title: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 55.0, 0.0),
              child: const Text(
                '설정',
                style: TextStyle(
                    fontFamily: 'gangwon',
                    color: Color(0xFF72614E),
                    fontWeight: FontWeight.w600,
                    fontSize: 23),
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.png'), // Replace 'assets/a.png' with the path to your image
              fit: BoxFit.cover,
            ),
          ),



          child: Padding(
            padding: EdgeInsets.fromLTRB(10.0, 0.0, 15.0, 0.0),
            child: Container(
              width: 410,
              // 디버깅을 위한 박스 데코레이션
              // decoration: BoxDecoration(
              //   border: Border.all(
              //     width: 1,
              //     color: Colors.orange,
              //   ),
              // ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 8.0, 0.0, 8.0),
                    child: Container(
                      child: Row(
                        children: [
                          Text(
                            "계정",
                            style: TextStyle(
                              fontFamily: 'gangwon',
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Color(0xFF72614E),
                            ),
                          ),
                          SizedBox(width: 305),
                          Container(
                            width: 20,
                            height: 40,
                            child: IconButton(
                              onPressed: (){
                                Navigator.push( context, MaterialPageRoute(
                                    builder: (context){
                                      return MyPage();
                                    }
                                ));
                              },
                              icon: Icon(Icons.arrow_forward_ios_rounded,
                                  color: Color(0xFF72614E)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(thickness: 1, height: 1, color: Color(0xFFE3DADA)),

                  Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 8.0, 0.0, 8.0),
                    child: Container(
                      child: Row(
                        children: [
                          Text(
                            "라이트 모드",
                            style: TextStyle(
                              fontFamily: 'gangwon',
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Color(0xFF72614E),
                            ),
                          ),
                          SizedBox(width: 260),
                          Container(
                            width: 20,
                            height: 40,
                            child: Switch(
                              thumbIcon: thumbIcon,
                              value: light1,
                              onChanged: (bool value) {
                                setState(() {
                                  light1 = value;
                                  //전체 색상 여기서 조정 어둡게/밝게
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(thickness: 1.5, height: 1,color: Color(0xFFE3DADA)),

                  Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 8.0, 0.0, 8.0),
                    child: Container(
                      child: Row(
                        children: [
                          Text(
                            "글꼴 변경하기",
                            style: TextStyle(
                              fontFamily: 'gangwon',
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Color(0xFF72614E),
                            ),
                          ),
                          SizedBox(width: 236),
                          Container(
                            width: 20,
                            height: 40,
                            child: IconButton(
                              onPressed: (){},
                              icon: Icon(Icons.arrow_forward_ios_rounded,
                                  color: Color(0xFF72614E)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(thickness: 1, height: 1, color: Color(0xFFE3DADA)),

                  Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 8.0, 0.0, 8.0),
                    child: Container(
                      child: Row(
                        children: [
                          Text(
                            "문의하기",
                            style: TextStyle(
                              fontFamily: 'gangwon',
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Color(0xFF72614E),
                            ),
                          ),
                          SizedBox(width: 272),
                          Container(
                            width: 20,
                            height: 40,
                            child: IconButton(
                              onPressed: (){
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18.0),
                                      ),
                                      backgroundColor: Color(0xFfF8ECE2),
                                      title: Text('개발자 INFO',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'gangwon',
                                            fontSize: 21,
                                            //color: Color(0xFF746553),
                                            color: Color(0xFF3C3731)

                                        ),),
                                      content: SizedBox(
                                        height: 48,
                                        child: Column(

                                          children: [

                                            Text('21900104@handong.ac.kr',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize:20,
                                                  fontFamily: 'gangwon',
                                                  //color: Color(0xFF746553),
                                                  color: Color(0xFF3C3731)

                                              ),),
                                            SizedBox(height: 2,),
                                            Text('22000405@handong.ac.kr',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 20,
                                                  fontFamily: 'gangwon',
                                                  //color: Color(0xFF746553),
                                                  color: Color(0xFF3C3731)

                                              ),),
                                          ],
                                        ),
                                      ),
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
                                              Navigator.pop(context);
                                            });
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: Icon(Icons.arrow_forward_ios_rounded,
                                  color: Color(0xFF72614E)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(thickness: 1, height: 1, color: Color(0xFFE3DADA)),



                  Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 16.0, 0.0, 16.0),
                    child: Container(
                      child: Row(
                        children: [
                          Text(
                            "버전",
                            style: TextStyle(
                              fontFamily: 'gangwon',
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Color(0xFF72614E),
                            ),
                          ),
                          SizedBox(width: 296),
                          Container(
                            child: Text(
                                "1.0.0",
                              style: TextStyle(
                                  fontFamily: 'gangwon',
                                  color: Color(0xFF72614E),
                                fontWeight: FontWeight.w600,
                                fontSize: 22
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(thickness: 1, height: 1, color: Color(0xFFE3DADA)),
                  SizedBox(height: 220,),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                    child: ElevatedButton(
                      child: Text(
                        "로그아웃", // 인덱스 0에 해당하는 요소가 없을 경우 빈 문자열 반환
                        style: TextStyle(
                            fontFamily: 'gangwon',
                            color: Color(0xFF72614E),
                            fontWeight: FontWeight.w600,
                            fontSize: 21),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary:  Color(0xFFEFE3D6),
                        minimumSize: const Size(370, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0), // Set the desired border radius here
                        ),
                      ),
                      onPressed: () async{
                        var name = CurrentUser(name: cn!.name);
                        currentUserProvider.removeUser(name);
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
          backgroundColor: Color(0xFFFEF5ED),
          selectedItemColor: Color(0xFF685F53),
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