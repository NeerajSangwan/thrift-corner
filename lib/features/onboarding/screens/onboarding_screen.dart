import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thrift_corner/features/home/screens/main_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thrift_corner/features/auth/bloc/auth_bloc.dart';
import 'package:thrift_corner/features/auth/bloc/auth_event.dart';
import 'package:thrift_corner/features/auth/bloc/auth_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentStep = 0;
  final int _totalSteps = 3;

  String? _selectedGender;
  DateTime? _selectedDateOfBirth;
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.read<AuthBloc>().add(
        CompleteOnboardingRequested(
          phone: _phoneController.text.trim(),
          gender: _selectedGender ?? '',
          dateOfBirth: _selectedDateOfBirth ?? DateTime.now(),
        ),
      );
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _showRollerDatePicker(BuildContext context) {
    DateTime initialDateTime = _selectedDateOfBirth ?? DateTime(2000, 1, 1);
    DateTime tempPickedDate = initialDateTime;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: 320,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                    const Text(
                      'Select Birthday',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedDateOfBirth = tempPickedDate;
                        });
                        Navigator.pop(context);
                        _nextPage();
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    brightness: Brightness.light,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initialDateTime,
                    maximumDate: DateTime.now(),
                    minimumYear: 1920,
                    maximumYear: DateTime.now().year,
                    onDateTimeChanged: (DateTime newDate) {
                      tempPickedDate = newDate;
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OnboardingCompleted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 40,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _currentStep > 0
                            ? IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.black,
                                  size: 20,
                                ),
                                onPressed: _previousPage,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/logo/logo.png',
                                  width: 32,
                                  height: 32,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.blur_on,
                                        color: Colors.black,
                                      ),
                                ),
                              ),
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Stack(
                          children: [
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 4,
                              width:
                                  MediaQuery.of(context).size.width *
                                  (0.45 * (_currentStep + 1) / _totalSteps),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    GestureDetector(
                      onTap: _nextPage,
                      child: SizedBox(
                        width: 40,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (int page) {
                    setState(() {
                      _currentStep = page;
                    });
                  },
                  children: [
                    _buildGenderStep(),
                    _buildBirthdayStep(),
                    _buildPhoneStep(),
                  ],
                ),
              ),

              if (_currentStep == _totalSteps - 1)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return GestureDetector(
                        onTap: state is AuthLoading
                            ? null
                            : () {
                                context.read<AuthBloc>().add(
                                  CompleteOnboardingRequested(
                                    phone: _phoneController.text.trim(),
                                    gender: _selectedGender ?? '',
                                    dateOfBirth:
                                        _selectedDateOfBirth ?? DateTime.now(),
                                  ),
                                );
                              },
                        child: Container(
                          width: double.infinity,
                          height: 58,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: state is AuthLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Finish Setup',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderStep() {
    final List<Map<String, dynamic>> genders = [
      {'label': 'Male', 'icon': Icons.male_rounded},
      {'label': 'Female', 'icon': Icons.female_rounded},
      {'label': 'Non-binary / Other', 'icon': Icons.blur_on_rounded},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'How do you\nidentify?',
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Helps us tailor your feed and curated thrift finds.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
          const SizedBox(height: 36),
          ...genders.map((gender) {
            final isSelected = _selectedGender == gender['label'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGender = gender['label'];
                  });
                  Future.delayed(const Duration(milliseconds: 250), () {
                    if (mounted) _nextPage();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        gender['icon'],
                        color: isSelected ? Colors.white : Colors.black54,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        gender['label'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBirthdayStep() {
    String formattedDate = _selectedDateOfBirth != null
        ? DateFormat('MMMM dd, yyyy').format(_selectedDateOfBirth!)
        : 'Select your birthday';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'When is your\nbirthday?',
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'We love celebrating you! (Must be at least 13 years old)',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: () => _showRollerDatePicker(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: _selectedDateOfBirth != null
                        ? Colors.black
                        : Colors.black38,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: _selectedDateOfBirth != null
                          ? Colors.black
                          : Colors.black38,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.unfold_more_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Add your mobile\nnumber',
            style: TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Used for instant buyer updates and delivery tracking details.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
          const SizedBox(height: 40),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              context.read<AuthBloc>().add(
                CompleteOnboardingRequested(
                  phone: _phoneController.text.trim(),
                  gender: _selectedGender ?? '',
                  dateOfBirth: _selectedDateOfBirth ?? DateTime.now(),
                ),
              );
            },
            style: const TextStyle(color: Colors.black, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Phone Number',
              hintStyle: const TextStyle(color: Colors.black38),
              prefixIcon: const Icon(
                Icons.phone_outlined,
                color: Colors.black38,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
