class AuthValidators {
  AuthValidators._();

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? requiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  static String? email(String? value) {
    final required = requiredField(value, 'Email');
    if (required != null) return required;
    if (!_emailPattern.hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? loginPassword(String? value) =>
      requiredField(value, 'Password');

  static String? signupPassword(String? value) {
    final required = requiredField(value, 'Password');
    if (required != null) return required;
    if (value!.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final required = requiredField(value, 'Confirm password');
    if (required != null) return required;
    if (value != password) return 'Passwords do not match';
    return null;
  }
}
