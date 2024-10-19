// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:video_player/video_player.dart';
// import '../utils/Common.dart';
// import '../utils/Extensions/StringExtensions.dart';
// import '../main.dart';
// import '../../utils/Colors.dart';
// import '../../utils/Constants.dart';
// import '../../utils/Extensions/app_common.dart';
// import '../network/RestApis.dart';
// import '../utils/images.dart';
// import 'EditProfileScreen.dart';
// import 'SignInScreen.dart';
// import 'DashBoardScreen.dart';
// import 'sign_in_screen.dart';

// class SplashScreen extends StatefulWidget {
//   @override
//   SplashScreenState createState() => SplashScreenState();
// }

// class SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     init();
//   }

//   void init() async {
//     await Future.delayed(Duration(seconds: 3));
//     if (sharedPref.getBool(IS_FIRST_TIME) ?? true) {
//       await Geolocator.requestPermission().then((value) async {
//         await Geolocator.getCurrentPosition().then((value) {
//           sharedPref.setDouble(LATITUDE, value.latitude);
//           sharedPref.setDouble(LONGITUDE, value.longitude);
//           launchScreen(context, SignInScreenNew(),
//               pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
//         });
//       }).catchError((e) {
//         launchScreen(context, SignInScreenNew(),
//             pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
//       });
//     } else {
//       if (!appStore.isLoggedIn) {
//         // launchScreen(context, SignInScreen(),
//         //     pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
//         launchScreen(context, SignInScreenNew(),
//             pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
//       } else {
//         if (sharedPref.getString(CONTACT_NUMBER).validate().isEmptyOrNull) {
//           launchScreen(context, EditProfileScreen(isGoogle: true),
//               isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
//         } else {
//           if (await checkPermission())
//             await Geolocator.requestPermission().then((value) async {
//               await Geolocator.getCurrentPosition().then((value) {
//                 sharedPref.setDouble(LATITUDE, value.latitude);
//                 sharedPref.setDouble(LONGITUDE, value.longitude);
//                 launchScreen(context, DashboardScreen(),
//                     pageRouteAnimation: PageRouteAnimation.Slide,
//                     isNewTask: true);
//               });
//             }).catchError((e) {
//               launchScreen(context, DashboardScreen(),
//                   pageRouteAnimation: PageRouteAnimation.Slide,
//                   isNewTask: true);
//             });
//         }
//       }
//     }
//   }

//   @override
//   void setState(fn) {
//     if (mounted) super.setState(fn);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Image.asset(
//         'images/icon_jawad.png',
//         width: MediaQuery.of(context).size.width,
//         height: MediaQuery.of(context).size.height,
//         fit: BoxFit.fill,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taxi_driver/screens/sign_in_screen.dart';
import 'package:video_player/video_player.dart';

