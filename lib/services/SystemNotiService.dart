import 'package:flutter/cupertino.dart';
import 'package:my_app/util/RequestApi.dart';

class SystemNotiService {
  static Future<dynamic> getUserNotis(
      String user_id, String index ,  BuildContext context) async {
    try {
      var result = await RequestApi.getRequest(true, "/api/user-notis", context , params: {"user_id" : user_id , "index" : index});
      return result;

    } catch (error) {
      return null;
    }
  }
}
