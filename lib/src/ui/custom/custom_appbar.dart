import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:landingpage/main.dart';
import 'package:landingpage/src/forms/login_page.dart';
import 'package:landingpage/src/ui/screens/album_page.dart';
import 'package:landingpage/src/ui/screens/artist_page.dart';
import 'package:landingpage/src/ui/screens/discover.dart';
import 'package:landingpage/src/ui/screens/homepage.dart';
import 'package:landingpage/src/ui/screens/library.dart';
import 'package:landingpage/src/ui/screens/playlist.dart';
// import 'package:landingpage/src/ui/screens/library_page.dart';
import 'package:landingpage/src/utils/colors.dart';

class CustomAppBar extends StatelessWidget {
  final bool isDarkMode;
  final bool showLoginButton;
  final bool showMenu; // controls whether the nav menu items render
  final String activePage; // e.g. "Home", "Discover", "Library", etc.
  final VoidCallback onToggleTheme;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    this.showLoginButton = true,
    this.showMenu = true,
    this.activePage = "",
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final bool isLoggedIn = currentUser != null;

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
                                  builder: (_) => const ArtistsPage(),
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
                                  builder: (_) =>
                                      PlaylistMenuPage(isDarkMode: isDarkMode),
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
                    // --- theme toggle — always visible, on every page ---
                    const SizedBox(width: 14),
                    _themeToggleButton(),

                    // --- spacing between theme toggle and login/logout button ---
                    const SizedBox(width: 16),

                    // --- Login / User menu — driven by real auth state ---
                    if (isLoggedIn)
                      _UserMenuButton(
                        isDarkMode: isDarkMode,
                        username:
                            currentUser.displayName ??
                            currentUser.email ??
                            "User",
                        onLogoutTap: (anchor) =>
                            _confirmLogout(context, isDarkMode, anchor),
                      )
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

                    // // --- theme toggle — always visible, on every page ---
                    // const SizedBox(width: 14),
                    // _themeToggleButton(),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Container(
        //   margin: const EdgeInsets.only(top: 5),
        //   width: 70,
        //   height: 5,
        //   decoration: BoxDecoration(
        //     color: AppColors.purpleAccent,
        //     borderRadius: BorderRadius.circular(20),
        //   ),
        // ),
      ],
    );
  }

  static Future<void> _confirmLogout(
    BuildContext context,
    bool isDarkMode,
    Offset anchor,
  ) async {
    final bool? confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "dismiss",
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _LogoutPopup(isDarkMode: !isDarkMode, anchor: anchor);
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
            alignment: Alignment.topRight,
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggleTheme,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 60, // Increase to 70 or 80 if you want it longer
            height: 35,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.deepPurple : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: isDarkMode ? Colors.white : AppColors.deepPurple,
              size: 20,
            ),
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

/// Circular user icon that, on hover, pops open a small glass card showing
/// the signed-in username and a "Logout" button. Position is computed
/// directly from the icon's on-screen coordinates via a GlobalKey +
/// RenderBox, and placed with a plain Positioned widget. Styled with a
/// solid purple frosted background (instead of white) and a gradient badge
/// icon poking out of the top, matching the confirm-logout popup's accent.
class _UserMenuButton extends StatefulWidget {
  final bool isDarkMode;
  final String username;
  final void Function(Offset anchor) onLogoutTap;

  const _UserMenuButton({
    required this.isDarkMode,
    required this.username,
    required this.onLogoutTap,
  });

  @override
  State<_UserMenuButton> createState() => _UserMenuButtonState();
}

class _UserMenuButtonState extends State<_UserMenuButton> {
  final GlobalKey _iconKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  Timer? _hideTimer;

  /// Bottom-right corner of the user icon, in global (screen) coordinates.
  Offset _iconBottomRightGlobal() {
    final RenderBox box =
        _iconKey.currentContext!.findRenderObject() as RenderBox;
    return box.localToGlobal(Offset(box.size.width, box.size.height));
  }

