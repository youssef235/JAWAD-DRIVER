import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../otp_firebase_services/firebase_otp.dart';
import '../utils/Common.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Extensions/custom_button.dart';
import '../utils/Extensions/custom_text_field.dart';
import 'SignUpScreen.dart';
import 'otp_screen.dart';

class SignInScreenNew extends StatefulWidget {
  final bool? isLogin;
  SignInScreenNew({super.key, this.isLogin});

  @override
  State<SignInScreenNew> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreenNew> {
  TextEditingController phoneController = TextEditingController();
  final PhoneAuthService _phoneAuthService = PhoneAuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
              // image: DecorationImage(
              //   image: AssetImage(
              //     "assets/images/login_bg.png",
              //   ),
              //   fit: BoxFit.cover,
              // ),
              ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                          'الرجاء ادخال رقم الجوال لأرسال رمز التحقق الى رقم جوالك المدخل',
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 80),
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //         border: Border.all(
                      //           color: ConstantColors.textFieldBoarderColor,
                      //         ),
                      //         borderRadius:
                      //             const BorderRadius.all(Radius.circular(6))),
                      //     padding: const EdgeInsets.only(left: 10),
                      //     child: IntlPhoneField(
                      //       onChanged: (phone) {
                      //         controller.phoneNumber.value =
                      //             phone.completeNumber;
                      //       },
                      //       invalidNumberMessage: "number invalid",
                      //       showDropdownIcon: false,
                      //       disableLengthCheck: true,
                      //       decoration: InputDecoration(
                      //         contentPadding:
                      //             const EdgeInsets.symmetric(vertical: 12),
                      //         hintText: 'Phone Number'.tr,
                      //         border: InputBorder.none,
                      //         isDense: true,
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      SizedBox(
                        height: 48,
                      ),
                      MainTextField(
                        controller: phoneController,
                        isShowSuffixIcon: false,
                        hintText: 'رقم الجوال',
                        labelText: 'رقم الجوال',
                        inputType: TextInputType.phone,
                        onChanged: (phone) {
                          // controller.phoneNumber.value = phone ?? "";
                        },
                      ),
                      SizedBox(
                        height: 28,
                      ),
                      // Padding(
                      //     padding: const EdgeInsets.only(top: 50),
                      //     child: ButtonThem.buildButton(
                      //       context,
                      //       title: 'Continue'.tr,
                      //       btnHeight: 50,
                      //       btnColor: ConstantColors.primary,
                      //       txtColor: Colors.white,
                      //       onPress: () async {
                      //         FocusScope.of(context).unfocus();
                      //         if (controller.phoneNumber.value.isNotEmpty) {
                      //           ShowToastDialog.showLoader("Code sending".tr);
                      //           controller
                      //               .sendCode(controller.phoneNumber.value);
                      //         }
                      //       },
                      //     )),
                      // Container(
                      //   width: 293,
                      //   height: 58,
                      //   decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: BorderRadius.circular(6),
                      //       boxShadow: [
                      //         BoxShadow(),
                      //       ]),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       Text(
                      //         'ارسال رمز التحقق واتساب',
                      //         style: const TextStyle(
                      //             letterSpacing: 0.60,
                      //             fontSize: 14,
                      //             color: Color(0xff242E42),
                      //             fontWeight: FontWeight.w900),
                      //       ),
                      //       SizedBox(
                      //         width: 33,
                      //       ),
                      //       SvgPicture.asset('images/whatsapp.svg')
                      //     ],
                      //   ),
                      // ),
                      // SizedBox(
                      //   height: 15,
                      // ),
                      // Container(
                      //   width: 293,
                      //   height: 58,
                      //   decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: BorderRadius.circular(6),
                      //       boxShadow: [
                      //         BoxShadow(),
                      //       ]),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       SizedBox(
                      //         width: 150,
                      //         child: Center(
                      //           child: Text(
                      //             'ارسال رسالة نصية',
                      //             style: const TextStyle(
                      //                 letterSpacing: 0.60,
                      //                 fontSize: 14,
                      //                 color: Color(0xff242E42),
                      //                 fontWeight: FontWeight.w900),
                      //           ),
                      //         ),
                      //       ),
                      //       SizedBox(
                      //         width: 33,
                      //       ),
                      //       Image.asset('images/smss.png')
                      //     ],
                      //   ),
                      // ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(language.donHaveAnAccount,
                                style: primaryTextStyle()
                                    .copyWith(color: Colors.white)),
                            SizedBox(width: 8),
                            inkWellWidget(
                              onTap: () {
                                hideKeyboard(context);
                                launchScreen(
                                    context,
                                    SignUpScreen(
                                        privacyPolicyUrl: '',
                                        termsConditionUrl: ''));
                              },
                              child: Text(language.signUp,
                                  style: boldTextStyle()
                                      .copyWith(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        height: 15,
                      ),
                      InkWell(
                        onTap: () {
                          launchUrl(
                            Uri.parse(
                                'https://www.freeprivacypolicy.com/live/986651fa-8599-460a-a440-c78583f5ecc0'),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            text: 'شروط الاستخدام والخصوصية',
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Colors.white, // Set the text color to white
                              decoration: TextDecoration
                                  .underline, // Underline the text
                              decorationColor: Colors
                                  .white, // Set the underline color to white
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      _isLoading
                          ? const Center(
                              child:
                                  CircularProgressIndicator(), // عرض مؤشر التحميل في الوسط
                            )
                          : CustomButton(
                              onTap: () async {
                                setState(() {
                                  _isLoading = true; // عند بدء التحميل
                                });

                                try {
                                  await _phoneAuthService.verifyPhoneNumber(
                                    phoneController.text,
                                    (String verificationId,
                                        String phoneNumber) {
                                      print("vvvvvvvvv is ${verificationId}");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => OtpScreen(
                                            verificationId: verificationId,
                                            phoneNumber: phoneNumber,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                  // await logInApi({
                                  //   "contact_number": widget.phoneNumber,
                                  //   "player_id":
                                  //       sharedPref.getString(PLAYER_ID),
                                  //   "user_type": "driver",
                                  //   'otp_code': textEditingController.text
                                  // }, isSocialLogin: false);
                                  //
                                  // launchScreen(context, OtpScreenSucess());
                                  // FocusScope.of(context).unfocus();
                                } catch (e) {
                                  toast('$e');
                                  await appStore.setLoading(false);
                                } finally {
                                  setState(() {
                                    _isLoading = false; // عند انتهاء التحميل
                                  });
                                }
                              },
                              buttonText: 'الاستمرار', // النص الافتراضي
                              color: Colors.white,
                            ),
                      // CustomButton(
                      //   onTap: () async {
                      //     FocusScope.of(context).unfocus();
                      //     if (phoneController.text.isNotEmpty) {
                      //       // ShowToastDialog.showLoader('جاري ارسال رمز التحقق');
                      //
                      //       launchScreen(
                      //           context,
                      //           OtpScreen(
                      //             phoneNumber: phoneController.text,
                      //             //verificationId: '123456',
                      //           ));
                      //       ShowToastDialog.closeLoader();
                      //       //  controller.sendCode(controller.phoneNumber.value);
                      //     }
                      //   },
                      //   buttonText: 'الاستمرار',
                      //   color: Colors.white,
                      // ),
                      // Padding(
                      //     padding: const EdgeInsets.only(top: 50),
                      //     child: ButtonThem.buildButton(
                      //       context,
                      //       title: 'Login With Email'.tr,
                      //       btnHeight: 50,
                      //       btnColor: ConstantColors.yellow,
                      //       txtColor: Colors.white,
                      //       onPress: () {
                      //         FocusScope.of(context).unfocus();
                      //         Get.back();
                      //       },
                      //     )),
                    ],
                  ),
                ),
              ),

              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: GestureDetector(
              //     onTap: () {
              //       Get.back();
              //     },
              //     child: Container(
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(30),
              //           color: Colors.white,
              //           boxShadow: <BoxShadow>[
              //             BoxShadow(
              //               color: Colors.black.withOpacity(0.3),
              //               blurRadius: 10,
              //               offset: const Offset(0, 2),
              //             ),
              //           ],
              //         ),
              //         child: const Padding(
              //           padding: EdgeInsets.all(8),
              //           child: Icon(
              //             Icons.arrow_back_ios_rounded,
              //             color: Colors.black,
              //           ),
              //         )),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
