import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:my_app/commons/SystemAlert.dart';
import 'package:my_app/objects/SystemUser.dart';
import 'package:my_app/pages/Register.dart';
import 'package:my_app/util/Route.dart' as route;
import 'package:my_app/services/UserServices.dart' as UserService;
import 'package:my_app/util/SystemException.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // form key for login str and password
  final _formKey = GlobalKey<FormState>();
  // text editing controllers
  final TextEditingController loginstrController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  // focus nodes of textediting controllers
  final FocusNode firstNode = new FocusNode();
  final FocusNode secondNode = new FocusNode();
  // show cross suffix icon of login str textfield
  bool showfirstSuf = false;
  // show password[makes obsecure text false]
  bool showPassword = false;
  // show pwicon
  bool showpwSuf = false;
  // loading button controller of login button
  bool islogingin = false;
  // loading button controller of accnewcreate button
  bool isnewaccCreate = false;
  @override
  void initState() {
    this.initialize();
    super.initState();
  }

  void initialize() {
    firstNode.addListener(() {
      setState(() {
        if (firstNode.hasFocus) {
          this.showfirstSuf = true;
        } else {
          this.showfirstSuf = false;
        }
      });
    });

    secondNode.addListener(() {
      setState(() {
        if (secondNode.hasFocus) {
          this.showpwSuf = true;
        } else {
          this.showpwSuf = false;
        }
      });
    });
  }

  void login() async {
    try {
      if (this._formKey.currentState.validate()) {
        SystemUser suser = new SystemUser();
        suser.loginStr = loginstrController.text;
        suser.password = passwordController.text;
        var result = await UserService.login(suser, context);
        if (result != null) {
          SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          sharedPreferences.setString(
              "auth_token", result["data"]["auth_token"]);
          sharedPreferences.setString(
              "user_data", jsonEncode(result["data"]["user_data"]));
        
            Phoenix.rebirth(context);
        
        } else {
          throw new SystemException("Response Return Null");
        }
      }
    } on SystemException catch (error) {} catch (error) {
      await SystemAlert.showAlert(0, error, context);
    }
  }

  void forgetPassword() {
    Navigator.pushNamed(context, route.ForgetPasswordRoute);
  }

  void createNewAccount() {
    setState(() {
      this.isnewaccCreate = true;
    });
    Navigator.pushNamed(context, route.RegisterRoute)
        .then((value) => setState(() {
              this.isnewaccCreate = false;
            }));
  }

  @override
  void dispose() {
    print("Login disposed");
    firstNode.dispose();
    this.islogingin = false;
    this.isnewaccCreate = false;
    super.dispose();
  }

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      color: Colors.grey,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Stack(alignment: Alignment.center, children: <Widget>[
            Container(
              //  height: double.infinity,
              //  width: double.infinity,
              alignment: Alignment.center,
              child: Image.asset(
                "assets/logincover.png",
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                // fit: BoxFit.contain,
              ),
            ),
            Center(
              child: Card(
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 15, 20, 5),
                  // color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 75,
                        height: 75,
                      ),
                      // SizedBox(
                      //   height: 5,
                      // ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              focusNode: firstNode,
                              controller: loginstrController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  hintStyle: TextStyle(color: Colors.grey),
                                  hintText: "Email or Phone No.",
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white)),
                                  suffixIcon: showfirstSuf
                                      ? IconButton(
                                          color: Colors.black,
                                          iconSize: 20,
                                          icon: Icon(Icons.clear),
                                          onPressed: () {
                                            setState(() {
                                              this.loginstrController.clear();
                                            });
                                          })
                                      : null),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please Enter Email of Phone";
                                } else {
                                  return null;
                                }
                              },
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            TextFormField(
                              focusNode: secondNode,
                              controller: passwordController,
                              obscureText: !showPassword,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white)),
                                  hintStyle: TextStyle(color: Colors.grey),
                                  hintText: "Password",
                                  suffixIcon: showpwSuf
                                      ? IconButton(
                                          iconSize: 20,
                                          icon: Icon(Icons.remove_red_eye),
                                          color: showPassword
                                              ? Colors.white
                                              : Colors.black,
                                          onPressed: () {
                                            setState(() {
                                              this.showPassword =
                                                  !this.showPassword;
                                            });
                                          })
                                      : null),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please Enter Password";
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      islogingin
                          ? Container(
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : FractionallySizedBox(
                              widthFactor: 1,
                              child: ElevatedButton(
                                  onPressed: () {
                                    this.login();
                                  },
                                  child: Text("Login",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ))),
                            ),
                      TextButton(
                          onPressed: () {
                            this.forgetPassword();
                          },
                          child: Text("Forget Password?")),
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: Container(
                                  child: Divider(
                            color: Colors.black,
                          ))),
                          Text("OR"),
                          Expanded(
                              child: Container(
                                  child: Divider(
                            color: Colors.black,
                          )))
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      isnewaccCreate
                          ? Container(
                              child: Center(
                                  child: CircularProgressIndicator(
                              backgroundColor: Colors.green,
                            )))
                          : FractionallySizedBox(
                              widthFactor: 0.8,
                              child: ElevatedButton(
                                style: ButtonStyle(backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                        (states) {
                                  return Colors.green;
                                })),
                                onPressed: () {
                                  this.createNewAccount();
                                },
                                child: Text(
                                  "Or Create New Account",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
