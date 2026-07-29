import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:landingpage/appbar/custom_appbar.dart';
import 'package:landingpage/src/ui/custom/custom_appbar.dart';
import 'package:landingpage/src/utils/colors.dart';
// import 'package:landingpage/util/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../../appbar/custom_appbar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isDarkMode = true;
  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? true;
    });
  }

  Future<void> _saveThemePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  void _toggleTheme() {
    setState(() => isDarkMode = !isDarkMode);
    _saveThemePreference(isDarkMode);
  }

  int selectedCategoryIndex = 0;
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = const [
    "Music Poppular",
    "Playlist",
    "Liked",
    "Pop Punk",
    "Viral Music",
    "Indie Music",
    "Pop",
    "Reggae",
  ];

  final List<Map<String, dynamic>> musicCards = const [
    {
      "title": "The Most Hitz\nMusic in 2023",
      "count": "220 Music List",
      "icon": Icons.headphones_rounded,
      "image": "assets/images/card2.png",
      "colors": AppColors.cardHitz,
      "flex": 3,
      "showButton": true,
    },
    {
      "title": "Relax",
      "count": "220 Music List",
      "icon": Icons.self_improvement_rounded,
      "image": "assets/images/card3.png",
      "colors": AppColors.cardRelax,
      "flex": 2,
      "showButton": true,
    },
    {
      "title": "Pop Punk",
      "count": "220 Music List",
      "icon": Icons.electric_bolt_rounded,
      "image": "assets/images/card4.png",
      "colors": AppColors.cardPopPunk,
      "flex": 2,
      "showButton": true,
    },
    {
      "title": "Nostalgic Songs\n90s high school era",
      "count": "220 Music List",
      "icon": Icons.album_rounded,
      "image": "assets/images/card5.png",
      "colors": AppColors.cardNostalgic,
      "flex": 3,
      "showButton": true,
    },
    {
      "title": "This song will shake\nyour spirits",
      "count": "220 Music List",
      "icon": Icons.graphic_eq_rounded,
      "image": "assets/images/card7.png",
      "colors": AppColors.cardShakeSpirits,
      "flex": 3,
      "showButton": true,
    },
    {
      "title": "Viral Music",
      "count": "220 Music List",
      "icon": Icons.trending_up_rounded,
      "image": "assets/images/card8.png",
      "colors": AppColors.cardViral,
      "flex": 2,
      "showButton": true,
    },
  ];

  List<String> get _filteredCategories {
    if (searchQuery.trim().isEmpty) return categories;
    final q = searchQuery.toLowerCase();
    return categories.where((c) => c.toLowerCase().contains(q)).toList();
  }

  List<Map<String, dynamic>> get _filteredMusicCards {
    if (searchQuery.trim().isEmpty) return musicCards;
    final q = searchQuery.toLowerCase();
    return musicCards
        .where((m) => (m["title"] as String).toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCategory(BuildContext context, String label) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _CategoryPage(isDarkMode: isDarkMode, category: label),
      ),
    );
  }

  List<Widget> _buildMusicRows(BuildContext context) {
    final cards = _filteredMusicCards;
    if (cards.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: Text(
              "No results for \"$searchQuery\"",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: AppColors.textMuted(isDarkMode),
              ),
            ),
          ),
        ),
      ];
    }

    final rows = <Widget>[];
    for (int i = 0; i < cards.length; i += 2) {
      final first = cards[i];
      final hasSecond = i + 1 < cards.length;
      final second = hasSecond ? cards[i + 1] : null;

      rows.add(
        Row(
          children: [
            Expanded(
              flex: first["flex"] as int,
              child: _MusicCard(
                isDarkMode: isDarkMode,
                data: first,
                height: 210,
                onTap: () => _openCategory(context, first["title"] as String),
              ),
            ),
            if (second != null) ...[
              const SizedBox(width: 18),
              Expanded(
                flex: second["flex"] as int,
                child: _MusicCard(
                  isDarkMode: isDarkMode,
                  data: second,
                  height: 210,
                  onTap: () =>
                      _openCategory(context, second["title"] as String),
                ),
              ),
            ],
          ],
        ),
      );
      if (i + 2 < cards.length) rows.add(const SizedBox(height: 18));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = FirebaseAuth.instance.currentUser;
    final displayName = (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName!
        : (user?.email?.split("@").first ?? "Listener");

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? AppColors.backgroundDark
                      : AppColors.backgroundLight,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                CustomAppBar(
                  isDarkMode: !isDarkMode,
                  showLoginButton: false,
                  onToggleTheme: _toggleTheme,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 25, bottom: 40),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: size.width * 0.9),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _WelcomeCard(
                              isDarkMode: isDarkMode,
                              name: displayName,
                            ),
                            const SizedBox(height: 28),

                            //  search bar — filters chips + cards live
                            _SearchBar(
                              isDarkMode: isDarkMode,
                              controller: _searchController,
                              onChanged: (value) {
                                setState(() => searchQuery = value);
                              },
                            ),
                            const SizedBox(height: 18),

                            // category pills — each one navigates on tap
                            SizedBox(
                              height: 42,
                              child: _filteredCategories.isEmpty
                                  ? Center(
                                      child: Text(
                                        "No categories match",
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 13,
                                          color: AppColors.textMuted(
                                            isDarkMode,
                                          ),
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _filteredCategories.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 10),
                                      itemBuilder: (context, index) {
                                        final label =
                                            _filteredCategories[index];
                                        final originalIndex = categories
                                            .indexOf(label);
                                        return _CategoryChip(
                                          isDarkMode: isDarkMode,
                                          label: label,
                                          selected:
                                              originalIndex ==
                                              selectedCategoryIndex,
                                          onTap: () {
                                            setState(
                                              () => selectedCategoryIndex =
                                                  originalIndex,
                                            );
                                            _openCategory(context, label);
                                          },
                                        );
                                      },
                                    ),
                            ),
                            const SizedBox(height: 30),

                            //  music card grid — filters + navigates on tap
                            ..._buildMusicRows(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final bool isDarkMode;
  final String name;

  const _WelcomeCard({required this.isDarkMode, required this.name});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
          decoration: BoxDecoration(
            color: AppColors.glassSurface(isDarkMode),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.glassBorder(isDarkMode),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.deepPurple,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back, $name",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(isDarkMode),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Here's what's happening with your music today.",
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: AppColors.textSecondary(isDarkMode),
                      ),
                    ),
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

class _SearchBar extends StatelessWidget {
  final bool isDarkMode;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.isDarkMode,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.glassSurface(isDarkMode),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.glassBorder(isDarkMode),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  textInputAction: TextInputAction.search,
                  style: GoogleFonts.spaceGrotesk(
                    color: AppColors.textPrimary(isDarkMode),
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search",
                    hintStyle: GoogleFonts.spaceGrotesk(
                      color: AppColors.textMuted(isDarkMode),
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              // Clear button appears only once there's something typed
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  if (value.text.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.textMuted(isDarkMode),
                    ),
                    onPressed: () {
                      controller.clear();
                      onChanged("");
                    },
                  );
                },
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.deepPurpleAccent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatefulWidget {
  final bool isDarkMode;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _CategoryChip({
    required this.isDarkMode,
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool highlighted = widget.selected || isHovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: highlighted
                ? AppColors.deepPurpleAccent
                : AppColors.glassSurface(widget.isDarkMode, darkAlpha: 0.07),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: highlighted
                  ? AppColors.deepPurpleAccent
                  : AppColors.glassBorder(widget.isDarkMode),
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: highlighted
                  ? Colors.white
                  : AppColors.textSecondary(widget.isDarkMode),
            ),
          ),
        ),
      ),
    );
  }
}

