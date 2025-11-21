import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../Styled accessories/styled_body_text.dart';
import '../Styled accessories/styled_header_text.dart';
import 'Login_Page.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ProfilePage({super.key, required this.userData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Map<String, dynamic> _currentUser;
  bool _isEditing = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late int _age;
  late String _gender;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.userData;
    _initializeControllers();
  }

  void _initializeControllers() {
    _usernameController =
        TextEditingController(text: _currentUser['username']);
    _bioController = TextEditingController(text: _currentUser['bio'] ?? '');
    _age = _currentUser['age'] ?? 18;
    _gender = _currentUser['gender'] ?? 'other';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // --- API Call: Update Profile ---
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final String apiUrl = '${dotenv.env['API_BASE_URL']}/api/users/profile';
    // In a real app, get token from secure storage
    // final token = await SecureStorage.getToken();

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          // 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': _currentUser['_id'],
          'username': _usernameController.text.trim(),
          'bio': _bioController.text.trim(),
          'age': _age,
          'gender': _gender,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _currentUser = data['user'];
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Failed to update profile.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not connect to server.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => _isLoading = false);
  }

  void _logout() {
    // TODO: Clear secure storage token
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.red[800],
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) _initializeControllers(); // Reset on cancel
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 20),
              
              // --- Username ---
              _buildTextField("Username", _usernameController),
              const SizedBox(height: 10),

              // --- Bio ---
              _buildTextField("Bio", _bioController, maxLines: 3),
              const SizedBox(height: 20),

              // --- Age & Gender Row ---
              Row(
                children: [
                  Expanded(child: _buildAgeDropdown()),
                  const SizedBox(width: 20),
                  Expanded(child: _buildGenderDropdown()),
                ],
              ),
              const SizedBox(height: 30),

              // --- Save Button (only in edit mode) ---
              if (_isEditing)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[800],
                    ),
                    onPressed: _isLoading ? null : _updateProfile,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Changes',
                            style: TextStyle(fontSize: 18)),
                  ),
                ),
              const SizedBox(height: 20),

              // --- Logout Button ---
              TextButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text("Logout", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      enabled: _isEditing,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: _isEditing ? const OutlineInputBorder() : InputBorder.none,
        filled: _isEditing,
        fillColor: Colors.grey[100],
      ),
      validator: (value) =>
          value == null || value.isEmpty ? '$label cannot be empty' : null,
    );
  }

  Widget _buildAgeDropdown() {
    return DropdownButtonFormField<int>(
      value: _age,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Age',
        border: _isEditing ? const OutlineInputBorder() : InputBorder.none,
      ),
      items: List.generate(83, (index) => index + 18)
          .map((age) => DropdownMenuItem(value: age, child: Text('$age')))
          .toList(),
      onChanged: _isEditing ? (value) => setState(() => _age = value!) : null,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Gender',
        border: _isEditing ? const OutlineInputBorder() : InputBorder.none,
      ),
      items: ['male', 'female', 'other']
          .map((g) => DropdownMenuItem(value: g, child: Text(g.toUpperCase())))
          .toList(),
      onChanged: _isEditing ? (value) => setState(() => _gender = value!) : null,
    );
  }
}