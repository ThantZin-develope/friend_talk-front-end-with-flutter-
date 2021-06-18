import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/commons/SystemAlert.dart';

import 'package:my_app/constants/UrlConstants.dart';
import 'package:my_app/util/SystemException.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestApi {
  static Future<Map<String, String>> requestHeaders(bool isAuthorized) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8'
    };
    if (isAuthorized) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
    
      headers.putIfAbsent("Authorization",
          () => "Bearer " + preferences.getString("auth_token"));
    }

    return headers;
  }
  static String artifactId = "/tztft-0.0.1-SNAPSHOT";
  static getRequest(bool isAuthorized, String requestUrl, BuildContext context,
      {Map<String, dynamic> params}) async {
    try {
      var response = await http.get(
          Uri.http(UrlConstants.apiRequest,artifactId+ requestUrl, params),
          headers: await requestHeaders(isAuthorized));
      var result = json.decode(response.body);
      print(response.statusCode);
      if (response.statusCode == 401) {
        print("401");
        throw new UnauthorizedException(result["error"].toString());
      } else if (response.statusCode == 405) {
        print("405");
        throw new NotAllowedException(result["message"].toString());
      } else if (response.statusCode == 404) {
        print("404");
        throw new NotFoundException(result["message"].toString());
      } else if (response.statusCode == 500) {
        print("500");
        throw new InternalServerErrorException(result["message"].toString());
      } else {
        return result;
      }
    } on UnauthorizedException catch (error) {
      await httpErrorHandler(1, error.cause, context);
    } on NotAllowedException catch (error) {
      await httpErrorHandler(2, error.cause, context);
    } on NotFoundException catch (error) {
      await httpErrorHandler(2, error.cause, context);
    } on InternalServerErrorException catch (error) {
      await httpErrorHandler(2, error.cause, context);
    } catch (error) {
      print(error.toString());
      await httpErrorHandler(3, error.toString(), context);
    }
  }

  static getUnit8List(
      bool isAuthorized, String requestUrl, BuildContext context,
      {Map<String, dynamic> params}) async {
    try {
      var response = await http.get(
          Uri.http(UrlConstants.apiRequest,artifactId+ requestUrl, params),
          headers: await requestHeaders(isAuthorized));
      return response.bodyBytes;
    } catch (error) {
      print(error.toString());
      await httpErrorHandler(3, error.toString(), context);
    }
  }

  static postRequest(
      bool isAuthorized, String requestUrl, dynamic body, BuildContext context,
      {Map<String, dynamic> params}) async {
    try {
      var response = await http.post(
          Uri.http(UrlConstants.apiRequest,artifactId +requestUrl, params),
          headers: await requestHeaders(isAuthorized),
          body: jsonEncode(body));
      var result = json.decode(response.body);

      if (response.statusCode == 401) {
        print("401");
        throw new UnauthorizedException(result["error"].toString());
      } else if (response.statusCode == 405) {
        print("405");

        throw new NotAllowedException(result["message"].toString());
      } else if (response.statusCode == 404) {
        print("404");
        throw new NotFoundException(result["message"].toString());
      } else if (response.statusCode == 500) {
        print("500");
        throw new InternalServerErrorException(result["message"].toString());
      } else {
        return result;
      }
    } on UnauthorizedException catch (error) {
      await httpErrorHandler(1, error.cause, context);
    } on NotAllowedException catch (error) {
      await httpErrorHandler(2, error.cause, context);
    } on NotFoundException catch (error) {
      await httpErrorHandler(2, error.cause, context);
    } on InternalServerErrorException catch (error) {
      await httpErrorHandler(2, error.cause, context);
    } catch (error) {
      await httpErrorHandler(3, error.toString(), context);
    }
  }

  static putRequest(
      bool isAuthorized, String requestUrl, dynamic body, BuildContext context,
      {Map<String, dynamic> params, bool isvoid = false}) async {
    try {
      var response = await http.put(
          Uri.http(UrlConstants.apiRequest,artifactId+ requestUrl, params),
          headers: await requestHeaders(isAuthorized),
          body: jsonEncode(body));
      var result;
      if (!isvoid) {
        result = json.decode(response.body);
      }

      if (response.statusCode == 401) {
        print("401");
        throw new UnauthorizedException(result["error"].toString());
      } else if (response.statusCode == 405) {
        print("405");
        throw new NotAllowedException(result["message"].toString());
      } else if (response.statusCode == 404) {
        print("404");
        throw new NotFoundException(result["message"].toString());
      } else if (response.statusCode == 500) {
        print("500");
        throw new InternalServerErrorException(result["message"].toString());
      } else {
        return result;
      }
    } on UnauthorizedException catch (error) {
      await httpErrorHandler(1, error.cause, context);
    } on NotAllowedException catch (error) {
      await httpErrorHandler(2, error.cause, context);
    } on NotFoundException catch (error) {
      await httpErrorHandler(2, error.cause, context);
    } on InternalServerErrorException catch (error) {
      await httpErrorHandler(2, error.cause, context);
    } catch (error) {
      await httpErrorHandler(3, error.toString(), context);
    }
  }

  static Future<void> logout(
      String requestUrl, BuildContext context, dynamic body) async {
    try {
      var response = await http.put(
          Uri.http(UrlConstants.apiRequest,artifactId+ requestUrl),
          headers: await requestHeaders(true),
          body: jsonEncode(body));
    } catch (error) {
      await httpErrorHandler(3, error.toString(), context);
    }
  }

  static Future<dynamic> picUpload(File file, String path, context) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String auth_token = preferences.getString("auth_token");
      var request = new http.MultipartRequest(
          "POST", Uri.parse("http://" + UrlConstants.apiRequest +artifactId+ path));
      Map<String, String> headers = {"Authorization": "Bearer " + auth_token};

      request.headers.addAll(headers);
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
      ));

      var response = await request.send();
      var result;
      response.stream.transform(utf8.decoder).listen((value) {
        result = value;
      });

      if (response.statusCode == 401) {
        print("401");
        throw new UnauthorizedException(result["error"].toString());
      } else if (response.statusCode == 405) {
        print("405");
        throw new NotAllowedException(result["message"].toString());
      } else if (response.statusCode == 404) {
        print("404");
        throw new NotFoundException(result["message"].toString());
      } else if (response.statusCode == 500) {
        print("500");
        throw new InternalServerErrorException(result["message"].toString());
      } else {
        return result;
      }
    } on UnauthorizedException catch (error) {
      await httpErrorHandler(1, error.cause, context);
    } on NotAllowedException catch (error) {
      await httpErrorHandler(2, error.cause, context);
    } on NotFoundException catch (error) {
      await httpErrorHandler(2, error.cause, context);
    } on InternalServerErrorException catch (error) {
      await httpErrorHandler(2, error.cause, context);
    } catch (error) {
      await httpErrorHandler(3, error.toString(), context);
    }
  }

  static httpErrorHandler(
      int type, String message, BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    //1 unauthorized 2 for rest of invalid server responses
    switch (type) {
      case 1:
        {
          bool isClose = await SystemAlert.showAlert(0, message, context);
          if (isClose) {
            preferences.clear();
            Phoenix.rebirth(context);
          }
          break;
        }
      case 2:
        {
          await SystemAlert.showAlert(0, message, context);
          break;
        }
      default:
        {
          await SystemAlert.showAlert(0, message, context);
          break;
        }
    }
  }
}
