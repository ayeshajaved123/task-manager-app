class Validators {
  static String? email(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Email is required';
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
    if (!ok) return 'Invalid email';
    return null;
  }

  static String? password(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Min 6 characters';
    return null;
  }

  static String? requiredText(String? v, String label) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return '$label is required';
    return null;
  }
}
