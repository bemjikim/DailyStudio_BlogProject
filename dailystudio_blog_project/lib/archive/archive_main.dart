import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailystudio_blog_project/archive/search_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

import '../favorite/favorite.dart';
import '../main.dart';
import '../mainhome/home.dart';
import '../mypage/setting.dart';
import 'archive_month.dart';



class ArchiveMain extends StatefulWidget {
  @override
  _ArchiveMainState createState() =>  _ArchiveMainState();
}
class _ArchiveMainState extends State<ArchiveMain> {
  PickedFile? _image;
  DateTime date = DateTime.now();

  late DocumentSnapshot productSnapshot;
  int _selectedIndex = 2;
  bool _isTitle = false;

  Future getImage() async {
    var image = await ImagePicker.platform.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image!;
    });
    _selectedIndex = 2;
  }



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        Navigator.push( context, MaterialPageRoute(
            builder: (context){
              return HomePage();
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
      if(_selectedIndex == 3)
      {
        Navigator.push( context, MaterialPageRoute(
            builder: (context){
              return SettingPage();
            }
        ));
      }
      _selectedIndex = 2;
    });
  }
  @override
  Widget build(BuildContext context) {
    final currentUserProvider = Provider.of<CurrentUserModel>(context);
    final currentUsers = currentUserProvider.currentUsers;
    var cn = currentUsers.isNotEmpty ? currentUsers[0] : null;
    final postRef = FirebaseFirestore.instance.collection('user').doc(cn!.name);
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFFFEF5ED),
            elevation: 1,
            leading: Expanded(
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new,
                      color: Color(0xFF72614E)),
                  onPressed: () {
                    Navigator.push( context, MaterialPageRoute(
                        builder: (context){
                          return HomePage();
                        }
                    ));
                  },
                )
            ),
            title: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                child: const Text(
                  '기록 보관소',
                  style: TextStyle(
                      fontFamily: 'gangwon',
                      color: Color(0xFF72614E),
                      fontWeight: FontWeight.w600,
                      fontSize: 23),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                child: IconButton(
                  icon: Icon(Icons.search,
                      color: Color(0xFF72614E),
                  size: 29,),
                  onPressed: () {
                    Navigator.push( context, MaterialPageRoute(
                        builder: (context){
                          return SearchPage();
                        }
                    ));
                  },
                ),
              )
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'), // Replace 'assets/a.png' with the path to your image
                fit: BoxFit.cover,
              ),
            ),


            child: StreamBuilder<QuerySnapshot>(
              stream: postRef.collection('post').orderBy('make').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                final yearCollections = snapshot.data?.docs ?? [];
                if(yearCollections.length ==0)
                {
                  return Center(
                    child: Text(
                        "There is no data",
                      style: TextStyle(
                          fontFamily: 'gangwon',
                          color: Color(0xFF72614E),
                          fontWeight: FontWeight.w200,
                          fontSize: 20),

                    ),
                  );
                }
                return ListView.builder(
                  itemCount: yearCollections.length,
                  itemBuilder: (BuildContext context, int index)  {
                    final yearCollection = yearCollections[index];

                    // Extract the names of subcollections
                    return Column(
                      children: [
                        if(yearCollections.length != 0)
                          ListTile(
                            title: Text(yearCollection.id + "년",
                              style: TextStyle(
                                fontSize: 22,
                                fontFamily: 'gangwon',
                                color: Color(0xFF72614E),// Adjust the value as per your preference
                                fontWeight: FontWeight.w600, // You can also adjust the font weight if needed
                              ),),
                          ),
                        StreamBuilder<QuerySnapshot>(
                          stream: yearCollection.reference.collection('month').orderBy('make').snapshots(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }

                            final monthDocs = snapshot.data?.docs ?? [];
                            if(monthDocs.isEmpty)
                            {
                              return Text("There is the no data",
                                style: TextStyle(
                                    fontFamily: 'gangwon',
                                    color: Color(0xFF72614E),
                                    fontWeight: FontWeight.w200,
                                    fontSize: 20),);
                            }
                            return GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 1, // Adjust the spacing value as per your preference
                                mainAxisSpacing: 1, // Adjust the spacing value as per your preference
                              ),
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: monthDocs.length,
                              itemBuilder: (BuildContext context, int index) {
                                final month = monthDocs[index].id;

                                return FutureBuilder<QuerySnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('user')
                                      .doc(cn!.name)
                                      .collection('post')
                                      .doc(yearCollection.id)
                                      .collection('month')
                                      .doc(month)
                                      .collection('posted')
                                      .get(),
                                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }

                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }

                                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                      return SizedBox(); // 빈 컨테이너 또는 로딩 상태를 보여줄 위젯을 반환합니다.
                                    }

                                    final productSnapshot = snapshot.data!.docs.last;
                                    return GridTile(
                                      child: Column(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return ArchiveMonth(
                                                      selection: yearCollection.id.toString() + "/" + month.toString(),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.network(
                                                productSnapshot['IMAGE'],
                                                height: 102.0,
                                                width: 102.0,
                                                fit: BoxFit.fitWidth,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4.0, bottom: 9),
                                            child: Text(month + "월",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontFamily: 'gangwon',
                                                color: Color(0xFF72614E),// Adjust the value as per your preference
                                                fontWeight: FontWeight.w600, // You can also adjust the font weight if needed
                                              ),),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
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
                fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),

        ),
      ),
    );
  }
}