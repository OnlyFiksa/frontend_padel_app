import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; // Import Image Picker
import 'dart:io'; // Import File untuk nampilin gambar
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final Color primaryColor = const Color(0xFF0d59f2); 

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  String? _imagePath; // State untuk nyimpen lokasi file gambar

  @override
  void initState() {
    super.initState();
    _loadProfileData(); 
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? 'Pemain Padel';
      _emailController.text = prefs.getString('userEmail') ?? 'pemain@padelpro.com';
      _bioController.text = prefs.getString('userBio') ?? 'Saya siap main Padel kapan saja!';
      _imagePath = prefs.getString('profileImagePath'); // Tarik foto lama jika ada
    });
  }

  // Fungsi buka Galeri HP
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Buka galeri untuk milih foto
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _imagePath = image.path; // Update state dengan foto baru
      });
    }
  }

  Future<void> _saveProfileData() async {
    // 1. Tembak API CodeIgniter 4
    AuthService authService = AuthService();
    bool isSuccess = await authService.updateProfile(_nameController.text, _emailController.text);

    if (isSuccess) {
      // 2. Kalau sukses di DB, baru simpan ke memori HP biar tampilannya ikut berubah
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _nameController.text);
      await prefs.setString('userEmail', _emailController.text);
      await prefs.setString('userBio', _bioController.text);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perubahan berhasil disimpan ke database!'), backgroundColor: Colors.green));
      Navigator.pop(context); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menyimpan ke database.'), backgroundColor: Colors.red));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [IconButton(icon: Icon(Icons.done, color: primaryColor), onPressed: _saveProfileData)],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPhotoSection(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(Icons.person, 'Personal Information'),
                  _buildTextField('Full Name', _nameController),
                  const SizedBox(height: 16),
                  _buildTextField('Email Address', _emailController, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildTextField('Bio', _bioController, maxLines: 3),
                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveProfileData,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [primaryColor.withOpacity(0.1), Colors.transparent])),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120, height: 120, 
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  color: Colors.grey.shade300, 
                  border: Border.all(color: Colors.white, width: 4), 
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]
                ), 
                // Logika nampilin gambar atau icon default
                child: _imagePath != null 
                    ? ClipOval(child: Image.file(File(_imagePath!), fit: BoxFit.cover))
                    : const Icon(Icons.person, size: 60, color: Colors.white)
              ),
              Positioned(
                bottom: 0, right: 0, 
                child: GestureDetector(
                  onTap: _pickImage, // Panggil fungsi Galeri
                  child: Container(
                    padding: const EdgeInsets.all(8), 
                    decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)), 
                    child: const Icon(Icons.photo_camera, color: Colors.white, size: 16)
                  ),
                )
              )
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _pickImage, // Panggil fungsi Galeri
            style: TextButton.styleFrom(backgroundColor: primaryColor.withOpacity(0.1), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text('Change Profile Photo', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: Row(children: [Icon(icon, color: primaryColor), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]));
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        TextFormField(controller: controller, maxLines: maxLines, keyboardType: keyboardType, decoration: InputDecoration(filled: true, fillColor: Colors.grey.shade50, contentPadding: const EdgeInsets.all(16), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor)))),
      ],
    );
  }
}