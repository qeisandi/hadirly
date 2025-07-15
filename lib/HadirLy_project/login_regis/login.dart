import 'package:flutter/material.dart';
import 'package:hadirly/HadirLy_project/bottomNav/bottom_nav.dart';
import 'package:hadirly/HadirLy_project/helper/Utils/snackbar_util.dart';
import 'package:hadirly/HadirLy_project/helper/servis/auth_servis.dart';
import 'package:hadirly/HadirLy_project/helper/sharedpref/pref_api.dart';
import 'package:hadirly/HadirLy_project/login_regis/regis.dart';

class Login extends StatefulWidget {
  static const String id = "/login";
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  AuthService authService = AuthService();
  bool isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;

  void login() async {
    setState(() {
      isLoading = true;
    });

    final res = await AuthService().loginUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    print("Respon dari API: $res");

    if (res["data"] != null) {
      final token = res['data']['token'];
      await SharedPref.saveToken(token);

      showCustomSnackbar(
        context,
        'Anda Berhasil Login!',
        type: SnackbarType.success,
      );

      Navigator.pushNamed(context, BottomNavScreen.id);
    } else {
      final message = res["message"] ?? "Terjadi kesalahan saat login.";
      showCustomSnackbar(context, "Maaf, $message", type: SnackbarType.error);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Center(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontFamily: 'Gilroy',
                                color: Colors.white,
                                fontSize: 32,
                              ),
                            ),
                            Text(
                              'Login to your Account',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 24),
                              Text(
                                'Username',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  fillColor: Color(0xFFEEF3F6),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator:
                                    (value) =>
                                        value == null || !value.contains('@')
                                            ? 'Enter valid email'
                                            : null,
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Password',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _isObscure,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  fillColor: Color(0xFFEEF3F6),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isObscure
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isObscure = !_isObscure;
                                      });
                                    },
                                  ),
                                ),
                                validator:
                                    (value) =>
                                        value == null || value.length < 6
                                            ? 'Password too short'
                                            : null,
                              ),
                              SizedBox(height: 40),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      print('Email : ${_emailController.text}');
                                      print(
                                        'Password : ${_passwordController.text}',
                                      );
                                      login();
                                    }
                                  },
                                  child:
                                      isLoading
                                          ? CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                          : Text(
                                            'Login',
                                            style: TextStyle(
                                              fontFamily: 'Gilroy',
                                              color: Colors.white,
                                            ),
                                          ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account?",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        createRoute(Regis()),
                                      );
                                    },
                                    child: Text(
                                      'Register',
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Route createRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: Duration(milliseconds: 500),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
