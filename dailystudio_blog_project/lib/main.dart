
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailystudio_blog_project/route/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CurrentUserModel(),
      child: MaterialApp(
          title: 'Namer App',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: DailyStudioBlog(),
        ),
    );
  }
}

class CurrentUser {
  final String name;

  CurrentUser({
    required this.name,
  });
}

class CurrentUserModel extends ChangeNotifier {
  final List<CurrentUser> _currentUser = [];

  List<CurrentUser> get currentUsers => _currentUser;
  
  void adduser(CurrentUser name)
  {
    _currentUser.add(name);
    notifyListeners();
  }
  void removeUser(CurrentUser name) {
    _currentUser.remove(name);
    notifyListeners();
  }
}
