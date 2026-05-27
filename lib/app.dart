import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/custom_bottom_nav.dart';
import 'features/cycle/presentation/screens/cycle_screen.dart';
import 'features/notes/presentation/screens/note_editor_screen.dart';
import 'features/notes/presentation/screens/notes_screen.dart';

// ─── Theme provider ───────────────────────────────────────────────────────────

final useSoftPinkProvider = StateProvider<bool>((ref) => false);

// ─── Router ───────────────────────────────────────────────────────────────────

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _ShellScreen(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: NotesScreen(),
          ),
        ),
        GoRoute(
          path: '/cycle',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CycleScreen(),
          ),
        ),
      ],
    ),
    // Note editor sits outside the shell — no bottom nav shown
    GoRoute(
      path: '/note',
      pageBuilder: (context, state) {
        final noteId = state.extra as String;
        return CustomTransitionPage(
          transitionDuration: const Duration(milliseconds: 340),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          child: NoteEditorScreen(noteId: noteId),
          transitionsBuilder: (ctx, anim, secAnim, child) {
            final slide = Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
            ));
            return SlideTransition(
              position: slide,
              child: FadeTransition(opacity: anim, child: child),
            );
          },
        );
      },
    ),
  ],
);

// ─── App root ─────────────────────────────────────────────────────────────────

class WoNotesApp extends ConsumerWidget {
  const WoNotesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useSoftPink = ref.watch(useSoftPinkProvider);
    return MaterialApp.router(
      title: 'WoNotes',
      debugShowCheckedModeBanner: false,
      theme: useSoftPink ? AppTheme.softPink : AppTheme.light,
      routerConfig: _router,
      locale: const Locale('ru', 'RU'),
    );
  }
}

// ─── Shell (bottom nav wrapper) ───────────────────────────────────────────────

class _ShellScreen extends StatelessWidget {
  final Widget child;
  const _ShellScreen({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = location.startsWith('/cycle') ? 1 : 0;

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: index,
        onTap: (i) {
          if (i == 0) context.go('/');
          if (i == 1) context.go('/cycle');
        },
      ),
    );
  }
}
