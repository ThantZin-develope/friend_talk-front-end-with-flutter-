
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:my_app/pages/Error.dart';
import 'package:my_app/pages/ForgetPassword.dart';

import 'package:my_app/pages/MessageDetail.dart';
import 'package:my_app/pages/Register.dart';
import 'package:my_app/pages/Test.dart';


Route generateRoute(RouteSettings routeSettings) {
  switch(routeSettings.name){
     case ForgetPasswordRoute :
    return MaterialPageRoute(builder: (context) => ForgetPassword());
    break;
    case RegisterRoute :
    return MaterialPageRoute(builder: (context) => Register());
    break;
    case MessageDetailRoute :
    return MaterialPageRoute(builder: (context) => MessengerDetail());
    break;
    case TestRoute :
    return MaterialPageRoute(builder: (context) => Test());
    break;
    default:
    return MaterialPageRoute(builder: (context) => ErrorPage());
    break;
  }
}

const ForgetPasswordRoute = "/forget-password";
const RegisterRoute = "/register-route";
const MessageDetailRoute = "/message-detail";
const TestRoute = "/test";

