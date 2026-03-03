import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bluetoothairmousekeyboard/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _issueController = TextEditingController();
  bool _isLoading = false;

  // --- THEME COLORS (replaced with AppThemeColors) ---
  static const Color darkBackground = AppThemeColors.bgMid;
  static const Color cardSurface = AppThemeColors.card;
  static const Color primaryCyan = AppThemeColors.accentCyan;
  static const Color textMain = Color(0xFFE6E7EC);
  static const Color textMuted = AppThemeColors.textSecondary;

  @override
  void dispose() {
    _emailController.dispose();
    _issueController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String email = _emailController.text;
      final String issue = _issueController.text;
      final String plateform = Platform.isAndroid ? 'Android' : "IOS";
      final String appName = 'Fire Tv Remote || $plateform';

      const String apiUrl = 'https://codstars.com/admin/api/feedback.php';

      try {
        final response = await http
            .post(
              Uri.parse(apiUrl),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'email': email,
                'details': issue,
                'appname': appName,
              }),
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 201 || response.statusCode == 200) {
          _showSnackBar(
              'Form submitted successfully!', Colors.green, Colors.white);
          _emailController.clear();
          _issueController.clear();
        } else {
          _showSnackBar(
            'Failed to submit form. Status: ${response.statusCode}',
            Colors.red,
            Colors.white,
          );
          debugPrint('API Error: ${response.body}');
          setState(() {
            _isLoading = false;
          });
        }
      } on TimeoutException catch (_) {
        _showSnackBar(
            'Request timed out. Please try again.', Colors.red, Colors.white);
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        _showSnackBar('An error occurred: $e', Colors.red, Colors.white);
        debugPrint('Error: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color backgroundColor, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: color)),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: const Text(
          "Report an Issue",
          style: TextStyle(
              color: textMain,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: darkBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: textMain),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 20),

              // EMAIL
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: textMain, fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon:
                      const Icon(Icons.email, color: primaryCyan),
                  labelStyle: const TextStyle(color: textMuted),
                  hintStyle:
                      TextStyle(color: textMuted.withOpacity(0.55)),
                  filled: true,
                  fillColor: cardSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: primaryCyan, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Colors.red, width: 1.2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.fromLTRB(16, 16, 16, 16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter your email';
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                      .hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ISSUE
              TextFormField(
                controller: _issueController,
                maxLines: 5,
                style: const TextStyle(color: textMain, fontSize: 15),
                decoration: InputDecoration(
                  labelText: 'Issue Description',
                  hintText: 'Describe your issue here...',
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 80.0),
                    child: Icon(Icons.description,
                        color: primaryCyan),
                  ),
                  labelStyle: const TextStyle(color: textMuted),
                  hintStyle:
                      TextStyle(color: textMuted.withOpacity(0.55)),
                  filled: true,
                  fillColor: cardSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: primaryCyan, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Colors.red, width: 1.2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.fromLTRB(16, 16, 16, 16),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please describe your issue';
                  if (value.length < 10)
                    return 'Issue description must be at least 10 characters long';
                  return null;
                },
              ),

              const SizedBox(height: 30),

              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: primaryCyan))
                  : RemoteScreenWidgets().customOrangeButton(
                      tittle: 'Submit Issue',
                      iconButtonTap: _submitForm,
                      buttonColor: primaryCyan,
                      textColor: Colors.white,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class RemoteScreenWidgets {
  Widget customOrangeButton({
    required String tittle,
    required VoidCallback iconButtonTap,
    Color? buttonColor,
    Color? textColor,
  }) {
    return ElevatedButton(
      onPressed: iconButtonTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: textColor,
        surfaceTintColor: Colors.transparent,
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: Text(
        tittle,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}