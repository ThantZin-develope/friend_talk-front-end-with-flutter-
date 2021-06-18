import 'package:flutter/cupertino.dart';
import 'package:my_app/util/RequestApi.dart';

class SystemUserService {
  static Future<dynamic> changePassowrd(String id, String oldPassword,
      String newPassword, BuildContext context) async {
    try {
      var result = await RequestApi.postRequest(
          true, "/api/change-password", null, context , params: {"id" : id , "oldPassword" : oldPassword , "newPassword" : newPassword});
          return result;
    } catch (error) {
      return null;
    }
  }
}
