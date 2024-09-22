import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_login_app/views/screens/HomeScreen.dart';
import 'package:get/get.dart';
import '../controller/SignInController.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController and Animations
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    // Start the animations when the screen builds
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SignInController controller = Get.put(SignInController());
    final size = MediaQuery.of(context).size;
    final bottomPadding = size.height * 0.05; // 5% of screen height

    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient to match the logo's colors
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFC4E1F5), Color(0xFF00A9E0)], // Light blue gradient background
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
              logo: AssetImage('assets/images/AppLogo.png'), // Use the provided logo
              title: "Pro-Tech",
              initialAuthMode: AuthMode.login,
              userType: LoginUserType.email,
              onLogin: (LoginData val) async {
                try {
                  await controller.handleLogin(val);
                  // Navigate to TermsAndConditionsScreen if login is successful
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
                primaryColor: Color(0xFF00A9E0), // Primary blue color from the logo
                accentColor: Color(0xFFF4583E), // Accent orange color from the logo
                errorColor: Colors.deepOrange,
                titleStyle: TextStyle(
                  color: Color(0xFFF4583E), // Title in orange
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black45,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
                bodyStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
                textFieldStyle: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
                buttonStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                cardTheme: CardTheme(
                  color: Colors.white,
                  elevation: 10,
                  margin: EdgeInsets.only(top: 20, bottom: 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                inputTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding: EdgeInsets.all(20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                buttonTheme: LoginButtonTheme(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Color(0xFFF4583E), // Button color in orange
                  elevation: 6,
                  highlightElevation: 8,
                ),
              ),
              messages: LoginMessages(
                forgotPasswordButton: 'Forgot Password?',
                recoverPasswordIntro:
                    'Please enter your email to recover your password.',
                recoverPasswordDescription:
                    'We will send you a link to reset your password.',
                recoverPasswordSuccess:
                    'Password recovery email sent successfully!',
              ),
            ),
          ),

          // Social login buttons
          Positioned(
            bottom: bottomPadding,
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
      pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Animation starts from the right
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  Widget _buildSocialLoginButtons(SignInController controller, BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonSize = size.width * 0.12; // 12% of screen width

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIconButton(
          icon: Icons.person_outline,
          onTap: controller.signInAnonymously,
          tooltip: 'Sign in Anonymously',
          size: buttonSize,
          color: Colors.grey.shade300,
        ),
        SizedBox(width: size.width * 0.05), // 5% of screen width
        _buildIconButton(
          icon: FontAwesomeIcons.google,
          onTap: controller.signInWithGoogle,
          tooltip: 'Sign in with Google',
          size: buttonSize,
          color: Colors.red.shade600,
        ),
        SizedBox(width: size.width * 0.05), // 5% of screen width
        _buildIconButton(
          icon: FontAwesomeIcons.facebook,
          onTap: controller.signInWithFacebook,
          tooltip: 'Sign in with Facebook',
          size: buttonSize,
          color: Colors.blue.shade800,
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    required double size,
    required Color color,
  }) {
    return Tooltip(
      message: tooltip,
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.teal.shade700,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 10,
                offset: Offset(4, 4),
              ),
            ],
          ),
          child: Icon(icon, size: size * 0.6, color: Colors.white),
        ),
      ),
    );
  }
}
