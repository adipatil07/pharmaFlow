import 'package:flutter/material.dart';
import 'package:pharma_supply/constants/app_theme.dart';
import 'package:pharma_supply/constants/constants.dart';
import 'package:pharma_supply/features/auth/models/user_model.dart';
import 'package:pharma_supply/services/firebase_service.dart';
import 'package:pharma_supply/widgets/snackbar_helper.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  UserType? selectedUserType = UserType.Manufacturer;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 60),
                  _buildLogo(),
                  SizedBox(height: 20),
                  _buildUserTypeSelector(),
                  SizedBox(height: 40),
                  _buildRegistrationForm(),
                  SizedBox(height: 30),
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            shape: BoxShape.circle,
          ),
          child:
              Icon(Icons.medical_services, size: 60, color: AppTheme.iconColor),
        ),
        SizedBox(height: 20),
        Text('PharmaFlow', style: AppTheme.headlineTextStyle),
      ],
    );
  }

  Widget _buildUserTypeSelector() {
    return Column(
      children: [
        Text(
          'Select User Role',
          style: AppTheme.subtitleTextStyle.copyWith(color: Colors.white),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: UserType.values.map((userType) {
                final isSelected = selectedUserType == userType;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ChoiceChip(
                    label: Text(_getUserTypeLabel(userType),
                        style: AppTheme.chipTextStyle),
                    selected: isSelected,
                    onSelected: (selected) =>
                        setState(() => selectedUserType = userType),
                    backgroundColor: Colors.transparent,
                    selectedColor: AppTheme.accentColor.withOpacity(0.3),
                    avatar: Icon(
                      _getUserTypeIcon(userType),
                      color:
                          isSelected ? Colors.transparent : AppTheme.iconColor,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.borderColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return Column(
      children: [
        _buildInputField(
            controller: nameController, hint: 'Full Name', icon: Icons.person),
        SizedBox(height: 20),
        _buildInputField(
            controller: emailController,
            hint: 'Email Address',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress),
        SizedBox(height: 20),
        _buildInputField(
            controller: phoneController,
            hint: 'Phone Number',
            icon: Icons.phone,
            keyboardType: TextInputType.phone),
        SizedBox(height: 20),
        _buildInputField(
            controller: passwordController,
            hint: 'Password',
            icon: Icons.lock,
            obscureText: true),
        SizedBox(height: 30),
        ElevatedButton(
          style: AppTheme.elevatedButtonStyle,
          onPressed: isLoading ? null : registerUser,
          child: isLoading
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text('CREATE ACCOUNT', style: AppTheme.buttonTextStyle),
        ),
      ],
    );
  }

  void registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    UserModel? user = await FirebaseService.registerUser(
      name: nameController.text,
      email: emailController.text,
      phone: phoneController.text,
      password: passwordController.text,
      userType: selectedUserType.toString().split('.').last,
    );

    if (user != null) {
      SnackBarHelper.showSnackBar(
        context,
        "User registered successfully!",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pop(context);
    } else {
      SnackBarHelper.showSnackBar(
        context,
        "User registration failed. Try again!",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

    setState(() => isLoading = false);
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: AppTheme.inputTextStyle,
      decoration: AppTheme.inputDecoration.copyWith(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.iconColor),
      ),
    );
  }

  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: RichText(
        text: TextSpan(
          text: 'Already have an account? ',
          style: AppTheme.bodyTextStyle.copyWith(color: Colors.white),
          children: [
            TextSpan(
              text: 'Login here',
              style: AppTheme.linkTextStyle,
            ),
          ],
        ),
      ),
    );
  }

  String _getUserTypeLabel(UserType userType) {
    switch (userType) {
      case UserType.Manufacturer:
        return 'Manufacturer';
      case UserType.Transporter:
        return 'Transporter';
      case UserType.Hospital:
        return 'Hospital';
      case UserType.MedicineStore:
        return 'Medical Store';
      case UserType.Patient:
        return 'Patient';
    }
  }

  IconData _getUserTypeIcon(UserType userType) {
    switch (userType) {
      case UserType.Manufacturer:
        return Icons.factory;
      case UserType.Transporter:
        return Icons.local_shipping;
      case UserType.Hospital:
        return Icons.local_hospital;
      case UserType.MedicineStore:
        return Icons.medical_services;
      case UserType.Patient:
        return Icons.person;
    }
  }
}
