import 'package:taxi_driver/model/UserDetailModel.dart';

class LoginResponse {
  UserData? data;
  String? message;
  bool? isUserExist;

  LoginResponse({this.data, this.message, this.isUserExist});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
      message: json['message'],
      isUserExist: json['is_user_exist'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['is_user_exist'] = this.isUserExist;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}