import '../../utils/Colors.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/app_common.dart';
import '../main.dart';
import '../utils/Common.dart';
import '../utils/Extensions/StringExtensions.dart';
import 'DashboardScreen.dart';
import 'EditProfileScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    _controller = VideoPlayerController.asset('images/logo.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
        _controller.play();
      });
    await Future.delayed(Duration(seconds: 2));
    if (sharedPref.getBool(IS_FIRST_TIME) ?? true) {
      await Geolocator.requestPermission().then((value) async {
        await Geolocator.getCurrentPosition().then((value) {
          sharedPref.setDouble(LATITUDE, value.latitude);
          sharedPref.setDouble(LONGITUDE, value.longitude);
          launchScreen(context, SignInScreenNew(),
              pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
        });
      }).catchError((e) {
        launchScreen(context, SignInScreenNew(),
            pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
      });
    } else {
      if (!appStore.isLoggedIn) {
        // launchScreen(context, SignInScreen(),
        //     pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
        launchScreen(context, SignInScreenNew(),
            pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
      } else {
        if (sharedPref.getString(CONTACT_NUMBER).validate().isEmptyOrNull) {
          launchScreen(context, EditProfileScreen(isGoogle: true),
              isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
        } else {
          if (await checkPermission())
            await Geolocator.requestPermission().then((value) async {
              await Geolocator.getCurrentPosition().then((value) {
                sharedPref.setDouble(LATITUDE, value.latitude);
                sharedPref.setDouble(LONGITUDE, value.longitude);
                launchScreen(context, DashboardScreen(),
                    pageRouteAnimation: PageRouteAnimation.Slide,
                    isNewTask: true);
              });
            }).catchError((e) {
              launchScreen(context, DashboardScreen(),
                  pageRouteAnimation: PageRouteAnimation.Slide,
                  isNewTask: true);
            });
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
        backgroundColor: primaryColor,
        body: _controller.value.isInitialized
            ? VideoPlayer(_controller)
            : Container());
  }
}

// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:taxi_driver/screens/DashboardScreen.dart';
// import 'package:taxi_driver/screens/SignInScreen.dart';
// import 'package:taxi_driver/utils/Extensions/StringExtensions.dart';
// import '../main.dart';
// import '../network/RestApis.dart';
// import '../utils/Colors.dart';
// import '../utils/Constants.dart';
// import '../utils/Extensions/app_common.dart';
// import 'EditProfileScreen.dart';
// import '../utils/Images.dart';
// import 'DocumentsScreen.dart';
// import 'WalkThroughScreen.dart';
// import 'sign_in_screen.dart';

// class SplashScreen extends StatefulWidget {
//   @override
//   SplashScreenState createState() => SplashScreenState();
// }

// class SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     init();
//   }

//   void init() async {
//     await driverDetail();

//     await Future.delayed(Duration(seconds: 2));
//     if (sharedPref.getBool(IS_FIRST_TIME) ?? true) {
//       await Geolocator.requestPermission().then((value) async {
//         await Geolocator.getCurrentPosition().then((value) {
//           sharedPref.setDouble(LATITUDE, value.latitude);
//           sharedPref.setDouble(LONGITUDE, value.longitude);
//           launchScreen(context, WalkThroughScreen(),
//               pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
//         });
//       }).catchError((e) {
//         launchScreen(context, WalkThroughScreen(),
//             pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
//       });
//     } else {
//       if (sharedPref.getString(CONTACT_NUMBER).validate().isEmptyOrNull &&
//           appStore.isLoggedIn) {
//         launchScreen(context, EditProfileScreen(isGoogle: true),
//             isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
//       } else if (sharedPref.getString(UID).validate().isEmptyOrNull &&
//           appStore.isLoggedIn) {
//         updateProfileUid().then((value) {
//           if (sharedPref.getInt(IS_Verified_Driver) == 1) {
//             launchScreen(context, DashboardScreen(),
//                 isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
//           } else {
//             launchScreen(context, DocumentsScreen(isShow: true),
//                 isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
//           }
//         });
//       } else if (sharedPref.getInt(IS_Verified_Driver) == 0 &&
//           appStore.isLoggedIn) {
//         launchScreen(context, DocumentsScreen(isShow: true),
//             pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
//       } else if (sharedPref.getInt(IS_Verified_Driver) == 1 &&
//           appStore.isLoggedIn) {
//         launchScreen(context, DashboardScreen(),
//             pageRouteAnimation: PageRouteAnimation.SlideBottomTop,
//             isNewTask: true);
//       } else {
//         launchScreen(context, SignInScreenNew(),
//             pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
//       }
//     }
//   }

//   Future<void> driverDetail() async {
//     if (appStore.isLoggedIn) {
//       await getUserDetail(userId: sharedPref.getInt(USER_ID))
//           .then((value) async {
//         await sharedPref.setInt(IS_ONLINE, value.data!.isOnline!);
//         appStore.isAvailable = value.data!.isAvailable;
//         if (value.data!.status == REJECT || value.data!.status == BANNED) {
//           toast(
//               '${language.yourAccountIs} ${value.data!.status}. ${language.pleaseContactSystemAdministrator}');
//           logout();
//         }
//       }).catchError((error) {});
//     }
//   }

//   @override
//   void setState(fn) {
//     if (mounted) super.setState(fn);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: primaryColor,
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Expanded(
//             child: Image.asset(
//               'images/splash.png',
//               fit: BoxFit.fill,
//               // height: 150,
//               // width: 150,
//             ),
//           ),
//           // SizedBox(height: 16),
//           // Text(language.appName,
//           //     style: boldTextStyle(color: Colors.white, size: 22)),
//         ],
//       ),
//     );
//   }
// }
