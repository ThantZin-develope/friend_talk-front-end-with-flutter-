import 'dart:async';

import 'package:ant_icons/ant_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/commons/SystemAlert.dart';
import 'package:my_app/objects/User.dart';
import 'package:my_app/services/SystemUserService.dart';
import 'package:my_app/util/SystemException.dart';

class ModifyPage extends StatefulWidget {
  final String header;
  final User currentUser;
  final String authToken;
  final int operationType;
  // 1 change screen 2 stickyNote 3 update profile
  ModifyPage(
      {Key key,
      @required this.header,
      @required this.currentUser,
      @required this.authToken,
      @required this.operationType})
      : super(key: key);
  _ModifyPageState createState() => _ModifyPageState();
}

class _ModifyPageState extends State<ModifyPage> {
  TextEditingController oldPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  TextEditingController stickyNotesController = TextEditingController();
  bool showOldPassword = false;
  bool shownewPassword = false;
  bool showconfirmPassword = false;
  final _passwordChangeForm = new GlobalKey<FormState>();

  _changePassword() async {
    try {
      if (_passwordChangeForm.currentState.validate()) {
        var result = await SystemUserService.changePassowrd(
            widget.currentUser.user_id.toString(),
            oldPassword.text,
            newPassword.text,
            context);
        if (result == null) {
          throw new SystemException("SystemException Occurs");
        }
        bool isClose =
            await SystemAlert.showAlert(2, result["message"], context);
        if (isClose) {
          Navigator.pop(context);
        }
      }
    } on SystemException catch (error) {} catch (error) {
      await SystemAlert.showAlert(0, error.toString(), context);
    }
  }

  Widget _returnBody() {
    if (widget.operationType == 1) {
      return Center(
          child: Card(
        child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            padding: EdgeInsets.all(10),
            child: Form(
              key: _passwordChangeForm,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Please Enter Old Password";
                      } else {
                        return null;
                      }
                    },
                    controller: oldPassword,
                    maxLines: 1,
                    obscureText: !showOldPassword,
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          constraints: BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              showOldPassword = !showOldPassword;
                            });
                          },
                          icon: Icon(
                            showOldPassword
                                ? AntIcons.eye_invisible
                                : AntIcons.eye,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                        isDense: true,
                        hintText: "Old Password"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Please Enter New Password";
                      } else if (value.length < 5) {
                        return "Please Enter Strong Password";
                      } else {
                        return null;
                      }
                    },
                    controller: newPassword,
                    maxLines: 1,
                    obscureText: !shownewPassword,
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          constraints: BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              shownewPassword = !shownewPassword;
                            });
                          },
                          icon: Icon(
                            shownewPassword
                                ? AntIcons.eye_invisible
                                : AntIcons.eye,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                        isDense: true,
                        hintText: "New Password"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: confirmPassword,
                    validator: (value) {
                      if (value.isEmpty) {
                        return "Please Enter Confirm Password";
                      } else if (value != newPassword.text) {
                        return "Password Not Match";
                      } else {
                        return null;
                      }
                    },
                    maxLines: 1,
                    obscureText: !showconfirmPassword,
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          constraints: BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              showconfirmPassword = !showconfirmPassword;
                            });
                          },
                          icon: Icon(
                            showconfirmPassword
                                ? AntIcons.eye_invisible
                                : AntIcons.eye,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                        isDense: true,
                        hintText: "Password Confirm"),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _changePassword();
                    },
                    child: Text(
                      "Confirm",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.fromLTRB(3, 2, 3, 2),
                        onPrimary: Colors.white,
                        primary: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ],
              ),
            )),
      ));
    }
    if (widget.operationType == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            new DateFormat("dd-MM-yyyy//HH:mm:ss").format(DateTime.now()),
          ),
          SizedBox(
            height: 7,
          ),
          TextField(
            autofocus: true,
            controller: stickyNotesController,
            maxLines: null,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderSide: BorderSide.none),
              isDense: true,
            ),
          )
        ],
      );
    }
  }

  @override
  void initState() {
    super.initState();
    this.initialize();
  }

  Timer timer;
  void initialize() {
    if (widget.operationType == 2) {
   
      if (widget.currentUser.stickyNotes != null) {
        stickyNotesController.text = widget.currentUser.stickyNotes;
      }
      timer = Timer.periodic(Duration(seconds: 5), (timer) {

        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
    timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Row(
            children: <Widget>[
              IconButton(
                  icon: Icon(AntIcons.arrow_left),
                  onPressed: () {
                    if (widget.operationType == 2) {
                      Navigator.pop(context, stickyNotesController.text);
                    } else {
                      Navigator.pop(context);
                    }
                  }),
              Text(widget.header)
            ],
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.fromLTRB(
              10, 10, 10, MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: GestureDetector(
              onTap: () {
               
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                
                  currentFocus.unfocus();
                }
              },
              child: Container(
                child: _returnBody(),
              ),
            ),
          ),
        ));
  }
}
