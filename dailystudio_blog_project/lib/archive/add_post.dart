import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailystudio_blog_project/archive/archive_main.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import '../favorite/favorite.dart';
import '../main.dart';
import '../mainhome/home.dart';
import '../mypage/setting.dart';



class AddPost extends StatefulWidget {
  @override
  _AddPostState createState() =>  _AddPostState();
}
class _AddPostState extends State<AddPost> {
  PickedFile? _image;
  DateTime date = DateTime.now();
  String scannedText = "";
  List<ImageLabel> labels = [];
  bool isImageLoaded = false;
  late DocumentSnapshot productSnapshot;
  final TextEditingController _title = new TextEditingController();
  final TextEditingController _content = new TextEditingController();
  final TextEditingController _price = new TextEditingController();
  int _selectedIndex = 0;
  bool _isTitle = false;
  bool _isContent = false;
  bool _isLoading = false;

  Future getImage() async {
    var image  = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    final ImageLabeler imageLabeler = GoogleMlKit.vision.imageLabeler();

    setState(() {
      _image = image!;
    });

    if (_image != null) {
      setState(() {
        isImageLoaded = true;
      });
    }
    final inputImage = InputImage.fromFilePath(_image!.path);
    final List<ImageLabel> imageLabels = await imageLabeler.processImage(inputImage);
    setState(() {
      labels = imageLabels;
    });

    for (var label in labels) {
      scannedText += '#'+ label.label + ' ';
    }
  }

  void _onItemTapped(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('알림'),
          content: Text('작성하고 계시는 글이 삭제됩니다\n괜찮으시겠습니까?'),
          actions: [
            TextButton(
              child: Text('아니요'),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
            ),
            TextButton(
              child: Text('예'),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                  _selectedIndex = index;
                  if (_selectedIndex == 0) {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return HomePage();
                        }
                    ));
                  }
                  if (_selectedIndex == 1) {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return FavoritePage();
                        }
                    ));
                  }
                  else if (_selectedIndex == 2) {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return ArchiveMain();
                        }
                    ));
                  }

                  if (_selectedIndex == 3) {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return SettingPage();
                        }
                    ));
                  }
                });
              },
            ),
          ],
        );
      },
    );
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
                    Navigator.pop(context);
                  },
                )
            ),
            title: Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 50.0, 0.0),
                child: const Text(
                  '기록 남기기',
                    style: TextStyle(
                        color: Color(0xFF72614E),
                        fontWeight: FontWeight.w600,
                        fontSize: 20),
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
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              reverse: true,
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 10, 0, 10),
                            child: IconButton(
                              icon: Icon(Icons.calendar_today_outlined,
                              size: 26,),
                              onPressed: () async {
                                final selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: date,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (selectedDate != null) {
                                  setState(() {
                                    date = selectedDate;
                                  });
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            "${date.year.toString()}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
                            style: TextStyle(
                              fontSize: 18, // Adjust the font size as desired
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 0.0),
                      child:
                      _isLoading ? new CircularProgressIndicator() : null,
                    ),
                    Container(
                        height: 426,
                        width: 370,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Color(0xFFBABABA),
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextField(
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                controller: _title,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,

                                ),
                                onChanged: (String text) {
                                  setState(() {
                                    _isTitle = text.length > 0;
                                  });
                                },
                                decoration: InputDecoration.collapsed(
                                  hintText: "제목",
                                  border: UnderlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFF72614E),
                                      style: BorderStyle.solid,
                                      width: 5.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 50,),
                            InkWell(
                              child: _image == null
                                  ? Image.asset(
                                "assets/camera.png",
                                height: 40.0,
                                width: 100.0,

                              )
                                  : Image.file(
                                File(_image!.path),
                                height: 100.0,
                                width: 320.0,
                                fit: BoxFit.fill,
                              ),
                              onTap: () {
                                getImage();
                              },
                            ),
                            SizedBox(height: 50,),

                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextField(
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                controller: _content,
                                style: TextStyle(color: Colors.black,
                                    fontSize: 18.0),
                                onChanged: (String text) {
                                  setState(() {
                                    _isContent = text.length > 0;
                                  });
                                },
                                decoration: InputDecoration.collapsed(
                                  hintText: "내용",
                                  border: UnderlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Color(0xFF72614E),
                                      style: BorderStyle.solid,
                                      width: 5.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                    ),
                    SizedBox(height: 14,),
                    ElevatedButton(
                        child: const Text(
                          '기록 인화하기',
                          style: TextStyle(
                              color: Color(0xFF72614E),
                              fontWeight: FontWeight.w600,
                              fontSize: 17),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary:  Color(0xFFE3CFB8),
                          minimumSize: const Size(370, 46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0), // Set the desired border radius here
                          ),
                        ),
                        onPressed: (){
                          if(_isTitle && _isContent && !_isLoading &&_image != null)
                          {
                            _handleSubmitted(_title.text,
                                _content.text, File(_image!.path), cn!.name);
                          }
                          else
                          {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('알림'),
                                  content: Text('제목, 사진, 내용을 기입해주세요'),
                                  actions: [
                                    TextButton(
                                      child: Text('OK'),
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
                          }
                        }
                    ),
                    SizedBox(height: 16,),
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
    final postMonth = postYear.collection('month').doc(date.month.toString());
    final posted = postMonth.collection('posted').doc(title);
    if(_image == null){
      postYear.set({
        'make' : 1,
      });
      postMonth.set({
        'make' : 1,
      });
      var downloadUrl =
          "https://firebasestorage.googleapis.com/v0/b/dailyblogproject-e323c.appspot.com/o/post%2F%EB%8B%A4%EC%9A%B4%EB%A1%9C%EB%93%9C.png?alt=media&token=fdbd13ff-bec6-4615-ae91-20410ff83a8a";
      posted.set({
        'IMAGE': downloadUrl,
        'Title': title,
        'Content': content,
        'favorite': false,
        'year' : date.year,
        'month' : date.month,
        'day' : date.day,
        'tag': scannedText,
        'wholeday' : date.year.toString() +  date.month.toString()  + date.day.toString(),
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
        postYear.set({
          'make' : 1,
        });
        postMonth.set({
          'make' : 1,
        });
        // post collection 만들고, 하위에 문서를 만든다
        posted.set({
          'IMAGE': downloadUrl,
          'Title': title,
          'Content': content,
          'likes': 0,
          'favorite': false,
          'year' : date.year,
          'month' : date.month,
          'day' : date.day,
          'tag': scannedText,
          'wholeday' : date.year.toString()  + date.month.toString()  + date.day.toString(),
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
