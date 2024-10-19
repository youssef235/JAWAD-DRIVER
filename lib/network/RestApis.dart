import 'dart:convert';
import 'dart:io';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:taxi_driver/model/DocumentListModel.dart';
import 'package:taxi_driver/model/RideDetailModel.dart';
import 'package:taxi_driver/model/RiderListModel.dart';
import 'package:taxi_driver/model/UserDetailModel.dart';
import 'package:taxi_driver/screens/sign_in_screen.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';

import '../main.dart';
import '../model/AdditionalFeesList.dart';
import '../model/AppSettingModel.dart';
import '../model/ChangePasswordResponseModel.dart';
import '../model/ComplaintCommentModel.dart';
import '../model/ContactNumberListModel.dart';
import '../model/CurrentRequestModel.dart';
import '../model/DriverDocumentList.dart';
import '../model/EarningListModelWeek.dart';
import '../model/LDBaseResponse.dart';
import '../model/LoginResponse.dart';
import '../model/NotificationListModel.dart';
import '../model/PaymentListModel.dart';
import '../model/ProfileUpdateModel.dart';
import '../model/ServiceModel.dart';
import '../model/WalletDetailModel.dart';
import '../model/WalletListModel.dart';
import '../model/WithDrawListModel.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';
import 'NetworkUtils.dart';

Future<LoginResponse> signUpApi(req) async {
  var url = Uri.parse('$DOMAIN_URL/api/driver-register'); // رابط API

  print("Sending request with data: $req"); // طباعة البيانات المرسلة

  var request = http.MultipartRequest('POST', url)
    ..fields['username'] = req['username']
    ..fields['first_name'] = req['first_name']
    ..fields['last_name'] = req['last_name']
    ..fields['password'] = req['password']
    ..fields['email'] = req['email']
    ..fields['service_id'] = req['service_id'].toString()
    ..fields['contact_number'] = req['contact_number']
    ..fields['user_bank_account[account_number]'] = req['account_number']
    ..fields['user_bank_account[bank_name]'] = req['bank_name']
    ..fields['user_bank_account[bank_code]'] = req['bank_code']
    ..fields['user_detail[national_id]'] = req['user_detail_national_id']
    ..fields['user_detail[car_model]'] = req['car_model']
    ..fields['user_detail[car_color]'] = req['car_color']
    ..fields['user_detail[car_plate_number]'] = req['car_plate_number']
    ..fields['user_detail[car_production_year]'] = req['car_production_year']
    ..files.add(await http.MultipartFile.fromPath('profile_image', req['profileImagePath']))
    ..files.add(await http.MultipartFile.fromPath('user_detail[national_id_image]', req['nationalIdImagePath']))
    ..files.add(await http.MultipartFile.fromPath('user_detail[drive_license_image]', req['driveLicenseImagePath']))
    ..files.add(await http.MultipartFile.fromPath('user_detail[car_registeration_image]', req['carRegistrationImagePath']));

  var streamedResponse = await request.send();

  // تحويل الاستجابة إلى http.Response
  var response = await http.Response.fromStream(streamedResponse);

  print("Response status code: ${response.statusCode}"); // طباعة كود الحالة
  print("Response body: ${response.body}"); // طباعة نص الاستجابة

  if (!(response.statusCode >= 200 && response.statusCode <= 206)) {
    try {
      var json = jsonDecode(response.body);

      if (json['status'] == true && json['all_message'] is Map) {
        // عرض رسائل الخطأ المفصلة
        String errorMessage = "";
        json['all_message'].forEach((key, value) {
          errorMessage += "${key}: ${value.join(", ")}\n"; // عرض الرسائل بشكل مفصّل
        });
        throw errorMessage.trim(); // طرح الخطأ بشكل شامل
      } else {
        throw 'خطأ غير معروف: ${json['message'] ?? 'يرجى المحاولة لاحقًا.'}';
      }
    } catch (e) {
      throw 'خطأ في تحليل JSON: ${response.body}';
    }
  }

  return await handleResponse(response).then((json) async {
    var loginResponse = LoginResponse.fromJson(json);
    if (loginResponse.data != null && loginResponse.data!.loginType == LoginTypeOTP) {
      await sharedPref.setString(TOKEN, loginResponse.data!.apiToken.validate());
      await sharedPref.setString(USER_TYPE, loginResponse.data!.userType.validate());
      await sharedPref.setString(FIRST_NAME, loginResponse.data!.firstName.validate());
      await sharedPref.setString(LAST_NAME, loginResponse.data!.lastName.validate());
      await sharedPref.setString(CONTACT_NUMBER, loginResponse.data!.contactNumber.validate());
      await sharedPref.setString(USER_EMAIL, loginResponse.data!.email.validate());
      await sharedPref.setString(USER_NAME, loginResponse.data!.username.validate());
      await sharedPref.setString(ADDRESS, loginResponse.data!.address.validate());
      await sharedPref.setInt(USER_ID, loginResponse.data!.id ?? 0);
      await sharedPref.setString(GENDER, loginResponse.data!.gender.validate());
      await sharedPref.setInt(IS_ONLINE, loginResponse.data!.isOnline ?? 0);
      await sharedPref.setString(UID, loginResponse.data!.uid.validate());
      await sharedPref.setString(LOGIN_TYPE, loginResponse.data!.loginType.validate());
      await sharedPref.setInt(IS_Verified_Driver, loginResponse.data!.isVerifiedDriver ?? 0);

      await appStore.setLoggedIn(true);
      await appStore.setUserEmail(loginResponse.data!.email.validate());
      await appStore.setUserProfile(loginResponse.data!.profileImage.validate());
    }
    return loginResponse;
  }).catchError((e) {
    toast('حدث خطأ: ${e.toString()}'); // إظهار الخطأ للمستخدم
    throw e; // إعادة طرح الخطأ
  });
}

Future<LoginResponse> logInApi(Map request,
    {bool isSocialLogin = false}) async {
  Response response = await buildHttpResponse(
      'social-login' ,
      request: request,
      method: HttpMethod.POST);

  if (!(response.statusCode >= 200 && response.statusCode <= 206)) {
    if (response.body.isJson()) {
      var json = jsonDecode(response.body);

      if (json.containsKey('code') &&
          json['code'].toString().contains('invalid_username')) {
        throw 'invalid_username';
      }
    }
  }

  return await handleResponse(response).then((json) async {
    var loginResponse = LoginResponse.fromJson(json);
    if (loginResponse.data != null) {
      await sharedPref.setString(
          TOKEN, loginResponse.data!.apiToken.validate());
      await sharedPref.setString(
          USER_TYPE, loginResponse.data!.userType.validate());
      await sharedPref.setString(
          FIRST_NAME, loginResponse.data!.firstName.validate());
      await sharedPref.setString(
          LAST_NAME, loginResponse.data!.lastName.validate());
      await sharedPref.setString(
          CONTACT_NUMBER, loginResponse.data!.contactNumber.validate());
      await sharedPref.setString(
          USER_EMAIL, loginResponse.data!.email.validate());
      await sharedPref.setString(
          USER_NAME, loginResponse.data!.username.validate());
      await sharedPref.setString(
          ADDRESS, loginResponse.data!.address.validate());
      await sharedPref.setInt(USER_ID, loginResponse.data!.id ?? 0);
      await sharedPref.setString(GENDER, loginResponse.data!.gender.validate());
      if (loginResponse.data!.isOnline != null)
        await sharedPref.setInt(IS_ONLINE, loginResponse.data!.isOnline ?? 0);
      await sharedPref.setInt(
          IS_Verified_Driver, loginResponse.data!.isVerifiedDriver ?? 0);
      if (loginResponse.data!.uid != null)
        await sharedPref.setString(UID, loginResponse.data!.uid.validate());
      await sharedPref.setString(
          LOGIN_TYPE, loginResponse.data!.loginType.validate());

      await appStore.setLoggedIn(true);
      await appStore.setUserEmail(loginResponse.data!.email.validate());
      await appStore
          .setUserProfile(loginResponse.data!.profileImage.validate());
    }
    return loginResponse;
  }).catchError((e) {
    throw e.toString();
  });
}

Future<VerifyOtpResponse> verifyOtpApi(Map<String, String> request) async {
  try {
    // تنفيذ الطلب
    Response response = await buildHttpResponse(
      'verify-otp',
      request: request,
      method: HttpMethod.POST,
    );

    // التحقق من حالة الاستجابة
    if (response.statusCode >= 200 && response.statusCode <= 206) {
      var json = await handleResponse(response);

      // التحقق من وجود التوكن في الاستجابة
      var token = json['token'];
      if (token != null && token.isNotEmpty) {
        print("Token received: $token");
        await sharedPref.setString(TOKEN, token);
        appStore.isLoggedIn = true; // تأكد من ضبط الحالة على تسجيل الدخول
      } else {
        throw 'Token is missing in the response';
      }

      // تخزين بيانات المستخدم في SharedPreferences
      var user = json['user'];
      if (user != null) {
        await sharedPref.setInt(USER_ID, user['id'] ?? 0);
        await sharedPref.setString(
            USER_TYPE, user['user_type']?.toString() ?? '');
        await sharedPref.setString(
            FIRST_NAME, user['first_name']?.toString() ?? '');
        await sharedPref.setString(
            LAST_NAME, user['last_name']?.toString() ?? '');
        await sharedPref.setString(
            CONTACT_NUMBER, user['contact_number']?.toString() ?? '');
        await sharedPref.setString(USER_EMAIL, user['email']?.toString() ?? '');
        await sharedPref.setString(
            USER_NAME, user['username']?.toString() ?? '');
        await sharedPref.setString(ADDRESS, user['address']?.toString() ?? '');
        await sharedPref.setString(
            USER_PROFILE_PHOTO, user['profile_image']?.toString() ?? '');
        await sharedPref.setString(GENDER, user['gender']?.toString() ?? '');
        await appStore.setUserProfile(user['profile_image']?.toString() ?? '');
      }

      return VerifyOtpResponse.fromJson(json);
    } else {
      throw 'Request failed with status: ${response.statusCode}';
    }
  } catch (e) {
    log('Error: ${e.toString()}');
    throw 'OTP verification failed: ${e.toString()}';
  }
}

class VerifyOtpResponse {
  bool? success;
  String? message;
  UserDetailModel? data;

  VerifyOtpResponse({this.success, this.message, this.data});

  // Factory constructor لتحويل JSON إلى كائن VerifyOtpResponse
  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      success: json['success'],
      message: json['message'],
      data:
          json['data'] != null ? UserDetailModel.fromJson(json['data']) : null,
    );
  }

  // لتحويل كائن VerifyOtpResponse إلى JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

Future<MultipartRequest> getMultiPartRequest(String endPoint,
    {String? baseUrl}) async {
  String url = '${baseUrl ?? buildBaseUrl(endPoint).toString()}';
  log(url);
  return MultipartRequest('POST', Uri.parse(url));
}

Future sendMultiPartRequest(MultipartRequest multiPartRequest,
    {Function(dynamic)? onSuccess, Function(dynamic)? onError}) async {
  multiPartRequest.headers.addAll(buildHeaderTokens());

  await multiPartRequest.send().then((res) {
    res.stream
        .transform(Utf8Decoder())
        .transform(LineSplitter())
        .listen((value) {
      onSuccess?.call(jsonDecode(value));
    });
  }).catchError((error) {
    onError?.call(error.toString());
  });
}

/// Profile Update
Future updateProfile(
    {String? firstName,
    String? lastName,
    String? userEmail,
    String? address,
    String? contactNumber,
    String? gender,
    File? file,
    String? uid,
    String? carModel,
    String? carColor,
    String? carPlateNumber,
    String? carProduction,
    int? serviceId}) async {
  MultipartRequest multiPartRequest =
      await getMultiPartRequest('update-profile');
  multiPartRequest.fields['id'] = sharedPref.getInt(USER_ID).toString();
  multiPartRequest.fields['username'] =
      sharedPref.getString(USER_NAME).validate();
  multiPartRequest.fields['email'] = userEmail ?? appStore.userEmail;
  multiPartRequest.fields['first_name'] = firstName.validate();
  multiPartRequest.fields['last_name'] = lastName.validate();
  multiPartRequest.fields['contact_number'] = contactNumber.validate();
  multiPartRequest.fields['address'] = address.validate();
  multiPartRequest.fields['gender'] = gender.validate();
  if (uid != null) multiPartRequest.fields['uid'] = uid.validate();
  if (carModel.validate().isNotEmpty)
    multiPartRequest.fields['user_detail[car_model]'] = carModel.validate();
  if (carColor.validate().isNotEmpty)
    multiPartRequest.fields['user_detail[car_color]'] = carColor.validate();
  if (carPlateNumber.validate().isNotEmpty)
    multiPartRequest.fields['user_detail[car_plate_number]'] =
        carPlateNumber.validate();
  if (carProduction.validate().isNotEmpty)
    multiPartRequest.fields['user_detail[car_production_year]'] =
        carProduction.validate();
  if (serviceId != null) multiPartRequest.fields['service_id'] = '$serviceId';
  multiPartRequest.fields['player_id'] =
      sharedPref.getString(PLAYER_ID).toString();

  if (file != null)
    multiPartRequest.files
        .add(await MultipartFile.fromPath('profile_image', file.path));

  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      ProfileUpdate res = ProfileUpdate.fromJson(data);
      if (res.data != null) {
        await sharedPref.setString(FIRST_NAME, res.data!.firstName.validate());
        await sharedPref.setString(LAST_NAME, res.data!.lastName.validate());
        await sharedPref.setString(USER_NAME, res.data!.username.validate());
        await sharedPref.setString(USER_ADDRESS, res.data!.address.validate());
        await sharedPref.setString(
            CONTACT_NUMBER, res.data!.contactNumber.validate());
        await sharedPref.setString(GENDER, res.data!.gender.validate());
        await appStore.setUserEmail(res.data!.email.validate());
        if (res.data!.loginType != LoginTypeGoogle)
          await appStore.setUserProfile(res.data!.profileImage.validate());
      }
    }
  }, onError: (error) {
    toast(error.toString());
  });
}

Future<void> logout({bool isDelete = false}) async {
  if (!isDelete) {
    await logoutApi().then((value) async {
      logOutSuccess();
    }).catchError((e) {
      throw e.toString();
    });
  } else {
    logOutSuccess();
  }
}

Future<ChangePasswordResponseModel> changePassword(Map req) async {
  return ChangePasswordResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('change-password',
          request: req, method: HttpMethod.POST)));
}

Future<ChangePasswordResponseModel> forgotPassword(Map req) async {
  return ChangePasswordResponseModel.fromJson(await handleResponse(
      await buildHttpResponse('forget-password',
          request: req, method: HttpMethod.POST)));
}

Future<ServiceModel> getServices() async {
  return ServiceModel.fromJson(await handleResponse(
      await buildHttpResponse('service-list', method: HttpMethod.GET)));
}

Future<UserDetailModel> getUserDetail({int? userId}) async {
  return UserDetailModel.fromJson(await handleResponse(await buildHttpResponse(
      'user-detail?id=$userId',
      method: HttpMethod.GET)));
}

Future<LDBaseResponse> changeStatus(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'update-user-status',
      method: HttpMethod.POST,
      request: request)));
}

