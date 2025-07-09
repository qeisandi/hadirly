// To parse this JSON data, do
//
//     final errorParams = errorParamsFromJson(jsonString);

import 'dart:convert';

ErrorParams errorParamsFromJson(String str) =>
    ErrorParams.fromJson(json.decode(str));

String errorParamsToJson(ErrorParams data) => json.encode(data.toJson());

class ErrorParams {
  String? message;
  dynamic data;

  ErrorParams({this.message, this.data});

  factory ErrorParams.fromJson(Map<String, dynamic> json) =>
      ErrorParams(message: json["message"], data: json["data"]);

  Map<String, dynamic> toJson() => {"message": message, "data": data};
}
