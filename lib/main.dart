import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';

import 'src/screens/main_screen.dart';
import 'src/screens/search_screen.dart';
import 'src/screens/trips_screen.dart';
import 'src/screens/seat_map_screen.dart';
import 'src/screens/sign_in_screen.dart';
import 'src/screens/sign_up_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);

    final router = GoRouter(
      initialLocation: '/home',
      refreshListenable: GoRouterRefreshStream(
        FirebaseAuth.instance.authStateChanges(),
      ),
      redirect: (context, state) {
        if (auth.isLoading) return null;

        final isLoggedIn = auth.valueOrNull != null;

        final goingToAuth =
            state.matchedLocation == '/signin' ||
            state.matchedLocation == '/signup';

        final isProtected =
            state.matchedLocation == '/trips' ||
            state.matchedLocation == '/seatmap';

        if (!isLoggedIn && isProtected) return '/signin';
        if (isLoggedIn && goingToAuth) return '/home';

        return null;
      },
      routes: [
        GoRoute(path: '/', redirect: (_, __) => '/home'),

        GoRoute(path: '/home', builder: (context, state) => const MainScreen()),

        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),

        GoRoute(
          path: '/signin',
          builder: (context, state) => const SignInScreen(),
        ),

        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpScreen(),
        ),

        GoRoute(
          path: '/trips',
          builder: (context, state) =>
              TripsScreen(args: state.extra as Map<String, dynamic>?),
        ),

        GoRoute(
          path: '/seatmap',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return SeatMapScreen(
              tripId: extra?['tripId'] as String?,
              from: extra?['from'] as String?,
              to: extra?['to'] as String?,
              price: extra?['price'] as num?,
            );
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text("Page not found")),
        body: Center(child: Text(state.error.toString())),
      ),
    );

    if (auth.isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Bus Booking',
      routerConfig: router,
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
