// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
import 'package:flutter/material.dart';
import '../login/login_page.dart';
import '../login/sign_up_page.dart';
import '../mainhome/home.dart';

// TODO: Convert ShrineApp to stateful widget (104)
class DailyStudioBlog extends StatelessWidget {
  const DailyStudioBlog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shrine',
      initialRoute: '/login',
      routes: {
        '/login': (BuildContext context) => LoginPage(),
        '/': (BuildContext context) => HomePage(),
        '/signup': (BuildContext context) =>  SignUpPage(),
      },
      // onGenerateRoute: (settings) {
      //   if (settings.name == '/detail') {
      //     final args = settings.arguments as String;
      //     return MaterialPageRoute(
      //       builder: (context) {
      //         return DetailPage(titled: args,);
      //       },
      //     );
      //   }
      // },
    );
  }
}

// TODO: Build a Shrine Theme (103)
// TODO: Build a Shrine Text Theme (103)