class _MusicCard extends StatefulWidget {
  final bool isDarkMode;
  final Map<String, dynamic> data;
  final double height;
  final VoidCallback? onTap;

  const _MusicCard({
    required this.isDarkMode,
    required this.data,
    required this.height,
    this.onTap,
  });

  @override
  State<_MusicCard> createState() => _MusicCardState();
}

class _MusicCardState extends State<_MusicCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.data["colors"] as List<Color>;
    final title = widget.data["title"] as String;
    final count = widget.data["count"] as String?;
    final showButton = widget.data["showButton"] as bool;
    final imagePath = widget.data["image"] as String?;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: colors.last.withValues(
                      alpha: isHovered ? 0.45 : 0.25,
                    ),
                    blurRadius: isHovered ? 26 : 14,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background photo (falls back to the gradient if no
                  // image is set, or if the asset fails to load).
                  if (imagePath != null)
                    Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: colors,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: colors,
                        ),
                      ),
                    ),

                  // Color-tint + darken overlay so text/button stay legible
                  // over any photo, while keeping the card's palette.
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.first.withValues(alpha: 0.55),
                          Colors.black.withValues(alpha: 0.72),
                        ],
                      ),
                    ),
                  ),

                  // Foreground content
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (count != null) ...[
                              Text(
                                count,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                            if (showButton)
                              GestureDetector(
                                // separate tap target so the button visually
                                // reacts too, but triggers the same navigation
                                onTap: widget.onTap,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    "Listen Now",
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: colors.last,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryPage extends StatelessWidget {
  final bool isDarkMode;
  final String category;

  const _CategoryPage({required this.isDarkMode, required this.category});

  @override
  Widget build(BuildContext context) {
    final title = category.replaceAll("\n", " ");
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? AppColors.backgroundDarkAlt
                : AppColors.categoryLightAlt,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary(isDarkMode),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(isDarkMode),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "Content for \"$title\" goes here",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      color: AppColors.textSecondary(isDarkMode),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
