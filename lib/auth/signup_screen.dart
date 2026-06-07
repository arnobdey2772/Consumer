import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import '../home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final supabase = Supabase.instance.client;
  int _currentStep = 1;
  bool _isLoading = false;
  bool _otpSent = false;
  String _tempPhoneNumber = "";

  // Controllers for Step 1 (Phone/OTP)
  final TextEditingController _phoneController = TextEditingController();

  // Controllers for Step 2 (Personal Info)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nidController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;

  // Controllers for Step 3 (Contact & Security)
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedDivision;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _nidController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 1. Send OTP
  Future<void> _sendOtp() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("দয়া করে মোবাইল নম্বর দিন")),
      );
      return;
    }

    setState(() => _isLoading = true);

    String phoneNumber = _phoneController.text.trim();
    
    // নম্বর ফরম্যাটিং লজিক (ডেমো কোডের মতো ফ্লেক্সিবল করা হলো)
    if (!phoneNumber.startsWith('+')) {
      if (phoneNumber.startsWith('01') && phoneNumber.length == 11) {
        // শুধুমাত্র বাংলাদেশের মোবাইল নম্বরের ক্ষেত্রে +৮৮ যোগ হবে
        phoneNumber = '+88$phoneNumber';
      } else {
        // অন্যান্য নম্বরের ক্ষেত্রে (যেমন আপনার ইউএস নম্বর) শুধু + যোগ হবে
        phoneNumber = '+$phoneNumber';
      }
    }
    _tempPhoneNumber = phoneNumber;

    try {
      await supabase.auth.signInWithOtp(phone: phoneNumber);
      setState(() {
        _otpSent = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ওটিপি পাঠানো হয়েছে")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ওটিপি পাঠাতে ব্যর্থ হয়েছে: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. Verify OTP
  Future<void> _verifyOtp(String otpCode) async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase.auth.verifyOTP(
        phone: _tempPhoneNumber,
        token: otpCode,
        type: OtpType.sms,
      );

      if (response.session != null) {
        setState(() {
          _currentStep = 2;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ভুল ওটিপি, আবার চেষ্টা করুন")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _nextStep() {
    if (_currentStep == 2) {
      if (_nameController.text.isEmpty || _nidController.text.isEmpty || _selectedDate == null || _selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("দয়া করে সব বাধ্যতামূলক তথ্য দিন")),
        );
        return;
      }
    }
    setState(() {
      if (_currentStep < 4) {
        _currentStep++;
      }
    });
  }

  // Final Registration Step
  Future<void> _handleSignup() async {
    if (_addressController.text.isEmpty || _selectedDivision == null || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("দয়া করে সব বাধ্যতামূলক তথ্য দিন")),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("পাসওয়ার্ড দুটি মিলছে না")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Update user password (as they are already authenticated via OTP)
      await supabase.auth.updateUser(
        UserAttributes(password: _passwordController.text),
      );

      final String userId = supabase.auth.currentUser!.id;

      // 2. Database Upsert using SQL schema
      await supabase.from('profiles').upsert({
        'id': userId,
        'full_name': _nameController.text,
        'nid_number': _nidController.text,
        'date_of_birth': _selectedDate?.toIso8601String().split('T')[0], // YYYY-MM-DD format
        'gender': _selectedGender,
        'phone_number': _tempPhoneNumber,
        'email': _emailController.text.isEmpty ? null : _emailController.text,
        'address': _addressController.text,
        'division': _selectedDivision,
      });

      setState(() {
        _currentStep = 4;
      });
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("রেজিস্ট্রেশন ব্যর্থ হয়েছে: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentStep < 4
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  if (_currentStep > 1) {
                    setState(() => _currentStep--);
                  } else {
                    Navigator.pop(context);
                  }
                },
              )
            : null,
        title: Text(
          _currentStep == 1 ? "ভেরিফিকেশন" : (_currentStep == 2 ? "ব্যক্তিগত তথ্য" : (_currentStep == 3 ? "যোগাযোগ ও নিরাপত্তা" : "সম্পন্ন")),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_currentStep < 4)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: Row(
                  children: [
                    _buildStepCircle(1, "ওটিপি", _currentStep >= 1),
                    _buildStepLine(_currentStep >= 2),
                    _buildStepCircle(2, "ব্যক্তিগত", _currentStep >= 2),
                    _buildStepLine(_currentStep >= 3),
                    _buildStepCircle(3, "নিরাপত্তা", _currentStep >= 3),
                    _buildStepLine(_currentStep >= 4),
                    _buildStepCircle(4, "সম্পন্ন", _currentStep >= 4),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            if (_currentStep == 1) _buildStepOtp(),
            if (_currentStep == 2) _buildStepPersonalInfo(),
            if (_currentStep == 3) _buildStepSecurity(),
            if (_currentStep == 4) _buildStepSuccess(),
            const SizedBox(height: 20),
            if (_currentStep < 4)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F8F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "আপনার তথ্য নিরাপদ ও গোপনীয় থাকবে",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B5E20)),
                            ),
                            Text(
                              "আমরা আপনার তথ্য কখনোই শেয়ার করি না",
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // STEP 1: Phone and OTP Verification
  Widget _buildStepOtp() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (!_otpSent) ...[
            Center(
              child: Column(
                children: [
                  Icon(Icons.phone_android_outlined, size: 80, color: Colors.green.shade700),
                  const SizedBox(height: 10),
                  const Text("মোবাইল নম্বর যাচাই", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text("আপনার সচল মোবাইল নম্বরটি দিন", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField("মোবাইল নম্বর *", "01XXXXXXXXX", Icons.phone_outlined, controller: _phoneController, keyboardType: TextInputType.phone),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("ওটিপি পাঠান", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ] else ...[
            Center(
              child: Column(
                children: [
                  Icon(Icons.vibration_outlined, size: 80, color: Colors.green.shade700),
                  const SizedBox(height: 10),
                  const Text("ওটিপি কোড দিন", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("$_tempPhoneNumber নম্বরে একটি ওটিপি পাঠানো হয়েছে", 
                     textAlign: TextAlign.center,
                     style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            OtpTextField(
              numberOfFields: 6,
              borderColor: const Color(0xFF1B5E20),
              focusedBorderColor: const Color(0xFF1B5E20),
              showFieldAsBox: true,
              onSubmit: (String verificationCode) {
                _verifyOtp(verificationCode);
              },
            ),
            const SizedBox(height: 30),
            if (_isLoading)
              const CircularProgressIndicator(color: Colors.green)
            else
              TextButton(
                onPressed: _sendOtp,
                child: const Text("ওটিপি পাননি? পুনরায় পাঠান", 
                  style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => setState(() => _otpSent = false),
              child: const Text("নম্বর ভুল? পরিবর্তন করুন", style: TextStyle(color: Colors.grey)),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("ইতোমধ্যে অ্যাকাউন্ট আছে? ", style: TextStyle(color: Colors.grey)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text("লগইন করুন", style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // STEP 2: Personal Info (Name, NID, DOB, Gender)
  Widget _buildStepPersonalInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                Icon(Icons.person_pin_circle_outlined, size: 80, color: Colors.green.shade700),
                const SizedBox(height: 10),
                const Text("ব্যক্তিগত তথ্য", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Text("আপনার সঠিক তথ্য দিন", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildTextField("আপনার নাম *", "আপনার পূর্ণ নাম লিখুন", Icons.person_outline, controller: _nameController),
          const SizedBox(height: 15),
          _buildTextField("জাতীয় পরিচয়পত্র নম্বর (NID) *", "আপনার NID নম্বর লিখুন", Icons.badge_outlined, controller: _nidController, keyboardType: TextInputType.number),
          const SizedBox(height: 15),
          _buildDatePickerField("জন্ম তারিখ *", "দিন/মাস/বছর নির্বাচন করুন", controller: _dobController),
          const SizedBox(height: 15),
          _buildDropdownField("লিঙ্গ *", "লিঙ্গ নির্বাচন করুন", Icons.group_outlined, items: ["পুরুষ", "মহিলা", "অন্যান্য"], value: _selectedGender, onChanged: (val) => setState(() => _selectedGender = val)),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("পরবর্তী ধাপ", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 3: Security & Contact (Email, Address, Division, Password)
  Widget _buildStepSecurity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                Icon(Icons.security_outlined, size: 80, color: Colors.green.shade700),
                const SizedBox(height: 10),
                const Text("যোগাযোগ ও নিরাপত্তা", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Text("আপনার সাথে যোগাযোগের জন্য তথ্য দিন", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildTextField("ইমেইল (ঐচ্ছিক)", "example@gmail.com", Icons.email_outlined, controller: _emailController, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 15),
          _buildTextField("ঠিকানা *", "বিস্তারিত ঠিকানা লিখুন", Icons.location_on_outlined, controller: _addressController),
          const SizedBox(height: 15),
          _buildDropdownField("বিভাগ *", "বিভাগ নির্বাচন করুন", Icons.map_outlined, items: ["ঢাকা", "চট্টগ্রাম", "রাজশাহী", "খুলনা", "বরিশাল", "সিলেট", "রংপুর", "ময়মনসিংহ"], value: _selectedDivision, onChanged: (val) => setState(() => _selectedDivision = val)),
          const SizedBox(height: 25),
          const Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text("পাসওয়ার্ড সেটআপ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("আপনার অ্যাকাউন্ট সুরক্ষিত রাখতে পাসওয়ার্ড দিন", style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildPasswordField("পাসওয়ার্ড *", "পাসওয়ার্ড লিখুন", controller: _passwordController, isVisible: _isPasswordVisible, toggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible)),
          const SizedBox(height: 15),
          _buildPasswordField("পাসওয়ার্ড নিশ্চিত করুন *", "পাসওয়ার্ড পুনরায় লিখুন", controller: _confirmPasswordController, isVisible: _isConfirmPasswordVisible, toggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible)),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSignup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("রেজিস্টার সম্পন্ন করুন", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(width: 10),
                        Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 4: Success
  Widget _buildStepSuccess() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
            child: const Icon(Icons.check, size: 60, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 20),
          const Text("রেজিস্টার সম্পন্ন!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
          const SizedBox(height: 8),
          const Text("আপনার অ্যাকাউন্ট সফলভাবে তৈরি হয়েছে।", style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("অ্যাকাউন্ট তথ্য", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 20),
                _buildInfoRow(Icons.person, "নাম", _nameController.text),
                const SizedBox(height: 15),
                _buildInfoRow(Icons.phone, "মোবাইল নম্বর", _tempPhoneNumber),
                const SizedBox(height: 15),
                _buildInfoRow(Icons.email, "ইমেইল", _emailController.text.isEmpty ? "দেওয়া হয়নি" : _emailController.text),
                const SizedBox(height: 15),
                _buildInfoRow(Icons.location_on, "ঠিকানা", _addressController.text),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text("লগইন করুন", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false),
              style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text("হোমে যান", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepCircle(int step, String label, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isActive ? const Color(0xFF1B5E20) : Colors.grey.shade200,
          child: Text(step.toString(), style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 8, color: isActive ? Colors.black : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(height: 1, color: isActive ? const Color(0xFF1B5E20) : Colors.grey.shade300, margin: const EdgeInsets.only(bottom: 15)),
    );
  }

  Widget _buildTextField(String label, String hint, IconData icon, {TextEditingController? controller, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, String hint, {TextEditingController? controller, required bool isVisible, required VoidCallback toggleVisibility}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
            suffixIcon: IconButton(icon: Icon(isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18), onPressed: toggleVisibility),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField(String label, String hint, {TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: true,
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context, 
              initialDate: DateTime(2000), 
              firstDate: DateTime(1900), 
              lastDate: DateTime.now()
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
                controller?.text = "${picked.day}/${picked.month}/${picked.year}";
              });
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.calendar_today_outlined, color: Colors.green, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint, IconData icon, {required List<String> items, String? value, required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.green, size: 20),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
      ],
    );
  }
}
