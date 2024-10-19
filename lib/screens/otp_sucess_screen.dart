// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import '../utils/Extensions/app_common.dart';
import '../utils/Extensions/custom_button.dart';
import 'DashboardScreen.dart';

class OtpScreenSucess extends StatelessWidget {
  OtpScreenSucess();

  final textEditingController = TextEditingController();

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
                        height: 200,
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
                          'تم بنجاح التحقق من رقم جوالك',
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
                          'مرحبا بك في Jawad  منصتك الاولى لطلب الرحلات',
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      CustomButton(
                        onTap: () async {
                          //Get.offAll(DashBoard());
                          // Get.to(
                          //   () => DashBoard(),
                          // );
                          launchScreen(context, DashboardScreen(),
                              isNewTask: true);
                        },
                        buttonText: 'الاستمرار',
                        color: Colors.white,
                      ),
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
              //         // decoration: BoxDecoration(
              //         //   borderRadius: BorderRadius.circular(30),
              //         //   color: Colors.white,
              //         //   boxShadow: <BoxShadow>[
              //         //     BoxShadow(
              //         //       color: Colors.black.withOpacity(0.3),
              //         //       blurRadius: 10,
              //         //       offset: const Offset(0, 2),
              //         //     ),
              //         //   ],
              //         // ),
              //         child: const Padding(
              //       padding: EdgeInsets.all(8),
              //       child: Icon(
              //         Icons.arrow_back_ios_rounded,
              //         color: Colors.white,
              //       ),
              //     )),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
