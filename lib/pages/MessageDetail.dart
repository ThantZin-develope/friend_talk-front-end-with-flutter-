import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/Streams/TestStream.dart';
import 'package:my_app/commons/ProfieImage.dart';
import 'package:my_app/commons/SkeletonContainer.dart';
import 'package:my_app/commons/SystemAlert.dart';
import 'package:my_app/commons/Username.dart';
import 'package:my_app/constants/UrlConstants.dart';
import 'package:my_app/objects/SystemMessage.dart';
import 'package:my_app/objects/User.dart';
import 'package:my_app/pages/Messenger.dart';
import 'package:my_app/extensions/SystemExtensions.dart';
import 'package:my_app/pages/Profile.dart';
import 'package:my_app/services/MessageService.dart';
import 'package:my_app/util/RequestApi.dart';
import 'package:my_app/util/SystemException.dart';

class MessengerDetail extends StatefulWidget {
  String authToken;
  User recipent;
  User sender;
  MessengerDetail({Key key, this.authToken, this.recipent, this.sender})
      : super(key: key);
  _MessengerDetailState createState() => _MessengerDetailState();
}

class _MessengerDetailState extends State<MessengerDetail> {
  String recipentprofileUrl;
  String senderprofileUrl;
  List<SystemMessage> messages = [];
  bool hasinitialize = false;
  ScrollController sccontroller = new ScrollController();
  ScrollController fakesccontroller = new ScrollController();
  TextEditingController messageController = new TextEditingController();
  bool ismessageloadingshow = false;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    this.initialize();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();

  // }

  void initialize() async {
    try {
      messagestreamController.stream.listen((event) {
        onMessageRecieved(event);
      });
      this.recipentprofileUrl = 'http://' +
          UrlConstants.apiRequest +
          RequestApi.artifactId +
          "/api/profilePic?id=" +
          widget.recipent.user_id.toString();
      this.senderprofileUrl = 'http://' +
          UrlConstants.apiRequest +
          RequestApi.artifactId +
          "/api/profilePic?id=" +
          widget.sender.user_id.toString();
      var result = await SystemMessageService.getOldMessages(
          widget.sender.user_id.toString(),
          widget.recipent.user_id.toString(),
          context);
      if (result == null) {
        throw new SystemException("SytemException Occurs");
      }
      for (var i = 0; i < result["data"].length; i++) {
        this.messages.add(SystemMessage.fromJSON(result["data"][i]));
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (fakesccontroller.hasClients) {
          fakesccontroller.jumpTo(fakesccontroller.position.maxScrollExtent);
        }
        if (sccontroller.hasClients) {
          sccontroller.jumpTo(sccontroller.position.maxScrollExtent);
        }
      });

      setState(() {
        hasinitialize = true;
      });
    } on SystemException catch (error) {} catch (error) {
      await SystemAlert.showAlert(0, error.toString(), context);
    }
  }

  onMessageRecieved(dynamic data) {
    SystemMessage message = data;


    if (message.sender.user_id == widget.sender.user_id) {
      this.ismessageloadingshow = false;
      this.messages.last = message;
    } else {
      this.messages.add(message);
    }

    setState(() {});
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

  Widget _messagebody() {
    if (!hasinitialize) {
      return ListView.separated(
          controller: fakesccontroller,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return index.isOdd
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SkeletonContainer(
                        width: 50,
                        height: 50,
                        radius: 25,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SkeletonContainer(
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: 20,
                            radius: 20,
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          SkeletonContainer(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 20,
                            radius: 20,
                          ),
                        ],
                      )
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          SkeletonContainer(
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: 20,
                            radius: 20,
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          SkeletonContainer(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 20,
                            radius: 20,
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      SkeletonContainer(
                        width: 50,
                        height: 50,
                        radius: 25,
                      ),
                    ],
                  );
          },
          separatorBuilder: (context, index) {
            return SizedBox(
              height: 7,
            );
          },
          itemCount: 15);
    }

    if (hasinitialize && this.messages.length == 0) {
      return Center(
        child: Text("Make a conversateion with " +
            (widget.recipent.gender == 0 ? "her" : "him")),
      );
    }

    if (hasinitialize && this.messages.length > 0) {
      return ListView.separated(
          scrollDirection: Axis.vertical,
          physics: ClampingScrollPhysics(),
          controller: sccontroller,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
           
            return this.messages[index].sender.user_id ==
                    widget.recipent.user_id
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      messageRepeation(this.messages[index].sender, index)
                          ? ProfileImage(
                              width: 35,
                              height: 35,
                              radius: 20,
                              auth_token: widget.authToken,
                              profileUrl: this.recipentprofileUrl)
                          : SizedBox(
                              width: 35,
                            ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6),
                        padding: EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey[300],
                        ),
                        child: Text(this.messages[index].message),
                      )
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      if (ismessageLoading(this.messages[index]))
                        Padding(
                          padding: EdgeInsets.only(right: 7),
                          child: Text("Sending"),
                        ),
                      Container(
                        padding: EdgeInsets.all(7),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.green),
                        child: Text(
                          this.messages[index].message,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      // this.messageRepeation(this.messages[index].sender, index)
                      //     ? ProfileImage(
                      //         width: 35,
                      //         height: 35,
                      //         radius: 20,
                      //         auth_token: widget.authToken,
                      //         profileUrl: this.senderprofileUrl)
                      //     : SizedBox(
                      //         width: 35,
                      //       )
                    ],
                  );
          },
          separatorBuilder: (BuildContext context, int indexx) {
            return SizedBox(
              height: 3,
            );
          },
          itemCount: this.messages.length);
    }
  }

  bool ismessageLoading(SystemMessage message) {
    if (message == this.messages.last && this.ismessageloadingshow) {
      return true;
    }
    return false;
  }

  _send() async {
    if (messageController.text.isNotEmpty) {
      SystemMessage message = new SystemMessage();
      message.sender = widget.sender;
      message.recipent = widget.recipent;
      message.message = messageController.text;
      message.created_id = widget.sender.user_id;
      message.updated_id = widget.sender.user_id;
      message.created_date = DateTime.now().changetoSystemStringDate();
      message.updated_date = DateTime.now().changetoSystemStringDate();

      ismessageloadingshow = true;
      this.messages.add(message);
      messageController.clear();
      setState(() {});
      try {
        messageSend(widget.authToken, message.toJSON());
      } catch (error) {
        messageSend(widget.authToken, message.toJSON());
      }
    }
  }

  bool messageRepeation(User user, int i) {
 
    //decide wheter is it last message if last message show imageicon in row

    if (i + 1 < this.messages.length) {
      // to decide is this image is last image in repetations if yes then hide imageicon else show
      if (this.messages[i + 1].sender.user_id == user.user_id) {
        return false;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: this._scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ProfileImage(
                auth_token: widget.authToken,
                profileUrl: this.recipentprofileUrl),
            SizedBox(
              width: 7,
            ),
            SystemUsername(
                name: widget.recipent.userName,
                showBlueMark: widget.recipent.role > 0 ? true : false,
                isPrimaryProfileUsername: false)
          ],
        ),
      ),
      body: Container(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          width: MediaQuery.of(context).size.width,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _messagebody(),
                ),
              ),
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.all(7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[300]),
                        constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.35),
                        child: TextField(
                          controller: messageController,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                      width: 50,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () {
                          _send();
                        },
                        child: Text(
                          "Send",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.fromLTRB(3, 2, 3, 2),
                            onPrimary: Colors.white,
                            primary: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
