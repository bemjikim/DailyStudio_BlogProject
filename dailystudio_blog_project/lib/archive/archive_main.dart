import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

import '../favorite/favorite.dart';
import '../main.dart';
import '../mainhome/home.dart';
import 'archive_month.dart';
import 'package:flutter/services.dart';


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
        child: Stack(
          children :[
            Container(
              decoration: BoxDecoration(
                image:DecorationImage(
                  image:AssetImage('assets/login.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.grey,
                  leading: Expanded(
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios_new),
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
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 50.0, 0.0),
                      child: const Text(
                        '기록 보관소',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
                body: StreamBuilder<QuerySnapshot>(
                  stream: postRef.collection('post').snapshots(),
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
                            "There is no data"
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
                              title: Text(
                                yearCollection.id + "년",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700, // 텍스트의 굵기 설정
                                ),
                              ),

                            ),
                            StreamBuilder<QuerySnapshot>(
                              stream: yearCollection.reference.collection('month').snapshots(),
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
                                  return Text("There is the no data");
                                }
                                return GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 0, // 아이템 간의 가로 간격
                                    mainAxisSpacing: 10,
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
                                          child: InkWell(
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
                                            child: Column(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  child: Image.network(
                                                    productSnapshot['IMAGE'],
                                                    height: 100.0,
                                                    width: 100.0,
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(4.0),
                                                  child: Text(month + "월",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 15
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
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
                      fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                  onTap: _onItemTapped,
                  type: BottomNavigationBarType.fixed,
                ),

              ),
            ),
          ],
        ),
      ),
    );
  }
}

