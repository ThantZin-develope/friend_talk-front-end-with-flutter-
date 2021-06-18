import 'dart:async';
import 'dart:convert';

import 'package:my_app/objects/SystemMessage.dart';
import 'package:my_app/objects/SystemNoti.dart';
import 'package:my_app/objects/User.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

StreamController messagestreamController =
    StreamController<SystemMessage>.broadcast();
StreamController notistreamController =
    StreamController<SystemNoti>.broadcast();

String onetooneBroadCastUrl = "/tztft/one-to-one";
String onetomanyBroadCastUrl = "/tztft/one-to-many";
String webSocketEndPoint =
    "ws://192.168.100.2:1010/tztft-0.0.1-SNAPSHOT/tzt-ws";
User currentUserWS;
String authTokenWS = '';
void onConnect(StompFrame frame) async {
  print("at on connect tpken =>" + authTokenWS);
  try {
    stompClient.subscribe(
      destination: '/user-id/' + currentUserWS.user_id.toString() + "/messages",
      callback: (frame) async {
        try {
          print("Message recieved");
          var result = json.decode(frame.body);
          if (!messagestreamController.isClosed) {
            messagestreamController.sink.add(SystemMessage.fromJSON(result));
          }
        } catch (error) {
          print("on subscring =>" + error.toString());
        }
      },
    );

    stompClient.subscribe(
        destination: "/noti/post-broadcast",
        callback: (frame) {
          try {
            var result = json.decode(frame.body);

            notistreamController.sink.add(SystemNoti.fromJSON(result));
          } catch (error) {
            print("on subscring =>" + error.toString());
          }
        });
  } catch (error) {
    print("Socket error =>" + error.toString());
  }
}

void restartmessageStreamController() {
  messagestreamController = new StreamController<SystemMessage>.broadcast();
}
 StompClient stompClient;

messageSend(String token, Map<String, dynamic> data) async {
 
    stompClient.send(
        destination: onetooneBroadCastUrl,
        body: json.encode(data),
        headers: {'Authorization': "Bearer " + token});
  
}

postNotiBroadCast(String token, Map<String, dynamic> data) async {

    stompClient.send(
        destination: onetomanyBroadCastUrl,
        body: json.encode(data),
        headers: {'Authorization': "Bearer " + token});
}


