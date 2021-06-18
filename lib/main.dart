import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/objects/User.dart';
import 'package:my_app/pages/DashBoard.dart';
import 'package:my_app/pages/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:my_app/util/Route.dart' as route;

import 'Streams/TestStream.dart';

void main() {
  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool hasToken;
  User currentUser;
  String authToken;
  SharedPreferences preferences;
  @override
  void initState() {
    super.initState();
    this.initialize();
  }

  void initialize() async {
    print("Initializing");
    this.preferences = await SharedPreferences.getInstance();
    this.authToken = preferences.getString("auth_token");
    print("token => ");

    if (this.authToken != null) {
      this.currentUser =
          User.fromJSON(json.decode(preferences.getString("user_data")));

      this.hasToken = true;
    } else {
      this.hasToken = false;
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    stompClient.deactivate();
    notistreamController.close();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: route.generateRoute,
      routes: {
        '/': (context) => hasToken == null
            ? Container(
                color: Colors.white,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: DefaultTextStyle(
                    style: TextStyle(fontSize: 30, color: Colors.black),
                    child: AnimatedTextKit(
                      animatedTexts: <AnimatedText>[
                        WavyAnimatedText("Loading ...")
                      ],
                    ),
                  ),
                ),
              )
            : hasToken
                ? Dashboard(
                    currentUser: this.currentUser,
                    authToken: this.authToken,
                    preferences: this.preferences,
                  )
                : Login()
      },
      title: "T_App",
      theme: ThemeData(
          primaryColor: Colors.lightBlue,
          dividerColor: Colors.grey,
          disabledColor: Colors.grey,
          backgroundColor: Colors.grey,
          cardColor: Colors.white,
          textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme)),
    );
  }
}



// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);


//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//   String testData = '';
//   @override 
//   void initState(){
//     super.initState();
//     initialTestingMode();
//     stompClient.activate();
//   }

//  Future<void> initialTestingMode() async {
//         this.testData = await this.test();
//    setState((){});

//   }
  

//   Future<String> test() async{
//     try{
// var response = await http.get(Uri.http('192.168.1.173:8282', "/systemuser/test") , headers: {'Content-Type' : 'application/Json'} );

// if(response.statusCode == 200 || response.statusCode == 201){

// var result = json.decode(response.body)["data"];

// return result;

// }
// return '';
//     }catch(error){
//       print(error);
//       return '';
//     }
//   }

//   void _incrementCounter() {
//     stompClient.send(destination: '/app/one-to-many', body: '{"message":"test" , "sender_id":1 , "recipent_id":1}', headers: {'Authorization' : '44a1f9b5-704e-4cbc-8e91-f9392f8f5de2'});
//   }

//   @override
//   Widget build(BuildContext context) {
 
//     return Scaffold(
//       appBar: AppBar(

//         title: Text(widget.title),
//       ),
//       body: Center(
  
//         child: Column(
      
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               testData,
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }

