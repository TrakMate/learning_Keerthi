import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landingpage/src/ui/custom/custom_appbar.dart';
import 'package:landingpage/src/ui/screens/album_detail_page.dart';
import 'package:landingpage/src/utils/colors.dart';
import 'package:landingpage/src/models/album_data.dart';
// import 'package:landingpage/src/ui/pages/album_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
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

  void _openAlbum(Album album) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            AlbumDetailPage(albumId: album.id, isDarkMode: isDarkMode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1100
        ? 5
        : width > 800
        ? 4
        : width > 550
        ? 3
        : 2;

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
                  activePage: "Albums",
                  onToggleTheme: _toggleTheme,
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                    itemCount: allAlbums.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 22,
                      childAspectRatio: 0.78,
                    ),
                    itemBuilder: (context, index) {
                      final album = allAlbums[index];
                      return _AlbumCard(
                        isDarkMode: isDarkMode,
                        album: album,
                        onTap: () => _openAlbum(album),
                      );
                    },
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

class _AlbumCard extends StatelessWidget {
  final bool isDarkMode;
  final Album album;
  final VoidCallback onTap;

  const _AlbumCard({
    required this.isDarkMode,
    required this.album,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: album.colors,
                ),
                boxShadow: [
                  BoxShadow(
                    color: album.colors.last.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.album_rounded,
                  color: Colors.white70,
                  size: 40,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            album.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.spaceGrotesk(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.textPrimary(isDarkMode),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            album.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: AppColors.textSecondary(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }
}
