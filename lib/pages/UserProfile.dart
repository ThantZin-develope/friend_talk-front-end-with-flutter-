import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/objects/User.dart';
import 'package:my_app/pages/Profile.dart';

class UserProfile extends StatefulWidget {
  User profileOwner;
  User currentUser;
  String auth_token;
  UserProfile({Key key, this.profileOwner, this.currentUser, this.auth_token})
      : super(key: key);
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.profileOwner.userName.toString() + " profile"),
      ),
      body: Profile(
        profileOwner: widget.profileOwner,
        currentUser: widget.currentUser,
        authToken: widget.auth_token,
      ),
    );
  }
}
