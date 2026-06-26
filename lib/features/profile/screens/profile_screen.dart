import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:thrift_corner/core/utils/snackbar_helper.dart';
import 'package:thrift_corner/features/auth/screens/login_screen.dart';
import 'package:thrift_corner/features/home/screens/wishlist_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  bool isDarkMode = false;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  Future<void> loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      setState(() {
        userData = doc.data();
        isLoading = false;
      });
    }
  }

  String _formatDOB(dynamic dob) {
    if (dob == null) return 'Not Added';
    try {
      if (dob is Timestamp) {
        return DateFormat('dd MMM yyyy').format(dob.toDate());
      } else if (dob is String && dob.isNotEmpty) {
        return DateFormat('dd MMM yyyy').format(DateTime.parse(dob));
      }
    } catch (e) {
      return 'Not Added';
    }
    return 'Not Added';
  }

  void _showEditProfileDialog() {
    nameController.text = userData?['name'] ?? '';
    phoneController.text = userData?['phone'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "EDIT PROFILE",
                      style: TextStyle(
                        color: Color(0xFF282C3F),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        letterSpacing: 1.2,
                      ),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF7E818C),
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  "Full Name",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7E818C),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: nameController,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF282C3F),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F6),
                    hintText: "Enter your name",
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: Color(0xFF282C3F),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                const Text(
                  "Phone Number",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7E818C),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF282C3F),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F6),
                    hintText: "Enter phone number",
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: Color(0xFF282C3F),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFEAEAEE)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "CANCEL",
                          style: TextStyle(
                            color: Color(0xFF7E818C),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF282C3F),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: _updateProfile,
                        child: const Text(
                          "SAVE CHANGES",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
      });

      await FirebaseAuth.instance.currentUser!.updateDisplayName(
        nameController.text.trim(),
      );

      Navigator.pop(context);
      await loadUserData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile Updated Successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = userData?['email'] ?? user?.email ?? 'No Email';
    final displayName =
        userData?['name'] ?? user?.displayName ?? userEmail.split('@')[0];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFEAEAEE), height: 1.0),
        ),
        title: const Text(
          'MY ACCOUNT',
          style: TextStyle(
            color: Color(0xFF282C3F),
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Color(0xFFF5F5F6),
                    child: Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFF282C3F),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF282C3F),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userEmail,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "📱 ${userData?['phone'] ?? 'Not Added'}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "👤 ${userData?['gender'] ?? 'Not Added'}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "🎂 ${_formatDOB(userData?['dateOfBirth'])}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _showEditProfileDialog,
                    child: const Icon(
                      Icons.edit,
                      color: Color(0xFF282C3F),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            _buildSectionHeader('SHOPPING ACCOUNT'),
            _buildMenuCard([
              _buildMenuItem(
                icon: Icons.local_mall_outlined,
                title: 'My Orders',
                onTap: () {},
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.favorite_border_rounded,
                title: 'Wishlist & Collection',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const WishlistScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.place_outlined,
                title: 'Saved Addresses',
                onTap: () {},
              ),
            ]),

            _buildSectionHeader('PREFERENCES'),
            _buildMenuCard([
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.dark_mode_outlined,
                          color: Color(0xFF282C3F),
                          size: 20,
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF282C3F),
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: isDarkMode,
                      activeColor: Colors.black,
                      activeTrackColor: Colors.black12,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xFFEAEAEE),
                      onChanged: (value) {
                        setState(() {
                          isDarkMode = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ]),

            _buildSectionHeader('LEGAL & HELP'),
            _buildMenuCard([
              _buildMenuItem(
                icon: Icons.help_outline_rounded,
                title: 'Customer Support',
                onTap: () {},
              ),
              _buildDivider(),
              _buildMenuItem(
                icon: Icons.gavel_outlined,
                title: 'Terms & Conditions',
                onTap: () {},
              ),
            ]),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      await GoogleSignIn().signOut();
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        SnackbarHelper.showSuccess(
                          context,
                          'Logged out successfully',
                        );
                        await Future.delayed(const Duration(seconds: 1));
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    } on FirebaseAuthException catch (e) {
                      if (context.mounted) {
                        SnackbarHelper.showError(context, e.code);
                      }
                    }
                  },
                  child: const Text(
                    'LOG OUT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Color(0xFF7E818C),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFEAEAEE), width: 0.8),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF282C3F), size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF282C3F),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF7E818C),
              size: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Color(0xFFF0F0F2)),
    );
  }
}
