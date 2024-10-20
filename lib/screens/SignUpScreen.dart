import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taxi_driver/Services/AuthService.dart';
import 'package:taxi_driver/main.dart';
import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';
import 'package:taxi_driver/utils/Extensions/context_extensions.dart';
import '../model/LoginResponse.dart';
import '../model/ServiceModel.dart';
import '../network/RestApis.dart';
import '../otp_firebase_services/firebase_otp.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Extensions/app_textfield.dart';
import 'DashboardScreen.dart';
import 'TermsConditionScreen.dart';
import 'dart:developer' as dev;
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'otp_screen.dart';
class SignUpScreen extends StatefulWidget {
  final bool isOtp;
  final bool socialLogin;

  final String? countryCode;
  final String? privacyPolicyUrl;
  final String? termsConditionUrl;
  final String? userName;

  SignUpScreen(
      {this.socialLogin = false,
      this.userName,
      this.isOtp = false,
      this.countryCode,
      this.privacyPolicyUrl,
      this.termsConditionUrl});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  AuthServices authService = AuthServices();

  List<GlobalKey<FormState>> formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController firstController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController nationalIdController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  TextEditingController userNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController carModelController = TextEditingController();
  TextEditingController carProductionController = TextEditingController();
  TextEditingController carPlateController = TextEditingController();
  TextEditingController carColorController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController bankCodeController = TextEditingController();

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode passFocus = FocusNode();

  bool mIsCheck = false;
  bool isAcceptedTc = false;
  String countryCode = defaultCountryCode;

  int currentIndex = 0;

  List<ServiceList> listServices = [];

  int selectedService = 0;

  XFile? imageProfile;
  int radioValue = -1;

  @override
  void initState() {
    super.initState();
    init();
  }

  String? national_id_image;
  String? drive_license_image;
  String? car_registeration_image;
  String? profileImage;

