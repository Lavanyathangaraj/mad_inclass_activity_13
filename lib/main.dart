import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:confetti/confetti.dart';

void main() {
  runApp(const SignupAdventureApp());
}

class SignupAdventureApp extends StatelessWidget {
  const SignupAdventureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signup Adventure',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
      ),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --------------------------------------
// Welcome Screen
// --------------------------------------
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(seconds: 2),
                curve: Curves.bounceOut,
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_emotions,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 40),
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Join The Adventure!',
                    textStyle: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
              ),
              const SizedBox(height: 20),
              const Text(
                'Create your account and start your journey',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignupScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Start Adventure',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------
// Signup Screen
// --------------------------------------
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Password Strength
  double _passwordStrength = 0;

  // Adventure Progress Tracker
  double _progress = 0; // 0.0 to 1.0
  String _progressMessage = "Let's start your adventure!";

  // --- Avatar Selection ---
  final List<String> _avatars = ['🚀', '🐼', '🌸', '🎵', '🦄'];
  String? _selectedAvatar;

  // Confetti Controller
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
      _updateProgress();
    }
  }

  void _checkPasswordStrength(String password) {
    double strength = 0;
    if (password.isEmpty) {
      strength = 0;
    } else if (password.length < 6) {
      strength = 0.25;
    } else {
      strength = 0.25;
      if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
      if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
      if (RegExp(r'[!@#\$&*~]').hasMatch(password)) strength += 0.25;
    }
    setState(() {
      _passwordStrength = strength.clamp(0, 1);
    });
  }

  void _updateProgress() {
    double progress = 0;
    if (_nameController.text.isNotEmpty) progress += 0.2;
    if (_emailController.text.isNotEmpty) progress += 0.2;
    if (_dobController.text.isNotEmpty) progress += 0.2;
    if (_passwordController.text.isNotEmpty) progress += 0.2;
    if (_selectedAvatar != null) progress += 0.2;

    setState(() {
      _progress = progress;
      if (progress >= 0.99) {
        _progressMessage = "🎉 Adventure Ready!";
        _confettiController.play();
      } else if (progress >= 0.75) {
        _progressMessage = "Great! Almost there!";
      } else if (progress >= 0.5) {
        _progressMessage = "Halfway through! Keep going!";
      } else if (progress >= 0.25) {
        _progressMessage = "Good start! Adventure awaits!";
      } else {
        _progressMessage = "Let's start your adventure!";
      }
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedAvatar == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please choose an avatar to start your journey!')),
        );
        return;
      }

      // Check if all fields are actually complete (progress is 1.0)
      if (_progress < 0.99) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please fill out all fields and choose an avatar!')),
        );
        return;
      }


      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              userName: _nameController.text,
              avatar: _selectedAvatar!,
              passwordStrength: _passwordStrength,
              progress: _progress,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Account 🎉'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              // Tip Container
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.tips_and_updates,
                                        color: Colors.deepPurple[800]),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Complete your adventure profile!',
                                        style: TextStyle(
                                          color: Colors.deepPurple[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Adventure Progress Tracker
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LinearProgressIndicator(
                                    value: _progress,
                                    minHeight: 10,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _progress < 0.25
                                          ? Colors.red
                                          : _progress < 0.5
                                              ? Colors.orange
                                              : _progress < 0.75
                                                  ? Colors.yellow
                                                  : Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _progressMessage,
                                    style: const TextStyle(
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),

                              // Adventure Name
                              _buildTextField(
                                controller: _nameController,
                                label: 'Adventure Name',
                                icon: Icons.person,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'What should we call you on this adventure?';
                                  }
                                  return null;
                                },
                                onChanged: (_) => _updateProgress(),
                              ),
                              const SizedBox(height: 20),

                              // Email
                              _buildTextField(
                                controller: _emailController,
                                label: 'Email Address',
                                icon: Icons.email,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'We need your email for adventure updates!';
                                  }
                                  if (!value.contains('@') ||
                                      !value.contains('.')) {
                                    return 'Oops! That doesn\'t look like a valid email';
                                  }
                                  return null;
                                },
                                onChanged: (_) => _updateProgress(),
                              ),
                              const SizedBox(height: 20),

                              // DOB
                              TextFormField(
                                controller: _dobController,
                                readOnly: true,
                                onTap: _selectDate,
                                decoration: InputDecoration(
                                  labelText: 'Date of Birth',
                                  prefixIcon: const Icon(Icons.calendar_today,
                                      color: Colors.deepPurple),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.date_range),
                                    onPressed: _selectDate,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'When did your adventure begin?';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Password Field with Strength Meter
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                onChanged: (value) {
                                  _checkPasswordStrength(value);
                                  _updateProgress();
                                },
                                decoration: InputDecoration(
                                  labelText: 'Secret Password',
                                  prefixIcon: const Icon(Icons.lock,
                                      color: Colors.deepPurple),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.deepPurple,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Every adventurer needs a secret password!';
                                  }
                                  if (value.length < 6) {
                                    return 'Make it stronger! At least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: LinearProgressIndicator(
                                  value: _passwordStrength,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _passwordStrength <= 0.25
                                        ? Colors.red
                                        : _passwordStrength <= 0.5
                                            ? Colors.orange
                                            : _passwordStrength <= 0.75
                                                ? Colors.yellow
                                                : Colors.green,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Avatar Selection
                              const Text(
                                'Choose Your Adventure Avatar:',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 12,
                                children: _avatars.map((avatar) {
                                  final bool isSelected =
                                      _selectedAvatar == avatar;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedAvatar = avatar;
                                      });
                                      _updateProgress();
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.deepPurple[200]
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.deepPurple
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Text(
                                        avatar,
                                        style: const TextStyle(fontSize: 30),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                          _buildSubmitButton(constraints.maxWidth), 
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }

  // **FINAL FIX** Applied ValueKey to children to stop RenderFlex overflow during the AnimatedContainer's transition.
  Widget _buildSubmitButton(double maxWidth) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      // Use two finite, non-null widths for smooth animation between button and spinner.
      width: _isLoading ? 60 : maxWidth, 
      height: 60,
      child: _isLoading
          ? const Center(
              // **Key added here**
              key: ValueKey('loading'),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            )
          : ElevatedButton(
              // **Key added here**
              key: ValueKey('button'),
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Start My Adventure',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.rocket_launch, color: Colors.white),
                ],
              ),
            ),
    );
  }
}

