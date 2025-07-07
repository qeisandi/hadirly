import 'package:flutter/material.dart';
import 'package:hadirly/HadirLy_project/login_regis/regis.dart';

class Login extends StatefulWidget {
  static const String id = "/login";
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 200),
                child: Column(
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
              ),
            ],
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 300),
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
                            SizedBox(height: 40),
                            Text(
                              'Username',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                fillColor: Color(0x50456882),
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
                                fillColor: Color(0x50456882),
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
                                  if (_formKey.currentState!.validate()) {}
                                },
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Don't have an account?"),
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
                                      color: Color.fromARGB(255, 119, 106, 97),
                                      fontWeight: FontWeight.bold,
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
