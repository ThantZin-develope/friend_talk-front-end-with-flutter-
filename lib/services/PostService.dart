import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:my_app/objects/Post.dart';
import 'package:my_app/objects/PostDetail.dart';
import 'package:my_app/util/RequestApi.dart';

class PostService {
  static Future<dynamic> createPost(Post post, context) async {
    try {
      var body = post.toJSON();
      var result =
          await RequestApi.postRequest(true, "/api/create-post", body, context);
      return result;
    } catch (error) {
      return null;
    }
  }

  static Future<dynamic> getuserPosts(String id, BuildContext context) async {
    try {
      var result = await RequestApi.getRequest(true, "/api/user_posts", context,
          params: {"id": id});
      return result;
    } catch (error) {
      return null;
    }
  }

  static Future<Uint8List> getPostImage(
      BuildContext context, String post_id) async {
    try {
      var result = await RequestApi.getUnit8List(
          true, "/api/post-picture", context,
          params: {"id": post_id});
      return result;
    } catch (error) {
      return null;
    }
  }

  static Future<dynamic> whenUserReact(
      PostDetail postDetail, BuildContext context) async {
    try {
      var body = postDetail.toJSON();
      var result =
          await RequestApi.postRequest(true, "/api/user-react", body, context);
      return result;
    } catch (error) {}
  }

  static Future<dynamic> getPosts(
      String pageIndex, BuildContext context) async {

    try {
      var result = await RequestApi.getRequest(true, "/api/getPosts", context,
          params: {"pageIndex": pageIndex});
      return result;
    } catch (error) {
      return null;
    }
  }

  static Future<dynamic> deletePost(Post post, BuildContext context) async {
    try {
      var body = post.toJSON();
      var result =
          await RequestApi.postRequest(true, "/api/post-delete", body, context);
      return result;
    } catch (error) {
      return null;
    }
  }

  static Future<dynamic> searchPost(String pattern , BuildContext context) async{
    try{
      var result = await RequestApi.getRequest(true, "/api/search-posts", context , params: {"pattern" :pattern });
      return result;
    }catch(error){
      return null;
    }

  }
 static Future<dynamic> findById(String pattern , BuildContext context) async{
    try{
      var result = await RequestApi.getRequest(true, "/api/findbyid", context , params: {"post_id" :pattern });
      return result;
    }catch(error){
      return null;
    }

  }
    static Future<dynamic> modifyPost(Post post, BuildContext context) async {
    try {
      var body = post.toJSON();
      var result =
          await RequestApi.putRequest(true, "/api/post-modify", body, context);
      return result;
    } catch (error) {
      return null;
    }
  }
}
