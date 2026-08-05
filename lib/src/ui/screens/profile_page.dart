import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landingpage/src/ui/custom/custom_appbar.dart';
import 'package:landingpage/src/utils/colors.dart';
// import 'package:landingpage/src/ui/widgets/appbar.dart'; // adjust to actual path of CustomAppBar

class ProfilePage extends StatefulWidget {
  final bool isDarkMode;
  const ProfilePage({super.key, this.isDarkMode = true});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late bool _isDarkMode;
  bool _isEditing = false;

  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    final User? user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleTheme() => setState(() => _isDarkMode = !_isDarkMode);

  Future<void> _saveName() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final String newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    try {
      await user.updateDisplayName(newName);
      await user.reload();
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Profile updated")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Couldn't update profile: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final Color bg = _isDarkMode ? Colors.black : Colors.white;
    final Color cardColor = _isDarkMode
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.04);
    final Color borderColor = _isDarkMode
        ? Colors.white.withOpacity(0.15)
        : Colors.black.withOpacity(0.08);
    final Color textColor = _isDarkMode ? Colors.white : Colors.black87;
    final Color subTextColor = _isDarkMode ? Colors.white60 : Colors.black54;
    final Color accent = _isDarkMode
        ? AppColors.lavenderAccent
        : AppColors.deepPurple;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomAppBar(
                isDarkMode: _isDarkMode,
                onToggleTheme: _toggleTheme,
                activePage: "",
                showMenu: true,
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: borderColor, width: 1.4),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: accent.withOpacity(0.2),
                            backgroundImage: user?.photoURL != null
                                ? NetworkImage(user!.photoURL!)
                                : null,
                            child: user?.photoURL == null
                                ? Icon(
                                    Icons.person_rounded,
                                    size: 48,
                                    color: accent,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 20),

                          _isEditing
                              ? SizedBox(
                                  width: 260,
                                  child: TextField(
                                    controller: _nameController,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.spaceGrotesk(
                                      color: textColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Your name",
                                      hintStyle: TextStyle(color: subTextColor),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: borderColor,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: accent),
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  user?.displayName?.isNotEmpty == true
                                      ? user!.displayName!
                                      : "Unnamed User",
                                  style: GoogleFonts.spaceGrotesk(
                                    color: textColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                          const SizedBox(height: 6),
                          Text(
                            user?.email ?? "No email on file",
                            style: GoogleFonts.spaceGrotesk(
                              color: subTextColor,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 28),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isEditing) ...[
                                OutlinedButton(
                                  onPressed: () => setState(() {
                                    _isEditing = false;
                                    _nameController.text =
                                        user?.displayName ?? "";
                                  }),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: borderColor),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(color: subTextColor),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: _saveName,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryPurple,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text("Save"),
                                ),
                              ] else
                                ElevatedButton(
                                  onPressed: () =>
                                      setState(() => _isEditing = true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryPurple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text("Edit Profile"),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
