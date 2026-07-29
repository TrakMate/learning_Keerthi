import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:landingpage/src/ui/custom/custom_appbar.dart';
import 'package:landingpage/src/utils/colors.dart';
import 'package:landingpage/src/models/song_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  bool isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _panelVisible = true);
    });
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

  // ---- search panel state ----
  final TextEditingController _searchController = TextEditingController();
  bool _panelVisible = false; // slides in once, then stays put
  Song? _searchedSong; // the song matched by the user's search, once submitted

  void _onSearchSubmitted(String value) {
    final query = value.trim();
    if (query.isEmpty) return;

    final match = allSongs.firstWhere(
      (s) => s.title.toLowerCase().contains(query.toLowerCase()),
      orElse: () => Song(
        id: 'custom-${query.hashCode}',
        title: query,
        artist: "Search result",
        colors: AppColors
            .songPalette[query.hashCode.abs() % AppColors.songPalette.length],
      ),
    );

    setState(() => _searchedSong = match);
  }

  void _clearSearch() {
    setState(() {
      _searchedSong = null;
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final panelWidth = size.width * 0.25;

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
                  activePage: "Discover",
                  onToggleTheme: _toggleTheme,
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _searchedSong == null
                            ? _SongBrowseList(
                                isDarkMode: isDarkMode,
                                songs: allSongs,
                                leftInset: panelWidth,
                              )
                            : _SearchResultView(
                                isDarkMode: isDarkMode,
                                song: _searchedSong!,
                                leftInset: panelWidth,
                                onClear: _clearSearch,
                              ),
                      ),

                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.easeOutCubic,
                        top: 0,
                        bottom: 0,
                        left: _panelVisible ? 0 : -panelWidth,
                        width: panelWidth,
                        child: _SearchPanel(
                          isDarkMode: isDarkMode,
                          controller: _searchController,
                          onSubmitted: _onSearchSubmitted,
                        ),
                      ),
                    ],
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

class _SearchPanel extends StatelessWidget {
  final bool isDarkMode;
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  const _SearchPanel({
    required this.isDarkMode,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: AppColors.glassSurface(isDarkMode),
        border: Border(
          right: BorderSide(
            color: AppColors.glassBorder(isDarkMode),
            width: 1.2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Discover",
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(isDarkMode),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Find a song by name",
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: AppColors.textSecondary(isDarkMode),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.glassSurface(
                isDarkMode,
                darkAlpha: 0.07,
                lightAlpha: 0.03,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.glassBorder(isDarkMode),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: AppColors.textMuted(isDarkMode),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onSubmitted: onSubmitted,
                    style: GoogleFonts.spaceGrotesk(
                      color: AppColors.textPrimary(isDarkMode),
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      hintText: "Song name...",
                      hintStyle: GoogleFonts.spaceGrotesk(
                        color: AppColors.textFaint(isDarkMode),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Press Enter to search",
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              color: AppColors.textFaint(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }
}

class _SongBrowseList extends StatelessWidget {
  final bool isDarkMode;
  final List<Song> songs;
  final double leftInset;

  const _SongBrowseList({
    required this.isDarkMode,
    required this.songs,
    required this.leftInset,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20 + leftInset, 24, 20, 40),
      itemCount: songs.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              "Browse songs",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(isDarkMode),
              ),
            ),
          );
        }
        final song = songs[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _SongBar(isDarkMode: isDarkMode, song: song),
        );
      },
    );
  }
}

class _SearchResultView extends StatelessWidget {
  final bool isDarkMode;
  final Song song;
  final double leftInset;
  final VoidCallback onClear;

  const _SearchResultView({
    required this.isDarkMode,
    required this.song,
    required this.leftInset,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20 + leftInset, 24, 20, 40),
      children: [
        Text(
          "Search result",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(isDarkMode),
          ),
        ),
        const SizedBox(height: 16),
        _SongBar(isDarkMode: isDarkMode, song: song),
        const SizedBox(height: 18),
        OutlinedButton(
          onPressed: onClear,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isDarkMode ? Colors.white38 : Colors.black26,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          ),
          child: Text(
            "Show all songs",
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary(isDarkMode),
            ),
          ),
        ),
      ],
    );
  }
}

class _SongBar extends StatefulWidget {
  final bool isDarkMode;
  final Song song;

  const _SongBar({required this.isDarkMode, required this.song});

  @override
  State<_SongBar> createState() => _SongBarState();
}

class _SongBarState extends State<_SongBar> {
  bool isPlaying = false;
  bool isFavorited = false;
  bool isSaved = false;
  double _progress = 0.3;

  @override
  void initState() {
    super.initState();
    _loadLikedState();
    _loadSavedState();
  }

