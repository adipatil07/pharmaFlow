import 'package:flutter/material.dart';
import 'package:pharma_supply/constants/app_theme.dart';
import 'package:pharma_supply/constants/constants.dart';
import 'package:pharma_supply/features/auth/models/user_model.dart';
import 'package:pharma_supply/features/auth/register_page.dart';
import 'package:pharma_supply/features/hospital/hospital_home_page.dart';
import 'package:pharma_supply/features/manufacturer/manufacturer_home_page.dart';
import 'package:pharma_supply/features/patient/patient_home_page.dart';
import 'package:pharma_supply/features/pharma_store/pharma_store_home_page.dart';
import 'package:pharma_supply/features/transporter/transporter_home_page.dart';
import 'package:pharma_supply/services/firebase_service.dart';
import 'package:pharma_supply/widgets/snackbar_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  UserType? selectedUserType = UserType.Manufacturer;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 60),
                _buildLogo(),
                SizedBox(height: 20),
                _buildUserTypeSelector(),
                SizedBox(height: 40),
                _buildLoginForm(),
                SizedBox(height: 30),
                _buildRegisterLink(),
              ],
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
        Text(
          'PharmaFlow',
          style: AppTheme.headlineTextStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                    onSelected: (selected) {
                      setState(() {
                        selectedUserType = userType;
                      });
                    },
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

  Widget _buildLoginForm() {
    return Column(
      children: [
        TextField(
          controller: emailController,
          style: AppTheme.inputTextStyle,
          decoration: AppTheme.inputDecoration.copyWith(
            hintText: 'Email',
            prefixIcon: Icon(Icons.email, color: AppTheme.iconColor),
          ),
        ),
        SizedBox(height: 20),
        TextField(
          controller: passwordController,
          obscureText: true,
          style: AppTheme.inputTextStyle,
          decoration: AppTheme.inputDecoration.copyWith(
            hintText: 'Password',
            prefixIcon: Icon(Icons.lock, color: AppTheme.iconColor),
          ),
        ),
        SizedBox(height: 30),
        ElevatedButton(
          style: AppTheme.elevatedButtonStyle,
          onPressed: _isLoading ? null : _handleLogin,
          child: _isLoading
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text('SIGN IN', style: AppTheme.buttonTextStyle),
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterPage(),
          ),
        );
      },
      child: RichText(
        text: TextSpan(
          text: 'New user ? ',
          style: AppTheme.bodyTextStyle.copyWith(color: Colors.white),
          children: [
            TextSpan(
              text: 'Create account',
              style: AppTheme.linkTextStyle,
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      SnackBarHelper.showSnackBar(
        context,
        "Please enter email and password.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    UserModel? user = await FirebaseService.loginUser(
      email: emailController.text,
      password: passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      SnackBarHelper.showSnackBar(
        context,
        "Welcome, ${user.name}!",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      if (user.type == "Manufacturer") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ManufacturerHomePage()),
        );
      } else if (user.type == "Transporter") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TransporterHomePage()),
        );
      } else if (user.type == "Patient") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PatientHomePage()),
        );
      } else if (user.type == "MedicineStore") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Pharmastorehomepage()),
        );
      } else if (user.type == "Hospital") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HospitalHomePage()),
        );
      } else {
        SnackBarHelper.showSnackBar(
          context,
          "User type not yet supported.",
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
      }
    } else {
      SnackBarHelper.showSnackBar(
        context,
        "Invalid email or password.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
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
