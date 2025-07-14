// To parse this JSON data, do
//
//     final profilePhotoResponse = profilePhotoResponseFromJson(jsonString);

import 'dart:convert';

ProfilePhotoResponse profilePhotoResponseFromJson(String str) =>
    ProfilePhotoResponse.fromJson(json.decode(str));

String profilePhotoResponseToJson(ProfilePhotoResponse data) =>
    json.encode(data.toJson());

class ProfilePhotoResponse {
  String? message;
  ProfilePhotoData? data;

  ProfilePhotoResponse({this.message, this.data});

  factory ProfilePhotoResponse.fromJson(
    Map<String, dynamic> json,
  ) => ProfilePhotoResponse(
    message: json["message"],
    data: json["data"] == null ? null : ProfilePhotoData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class ProfilePhotoData {
  int? id;
  String? name;
  String? email;
  String? batchKe;
  String? trainingTitle;
  Batch? batch;
  Training? training;
  String? jenisKelamin;
  String? profilePhoto;

  ProfilePhotoData({
    this.id,
    this.name,
    this.email,
    this.batchKe,
    this.trainingTitle,
    this.batch,
    this.training,
    this.jenisKelamin,
    this.profilePhoto,
  });

  factory ProfilePhotoData.fromJson(Map<String, dynamic> json) =>
      ProfilePhotoData(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        batchKe: json["batch_ke"],
        trainingTitle: json["training_title"],
        batch: json["batch"] == null ? null : Batch.fromJson(json["batch"]),
        training:
            json["training"] == null
                ? null
                : Training.fromJson(json["training"]),
        jenisKelamin: json["jenis_kelamin"],
        profilePhoto: json["profile_photo"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "batch_ke": batchKe,
    "training_title": trainingTitle,
    "batch": batch?.toJson(),
    "training": training?.toJson(),
    "jenis_kelamin": jenisKelamin,
    "profile_photo": profilePhoto,
  };
}

class Batch {
  int? id;
  String? batchKe;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? createdAt;
  DateTime? updatedAt;

  Batch({
    this.id,
    this.batchKe,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Batch.fromJson(Map<String, dynamic> json) => Batch(
    id: json["id"],
    batchKe: json["batch_ke"],
    startDate:
        json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
    endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
    createdAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt:
        json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "batch_ke": batchKe,
    "start_date": startDate?.toIso8601String(),
    "end_date": endDate?.toIso8601String(),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class Training {
  int? id;
  String? title;
  dynamic description;
  dynamic participantCount;
  dynamic standard;
  dynamic duration;
  DateTime? createdAt;
  DateTime? updatedAt;

  Training({
    this.id,
    this.title,
    this.description,
    this.participantCount,
    this.standard,
    this.duration,
    this.createdAt,
    this.updatedAt,
  });

  factory Training.fromJson(Map<String, dynamic> json) => Training(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    participantCount: json["participant_count"],
    standard: json["standard"],
    duration: json["duration"],
    createdAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt:
        json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "participant_count": participantCount,
    "standard": standard,
    "duration": duration,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

// Model untuk upload foto profil (PUT /api/profile/photo)
class ProfilePhotoUploadResponse {
  String? message;
  ProfilePhotoUploadData? data;

  ProfilePhotoUploadResponse({this.message, this.data});

  factory ProfilePhotoUploadResponse.fromJson(Map<String, dynamic> json) =>
      ProfilePhotoUploadResponse(
        message: json["message"],
        data:
            json["data"] == null
                ? null
                : ProfilePhotoUploadData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class ProfilePhotoUploadData {
  String? profilePhoto;

  ProfilePhotoUploadData({this.profilePhoto});

  factory ProfilePhotoUploadData.fromJson(Map<String, dynamic> json) =>
      ProfilePhotoUploadData(profilePhoto: json["profile_photo"]);

  Map<String, dynamic> toJson() => {"profile_photo": profilePhoto};
}