  Future<void> _loadLikedState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final liked = prefs.getStringList(likedSongIdsKey) ?? [];
    setState(() => isFavorited = liked.contains(widget.song.id));
  }

  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final saved = prefs.getStringList(savedSongIdsKey) ?? [];
    setState(() => isSaved = saved.contains(widget.song.id));
  }

  // Save/like button — toggles + persists to SharedPreferences so
  // LibraryPage's "Liked" tab picks it up immediately (they share the
  // same key + song ids from song_data.dart).
  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final liked = (prefs.getStringList(likedSongIdsKey) ?? []).toSet();
    final nowFavorited = !isFavorited;
    setState(() => isFavorited = nowFavorited);
    if (nowFavorited) {
      liked.add(widget.song.id);
    } else {
      liked.remove(widget.song.id);
    }
    await prefs.setStringList(likedSongIdsKey, liked.toList());
  }

  // Bookmark/save button — separate from "liked". Persists to its own
  // SharedPreferences key so LibraryPage's "Saved" tab can read it.
  Future<void> _toggleSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = (prefs.getStringList(savedSongIdsKey) ?? []).toSet();
    final nowSaved = !isSaved;
    setState(() => isSaved = nowSaved);
    if (nowSaved) {
      saved.add(widget.song.id);
    } else {
      saved.remove(widget.song.id);
    }
    await prefs.setStringList(savedSongIdsKey, saved.toList());

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: widget.isDarkMode
            ? const Color(0xff220833)
            : Colors.white,
        content: Text(
          nowSaved
              ? 'Saved "${widget.song.title}"'
              : 'Removed "${widget.song.title}" from Saved',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.textPrimary(widget.isDarkMode),
            fontWeight: FontWeight.w600,
          ),
        ),
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  // Bonus: playing a track also logs it to "recently played", which
  // LibraryPage's "Recent" tab reads from the same shared key.
  Future<void> _markPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList(recentlyPlayedIdsKey) ?? [];
    recent.remove(widget.song.id);
    recent.insert(0, widget.song.id);
    final capped = recent.length > 25 ? recent.sublist(0, 25) : recent;
    await prefs.setStringList(recentlyPlayedIdsKey, capped);
  }

  void _togglePlay() {
    final nowPlaying = !isPlaying;
    setState(() => isPlaying = nowPlaying);
    if (nowPlaying) _markPlayed();
  }

  void _seek(double value) => setState(() => _progress = value.clamp(0.0, 1.0));

  // Opens the "add to playlist" bottom sheet listing the 4 library
  // playlists; tapping one saves this song into it (song_data.dart).
  void _openAddToPlaylist() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          _AddToPlaylistSheet(isDarkMode: widget.isDarkMode, song: widget.song),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;
    final song = widget.song;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: AppColors.glassSurface(isDarkMode),
            border: Border.all(color: AppColors.glassBorder(isDarkMode)),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(colors: song.colors),
                      boxShadow: isPlaying
                          ? [
                              BoxShadow(
                                color: song.colors.last.withValues(alpha: 0.45),
                                blurRadius: 16,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      isPlaying
                          ? Icons.graphic_eq_rounded
                          : Icons.music_note_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.textPrimary(isDarkMode),
                                ),
                              ),
                            ),
                            // --- add to playlist button ---
                            GestureDetector(
                              onTap: _openAddToPlaylist,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.playlist_add_rounded,
                                  size: 20,
                                  color: AppColors.textFaint(isDarkMode),
                                ),
                              ),
                            ),
                            // --- save/bookmark button ---
                            GestureDetector(
                              onTap: _toggleSaved,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  isSaved
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                  size: 18,
                                  color: isSaved
                                      ? song.colors.last
                                      : AppColors.textFaint(isDarkMode),
                                ),
                              ),
                            ),
                            // --- like/favorite button ---
                            GestureDetector(
                              onTap: _toggleFavorite,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  isFavorited
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  size: 18,
                                  color: isFavorited
                                      ? song.colors.last
                                      : AppColors.textFaint(isDarkMode),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "${isPlaying ? 'Now Playing' : 'Paused'} • ${song.artist}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // The seek "line" — every song bar has one.
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            activeTrackColor: song.colors.last,
                            inactiveTrackColor: AppColors.glassBorder(
                              isDarkMode,
                              darkAlpha: 0.15,
                              lightAlpha: 0.08,
                            ),
                            thumbColor: song.colors.last,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 5,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12,
                            ),
                            overlayColor: song.colors.last.withValues(
                              alpha: 0.2,
                            ),
                          ),
                          child: Slider(
                            value: _progress,
                            min: 0.0,
                            max: 1.0,
                            onChanged: _seek,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: song.colors),
                      ),
                      child: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add-to-playlist sheet — lists the 4 library playlists; tapping one saves
// this song into it via song_data.dart's addSongToPlaylist, which persists
// to SharedPreferences so LibraryPage's Playlists tab picks it up.
// ---------------------------------------------------------------------------

class _AddToPlaylistSheet extends StatelessWidget {
  final bool isDarkMode;
  final Song song;

  const _AddToPlaylistSheet({required this.isDarkMode, required this.song});

  Future<void> _add(BuildContext context, Playlist playlist) async {
    final added = await addSongToPlaylist(playlist.id, song.id);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDarkMode ? const Color(0xff220833) : Colors.white,
        content: Text(
          added
              ? 'Added "${song.title}" to ${playlist.title}'
              : '"${song.title}" is already in ${playlist.title}',
          style: GoogleFonts.spaceGrotesk(
            color: AppColors.textPrimary(isDarkMode),
            fontWeight: FontWeight.w600,
          ),
        ),
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xff220833).withValues(alpha: 0.97)
                : Colors.white.withValues(alpha: 0.96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: AppColors.glassBorder(isDarkMode)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glassBorder(
                      isDarkMode,
                      darkAlpha: 0.35,
                      lightAlpha: 0.25,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "Add to playlist",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(isDarkMode),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                song.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: AppColors.textSecondary(isDarkMode),
                ),
              ),
              const SizedBox(height: 18),
              ...playlists.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => _add(context, p),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.glassSurface(
                          isDarkMode,
                          darkAlpha: 0.08,
                          lightAlpha: 0.04,
                        ),
                        border: Border.all(
                          color: AppColors.glassBorder(isDarkMode),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: p.gradient),
                            ),
                            child: Icon(p.icon, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.title,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: AppColors.textPrimary(isDarkMode),
                                  ),
                                ),
                                Text(
                                  p.description,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 11,
                                    color: AppColors.textSecondary(isDarkMode),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.add_circle_outline_rounded,
                            size: 20,
                            color: AppColors.textFaint(isDarkMode),
                          ),
                        ],
                      ),
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
