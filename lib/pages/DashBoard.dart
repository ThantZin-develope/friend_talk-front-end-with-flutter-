import 'package:ant_icons/ant_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:my_app/Streams/TestStream.dart';
import 'package:my_app/commons/SystemAlert.dart';
import 'package:my_app/objects/SystemMessage.dart';
import 'package:my_app/objects/SystemNoti.dart';
import 'package:my_app/services/UserServices.dart' as UserService;
import 'package:my_app/objects/User.dart';
import 'package:my_app/pages/Home.dart';
import 'package:my_app/pages/Messenger.dart';
import 'package:my_app/pages/ModifyPage.dart';
import 'package:my_app/pages/Notification.dart';
import 'package:my_app/pages/Profile.dart';
import 'package:my_app/pages/Reports.dart';
import 'package:my_app/Streams/TestStream.dart' as systemWebSocket;
import 'package:my_app/util/RequestApi.dart';
import 'package:my_app/util/SystemException.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class Dashboard extends StatefulWidget {
  _DashboardState createState() => _DashboardState();
  final User currentUser;
  final String authToken;
  final SharedPreferences preferences;
  Dashboard({Key key, this.currentUser, this.authToken, this.preferences})
      : super(key: key);
}

class _DashboardState extends State<Dashboard> {
  bool isAdmin = false;
  int noofhomenoti = 0;
  int noofreportnoti = 0;
  int noofnotinoti = 0;
  int noofmsgnoti = 0;
  var taps = [true, false, false, false, false];
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  int currenttab = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    this.initialize();
  }

  void initialize() {
    buildListeners();

    if (widget.currentUser.role == 0) {
      this.taps.removeLast();
    } else {
      this.isAdmin = true;
    }

    systemWebSocket.currentUserWS = widget.currentUser;

    systemWebSocket.stompClient = StompClient(
      config: StompConfig(
          url: webSocketEndPoint,
          onConnect: systemWebSocket.onConnect,
          stompConnectHeaders: {'Authorization': "Bearer " + widget.authToken},
          onWebSocketError: (dynamic frame) {
            onWebSocketError();
          },
          webSocketConnectHeaders: {
            'Authorization': "Bearer " + widget.authToken
          }),
    );
    systemWebSocket.stompClient.activate();
  }

  onWebSocketError() async {
    bool isClose = await SystemAlert.showAlert(0, "Technical Error!", context);
  }

  buildListeners() {
    messagestreamController.stream.listen((event) {
      SystemMessage message = event;

      if (message.recipent.user_id == widget.currentUser.user_id) {
        if (!isAdmin && currenttab != 2) {
          setState(() {
            this.noofmsgnoti++;
          });
        }
        if (isAdmin && currenttab != 3) {
          setState(() {
            this.noofmsgnoti++;
          });
        }
      }
    });
    notistreamController.stream.listen((event) {
      SystemNoti result = event;
      print("Recieveing NotiMesage");
      // when another use post then notitype is 0 and show every one except postowner
      if (result.noti_type == 0 &&
          widget.currentUser.user_id != result.post.owner.user_id) {
        if (!isAdmin && currenttab != 1) {
          this.noofnotinoti++;
        }
        if (currenttab != 0) {
          this.noofhomenoti++;
        }
        if (isAdmin && currenttab != 2) {
          this.noofnotinoti++;
        }
      }
      if (result.noti_type != 0 &&
          widget.currentUser.user_id == result.post.owner.user_id) {
        if (!isAdmin && currenttab != 1) {
          this.noofnotinoti++;
        }
        if (isAdmin && currenttab != 2) {
          this.noofnotinoti++;
        }
      }
      setState(() {});
    });
  }

  colorStateChange(int step) {
    for (int i = 0; i < taps.length; i++) {
      if (step == i) {
        taps[i] = true;
      } else {
        taps[i] = false;
      }
    }
  }

  onTap(int tab) {
    currenttab = tab;
    this.colorStateChange(tab);
    if (tab == 0) {
      this.noofhomenoti = 0;
    }
    if (isAdmin) {
      if (tab == 1) {
        this.noofreportnoti = 0;
      } else if (tab == 2) {
        this.noofnotinoti = 0;
      } else if (tab == 3) {
        this.noofmsgnoti = 0;
      } else {}
    } else {
      if (tab == 1) {
        this.noofnotinoti = 0;
      } else if (tab == 2) {
        this.noofmsgnoti = 0;
      } else {}
    }

    setState(() {});
  }

  _logout(BuildContext context) async {
    print("logint out");
    await RequestApi.logout(
        "/api/logout", context, widget.currentUser.toJSON());
    widget.preferences.clear();
    Phoenix.rebirth(context);
  }

  _stickyWrite(String stickyNotes) async {
    widget.currentUser.stickyNotes = stickyNotes;
    await UserService.stickyWrite(widget.currentUser, context);
  }

  _accDelete() async {
    try {
      var result =
          await UserService.userModify(widget.currentUser, context, "3");
      if (result == null) {
        throw new SystemException("SystemException Occurs");
      }
      bool isClose = await SystemAlert.showAlert(2, result["message"], context);
      if (isClose) {
        _logout(context);
      }
    } on SystemException catch (error) {} catch (error) {
      await SystemAlert.showAlert(0, error.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: isAdmin ? 5 : 4,
      child: Scaffold(
          key: this._scaffoldKey,
          endDrawer: Drawer(
              child: SingleChildScrollView(
                  child: Container(
            padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ModifyPage(
                                header: "Your Sticky Notes",
                                currentUser: widget.currentUser,
                                authToken: widget.authToken,
                                operationType: 2))).then((value) {
                      if (value != null) {
                        _stickyWrite(value);
                      }
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(AntIcons.book),
                        SizedBox(
                          width: 10,
                        ),
                        Text("Your Sticky Notes"),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(AntIcons.edit),
                        SizedBox(
                          width: 10,
                        ),
                        Text("Update Profiel Details"),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ModifyPage(
                                header: "Change password",
                                currentUser: widget.currentUser,
                                authToken: widget.authToken,
                                operationType: 1)));
                  },
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(AntIcons.setting),
                        SizedBox(
                          width: 10,
                        ),
                        Text("Change password"),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    _accDelete();
                  },
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(AntIcons.delete),
                        SizedBox(
                          width: 10,
                        ),
                        Text("Delete this account"),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    _logout(context);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(AntIcons.logout_outline),
                        SizedBox(
                          width: 10,
                        ),
                        Text("Log out"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ))),
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              "fritalk",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent),
            ),
            bottom: TabBar(
              onTap: (tab) => onTap(tab),
              tabs: <Tab>[
                Tab(
                  child: Stack(
                    children: <Widget>[
                      Icon(
                        taps[0] ? AntIcons.home : AntIcons.home_outline,
                        color: taps[0] ? Colors.blueAccent : Colors.black,
                        size: 27,
                      ),
                      if (noofhomenoti > 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              noofhomenoti > 99
                                  ? "99+"
                                  : noofhomenoti.toString(),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 8),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
                if (isAdmin)
                  Tab(
                    icon: Stack(
                      children: <Widget>[
                        Icon(
                          taps[1]
                              ? AntIcons.database
                              : AntIcons.database_outline,
                          color: taps[1] ? Colors.blueAccent : Colors.black,
                          size: 27,
                        ),
                        if (noofreportnoti > 0)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Text(
                                noofreportnoti > 99
                                    ? "99+"
                                    : noofreportnoti.toString(),
                                style:
                                    TextStyle(color: Colors.white, fontSize: 8),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                Tab(
                  icon: Stack(
                    children: <Widget>[
                      Icon(
                        taps[isAdmin ? 2 : 1]
                            ? AntIcons.notification
                            : AntIcons.notification_outline,
                        color: taps[isAdmin ? 2 : 1]
                            ? Colors.blueAccent
                            : Colors.black,
                        size: 27,
                      ),
                      if (noofnotinoti > 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              noofnotinoti > 99
                                  ? "99+"
                                  : noofnotinoti.toString(),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 8),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
                Tab(
                  icon: Stack(
                    children: <Widget>[
                      Icon(
                        taps[isAdmin ? 3 : 2]
                            ? AntIcons.message
                            : AntIcons.message_outline,
                        color: taps[isAdmin ? 3 : 2]
                            ? Colors.blueAccent
                            : Colors.black,
                        size: 27,
                      ),
                      if (noofmsgnoti > 0)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              noofmsgnoti > 99 ? "99+" : noofmsgnoti.toString(),
                              style:
                                  TextStyle(color: Colors.white, fontSize: 8),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
                Tab(
                  icon: Icon(
                    taps[isAdmin ? 4 : 3]
                        ? AntIcons.profile
                        : AntIcons.profile_outline,
                    size: 27,
                    color: taps[isAdmin ? 4 : 3]
                        ? Colors.blueAccent
                        : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          body: Container(
            child: TabBarView(
              children: <Widget>[
                Home(
                  currentUser: widget.currentUser,
                  authToken: widget.authToken,
                ),
                if (isAdmin) Report(),
                SystemNotification(
                  currentUser: widget.currentUser,
                  authToken: widget.authToken,
                ),
                Messenger(
                    currentUser: widget.currentUser,
                    authToken: widget.authToken),
                Profile(
                    profileOwner: widget.currentUser,
                    currentUser: widget.currentUser,
                    authToken: widget.authToken),
              ],
            ),
          )
          // )
          //   ],
          // ),
          ),
    );
  }
}
