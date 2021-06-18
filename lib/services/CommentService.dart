import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/objects/Comment.dart';
import 'package:my_app/util/RequestApi.dart';

class CommentService {
  static Future<dynamic> getComments(String post_id , BuildContext context) async{
try{

var result = await RequestApi.getRequest(true, "/api/comments", context , params: {"id" : post_id});
return result;
}catch(error){
  return null;
}
  }

  static Future<dynamic> writeComment(Comment comment , BuildContext context) async {
    try{
      var body = comment.toJSON();

      var result = await RequestApi.postRequest(true, "/api/writeComment", body, context);
      return result;
    }catch(error){
      return null;
    }
  }
}