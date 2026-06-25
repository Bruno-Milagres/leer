import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/annotations/presentation/annotations_screen.dart';
import '../../features/book_detail/presentation/book_detail_screen.dart';
import '../../features/downloads/presentation/downloads_screen.dart';
import '../../features/library/presentation/library_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/reader/presentation/reader_screen.dart';
import '../../features/settings/presentation/reader_settings_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/sources_screen.dart';
import '../providers.dart';
import 'app_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _libraryKey = GlobalKey<NavigatorState>();
final _downloadsKey = GlobalKey<NavigatorState>();
final _settingsKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.onDispose(refresh.dispose);
  ref.listen(allSourcesProvider, (_, __) => refresh.value++);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/library',
    refreshListenable: refresh,
    redirect: (context, state) {
      final sourcesAsync = ref.read(allSourcesProvider);
      if (sourcesAsync.isLoading) return null;

      final sources = sourcesAsync.valueOrNull ?? [];
      final hasSources = sources.isNotEmpty;
      final atOnboarding = state.matchedLocation == '/onboarding';
      final atSourceSetup = state.matchedLocation.startsWith(
        '/settings/sources',
      );

      if (!hasSources && !atOnboarding && !atSourceSetup) {
        return '/onboarding';
      }
      if (hasSources && atOnboarding) {
        return '/library';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/library/book/:id/read',
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            ReaderScreen(bookId: int.parse(state.pathParameters['id']!)),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _libraryKey,
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
                routes: [
                  GoRoute(
                    path: 'book/:id',
                    parentNavigatorKey: _libraryKey,
                    builder: (context, state) => BookDetailScreen(
                      bookId: int.parse(state.pathParameters['id']!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _downloadsKey,
            routes: [
              GoRoute(
                path: '/downloads',
                builder: (context, state) => const DownloadsScreen(),
              ),
              GoRoute(
                path: '/annotations',
                builder: (context, state) => const AnnotationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _settingsKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'sources',
                    builder: (context, state) => const SourcesScreen(),
                  ),
                  GoRoute(
                    path: 'reader',
                    builder: (context, state) => const ReaderSettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
