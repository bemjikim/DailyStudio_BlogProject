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
      if (_selectedIndex == 3) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return SettingPage();
        }));
      }
      _selectedIndex = 2;
    });
  }

  void _search(String name, String text) async{
    String searchTerm = _searchController.text; // 검색어 가져오기
    List<DocumentSnapshot> allResults = []; // 전체 데이터에서 검색 결과를 저장할 리스트

    final postRef = await FirebaseFirestore.instance.collection('user').doc(name);
    print("This is result!!");

      setState(() {
        postRef.collection('post').get().then((QuerySnapshot snapshot) {
          // 전체 데이터를 가져옴
          snapshot.docs.forEach((DocumentSnapshot yearCollection) {
            yearCollection.reference.collection('month').get().then((QuerySnapshot snapshot) {
              snapshot.docs.forEach((DocumentSnapshot monthDoc) {
                monthDoc.reference.collection('posted').orderBy('wholeday').get().then((QuerySnapshot snapshot) {
                  snapshot.docs.forEach((DocumentSnapshot productSnapshot) {
                    // 검색어와 비교하여 일치하는 경우 결과에 추가
                    String result = productSnapshot['tag'];
                    print("This is result!!" + result);
                    print('text:' + text);
                    if(result.contains(searchTerm))
                    {
                      allResults.add(productSnapshot);
                      print("get!!!!");
                      print(allResults.length);
                    }
                  });
                });
              });
            });
          });
        });
        _searchResults = allResults; // 검색 결과를 저장
        _isSearch = true;
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
            backgroundColor: Colors.grey,
            leading: Expanded(
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return HomePage();
                  }));
                },
              ),
            ),
            title: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 50.0, 0.0),
                child: const Text(
                  '검색',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                        ),
                      ),
                    ),
                    IconButton(
                        icon: Icon(Icons.search),
                        onPressed:(){
                          _search(cn!.name, _searchController.text);
                        }
                    ),
                  ],
                ),
              ),
              if(!_isSearch || _searchController.text.length == 0)
                ListTile(
                  title: Text(
                    "검색을 해주세요"
                  ),
                ),
              if(_isSearch && _searchController.text.length > 0)
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
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
                          child: Text("There is no data"),
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
                                        .orderBy('day')
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
                                      if (productSnapshots.isEmpty) {
                                        return SizedBox(); // 빈 컨테이너 또는 로딩 상태를 보여줄 위젯을 반환합니다.
                                      }

                                      return ListView.builder(
                                        // 스크롤 동작 비활성화
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: productSnapshots.length,
                                        itemBuilder: (BuildContext context, int index) {
                                          final productSnapshot = productSnapshots[index];
                                          if(productSnapshot['tag'].toLowerCase().contains(_searchController.text))
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
                                                          iconSize: 20,
                                                        ),
                                                      ),
                                                      Text(
                                                        productSnapshot['Title'].toString(),
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(0.0, 10, 0, 0),
                                                child: Stack(children: [
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                        return ArchiveDetail(detailed: productSnapshot.id + "/" + productSnapshot['year'].toString() + "/" + productSnapshot['month'].toString() + "/" + productSnapshot['day'].toString());
                                                      }));
                                                    },
                                                    child: Image.network(
                                                      productSnapshot['IMAGE'],
                                                      height: 200.0,
                                                      width: 350.0,
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(20.0, 10, 0, 0),
                                                    child: Text(
                                                      productSnapshot['year'].toString() +
                                                          '.' +
                                                          productSnapshot['month'].toString() +
                                                          '.' +
                                                          productSnapshot['day'].toString(),
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 20,
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
                fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}