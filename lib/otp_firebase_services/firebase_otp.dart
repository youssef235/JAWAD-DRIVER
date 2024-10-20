import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> verifyPhoneNumber(
      String phoneNumber, Function(String, String) codeSent) async {
    print('Attempting to send OTP to $phoneNumber');

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: "+966${phoneNumber}",
        timeout: Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('Verification completed automatically');
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
          throw e.message!; // رفع الاستثناء في حالة الفشل
        },
        codeSent: (String verificationId, int? resendToken) {
          print('OTP sent successfully. Verification ID: $verificationId');
          codeSent(verificationId,
              phoneNumber); // إرسال رقم الهاتف مع الـ verificationId
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Auto retrieval timeout for verification ID: $verificationId');
        },
      );
    } catch (error) {
      print('Error during OTP sending: $error');
      throw error; // رفع الاستثناء عند حدوث خطأ
    }
  }

  Future<void> signInWithOtp(String verificationId, String smsCode) async {
    print(
        'Attempting to sign in with OTP: $smsCode and Verification ID: $verificationId');

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    try {
      await _auth.signInWithCredential(credential);
      print('Signed in successfully!');
    } catch (e) {
      print('Error during sign in: $e');
      throw e; // رفع الاستثناء عند حدوث خطأ
    }
  }
}
