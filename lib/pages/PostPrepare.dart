import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:my_app/services/PostService.dart';
import 'package:my_app/services/UserServices.dart' as UserService;
import 'package:ant_icons/ant_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/commons/ProfieImage.dart';
import 'package:my_app/commons/SystemAlert.dart';
import 'package:my_app/commons/Username.dart';
import 'package:my_app/objects/Post.dart';
import 'package:my_app/objects/User.dart';
import 'package:my_app/util/SystemException.dart';
import 'package:my_app/extensions/SystemExtensions.dart';

class PostPrepare extends StatefulWidget {
  final int operationType;
  final File pickedImage;
  final String header;
  final Post post;
  final String profileUrl;
  final String authToken;
  final User owner;
  final double imageSize;

  // 0 = profile upload 1 = cover upload , 2 = post creat , 3 = post edit
  PostPrepare(
      {Key key,
      @required this.operationType,
      this.pickedImage,
      this.post,
      this.header,
      @required this.imageSize,
      @required this.profileUrl,
      @required this.authToken,
      @required this.owner})
      : super(key: key);

  _PostPrepareState createState() => _PostPrepareState();
}

class _PostPrepareState extends State<PostPrepare> {
  TextEditingController controller = TextEditingController();
  File _picekdImage;
  bool isPostBtnDisabled;
  ImagePicker imagepicker;
  Uint8List bytesArray;
  @override
  void initState() {
    this.initialize();
    super.initState();
  }

  void initialize() async {
    clearImageCaches();
    if (widget.post != null) {
      controller.text = widget.post.status_body;
      if (widget.post.hasPicture) {
   
        var result = await PostService.getPostImage(
            context, widget.post.post_id.toString());
        if (result != null) {
          bytesArray = result;
        }
      }
    }else{
      _picekdImage = widget.pickedImage;
    }
    setState(() {});
  }

  void clearImageCaches() {
    setState(() {
      imageCache.clear();
      imageCache.clearLiveImages();
    });
  }

  _upload() async {
    try {
      Post postResult;
      if (widget.operationType != 3) {
        Post post = new Post();
        if (this._picekdImage != null) {
          post.picture = await this._picekdImage.readAsBytes();
          post.hasPicture = true;
        }
        post.status_body = controller.text;
        post.created_date = DateTime.now().changetoSystemStringDate();
        post.updated_date = DateTime.now().changetoSystemStringDate();
        post.owner = widget.owner;
        post.created_id = widget.owner.user_id;
        post.updated_id = widget.owner.user_id;
        SystemAlert.showMessagingAlert(context, "Posting..");

        if (widget.operationType == 0) {
          var result = await UserService.uploadpandcvpic(
              context, post, widget.operationType.toString());
          if (result == null) {
            throw new SystemException("SomeError Occurs");
          } else {
            postResult = Post.fromJSON(result["data"]);
          }
        }
        if (widget.operationType == 1) {
          var result = await UserService.uploadpandcvpic(
              context, post, widget.operationType.toString());
          if (result == null) {
            throw new SystemException("SomeError Occurs");
          } else {
            postResult = Post.fromJSON(result["data"]);
          }
        }
        if (widget.operationType == 2) {
          var result = await PostService.createPost(post, context);
          if (result == null) {
            throw new SystemException("SomeError Occurs");
          } else {
         
          
            postResult = Post.fromJSON(result["data"]);
          }
        }
        // first pop to close posting dialog second pop for data trnsfer;

      } else {
        Post post = widget.post;
        post.updated_date = DateTime.now().changetoSystemStringDate();
        post.picture = this.bytesArray;
        post.status_body = controller.text;
        var result = await PostService.modifyPost(post, context);
        SystemAlert.showMessagingAlert(context, "Editing..");
        if (result == null) {
          throw new SystemException("SysemException occurs");
        } else {
          postResult = Post.fromJSON(result["data"]);
        }
      }
      Navigator.pop(context);
      Navigator.pop(context, postResult);
    } on SystemException catch (error) {
      Navigator.pop(context);
    } catch (error) {
      Navigator.pop(context);
      await SystemAlert.showAlert(0, error.toString(), context);
    }
  }

  _imageAction() async {
    imagepicker = ImagePicker();
    var pickedImage = await imagepicker.getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        this._picekdImage = File(pickedImage.path);
      });
    }
  }

  Widget _returnFloatBtn() {
    if (widget.operationType == 2 && this._picekdImage == null) {
      return FloatingActionButton(
        onPressed: () {
          this._imageAction();
        },
        child: Icon(AntIcons.camera_outline),
      );
    }
    return null;
  }

  Widget _returnPostBtn() {
    this.isPostBtnDisabled =
        (this.controller.text.trim().length > 0 || this._picekdImage != null)
            ? false
            : true;
    return Container(
        child: Center(
      child: ElevatedButton(
        onPressed: () {
          this.isPostBtnDisabled ? null : _upload();
        },
        child: Text(
          "Post",
          style: TextStyle(
              color: isPostBtnDisabled ? Colors.grey[600] : Colors.white,
              fontWeight: FontWeight.bold),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
            if (isPostBtnDisabled) return Colors.grey;
            return Colors.blueAccent;
          }),
        ),
      ),
    ));
  }

  _imagePop() {
    
    setState(() {
      this.bytesArray = null;
      this._picekdImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: <Widget>[_returnPostBtn()],
        title: Text(widget.header),
      ),
      floatingActionButton: _returnFloatBtn(),
      body: Container(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: SingleChildScrollView(
          child: GestureDetector(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Row(
                    children: <Widget>[
                      ProfileImage(
                        auth_token: widget.authToken,
                        profileUrl: widget.profileUrl,
                        valueKey: new Random().nextInt(100),
                      ),
                      SizedBox(
                        width: 7,
                      ),
                      SystemUsername(
                          name: widget.owner.userName,
                          showBlueMark: widget.owner.role == 0 ? false : true,
                          isPrimaryProfileUsername: false),
                    ],
                  ),
                ),
                SizedBox(
                  height: 7,
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  constraints: BoxConstraints(maxHeight: double.infinity),
                  child: TextField(
                    maxLines: null,
                    controller: controller,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "What do you wanna talk about?"),
                  ),
                ),
                if (this._picekdImage != null || this.bytesArray != null)
                  Stack(
                    alignment: Alignment.topRight,
                    children: <Widget>[
                      widget.operationType == 3
                          ? Image.memory(bytesArray)
                          : Image.file(
                              this._picekdImage,
                            ),
                      if (widget.operationType != 0 &&
                          widget.operationType != 1)
                        Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                                onPressed: () {
                                  this._imagePop();
                                },
                                icon: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: Colors.black),
                                  child: Icon(
                                    AntIcons.close_circle_outline,
                                    size: 25,
                                    color: Colors.white,
                                  ),
                                ))),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
