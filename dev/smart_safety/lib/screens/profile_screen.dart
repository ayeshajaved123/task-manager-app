import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_community_safety/models/user_model.dart';
import 'package:smart_community_safety/services/hive_service.dart';
import 'package:smart_community_safety/utils/helpers.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isVerifying = false;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cnicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final user = HiveService.userBox.get(userId);
    if (user != null) {
      setState(() {
        _user = user;
        _nameController.text = user.name;
        _phoneController.text = user.phone;
        _cnicController.text = user.cnic;
      });
    } else {
      // Create default user
      final firebaseUser = FirebaseAuth.instance.currentUser!;
      final newUser = UserModel(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'User',
        email: firebaseUser.email ?? 'No email',
        phone: '',
        cnic: '',
        isVerified: firebaseUser.emailVerified,
        profilePicturePath: null,
      );
      HiveService.userBox.put(userId, newUser);
      setState(() {
        _user = newUser;
        _nameController.text = newUser.name;
        _phoneController.text = newUser.phone;
        _cnicController.text = newUser.cnic;
      });
    }
  }

  Future<void> _pickImage() async {
    // Request permission
    final status = await Permission.photos.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      Helpers.showSnackbar(context, 'Gallery access denied');
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    try {
      // Save to persistent storage
      final appDir = await getApplicationDocumentsDirectory();
      final newPath = '${appDir.path}/profile_${_user!.id}.jpg';
      await File(image.path).copy(newPath);

      // Update user
      final updatedUser = UserModel(
        id: _user!.id,
        name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'User',
        email: _user!.email,
        phone: _phoneController.text.trim(),
        cnic: _cnicController.text.trim(),
        isVerified: _user!.isVerified,
        profilePicturePath: newPath,
      );
      await HiveService.userBox.put(_user!.id, updatedUser);
      setState(() {
        _user = updatedUser;
      });
      Helpers.showSnackbar(context, 'Profile picture updated!');
    } catch (e) {
      Helpers.showSnackbar(context, 'Failed to save image');
    }
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;

    final updatedUser = UserModel(
      id: _user!.id,
      name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'User',
      email: _user!.email,
      phone: _phoneController.text.trim(),
      cnic: _cnicController.text.trim(),
      isVerified: _user!.isVerified,
      profilePicturePath: _user!.profilePicturePath,
    );
    await HiveService.userBox.put(_user!.id, updatedUser);
    setState(() {
      _user = updatedUser;
    });
    Helpers.showSnackbar(context, 'Profile saved!');
  }

  Future<void> _resendVerificationEmail() async {
    if (_isVerifying) return;

    setState(() => _isVerifying = true);
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      Helpers.showSnackbar(context, 'Verification email sent!');

      // Update local user
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      final updatedUser = UserModel(
        id: _user!.id,
        name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'User',
        email: _user!.email,
        phone: _phoneController.text.trim(),
        cnic: _cnicController.text.trim(),
        isVerified: true,
        profilePicturePath: _user!.profilePicturePath,
      );
      await HiveService.userBox.put(_user!.id, updatedUser);
      setState(() {
        _user = updatedUser;
      });
    } catch (e) {
      Helpers.showSnackbar(context, 'Failed to send verification email');
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Profile Picture with Camera Icon
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Theme.of(context).cardColor,
                  child: _user!.profilePicturePath != null
                      ? ClipOval(
                    child: Image.file(
                      File(_user!.profilePicturePath!),
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  )
                      : const Icon(
                    Icons.account_circle,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
                // Camera icon button
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Name Field
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Email Field
            TextField(
              enabled: false,
              controller: TextEditingController(text: _user!.email),
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                suffixIcon: _user!.isVerified
                    ? const Icon(Icons.verified, color: Colors.green)
                    : TextButton(
                  onPressed: _resendVerificationEmail,
                  child: const Text('Verify', style: TextStyle(fontSize: 12)),
                ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Phone Field
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // CNIC Field
            TextField(
              controller: _cnicController,
              decoration: const InputDecoration(
                labelText: 'CNIC (Optional)',
                prefixIcon: Icon(Icons.credit_card),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: const Text('Save Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}