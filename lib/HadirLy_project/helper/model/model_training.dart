// To parse this JSON data, do
//
//     final getTrainings = getTrainingsFromJson(jsonString);

import 'dart:convert';

GetTrainings getTrainingsFromJson(String str) =>
    GetTrainings.fromJson(json.decode(str));

String getTrainingsToJson(GetTrainings data) => json.encode(data.toJson());

class GetTrainings {
  String? message;
  List<Trainings>? data;

  GetTrainings({this.message, this.data});

  factory GetTrainings.fromJson(Map<String, dynamic> json) => GetTrainings(
    message: json["message"],
    data:
        json["data"] == null
            ? []
            : List<Trainings>.from(
              json["data"]!.map((x) => Trainings.fromJson(x)),
            ),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Trainings {
  int? id;
  String? title;

  Trainings({this.id, this.title});

  factory Trainings.fromJson(Map<String, dynamic> json) =>
      Trainings(id: json["id"], title: json["title"]);

  Map<String, dynamic> toJson() => {"id": id, "title": title};
}
