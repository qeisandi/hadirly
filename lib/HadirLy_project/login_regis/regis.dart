import 'package:flutter/material.dart';
import 'package:hadirly/HadirLy_project/helper/servis/servis.dart';

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
  String? _selectedBatch;
  String? _selectedKejuruan;

  final List<String> _genderOptions = ['Laki-laki', 'Perempuan'];
  final List<String> _batchOptions = ['Batch 1', 'Batch 2', 'Batch 3'];
  final List<String> _kejuruanOptions = [
    'Mobile Programming',
    'Desain Grafis',
    'Teknik Komputer dan Jaringan',
  ];

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
                crossAxisAlignment: CrossAxisAlignment.center,
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
                        children: [
                          _buildInputField(
                            label: 'Nama Lengkap',
                            controller: _nameController,
                            icon: Icons.person,
                            validator:
                                (v) =>
                                    v == null || v.trim().isEmpty
                                        ? 'Nama wajib diisi'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            label: 'Email',
                            controller: _emailController,
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator:
                                (v) =>
                                    v == null || !v.contains('@')
                                        ? 'Email tidak valid'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            label: 'Password',
                            controller: _passwordController,
                            icon: Icons.lock,
                            obscureText: _isObscure,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isObscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() => _isObscure = !_isObscure);
                              },
                            ),
                            validator:
                                (v) =>
                                    v == null || v.length < 6
                                        ? 'Minimal 6 karakter'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            label: 'Jenis Kelamin',
                            value: _selectedGender,
                            items: _genderOptions,
                            onChanged:
                                (val) => setState(() => _selectedGender = val),
                            validator: (v) => v == null ? 'Pilih gender' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            label: 'Batch',
                            value: _selectedBatch,
                            items: _batchOptions,
                            onChanged:
                                (val) => setState(() => _selectedBatch = val),
                            validator: (v) => v == null ? 'Pilih batch' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            label: 'Kejuruan',
                            value: _selectedKejuruan,
                            items: _kejuruanOptions,
                            onChanged:
                                (val) =>
                                    setState(() => _selectedKejuruan = val),
                            validator:
                                (v) => v == null ? 'Pilih kejuruan' : null,
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isLoading ? null : _registerUser,
                              child:
                                  _isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : const Text(
                                        'Daftar Sekarang',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
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

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authService = AuthService();

      int batchId = _batchOptions.indexOf(_selectedBatch!) + 1;
      int trainingId = _kejuruanOptions.indexOf(_selectedKejuruan!) + 1;

      final result = await authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        jenisKelamin: _selectedGender!,
        batchId: batchId,
        trainingId: trainingId,
      );

      setState(() => _isLoading = false);

      if (result != null && result.data?.token != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Registrasi berhasil!")));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrasi gagal. Coba lagi.")),
        );
      }
    }
  }

  Widget _buildInputField({
    required String label,
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
        labelText: label,
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
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?)? onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFEEF3F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items:
          items
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
    );
  }
}
