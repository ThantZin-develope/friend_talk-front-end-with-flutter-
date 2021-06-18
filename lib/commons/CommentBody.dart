import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/Streams/TestStream.dart';
import 'package:my_app/commons/SystemAlert.dart';
import 'package:my_app/constants/SystemIcons.dart';

import 'package:my_app/extensions/SystemExtensions.dart';
import 'package:my_app/commons/ProfieImage.dart';
import 'package:my_app/commons/SkeletonContainer.dart';
import 'package:my_app/commons/Username.dart';

import 'package:my_app/constants/UrlConstants.dart';
import 'package:my_app/objects/Comment.dart';
import 'package:my_app/objects/Post.dart';
import 'package:my_app/objects/SystemNoti.dart';
import 'package:my_app/objects/User.dart';
import 'package:my_app/services/CommentService.dart';
import 'package:my_app/util/RequestApi.dart';
import 'package:my_app/util/SystemException.dart';

class CommentBody extends StatefulWidget {
  String auth_token;
  User player;
  Post post;

  CommentBody(
      {Key key,
      @required this.auth_token,
      @required this.player,
      @required this.post})
      : super(key: key);
  _CommentBodyState createState() => _CommentBodyState();
}

class _CommentBodyState extends State<CommentBody> {
  String profileUrl;
  bool hasInitialized = false;
  List<Comment> comments = [];
  double firstRandom = 0.5;
  double secondRandom = 0.7;
  double thirdRandom = 0.6;
  String usersImgageUrl;
  TextEditingController commentText = new TextEditingController();
  final ScrollController scrollController = new ScrollController();
  bool whileCommenting = false;
  @override
  void initState() {
    super.initState();
    this.initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void initialize() async {
    try {
  
      this.usersImgageUrl = 'http://' +
          UrlConstants.apiRequest +
          RequestApi.artifactId +
          "/api/profilePic?id=";
      this.profileUrl = 'http://' +
          UrlConstants.apiRequest +
          RequestApi.artifactId +
          "/api/profilePic?id=" +
          widget.player.user_id.toString();
      fetchComments();
    } on SystemException catch (error) {} catch (error) {
      await SystemAlert.showAlert(0, error.toString(), context);
    }
  }

  fetchComments() async {
    var result = await CommentService.getComments(
        widget.post.post_id.toString(), context);
    if (result == null) {
      throw new SystemException("System Exception Occurs");
    } else {
      for (var i = 0; i < result["data"].length; i++) {
        comments.add(Comment.fromJSON(result["data"][i]));
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
    
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });


    setState(() {
      hasInitialized = true;
    });
  }

  @override
  void dispose() {
    super.dispose();

    widget.post = null;
  }

  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  Widget commentBody(BuildContext context) {
    if (!hasInitialized) {
      return ListView.separated(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SkeletonContainer(
                  height: 50,
                  width: 50,
                  radius: 25,
                ),
                SizedBox(
                  width: 7,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SkeletonContainer(
                        height: 20,
                        width: MediaQuery.of(context).size.width * firstRandom),
                    SizedBox(
                      height: 5,
                    ),
                    SkeletonContainer(
                        height: 20,
                        width:
                            MediaQuery.of(context).size.width * secondRandom),
                    SizedBox(
                      height: 5,
                    ),
                    SkeletonContainer(
                      height: 20,
                      width: MediaQuery.of(context).size.width * thirdRandom,
                    )
                  ],
                )
              ],
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(
              height: 7,
            );
          },
          itemCount: 4);
    }
    if (hasInitialized && comments.length > 0) {
      return ListView.separated(
          scrollDirection: Axis.vertical,
          physics: ClampingScrollPhysics(),
          controller: scrollController,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ProfileImage(
                    auth_token: widget.auth_token,
                    profileUrl: this.usersImgageUrl +
                        comments[index].owner.user_id.toString()),
                SizedBox(
                  width: 7,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SystemUsername(
                        name: comments[index].owner.userName,
                        showBlueMark:
                            comments[index].owner.role > 0 ? true : false,
                        isPrimaryProfileUsername: false),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8),
                      child: Text(comments[index].comment),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(comments[index].created_date.forPostDate()),
                        if (this.comments.last == this.comments[index] &&
                            whileCommenting)
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text("Commenting"),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(
              height: 7,
            );
          },
          itemCount: comments.length);
    }
    if (hasInitialized && comments.length == 0) {
      return Center(
        child: Text("NO Comments Yet"),
      );
    }
  }

  _comment() async {
    try {
      if (commentText.text.isNotEmpty) {
        Comment comment = new Comment();
        comment.created_date = DateTime.now().changetoSystemStringDate();
        comment.updated_date = DateTime.now().changetoSystemStringDate();
        comment.created_id = widget.player.user_id;
        comment.updated_id = widget.player.user_id;
        comment.comment = commentText.text;
        comment.owner = widget.player;
        comment.post_id = widget.post.post_id;
        setState(() {
          commentText.clear();
          whileCommenting = true;
        });

        var result = await CommentService.writeComment(comment, context);
        if (result != null) {
          widget.post.noOfComments = widget.post.noOfComments + 1;
          whileCommenting = false;
          Comment resultComment = Comment.fromJSON(result["data"]);
          this.comments.add(resultComment);
          setState(() {});
          if (widget.post.owner.user_id != widget.player.user_id) {
            SystemNoti systemNoti = new SystemNoti();
            systemNoti.created_date = DateTime.now().changetoSystemStringDate();
            systemNoti.created_id = widget.player.user_id;
            systemNoti.noti_message =
                widget.player.userName + " has commented on your post";
            systemNoti.noti_type = 2;
            systemNoti.post = widget.post;
            systemNoti.notimaker = widget.player;
            var data = systemNoti.toJSON();
            try {
              postNotiBroadCast(widget.auth_token, data);
            } catch (error) {
              postNotiBroadCast(widget.auth_token, data);
            }
          }
        } else {}
      }
    } catch (error) {
      await SystemAlert.showAlert(0, error.toString(), context);
    }
  }

  Widget maxReactions() {
    List<dynamic> reactionsRoom = [0, 0, 0, 0, 0, 0, 0];

    widget.post.post_details_list.forEach((element) {
      reactionsRoom[element.user_reaction] =
          reactionsRoom[element.user_reaction] + 1;
    });
    var largestValue = reactionsRoom
        .reduce((value, element) => value > element ? value : element);
    var secondLargestValue = reactionsRoom[0];
    reactionsRoom.forEach((element) {
      if (element <= largestValue) {
        if (element > secondLargestValue) {
          secondLargestValue = element;
        }
      }
    });
    return Row(
      children: <Widget>[
        SystemReactionImage.reactions(reactionsRoom.indexOf(largestValue), 20),
        SystemReactionImage.reactions(
            reactionsRoom.lastIndexOf(secondLargestValue), 20),
      ],
    );
  }

  Widget _reactedButton() {
    if (hasInitialized) {
      if (widget.post.post_details_list.length > 0) {

        return InkWell(
          child: widget.post.post_details_list.length == 1
              ? Row(
                  children: <Widget>[
                    SystemReactionImage.reactions(
                        widget.post.post_details_list[0].user_reaction, 20),
                    SizedBox(
                      width: 7,
                    ),
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75),
                      child: Text(
                          widget.post.post_details_list[0].reactor.userName +
                              " has reacted on this"),
                    )
                  ],
                  crossAxisAlignment: CrossAxisAlignment.center,
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    this.maxReactions(),
                    SizedBox(),
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7),
                      child: Text(
                          widget.post.post_details_list[0].reactor.userName +
                              " and " +
                              (widget.post.post_details_list.length - 1)
                                  .toString() +
                              " others Reacted on this"),
                    ),
                  ],
                ),
        );
      } else {
        return Text("Be the First react of this");
      }
    } else {
      return Text("Initializing");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        width: MediaQuery.of(context).size.width,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
                width: MediaQuery.of(context).size.width,
                height: 40,
                padding: EdgeInsets.only(left: 7),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _reactedButton(),
                )),
            // Expanded(
            // child:
            //   Column(

            // children: <Widget>[
            Expanded(
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: commentBody(context)),
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
                          maxHeight: MediaQuery.of(context).size.height * 0.35),
                      child: TextField(
                        controller: commentText,
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
                        _comment();
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
        )
        //   ),
        // ],
        // )
        );
  }
}
