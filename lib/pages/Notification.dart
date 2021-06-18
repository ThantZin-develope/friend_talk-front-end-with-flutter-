import 'package:ant_icons/ant_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/commons/ProfieImage.dart';
import 'package:my_app/commons/SystemAlert.dart';
import 'package:my_app/constants/SystemColors.dart';
import 'package:my_app/constants/SystemIcons.dart';
import 'package:my_app/constants/UrlConstants.dart';
import 'package:my_app/objects/Post.dart';
import 'package:my_app/objects/SystemNoti.dart';
import 'package:my_app/objects/User.dart';
import 'package:my_app/pages/SinglePostPage.dart';
import 'package:my_app/services/SystemNotiService.dart';
import 'package:my_app/util/RequestApi.dart';
import 'package:my_app/util/SystemException.dart';
import 'package:my_app/extensions/SystemExtensions.dart';
import 'package:my_app/extensions/SystemExtensions.dart';

class SystemNotification extends StatefulWidget {
  final User currentUser;
  final String authToken;
  SystemNotification({Key key, this.currentUser, this.authToken})
      : super(key: key);
  NotificationState createState() => NotificationState();
}

class NotificationState extends State<SystemNotification> {
  String userProfileUrl;
  List<SystemNoti> notis = [];
  bool hasinitialize = false;
  bool isdatafetching = false;
  final ScrollController scrollController = ScrollController();
  int requesteIndex = 1;
  @override
  void initState() {
    super.initState();
    this.initialize();
  }

  void initialize() async {
    try {
      this.scrollController.addListener(() {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          if (this.hasinitialize) {
            setState(() {
              this.isdatafetching = true;
            });
            this.requesteIndex++;
            this.notiFetch();
          }
        }
      });
      this.userProfileUrl = 'http://' +
          UrlConstants.apiRequest +
          RequestApi.artifactId +
          "/api/profilePic?id=";
      notiFetch();
    } on SystemException catch (error) {} catch (error) {
      await SystemAlert.showAlert(0, error.toString(), context);
    }
  }

  notiFetch() async {
    try {
      var result = await SystemNotiService.getUserNotis(
          widget.currentUser.user_id.toString(),
          requesteIndex.toString(),
          context);
      if (result == null) {
        throw new SystemException("SystemException Occurs");
      }
      if (result["data"].length == 0) {
        this.requesteIndex--;
      } else {
        for (var i = 0; i < result["data"].length; i++) {
          this.notis.add(SystemNoti.fromJSON(result["data"][i]));
        }
      }
      if (!hasinitialize) {
        hasinitialize = true;
      }
      this.isdatafetching = false;
      this.notis.removeDuplicateNotiss();
      setState(() {});
    } on SystemException catch (error) {} catch (error) {
      await SystemAlert.showAlert(0, error.toString(), context);
    }
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

  _postDetail(Post post) {
  
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SinglePostPage(
                  owner: post.owner,
                  post: post,
                  currentUser: widget.currentUser,
                  authToken: widget.authToken,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return !hasinitialize
        ? Container(
            width: MediaQuery.of(context).size.width,
            height: double.infinity,
            child: Center(
              child: Container(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          )
        : this.notis.length > 0
            ? Stack(
                children: [
                  ListView.separated(
                      controller: scrollController,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            _postDetail(this.notis[index].post);
                          },
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.all(7),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(7),
                                    height: 50,
                                    width: 50,
                                    child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.topCenter,
                                          child: ProfileImage(
                                              auth_token: widget.authToken,
                                              profileUrl: userProfileUrl +
                                                  this
                                                      .notis[index]
                                                      .notimaker
                                                      .user_id
                                                      .toString()),
                                        ),
                                        if (this.notis[index].noti_type == 1 &&
                                            this.notis[index].reaction != -1)
                                          Align(
                                              alignment: Alignment.bottomRight,
                                              child:
                                                  SystemReactionImage.reactions(
                                                      this
                                                          .notis[index]
                                                          .reaction,
                                                      25))
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                      child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        this.notis[index].noti_message,
                                        style: TextStyle(
                                            color: this
                                                        .notis[index]
                                                        .noti_type ==
                                                    0
                                                ? Colors.black
                                                : this.notis[index].noti_type ==
                                                        1
                                                    ? SystemColors
                                                        .getReactionColors(this
                                                            .notis[index]
                                                            .reaction)
                                                    : SystemColors
                                                        .getReactionColors(7)),
                                      ),
                                      Text(
                                        this
                                            .notis[index]
                                            .created_date
                                            .forPostDate(),
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      )
                                    ],
                                  ))
                                ],
                              )),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: 1,
                        );
                      },
                      itemCount: this.notis.length),
                  if (isdatafetching)
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 20,
                        height: 20,
                        margin: EdgeInsets.only(top: 10),
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    )
                ],
              )
            : Container(
                height: double.infinity,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Text("No Noti Yet!"),
                ),
              );
  }
}