Future<LDBaseResponse> saveBooking(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'update-user-status',
      method: HttpMethod.POST,
      request: request)));
}

Future<WalletListModel> getWalletList({required int pageData}) async {
  return WalletListModel.fromJson(await handleResponse(await buildHttpResponse(
      'wallet-list?page=$pageData',
      method: HttpMethod.GET)));
}

Future<PaymentListModel> getPaymentList() async {
  return PaymentListModel.fromJson(await handleResponse(await buildHttpResponse(
      'payment-gateway-list?status=1',
      method: HttpMethod.GET)));
}

Future<LDBaseResponse> saveWallet(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'save-wallet',
      method: HttpMethod.POST,
      request: request)));
}

Future<LDBaseResponse> saveSOS(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'save-sos',
      method: HttpMethod.POST,
      request: request)));
}

Future<ContactNumberListModel> getSosList({int? regionId}) async {
  return ContactNumberListModel.fromJson(await handleResponse(
      await buildHttpResponse(
          regionId != null ? 'sos-list?region_id=$regionId' : 'sos-list',
          method: HttpMethod.GET)));
}

Future<ContactNumberListModel> deleteSosList({int? id}) async {
  return ContactNumberListModel.fromJson(await handleResponse(
      await buildHttpResponse('sos-delete/$id', method: HttpMethod.POST)));
}

Future<WithDrawListModel> getWithDrawList({int? page}) async {
  return WithDrawListModel.fromJson(await handleResponse(
      await buildHttpResponse('withdrawrequest-list?page=$page',
          method: HttpMethod.GET)));
}

Future<LDBaseResponse> saveWithDrawRequest(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'save-withdrawrequest',
      method: HttpMethod.POST,
      request: request)));
}

Future<AppSettingModel> getAppSetting() async {
  return AppSettingModel.fromJson(await handleResponse(
      await buildHttpResponse('admin-dashboard', method: HttpMethod.GET)));
}

Future<RiderListModel> getRiderRequestList(
    {int? page, String? status, LatLng? sourceLatLog, int? driverId}) async {
  if (sourceLatLog != null) {
    return RiderListModel.fromJson(await handleResponse(await buildHttpResponse(
        'riderequest-list?page=$page&driver_id=$driverId',
        method: HttpMethod.GET)));
  } else {
    return RiderListModel.fromJson(await handleResponse(await buildHttpResponse(
        status != null
            ? 'riderequest-list?page=$page&status=$status&driver_id=$driverId'
            : 'riderequest-list?page=$page&driver_id=$driverId',
        method: HttpMethod.GET)));
  }
}

Future<DocumentListModel> getDocumentList() async {
  return DocumentListModel.fromJson(await handleResponse(
      await buildHttpResponse('document-list', method: HttpMethod.GET)));
}

Future<DriverDocumentList> getDriverDocumentList() async {
  return DriverDocumentList.fromJson(await handleResponse(
      await buildHttpResponse('driver-document-list', method: HttpMethod.GET)));
}

/// Profile Update
Future uploadDocument(
    {int? driverId, int? documentId, File? file, int? isExpire}) async {
  MultipartRequest multiPartRequest =
      await getMultiPartRequest('driver-document-save');
  multiPartRequest.fields['driver_id'] = driverId.toString();
  multiPartRequest.fields['document_id'] = documentId.toString();
  multiPartRequest.fields['is_verified'] = '0';
  if (isExpire != null) multiPartRequest.fields['is_verified'] = '0';
  if (file != null)
    multiPartRequest.files
        .add(await MultipartFile.fromPath('driver_document', file.path));

  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      //
    }
  }, onError: (error) {
    toast(error.toString());
  });
}

Future<LDBaseResponse> deleteDeliveryDoc(int id) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'driver-document-delete/$id',
      method: HttpMethod.POST)));
}

