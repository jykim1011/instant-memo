import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget wrapWithLocale({required Locale locale, required Widget child}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    home: child,
  );
}

void main() {
  testWidgets('English locale resolves appTitle and myMemos', (tester) async {
    await tester.pumpWidget(
      wrapWithLocale(
        locale: const Locale('en'),
        child: Builder(
          builder: (ctx) {
            final l10n = AppLocalizations.of(ctx)!;
            return Column(children: [
              Text(l10n.appTitle),
              Text(l10n.myMemos),
              Text(l10n.active),
              Text(l10n.completed),
            ]);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Instant Memo'), findsOneWidget);
    expect(find.text('My Memos'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
  });

  testWidgets('Korean locale resolves appTitle and myMemos', (tester) async {
    await tester.pumpWidget(
      wrapWithLocale(
        locale: const Locale('ko'),
        child: Builder(
          builder: (ctx) {
            final l10n = AppLocalizations.of(ctx)!;
            return Column(children: [
              Text(l10n.appTitle),
              Text(l10n.myMemos),
              Text(l10n.active),
              Text(l10n.completed),
            ]);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('순간 메모'), findsOneWidget);
    expect(find.text('내 메모'), findsOneWidget);
    expect(find.text('진행 중'), findsOneWidget);
    expect(find.text('완료'), findsOneWidget);
  });
}
