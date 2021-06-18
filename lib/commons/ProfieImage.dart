import 'package:flutter/cupertino.dart';

class ProfileImage extends StatelessWidget {
  String auth_token;
  String profileUrl;
  int valueKey;
  double height;
  double width;
  double radius;
  ProfileImage(
      {Key key,
      @required this.auth_token,
      @required this.profileUrl,
      this.radius,
      this.height,
      this.width,
      this.valueKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(this.radius == null ? 25 : this.radius),
      child: FadeInImage(
        placeholder: AssetImage("assets/defaultuser.jpg"),
        height: this.height == null ? 40 : this.height,
        width: this.width == null ? 40 : this.width,
        fit: BoxFit.fill,
        key: ValueKey(valueKey),
        image: NetworkImage(
          profileUrl,
          headers: {"Authorization": "Bearer " + this.auth_token},
        ),
      ),
    );
  }
}
