import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/commons/PostBody.dart';
import 'package:my_app/commons/SystemAlert.dart';
import 'package:my_app/constants/UrlConstants.dart';
import 'package:my_app/objects/Post.dart';
import 'package:my_app/objects/SystemReports.dart';
import 'package:my_app/objects/User.dart';
import 'package:my_app/pages/PostPrepare.dart';
import 'package:my_app/extensions/SystemExtensions.dart';
import 'package:my_app/pages/UserProfile.dart';
import 'package:my_app/services/PostService.dart';
import 'package:my_app/services/ReportService.dart';
import 'package:my_app/util/RequestApi.dart';
import 'package:my_app/util/SystemException.dart';
import 'package:my_app/extensions/SystemExtensions.dart';
import 'package:my_app/services/UserServices.dart' as UserService;

class SinglePostPage extends StatefulWidget {
  final Post post;
  final User currentUser;
  final String authToken;
  final User owner;
  SinglePostPage(
      {Key key,
      this.post,
      this.currentUser,
      this.authToken,
      @required this.owner})
      : super(key: key);
  SinglePostPageState createState() => SinglePostPageState();
}

class SinglePostPageState extends State<SinglePostPage> {
  String profileUrl;

  Post postp;
  @override
  void initState() {
    super.initState();
    this.initialize();
  }
  
  bool hasInitailized = false;
  void initialize() async {
    this.profileUrl = 'http://' +
        UrlConstants.apiRequest +
        RequestApi.artifactId +
        "/api/profilePic?id=" +
        widget.currentUser.user_id.toString();
    var result =
        await PostService.findById(widget.post.post_id.toString(), context);
    if (result == null) {
      throw Exception();
    } else {
      setState(() {
        postp = Post.fromJSON(result["data"]);
        hasInitailized = true;
      });
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
                      )));
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
    Navigator.pop(context);
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
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.owner.userName + "' post"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(
              7, 7, 7, MediaQuery.of(context).viewInsets.bottom),
          child: PostBody(
            authToken: widget.authToken,
            owner: widget.owner,
            post: !hasInitailized ? widget.post : postp,
            parentPostState: this,
            onpopUpClick: (value, operation, post) {
              onpostOperation(value, operation, post);
            },
            currentUser: widget.currentUser,
          ),
        ),
      ),
    );
  }
}