  Future<void> _pickFile(String? filePath) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        // type: FileType.image,
        );
    dev.log(filePath.toString(), name: 'national_id_image');

    dev.log((filePath == 'profileImage').toString(), name: 'national_id_image');

    dev.log(result.toString());

    if (result != null) {
      setState(() {
        if (filePath == 'national_id_image') {
          national_id_image = result.files.single.path;
        } else if (filePath == 'drive_license_image') {
          drive_license_image = result.files.single.path;
        } else if (filePath == 'car_registeration_image') {
          car_registeration_image = result.files.single.path;
        } else if (filePath == 'profileImage') {
          profileImage = result.files.single.path;
          dev.log(profileImage.toString(), name: 'profileImage');
        }
      });
    } else {
      // User canceled the picker
    }
  }

  void init() async {
    if (sharedPref.getString(PLAYER_ID).validate().isEmpty) {
      await saveOneSignalPlayerId().then((value) {
        //
      });
    }
    await getServices().then((value) {
      listServices.addAll(value.data!);
      setState(() {});
    }).catchError((error) {
      log(error.toString());
    });
  }

  Future<void> registerUser({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String userType,
    required String contactNumber,
    required String password,
    required String playerId,
    required String carModel,
    required String carColor,
    required String carPlateNumber,
    required String carProductionYear,
    required String serviceId,
    required String profileImagePath,
    required String nationalIdImagePath,
    required String driveLicenseImagePath,
    required String carRegistrationImagePath,
    required String userDetailNationalId,
    required String accountNumber,
    required BuildContext context,
  }) async {
    final String apiUrl = 'https://yourapi.com/register'; // استبدل هذا بعنوان الـ API الخاص بك

    // إعداد البيانات للإرسال
    final Map<String, dynamic> data = {
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'email': email,
      'user_type': userType,
      'contact_number': contactNumber,
      'password': password,
      'player_id': playerId,
      'car_model': carModel,
      'car_color': carColor,
      'car_plate_number': carPlateNumber,
      'car_production_year': carProductionYear,
      'user_detail': {
        'car_model': carModel,
        'car_color': carColor,
        'car_plate_number': carPlateNumber,
        'car_production_year': carProductionYear,
      },
      'service_id': serviceId,
      'profileImagePath': profileImagePath,
      'nationalIdImagePath': nationalIdImagePath,
      'driveLicenseImagePath': driveLicenseImagePath,
      'carRegistrationImagePath': carRegistrationImagePath,
      'user_detail_national_id': userDetailNationalId,
      'account_number': accountNumber,
    };

    try {
      // إرسال الطلب
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      // التحقق من الاستجابة
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // إذا كانت الاستجابة ناجحة، انتقل إلى صفحة الداشبورد
        Navigator.pushReplacementNamed(context, '/dashboard'); // تأكد من أن لديك مسار '/dashboard' معرف في تطبيقك
      } else {
        // إذا كانت الاستجابة غير ناجحة، اطبع رسالة الخطأ
        final errorResponse = jsonDecode(response.body);
        String errorMessage = errorResponse['message'] ?? 'حدث خطأ غير متوقع.';
        print('Error during registration: $errorMessage');
        // يمكنك أيضًا عرض رسالة الخطأ للمستخدم باستخدام AlertDialog أو Snackbar
      }
    } catch (e) {
      print('Error during registration: $e');
      // يمكنك أيضًا عرض رسالة خطأ للمستخدم
    }
  }
  Future<void> register() async {
    hideKeyboard(context);
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (isAcceptedTc) {
        appStore.setLoading(true);
        dev.log(listServices[selectedService].id.toString(), name: 'serviceId');

        Map req = {
          'first_name': firstController.text.trim(),
          'last_name': lastNameController.text.trim(),
          'username': firstController.text.trim(),
          'email': emailController.text.trim(),
          "user_type": "driver",
          "contact_number": widget.socialLogin
              ? '${widget.countryCode}${widget.userName}'
              : "+966${phoneController.text.trim()}",
          'password': widget.socialLogin ? widget.userName : passController.text.trim(),
          "player_id": sharedPref.getString(PLAYER_ID).validate(),
          if (widget.socialLogin) 'login_type': LoginTypeOTP,
          'car_model': carModelController.text.trim(),
          'car_color': carColorController.text.trim(),
          'car_plate_number': carPlateController.text.trim(),
          'car_production_year': carProductionController.text.trim(),
          "user_detail": {
            'car_model': carModelController.text.trim(),
            'car_color': carColorController.text.trim(),
            'car_plate_number': carPlateController.text.trim(),
            'car_production_year': carProductionController.text.trim(),
          },
          'service_id': listServices[selectedService].id,
          'profileImagePath': profileImage,
          'nationalIdImagePath': national_id_image,
          "driveLicenseImagePath": drive_license_image,
          "carRegistrationImagePath": car_registeration_image,
          "user_detail_national_id": nationalIdController.text,
          "account_number": accountNumberController.text.trim(),
          "bank_name": bankNameController.text.trim(),
          "bank_code": bankCodeController.text.trim(),
        };

        try {
          // تنفيذ API التسجيل
          LoginResponse loginResponse = await signUpApi(req);

          // تحقق من نجاح التسجيل
          if (loginResponse.data != null) {
            // استخدم بيانات المستخدم هنا
            int userId = loginResponse.data!.id ?? 0; // استخراج الـ ID
            String username = loginResponse.data!.username.validate();
            String email = loginResponse.data!.email.validate();
            String contactNumber = loginResponse.data!.contactNumber.validate();

            // يمكنك الآن استخدام هذه البيانات كما تريد، سواء للإظهار في واجهة المستخدم أو التخزين
            print("User ID: $userId");
            print("Username: $username");
            print("Email: $email");
            print("Contact Number: $contactNumber");

            // تنفيذ عملية تسجيل المستخدم
            await authService.signUpWithEmailPassword(
              context,
              mobileNumber: widget.socialLogin
                  ? '${widget.countryCode}${widget.userName}'
                  : '$countryCode${phoneController.text.trim()}',
              email: emailController.text.trim(),
              fName: firstController.text.trim(),
              lName: lastNameController.text.trim(),
              userName: widget.socialLogin
                  ? widget.userName
                  : userNameController.text.trim(),
              password: widget.socialLogin
                  ? widget.userName
                  : passController.text.trim(),
              userType: DRIVER,
              isOtpLogin: widget.socialLogin,
            );

            // حفظ رقم الجوال في shared preferences بعد التسجيل الناجح
            String mobileNumber = widget.socialLogin
                ? '${widget.countryCode}${widget.userName}'
                : phoneController.text.trim();
            await sharedPref.setString(CONTACT_NUMBER, mobileNumber);

            // عرض رسالة نجاح مع بيانات المستخدم
            toast("تم تسجيل سائق بنجاح");
         //   toast("بيانات المستخدم: ID: $userId، Username: $username، Email: $email، Contact: $contactNumber");

            // إعادة توجيه المستخدم إلى شاشة OTP بعد التسجيل الناجح
            final PhoneAuthService _phoneAuthService = PhoneAuthService();

            await _phoneAuthService.verifyPhoneNumber(
              phoneController.text,
                  (String verificationId, String phoneNumber) {
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
          } else {
            // في حالة عدم وجود بيانات
            toast("فشل في تسجيل السائق: ${loginResponse.message}");
          }
        } catch (error) {
          print("Error during registration: $error");
          toast("حدث خطأ أثناء التسجيل");
        } finally {
          appStore.setLoading(false);
        }
      }
    }
  }





  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: BackButton(color: context.iconColor),
        title: Text(language.signUp,
            style: boldTextStyle().copyWith(color: Colors.white)),
      ),
      body: Stack(
        children: [
          Form(
            key: formKey,
            child: Stepper(
              currentStep: currentIndex,
              onStepCancel: () {
                if (currentIndex > 0) {
                  currentIndex--;
                  setState(() {});
                }
              },
              onStepContinue: () {
                log(formKeys[currentIndex].currentState!.validate());
                if (formKeys[currentIndex].currentState!.validate()) {
                  if (currentIndex == 1 && listServices.isEmpty) {
                    return toast(language.pleaseSelectService);
                  } else if (currentIndex <= 3) {
                    currentIndex++;
                    log(currentIndex);

                    setState(() {});
                  } else {
                    register();
                  }
                }
              },
              onStepTapped: (int index) {
                currentIndex = index;
                setState(() {});
              },
              steps: [
                Step(
                  isActive: currentIndex <= 0,
                  state: currentIndex <= 0
                      ? StepState.disabled
                      : StepState.complete,
                  title: Text(language.userDetail,
                      style: boldTextStyle().copyWith(color: Colors.white)),
                  content: Form(
                    key: formKeys[0],
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                textFieldType: TextFieldType.NAME,
                                controller: firstController,
                                // focus: firstNameFocus,
                                // nextFocus: lastNameFocus,
                                errorThisFieldRequired:
                                    language.thisFieldRequired,
                                textStyle: TextStyle(color: Colors.white),
                                decoration: inputDecoration(
                                  context,
                                  label: language.firstName,
                                  labelextStyle: TextStyle(color: Colors.white),
                                ).copyWith(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(defaultRadius),
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(107, 79, 169, 1),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: AppTextField(
                                textFieldType: TextFieldType.NAME,
                                controller: lastNameController,
                                // focus: lastNameFocus,
                                // nextFocus: emailFocus,
                                errorThisFieldRequired:
                                    language.thisFieldRequired,
                                textStyle: TextStyle(color: Colors.white),
                                decoration: inputDecoration(
                                  context,
                                  label: language.lastName,
                                  labelextStyle: TextStyle(color: Colors.white),
                                ).copyWith(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(defaultRadius),
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(107, 79, 169, 1),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        AppTextField(
                          textFieldType: TextFieldType.PHONE,
                          // focus: emailFocus,
                          controller: nationalIdController,
                          // nextFocus: userNameFocus,
                          errorThisFieldRequired: language.thisFieldRequired,
                          textStyle: TextStyle(color: Colors.white),
                          decoration: inputDecoration(
                            context,
                            label: 'رقم الهوية الوطنية',
                            labelextStyle: TextStyle(color: Colors.white),
                          ).copyWith(
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(defaultRadius),
                              borderSide: BorderSide(
                                color: Color.fromRGBO(107, 79, 169, 1),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        AppTextField(
                          textFieldType: TextFieldType.EMAIL,
                          // focus: emailFocus,
                          controller: emailController,
                          // nextFocus: userNameFocus,
                          errorThisFieldRequired: language.thisFieldRequired,
                          textStyle: TextStyle(color: Colors.white),
                          decoration: inputDecoration(
                            context,
                            label: 'الايميل',
                            labelextStyle: TextStyle(color: Colors.white),
                          ).copyWith(
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(defaultRadius),
                              borderSide: BorderSide(
                                color: Color.fromRGBO(107, 79, 169, 1),
                              ),
                            ),
                          ),
                        ),
                        if (widget.socialLogin != true) SizedBox(height: 8),
                        if (widget.socialLogin != true)
                          AppTextField(
                            controller: phoneController,
                            textFieldType: TextFieldType.PHONE,
                            // focus: phoneFocus,
                            // nextFocus: passFocus,
                            textStyle: TextStyle(color: Colors.white),
                            // decoration: inputDecoration(
                            //   context,
                            //   label: language.firstName,
                            //   labelextStyle: TextStyle(color: Colors.white),
                            // ),
                            decoration: inputDecoration(
                              context,
                              label: language.phoneNumber,
                              labelextStyle: TextStyle(color: Colors.white),
                              prefixIcon: IntrinsicHeight(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CountryCodePicker(
                                      padding: EdgeInsets.zero,
                                      initialSelection: countryCode,
                                      showCountryOnly: false,
                                      dialogSize: Size(
                                          MediaQuery.of(context).size.width -
                                              60,
                                          MediaQuery.of(context).size.height *
                                              0.6),
                                      showFlag: true,
                                      showFlagDialog: true,
                                      showOnlyCountryWhenClosed: false,
                                      alignLeft: false,
                                      textStyle:
                                          primaryTextStyle(color: Colors.white),
                                      dialogBackgroundColor:
                                          Theme.of(context).cardColor,
                                      barrierColor: Colors.black12,
                                      dialogTextStyle: primaryTextStyle(),
                                      searchDecoration: InputDecoration(
                                        iconColor:
                                            Theme.of(context).dividerColor,
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Theme.of(context)
                                                    .dividerColor)),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white)),
                                      ),
                                      searchStyle: primaryTextStyle(),
                                      onInit: (c) {
                                        countryCode = c!.dialCode!;
                                      },
                                      onChanged: (c) {
                                        countryCode = c.dialCode!;
                                      },
                                    ),
                                    VerticalDivider(
                                        color: Colors.grey.withOpacity(0.5)),
                                  ],
                                ),
                              ),
                            ).copyWith(
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(defaultRadius),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(107, 79, 169, 1),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value!.trim().isEmpty)
                                return language.thisFieldRequired;
                              return null;
                            },
                          ),
                        if (widget.socialLogin != true) SizedBox(height: 8),
                        if (widget.socialLogin != true)
                          AppTextField(
                            controller: passController,
                            // focus: passFocus,
                            autoFocus: false,
                            textStyle: TextStyle(color: Colors.white),
                            textFieldType: TextFieldType.PASSWORD,
                            errorThisFieldRequired: language.thisFieldRequired,
                            decoration: inputDecoration(
                              context,
                              label: language.password,
                              labelextStyle: TextStyle(color: Colors.white),
                            ).copyWith(
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(defaultRadius),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(107, 79, 169, 1),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Step(
                  isActive: currentIndex <= 1,
                  state: currentIndex <= 1
                      ? StepState.disabled
                      : StepState.complete,
                  title: Text(language.selectService,
                      style: boldTextStyle().copyWith(color: Colors.white)),
                  content: Form(
                    key: formKeys[1],
                    child: listServices.isNotEmpty
                        ? Column(
                            children: listServices.map((e) {
                              return inkWellWidget(
                                onTap: () {
                                  selectedService = listServices.indexOf(e);
                                  setState(() {});
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 8),
                                  padding: EdgeInsets.only(
                                      left: 16, right: 8, top: 4, bottom: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: selectedService ==
                                                listServices.indexOf(e)
                                            ? Colors.green
                                            : Colors.white.withOpacity(0.5)),
                                    borderRadius:
                                        BorderRadius.circular(defaultRadius),
                                  ),
                                  child: Row(
                                    children: [
                                      commonCachedNetworkImage(e.serviceImage,
                                          fit: BoxFit.contain,
                                          height: 50,
                                          width: 50),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Text(e.name.validate(),
                                            style: boldTextStyle()
                                                .copyWith(color: Colors.white)),
                                      ),
                                      Visibility(
                                        visible: selectedService ==
                                            listServices.indexOf(e),
                                        child: Icon(Icons.check_circle_outline,
                                            color: Colors.green),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : emptyWidget(),
                  ),
                ),
                Step(
                  isActive: currentIndex <= 2,
                  state: currentIndex <= 2
                      ? StepState.disabled
                      : StepState.complete,
                  title: Text('معلومات السيارة', // طراز السيارة
                      style: boldTextStyle().copyWith(color: Colors.white)),
                  content: Form(
                    key: formKeys[2],
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: AppTextField(
                            textFieldType: TextFieldType.NAME,
                            controller: carModelController,
                            textStyle: TextStyle(color: Colors.white),
                            decoration: inputDecoration(
                              context,
                              label: 'نوع السيارة', // طراز السيارة
                              labelextStyle: TextStyle(color: Colors.white),
                            ).copyWith(
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(defaultRadius),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(107, 79, 169, 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: AppTextField(
                            textFieldType: TextFieldType.NAME,
                            controller: carPlateController,
                            textStyle: TextStyle(color: Colors.white),
                            decoration: inputDecoration(
                              context,
                              label: language.carPlateNumber,
                              labelextStyle: TextStyle(color: Colors.white),
                            ).copyWith(
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(defaultRadius),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(107, 79, 169, 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: AppTextField(
                            textFieldType: TextFieldType.NAME,
                            controller: carProductionController,
                            textStyle: TextStyle(color: Colors.white),
                            decoration: inputDecoration(
                              context,
                              label: 'موديل السيارة',
                              labelextStyle: TextStyle(color: Colors.white),
                            ).copyWith(
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(defaultRadius),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(107, 79, 169, 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: AppTextField(
                            textFieldType: TextFieldType.NAME,
                            controller: carColorController,
                            textStyle: TextStyle(color: Colors.white),
                            decoration: inputDecoration(
                              context,
                              label: language.carColor,
                              labelextStyle: TextStyle(color: Colors.white),
                            ).copyWith(
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(defaultRadius),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(107, 79, 169, 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),


                Step(
                  isActive: currentIndex <= 3,
                  state: currentIndex <= 3
                      ? StepState.disabled
                      : StepState.complete,
                  title: Text('ارفاق الصور',
                      style: boldTextStyle().copyWith(color: Colors.white)),
                  content: Form(
                    key: formKeys[3],
                    child: Column(
                      children: [
                        //                         String? national_id_image;
                        // String? drive_license_image;
                        // String? car_registeration_image;
                        // String? profileImage;
                        SelectFileWidget(
                          text: 'الهوية الوطنية',
                          onTap: () {
                            _pickFile('national_id_image');
                          },
                        ),
                        national_id_image != null
                            ? Image.file(File(national_id_image!))
                            : Text(
                                '',
                                style: TextStyle(color: Colors.white),
                              ),
                        SelectFileWidget(
                          text: 'الصورة الشخصية',
                          onTap: () {
                            _pickFile('profileImage');
                          },
                        ),
                        profileImage != null
                            ? Image.file(File(profileImage!))
                            : Text(
                                '',
                                style: TextStyle(color: Colors.white),
                              ),
                        SelectFileWidget(
                          text: 'رخصة القيادة',
                          onTap: () {
                            _pickFile('drive_license_image');
                          },
                        ),
                        drive_license_image != null
                            ? Image.file(File(drive_license_image!))
                            : Text(
                                '',
                                style: TextStyle(color: Colors.white),
                              ),
                        SelectFileWidget(
                          text: 'استمارة السيارة',
                          onTap: () {
                            _pickFile('car_registeration_image');
                          },
                        ),
                        car_registeration_image != null
                            ? Image.file(File(car_registeration_image!))
                            : Text(
                                '',
                                style: TextStyle(color: Colors.white),
                              ),
                      ],
                    ),
                  ),
                ),
                Step(
                  isActive: currentIndex <= 4,
                  state: currentIndex <= 4
                      ? StepState.disabled
                      : StepState.complete,
                  title: Text('معلومات الحساب البنكي',
                      style: boldTextStyle().copyWith(color: Colors.white)),
                  content: Form(
                    key: formKeys[4],
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        AppTextField(
                          textFieldType: TextFieldType.PHONE,
                          // focus: emailFocus,
                          controller: bankCodeController,
                          isValidationRequired: false,
                          // nextFocus: userNameFocus,
                          // errorThisFieldRequired: language.thisFieldRequired,
                          textStyle: TextStyle(color: Colors.white),
                          decoration: inputDecoration(
                            context,
                            label: 'STC pay',
                            labelextStyle: TextStyle(color: Colors.white),
                          ).copyWith(
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(defaultRadius),
                              borderSide: BorderSide(
                                color: Color.fromRGBO(107, 79, 169, 1),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        AppTextField(
                          textFieldType: TextFieldType.NAME,
                          isValidationRequired: false,

                          // focus: emailFocus,
                          controller: bankNameController,
                          // nextFocus: userNameFocus,
                          //  errorThisFieldRequired: language.thisFieldRequired,
                          textStyle: TextStyle(color: Colors.white),
                          decoration: inputDecoration(
                            context,
                            label: 'اسم البنك',
                            labelextStyle: TextStyle(color: Colors.white),
                          ).copyWith(
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(defaultRadius),
                              borderSide: BorderSide(
                                color: Color.fromRGBO(107, 79, 169, 1),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        AppTextField(
                          textFieldType: TextFieldType.NAME,
                          // focus: emailFocus,
                          isValidationRequired: false,

                          controller: accountNumberController,
                          // nextFocus: userNameFocus,
                          //  errorThisFieldRequired: language.thisFieldRequired,
                          textStyle: TextStyle(color: Colors.white),
                          decoration: inputDecoration(
                            context,
                            label: 'رقم الحساب',
                            labelextStyle: TextStyle(color: Colors.white),
                          ).copyWith(
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(defaultRadius),
                              borderSide: BorderSide(
                                color: Color.fromRGBO(107, 79, 169, 1),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          //  activeColor: Colors.white,
                          title: RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: '${language.agreeToThe} ',
                                  style: secondaryTextStyle()
                                      .copyWith(color: Colors.white)),
                              TextSpan(
                                text: language.termsConditions,
                                style: boldTextStyle(
                                    color: Colors.white, size: 14),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    if (widget.termsConditionUrl != null &&
                                        widget.termsConditionUrl!.isNotEmpty) {
                                      launchScreen(
                                          context,
                                          TermsConditionScreen(
                                              title: language.termsConditions,
                                              subtitle:
                                                  widget.termsConditionUrl),
                                          pageRouteAnimation:
                                              PageRouteAnimation.Slide);
                                    } else {
                                      toast(language.txtURLEmpty);
                                    }
                                  },
                              ),
                              TextSpan(
                                  text: ' & ',
                                  style: secondaryTextStyle()
                                      .copyWith(color: Colors.white)),
                              TextSpan(
                                text: language.privacyPolicy,
                                style: boldTextStyle(
                                    color: Colors.white, size: 14),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    if (widget.privacyPolicyUrl != null &&
                                        widget.privacyPolicyUrl!.isNotEmpty) {
                                      launchScreen(
                                          context,
                                          TermsConditionScreen(
                                              title: language.privacyPolicy,
                                              subtitle:
                                                  widget.privacyPolicyUrl),
                                          pageRouteAnimation:
                                              PageRouteAnimation.Slide);
                                    } else {
                                      toast(language.txtURLEmpty);
                                    }
                                  },
                              ),
                            ]),
                            textAlign: TextAlign.left,
                          ),
                          value: isAcceptedTc,
                          onChanged: (val) async {
                            isAcceptedTc = val!;
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
          Observer(builder: (context) {
            return Visibility(
              visible: appStore.isLoading,
              child: loaderWidget(),
            );
          })
        ],
      ),
    );
  }
}

class SelectFileWidget extends StatelessWidget {
  const SelectFileWidget({
    super.key,
    required this.text,
    required this.onTap,
  });
  final String text;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(color: Colors.white),
          ),
          ElevatedButton(
              onPressed: () {
                onTap();
              },
              child: Text('اختيار ملف'))
        ],
      ),
    );
  }
}
