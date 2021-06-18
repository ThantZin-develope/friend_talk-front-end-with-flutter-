import 'package:flutter/cupertino.dart';
import 'package:my_app/util/RequestApi.dart';

class SystemMessageService{

  static Future<dynamic> getOldMessages(String sender_id , String recipent_id , BuildContext context)async{
try{
 var result = await RequestApi.getRequest(true, "/api/messages", context , params: {"sender_id" : sender_id , "recipent_id" : recipent_id});
return result;
}catch(error){
  return null;
}
  }

  static Future<dynamic> getLastmessages(BuildContext context) async {
    try{
var result = await RequestApi.getRequest(true, "/api/last-messages", context);
return result;
    }catch(error){
      return null;
    }
  }
}