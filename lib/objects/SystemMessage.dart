import 'package:my_app/objects/User.dart';

class SystemMessage {
  int message_id;
  String message;
  User sender;
  User recipent;
  int created_id;
  int updated_id;
  String created_date;
  String updated_date;

  SystemMessage(
      {this.message_id,
      this.message,
      this.sender,
      this.recipent,
      this.created_id,
      this.updated_id,
      this.created_date,
      this.updated_date});

  SystemMessage.fromJSON(Map<String, dynamic> jsonData) {
    this.message_id = jsonData["message_id"];
    this.message = jsonData["message"];
    this.sender = User.fromJSON(jsonData["sender"]);
    this.recipent = User.fromJSON(jsonData["recipent"]);
    this.created_id = jsonData["created_id"];
    this.updated_id = jsonData["updated_id"];
    this.created_date = jsonData["created_date"];
    this.updated_date = jsonData["updated_date"];
  }

  Map<String, dynamic> toJSON() {
    return {
      "message_id": this.message_id,
      "message": this.message,
      "sender": this.sender.toJSON(),
      "recipent": this.recipent.toJSON(),
      "created_id": this.created_id,
      "updated_id": this.updated_id,
      "created_date": this.created_date,
      "updated_date": this.updated_date
    };
  }
}
