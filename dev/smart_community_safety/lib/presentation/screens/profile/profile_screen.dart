import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _cnic = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final p = context.read<ProfileProvider>();
      await p.load();
      if (!mounted) return;
      _name.text = p.name;
      _phone.text = p.phone;
      _cnic.text = p.cnic;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _cnic.dispose();
    super.dispose();
  }

  int _trustScore(ProfileProvider p) {
    int score = 40;
    if (p.name.trim().isNotEmpty) score += 15;
    if (p.phone.trim().isNotEmpty) score += 10;
    if (p.cnic.trim().isNotEmpty) score += 15;
    if (p.photoPath.trim().isNotEmpty) score += 10;
    if (p.verificationRequested) score += 5;
    if (p.isVerified) score += 20;
    if (score > 100) score = 100;
    return score;
  }

  Future<void> _pickPhoto(ProfileProvider p) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (x == null) return;

    await p.save(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      cnic: _cnic.text.trim(),
      photoPath: x.path,
    );
  }

  Future<void> _save(ProfileProvider p) async {
    await p.save(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      cnic: _cnic.text.trim(),
      photoPath: p.photoPath,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProfileProvider>();
    final email = FirebaseAuth.instance.currentUser?.email ?? "";

    final score = _trustScore(p);
    final verified = p.isVerified;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")), // ✅ only once
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar + upload
                  GestureDetector(
                    onTap: () => _pickPhoto(p),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                          backgroundImage: p.photoPath.trim().isNotEmpty && File(p.photoPath).existsSync()
                              ? FileImage(File(p.photoPath))
                              : null,
                          child: p.photoPath.trim().isEmpty
                              ? Icon(Icons.person_rounded,
                              size: 48, color: Theme.of(context).colorScheme.primary)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Name below image
                  Text(
                    p.name.trim().isEmpty ? "Your Name" : p.name.trim(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),

                  // Email under name
                  Text(
                    email,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),

                  const SizedBox(height: 10),

                  // Verified badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: verified ? Colors.green.withOpacity(0.12) : Colors.orange.withOpacity(0.12),
                    ),
                    child: Text(
                      verified ? "Verified User" : "Unverified User",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: verified ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Verification request button
                  FilledButton.tonalIcon(
                    onPressed: verified
                        ? null
                        : () async {
                      await p.requestVerification();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Verification request sent.")),
                      );
                    },
                    icon: const Icon(Icons.verified_outlined),
                    label: Text(verified ? "Verified" : "Request Verification"),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Trust score
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Trust Score", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: score / 100,
                      minHeight: 12,
                      backgroundColor: Colors.black.withOpacity(0.08),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text("$score / 100",
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 6),
                  const Text(
                    "Complete profile + request verification to increase trust score.",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Permissions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Permissions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _chip("Low Severity Reports", true),
                      _chip("Medium Severity Reports", true),
                      _chip("High Severity Reports", verified),
                      _chip("Community Chat", true),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    verified
                        ? "You can report High severity incidents."
                        : "High severity requires verified profile.",
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Editable form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Phone",
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _cnic,
                    decoration: const InputDecoration(
                      labelText: "CNIC (dummy)",
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: p.loading ? null : () => _save(p),
                    child: p.loading
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text("Save Profile"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, bool allowed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: allowed ? Colors.green.withOpacity(0.12) : Colors.red.withOpacity(0.12),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(allowed ? Icons.check_circle_outline : Icons.lock_outline,
              size: 18, color: allowed ? Colors.green : Colors.red),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
