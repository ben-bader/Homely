class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) return 'Please enter a valid email';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]')))
      return 'Password must contain at least one uppercase letter';
    if (!value.contains(RegExp(r'[a-z]')))
      return 'Password must contain at least one lowercase letter';
    if (!value.contains(RegExp(r'[0-9]')))
      return 'Password must contain at least one number';
    return null;
  }

  static String? validatePasswordMatch(String? value, String? password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    if (value.length < 2) return 'Name must be at least 2 characters';
    final nameRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s]+$');
    if (!nameRegex.hasMatch(value)) return 'Name can only contain letters';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final cleanedValue = value.replaceAll(RegExp(r'[\s-]'), '');
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(cleanedValue))
      return 'Please enter a valid phone number';
    return null;
  }

  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty)
      return '${fieldName ?? 'This field'} is required';
    return null;
  }

  static String? validateNumber(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty)
      return '${fieldName ?? 'This field'} is required';
    if (double.tryParse(value) == null) return 'Please enter a valid number';
    return null;
  }

  static String? validatePositiveNumber(String? value, {String? fieldName}) {
    final numberError = validateNumber(value, fieldName: fieldName);
    if (numberError != null) return numberError;
    final number = double.parse(value!);
    if (number <= 0) return '${fieldName ?? 'Value'} must be greater than 0';
    return null;
  }

  static String? validateMinLength(
    String? value,
    int minLength, {
    String? fieldName,
  }) {
    if (value == null || value.isEmpty)
      return '${fieldName ?? 'This field'} is required';
    if (value.length < minLength)
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    return null;
  }

  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String? fieldName,
  }) {
    if (value != null && value.length > maxLength)
      return '${fieldName ?? 'This field'} must not exceed $maxLength characters';
    return null;
  }

  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlRegex.hasMatch(value)) return 'Please enter a valid URL';
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) return 'Price is required';
    final price = double.tryParse(value.replaceAll(',', ''));
    if (price == null) return 'Please enter a valid price';
    if (price <= 0) return 'Price must be greater than 0';
    return null;
  }

  static String? validateDescription(String? value, {int minLength = 10}) {
    if (value == null || value.isEmpty) return 'Description is required';
    if (value.length < minLength)
      return 'Description must be at least $minLength characters';
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) return 'Address is required';
    if (value.length < 5) return 'Please enter a complete address';
    return null;
  }

  static String? Function(String?) customRegexValidator({
    required RegExp regex,
    required String errorMessage,
    bool required = true,
  }) {
    return (String? value) {
      if (value == null || value.isEmpty)
        return required ? 'This field is required' : null;
      if (!regex.hasMatch(value)) return errorMessage;
      return null;
    };
  }

  static String? Function(String?) combineValidators(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
