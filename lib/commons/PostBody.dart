import 'dart:math';

import 'package:ant_icons/ant_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:my_app/Streams/TestStream.dart';

import 'package:my_app/commons/BottomSheetModal.dart';
import 'package:my_app/commons/CommentBody.dart';
import 'package:my_app/commons/ProfieImage.dart';
import 'package:my_app/commons/SystemAlert.dart';
import 'package:my_app/commons/SystemReactionButtons.dart';
import 'package:my_app/commons/Username.dart';
import 'package:my_app/constants/SystemIcons.dart';
import 'package:my_app/constants/UrlConstants.dart';
import 'package:my_app/objects/Post.dart';
import 'package:my_app/objects/PostDetail.dart';
import 'package:my_app/objects/SystemNoti.dart';
import 'package:my_app/objects/User.dart';
import 'package:my_app/extensions/SystemExtensions.dart';
import 'package:my_app/pages/Notification.dart';
import 'package:my_app/pages/SinglePostPage.dart';
import 'package:my_app/services/PostService.dart';
import 'package:my_app/util/RequestApi.dart';
import 'package:my_app/util/SystemException.dart';

class PostBody extends StatefulWidget {
  final String authToken;
  final bool showpopupbtn;
  final User owner;
  final Post post;
  final User currentUser;
  final Function onpopUpClick;

  final SinglePostPageState parentPostState;
  const PostBody({
    Key key,
    this.showpopupbtn,
    this.authToken,
    this.onpopUpClick,
    this.owner,
    this.post,
    this.parentPostState,
    this.currentUser,
  }) : super(key: key);
  _PostBodyState createState() => _PostBodyState();
}

