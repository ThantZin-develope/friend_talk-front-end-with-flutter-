import 'package:flutter/cupertino.dart';

class Test extends StatefulWidget{
  _TestState createState()=> _TestState();
}

class _TestState extends State<Test>{

  @override 
  Widget build(BuildContext context){
    return Container(child: Center(child: Text("Test Page Works"),),);
  }
}