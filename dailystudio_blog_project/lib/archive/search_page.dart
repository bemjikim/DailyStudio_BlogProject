import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailystudio_blog_project/archive/archive_main.dart';
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
import 'detail.dart';

class SearchPage extends StatefulWidget {
  @override
  SearchPageState createState() =>  SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  PickedFile? _image;
  DateTime date = DateTime.now();
  bool _isSearch = false;
  late DocumentSnapshot productSnapshot;
  int _selectedIndex = 2;
  bool _isTitle = false;
  String search = "";
  TextEditingController _searchController = TextEditingController(); // 검색어를 입력받는 컨트롤러
  List<DocumentSnapshot> _searchResults = []; // 검색 결과를 저장하는 리스트

  Future getImage() async {
    var image = await ImagePicker.platform.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image!;
    });
    _selectedIndex = 2;
  }
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return HomePage();
        }));
      }
      if (_selectedIndex == 1) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return FavoritePage();
        }));
      }
      if (_selectedIndex == 2) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return ArchiveMain();
        }));
      }
      if (_selectedIndex == 3) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return SettingPage();
        }));
      }
      _selectedIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserProvider = Provider.of<CurrentUserModel>(context);
    final currentUsers = currentUserProvider.currentUsers;
    var cn = currentUsers.isNotEmpty ? currentUsers[0] : null;
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ArchiveMain();
                  }));
                },
              ),
            ),
            title: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 50.0, 0.0),
                child: const Text(
                  '검색',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF72614E) ),
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
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            style: TextStyle(fontSize: 20),
                            decoration: InputDecoration(
                          ),
                        ),
                      ),
                      IconButton(
                          icon: Icon(Icons.search,
                              color: Color(0xFF72614E),
                          size: 30,),
                          onPressed:()async{
                            setState(() {
                              search = _searchController.text;
                            });
                          }
                      ),
                    ],
                  ),
                ),
                  Expanded(
                    child:showBody()
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

  showBody() {
    final currentUserProvider = Provider.of<CurrentUserModel>(context);
    final currentUsers = currentUserProvider.currentUsers;
    var cn = currentUsers.isNotEmpty ? currentUsers[0] : null;
    final postRef = FirebaseFirestore.instance.collection('user').doc(cn!.name);

    return StreamBuilder<QuerySnapshot>(
      stream: postRef.collection('post').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        final yearCollections = snapshot.data?.docs ?? [];
        if (yearCollections.length == 0) {
          return Center(
            child: Text("There is no data",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),),
          );
        }

        List<DocumentSnapshot> displayedResults = _searchResults;

        return ListView.builder(
          itemCount: yearCollections.length,
          itemBuilder: (BuildContext context, int index) {
            final yearCollection = yearCollections[index];

            // Extract the names of subcollections
            return StreamBuilder<QuerySnapshot>(
              stream: yearCollection.reference.collection('month').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                final monthDocs = snapshot.data?.docs ?? [];
                if (monthDocs.isEmpty) {
                  return Text("There is no data");
                }

                return ListView.builder(
                  // 스크롤 동작 비활성화
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: monthDocs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final month = monthDocs[index].id;

                    return StreamBuilder<QuerySnapshot>(
                      stream: yearCollection.reference
                          .collection('month')
                          .doc(month)
                          .collection('posted')
                          .orderBy('wholeday')
                          .snapshots(),
                      builder:
                          (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        final productSnapshots = snapshot.data?.docs ?? [];
                        print(productSnapshots.length);
                        final filteredSnapshots = productSnapshots.where((snapshot) => snapshot['tag'].toString().contains(_searchController.text)).toList();
                        print(filteredSnapshots.length);
                        if(_searchController.text.length == 0 || filteredSnapshots.isEmpty)
                          {
                            return Center(
                              child: Text("There is no data."),
                            );
                          }
                        return ListView.builder(
                          // 스크롤 동작 비활성화
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: filteredSnapshots.length,
                          itemBuilder: (BuildContext context, int index) {
                            final productSnapshot = filteredSnapshots[index];
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(20.0, 5, 0, 0),
                                    child: Container(
                                      width: 600,
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 35,
                                            width: 35,
                                            child: IconButton(
                                              onPressed: () async {
                                                if (productSnapshot['favorite'] == false)
                                                  try {
                                                    await FirebaseFirestore.instance
                                                        .collection('user')
                                                        .doc(cn!.name)
                                                        .collection('post')
                                                        .doc(yearCollection.id)
                                                        .collection('month')
                                                        .doc(month)
                                                        .collection('posted')
                                                        .doc(productSnapshot.id)
                                                        .update({
                                                      'favorite': true,
                                                    });
                                                    await FirebaseFirestore.instance
                                                        .collection('user')
                                                        .doc(cn!.name)
                                                        .collection('favorite')
                                                        .doc(productSnapshot.id)
                                                        .set({
                                                      'IMAGE': productSnapshot['IMAGE'],
                                                      'Title': productSnapshot['Title'],
                                                      'Content': productSnapshot['Content'],
                                                      'favorite': true,
                                                      'year': productSnapshot['year'],
                                                      'month': productSnapshot['month'],
                                                      'day': productSnapshot['day'],
                                                      'wholeday': int.parse(
                                                          productSnapshot['wholeday']),
                                                    });
                                                    setState(() {});
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      SnackBar(content: Text(e.toString())),
                                                    );
                                                  }

                                                if (productSnapshot['favorite'] == true)
                                                  try {
                                                    await FirebaseFirestore.instance
                                                        .collection('user')
                                                        .doc(cn!.name)
                                                        .collection('post')
                                                        .doc(yearCollection.id)
                                                        .collection('month')
                                                        .doc(month)
                                                        .collection('posted')
                                                        .doc(productSnapshot.id)
                                                        .update({
                                                      'favorite': false,
                                                    });
                                                    await FirebaseFirestore.instance
                                                        .collection('user')
                                                        .doc(cn!.name)
                                                        .collection('favorite')
                                                        .doc(productSnapshot.id)
                                                        .delete();
                                                    setState(() {});
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      SnackBar(content: Text(e.toString())),
                                                    );
                                                  }
                                              },
                                              icon: productSnapshot['favorite'] == true
                                                  ? Icon(Icons.star)
                                                  : Icon(Icons.star_border_outlined),
                                              iconSize: 28,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8, left: 8),
                                            child: Text(
                                              productSnapshot['Title'].toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0.0, 7, 0, 0),
                                    child: Stack(children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                                            return ArchiveDetail(detailed: productSnapshot.id + "/" + productSnapshot['year'].toString() + "/" + productSnapshot['month'].toString() + "/" + productSnapshot['day'].toString());
                                          }));
                                        },
                                        child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            productSnapshot['IMAGE'],
                                            height: 250.0,
                                            width: 370.0,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(17.0, 11, 0, 0),
                                        child: Text(
                                          productSnapshot['year'].toString() +
                                              '.' +
                                              productSnapshot['month'].toString().padLeft(2, '0') +
                                              '.' +
                                              productSnapshot['day'].toString().padLeft(2, '0'),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                ],
                              );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}