class _PostBodyState extends State<PostBody> {
  String profileUrl;
  String postPictureUrl;
  Map<String, String> authHeader;
  int postOperation;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    this.initialize();
  }

  @override
  void dispose() {

    super.dispose();
  }

  void initialize() {
    ;
    clearCacheImages();
    this.profileUrl = 'http://' +
        UrlConstants.apiRequest +
        RequestApi.artifactId +
        "/api/profilePic?id=" +
        widget.owner.user_id.toString();
    this.postPictureUrl = 'http://' +
        UrlConstants.apiRequest +
        RequestApi.artifactId +
        "/api/post-picture?id=";
    authHeader = {"Authorization": "Bearer " + this.widget.authToken};
  }

  void clearCacheImages() {
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  bool isUserReacted(Post post) {
    bool returnValue = false;

    if (post.post_details_list.length > 0) {
      post.post_details_list.forEach((element) {
        if (element.reactor.user_id == widget.currentUser.user_id &&
            element.user_reaction != null) {
          returnValue = true;
        }
      });
    }
    return returnValue;
  }

  int reactIndex(Post post) {
    int returnValue = -1;

    if (post.post_details_list.length > 0) {
      post.post_details_list.forEach((element) {
        if (element.reactor.user_id == widget.currentUser.user_id &&
            element.user_reaction != null) {
          returnValue = element.user_reaction;
        }
      });
    }
    return returnValue;
  }

  _react(int type, Post post) async {
    try {
      PostDetail postDetail = new PostDetail();
      postDetail.post = post;
      postDetail.created_date = DateTime.now().changetoSystemStringDate();
      postDetail.updated_date = DateTime.now().changetoSystemStringDate();
      postDetail.created_id = widget.currentUser.user_id;
      postDetail.updated_id = widget.currentUser.user_id;
      postDetail.reactor = widget.currentUser;
      postDetail.user_reaction = type;
      var result = await PostService.whenUserReact(postDetail, context);

      if (result == null) {
        throw new SystemException("System Exception occurs");
      } else {
        PostDetail resultPostDetail = PostDetail.fromJSON(result["data"]);

        if (result["operationType"] != null &&
            result["operationType"] == "delete") {
          widget.post.post_details_list.removeWhere((element) =>
              element.post_detail_id == resultPostDetail.post_detail_id);
        } else {
          if (widget.post.post_details_list.length == 0) {
            widget.post.post_details_list.add(resultPostDetail);
          } else {
            bool notfound = false;
            for (var i = 0; i < widget.post.post_details_list.length; i++) {
              if (widget.post.post_details_list[i].post_detail_id ==
                  resultPostDetail.post_detail_id) {
                notfound = true;
                widget.post.post_details_list[i] = resultPostDetail;
              }
            }
            if (!notfound) {
              widget.post.post_details_list.add(resultPostDetail);
            }
          }
        }

        setState(() {});
        if (widget.post.owner.user_id != widget.currentUser.user_id) {
          SystemNoti noti = new SystemNoti();
          noti.created_date = DateTime.now().changetoSystemStringDate();
          noti.created_id = widget.currentUser.user_id;
          noti.noti_type = 1;
          noti.reaction = type;
          noti.post = post;
          noti.notimaker = widget.currentUser;
          var body = noti.toJSON();
          try {
            postNotiBroadCast(widget.authToken, body);
          } catch (error) {
            postNotiBroadCast(widget.authToken, body);
          }
        }
      }
    } on SystemException catch (error) {
      // setState(() {
      //   this.isUserReacted(post);
      //   this.reactIndex(post);
      // });
    } catch (error) {
      await SystemAlert.showAlert(0, error.toString(), context);
    }
  }

  List<PopupMenuItem<int>> _postdashButtons() {
    if (widget.owner.user_id == widget.currentUser.user_id) {
      postOperation = 0;
      return [
        new PopupMenuItem(
          child: Text("Edit Post"),
          value: 1,
        ),
        new PopupMenuItem(
          child: Text("Delete Post"),
          value: 2,
        )
      ];
    }
    if (widget.owner.user_id != widget.currentUser.user_id &&
        widget.currentUser.role == 0) {
      postOperation = 1;
      return [
        if (widget.owner.role != 2)
          new PopupMenuItem(
            child: Text("Report this person"),
            value: 1,
          ),
        new PopupMenuItem(
          child: Text("View Profile"),
          value: 2,
        ),
      ];
    }
    if (widget.owner.user_id != widget.currentUser.user_id &&
        widget.currentUser.role == 1 &&
        widget.owner.role == 0) {
      postOperation = 2;
      return [
        new PopupMenuItem(
          child: Text("Remove This person"),
          value: 1,
        ),
        new PopupMenuItem(
          child: Text("Delete this post"),
          value: 2,
        ),
        new PopupMenuItem(
          child: Text("View Profile"),
          value: 3,
        ),
      ];
    }
    if (widget.owner.user_id != widget.currentUser.user_id &&
        widget.currentUser.role == 1 &&
        widget.owner.role == 1) {
      postOperation = 3;
      return [
        new PopupMenuItem(
          child: Text("View Profile"),
          value: 1,
        ),
      ];
    }
    if (widget.owner.user_id != widget.currentUser.user_id &&
        widget.currentUser.role == 2) {
      postOperation = 4;
      return [
        new PopupMenuItem(
          child: Text("Remove This person"),
          value: 1,
        ),
        new PopupMenuItem(
          child: Text("Delete this post"),
          value: 2,
        ),
        if (widget.owner.role == 1)
          new PopupMenuItem(
            child: Text("Remove this person from Admin"),
            value: 3,
          ),
        if (widget.owner.role == 0)
          new PopupMenuItem(
            child: Text("Set this person to Admin"),
            value: 4,
          ),
        new PopupMenuItem(
          child: Text("View Profile"),
          value: 5,
        ),
      ];
    }
  }

  _comment(Post post) {
    BottomSheetModel.showSystetmBottomModel(
        context,
        CommentBody(
          auth_token: widget.authToken,
          player: widget.currentUser,
          post: widget.post,
        ));
  }

  Widget _reactions(Post post) {
    List<dynamic> reactionsRoom = [0, 0, 0, 0, 0, 0, 0];
    post.post_details_list.forEach((element) {
      reactionsRoom[element.user_reaction] =
          reactionsRoom[element.user_reaction] + 1;
    });
    var largestValue = reactionsRoom
        .reduce((value, element) => value > element ? value : element);
    return SystemReactionImage.reactions(
        reactionsRoom.indexOf(largestValue), 20);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 7, top: 5, bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ProfileImage(
                    auth_token: widget.authToken,
                    profileUrl: profileUrl,
                    valueKey: new Random().nextInt(100),
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SystemUsername(
                          name: this.widget.owner.userName,
                          showBlueMark:
                              this.widget.owner.role > 0 ? true : false,
                          isPrimaryProfileUsername: false),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        widget.post.created_date == null
                            ? ""
                            : widget.post.created_date.forPostDate(),
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    ],
                  ),
                  Spacer(),
                  if (widget.showpopupbtn == null || widget.showpopupbtn)
                    PopupMenuButton(
                      onSelected: (value) {
                        widget.onpopUpClick(value, postOperation, widget.post);
                      },
                      padding: EdgeInsets.zero,
                      itemBuilder: (context) {
                        return _postdashButtons();
                      },
                      icon: Icon(AntIcons.dash),
                    )
                ],
              ),
            ),
            Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (widget.post.status_body != null)
                    Container(
                      padding: EdgeInsets.all(7),
                      child: Text(widget.post.status_body),
                    ),
                  if (widget.post.hasPicture)
                    Center(
                        child: FadeInImage(
                            fit: BoxFit.cover,
                            placeholder: AssetImage(
                              "assets/default.png",
                            ),
                            image: NetworkImage(
                              this.postPictureUrl +
                                  widget.post.post_id.toString(),
                              headers: this.authHeader,
                            )))
                ],
              ),
            ),
            SizedBox(
              height: 7,
            ),
            Row(
              children: <Widget>[
                if (widget.post.post_details_list.length > 0)
                  _reactions(widget.post),
                if (widget.post.post_details_list.length > 0)
                  SizedBox(width: 3),
                Text("Reactions :"),
                SizedBox(width: 3),
                Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.3),
                    child:
                        Text(widget.post.post_details_list.length.toString())),
                Spacer(),
                Text("Comments"),
                SizedBox(width: 3),
                Text(widget.post.noOfComments.toString())
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                Expanded(
                  child: SystemReactionButtons(
                    hasChecked: this.isUserReacted(widget.post),
                    reactionIndex: this.reactIndex(widget.post),
                    reactionChange: (value) {
                      this._react(value, widget.post);
                    },
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _comment(widget.post);
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/comment.PNG",
                            width: 20,
                            height: 20,
                          ),
                          SizedBox(
                            width: 7,
                          ),
                          Text("Comment")
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
