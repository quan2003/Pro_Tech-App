import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/SignInController.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_login_app/views/screens/HomeScreen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final SignInController controller = Get.put(SignInController());
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 255, 255),
                  Color(0xFF00a9e0),
                  Color(0xFF0077b6),
                  Color(0xFF023e8a)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: FlutterLogin(
              onSignup: (val) async {
                await controller.handleSignup(val);
                return null;
              },
              logo: const AssetImage('assets/images/AppLogo.png'),
              initialAuthMode: AuthMode.login,
              userType: LoginUserType.email,
              onLogin: (LoginData val) async {
                try {
                  await controller.handleLogin(val);
                  Navigator.of(context).push(_createRoute());
                  return null;
                } catch (e) {
                  return e.toString();
                }
              },
              onRecoverPassword: (val) async {
                await controller.handlePasswordRecovery(val);
                return null;
              },
              theme: LoginTheme(
                primaryColor: const Color.fromARGB(255, 255, 255, 255),
                accentColor: const Color.fromARGB(255, 115, 163, 248),
                errorColor: Colors.deepOrange,
                titleStyle: TextStyle(
                  color: const Color(0xFFF4583E),
                  fontSize: isSmallScreen ? 28 : 36,
                  fontWeight: FontWeight.w900,
                ),
                bodyStyle: TextStyle(
                  fontSize: isSmallScreen ? 14 : 18,
                  color: Colors.black,
                ),
                textFieldStyle: TextStyle(
                  fontSize: isSmallScreen ? 14 : 18,
                  color: Colors.black,
                ),
                buttonStyle: TextStyle(
                  fontSize: isSmallScreen ? 16 : 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
                cardTheme: CardTheme(
                  color: const Color.fromARGB(255, 97, 201, 249), // Màu Baby Blue
                  elevation: 5,
                  margin: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                inputTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  prefixIconColor: Colors.grey,
                  suffixIconColor: Colors.grey,
                ),
                buttonTheme: LoginButtonTheme(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: const Color.fromARGB(255, 255, 149, 95),
                  elevation: 5,
                  highlightElevation: 3,
                ),
              ),
              messages: LoginMessages(
                userHint: 'Email',
                passwordHint: 'Password',
                confirmPasswordHint: 'Confirm Password',
                loginButton: 'LOGIN',
                signupButton: 'SIGN UP',
                forgotPasswordButton: 'Forgot Password?',
                recoverPasswordIntro:
                    'Please enter your email to recover your password.',
                recoverPasswordDescription:
                    'We will send you a link to reset your password.',
                recoverPasswordSuccess:
                    'Password recovery email sent successfully!',
                flushbarTitleError: 'Error',
                flushbarTitleSuccess: 'Success',
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.05,
            left: 0,
            right: 0,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildSocialLoginButtons(controller, context),
            ),
          ),
        ],
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const HomeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  Widget _buildSocialLoginButtons(
      SignInController controller, BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final buttonSize = isSmallScreen ? size.width * 0.1 : size.width * 0.08;

    return Column(
      children: [
        const Text(
          'Or sign in with',
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 16),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: FontAwesomeIcons.google,
              onTap: controller.signInWithGoogle,
              tooltip: 'Sign in with Google',
              size: buttonSize,
              color: Colors.red.shade600,
            ),
            SizedBox(width: size.width * 0.03),
            _buildSocialButton(
              icon: FontAwesomeIcons.facebook,
              onTap: controller.signInWithFacebook,
              tooltip: 'Sign in with Facebook',
              size: buttonSize,
              color: Colors.blue.shade800,
            ),
            SizedBox(width: size.width * 0.03),
            _buildSocialButton(
              icon: FontAwesomeIcons.twitter,
              onTap: () {
                // TODO: Implement Twitter sign-in
              },
              tooltip: 'Sign in with Twitter',
              size: buttonSize,
              color: Colors.lightBlue,
            ),
            SizedBox(width: size.width * 0.03),
            _buildSocialButton(
              icon: Icons.person_outline,
              onTap: controller.signInAnonymously,
              tooltip: 'Sign in Anonymously',
              size: buttonSize,
              color: Colors.grey.shade300,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    required double size,
    required Color color,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
          ),
          child: Icon(icon, size: size * 0.6, color: color),
        ),
      ),
    );
  }
}
