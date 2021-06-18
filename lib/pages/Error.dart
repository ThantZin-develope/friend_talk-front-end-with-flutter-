import 'package:flutter/cupertino.dart';

class ErrorPage extends StatefulWidget{
  _ErrorState createState()=> _ErrorState();
}

class _ErrorState extends State<ErrorPage>{

  @override 
  Widget build(BuildContext context){
    return Container( 
      child: Center(child: Text("Error Page"),),
    );
  }
}