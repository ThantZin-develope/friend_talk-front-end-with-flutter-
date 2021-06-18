import 'package:ant_icons/ant_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';

class SystemReactionButtons extends StatelessWidget {
  bool hasChecked;
  Function reactionChange;
  int reactionIndex;

  SystemReactionButtons(
      {Key key,
      @required this.hasChecked,
      this.reactionChange,
      this.reactionIndex})
      : super(key: key);

//   _SystemReactionButtonsState createState() => _SystemReactionButtonsState();
// }

// class _SystemReactionButtonsState extends State<SystemReactionButtons> {

  Reaction like = Reaction(
      icon: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Icon(
              AntIcons.like,
              color: Colors.blue,
              size: 20,
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "Like",
            style: TextStyle(color: Colors.blue),
          )
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
      previewIcon: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Icon(
          AntIcons.like,
          size: 25,
          color: Colors.blue,
        ),
      ));

  Reaction defaultReaction = Reaction(
      icon: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Icon(
              AntIcons.like_outline,
              size: 20,
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Text("Like")
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
      previewIcon: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Icon(
          AntIcons.like_outline,
          size: 25,
        ),
      ));
  List<Reaction> reactions = [
    Reaction(
        icon: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Icon(
                AntIcons.like,
                color: Colors.blue,
                size: 20,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              "Like",
              style: TextStyle(color: Colors.blue),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        previewIcon: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Icon(
            AntIcons.like,
            size: 25,
            color: Colors.blue,
          ),
        )),
    Reaction(
        icon: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                "assets/love.png",
                height: 20,
                width: 20,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              "Love",
              style: TextStyle(color: Colors.red[900]),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        previewIcon: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Image.asset(
            "assets/love.png",
            height: 25,
            width: 25,
          ),
        )),
    Reaction(
        icon: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                "assets/blush.png",
                height: 20,
                width: 20,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              "Mwah",
              style: TextStyle(color: Colors.yellowAccent),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        previewIcon: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Image.asset(
            "assets/blush.png",
            height: 25,
            width: 25,
          ),
        )),
    Reaction(
        icon: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                "assets/haha.png",
                height: 20,
                width: 20,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              "Haha",
              style: TextStyle(color: Colors.yellow),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        previewIcon: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Image.asset(
            "assets/haha.png",
            height: 25,
            width: 25,
          ),
        )),
    Reaction(
        icon: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                "assets/wow.png",
                height: 20,
                width: 20,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              "Wow",
              style: TextStyle(color: Colors.yellowAccent),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        previewIcon: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Image.asset(
            "assets/wow.png",
            height: 25,
            width: 25,
          ),
        )),
    Reaction(
        icon: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                "assets/sad.png",
                height: 20,
                width: 20,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              "Sad",
              style: TextStyle(color: Colors.yellowAccent),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        previewIcon: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Image.asset(
            "assets/sad.png",
            height: 25,
            width: 25,
          ),
        )),
    Reaction(
        icon: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.asset(
                "assets/angry.png",
                height: 20,
                width: 20,
              ),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              "Angry",
              style: TextStyle(color: Colors.orange),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        previewIcon: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Image.asset(
            "assets/angry.png",
            height: 25,
            width: 25,
          ),
        ))
  ];


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: FlutterReactionButtonCheck(
          boxPadding: EdgeInsets.all(10),
          boxItemsSpacing: 5,
          isChecked: hasChecked,
          boxDuration: Duration(milliseconds: 100),
          boxAlignment: Alignment.bottomLeft,
          boxPosition: Position.BOTTOM,
          initialReaction: defaultReaction,
          selectedReaction: hasChecked ? reactions[reactionIndex] : null,
          onReactionChanged: (reaction, index, isChecked) {
            reactionChange(index);
          },
          reactions: this.reactions),
    );
  }
}
