import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailystudio_blog_project/archive/archive_main.dart';
import 'package:dailystudio_blog_project/mainhome/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../archive/detail.dart';
import '../main.dart';
import '../mypage/setting.dart';


class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
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

      if (_selectedIndex == 2) {
        Navigator.push( context, MaterialPageRoute(
            builder: (context){
              return ArchiveMain();
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
      _selectedIndex = 1;
    });
  }

  @override
  void initState() {
    super.initState();
    // widget 멤버에 접근하는 코드를 initState() 메서드로 이동
  }

  @override
  Widget build(BuildContext context) {
    final currentUserProvider = Provider.of<CurrentUserModel>(context);
    final currentUsers = currentUserProvider.currentUsers;
    var cn = currentUsers.isNotEmpty ? currentUsers[0] : null;
    final postRef = FirebaseFirestore.instance
        .collection('user')
        .doc(cn!.name)
        .collection('favorite')
        .orderBy('wholeday');
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFFEF5ED),
          elevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                color: Color(0xFF72614E)),
            onPressed: () {
              Navigator.push( context, MaterialPageRoute(
                  builder: (context){
                    return HomePage();
                  }
              ));
            },
            color: Colors.white,
          ),
          title: Center(
            child: Padding(
              padding:  EdgeInsets.fromLTRB(0.0, 0.0, 50.0, 0.0),
              child:  Text("기억에 남는 순간",
                style: TextStyle(
                    fontSize: 23,
                    fontFamily: 'gangwon',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF72614E) ),),
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

          child: StreamBuilder<QuerySnapshot>(
            stream: postRef.snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              final yearCollections = snapshot.data?.docs ?? [];
              if(yearCollections.isEmpty)
                return Center(
                  child: Text("There is a no data."),
                );
              return ListView.builder(
                itemCount: yearCollections.length,
                itemBuilder: (BuildContext context, int index)  {
                  final yearCollection = yearCollections[index];
                  // Extract the names of subcollections
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 5, 0, 0),
                        child: Container(
                          width: 600,
                          child: Row(
                            children: [
                              Container(
                                height: 35,
                                width: 35,
                                child: IconButton(
                                  onPressed: ()async{
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('user')
                                            .doc(cn!.name)
                                            .collection('post')
                                            .doc(yearCollection.get('year').toString())
                                            .collection('month')
                                            .doc(yearCollection.get('month').toString())
                                            .collection('posted')
                                            .doc(yearCollection.id).update({
                                          'favorite' : false,
                                        });
                                        await FirebaseFirestore.instance
                                            .collection('user')
                                            .doc(cn!.name)
                                            .collection('favorite')
                                            .doc(yearCollection.id).delete();
                                        setState(() {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                                            return FavoritePage();
                                          }));
                                        });
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(e.toString())),
                                        );
                                      }
                                  },
                                  icon:  yearCollection.get('favorite')==true?Icon(Icons.star):Icon(Icons.star_border_outlined),
                                  iconSize: 28,
                                  color: Color(0xFF72614E),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 7, left: 8),
                                child: Text(
                                  yearCollection.get('Title').toString(),
                                  style: TextStyle(
                                    fontFamily: 'gangwon',
                                    color: Color(0xFF72614E),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 10, 0, 10),
                        child: Stack(
                            children:[
                              InkWell(
                                onTap: () {
                                  Navigator.push( context, MaterialPageRoute(
                                      builder: (context){
                                        return ArchiveDetail(detailed: yearCollection.id + "/" + yearCollection.get('year').toString() + "/" + yearCollection.get('month').toString() + "/" + yearCollection.get('day').toString());
                                      }
                                  ));
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    yearCollection.get('IMAGE'),
                                    height: 250.0,
                                    width: 370.0,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(17.0, 11, 0, 0),
                                child: Text(
                                  yearCollection.get('year').toString()+ '.' + yearCollection.get('month').toString().padLeft(2, '0') + '.' + yearCollection.get('day').toString().padLeft(2, '0'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'gangwon',
                                    fontSize: 21,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ]
                        ),
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
    );
  }
}