  void _openMenu() {
    _hideTimer?.cancel();
    if (_overlayEntry != null) return;
    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _scheduleClose() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 180), _closeMenu);
  }

  void _closeMenu() {
    _hideTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _buildOverlayEntry() {
    const Color accent = Color(0xFFD89AE8);

    final Color cardColor = const Color(0xFF8F789A).withOpacity(0.78);

    final Color borderColor = Colors.white.withOpacity(0.22);
    const Color textColor = Colors.white;

    // Compute the position once, right before building the overlay.
    final Offset anchor = _iconBottomRightGlobal();
    const double cardWidth = 210;
    const double gap = 10; // vertical distance below the icon

    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Positioned from the RIGHT and TOP edges of the screen, so the
            // card's top-right corner sits right under the icon's
            // bottom-right corner.
            Positioned(
              right: MediaQuery.of(context).size.width - anchor.dx,
              top: anchor.dy + gap,
              child: MouseRegion(
                onEnter: (_) => _hideTimer?.cancel(),
                onExit: (_) => _scheduleClose(),
                child: SizedBox(
                  width: cardWidth,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Main glass card — frosted blur, purple fill, soft
                      // accent border, purple-tinted shadow.
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            margin: const EdgeInsets.only(top: 18),
                            padding: const EdgeInsets.fromLTRB(14, 26, 14, 14),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: borderColor,
                                width: 1.4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.28),
                                  blurRadius: 30,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.username,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.spaceGrotesk(
                                    color: textColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    letterSpacing: 0.3,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 32,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      final Offset logoutAnchor =
                                          _iconBottomRightGlobal();
                                      _closeMenu();
                                      widget.onLogoutTap(logoutAnchor);
                                    },
                                    icon: const Icon(
                                      Icons.logout_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      //loggggggggggggggggggg
                                      "Logout",
                                      style: GoogleFonts.spaceGrotesk(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                        fontSize: 12,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
                              border: Border.all(
                                color: borderColor,
                                width: 1.4,
                              ),
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
                                  widget.username,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.spaceGrotesk(
                                    color: textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.none,
                                  ),
                                ),

                                const SizedBox(height: 22),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final Offset logoutAnchor =
                                          _iconBottomRightGlobal();
                                      _closeMenu();
                                      widget.onLogoutTap(logoutAnchor);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: widget.isDarkMode
                                          ? Colors.white
                                          : const Color(0xFF6A1B9A),
                                      foregroundColor: widget.isDarkMode
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
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Gradient badge icon poking out the top, aligned to
                      // the right so it sits under the user icon.
                      Positioned(
                        right: 12,
                        top: 0,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFD89AE8), Color(0xFFC67AD8)],
                            ),
                            border: Border.all(
                              color: widget.isDarkMode
                                  ? Colors.black
                                  : Colors.white,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withOpacity(0.55),
                                blurRadius: 14,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.black,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _openMenu(),
      onExit: (_) => _scheduleClose(),
      child: Container(
        key: _iconKey,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.isDarkMode ? AppColors.deepPurple : Colors.white,
        ),
        child: Icon(
          Icons.person_rounded,
          color: widget.isDarkMode ? Colors.white : AppColors.deepPurple,
          size: 20,
        ),
      ),
    );
  }
}

class _LogoutPopup extends StatelessWidget {
  final bool isDarkMode;
  final Offset anchor; // bottom-right corner of the user icon, in global coords

  const _LogoutPopup({required this.isDarkMode, required this.anchor});

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

    const double popupWidth = 260;
    const double gap = 10; // vertical distance below the icon
    final double screenWidth = MediaQuery.of(context).size.width;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Positioned from the RIGHT and TOP edges — card's top-right
          // corner sits right under the icon's bottom-right corner.
          Positioned(
            right: screenWidth - anchor.dx,
            top: anchor.dy + gap,
            child: SizedBox(
              width: popupWidth,
              child: Stack(
                clipBehavior: Clip.none,
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
                                decoration: TextDecoration.none,
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
                                decoration: TextDecoration.none,
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
                                        decoration: TextDecoration.none,
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
                                      backgroundColor: isDarkMode
                                          ? Colors.white
                                          : const Color(
                                              0xFF6A1B9A,
                                            ), // Purple for light mode
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
                                        decoration: TextDecoration.none,
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

                  // Badge icon poking out of the top edge, aligned to the
                  // right so it sits under the user icon.
                  Positioned(
                    right: 12,
                    top: 0,
                    child: Container(
                      width: 52,
                      height: 52,
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
                      child: Icon(
                        Icons.logout_rounded,
                        color: isDarkMode ? Colors.black : Colors.white,
                        size: 24,
                      ),
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
