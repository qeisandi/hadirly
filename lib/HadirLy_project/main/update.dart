import 'package:flutter/material.dart';
import 'package:hadirly/HadirLy_project/helper/servis/auth_servis.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  AuthService authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await authService.updateProfile(
        name: _nameController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Profil berhasil diperbarui!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memperbarui profil: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final oldName = ModalRoute.of(context)?.settings.arguments as String?;
    if (oldName != null && _nameController.text.isEmpty) {
      _nameController.text = oldName;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        title: Text("Ubah Profil", style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: const Color(0xFF1B3C53),
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.edit_outlined, color: Color(0xFF1B3C53)),
                  SizedBox(width: 8),
                  Text(
                    "Silakan perbarui data profil Anda",
                    style: TextStyle(fontFamily: 'Inter', fontSize: 18),
                  ),
                ],
              ),
              SizedBox(height: 24),

              _buildInputField(
                controller: _nameController,
                label: 'Nama Lengkap',
                icon: Icons.person_outline,
                validatorMessage: 'Nama tidak boleh kosong',
              ),

              SizedBox(height: 16),

              _buildInputField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
              ),

              SizedBox(height: 16),

              _buildInputField(
                controller: _phoneController,
                label: 'Nomor HP',
                icon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
              ),

              SizedBox(height: 16),

              _buildInputField(
                controller: _addressController,
                label: 'Alamat',
                icon: Icons.home_outlined,
                maxLines: 2,
              ),

              SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon:
                      _isLoading
                          ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Icon(Icons.save_alt_outlined, color: Colors.white),
                  label: Text(
                    _isLoading ? "Menyimpan..." : "Simpan Perubahan",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3C53),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? validatorMessage,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Color(0xFFEEF3F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      validator:
          validatorMessage != null
              ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return validatorMessage;
                }
                return null;
              }
              : null,
    );
  }
}
