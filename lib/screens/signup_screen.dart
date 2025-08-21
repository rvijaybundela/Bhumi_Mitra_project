import 'package:flutter/material.dart';

const kBrown = Color(0xFF8B4513);

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final otpCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    mobileCtrl.dispose();
    otpCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.black38, fontSize: 16),
    filled: true,
    fillColor: Colors.white,
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black26, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black26, width: 1),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide(color: kBrown, width: 2),
    ),
  );

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 8),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: kBrown,
        fontSize: 16,          // increased label size
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kBrown,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Bhumi Mitra',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        // Settings icon removed
      ),
      body: Stack(
        children: [
          // Bottom map image
          Positioned.fill(
            child: Image.asset('assets/images/bg_map.png', fit: BoxFit.cover),
          ),
          // Top white half mask (keeps split look)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: size.height * 0.42,
            child: Container(color: Colors.white),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 96), // reduced bottom padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 6),
                  const Text(
                    'Sign Up',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: kBrown,
                      fontSize: 38,                 // increased title size
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Already Registered? Log in here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                  const SizedBox(height: 14),

                  // Name
                  _sectionTitle('Name'),
                  TextField(
                    controller: nameCtrl,
                    decoration: _dec('Enter full name'),
                    textInputAction: TextInputAction.next,
                  ),

                  // Email
                  _sectionTitle('Email'),
                  TextField(
                    controller: emailCtrl,
                    decoration: _dec('Enter email'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),

                  // Mobile
                  _sectionTitle('Mobile No'),
                  TextField(
                    controller: mobileCtrl,
                    decoration: _dec('Enter mobile number'),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),

                  // OTP
                  _sectionTitle('OTP'),
                  TextField(
                    controller: otpCtrl,
                    decoration: _dec('Enter OTP here'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),

          // Register button (slightly less spacing below)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18), // less space than before
              child: SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/bhumi_mitra');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBrown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    elevation: 3,
                  ),
                  child: const Text('Register'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
