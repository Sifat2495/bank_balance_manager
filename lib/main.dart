import 'package:flutter/material.dart';
import 'home_page.dart';
import 'dart:async';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const CardBalanceApp());
}

class CardBalanceApp extends StatelessWidget {
  const CardBalanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Balance Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _backgroundController;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();


    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));


    _backgroundController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));


    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, 0),
                radius: _gradientAnimation.value,
                colors: [Colors.white, Colors.blue.shade800],
                stops: [0.5, 1.0],
              ),
            ),
            child: Center(
              child: ScaleTransition(
                scale: _animation,
                child: Image.asset(
                  'assets/icons/splash1.png',
                  width: 150,
                  height: 150,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _backgroundController.dispose();
    super.dispose();
  }
}
