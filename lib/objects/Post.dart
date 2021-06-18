import 'dart:typed_data';

import 'package:my_app/objects/PostDetail.dart';
import 'package:my_app/objects/User.dart';

class Post {
  int post_id;
  String status_body;
  Uint8List picture;
  User owner;
  int created_id;
  int updated_id;
  String created_date;
  String updated_date;
  List<PostDetail> post_details_list = [];
  int noOfComments;
  bool hasPicture;
  Post({
    this.post_id,
    this.status_body,
    this.picture,
    this.owner,
    this.created_id,
    this.updated_id,
    this.created_date,
    this.hasPicture,
    this.updated_date,
    this.noOfComments,
  });

  Post.fromJSON(Map<String, dynamic> jsonData) {
    this.post_id = jsonData["post_id"];
    this.status_body = jsonData["status_body"];

    this.owner = User.fromJSON(jsonData["owner"]);
    this.created_id = jsonData["created_id"];
    this.updated_id = jsonData["updated_id"];
    this.created_date = jsonData["created_date"];
    this.updated_date = jsonData["updated_date"];
    if (jsonData.containsKey("hasPicture")) {
      this.hasPicture = jsonData["hasPicture"];
    }
    if (jsonData.containsKey("noOfComments")) {
      this.noOfComments = jsonData["noOfComments"];
    }
    if (jsonData.containsKey("post_details_list") && jsonData["post_details_list"] != null) {
      for (var i = 0; i < jsonData["post_details_list"].length; i++) {
        this
            .post_details_list
            .add(PostDetail.fromJSON(jsonData["post_details_list"][i]));
      }
    }
  }

  Map<String, dynamic> toJSON() {
    return {
      "post_id": this.post_id,
      "status_body": this.status_body,
      "picture": this.picture,
      "owner": this.owner.toJSON(),
      "created_id": this.created_id,
      "updated_id": this.updated_id,
      "created_date": this.created_date,
      "updated_date": this.updated_date,
    };
  }
}
