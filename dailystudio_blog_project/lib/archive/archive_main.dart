import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'archive_month.dart';



class ArchiveMain extends StatefulWidget {
  @override
  _ArchiveMainState createState() =>  _ArchiveMainState();
}
class _ArchiveMainState extends State<ArchiveMain> {
  PickedFile? _image;
  DateTime date = DateTime.now();
  late DocumentSnapshot productSnapshot;
  final TextEditingController _title = new TextEditingController();
  final TextEditingController _content = new TextEditingController();
  final TextEditingController _price = new TextEditingController();

  int _selectedIndex = 2;
  bool _isTitle = false;
  bool _isContent = false;
  bool _isLoading = false;

  Future getImage() async {
    var image = await ImagePicker.platform.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image!;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/');
      }
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
                    Navigator.pop(context);
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

              return ListView.builder(
                itemCount: yearCollections.length,
                itemBuilder: (BuildContext context, int index)  {
                  final yearCollection = yearCollections[index];
                  final monthCollection = yearCollection.reference.collection(yearCollection.id);
                  // Extract the names of subcollections
                  return Column(
                    children: [
                      ListTile(
                        title: Text(yearCollection.id + "년"),
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

                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                            ),
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: monthDocs.length,
                            itemBuilder: (BuildContext context, int index) {
                              final month = monthDocs[index].id;

                              return GridTile(
                                child: Column(
                                    children:[
                                        InkWell(
                                          onTap: () {
                                              Navigator.push( context, MaterialPageRoute(
                                                  builder: (context){
                                                    return ArchiveMonth(selection: yearCollection.id.toString() + "/" + month.toString());
                                                  }
                                              ));
                                          },
                                          child: Image.asset(
                                          'assets/default.png',
                                          height: 100.0,
                                          width: 110.0,
                                          fit: BoxFit.fill,
                                      ),
                                        )
                                      ,Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(month + "월"),
                                      )
                                    ]
                                ),
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
    );
  }
  Future<void> _handleSubmitted(
      String title, String content, File img, String name) async {
    setState(() {
      _isLoading = true;
      FocusScope.of(context).unfocus();
    });
    final firebaseStorageRef = FirebaseStorage.instance;
    final postRef = FirebaseFirestore.instance.collection('user').doc(name);
    final postYear = postRef.collection('post').doc(date.year.toString());
    final postMonth = postYear.collection(date.month.toString()).doc(title);
    if(_image == null){
      var downloadUrl =
          "https://firebasestorage.googleapis.com/v0/b/dailyblogproject-e323c.appspot.com/o/post%2F%EB%8B%A4%EC%9A%B4%EB%A1%9C%EB%93%9C.png?alt=media&token=fdbd13ff-bec6-4615-ae91-20410ff83a8a";
      postMonth.set({
        'IMAGE': downloadUrl,
        'Title': title,
        'Content': content,
        'likes': 0,
        'year' : date.year,
        'month' : date.month,
        'day' : date.day,
        'createdTime': FieldValue.serverTimestamp(),
        'modifiedTime': FieldValue.serverTimestamp(),
      }).then((onValue) {
        //정보 인서트후, 상위페이지로 이동
        Navigator.pop(context);
      });
    }
    else{
      TaskSnapshot task = await firebaseStorageRef
          .ref() // 시작점
          .child('post') // collection 이름
          .child(title) // 업로드한 파일의 최종이름, 본인이 원하는 이름.
          .putFile(File(_image!.path));
      if (task != null) {
        // 업로드 완료되면 데이터의 주소를 얻을수 있음, future object
        var downloadUrl = await task.ref.getDownloadURL();

        // post collection 만들고, 하위에 문서를 만든다
        postMonth.set({
          'IMAGE': downloadUrl,
          'Title': title,
          'Content': content,
          'likes': 0,
          'year' : date.year,
          'month' : date.month,
          'day' : date.day,
          'createdTime': FieldValue.serverTimestamp(),
          'modifiedTime': FieldValue.serverTimestamp(),
        }).then((onValue) {
          //정보 인서트후, 상위페이지로 이동
          Navigator.pop(context);
        });
      }
    }


  }
}

