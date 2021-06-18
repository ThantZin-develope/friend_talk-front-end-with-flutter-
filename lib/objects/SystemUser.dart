
import 'dart:core';
class SystemUser {
  int sys_user_id;

  String resetPasswordCode;

  int del_flag;

  int createdId;

  int updatedId;

  String createdDate;

  String updatedDate;

  String loginStr;

  String password;

  SystemUser(
      {this.sys_user_id,
      this.resetPasswordCode,
      this.del_flag,
      this.createdId,
      this.updatedId,
      this.createdDate,
      this.updatedDate,
      this.loginStr,
      this.password});

  SystemUser.fromJSON(Map<String, dynamic> jsonData) {
    this.sys_user_id = jsonData["sys_user_id"];
    this.resetPasswordCode = jsonData["resetPasswordCode"];
    this.del_flag = jsonData["del_flag"];
    this.createdId = jsonData["createdId"];
    this.updatedId = jsonData["updatedId"];
    this.createdDate = jsonData["createdDate"];
    this.updatedDate = jsonData["updatedDate"];
    this.loginStr = jsonData["loginStr"];
    
  }

  Map<String, dynamic> toJSON() {
    return {
      "resetPasswordCode": this.resetPasswordCode,
      "createdDate": this.createdDate,
      "updatedDate": this.updatedDate,
      "loginStr": this.loginStr,
      "password": this.password,
      "del_flag" : this.del_flag,
    };
  }
}
