import 'package:my_app/objects/User.dart';

class Comment {
  int comment_id;

  int post_id;

  User owner;

  String comment;

  int created_id;

  int updated_id;

  String created_date;

  String updated_date;

  Comment(
      {this.comment_id,
      this.post_id,
      this.owner,
      this.comment,
      this.created_id,
      this.updated_id,
      this.created_date,
      this.updated_date});

  Comment.fromJSON(Map<String, dynamic> jsonData) {
    this.comment_id = jsonData["comment_id"];
    this.post_id = jsonData["post_id"];
    this.owner = User.fromJSON(jsonData["owner"]);
    this.comment = jsonData["comment"];
    this.created_id = jsonData["created_id"];
    this.updated_id = jsonData["updated_id"];
    this.created_date = jsonData["created_date"];
    this.updated_date = jsonData["updated_date"];
  }

  Map<String, dynamic> toJSON() {
    return {
      "comment_id": this.comment_id,
      "post_id": this.post_id,
      "owner": this.owner.toJSON(),
      "comment": this.comment,
      "created_id": this.created_id,
      "updated_id": this.updated_id,
      "created_date": this.created_date,
      "updated_date": this.updated_date
    };
  }
}
