import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/constants/SystemIcons.dart';

class SystemAlert {
  // status 0 error 1 info 2 success
  static Future<dynamic> showAlert(
      int status, String message, context) async {
    // Timer timer;
    Widget closeBtn;
    Widget title;
    Widget body;
    switch (status) {
      case 0:
        {
          closeBtn = ElevatedButton(
              onPressed: () => {
                    Navigator.of(context).pop(true),
                  },
              child: Text(
                "Close",
                style: TextStyle(color: Colors.black),
              ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.grey;
                  } else {
                    return Colors.white;
                  }
                }),
              ));
          title = Row(
            children: <Widget>[
              SystemIcons.errorIcon,
              SizedBox(
                width: 10,
              ),
              Text("Error")
            ],
          );
          body = Text(message);
          break;
        }
      case 1:
        {
          closeBtn = ElevatedButton(
            onPressed: () => {Navigator.of(context).pop(true)},
            child: Text(
              "Close",
              style: TextStyle(color: Colors.black),
            ),
            style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.grey;
              } else {
                return Colors.white;
              }
            })),
          );
          title = Row(
            children: <Widget>[
              SystemIcons.infoIcon,
              SizedBox(
                width: 20,
              ),
              Text("Info"),
            ],
          );
          body = Text(message);
          break;
        }
      case 2:
        {
          closeBtn = ElevatedButton(
            onPressed: () => {Navigator.of(context).pop(true)},
            child: Text(
              "Close",
              style: TextStyle(color: Colors.black),
            ),
            style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.grey;
              } else {
                return Colors.white;
              }
            })),
          );
          title = Row(
            children: <Widget>[
              SystemIcons.successIcon,
              SizedBox(
                width: 20,
              ),
              Text("Success"),
            ],
          );
          body = Text(message);
          break;
        }
      default:
        {
          title = Text("Notification");
          closeBtn = ElevatedButton(
            onPressed: () => {Navigator.of(context).pop(true)},
            child: Text(
              "Close",
              style: TextStyle(color: Colors.black),
            ),
            style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.grey;
              } else {
                return Colors.white;
              }
            })),
          );
          body = Text(message);
          // timer = new Timer(Duration(seconds: 2), () {
          //   Navigator.of(context).pop(true);
          // });
          break;
        }
    }

    AlertDialog alert = new AlertDialog(
      title: title,
      content: body,
      actions: [closeBtn],
    );

    bool isClose = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return alert;
        });
    return isClose;
  }

  static Future<dynamic> showMessagingAlert(
      BuildContext context, String message) async {
    AlertDialog alert = AlertDialog(
      content: Container(
        height: 100,
        child: Center(
            child: Text(message),
        ),
      ),
    );

    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return alert;
        });
  }
}
