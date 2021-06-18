import 'package:flutter/cupertino.dart';

import 'package:my_app/objects/Post.dart';
import 'package:my_app/objects/SystemUser.dart';
import 'package:my_app/objects/User.dart';
import 'package:my_app/util/RequestApi.dart';

Future<dynamic> register(User user, BuildContext context) async {
  try {

    var body = user.toJSON();


    var result =
        await RequestApi.postRequest(false, "/api/auth/sign-up", body, context);
    return result;
  } catch (error) {
    return null;
  }
}

Future<dynamic> userModify(
    User user, BuildContext context, String op_type) async {
  try {
    var body = user.toJSON();
    var result = await RequestApi.putRequest(
        true, "/api/user-modify", body, context,
        params: {"op_type": op_type});
    return result;
  } catch (error) {
    return null;
  }
}

Future<void> stickyWrite(User user, BuildContext context) async {
  try {
    var body = user.toJSON();
    var result =
        await RequestApi.putRequest(true, "/api/sticky-write", body, context , isvoid: true);
    return result;
  } catch (error) {}
}

Future<dynamic> uploadpandcvpic(
    BuildContext context, Post post, String operationType) async {
  try {
    var body = post.toJSON();

    var result = await RequestApi.postRequest(
        true, "/api/upload-pandcvpic/" + operationType, body, context);
    return result;
  } catch (error) {
    return null;
  }
}

Future<dynamic> login(SystemUser user, BuildContext context) async {
  try {
    var body = user.toJSON();

    var result =
        await RequestApi.postRequest(false, "/api/auth/sign-in", body, context);
    return result;
  } catch (error) {
    return null;
  }
}

Future<dynamic> getAllUsers(BuildContext context) async {
  try {
    var result = await RequestApi.getRequest(true, "/api/users", context);
    return result;
  } catch (error) {
    return null;
  }
}
