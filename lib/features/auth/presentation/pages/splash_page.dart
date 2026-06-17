import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/config/app_info.dart';

/// Shown while [AuthCubit] resolves the initial session. The router redirects
/// away as soon as auth becomes Authenticated/Unauthenticated.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FlutterLogo(size: 72),
            const SizedBox(height: 24),
            Text(
              AppInfo.appName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
