import 'package:flutter/material.dart';
import 'package:hadirly/HadirLy_project/helper/servis/servis.dart';
import 'package:hadirly/HadirLy_project/helper/servis/batch_servis.dart';
import 'package:hadirly/HadirLy_project/helper/model/model_batch.dart';

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
  String? _selectedTrainingTitle;

  final List<String> _genderOptions = ['Laki-laki', 'Perempuan'];
  List<BatchData> _batchOptions = [];

  final List<String> _kejuruanOptions = [
    'Desain Grafis',
    'Teknisi Komputer',
    'Barista',
    'Web Programming',
    'Digital Marketing',
  ];

  @override
  void initState() {
    super.initState();
    _loadBatchData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    'Register',
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      color: Colors.white,
                      fontSize: 38,
                    ),
                  ),
                  const Text(
                    'Daftarkan akun kamu sekarang!',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
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
                          _buildLabel('Nama Lengkap'),
                          _buildInputField(
                            controller: _nameController,
                            icon: Icons.person,
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                          ),
                          _buildLabel('Email'),
                          _buildInputField(
                            controller: _emailController,
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v == null || !v.contains('@') ? 'Email tidak valid' : null,
                          ),
                          _buildLabel('Password'),
                          _buildInputField(
                            controller: _passwordController,
                            icon: Icons.lock,
                            obscureText: _isObscure,
                            suffixIcon: IconButton(
                              icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _isObscure = !_isObscure),
                            ),
                            validator: (v) => v == null || v.length < 6 ? 'Minimal 6 karakter' : null,
                          ),
                          _buildLabel('Jenis Kelamin'),
                          _buildDropdown(
                            value: _selectedGender,
                            items: _genderOptions,
                            onChanged: (val) => setState(() => _selectedGender = val),
                            icon: Icons.wc,
                          ),
                          _buildLabel('Batch'),
                          _buildDropdown(
                            value: _selectedBatch?.batchKe,
                            items: _batchOptions.map((b) => b.batchKe ?? '').toList(),
                            onChanged: (val) {
                              final selected = _batchOptions.firstWhere((b) => b.batchKe == val);
                              setState(() => _selectedBatch = selected);
                            },
                            icon: Icons.group,
                          ),
                          _buildLabel('Kejuruan'),
                          _buildDropdown(
                            value: _selectedTrainingTitle,
                            items: _kejuruanOptions,
                            onChanged: (val) => setState(() => _selectedTrainingTitle = val),
                            icon: Icons.school,
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isLoading ? null : _registerUser,
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Daftar Sekarang', style: TextStyle(fontSize: 16, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Sudah punya akun?"),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
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

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        jenisKelamin: _selectedGender!,
        batchId: _selectedBatch!.id!,
        trainingId: 1,
      );

      setState(() => _isLoading = false);

      if (result != null && result.data?.token != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrasi berhasil!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrasi gagal. Coba lagi.")),
        );
      }
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFEEF3F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      onChanged: onChanged,
      validator: (v) => v == null || v.isEmpty ? 'Wajib dipilih' : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFEEF3F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }
}
