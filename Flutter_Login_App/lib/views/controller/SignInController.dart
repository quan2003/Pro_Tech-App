import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../Routes/AppRoutes.dart'; // Import AppRoutes

class SignInController extends GetxController {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  /// Đăng nhập bằng Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        Get.snackbar(
          "Sign In Cancelled",
          "You canceled the Google sign-in.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        Get.snackbar(
          "Login Successful",
          "Welcome ${user.displayName ?? 'User'}!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Kiểm tra xem người dùng có phải là người dùng mới hay không
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          Get.offNamed(AppRoutes
              .TERMSANDCONDITIONS); // Điều hướng đến Điều khoản và Dịch vụ cho người dùng mới
        } else {
          Get.offNamed(AppRoutes
              .HOMESCREEN); // Điều hướng đến Home cho người dùng đã đăng nhập trước đó
        }
      }

      return user;
    } catch (e) {
      Get.snackbar(
        "Login Failed",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("Login error: $e");
      return null;
    }
  }

  /// Đăng nhập bằng Facebook
  Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AccessToken? accessToken = result.accessToken;

        if (accessToken != null) {
          final OAuthCredential facebookAuthCredential =
              FacebookAuthProvider.credential(accessToken.tokenString);

          UserCredential userCredential =
              await firebaseAuth.signInWithCredential(facebookAuthCredential);
          User? user = userCredential.user;

          if (user != null) {
            Get.snackbar(
              "Login Successful",
              "Welcome ${user.displayName ?? 'User'}!",
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );

            // Kiểm tra xem người dùng có phải là người dùng mới hay không
            if (userCredential.additionalUserInfo?.isNewUser ?? false) {
              Get.offNamed(AppRoutes
                  .TERMSANDCONDITIONS); // Điều hướng đến Điều khoản và Dịch vụ cho người dùng mới
            } else {
              Get.offNamed(AppRoutes
                  .HOMESCREEN); // Điều hướng đến Home cho người dùng đã đăng nhập trước đó
            }
          }

          return user;
        }
      } else if (result.status == LoginStatus.cancelled) {
        Get.snackbar(
          "Login Cancelled",
          "You cancelled the Facebook sign-in.",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return null;
      } else if (result.status == LoginStatus.failed) {
        Get.snackbar(
          "Login Failed",
          result.message ?? "An unknown error occurred",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }
    } catch (e) {
      Get.snackbar(
        "Login Failed",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("Facebook login error: $e");
      return null;
    }
    return null;
  }

  /// Xử lý Đăng ký với Email và Mật khẩu
  Future<void> handleSignup(SignupData signupData) async {
    try {
      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: signupData.name!,
        password: signupData.password!,
      );
      

      User? user = userCredential.user;

      if (user != null) {
        Get.snackbar(
          "Sign Up Successful",
          "Welcome ${user.email}!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offNamed(AppRoutes
            .TERMSANDCONDITIONS); // Điều hướng đến Điều khoản và Dịch vụ sau khi đăng ký
      }
    } catch (e) {
      Get.snackbar(
        "Sign Up Failed",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("Sign up error: $e");
    }
  }

  /// Xử lý Đăng nhập với Email và Mật khẩu
  Future<void> handleLogin(LoginData loginData) async {
    try {
      UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
        email: loginData.name,
        password: loginData.password,
      );

      User? user = userCredential.user;

      if (user != null) {
        Get.snackbar(
          "Login Successful",
          "Welcome back, ${user.email}!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offNamed(
            AppRoutes.HOMESCREEN); // Điều hướng đến Home sau khi đăng nhập
      }
    } catch (e) {
      print("Login error: $e");
      throw 'Thông tin đăng nhập không chính xác. Vui lòng thử lại.'; // Ném ngoại lệ với thông báo lỗi
    }
  }

  /// Xử lý Khôi phục Mật khẩu
  Future<void> handlePasswordRecovery(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        "Password Recovery",
        "Password reset email sent to $email",
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Password Recovery Failed",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("Password recovery error: $e");
    }
  }

  /// Đăng nhập Ẩn danh
  Future<User?> signInAnonymously() async {
    try {
      UserCredential userCredential = await firebaseAuth.signInAnonymously();
      User? user = userCredential.user;

      if (user != null) {
        Get.snackbar(
          "Anonymous Login Successful",
          "Welcome, Anonymous User!",
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        Get.offNamed(AppRoutes
            .HOMESCREEN); // Điều hướng đến Home sau khi đăng nhập ẩn danh
      }

      return user;
    } catch (e) {
      Get.snackbar(
        "Anonymous Login Failed",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("Anonymous login error: $e");
      return null;
    }
  }
}
