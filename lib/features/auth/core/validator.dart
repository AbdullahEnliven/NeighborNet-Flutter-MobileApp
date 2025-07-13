class PhoneValidator {

  static bool isValid(String number) {
    final regex = RegExp(r'^3[0-9]{9}$');
    return regex.hasMatch(number);
  }

  static String? validate(String number) {
    if (number.isEmpty) {
      return 'Phone number is required';
    }
    if (!isValid(number)) {
      return 'Enter a valid Pakistani phone number (e.g., 3001234567)';
    }
    return null;
  }
}