// --------------------------------------
// Success Screen
// --------------------------------------
class SuccessScreen extends StatefulWidget {
  final String userName;
  final String avatar;
  final double passwordStrength;
  final double progress;
  const SuccessScreen({
    super.key,
    required this.userName,
    required this.avatar,
    required this.passwordStrength,
    required this.progress,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  late final ConfettiController _confettiController;
  List<String> badges = [];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 10));
    _confettiController.play();

    badges = _calculateBadges(widget.passwordStrength, widget.progress);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  List<String> _calculateBadges(double passwordStrength, double progress) {
    List<String> badges = [];

    // Strong Password Master
    if (passwordStrength >= 1.0) badges.add('🏆 Strong Password Master'); 

    // Profile Completer
    if (progress >= 1.0) badges.add('🎖 Profile Completer');

    // Early Bird Special
    if (DateTime.now().hour < 12) badges.add('🌅 Early Bird Special');

    return badges;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.deepPurple,
                Colors.purple,
                Colors.blue,
                Colors.green,
                Colors.orange,
              ],
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.avatar,
                    style: const TextStyle(fontSize: 100),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.userName,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 20),
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Welcome, Adventurer! 🎉',
                        textAlign: TextAlign.center,
                        textStyle: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    totalRepeatCount: 1,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Your adventure begins now!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),

                  // Badges
                  if (badges.isNotEmpty)
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          '🏅 Achievements Unlocked!',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 12,
                          children: badges
                              .map((b) => Chip(
                                    label: Text(b),
                                    backgroundColor: Colors.deepPurple[100],
                                  ))
                              .toList(),
                        ),
                      ],
                    ),

                  const SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () => _confettiController.play(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'More Celebration!',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}