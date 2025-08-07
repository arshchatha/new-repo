// password validator.
bool isValidPassword(String password) {
  if (password.isEmpty) {
    return false;
  }

  // Regular expression for password validation.
  // At least 8 characters, one uppercase, one lowercase, one digit, and one special character.
  RegExp passwordRegex = RegExp(
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');

  return passwordRegex.hasMatch(password);
  
}
