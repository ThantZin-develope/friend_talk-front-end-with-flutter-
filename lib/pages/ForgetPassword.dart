import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ForgetPassword extends StatefulWidget {
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  int step = 0;
  _stepper() {
    if (step == 0) {
      return TextField(
        maxLines: 1,
        decoration: InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          hintText: "Email or Phone No",
        ),
      );
    }
    if (step == 1) {
      return TextField(
        maxLines: 1,
        decoration: InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          hintText: "Enter Code",
        ),
      );
    }
    if (step == 2) {
      return TextField(
          maxLines: 1,
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            hintText: "New Password",
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Forget Password",
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _stepper(),
                        SizedBox(
                          height: 10,
                        ),
                        if (step == 2)
                          TextField(
                              maxLines: 1,
                              decoration: InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                                hintText: "Confirm Password",
                              )),
                        SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              this.step++;
                            });
                          },
                          child: Text(
                            "Next",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              onPrimary: Colors.white,
                              primary: Colors.green,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ],
                    ),
                  ),
                ))));
  }
}
