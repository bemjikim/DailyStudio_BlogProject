import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class ArchiveMonth extends StatefulWidget {
  final String selection;
  ArchiveMonth({required this.selection});
  @override
  _ArchiveMonthState createState() => _ArchiveMonthState();
}

class _ArchiveMonthState extends State<ArchiveMonth> {
  int _selectedIndex = 2;
  late List<String> dates;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/');
      }

      if (_selectedIndex == 2) {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/main_archive');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // widget 멤버에 접근하는 코드를 initState() 메서드로 이동
    dates = widget.selection.split('/');
  }

  @override
  Widget build(BuildContext context) {
    final currentUserProvider = Provider.of<CurrentUserModel>(context);
    final currentUsers = currentUserProvider.currentUsers;
    var cn = currentUsers.isNotEmpty ? currentUsers[0] : null;
    final years = dates[0];
    final month = dates[1];
    final postRef = FirebaseFirestore.instance
        .collection('user')
        .doc(cn!.name)
        .collection('post')
        .doc(years)
        .collection('month')
        .doc(month)
        .collection('posted').orderBy('day');
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.white,
          ),
          title: Center(
            child: Padding(
              padding:  EdgeInsets.fromLTRB(0.0, 0.0, 50.0, 0.0),
              child:  Text(month + "월의 기록", style: TextStyle(fontSize: 20, color: Colors.white ),),
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: postRef.snapshots(),
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
                // Extract the names of subcollections
                return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(35.0, 20, 0, 0),
                        child: Container(
                          width: 600,
                          child: Text(
                              yearCollection.get('Title').toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 10, 0, 0),
                        child: Stack(
                          children:[
                            Image.asset(
                              'assets/default.png',
                              height: 200.0,
                              width: 350.0,
                              fit: BoxFit.fill,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20.0, 10, 0, 0),
                              child: Text(
                                yearCollection.get('year').toString()+ '.' + yearCollection.get('month').toString() + '.' + yearCollection.get('day').toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
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