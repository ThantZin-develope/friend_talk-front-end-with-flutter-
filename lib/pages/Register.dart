import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:my_app/commons/SystemAlert.dart';
import 'package:my_app/objects/SystemUser.dart';
import 'package:my_app/objects/User.dart';

import 'package:my_app/util/Route.dart' as route;
import 'package:my_app/services/UserServices.dart' as UserService;
import 'package:my_app/extensions/SystemExtensions.dart';

class Register extends StatefulWidget {
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  Gender gender = Gender.male;

  //bithDate
  DateTime birthDate;
  var stepActives = [];
  var stepStates = [];
  int currentStep = 0;
  // forkey for user name filling
  var stformKey = GlobalKey<FormState>();

  // formkey for login str and password
  var ndformKey = GlobalKey<FormState>();
  //text controller for user firstname and last name
  TextEditingController firstnameController = new TextEditingController();
  TextEditingController secondnameController = new TextEditingController();
  TextEditingController loginstrController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  bool showPassword = false;
  bool showpwSuffix = false;

  final FocusNode pwFocusnode = new FocusNode();
  @override
  void initState() {
    this.initialize();
    super.initState();
  }

  @override
  void dispose() {
    pwFocusnode.dispose();
    super.dispose();
  }

  goto(int step, {bool isTap = false}) {

    if (isTap) {
      if (stepStates[step] == StepState.complete) {
        if (_checkvalidation(step)) {
          setState(() {
            currentStep = step;
          });
        }
      }
    } else {
      setState(() {
        currentStep = step;
      });
    }
  }

  next(BuildContext context) {

    if (currentStep <= 2) {
      if (_checkvalidation(currentStep)) {
        goto(currentStep + 1);
      }
    } else {
      if (_checkvalidation(currentStep)) {
        this.showWorkingDialog(context);
      }
    }
  }

  showWorkingDialog(BuildContext context) async {
   

    try {
      SystemAlert.showMessagingAlert(context, "Working on it");

      User user = new User();
      user.birthDate = birthDate.changetoSystemStringDate();
     
      user.createdDate = DateTime.now().changetoSystemStringDate();
      user.updatedDate = DateTime.now().changetoSystemStringDate();
      user.gender = gender == Gender.female ? 0 : 1;
      user.userName =
          firstnameController.text + " " + secondnameController.text;
      user.suser = new SystemUser();
      user.suser.loginStr = loginstrController.text;
      user.suser.password = passwordController.text;

      user.suser.createdDate = DateTime.now().changetoSystemStringDate();
      user.suser.updatedDate = DateTime.now().changetoSystemStringDate();

      var response = await UserService.register(user, context);
      Navigator.of(context).pop();

      if (response != null ) {
        bool isClose =
            await SystemAlert.showAlert(2, response["message"], context);
        if (isClose) {
          Navigator.pop(context);
        }
      }
    } catch (error) {
   

     

      Navigator.of(context).pop();
      await SystemAlert.showAlert(0, error.toString(), context);
    }
  }

  bool _checkvalidation(int step) {
    if (step == 0) {
      if (stformKey.currentState.validate()) {
        setState(() {
          stepStates[step] = StepState.complete;

          stepActives[step + 1] = true;
        });
        return true;
      } else {
        setState(() {
          stepStates[step] = StepState.error;
        });

        return false;
      }
    } else if (step == 1) {
      if (birthDate != null) {
        setState(() {
          stepStates[step] = StepState.complete;
          stepActives[step + 1] = true;
        });

        return true;
      } else {
        setState(() {
          stepStates[step] = StepState.error;
        });

        return false;
      }
    } else if (step == 2) {
      setState(() {
        stepStates[step] = StepState.complete;
        stepActives[step + 1] = true;
      });

      return true;
    } else {
      if (ndformKey.currentState.validate()) {
        setState(() {
          stepStates[step] = StepState.complete;
        });

        return true;
      } else {
        setState(() {
          stepStates[step] = StepState.error;
        });

        return false;
      }
    }
  }

  back() {
    if (currentStep >= 1) {
      goto(currentStep - 1);
    }
  }

