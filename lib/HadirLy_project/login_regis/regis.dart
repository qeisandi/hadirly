import 'package:flutter/material.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_batch.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_training.dart';
import 'package:hadirly/HadirLy_project/helper/servis/auth_servis.dart';
import 'package:hadirly/HadirLy_project/helper/servis/batch_servis.dart';
import 'package:hadirly/HadirLy_project/helper/servis/training_servis.dart';

class Regis extends StatefulWidget {
  static const String id = "/register";
  const Regis({super.key});

  @override
  State<Regis> createState() => _RegisState();
}

class _RegisState extends State<Regis> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isObscure = true;
  bool _isLoading = false;

  AuthService authService = AuthService();

  String? _selectedGender;
  BatchData? _selectedBatch;
  Trainings? _selectedTraining;

  final List<String> _genderOptions = ['L', 'P'];
  List<BatchData> _batchOptions = [];
  List<Trainings> _trainingOptions = [];

  @override
  void initState() {
    super.initState();
    _loadBatchData();
    _loadTrainingData();
  }

  Future<void> _loadBatchData() async {
    try {
      final batches = await BatchServis().ambilBatch();
      setState(() {
        _batchOptions = batches;
        if (_batchOptions.isNotEmpty) {
          _selectedBatch = _batchOptions.first;
        }
      });
    } catch (e) {
      debugPrint('Error loading batch: $e');
    }
  }

  Future<void> _loadTrainingData() async {
    try {
      final trainings = await TrainingService().ambilTrainings();
      setState(() {
        _trainingOptions = trainings;
        if (_trainingOptions.isNotEmpty) {
          _selectedTraining = _trainingOptions.first;
        }
      });
    } catch (e) {
      debugPrint('Error loading training: $e');
    }
  }

  void _registerUser() async {
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pilih jenis kelamin terlebih dahulu")),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        jenisKelamin: _selectedGender ?? '',
        batchId: _selectedBatch?.id ?? 0,
        trainingId: _selectedTraining?.id ?? 0,
      );

      setState(() => _isLoading = false);

      if (result != null && result.data?.token != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text("Registrasi berhasil!"),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Registrasi gagal. Coba lagi."),
          ),
        );
      }
    }
  }

  String? _validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'Wajib diisi';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || !value.contains('@')) {
      return 'Email tidak valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return 'Minimal 6 karakter';
    }
    return null;
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
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  SizedBox(height: 60),
                  Text(
                    'Register',
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      color: Colors.white,
                      fontSize: 38,
                    ),
                  ),
                  Text(
                    'Daftarkan akun kamu sekarang!',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 16, bottom: 6),
                            child: Text(
                              "Nama Lengkap",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.next,

                            controller: _nameController,
                            validator: _validateRequired,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: Color(0xFFEEF3F6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 16, bottom: 6),
                            child: Text(
                              "Email",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.next,

                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email, color: Colors.grey),
                              filled: true,
                              fillColor: Color(0xFFEEF3F6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 16, bottom: 6),
                            child: Text(
                              "Password",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.next,

                            controller: _passwordController,
                            obscureText: _isObscure,
                            validator: _validatePassword,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock, color: Colors.grey),
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
                              filled: true,
                              fillColor: Color(0xFFEEF3F6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 16, bottom: 6),
                            child: Text(
                              "Jenis Kelamin",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Column(
                            children:
                                _genderOptions.map((gender) {
                                  return RadioListTile<String>(
                                    value: gender,
                                    groupValue: _selectedGender,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedGender = value;
                                      });
                                    },
                                    title: Text(gender),
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                  );
                                }).toList(),
                          ),
                          if (_selectedGender == null)
                            Padding(
                              padding: EdgeInsets.only(top: 16, bottom: 6),
                              child: Text(
                                "Batch",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                          DropdownButtonFormField<String>(
                            value: _selectedBatch?.batchKe,
                            isExpanded: true,
                            items:
                                _batchOptions.map((b) {
                                  return DropdownMenuItem(
                                    value: b.batchKe ?? '',
                                    child: Text(b.batchKe ?? ''),
                                  );
                                }).toList(),
                            onChanged: (val) {
                              final selected = _batchOptions.firstWhere(
                                (b) => b.batchKe == val,
                              );
                              setState(() => _selectedBatch = selected);
                            },
                            validator: _validateRequired,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.group, color: Colors.grey),
                              filled: true,
                              fillColor: Color(0xFFEEF3F6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 16, bottom: 6),
                            child: Text(
                              "Kejuruan",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          DropdownButtonFormField<Trainings>(
                            value: _selectedTraining,
                            isExpanded: true,
                            items:
                                _trainingOptions.map((item) {
                                  return DropdownMenuItem<Trainings>(
                                    value: item,
                                    child: Text(item.title ?? ''),
                                  );
                                }).toList(),
                            onChanged:
                                (val) =>
                                    setState(() => _selectedTraining = val),
                            validator:
                                (v) => v == null ? 'Wajib dipilih' : null,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.school,
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: Color(0xFFEEF3F6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isLoading ? null : _registerUser,
                              child:
                                  _isLoading
                                      ? CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : Text(
                                        'Daftar Sekarang',
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
                              Text("Sudah punya akun?"),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
