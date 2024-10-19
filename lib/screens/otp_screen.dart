// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../main.dart';
import '../network/RestApis.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Extensions/custom_button.dart';
import 'otp_sucess_screen.dart';

class OtpScreen extends StatefulWidget {
  String? phoneNumber;
  String? verificationId;

  OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final textEditingController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          // decoration: const BoxDecoration(
          //   image: DecorationImage(
          //     image: AssetImage("assets/images/login_bg.png"),
          //     fit: BoxFit.cover,
          //   ),
          // ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 80,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Image.asset(
                          "images/icon_jawad.png",
                          height: 200,
                        ),
                      ),
                      SizedBox(
                        height: 26,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'رمز التحقق',
                          style: const TextStyle(
                              letterSpacing: 0.60,
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'تم ارسال رمز التحقق الى هاتفك ',
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        height: 85,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Pinput(
                            controller: textEditingController,
                            defaultPinTheme: PinTheme(
                              height: 50,
                              width: 50,

                              textStyle: const TextStyle(
                                  letterSpacing: 0.60,
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                              // margin: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                shape: BoxShape.rectangle,
                                color: Colors.black,
                                border:
                                    Border.all(color: Colors.white, width: 0.7),
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            length: 6,
                          ),
                        ),

                        // PinCodeTextField(
                        //   length: 6,
                        //   appContext: context,
                        //   keyboardType: TextInputType.phone,
                        //   textInputAction: TextInputAction.done,
                        //   pinTheme: PinTheme(
                        //     fieldHeight: 50,
                        //     fieldWidth: 50,
                        //     activeColor: ConstantColors.textFieldBoarderColor,
                        //     selectedColor:
                        //         ConstantColors.textFieldBoarderColor,
                        //     inactiveColor:
                        //         ConstantColors.textFieldBoarderColor,
                        //     activeFillColor: Colors.white,
                        //     inactiveFillColor: Colors.white,
                        //     selectedFillColor: Colors.white,
                        //     shape: PinCodeFieldShape.box,
                        //     borderRadius: BorderRadius.circular(10),
                        //   ),
                        //   enableActiveFill: true,
                        //   cursorColor: ConstantColors.primary,
                        //   controller: textEditingController,
                        //   onCompleted: (v) async {},
                        //   onChanged: (value) {
                        //     log(value);
                        //   },
                        // ),
                      ),
                      SizedBox(
                        height: 68,
                      ),
                      _isLoading
                          ? Center(
                              child:
                                  CircularProgressIndicator(), // عرض مؤشر التحميل أثناء التحميل
                            )
                          : CustomButton(
                              onTap: () async {
                                setState(() {
                                  _isLoading = true; // عند بدء التحميل
                                });

                                // تحقق من صحة رمز OTP
                                if (textEditingController.text.isEmpty ||
                                    textEditingController.text.length < 6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('يرجى إدخال رمز OTP صحيح')),
                                  );
                                  setState(() {
                                    _isLoading =
                                        false; // إعادة تعيين حالة التحميل
                                  });
                                  return;
                                }

                                final phoneNumber =
                                    '+20${widget.phoneNumber?.substring(1)}';

                                try {
                                  VerifyOtpResponse response =
                                      await verifyOtpApi({
                                    'phoneNumber': phoneNumber,
                                    'sessionInfo': widget.verificationId!,
                                    'code': textEditingController.text,
                                        "user_type": "driver"
                                      });

                                  if (response.message == null) {
                                    // حفظ حالة تسجيل الدخول
                                    await sharedPref.setBool(
                                        'isLoggedIn', true);

                                    // الحصول على التوكن من SharedPreferences
                                    String? token = sharedPref.getString(TOKEN);

                                    if (token != null) {
                                      print('Token: $token');
                                    } else {
                                      print(
                                          'Token not found in SharedPreferences.');
                                    }

                                    // التوجيه إلى الشاشة الرئيسية
                                    launchScreen(context, OtpScreenSucess());
                                    FocusScope.of(context).unfocus();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'فشل التحقق من OTP: ${response.message}')),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('حدث خطأ: $e')),
                                  );
                                } finally {
                                  setState(() {
                                    _isLoading = false; // عند انتهاء التحميل
                                  });
                                }
                              },
                              buttonText: 'الاستمرار', // نص الزر
                              color: Colors.white,
                            ),

                      // Padding(
                      //     padding: const EdgeInsets.only(top: 40),
                      //     child: ButtonThem.buildButton(
                      //       context,
                      //       title: 'done'.tr,
                      //       btnHeight: 50,
                      //       btnColor: ConstantColors.primary,
                      //       txtColor: Colors.white,
                      //       onPress: () async {
                      //         FocusScope.of(context).unfocus();

                      //         if (textEditingController.text.length == 6) {
                      //           ShowToastDialog.showLoader("Verify OTP".tr);
                      //           PhoneAuthCredential credential =
                      //               PhoneAuthProvider.credential(
                      //                   verificationId:
                      //                       verificationId.toString(),
                      //                   smsCode: textEditingController.text);
                      //           await FirebaseAuth.instance
                      //               .signInWithCredential(credential)
                      //               .then((value) async {
                      //             Map<String, String> bodyParams = {
                      //               'phone': phoneNumber.toString(),
                      //               'user_cat': "customer",
                      //             };
                      //             await controller
                      //                 .phoneNumberIsExit(bodyParams)
                      //                 .then((value) async {
                      //               if (value == true) {
                      //                 Map<String, String> bodyParams = {
                      //                   'phone': phoneNumber.toString(),
                      //                   'user_cat': "customer",
                      //                 };
                      //                 await controller
                      //                     .getDataByPhoneNumber(bodyParams)
                      //                     .then((value) {
                      //                   if (value != null) {
                      //                     if (value.success == "success") {
                      //                       ShowToastDialog.closeLoader();

                      //                       Preferences.setInt(
                      //                           Preferences.userId,
                      //                           int.parse(
                      //                               value.data!.id.toString()));
                      //                       Preferences.setString(
                      //                           Preferences.user,
                      //                           jsonEncode(value));
                      //                       Preferences.setString(
                      //                           Preferences.accesstoken,
                      //                           value.data!.accesstoken
                      //                               .toString());
                      //                       Preferences.setString(
                      //                           Preferences.admincommission,
                      //                           value.data!.adminCommission
                      //                               .toString());
                      //                       API.header['accesstoken'] =
                      //                           Preferences.getString(
                      //                               Preferences.accesstoken);

                      //                       if (value.data!.photo == null ||
                      //                           value.data!.photoPath
                      //                               .toString()
                      //                               .isEmpty) {
                      //                         Get.to(() =>
                      //                             AddProfilePhotoScreen());
                      //                       } else {
                      //                         Preferences.setBoolean(
                      //                             Preferences.isLogin, true);
                      //                         Get.offAll(DashBoard());
                      //                       }
                      //                     } else {
                      //                       ShowToastDialog.showToast(
                      //                           value.error);
                      //                     }
                      //                   }
                      //                 });
                      //               } else if (value == false) {
                      //                 ShowToastDialog.closeLoader();
                      //                 Get.off(SignupScreen(
                      //                   phoneNumber: phoneNumber.toString(),
                      //                 ));
                      //               }
                      //             });
                      //           }).catchError((error) {
                      //             ShowToastDialog.closeLoader();
                      //             ShowToastDialog.showToast(
                      //                 "Code is Invalid".tr);
                      //           });
                      //         } else {
                      //           ShowToastDialog.showToast(
                      //               "Please Enter OTP".tr);
                      //         }
                      //       },
                      //     ))
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                      // decoration: BoxDecoration(
                      //   borderRadius: BorderRadius.circular(30),
                      //   color: Colors.white,
                      //   boxShadow: <BoxShadow>[
                      //     BoxShadow(
                      //       color: Colors.black.withOpacity(0.3),
                      //       blurRadius: 10,
                      //       offset: const Offset(0, 2),
                      //     ),
                      //   ],
                      // ),
                      child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white,
                    ),
                  )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
