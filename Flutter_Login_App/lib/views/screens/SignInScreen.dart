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

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

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
    final isSmallScreen = size.width < 600;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFC4E1F5), Color(0xFF00A9E0)],
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
                  title: "Pro-Tech",
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
                    primaryColor: const Color(0xFF00A9E0),
                    accentColor: const Color(0xFFF4583E),
                    errorColor: Colors.deepOrange,
                    titleStyle: TextStyle(
                      color: const Color(0xFFF4583E),
                      fontSize: isSmallScreen ? 28 : 36,
                      fontWeight: FontWeight.w900,
                      shadows: const [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black45,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
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
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    cardTheme: CardTheme(
                      color: Colors.white,
                      elevation: 10,
                      margin: EdgeInsets.only(top: 20, bottom: isSmallScreen ? 30 : 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    inputTheme: InputDecorationTheme(
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: EdgeInsets.all(isSmallScreen ? 15 : 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    buttonTheme: LoginButtonTheme(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: const Color(0xFFF4583E),
                      elevation: 6,
                      highlightElevation: 8,
                    ),
                  ),
                  messages: LoginMessages(
                    forgotPasswordButton: 'Forgot Password?',
                    recoverPasswordIntro: 'Please enter your email to recover your password.',
                    recoverPasswordDescription: 'We will send you a link to reset your password.',
                    recoverPasswordSuccess: 'Password recovery email sent successfully!',
                  ),
                ),
              ),
              Positioned(
                bottom: constraints.maxHeight * 0.05,
                left: 0,
                right: 0,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildSocialLoginButtons(controller, context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
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
    final isSmallScreen = size.width < 600;
    final buttonSize = isSmallScreen ? size.width * 0.1 : size.width * 0.08;

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
        SizedBox(width: size.width * 0.03),
        _buildIconButton(
          icon: FontAwesomeIcons.google,
          onTap: controller.signInWithGoogle,
          tooltip: 'Sign in with Google',
          size: buttonSize,
          color: Colors.red.shade600,
        ),
        SizedBox(width: size.width * 0.03),
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
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
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
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 5,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Icon(icon, size: size * 0.6, color: Colors.white),
        ),
      ),
    );
  }
}