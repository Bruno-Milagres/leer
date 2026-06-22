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
import '../../features/settings/presentation/server_settings_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../providers.dart';
import 'app_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _libraryKey = GlobalKey<NavigatorState>();
final _downloadsKey = GlobalKey<NavigatorState>();
final _settingsKey = GlobalKey<NavigatorState>();

/// Router do app (seção 6). Redireciona para /onboarding quando não há
/// servidor configurado, e de / para /library.
final goRouterProvider = Provider<GoRouter>((ref) {
  // Reavalia os redirects sempre que o servidor ativo muda.
  final refresh = ValueNotifier<int>(0);
  ref.onDispose(refresh.dispose);
  ref.listen(activeServerProvider, (_, __) => refresh.value++);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/library',
    refreshListenable: refresh,
    redirect: (context, state) {
      final activeServer = ref.read(activeServerProvider);
      // Durante o carregamento inicial não redirecionamos.
      if (activeServer.isLoading) return null;

      final hasServer = activeServer.valueOrNull != null;
      final atOnboarding = state.matchedLocation == '/onboarding';
      final atServerSetup = state.matchedLocation == '/settings/server';

      if (!hasServer && !atOnboarding && !atServerSetup) {
        return '/onboarding';
      }
      if (hasServer && atOnboarding) {
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
        builder: (context, state) => ReaderScreen(
          bookId: int.parse(state.pathParameters['id']!),
        ),
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
                    path: 'server',
                    builder: (context, state) => const ServerSettingsScreen(),
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