  void initialize() {
    this.pwFocusnode.addListener(() {
      if (pwFocusnode.hasPrimaryFocus) {
        setState(() {
          this.showpwSuffix = true;
        });
      } else {
        setState(() {
          this.showpwSuffix = false;
        });
      }
    });
    for (int i = 0; i < 4; i++) {
      if (i == 0) {
        stepActives.add(true);
        stepStates.add(StepState.indexed);
      }
      stepActives.add(false);
      stepStates.add(StepState.editing);
    }
  }

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  void showDatePicker(BuildContext context) {
   
    DatePicker.showDatePicker(context, maxTime: DateTime.now(),
        onConfirm: (date) {
      setState(() {
        this.birthDate = date;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Have Fun",
          style: TextStyle(color: Colors.green),
        ),
        automaticallyImplyLeading: false,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Card(
            child: Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stepper(
                controlsBuilder: (BuildContext context,
                    {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                  return Row(
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          next(context);
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
                      SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          back();
                        },
                        child: Text(
                          "Back",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            onPrimary: Colors.white,
                            primary: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ),
                    ],
                  );
                },
                physics: NeverScrollableScrollPhysics(),
                // onStepContinue: () => next(context),
                onStepTapped: (step) => goto(step, isTap: true),
                // onStepCancel: back,
                type: StepperType.vertical,
                currentStep: currentStep,
                steps: <Step>[
                  Step(
                    isActive: stepActives[0],
                    state: stepStates[0],
                    title: Text("Your Full Name"),
                    content: Form(
                      key: stformKey,
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            child: TextFormField(
                              controller: firstnameController,
                              decoration:
                                  InputDecoration(hintText: "First Name"),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Your First Name";
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            width: 25,
                          ),
                          Flexible(
                            child: TextFormField(
                              controller: secondnameController,
                              decoration:
                                  InputDecoration(hintText: "Last Name"),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Your Last Name";
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Step(
                    isActive: stepActives[1],
                    state: stepStates[1],
                    title: Text("Your BirthDate "),
                    content: InkWell(
                      onTap: () => showDatePicker(context),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        decoration:
                            BoxDecoration(border: Border(bottom: BorderSide())),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.calendar_today),
                            SizedBox(
                              width: 10,
                            ),
                            Text(birthDate == null
                                ? "Select BirthDate"
                                : DateFormat("yyyy-MM-dd").format(birthDate))
                          ],
                        ),
                      ),
                    ),
                  ),
                  Step(
                    state: stepStates[2],
                    isActive: stepActives[2],
                    title: Text("Gender"),
                    content: Row(
                      children: <Widget>[
                        Text("Male"),
                        Radio(
                          value: Gender.male,
                          groupValue: gender,
                          onChanged: (value) {
                            setState(() {
                              gender = value;
                            });
                          },
                        ),
                        SizedBox(width: 14),
                        Text("Female"),
                        Radio(
                          value: Gender.female,
                          groupValue: gender,
                          onChanged: (value) {
                            setState(() {
                              gender = value;
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  Step(
                      state: stepStates[3],
                      isActive: stepActives[3],
                      title: Text("Last Step"),
                      content: Form(
                        key: ndformKey,
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                controller: loginstrController,
                                decoration: InputDecoration(
                                    hintText: "Email or Phone No"),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Please Fill this";
                                  } else if (num.tryParse(value) != null) {
                                    if (value.length < 5) {
                                      return "Please Fill Valid Phone Number";
                                    } else {
                                      return null;
                                    }
                                  } else if (value.length > 0) {
                                    if (!RegExp(
                                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                        .hasMatch(value)) {
                                      return "Please Fill Valid Email";
                                    }
                                    return null;
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Container(
                              child: TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                focusNode: pwFocusnode,
                                controller: passwordController,
                                obscureText: !showPassword,
                                decoration: InputDecoration(
                                    hintText: "Password",
                                    suffixIcon: showpwSuffix
                                        ? IconButton(
                                            icon: Icon(Icons.remove_red_eye),
                                            onPressed: () {
                                              setState(() {
                                                this.showPassword =
                                                    !this.showPassword;
                                              });
                                            },
                                            color: showPassword
                                                ? Colors.blue
                                                : Colors.grey,
                                          )
                                        : null),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Please Fill this";
                                  } else if (value.length <= 5) {
                                    return "Too Weak Password";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum Gender { male, female }