Future<LoginResponse> updateStatus(Map request) async {
  return LoginResponse.fromJson(await handleResponse(await buildHttpResponse(
      'update-user-status',
      method: HttpMethod.POST,
      request: request)));
}

/// Update Vehicle Info
Future updateVehicleDetail(
    {String? carModel,
    String? carColor,
    String? carPlateNumber,
    String? carProduction}) async {
  MultipartRequest multiPartRequest =
      await getMultiPartRequest('update-profile');
  multiPartRequest.fields['id'] = sharedPref.getInt(USER_ID).toString();
  multiPartRequest.fields['email'] =
      sharedPref.getString(USER_EMAIL).validate();
  multiPartRequest.fields['contact_number'] =
      sharedPref.getString(CONTACT_NUMBER).validate();
  multiPartRequest.fields['username'] =
      sharedPref.getString(USER_NAME).validate();
  multiPartRequest.fields['user_detail[car_model]'] = carModel.validate();
  multiPartRequest.fields['user_detail[car_color]'] = carColor.validate();
  multiPartRequest.fields['user_detail[car_plate_number]'] =
      carPlateNumber.validate();
  multiPartRequest.fields['user_detail[car_production_year]'] =
      carProduction.validate();

  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      //
    }
  }, onError: (error) {
    toast(error.toString());
  });
}

/// Update Bank Info
Future updateBankDetail(
    {String? bankName,
    String? bankCode,
    String? accountName,
    String? accountNumber}) async {
  MultipartRequest multiPartRequest =
      await getMultiPartRequest('update-profile');
  multiPartRequest.fields['email'] =
      sharedPref.getString(USER_EMAIL).validate();
  multiPartRequest.fields['contact_number'] =
      sharedPref.getString(CONTACT_NUMBER).validate();
  multiPartRequest.fields['username'] =
      sharedPref.getString(USER_NAME).validate();
  multiPartRequest.fields['user_bank_account[bank_name]'] = bankName.validate();
  multiPartRequest.fields['user_bank_account[bank_code]'] = bankCode.validate();
  multiPartRequest.fields['user_bank_account[account_holder_name]'] =
      accountName.validate();
  multiPartRequest.fields['user_bank_account[account_number]'] =
      accountNumber.validate();

  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      //
    }
  }, onError: (error) {
    toast(error.toString());
  });
}

Future<CurrentRequestModel> getCurrentRideRequest() async {
  return CurrentRequestModel.fromJson(await handleResponse(
      await buildHttpResponse('current-riderequest', method: HttpMethod.GET)));
}

Future<LDBaseResponse> rideRequestUpdate(
    {required Map request, int? rideId}) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'riderequest-update/$rideId',
      method: HttpMethod.POST,
      request: request)));
}

Future<LDBaseResponse> ratingReview({required Map request}) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'save-ride-rating',
      method: HttpMethod.POST,
      request: request)));
}

Future<AdditionalFeesList> getAdditionalFees() async {
  return AdditionalFeesList.fromJson(await handleResponse(
      await buildHttpResponse('additional-fees-list?status=1',
          method: HttpMethod.GET)));
}

Future<LDBaseResponse> adminNotify({required Map request}) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'admin-sos-notify',
      method: HttpMethod.POST,
      request: request)));
}

Future<RideDetailModel> rideDetail({required int? orderId}) async {
  return RideDetailModel.fromJson(await handleResponse(await buildHttpResponse(
      'riderequest-detail?id=$orderId',
      method: HttpMethod.GET)));
}

Future<LDBaseResponse> saveComplain({required Map request}) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'save-complaint',
      method: HttpMethod.POST,
      request: request)));
}

Future<LDBaseResponse> completeRide({required Map request}) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'complete-riderequest',
      method: HttpMethod.POST,
      request: request)));
}

Future<LDBaseResponse> savePayment(Map request) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'save-payment',
      method: HttpMethod.POST,
      request: request)));
}

Future<LDBaseResponse> rideRequestResPond({required Map request}) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'riderequest-respond',
      method: HttpMethod.POST,
      request: request)));
}

