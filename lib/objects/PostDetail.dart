import 'package:my_app/objects/Post.dart';
import 'package:my_app/objects/User.dart';

class PostDetail {
  int post_detail_id;
  Post post;
  User reactor;
  int user_seen;
  int user_reaction;
  int created_id;
  int updated_id;
  String created_date;
  String updated_date;

  PostDetail(
      {this.post_detail_id,
      this.post,
      this.reactor,
      this.user_seen,
      this.user_reaction,
      this.created_id,
      this.updated_id,
      this.created_date,
      this.updated_date});

  PostDetail.fromJSON(Map<String, dynamic> jsonData) {
    this.post_detail_id = jsonData["post_detail_id"];
    if (jsonData.containsKey("post")) {
      this.post = Post.fromJSON(jsonData["post"]);
    }
    this.reactor = User.fromJSON(jsonData["reactor"]);
    this.user_seen = jsonData["user_seen"];
    this.user_reaction = jsonData["user_reaction"];
    this.created_date = jsonData["created_date"];
    this.updated_date = jsonData["updated_date"];
    this.created_id = jsonData["created_id"];
    this.updated_id = jsonData["updated_id"];
  }

  Map<String, dynamic> toJSON() {
    return {
      "post": this.post.toJSON(),
      "reactor": this.reactor.toJSON(),
      "user_seen": this.user_seen,
      "user_reaction": this.user_reaction,
      "created_id": this.created_id,
      "updated_id": this.updated_id,
      "created_date": this.created_date,
      "updated_date": this.updated_date,
    };
  }
}
