import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'services/user_services.dart';
import '../models/user_model.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final UserService _userService = UserService();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = false;
  bool _isEditing = false;
  late AppUser? _user;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final uid = _userService.currentUser?.uid;
    if (uid != null) {
      _user = await _userService.getUserData(uid);
      if (_user != null) {
        _nameController.text = _user!.name ?? '';
        _phoneController.text = _user!.phone ?? '';
        _bioController.text = _user!.bio ?? '';
        _selectedGender = _user!.gender;
        _selectedDate = _user!.birthDate;
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      if (image != null) {
        setState(() => _isLoading = true);
        String photoURL = await uploadToCloudinary(File(image.path));
        if (photoURL.isNotEmpty && _user != null) {
          await _userService.updateUserPhoto(_user!.uid, photoURL);
          await _loadUserData();
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при загрузке фото: $e')),
      );
    }
  }

  Future<String> uploadToCloudinary(File file) async {
    final cloudName = "dbyfybai7";
    final uploadPreset = "socpet_upload";
    final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    var request = http.MultipartRequest("POST", uri);
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final data = jsonDecode(res);
      return data["secure_url"];
    } else {
      throw Exception("Ошибка загрузки изображения");
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveChanges() async {
    if (_user == null) return;
    setState(() => _isLoading = true);
    try {
      final uid = _user!.uid;

      if (_nameController.text != _user!.name) {
        await _userService.updateUserName(uid, _nameController.text);
      }
      if (_phoneController.text != _user!.phone) {
        await _userService.updateUserPhone(uid, _phoneController.text);
      }
      if (_bioController.text != _user!.bio) {
        await _userService.updateUserBio(uid, _bioController.text);
      }
      if (_selectedGender != _user!.gender && _selectedGender != null) {
        await _userService.updateUserGender(uid, _selectedGender!);
      }
      if (_selectedDate != _user!.birthDate && _selectedDate != null) {
        await _userService.updateUserBirthDate(uid, _selectedDate!);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Профиль обновлён!"), backgroundColor: Colors.green),
      );

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      _loadUserData();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка при сохранении: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_user == null) {
      return const Scaffold(body: Center(child: Text("Пользователь не найден")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFFF3AB3F),
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(icon: const Icon(Icons.edit), onPressed: () => setState(() => _isEditing = true)),
          if (_isEditing) IconButton(icon: const Icon(Icons.check), onPressed: _saveChanges),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Аватар
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _user!.photoURL != null ? NetworkImage(_user!.photoURL!) : null,
                    child: _user!.photoURL == null ? const Icon(Icons.person, size: 60) : null,
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFF3AB3F),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 18),
                          color: Colors.white,
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Email
            Card(
              child: ListTile(
                leading: const Icon(Icons.email),
                title: const Text("Email"),
                subtitle: Text(_user!.email),
              ),
            ),
            const SizedBox(height: 10),

            // Имя
            Card(
              child: _isEditing
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Имя", prefixIcon: Icon(Icons.person))),
                    )
                  : ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text("Имя"),
                      subtitle: Text(_user!.name ?? 'Не указано'),
                    ),
            ),
            const SizedBox(height: 10),

            // Пол
            Card(
              child: _isEditing
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(labelText: "Пол", prefixIcon: Icon(Icons.people)),
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('Мужской')),
                          DropdownMenuItem(value: 'female', child: Text('Женский')),
                          DropdownMenuItem(value: 'other', child: Text('Другое')),
                        ],
                        onChanged: (v) => setState(() => _selectedGender = v),
                      ),
                    )
                  : ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text("Пол"),
                      subtitle: Text(_user!.gender?.toUpperCase() ?? 'Не указано'),
                    ),
            ),
            const SizedBox(height: 10),

            // Дата рождения
            Card(
              child: _isEditing
                  ? ListTile(
                      leading: const Icon(Icons.cake),
                      title: const Text("Дата рождения"),
                      subtitle: Text(_selectedDate != null ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}" : 'Не указано'),
                      trailing: IconButton(icon: const Icon(Icons.calendar_today), onPressed: _selectDate),
                    )
                  : ListTile(
                      leading: const Icon(Icons.cake),
                      title: const Text("Дата рождения"),
                      subtitle: Text(_user!.birthDate != null ? "${_user!.birthDate!.day}/${_user!.birthDate!.month}/${_user!.birthDate!.year}" : 'Не указано'),
                    ),
            ),
            const SizedBox(height: 10),

            // Телефон
            Card(
              child: _isEditing
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(controller: _phoneController, decoration: const InputDecoration(labelText: "Телефон", prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone),
                    )
                  : ListTile(
                      leading: const Icon(Icons.phone),
                      title: const Text("Телефон"),
                      subtitle: Text(_user!.phone ?? 'Не указано'),
                    ),
            ),
            const SizedBox(height: 10),

            // Био
            Card(
              child: _isEditing
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(controller: _bioController, decoration: const InputDecoration(labelText: "Био", prefixIcon: Icon(Icons.info)), maxLines: 3),
                    )
                  : ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text("Био"),
                      subtitle: Text(_user!.bio ?? 'Нет информации'),
                    ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {

                await FirebaseAuth.instance.signOut();


                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const Login_Page()),
                    (route) => false,
                  );
                }
              },
              child: const Text("Выйти"),
            ),
          ],
        ),
      ),
    );
  }
}