import 'package:flutter/material.dart';
import '../home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int _currentStep = 1;

  void _nextStep() {
    setState(() {
      if (_currentStep < 3) {
        _currentStep++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentStep < 3 ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ) : null,
        title: Text(
          _currentStep == 1 ? "ব্যক্তিগত তথ্য" : (_currentStep == 2 ? "যোগাযোগ ও নিরাপত্তা" : "সম্পন্ন"),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stepper (only for step 1 and 2)
            if (_currentStep < 3)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: Row(
                  children: [
                    _buildStepCircle(1, "ব্যক্তিগত তথ্য", _currentStep >= 1),
                    _buildStepLine(_currentStep >= 2),
                    _buildStepCircle(2, "যোগাযোগ ও নিরাপত্তা", _currentStep >= 2),
                    _buildStepLine(_currentStep >= 3),
                    _buildStepCircle(3, "সম্পন্ন", _currentStep >= 3),
                  ],
                ),
              ),
            
            const SizedBox(height: 20),
            
            if (_currentStep == 1) _buildStep1(),
            if (_currentStep == 2) _buildStep2(),
            if (_currentStep == 3) _buildStep3(),
            
            const SizedBox(height: 20),
            // Privacy Notice Box (only for step 1 and 2)
            if (_currentStep < 3)
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                            Text(
                              "আমরা আপনার তথ্য কখনোই শেয়ার করি না",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
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

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                Icon(Icons.person_pin_circle_outlined, size: 80, color: Colors.green.shade700),
                const SizedBox(height: 10),
                const Text(
                  "ব্যক্তিগত তথ্য",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "আপনার সঠিক তথ্য দিন",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildTextField("নাম (বাংলায়) *", "আপনার পূর্ণ নাম লিখুন", Icons.person_outline),
          const SizedBox(height: 15),
          _buildTextField("নাম (ইংরেজিতে)", "আপনার নাম লিখুন (ঐচ্ছিক)", Icons.person_outline),
          const SizedBox(height: 15),
          _buildTextField("জাতীয় পরিচয়পত্র নম্বর (NID) *", "আপনার NID নম্বর লিখুন", Icons.badge_outlined),
          const SizedBox(height: 15),
          _buildDatePickerField("জন্ম তারিখ *", "দিন/মাস/বছর নির্বাচন করুন"),
          const SizedBox(height: 15),
          _buildDropdownField("লিঙ্গ *", "লিঙ্গ নির্বাচন করুন", Icons.group_outlined),
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
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("ইতোমধ্যে অ্যাকাউন্ট আছে? ", style: TextStyle(color: Colors.grey)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  "লগইন করুন",
                  style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                Icon(Icons.security_outlined, size: 80, color: Colors.green.shade700),
                const SizedBox(height: 10),
                const Text(
                  "যোগাযোগ তথ্য",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "আপনার সাথে যোগাযোগের জন্য তথ্য দিন",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildTextField("মোবাইল নম্বর *", "01XXXXXXXXX", Icons.phone_outlined),
          const SizedBox(height: 15),
          _buildTextField("ইমেইল (ঐচ্ছিক)", "example@gmail.com", Icons.email_outlined),
          const SizedBox(height: 15),
          _buildTextField("ঠিকানা *", "বিস্তারিত ঠিকানা লিখুন", Icons.location_on_outlined),
          const SizedBox(height: 15),
          _buildDropdownField("বিভাগ *", "বিভাগ নির্বাচন করুন", Icons.map_outlined),
          
          const SizedBox(height: 25),
          const Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text("নিরাপত্তা সেটআপ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("আপনার অ্যাকাউন্ট সুরক্ষিত রাখতে পাসওয়ার্ড দিন", style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildPasswordField("পাসওয়ার্ড *", "পাসওয়ার্ড লিখুন"),
          const SizedBox(height: 15),
          _buildPasswordField("পাসওয়ার্ড নিশ্চিত করুন *", "পাসওয়ার্ড পুনরায় লিখুন"),
          
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

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 60, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 20),
          const Text(
            "রেজিস্টার সম্পন্ন!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
          ),
          const SizedBox(height: 8),
          const Text(
            "আপনার অ্যাকাউন্ট সফলভাবে তৈরি হয়েছে।",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 30),
          
          // Account Info Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("অ্যাকাউন্ট তথ্য", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 20),
                _buildInfoRow(Icons.person, "নাম", "রাকিব ইসলাম"),
                const SizedBox(height: 15),
                _buildInfoRow(Icons.phone, "মোবাইল নম্বর", "01XXXXXXXXX"),
                const SizedBox(height: 15),
                _buildInfoRow(Icons.email, "ইমেইল", "example@gmail.com"),
                const SizedBox(height: 15),
                _buildInfoRow(Icons.location_on, "ঠিকানা", "ধানমন্ডি, ঢাকা, বাংলাদেশ"),
              ],
            ),
          ),
          
          const SizedBox(height: 25),
          
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.email_outlined, color: Color(0xFF2E7D32), size: 30),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("ইমেইল যাচাই করুন", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1B5E20))),
                      SizedBox(height: 4),
                      Text(
                        "আমরা আপনার ইমেইলে একটি ভেরিফিকেশন লিঙ্ক পাঠিয়েছি। অনুগ্রহ করে আপনার ইমেইল যাচাই করুন।",
                        style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Login Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("লগইন করুন", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 15),
          
          // Home Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_outlined, color: Color(0xFF1B5E20), size: 22),
                  SizedBox(width: 10),
                  Text("হোমে যান", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 25),
          const Text("সমস্যা হচ্ছে? সহায়তা নিন", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          ],
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
          child: Text(
            step.toString(),
            style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 8, color: isActive ? Colors.black : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 1,
        color: isActive ? const Color(0xFF1B5E20) : Colors.grey.shade300,
        margin: const EdgeInsets.only(bottom: 15),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll(" *", ""),
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
            children: [
              if (label.contains("*"))
                const TextSpan(text: " *", style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll(" *", ""),
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
            children: [
              if (label.contains("*"))
                const TextSpan(text: " *", style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
            suffixIcon: const Icon(Icons.visibility_off_outlined, color: Colors.grey, size: 18),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll(" *", ""),
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
            children: [
              if (label.contains("*"))
                const TextSpan(text: " *", style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: const Icon(Icons.calendar_today_outlined, color: Colors.green, size: 20),
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey, size: 18),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll(" *", ""),
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
            children: [
              if (label.contains("*"))
                const TextSpan(text: " *", style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.green, size: 20),
            suffixIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
      ],
    );
  }
}
