import 'dart:math';

import 'package:ant_icons/ant_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/Streams/TestStream.dart';

import 'package:my_app/commons/FakePosts.dart';
import 'package:my_app/commons/PostBody.dart';
import 'package:my_app/commons/ProfieImage.dart';

import 'package:my_app/commons/SystemAlert.dart';

import 'package:my_app/constants/UrlConstants.dart';
import 'package:my_app/objects/Post.dart';
import 'package:my_app/objects/SystemNoti.dart';
import 'package:my_app/objects/SystemReports.dart';

import 'package:my_app/objects/User.dart';
import 'package:my_app/pages/PostPrepare.dart';
import 'package:my_app/pages/SearchPage.dart';
import 'package:my_app/services/UserServices.dart' as UserService;
import 'package:my_app/pages/UserProfile.dart';
import 'package:my_app/services/PostService.dart';
import 'package:my_app/extensions/SystemExtensions.dart';
import 'package:my_app/services/ReportService.dart';
import 'package:my_app/util/RequestApi.dart';
import 'package:my_app/util/SystemException.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  _HomeState createState() => _HomeState();
  final User currentUser;
  final String authToken;
  const Home({Key key, @required this.currentUser, @required this.authToken})
      : super(key: key);
}

class _HomeState extends State<Home> {
  ScrollController sccontroller = new ScrollController();
  bool isinitialized = false;
  List<Post> posts = [];
  bool datafetching = false;
  SharedPreferences preferences;
  String profileUrl;
  int requestIndex = 1;

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

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void clearImageCaches() {
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  writenewPost(BuildContext context) {
  
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

        setState(() {
          this.posts.insert(0, value);
        });
        postBroadCast(value);
      }
    });
  }

  postBroadCast(Post post) {
    SystemNoti systemNoti = new SystemNoti();
    systemNoti.created_date = DateTime.now().changetoSystemStringDate();
    systemNoti.created_id = widget.currentUser.user_id;
    systemNoti.noti_message =
        widget.currentUser.userName + " has Posted Something New";
    systemNoti.noti_type = 0;
    systemNoti.notimaker = widget.currentUser;
    systemNoti.post = post;
    var body = systemNoti.toJSON();
    try{
    postNotiBroadCast(widget.authToken, body);
    }catch(error){
    postNotiBroadCast(widget.authToken, body);
    }

  }

  void initialize() async {
    try {
      clearImageCaches();
  
      notistreamController.stream.listen((event) {
        SystemNoti result = event;
        // if notitype = 0 for post upload noti type and postonwer is not equal currenuse then add the latest post
        if (result.post.owner.user_id != widget.currentUser.user_id &&
            result.noti_type == 0) {
          _onPostReceived(result.post);
        }
      });
      this.profileUrl = 'http://' +
          UrlConstants.apiRequest + RequestApi.artifactId+
          "/api/profilePic?id=" +
          widget.currentUser.user_id.toString();

      _postsFetch();
      this.sccontroller.addListener(() {
        if (sccontroller.position.pixels ==
            sccontroller.position.maxScrollExtent) {
          if (this.isinitialized ) {
            setState(() {
              this.datafetching = true;
            });
            this.requestIndex = this.requestIndex + 1;
            _postsFetch();
          }
        }
      });
    } catch (error) {
   
      await SystemAlert.showAlert(0, error.toString(), context);
    }
  }

  _onPostReceived(Post post) {
    bool isAlreadyExist = false;
    for (var i = 0; i < this.posts.length; i++) {
      if (this.posts[i].post_id == post.post_id) {
        this.posts[i] = post;
        isAlreadyExist = true;
        break;
      }
    }
    if (!isAlreadyExist) {
      this.posts.add(post);
    }

    this.posts.removeDuplicatePosts();
    setState(() {});
  }

  _postsFetch() async {
 
    try {
      var result =
          await PostService.getPosts(this.requestIndex.toString(), context);
      if (result == null) {
        throw new SystemException("SystemException occurs");
      }

      if (result["data"].length == 0) {
    
        this.requestIndex = this.requestIndex - 1;
      } else {
        for (var i = 0; i < result["data"].length; i++) {
          this.posts.add(Post.fromJSON(result["data"][i]));
        }

        this.posts.removeDuplicatePosts();
      }
      this.datafetching = false;
      if (!isinitialized) {
        isinitialized = true;
      }
      setState(() {});
    } on SystemException catch (error) {} catch (error) {
      await SystemAlert.showAlert(0, error.toString(), context);
    }
  }

  onpostOperation(int value, int operation, Post post) async {
    try {
 
      if (operation == 0) {
        if (value == 1) {
   
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostPrepare(
                        imageSize: MediaQuery.of(context).size.width,
                        header: "Edit Post",
                        operationType: 3,
                        profileUrl: this.profileUrl,
                        authToken: widget.authToken,
                        owner: widget.currentUser,
                        post: post,
                      ))).then((value) {
            if (value != null) {
              Post newPost = value;
              for (var i = 0; i < this.posts.length; i++) {
                if (this.posts[i].post_id == newPost.post_id) {
                  this.posts[i] = newPost;
                  break;
                }
              }
              setState(() {});
              postBroadCast(value);
            }
          });
        }
        if (value == 2) {
          _postdelete(post);
        }
      }

      if (operation == 1) {
        if (value == 1) {
          SystemReports report = new SystemReports();
          report.created_date = DateTime.now().changetoSystemStringDate();
          report.created_id = widget.currentUser.user_id;
          report.updated_date = DateTime.now().changetoSystemStringDate();
          report.updated_id = widget.currentUser.user_id;
          report.user = post.owner;
          report.report_type = 2;

          var result = await ReportService.report(context, report);
          if (result == null) {
            throw new SystemException("SytemException Occurs");
          }
          await SystemAlert.showAlert(2, result["message"], context);
        }
        if (value == 2) {
          viewProfile(post);
        }
      }
