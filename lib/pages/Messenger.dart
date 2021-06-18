import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/commons/ProfieImage.dart';
import 'package:my_app/commons/SystemAlert.dart';
import 'package:my_app/commons/Username.dart';
import 'package:my_app/constants/UrlConstants.dart';
import 'package:my_app/objects/SystemMessage.dart';
import 'package:my_app/objects/User.dart';
import 'package:my_app/pages/MessageDetail.dart';
import 'package:my_app/services/MessageService.dart';
import 'package:my_app/services/UserServices.dart' as UserService;
import 'package:my_app/util/RequestApi.dart';
import 'package:my_app/util/SystemException.dart';

class Messenger extends StatefulWidget {
  final User currentUser;
  final String authToken;

  _MessengerState createState() => _MessengerState();
  const Messenger({Key key, this.currentUser, this.authToken})
      : super(key: key);
}

class _MessengerState extends State<Messenger> {
  List<User> users = [];
  bool hasInitialzie = false;
  String profileUrl;
  List<SystemMessage> lastMessages = [];
  @override
  void initState() {
    super.initState();
    this.initialzie();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  void initialzie() async {
    try {
      this.profileUrl =
          'http://' + UrlConstants.apiRequest + RequestApi.artifactId + "/api/profilePic?id=";
      var result = await UserService.getAllUsers(context);
      if (result == null) {
        throw new SystemException("System Exception Occurs");
      }
      for (var i = 0; i < result["data"].length; i++) {
        this.users.add(User.fromJSON(result["data"][i]));
      }
      this.users.removeWhere(
          (element) => element.user_id == widget.currentUser.user_id);
      hasInitialzie = true;
      _fetchLastMessage();
    } on SystemException catch (error) {} catch (error) {
      await SystemAlert.showAlert(0, error.toString(), context);
    }
  }

  _fetchLastMessage() async {
    try {
      this.lastMessages = [];
      var result = await SystemMessageService.getLastmessages(context);
      if (result == null) {
        throw new SystemException("Systemexception Occurs");
      }
      for (var i = 0; i < result["data"].length; i++) {
        this.lastMessages.add(SystemMessage.fromJSON(result["data"][i]));
      }
      
      setState(() {});
    } on SystemException catch (error) {} catch (error) {
      await SystemAlert.showAlert(0, error.toString(), context);
    }
  }

  _messagePrepare(User recipent) {

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MessengerDetail(
                  authToken: widget.authToken,
                  recipent: recipent,
                  sender: widget.currentUser,
                ))).then((value) => this._fetchLastMessage());
  }

  _getLastMessageSeen(User recipent) {
    String returnstr = 'No Conversation Yet';
    for (var i = 0; i < this.lastMessages.length; i++) {
      bool firstbool =
          widget.currentUser.user_id == this.lastMessages[i].sender.user_id &&
              recipent.user_id == this.lastMessages[i].recipent.user_id;
      bool secondbool =
          widget.currentUser.user_id == this.lastMessages[i].recipent.user_id &&
              recipent.user_id == this.lastMessages[i].sender.user_id;

      if (firstbool || secondbool) {
        if (this.lastMessages[i].sender.user_id == widget.currentUser.user_id) {
          returnstr = "You : " + this.lastMessages[i].message;
        } else {
          returnstr = this.lastMessages[i].message;
        }

        break;
      }
    }

    return returnstr;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 7, top: 7, bottom: 7),
            child: Text(
              "Your Chats",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          if (!hasInitialzie)
            Expanded(
              child: Center(
                child: Text("Initializing"),
              ),
            ),
          if (hasInitialzie)
            Container(
                height: 125,
                child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          this._messagePrepare(this.users[index]);
                        },
                        child: Card(
                            child: Container(
                          padding: EdgeInsets.all(7),
                          width: 100,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              ProfileImage(
                                auth_token: widget.authToken,
                                profileUrl: this.profileUrl +
                                    users[index].user_id.toString(),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                this
                                            .users[index]
                                            .userName
                                            .substring(
                                                0,
                                                this
                                                    .users[index]
                                                    .userName
                                                    .indexOf(" "))
                                            .length >
                                        10
                                    ? this.users[index].userName.substring(0, 5)
                                    : this.users[index].userName.substring(
                                        0,
                                        this
                                            .users[index]
                                            .userName
                                            .indexOf(" ")),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        )),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(width: 0.5);
                    },
                    itemCount: this.users.length)),
          if (hasInitialzie)
            Expanded(
              child: ListView.separated(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        this._messagePrepare(this.users[index]);
                      },
                      child: Container(
                        padding: EdgeInsets.all(5),
                        width: double.infinity,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ProfileImage(
                              auth_token: widget.authToken,
                              profileUrl: this.profileUrl +
                                  users[index].user_id.toString(),
                              valueKey: new Random().nextInt(100),
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SystemUsername(
                                    name: this.users[index].userName,
                                    showBlueMark: this.users[index].role > 0
                                        ? true
                                        : false,
                                    isPrimaryProfileUsername: false),
                                SizedBox(
                                  height: 3,
                                ),
                                Text(_getLastMessageSeen(this.users[index]))
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: 5,
                    );
                  },
                  itemCount: this.users.length),
            ),
        ],
      ),
    );
  }
}
