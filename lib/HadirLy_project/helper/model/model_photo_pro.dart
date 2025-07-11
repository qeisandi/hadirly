// To parse this JSON data, do
//
//     final photoProfile = photoProfileFromJson(jsonString);

import 'dart:convert';

PhotoProfile photoProfileFromJson(String str) =>
    PhotoProfile.fromJson(json.decode(str));

String photoProfileToJson(PhotoProfile data) => json.encode(data.toJson());

class PhotoProfile {
  String? message;
  Photo? data;

  PhotoProfile({this.message, this.data});

  factory PhotoProfile.fromJson(Map<String, dynamic> json) => PhotoProfile(
    message: json["message"],
    data: json["data"] == null ? null : Photo.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class Photo {
  String? profilePhoto;

  Photo({this.profilePhoto});

  factory Photo.fromJson(Map<String, dynamic> json) =>
      Photo(profilePhoto: json["profile_photo"]);

  Map<String, dynamic> toJson() => {"profile_photo": profilePhoto};
}
