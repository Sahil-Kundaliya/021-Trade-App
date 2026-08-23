import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:search/src/root/presentation/widgets/search_skeleton.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('shimmer preserves primitives in ${theme.brightness.name}', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(
            body: AppShimmer(
              child: Column(
                children: [
                  SkeletonBox(width: 100, height: 20),
                  SkeletonLine(widthFactor: .5),
                  SkeletonCircle(size: 32),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonBox), findsNWidgets(2));
      expect(find.byType(SkeletonLine), findsOneWidget);
      expect(find.byType(SkeletonCircle), findsOneWidget);
      expect(tester.getSize(find.byType(SkeletonCircle)), const Size(32, 32));
    });
  }

  testWidgets('reduced motion renders a static skeleton', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Center(
            child: AppShimmer(child: SkeletonBox(width: 80, height: 18)),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 2));
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.getSize(find.byType(SkeletonBox)), const Size(80, 18));
  });

  testWidgets('search skeleton has exactly three initial result rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: SearchSkeleton()),
      ),
    );

    expect(find.byType(SkeletonCircle), findsNWidgets(3));
  });
}