/// Get Notification List
Future<NotificationListModel> getNotification({required int page}) async {
  return NotificationListModel.fromJson(await handleResponse(
      await buildHttpResponse('notification-list?page=$page&limit=$PER_PAGE',
          method: HttpMethod.POST)));
}

Future<LDBaseResponse> deleteUser() async {
  return LDBaseResponse.fromJson(await handleResponse(
      await buildHttpResponse('delete-user-account', method: HttpMethod.POST)));
}

Future<EarningListModelWeek> earningList({Map? req}) async {
  return EarningListModelWeek.fromJson(await handleResponse(
      await buildHttpResponse('earning-list',
          method: HttpMethod.POST, request: req)));
}

Future updateProfileUid() async {
  MultipartRequest multiPartRequest =
      await getMultiPartRequest('update-profile');
  multiPartRequest.fields['id'] = sharedPref.getInt(USER_ID).toString();
  multiPartRequest.fields['username'] =
      sharedPref.getString(USER_NAME).validate();
  multiPartRequest.fields['email'] =
      sharedPref.getString(USER_EMAIL).validate();
  multiPartRequest.fields['uid'] = sharedPref.getString(UID).toString();

  log('multipart request:${multiPartRequest.fields}');
  log(sharedPref.getString(UID).toString());

  await sendMultiPartRequest(multiPartRequest, onSuccess: (data) async {
    if (data != null) {
      //
    }
  }, onError: (error) {
    toast(error.toString());
  });
}

Future<WalletDetailModel> walletDetailApi() async {
  return WalletDetailModel.fromJson(await handleResponse(
      await buildHttpResponse('wallet-detail', method: HttpMethod.GET)));
}

Future<LDBaseResponse> complaintComment({required Map request}) async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'save-complaintcomment',
      method: HttpMethod.POST,
      request: request)));
}

Future<ComplaintCommentModel> complaintList(
    {required int complaintId, required int currentPage}) async {
  return ComplaintCommentModel.fromJson(await handleResponse(
      await buildHttpResponse(
          'complaintcomment-list?complaint_id=$complaintId&page=$currentPage',
          method: HttpMethod.GET)));
}

Future<LDBaseResponse> logoutApi() async {
  return LDBaseResponse.fromJson(await handleResponse(await buildHttpResponse(
      'logout?clear=player_id',
      method: HttpMethod.GET)));
}

logOutSuccess() async {
  sharedPref.remove(FIRST_NAME);
  sharedPref.remove(LAST_NAME);
  sharedPref.remove(USER_PROFILE_PHOTO);
  sharedPref.remove(USER_NAME);
  sharedPref.remove(USER_ADDRESS);
  sharedPref.remove(CONTACT_NUMBER);
  sharedPref.remove(GENDER);
  sharedPref.remove(UID);
  sharedPref.remove(TOKEN);
  sharedPref.remove(USER_TYPE);
  sharedPref.remove(ADDRESS);
  sharedPref.remove(USER_ID);
  appStore.setLoggedIn(false);
  if (!(sharedPref.getBool(REMEMBER_ME) ?? false) ||
      sharedPref.getString(LOGIN_TYPE) == LoginTypeGoogle ||
      sharedPref.getString(LOGIN_TYPE) == LoginTypeOTP) {
    sharedPref.remove(USER_EMAIL);
    sharedPref.remove(USER_PASSWORD);
    sharedPref.remove(REMEMBER_ME);
  }
  sharedPref.remove(LOGIN_TYPE);
  sharedPref.remove(LATITUDE);
  sharedPref.remove(LONGITUDE);
  launchScreen(getContext, SignInScreenNew(), isNewTask: true);
}

Future<AppSettingModel> getAppSettingApi() async {
  return AppSettingModel.fromJson(await handleResponse(
      await buildHttpResponse('appsetting', method: HttpMethod.GET)));
}
