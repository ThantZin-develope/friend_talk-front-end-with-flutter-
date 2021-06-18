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
import 'package:my_app/services/UserServices.dart' as UserService;

class SearchPage extends StatefulWidget {
  final User currentUser;
  final String authToken;
  SearchPage({Key key, this.currentUser, this.authToken}) : super(key: key);
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Post> results = [];
  TextEditingController searchController = new TextEditingController();
  String profileUrl;
  @override
  void initState() {
    super.initState();
    this.initialize();
  }

  void initialize() {
    this.profileUrl = 'http://' +
        UrlConstants.apiRequest +
        RequestApi.artifactId +
        "/api/profilePic?id=" +
        widget.currentUser.user_id.toString();
    this.resultFetch();
  }

  resultFetch() async {
    try {
      if (searchController.text.isNotEmpty) {
  
        var result =
            await PostService.searchPost(searchController.text, context);
        if (result == null) {
          throw new SystemException("System Exception Occurs");
        }
        for (var i = 0; i < result["data"].length; i++) {
          this.results.add(Post.fromJSON(result["data"][i]));
        }
        
        setState(() {});
      }
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
              for (var i = 0; i < this.results.length; i++) {
                if (this.results[i].post_id == newPost.post_id) {
                  this.results[i] = newPost;
                  break;
                }
              }
              setState(() {});
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
    this
        .results
        .removeWhere((element) => element.post_id == resultpost.post_id);
    this.results.removeDuplicatePosts();
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

  Widget searchResult() {
    if (results.length == 0) {
      return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Text("No Result!"),
          ));
    } else {
      return ListView.separated(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return PostBody(
              onpopUpClick: (value, operation, post) {
                onpostOperation(value, operation, post);
              },
            
              authToken: widget.authToken,
              owner: results[index].owner,
              currentUser: widget.currentUser,
              post: results[index],
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(
              height: 7,
            );
          },
          itemCount: this.results.length);
    }
  }

  @override
  Widget build(BuildContext) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: TextFormField(
              onFieldSubmitted: (value) {
                resultFetch();
              },
              autovalidateMode: AutovalidateMode.always,
              controller: searchController,
              autofocus: true,
              maxLines: 1,
              decoration: InputDecoration(
                isDense: true,
              ),
            )),
        body: Container(
          padding: EdgeInsets.fromLTRB(
              7, 7, 7, MediaQuery.of(context).viewInsets.bottom),
          child: searchResult(),
        ),
      ),
    );
  }
}