//todo
      if (operation == 2) {
        if (value == 1) {
          var result = await UserService.userModify(post.owner, context, "3");
          if (result == null) {
            throw new SystemException("SystemException Occurs");
          }
          await SystemAlert.showAlert(2, result["message"], context);
        }
        if (value == 2) {
          _postdelete(post);
        }
        if (value == 3) {
          viewProfile(post);
        }
      }

      if (operation == 3) {
        viewProfile(post);
      }

      if (operation == 4) {
        if (value == 1) {
          /// 3
          var result = await UserService.userModify(post.owner, context, "3");
          if (result == null) {
            throw new SystemException("SystemException Occurs");
          }
          await SystemAlert.showAlert(2, result["message"], context);
        }
        if (value == 2) {
          _postdelete(post);
        }
        if (value == 3) {
          //remove from admin
          var result = await UserService.userModify(post.owner, context, "2");
          if (result == null) {
            throw new SystemException("SystemException Occurs");
          }
          await SystemAlert.showAlert(2, result["message"], context);
        }
        if (value == 4) {
          // 1 set admin
          var result = await UserService.userModify(post.owner, context, "1");
          if (result == null) {
            throw new SystemException("SystemException Occurs");
          }
          await SystemAlert.showAlert(2, result["message"], context);
        }
        if (value == 5) {
          viewProfile(post);
        }
      }
    } on SystemException catch (error) {} catch (error) {
      await SystemAlert.showAlert(0, error.toString(), context);
    }
  }

  _postdelete(Post post) async {
  
    var result = await PostService.deletePost(post, context);
    if (result == null) {
      throw new SystemException("SystemException Occurs");
    }
    Post resultpost = Post.fromJSON(result["data"]);
    this.posts.removeWhere((element) => element.post_id == resultpost.post_id);
    this.posts.removeDuplicatePosts();
    setState(() {});
  }

  viewProfile(Post post) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserProfile(
                  profileOwner: post.owner,
                  currentUser: widget.currentUser,
                  auth_token: widget.authToken,
                ))).then((value) => this._postsFetch());
  }

  Widget _homeBody() {
    if (!isinitialized) {
      return Flexible(
          child: FakePosts(
        enableScroll: true,
        fakePostsLemgth: 7,
      ));
    }
    if (isinitialized && posts.length == 0) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Center(
          child: Text("No Posts Yet"),
        ),
      );
    }
    if (isinitialized && posts.length > 0) {
      return Flexible(
        child: ListView.separated(
            shrinkWrap: true,
            controller: sccontroller,
            itemBuilder: (context, index) {
              return PostBody(
                onpopUpClick: (value, operation, post) {
                  onpostOperation(value, operation, post);
                },
                authToken: widget.authToken,
                owner: posts[index].owner,
                currentUser: widget.currentUser,
                post: posts[index],
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(
                height: 7,
              );
            },
            itemCount: this.posts.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    ProfileImage(
                      auth_token: widget.authToken,
                      profileUrl: profileUrl,
                      valueKey: new Random().nextInt(100),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () {
                        writenewPost(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7),
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12)),
                        child: Text("What's Up!"),
                      ),
                    ),
                    Spacer(),
                    IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        icon: Icon(AntIcons.search_outline),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchPage(
                                        currentUser: widget.currentUser,
                                        authToken: widget.authToken,
                                      ))).then((value) => this._postsFetch());
                        })
                  ],
                ),
              ),

              //to check if post lenth is zero show no post text
              _homeBody(),
            ],
          ),
          if (datafetching)
            Align(
                alignment: Alignment.topCenter,
                child: Container(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                  width: 20,
                  height: 20,
                  margin: EdgeInsets.only(top: 12),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(12)),
                ))
        ],
      ),
    );
  }
}
