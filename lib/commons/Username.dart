import 'package:ant_icons/ant_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SystemUsername extends StatelessWidget {
  String name;
  bool showBlueMark;
  bool isPrimaryProfileUsername;
  SystemUsername({
    Key key,
    @required this.name,
    @required this.showBlueMark,
    @required this.isPrimaryProfileUsername,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: this.isPrimaryProfileUsername
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: <Widget>[
        Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width *
                  (this.isPrimaryProfileUsername ? 0.4 : 0.6)),
          child: Text(
            this.name,
            style: TextStyle(
                fontSize: this.isPrimaryProfileUsername ? 20 : 15,
                fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          width: 7,
        ),
        if (this.showBlueMark)
          Icon(
            AntIcons.check_circle,
            color: Colors.blue,
            size: this.isPrimaryProfileUsername ? 25 : 18,
          )
      ],
    );
  }
}
