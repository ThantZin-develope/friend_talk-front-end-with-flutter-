import 'dart:core';

import 'package:my_app/objects/Post.dart';
import 'package:my_app/objects/User.dart';

class SystemNoti {
  int noti_id;
  Post post;
  int noti_type;
  int reaction;
  String noti_message;
  int created_id;
  String created_date;
  User notimaker;

  SystemNoti(
      {this.noti_id,
      this.post,
      this.noti_type,
      this.reaction,
      this.noti_message,
      this.created_id,
      this.created_date,
      this.notimaker});

  SystemNoti.fromJSON(Map<String, dynamic> jsonData) {
    this.noti_id = jsonData["noti_id"];
    this.post = Post.fromJSON(jsonData["post"]);
    this.noti_type = jsonData["noti_type"];
    this.reaction = jsonData["reaction"];
    this.noti_message = jsonData["noti_message"];
    this.notimaker = User.fromJSON(jsonData["notimaker"]);
    this.created_id = jsonData["created_id"];
    this.created_date = jsonData["created_date"];
  }

  Map<String, dynamic> toJSON() {
    return {
      "noti_type": this.noti_type,
      "post": this.post.toJSON(),
      "noti_id": this.noti_id,
      "reaction": this.reaction,
      "noti_message": this.noti_message,
      "notimaker": this.notimaker.toJSON(),
      "created_id": this.created_id,
      "created_date": this.created_date,
    };
  }
}
