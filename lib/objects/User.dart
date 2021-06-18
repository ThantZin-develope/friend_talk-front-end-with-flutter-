import 'dart:core';
import 'dart:typed_data';

import 'SystemUser.dart';

class User {
  int user_id;

  String birthDate;

  int rsStatus;

  SystemUser suser;

  int role;

  int createdId;

  int updatedId;

  String createdDate;

  String updatedDate;

  int del_flag;

  String userName;

  int gender;

  String stickyNotes;

  User(
      {this.user_id,
      this.birthDate,
      this.rsStatus,
      this.suser,
      this.role,
      this.createdId,
      this.updatedId,
      this.createdDate,
      this.stickyNotes,
      this.updatedDate,
      this.del_flag,
      this.userName,
      this.gender});

  User.fromJSON(Map<String, dynamic> jsonData) {
    this.user_id = jsonData["user_id"];
    this.birthDate = jsonData["birthDate"];
    this.rsStatus = jsonData["rsStatus"];
    if (jsonData.containsKey("suser")) {
      this.suser = SystemUser.fromJSON(jsonData["suser"]);
    }

    this.role = jsonData["role"];
    this.createdId = jsonData["createdId"];
    this.updatedId = jsonData["updatedId"];
    this.createdDate = jsonData["createdDate"];
    this.updatedDate = jsonData["updatedDate"];
    this.del_flag = jsonData["del_flag"];
    this.userName = jsonData["userName"];
    this.gender = jsonData["gender"];
    this.stickyNotes = jsonData["stickyNotes"];
  }

  Map<String, dynamic> toJSON() {
    return {
      "user_id": this.user_id,
      "birthDate": this.birthDate,
      "rsStatus": this.rsStatus,
      "suser": this.suser == null ? null : this.suser.toJSON(),
      "createdDate": this.createdDate,
      "updatedDate": this.updatedDate,
      "userName": this.userName,
      "gender": this.gender,
      "stickyNotes" : this.stickyNotes
    };
  }

  // Map<String, dynamic> toJsonForpandcvPic(){
  //   return{
  //     "user_id" : this.user_id,
  //     "profilePic" : this.profilePic,
  //     "coverPic" : this.coverPic,
  //   };
  // }
}
