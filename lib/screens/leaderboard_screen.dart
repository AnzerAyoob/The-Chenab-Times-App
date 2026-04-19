import 'package:flutter/material.dart';
import 'package:the_chenab_times/services/auth_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<LeaderboardEntry>> _future;
  int _lastSyncVersion = -1;

  @override
  void initState() {
    super.initState();
    _future = AuthService.instance.fetchLeaderboard();
    _lastSyncVersion = AuthService.instance.streakSyncVersion;
    AuthService.instance.addListener(_handleAuthUpdates);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = AuthService.instance.fetchLeaderboard();
    });
    await _future;
  }

  void _handleAuthUpdates() {
    final currentVersion = AuthService.instance.streakSyncVersion;
    if (currentVersion == _lastSyncVersion || !mounted) return;
    _lastSyncVersion = currentVersion;
    setState(() {
      _future = AuthService.instance.fetchLeaderboard();
    });
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_handleAuthUpdates);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? const Color(0xFF1A1A1A)
        : const Color(0xFFFFFCF7);
    final borderColor = isDark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFE4CFB1);
    final subtitleColor = isDark
        ? const Color(0xFFB5B5B5)
        : const Color(0xFF7A6247);
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<LeaderboardEntry>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 180),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }

            final entries = snapshot.data ?? const <LeaderboardEntry>[];
            if (entries.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 180),
                  Center(child: Text('No streaks yet. Be the first to play.')),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      _RankBadge(rank: index + 1),
                      const SizedBox(width: 14),
                      _LeaderboardAvatar(
                        name: entry.name,
                        profilePhoto: entry.profilePhoto,
                        radius: 18,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _rankLabel(index + 1),
                              style: TextStyle(
                                color: subtitleColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${entry.bestStreak}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF8C1D18),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _rankLabel(int rank) {
    switch (rank) {
      case 1:
        return 'Diamond Streak';
      case 2:
        return 'Gold Streak';
      case 3:
        return 'Bronze Streak';
      default:
        return 'Top 10 Streak';
    }
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final color = switch (rank) {
      1 => const Color(0xFF59B7FF),
      2 => const Color(0xFFD4A82A),
      3 => const Color(0xFFB5754B),
      _ => const Color(0xFF8C1D18),
    };

    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.14),
        border: Border.all(color: color),
      ),
      child: Text(
        '#$rank',
        style: TextStyle(color: color, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _LeaderboardAvatar extends StatefulWidget {
  const _LeaderboardAvatar({
    required this.name,
    required this.profilePhoto,
    required this.radius,
  });

  final String name;
  final String? profilePhoto;
  final double radius;

  @override
  State<_LeaderboardAvatar> createState() => _LeaderboardAvatarState();
}

class _LeaderboardAvatarState extends State<_LeaderboardAvatar> {
  bool _imageFailed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasProfilePhoto =
        !_imageFailed &&
        widget.profilePhoto != null &&
        widget.profilePhoto!.trim().isNotEmpty;
    final initials = _buildInitials(widget.name);

    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: isDark
          ? const Color(0xFF252525)
          : const Color(0xFFF2E2CA),
      backgroundImage: hasProfilePhoto
          ? NetworkImage(widget.profilePhoto!.trim())
          : null,
      onBackgroundImageError: hasProfilePhoto
          ? (_, __) {
              if (!mounted) return;
              setState(() => _imageFailed = true);
            }
          : null,
      child: hasProfilePhoto
          ? null
          : Text(
              initials,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: Color(0xFF8C1D18),
              ),
            ),
    );
  }

  String _buildInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
