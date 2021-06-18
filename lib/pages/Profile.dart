import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:ant_icons/ant_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/Streams/TestStream.dart';
import 'package:my_app/commons/BottomSheetModal.dart';
import 'package:my_app/commons/CommentBody.dart';
import 'package:my_app/commons/FakePosts.dart';
import 'package:my_app/commons/PostBody.dart';
import 'package:my_app/commons/ProfieImage.dart';
import 'package:my_app/commons/SkeletonContainer.dart';
import 'package:my_app/commons/SystemAlert.dart';

import 'package:my_app/commons/Username.dart';
import 'package:my_app/constants/UrlConstants.dart';
import 'package:my_app/objects/Post.dart';
import 'package:my_app/objects/PostDetail.dart';
import 'package:my_app/objects/SystemNoti.dart';
import 'package:my_app/objects/User.dart';
import 'package:my_app/pages/PostPrepare.dart';
import 'package:my_app/services/PostService.dart';
import 'package:my_app/util/RequestApi.dart';
import 'package:my_app/util/SystemException.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/extensions/SystemExtensions.dart';

class Profile extends StatefulWidget {
  _ProfileState createState() => _ProfileState();
  final User profileOwner;
  final User currentUser;
  final String authToken;
  const Profile({Key key, this.profileOwner, this.currentUser, this.authToken})
      : super(key: key);
}

class _ProfileState extends State<Profile> {
  SharedPreferences preferences;
  String postPictureUrl;
  String auth_token;
  User profileOwner;
  String profileUrl;
  String coverPicUrl;
  ImagePicker picker;
  Map<String, String> authHeader;
  bool hasInitalized = false;
  User currentUser;
  List<Post> userPosts = [];
  int myReact;
  bool isReacted = false;
  @override
  void initState() {
    this.initialize();
    super.initState();
  }

