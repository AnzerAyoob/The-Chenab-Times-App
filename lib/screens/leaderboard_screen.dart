import 'package:flutter/material.dart';
import 'package:the_chenab_times/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

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

  bool _canOpenProfile(int index, LeaderboardEntry entry) {
    return index < 3;
  }

  Future<void> _openExternalUrl(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showProfileSheet(LeaderboardEntry entry, int rank) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = switch (rank) {
      1 => const Color(0xFF59B7FF),
      2 => const Color(0xFFD4A82A),
      _ => const Color(0xFFB5754B),
    };
    final tagline = [
      if ((entry.jobTitle ?? '').trim().isNotEmpty) entry.jobTitle!.trim(),
      if ((entry.company ?? '').trim().isNotEmpty) entry.company!.trim(),
    ].join(' at ');
    final hasExtendedProfile = entry.hasProfileShoutout;
    final headline = switch (rank) {
      1 => 'Spotlight Winner',
      2 => 'Featured Runner-Up',
      _ => 'Bronze Spotlight',
    };
    final subhead = hasExtendedProfile
        ? 'Public profile details are shown from the winner\'s Gravatar presence.'
        : 'This winner still gets a premium Chenab Times shoutout even without a public Gravatar profile.';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isDark ? const Color(0xFF181512) : const Color(0xFFFFFCF7),
                    isDark ? const Color(0xFF231B14) : const Color(0xFFF8E9D3),
                    isDark ? const Color(0xFF121212) : const Color(0xFFFFF4E8),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: isDark ? 0.18 : 0.16),
                    blurRadius: 28,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor,
                            accentColor.withValues(alpha: 0.72),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.28),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.campaign_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Top 3 Shoutout',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RankBadge(rank: rank),
                        const SizedBox(width: 14),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                accentColor.withValues(alpha: 0.95),
                                accentColor.withValues(alpha: 0.45),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(alpha: 0.24),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: _LeaderboardAvatar(
                            name: entry.name,
                            profilePhoto: entry.profilePhoto,
                            radius: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                headline,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                entry.name,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (tagline.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  tagline,
                                  style: TextStyle(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.78,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              if ((entry.location ?? '').trim().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  entry.location!.trim(),
                                  style: TextStyle(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.62,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accentColor.withValues(alpha: isDark ? 0.16 : 0.14),
                            colorScheme.surface.withValues(
                              alpha: isDark ? 0.72 : 0.94,
                            ),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            headline,
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subhead,
                            style: TextStyle(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.72,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if ((entry.bio ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withValues(
                            alpha: isDark ? 0.56 : 0.88,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.08,
                            ),
                          ),
                        ),
                        child: Text(
                          entry.bio!.trim(),
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            height: 1.45,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withValues(
                            alpha: isDark ? 0.56 : 0.88,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.08,
                            ),
                          ),
                        ),
                        child: Text(
                          'A top Chenab Times Games performer earning a community shoutout for their spot on the leaderboard.',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.82,
                            ),
                            height: 1.45,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        if ((entry.profileUrl ?? '').trim().isNotEmpty)
                          _ProfileLinkChip(
                            label: 'Gravatar Profile',
                            icon: Icons.verified_user_outlined,
                            accentColor: accentColor,
                            onTap: () => _openExternalUrl(entry.profileUrl!),
                          ),
                        ...entry.socialAccounts.map(
                          (account) => _ProfileLinkChip(
                            label: account.label,
                            icon: Icons.open_in_new_rounded,
                            accentColor: accentColor,
                            onTap: () => _openExternalUrl(account.url),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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
                  Center(child: Text('No points yet. Be the first to play.')),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final canOpenProfile = _canOpenProfile(index, entry);
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: canOpenProfile
                        ? () => _showProfileSheet(entry, index + 1)
                        : null,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
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
                                if (canOpenProfile) ...[
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFB32821),
                                              Color(0xFFD96B44),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Color(0x22B32821),
                                              blurRadius: 12,
                                              offset: Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: const Text(
                                          'Shoutout',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 11,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        'Tap to view profile',
                                        style: TextStyle(
                                          color: Color(0xFF8C1D18),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else if (index < 3) ...[
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Winner profile',
                                    style: TextStyle(
                                      color: Color(0xFF8C1D18),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${entry.totalPoints}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF8C1D18),
                                ),
                              ),
                              if (canOpenProfile) ...[
                                const SizedBox(height: 6),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFF8C1D18),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
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
        return 'Diamond Points';
      case 2:
        return 'Gold Points';
      case 3:
        return 'Bronze Points';
      default:
        return 'Top 10 Points';
    }
  }
}

class _ProfileLinkChip extends StatelessWidget {
  const _ProfileLinkChip({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: accentColor),
      label: Text(label),
      backgroundColor: accentColor.withValues(alpha: 0.08),
      side: BorderSide(color: accentColor.withValues(alpha: 0.18)),
      onPressed: onTap,
    );
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
