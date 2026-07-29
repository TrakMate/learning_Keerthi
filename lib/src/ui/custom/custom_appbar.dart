import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:landingpage/main.dart';
import 'package:landingpage/src/forms/login_page.dart';
import 'package:landingpage/src/ui/screens/album_page.dart';
import 'package:landingpage/src/ui/screens/discover.dart';
import 'package:landingpage/src/ui/screens/homepage.dart';
import 'package:landingpage/src/ui/screens/library.dart';
// import 'package:landingpage/src/ui/screens/library_page.dart';
import 'package:landingpage/src/utils/colors.dart';

class CustomAppBar extends StatelessWidget {
  final bool isDarkMode;
  final bool showLoginButton;
  final bool showMenu; // controls whether the nav menu items render
  final String activePage; // e.g. "Home", "Discover", "Library", etc.
  final VoidCallback onToggleTheme;

  const CustomAppBar({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    this.showLoginButton = true,
    this.showMenu = true,
    this.activePage = "",
  });

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

    return Column(
      children: [
        const SizedBox(height: 30),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.12) // Dark mode
                      : Colors.black.withValues(alpha: 0.06), // Light mode
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                    color: isDarkMode
                        ? Colors.black.withValues(alpha: 0.50) // Dark mode
                        : Colors.white.withValues(alpha: 0.50), // Light mode
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.35) // Dark mode
                          : Colors.black.withValues(alpha: 0.35), // Light mode
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/glogo.png', // Your logo path
                          width: 45,
                          height: 45,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(width: 0),

                        Text(
                          "Lizzen",
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors
                                      .black // Dark mode
                                : Colors.white, // Light mode
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    if (showMenu) ...[
                      Row(
                        children: [
                          _menuItem(
                            context,
                            "Home",
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HomePage(isDarkMode: true),
                                ),
                              );
                            },
                            isDarkMode,
                            isActive: activePage == "Home",
                          ),

                          const SizedBox(width: 25),

                          _menuItem(
                            context,
                            "Discover",
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DiscoverPage(),
                                ),
                              );
                            },
                            isDarkMode,
                            isActive: activePage == "Discover",
                          ),

                          const SizedBox(width: 25),

                          _menuItem(
                            context,
                            "Library",
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LibraryPage(isDarkMode: true),
                                ),
                              );
                            },
                            isDarkMode,
                            isActive: activePage == "Library",
                          ),

                          const SizedBox(width: 25),

                          _menuItem(
                            context,
                            "Albums",
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AlbumsPage(),
                                ),
                              );
                            },
                            isDarkMode,
                            isActive: activePage == "Albums",
                          ),

                          const SizedBox(width: 25),

                          _menuItem(
                            context,
                            "Artists",
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const Placeholder(),
                                ),
                              );
                            },
                            isDarkMode,
                            isActive: activePage == "Artists",
                          ),

                          const SizedBox(width: 25),

                          _menuItem(
                            context,
                            "Playlist",
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const Placeholder(),
                                ),
                              );
                            },
                            isDarkMode,
                            isActive: activePage == "Playlist",
                          ),
                        ],
                      ),
                      const SizedBox(width: 25),
                    ],
                    // --- end menu items ---

                    // --- Login / Logout — driven by real auth state ---
                    if (isLoggedIn)
                      _logoutButton(context, isDarkMode)
                    else if (showLoginButton)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                    // --- theme toggle — always visible, on every page ---
                    const SizedBox(width: 14),
                    _themeToggleButton(),
                  ],
                ),
              ),
            ),
          ),
        ),

        Container(
          margin: const EdgeInsets.only(top: 5),
          width: 70,
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.purpleAccent,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ],
    );
  }

  Widget _logoutButton(BuildContext context, bool isDarkMode) {
    return TextButton.icon(
      onPressed: () => _confirmLogout(context, isDarkMode),
      style: TextButton.styleFrom(
        foregroundColor: isDarkMode ? Colors.black : Colors.white,
      ),
      icon: const Icon(Icons.logout_rounded, size: 18),
      label: Text(
        "Logout",
        style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, bool isDarkMode) async {
    final bool? confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "dismiss",
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _LogoutPopup(isDarkMode: !isDarkMode);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
          reverseCurve: Curves.easeIn,
        );
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.85 + (0.15 * curved.value),
            child: child,
          ),
        );
      },
    );

    if (confirmed != true) return;

    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  Widget _themeToggleButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggleTheme,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDarkMode ? AppColors.deepPurple : Colors.white,
          ),
          child: Icon(
            isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: isDarkMode ? Colors.white : AppColors.deepPurple,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    String text,
    VoidCallback onPressed,
    bool isDarkMode, {
    bool isActive = false,
  }) {
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        final bool highlighted = isActive || isHovered;
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: isDarkMode ? Colors.black : Colors.white,
              overlayColor: Colors.transparent,
              padding: EdgeInsets.zero,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 17,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isDarkMode ? Colors.black : Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 3,
                  width: highlighted ? 50 : 0,
                  decoration: BoxDecoration(
                    color: AppColors.purpleAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LogoutPopup extends StatelessWidget {
  final bool isDarkMode;

  const _LogoutPopup({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final Color accent = isDarkMode
        ? AppColors.lavenderAccent
        : AppColors.deepPurple;

    final Color cardColor = isDarkMode
        ? Colors.white.withOpacity(0.10)
        : Colors.white.withOpacity(0.85);

    final Color borderColor = isDarkMode
        ? Colors.white.withOpacity(0.18)
        : Colors.black.withOpacity(0.08);

    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color subTextColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.25,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Main glass card
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    margin: const EdgeInsets.only(top: 26),
                    padding: const EdgeInsets.fromLTRB(18, 34, 18, 20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor, width: 1.4),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.35),
                          blurRadius: 30,
                          spreadRadius: 2,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Log Out",
                          style: GoogleFonts.spaceGrotesk(
                            color: accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Are you sure you want to log out of Lizzen?",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spaceGrotesk(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 22),

                        Row(
                          children: [
                            // CANCEL — outline / ghost style
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: isDarkMode
                                        ? Colors.white.withOpacity(0.25)
                                        : Colors.black.withOpacity(0.15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Cancel",
                                  style: GoogleFonts.spaceGrotesk(
                                    color: subTextColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // CONFIRM — filled accent style
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  foregroundColor: isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Logout",
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Badge icon poking out of the top edge.
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [accent, accent.withOpacity(0.55)],
                  ),
                  border: Border.all(
                    color: isDarkMode ? Colors.black : Colors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.55),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: isDarkMode ? Colors.black : Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
