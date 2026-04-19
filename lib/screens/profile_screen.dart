import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_chenab_times/screens/saved_articles_screen.dart';
import 'package:the_chenab_times/services/auth_service.dart';
import 'package:the_chenab_times/utils/avatar_helper.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFCF7),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFE4CFB1),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  backgroundImage: user == null
                      ? null
                      : NetworkImage(getUserAvatar(user.email, user.photo)),
                  child: user == null
                      ? const Icon(Icons.person_outline_rounded, size: 36)
                      : null,
                ),
                const SizedBox(height: 14),
                Text(
                  user?.name ?? 'Guest User',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  user?.email ?? 'Not logged in',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            tileColor: isDark
                ? const Color(0xFF1A1A1A)
                : const Color(0xFFFFFCF7),
            leading: const Icon(Icons.bookmark_outline_rounded),
            title: const Text('Saved Articles'),
            subtitle: const Text('Open your synced and local bookmarks'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedArticlesScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            tileColor: isDark
                ? const Color(0xFF1A1A1A)
                : const Color(0xFFFFFCF7),
            leading: Icon(
              user == null
                  ? Icons.lock_outline_rounded
                  : Icons.verified_user_outlined,
            ),
            title: Text(user == null ? 'Login Status' : 'Logged In'),
            subtitle: Text(
              user == null
                  ? 'Log in to sync streaks and saved articles'
                  : 'Your account is active on this device',
            ),
          ),
          if (user != null) ...[
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () async {
                await context.read<AuthService>().logout();
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log Out'),
            ),
          ],
        ],
      ),
    );
  }
}