  bool isUserReacted(Post post) {
    bool returnValue = false;
    if (post.post_details_list.length > 0) {
      post.post_details_list.forEach((element) {
        if (element.reactor.user_id == this.currentUser.user_id &&
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
        if (element.reactor.user_id == this.currentUser.user_id &&
            element.user_reaction != null) {
       
          returnValue = element.user_reaction;
        }
      });
    }
    return returnValue;
  }

  userPostsFetching() async {
    try {
      this.userPosts = [];
      var result = await PostService.getuserPosts(
          profileOwner.user_id.toString(), context);
      if (result == null) {
        throw new SystemException("System error occurs");
      }
      for (var i = 0; i < result["data"].length; i++) {
        this.userPosts.add(Post.fromJSON(result["data"][i]));
      }
   
      setState(() {});
    } on SystemException catch (error) {} catch (error) {
      SystemAlert.showAlert(0, error.toString(), context);
    }
  }

  void clearImageCaches() {
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  initialize() async {

    this.postPictureUrl =
        'http://' + UrlConstants.apiRequest + "/api/post-picture?id=";

    this.auth_token = widget.authToken;
    this.currentUser = widget.currentUser;

    clearImageCaches();

    this.hasInitalized = true;
    this.profileOwner = widget.profileOwner;
    this.profileUrl = 'http://' +
        UrlConstants.apiRequest +
        RequestApi.artifactId +
        "/api/profilePic?id=" +
        profileOwner.user_id.toString();

    this.coverPicUrl = 'http://' +
        UrlConstants.apiRequest +
        RequestApi.artifactId +
        "/api/coverPic?id=" +
        profileOwner.user_id.toString();
    authHeader = {"Authorization": "Bearer " + this.auth_token};
    userPostsFetching();
  }

  _react(int type, Post post) async {
    try {
      this.myReact = type;
      PostDetail postDetail = new PostDetail();
      postDetail.post = post;
      postDetail.created_date = DateTime.now().changetoSystemStringDate();
      postDetail.updated_date = DateTime.now().changetoSystemStringDate();
      postDetail.created_id = this.profileOwner.user_id;
      postDetail.updated_id = this.profileOwner.user_id;
      postDetail.reactor = this.profileOwner;
      postDetail.user_reaction = myReact;
      var result = await PostService.whenUserReact(postDetail, context);
      if (result == null) {
        throw new SystemException("System Exception occurs");
      }
    } on SystemException catch (error) {
      setState(() {
        this.isUserReacted(post);
        this.reactIndex(post);
      });
    } catch (error) {
      await SystemAlert.showAlert(0, error.toString(), context);
    }
  }

  _comment(Post post) {
    BottomSheetModel.showSystetmBottomModel(
        context,
        CommentBody(
          auth_token: this.auth_token,
          player: this.currentUser,
          post: post,
        ));
  }

// image picking action of both coverphoto and profile
  _imagePickActionPrepare(int operationType, {bool iscoverPhoto = false}) {
    Widget bottomSheetModal = Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(200), topRight: Radius.circular(200))),
      padding: EdgeInsets.all(7),
      height: MediaQuery.of(context).size.height * 0.3,
      child: ClipRect(
        child: ListView(
          children: <Widget>[
            Container(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  if (operationType == 1) {
                    this._coverPhototAction(1);
                  } else {
                    this._profileAction(1);
                  }
                },
                child: Row(
                  children: <Widget>[
                    Icon(
                      AntIcons.camera_outline,
                      size: 30,
                    ),
                    SizedBox(
                      width: 7,
                    ),
                    Text(
                      "Choose From Camera",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.black,
            ),
            Container(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  if (operationType == 1) {
                    this._coverPhototAction(2);
                  } else {
                    this._profileAction(2);
                  }
                },
                child: Row(
                  children: <Widget>[
                    Icon(
                      AntIcons.picture_outline,
                      size: 30,
                    ),
                    SizedBox(
                      width: 7,
                    ),
                    Text(
                      "Choose From Gallery",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
            Divider(
              color: Colors.black,
            ),
            Container(
              child: InkWell(
                onTap: () {
                  if (operationType == 1) {
                    Navigator.of(context).pop();
                    this._coverPhototAction(3);
                  } else {
                    this._profileAction(3);
                  }
                },
                child: Row(
                  children: <Widget>[
                    Icon(
                      AntIcons.fund_outline,
                      size: 30,
                    ),
                    SizedBox(
                      width: 7,
                    ),
                    Text(
                      iscoverPhoto
                          ? "View Cover Photo"
                          : "View Profile Picture",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    BottomSheetModel.showSystetmBottomModel(context, bottomSheetModal);
  }

  postBroadCast(Post post, int type) {
    SystemNoti systemNoti = new SystemNoti();
    systemNoti.created_date = DateTime.now().changetoSystemStringDate();
    systemNoti.created_id = widget.profileOwner.user_id;
    var str;
    if (type == 0) {
      str = " has uploaded profile pictuure";
    } else if (type == 1) {
      str = " has uploaded cover picture";
    } else {
      str = " has posted something new";
    }
    systemNoti.noti_message = widget.profileOwner.userName.toString() + str;

    systemNoti.noti_type = 0;
    systemNoti.notimaker = widget.profileOwner;
    systemNoti.post = post;
    var body = systemNoti.toJSON();
    try {
      postNotiBroadCast(widget.authToken, body);
    } catch (error) {
      postNotiBroadCast(widget.authToken, body);
    }
  }

  Future _profileAction(int value) async {
    try {
      picker = ImagePicker();
      if (value == 1) {
        var pickedFile = await picker.getImage(source: ImageSource.camera);
        if (pickedFile != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostPrepare(
                        imageSize: MediaQuery.of(context).size.width,
                        header: "Profile Upload",
                        operationType: 0,
                        pickedImage: File(pickedFile.path),
                        profileUrl: this.profileUrl,
                        authToken: this.auth_token,
                        owner: profileOwner,
                      ))).then((value) {
            clearImageCaches();
            this.userPostsFetching();
            this.postBroadCast(value, 0);
          });
        }
      } else if (value == 2) {
        var pickedFile = await picker.getImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostPrepare(
                        imageSize: MediaQuery.of(context).size.width,
                        header: "Profile Upload",
                        operationType: 0,
                        pickedImage: File(pickedFile.path),
                        profileUrl: this.profileUrl,
                        authToken: this.auth_token,
                        owner: profileOwner,
                      ))).then((value) {
            clearImageCaches();
            this.userPostsFetching();
            postBroadCast(value, 0);
          });
        }
      } else {
        //todo to show image
      }
    } catch (error) {
      SystemAlert.showAlert(0, error.toString(), context);
    }
  }

  _postingStatus() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PostPrepare(
                  imageSize: MediaQuery.of(context).size.width,
                  header: "Create Post",
                  operationType: 2,
                  profileUrl: this.profileUrl,
                  authToken: widget.authToken,
                  owner: widget.currentUser,
                ))).then((value) {
      if (value != null) {
        this.userPostsFetching();
        postBroadCast(value, 2);
      }
    });
  }

  Future _coverPhototAction(int value) async {
    try {
      picker = ImagePicker();
      if (value == 1) {
        var pickedImage = await picker.getImage(source: ImageSource.camera);
        if (pickedImage != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostPrepare(
                        imageSize: MediaQuery.of(context).size.width,
                        header: "Cover Photo Upload",
                        operationType: 1,
                        pickedImage: File(pickedImage.path),
                        profileUrl: this.profileUrl,
                        authToken: this.auth_token,
                        owner: profileOwner,
                      ))).then((value) {
            clearImageCaches();
            this.userPostsFetching();
            postBroadCast(value, 1);
          });
        }
      } else if (value == 2) {
        var pickedImage = await picker.getImage(source: ImageSource.gallery);
        if (pickedImage != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostPrepare(
                        imageSize: MediaQuery.of(context).size.width,
                        header: "Cover Photo Upload",
                        operationType: 1,
                        pickedImage: File(pickedImage.path),
                        profileUrl: this.profileUrl,
                        authToken: this.auth_token,
                        owner: profileOwner,
                      ))).then((value) {
            clearImageCaches();
            this.userPostsFetching();
            postBroadCast(value, 1);
          });
        }
      } else {
        // to implement view image;
      }
    } catch (error) {
      SystemAlert.showAlert(0, error, context);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _returnRelationStatus() {
    if (profileOwner.rsStatus == null) {
      return "Not Described";
    } else if (profileOwner.rsStatus == 0) {
      return "Single";
    } else if (profileOwner.rsStatus == 1) {
      return "In a RelationShip";
    } else if (profileOwner.rsStatus == 2) {
      return "Married";
    } else {
      return "In a Complicated";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 7, right: 7, top: 5),
      child: SingleChildScrollView(
        child: GestureDetector(
          child: Column(
            children: <Widget>[
              // cover photo and profile photo
              Container(
                height: 270,
                color: Colors.white,
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 210,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(40))),
                        child: Card(
                          child: Stack(
                            children: <Widget>[
                              Align(
                                  alignment: Alignment.center,
                                  child: this.hasInitalized
                                      ? FadeInImage(
                                          placeholder: AssetImage(
                                              "assets/defaultuser.jpg"),
                                          image: NetworkImage(
                                            this.coverPicUrl,
                                            headers: this.authHeader,
                                          ),
                                          width: double.infinity,
                                          height: 210,
                                          fit: BoxFit.cover,
                                          key: ValueKey(
                                              new Random().nextInt(100)),
                                        )
                                      : SkeletonContainer(
                                          width: double.infinity, height: 198)),
                              if (hasInitalized &&
                                  profileOwner.user_id == currentUser.user_id)
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    color: Colors.white,
                                    child: IconButton(
                                      color: Colors.black,
                                      padding: EdgeInsets.all(0),
                                      icon: Icon(AntIcons.interation_outline),
                                      onPressed: () {
                                        _imagePickActionPrepare(1,
                                            iscoverPhoto: true);
                                      },
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 130,
                        height: 130,
                        child: Stack(
                          children: <Widget>[
                            ClipRRect(
                                // borderRadius: BorderRadius.circular(70),
                                child: this.hasInitalized
                                    ? FadeInImage(
                                        placeholder: AssetImage(
                                            "assets/defaultuser.jpg"),
                                        image: NetworkImage(
                                          this.profileUrl,
                                          headers: authHeader,
                                        ),
                                        fit: BoxFit.fill,
                                        height: 130,
                                        width: 130,
                                        key:
                                            ValueKey(new Random().nextInt(100)),
                                      )
                                    : SkeletonContainer(
                                        width: 130,
                                        height: 130,
                                      )),
                            if (hasInitalized &&
                                profileOwner.user_id == currentUser.user_id)
                              Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    color: Colors.white,
                                    width: 24,
                                    height: 24,
                                    child: IconButton(
                                      padding: EdgeInsets.all(0),
                                      icon: Icon(
                                        AntIcons.interation_outline,
                                      ),
                                      color: Colors.black,
                                      onPressed: () {
                                        _imagePickActionPrepare(2);
                                      },
                                    ),
                                  ))
                          ],
                        ),
                      ),
                    ),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: PopupMenuButton(
                          itemBuilder: (context) {
                            return [
                              new PopupMenuItem(child: Text("Test")),
                              new PopupMenuItem(child: Text("Test")),
                              new PopupMenuItem(child: Text("Test")),
                            ];
                          },
                          icon: Icon(AntIcons.ellipsis),
                        )),
                  ],
                ),
              ),

              //splited box
              SizedBox(
                height: 10,
              ),

              //biography
              Card(
                child: Container(
                  padding: EdgeInsets.all(7),
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      Align(
                          alignment: Alignment.topCenter,
                          child: this.hasInitalized
                              ? SystemUsername(
                                  name: this.profileOwner.userName,
                                  showBlueMark: this.profileOwner.role == 0
                                      ? false
                                      : true,
                                  isPrimaryProfileUsername: true,
                                )
                              : SkeletonContainer(
                                  width:
                                      MediaQuery.of(context).size.width * 0.45,
                                  height: 20,
                                )),
                      SizedBox(
                        height: 30,
                      ),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Icon(
                                          AntIcons.calendar,
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 7,
                                        ),
                                        Text("BirthDate"),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 7,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Icon(
                                          AntIcons.environment,
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 7,
                                        ),
                                        Text("Live in"),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 7,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Icon(
                                          AntIcons.heart,
                                          size: 18,
                                        ),
                                        SizedBox(
                                          width: 7,
                                        ),
                                        Text("Relationship"),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  this.hasInitalized
                                      ? Text(
                                          profileOwner.birthDate
                                              .forShowStringDate(),
                                          textAlign: TextAlign.center,
                                        )
                                      : SkeletonContainer(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          height: 18,
                                        ),
                                  SizedBox(
                                    height: 7,
                                  ),
                                  this.hasInitalized
                                      ? Text(
                                          "Not Described",
                                          textAlign: TextAlign.center,
                                        )
                                      : SkeletonContainer(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          height: 18,
                                        ),
                                  SizedBox(
                                    height: 7,
                                  ),
                                  this.hasInitalized
                                      ? Text(
                                          this._returnRelationStatus(),
                                          textAlign: TextAlign.center,
                                        )
                                      : SkeletonContainer(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          height: 18,
                                        ),
                                ],
                              ))
                            ],
                          )),
                    ],
                  ),
                ),
              ),
              if (widget.profileOwner.user_id == widget.currentUser.user_id)
                Card(
                  child: Container(
                    padding: EdgeInsets.all(7),
                    width: double.infinity,
                    child: Row(
                      children: <Widget>[
                        this.hasInitalized
                            ? ProfileImage(
                                auth_token: this.auth_token,
                                profileUrl: this.profileUrl,
                                valueKey: new Random().nextInt(100),
                              )
                            : SkeletonContainer(
                                width: 50,
                                height: 50,
                                radius: 25,
                              ),
                        SizedBox(
                          width: 10,
                        ),
                        this.hasInitalized
                            ? Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12)),
                                child: InkWell(
                                  onTap: () {
                                    _postingStatus();
                                  },
                                  child: Container(
                                    child: Text("Whats on your mind?"),
                                  ),
                                ),
                              )
                            : SkeletonContainer(
                                height: 40,
                                width: MediaQuery.of(context).size.width * 0.65,
                                radius: 12,
                              )
                      ],
                    ),
                  ),
                ),
              if (!hasInitalized)
                FakePosts(
                  fakePostsLemgth: 3,
                  enableScroll: false,
                ),
              if (hasInitalized && this.userPosts.length > 0)
                ListView.separated(
                  itemBuilder: (context, index) {
                    return PostBody(
                      owner: userPosts[index].owner,
                      currentUser: this.currentUser,
                      authToken: this.auth_token,
                      post: userPosts[index],
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: 5,
                    );
                  },
                  itemCount: userPosts.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
