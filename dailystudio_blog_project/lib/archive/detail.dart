import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailystudio_blog_project/archive/archive_main.dart';
import 'package:dailystudio_blog_project/archive/archive_month.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../favorite/favorite.dart';
import '../main.dart';
import '../mainhome/home.dart';

enum DetailPageState {
  normal,
  creating,
}

class ArchiveDetail extends StatefulWidget {
  final String detailed;
  ArchiveDetail({required this.detailed});
  @override
  State<ArchiveDetail> createState() => _ArchiveDetailState();
}

class _ArchiveDetailState extends State<ArchiveDetail> {
  DetailPageState _pageState = DetailPageState.normal;
  late DocumentSnapshot productSnapshot;
  bool isLoading = true;
  int likesCount = 0;
  bool isLiked = false;
  bool isWriter = false;
  var data;
  int i = 0;
  PickedFile? _image;
  bool _isImage = false;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  int _selectedIndex = 1;
  late List<String> dates;

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
      if (_selectedIndex == 2) {
        Navigator.push( context, MaterialPageRoute(
            builder: (context){
              return ArchiveMain();
            }
        ));
      }
      _selectedIndex = 2;
    });
  }

  Future getImage() async {
    var image = await ImagePicker.platform.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image!;
      _isImage = true;
    });
  }

  void _handleCreateButtonPressed() {
    setState(() {
      _pageState = DetailPageState.creating;
    });
  }

  @override
  void initState() {
    super.initState();
    dates = widget.detailed.split('/');
  }
  Future<void>_getdata(String cn, String years, String month, String id) async {
    if(i == 0) {
      final post = await FirebaseFirestore.instance
          .collection('user')
          .doc(cn)
          .collection('post')
          .doc(years)
          .collection('month')
          .doc(month)
          .collection('posted')
          .doc(id)
          .get();
      setState(() {
        isLoading = false;
      });
      if (post.exists) {
        data = post.data(); // post 컬렉션의 필드값을 가져옵니다
        isLoading = false;
        // 가져온 필드 값을 사용하여 원하는 작업 수행
      }
      _titleController.text = data['Title'];
      _descriptionController.text = data['Content'];
    }
    i++;
  }
  @override
  Widget build(BuildContext context) {
    final currentUserProvider = Provider.of<CurrentUserModel>(context);
    final currentUsers = currentUserProvider.currentUsers;
    var cn = currentUsers.isNotEmpty ? currentUsers[0] : null;
    final id = dates[0];
    final years = dates[1];
    final month = dates[2];
    final day = dates[3];
    DocumentSnapshot? postSnapshot;
    _getdata(cn!.name, years, month, id);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
             years + "." + month + "." + day,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),

          leading: _pageState == DetailPageState.normal
              ? IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.pop(context);
            },
          )
              : IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              setState(() {
                _titleController.text = data['Title'];
                _descriptionController.text = data['Content'];
                _pageState = DetailPageState.normal;
                _isImage = false;
              });
            },
          ),
          actions: <Widget>[
            if (_pageState == DetailPageState.normal)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: const Icon(
                  Icons.create,
                  semanticLabel: 'modifed',
                  color: Colors.white,
                ),
                onPressed: _handleCreateButtonPressed,
              ),
            if (_pageState == DetailPageState.normal)
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  semanticLabel: 'delete',
                  color: Colors.white,
                ),
                onPressed: () async{
                  await FirebaseFirestore.instance
                      .collection('user')
                      .doc(cn!.name)
                      .collection('post')
                      .doc(years)
                      .collection('month')
                      .doc(month)
                      .collection('posted')
                      .doc(id).delete();
                  await FirebaseFirestore.instance
                      .collection('user')
                      .doc(cn!.name)
                      .collection('favorite')
                      .doc(id).delete();

                  final check_month = await FirebaseFirestore.instance
                      .collection('user')
                      .doc(cn!.name)
                      .collection('post')
                      .doc(years)
                      .collection('month')
                      .doc(month)
                      .collection('posted')
                      .get();
                  if(check_month.docs.isEmpty)
                    {
                      await FirebaseFirestore.instance
                          .collection('user')
                          .doc(cn!.name)
                          .collection('post')
                          .doc(years)
                          .collection('month')
                          .doc(month)
                          .delete();
                    }
                  final check_year = await FirebaseFirestore.instance
                      .collection('user')
                      .doc(cn!.name)
                      .collection('post')
                      .doc(years)
                      .collection('month')
                      .get();
                  if(check_year.docs.isEmpty)
                  {
                    await FirebaseFirestore.instance
                        .collection('user')
                        .doc(cn!.name)
                        .collection('post')
                        .doc(years)
                        .delete();
                  }
                  Navigator.push( context, MaterialPageRoute(
                      builder: (context){
                        return ArchiveMonth(selection: data['year'].toString()+"/"+data['month'].toString());
                      }
                  ));;
                },
              ),
            if (_pageState == DetailPageState.creating)
              TextButton(
                onPressed: () async{
                  late String title = _titleController.text;
                  late String description = _descriptionController.text;
                  final firebaseStorageRef = FirebaseStorage.instance;
                  var downloadUrl = data['IMAGE'];
                  if(_isImage == true)
                  {
                    TaskSnapshot task = await firebaseStorageRef
                        .ref() // 시작점
                        .child('post') // collection 이름
                        .child(title) // 업로드한 파일의 최종이름, 본인이 원하는 이름.
                        .putFile(File(_image!.path));
                    downloadUrl = await task.ref.getDownloadURL();
                  }
                  try {
                    await FirebaseFirestore.instance
                        .collection('user')
                        .doc(cn!.name)
                        .collection('post')
                        .doc(years)
                        .collection('month')
                        .doc(month)
                        .collection('posted')
                        .doc(id).update({
                        'Title': _titleController.text,
                        'Content': _descriptionController.text,
                        'IMAGE': downloadUrl,
                    });

                    setState(() {
                      i = 0;
                      _pageState = DetailPageState.normal;
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
                child: Text('Save'),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                ),
              ),
          ],
          centerTitle: true,
          backgroundColor: Colors.grey,
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            :SingleChildScrollView(
          scrollDirection: Axis.vertical,
          reverse: true,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: _pageState == DetailPageState.normal?Row(
                  children: [
                    Container(
                      height: 35,
                      width: 35,
                      child: IconButton(
                        onPressed: ()async{
                          if(data['favorite'] == false)
                          try {
                            await FirebaseFirestore.instance
                                .collection('user')
                                .doc(cn!.name)
                                .collection('post')
                                .doc(years)
                                .collection('month')
                                .doc(month)
                                .collection('posted')
                                .doc(id).update({
                              'favorite' : true,
                            });
                            setState(() {
                              i = 0;
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }

                          if(data['favorite'] == true)
                            try {
                              await FirebaseFirestore.instance
                                  .collection('user')
                                  .doc(cn!.name)
                                  .collection('post')
                                  .doc(years)
                                  .collection('month')
                                  .doc(month)
                                  .collection('posted')
                                  .doc(id).update({
                              'favorite' : false,
                              });
                              setState(() {
                                i = 0;
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                        },
                        icon: data['favorite']==true?Icon(Icons.star):Icon(Icons.star_border_outlined),
                        iconSize: 20,
                      ),
                    ),
                    Text(
                        data['Title'],
                    ),
                  ],
                ):Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: Container(
                    width: 350,
                    child: TextFormField(
                      controller: _titleController,
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          borderSide: BorderSide(
                            color: Colors.purpleAccent,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onDoubleTap: () {
                  setState(() {
                  });
                },
                child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child:_isImage?Image.file(
                        File(_image!.path),
                        height: 250.0,
                        width: 350.0,
                        fit: BoxFit.fill,
                      ):Image.network(
                        data['IMAGE'],
                        height: 250,
                        width: 350,
                        fit: BoxFit.fill,
                      ),
                    ),
              ),
              if (_pageState == DetailPageState.creating)
                Padding(
                  padding: const EdgeInsets.fromLTRB(330, 0, 0, 0),
                  child: IconButton(
                    icon: Icon(
                        Icons.camera_alt
                    ),
                    onPressed: (){
                      getImage();
                    },
                  ),
                ),
              _pageState == DetailPageState.normal?Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  width: 348,
                  decoration: BoxDecoration(
                    border: Border.all(
                    width: 1,
                    color: Colors.orange,
                    ),
                    ),
                  child: Text(
                    data['Content'],
                  ),
                ),
              ):Container(
                width: 348,
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 10, // 최대 라인수
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide(
                        color: Colors.purpleAccent,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.blue,
                  ),
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
              fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}