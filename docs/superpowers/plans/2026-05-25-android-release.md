# Instant Memo Android Release Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prepare Instant Memo for Google Play Store release with KO/EN i18n, real AdMob IDs, release signing, and GitHub push.

**Architecture:** Single Flutter app with `flutter_localizations` for automatic KO/EN switching by device locale. Release signing configured via `android/key.properties` (gitignored). New standalone GitHub repo for the app directory only.

**Tech Stack:** Flutter 3.x, flutter_localizations (Flutter SDK), intl ^0.18.0, google_mobile_ads ^5.1.0, shared_preferences ^2.3.0, Android Gradle, GitHub CLI (`gh`)

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `pubspec.yaml` | Modify | Add flutter_localizations, intl, generate: true |
| `l10n.yaml` | Create | Configure ARB generation |
| `lib/l10n/app_en.arb` | Create | English strings |
| `lib/l10n/app_ko.arb` | Create | Korean strings |
| `lib/main.dart` | Modify | Add localizationsDelegates, replace hardcoded strings, update AdMob ID |
| `android/app/src/main/AndroidManifest.xml` | Modify | Replace test AdMob app ID with real ID |
| `android/app/build.gradle` | Modify | Add release signing config |
| `android/key.properties` | Create (manual) | Keystore credentials — gitignored |
| `.gitignore` | Create | Flutter standard + signing exclusions |
| `test/l10n_test.dart` | Create | Widget test for KO/EN string resolution |

---

## Task 1: Add i18n Dependencies and ARB Files

**Files:**
- Modify: `pubspec.yaml`
- Create: `l10n.yaml`
- Create: `lib/l10n/app_en.arb`
- Create: `lib/l10n/app_ko.arb`

- [ ] **Step 1: Update pubspec.yaml**

Replace the existing `pubspec.yaml` with:

```yaml
name: instant_memo
description: Quick memo app to capture fleeting thoughts.
publish_to: none
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.0
  google_mobile_ads: ^5.1.0
  shared_preferences: ^2.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
  generate: true
```

- [ ] **Step 2: Create l10n.yaml at project root**

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

- [ ] **Step 3: Create lib/l10n/app_en.arb**

```json
{
  "@@locale": "en",
  "appTitle": "Instant Memo",
  "myMemos": "My Memos",
  "active": "Active",
  "completed": "Completed",
  "addMemo": "Add Memo",
  "editMemo": "Edit Memo",
  "deleteMemo": "Delete Memo",
  "deleteConfirm": "Delete this memo?",
  "deleteConfirmPermanent": "Permanently delete this memo?",
  "cancel": "Cancel",
  "delete": "Delete",
  "save": "Save",
  "hintText": "Write down what comes to mind...",
  "emptyActive": "No memos yet.\nTap + to write your first memo.",
  "emptyCompleted": "No completed memos.",
  "memoDeleted": "Memo deleted.",
  "emptyContent": "Please enter memo content.",
  "deleteThisMemo": "Delete this memo"
}
```

- [ ] **Step 4: Create lib/l10n/app_ko.arb**

```json
{
  "@@locale": "ko",
  "appTitle": "순간 메모",
  "myMemos": "내 메모",
  "active": "활성",
  "completed": "완료",
  "addMemo": "메모 추가",
  "editMemo": "메모 편집",
  "deleteMemo": "메모 삭제",
  "deleteConfirm": "이 메모를 삭제하시겠습니까?",
  "deleteConfirmPermanent": "이 메모를 영구적으로 삭제하시겠습니까?",
  "cancel": "취소",
  "delete": "삭제",
  "save": "저장",
  "hintText": "지금 떠오르는 생각을 적어보세요...",
  "emptyActive": "아직 메모가 없습니다.\n+ 버튼을 눌러 첫 메모를 작성해보세요.",
  "emptyCompleted": "완료된 메모가 없습니다.",
  "memoDeleted": "메모가 삭제되었습니다.",
  "emptyContent": "메모 내용을 입력해 주세요.",
  "deleteThisMemo": "이 메모 삭제"
}
```

- [ ] **Step 5: Install dependencies**

```bash
cd D:/app-creator-agent/apps/2026-05-24-instant-memo
flutter pub get
```

Expected: No errors. Dependencies resolved.

---

## Task 2: Write Failing i18n Widget Test

**Files:**
- Create: `test/l10n_test.dart`

- [ ] **Step 1: Create test/l10n_test.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget _wrap({required Locale locale, required Widget child}) {
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
      _wrap(
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
    expect(find.text('Instant Memo'), findsOneWidget);
    expect(find.text('My Memos'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
  });

  testWidgets('Korean locale resolves appTitle and myMemos', (tester) async {
    await tester.pumpWidget(
      _wrap(
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
    expect(find.text('순간 메모'), findsOneWidget);
    expect(find.text('내 메모'), findsOneWidget);
    expect(find.text('활성'), findsOneWidget);
    expect(find.text('완료'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails (generated code not yet created)**

```bash
flutter test test/l10n_test.dart
```

Expected: FAIL — `package:flutter_gen/gen_l10n/app_localizations.dart` cannot be resolved because `flutter gen-l10n` has not been run yet.

- [ ] **Step 3: Generate localization code**

```bash
flutter gen-l10n
```

Expected: No errors. `.dart_tool/flutter_gen/gen_l10n/app_localizations.dart` is generated.

- [ ] **Step 4: Run test to verify it passes**

```bash
flutter test test/l10n_test.dart
```

Expected: All 2 tests PASS.

---

## Task 3: Update main.dart with Localizations

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Replace lib/main.dart entirely**

Replace the full content of `lib/main.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      initialRoute: '/',
      routes: {
        '/': (ctx) => const MemoListScreen(),
        '/memolist': (ctx) => const MemoListScreen(),
        '/memoform': (ctx) => const MemoFormScreen(),
      },
    );
  }
}

class Memo {
  final String id;
  final String content;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  const Memo({
    required this.id,
    required this.content,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt,
  });

  static String generateId() {
    final rng = Random();
    final ts = DateTime.now().microsecondsSinceEpoch;
    final r = rng.nextInt(999999).toString().padLeft(6, '0');
    return '${ts}_$r';
  }

  Memo copyWith({
    String? content,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return Memo(
      id: id,
      content: content ?? this.content,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      completedAt:
          clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory Memo.fromJson(Map<String, dynamic> json) => Memo(
        id: json['id'] as String,
        content: json['content'] as String,
        isCompleted: json['isCompleted'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
      );
}

class MemoStorage {
  static const String memoListJsonKey = 'memo_list_json_key';

  static Future<List<Memo>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(memoListJsonKey);
    if (raw == null) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((e) => Memo.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(List<Memo> memos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        memoListJsonKey, json.encode(memos.map((m) => m.toJson()).toList()));
  }
}

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final ad = BannerAd(
      adUnitId: 'ca-app-pub-4710152968528474/2033909610',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _ad = ad as BannerAd;
              _loaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    );
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _ad == null) return const SizedBox.shrink();
    return SizedBox(
      width: _ad!.size.width.toDouble(),
      height: _ad!.size.height.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }
}

class MemoListScreen extends StatefulWidget {
  const MemoListScreen({super.key});

  @override
  State<MemoListScreen> createState() => _MemoListScreenState();
}

class _MemoListScreenState extends State<MemoListScreen> {
  List<Memo> _memos = [];
  bool _showCompleted = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final memos = await MemoStorage.load();
    if (mounted) {
      setState(() {
        _memos = memos;
        _loading = false;
      });
    }
  }

  Future<void> _persist() => MemoStorage.save(_memos);

  List<Memo> get _visible =>
      _memos.where((m) => m.isCompleted == _showCompleted).toList();

  Future<void> _toggle(Memo memo) async {
    final i = _memos.indexWhere((m) => m.id == memo.id);
    if (i < 0) return;
    final next = !memo.isCompleted;
    setState(() {
      _memos[i] = memo.copyWith(
        isCompleted: next,
        completedAt: next ? DateTime.now() : null,
        clearCompletedAt: !next,
      );
    });
    await _persist();
  }

  Future<void> _remove(Memo memo) async {
    setState(() => _memos.removeWhere((m) => m.id == memo.id));
    await _persist();
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.memoDeleted),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _goForm({Memo? memo}) async {
    final result =
        await Navigator.pushNamed(context, '/memoform', arguments: memo);
    if (!mounted) return;
    if (result is Memo) {
      final i = _memos.indexWhere((m) => m.id == result.id);
      setState(() {
        if (i >= 0) {
          _memos[i] = result;
        } else {
          _memos.insert(0, result);
        }
      });
      await _persist();
    } else if (result == 'delete') {
      await _loadAll();
    }
  }

  String _fmt(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Future<bool?> _confirmDelete(BuildContext ctx) {
    final l10n = AppLocalizations.of(ctx)!;
    return showDialog<bool>(
      context: ctx,
      builder: (dlg) => AlertDialog(
        title: Text(l10n.deleteMemo),
        content: Text(l10n.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlg, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dlg, true),
            child: Text(l10n.delete,
                style: TextStyle(
                    color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final visible = _visible;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myMemos),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  label: Text(l10n.active),
                  icon: const Icon(Icons.edit_note),
                ),
                ButtonSegment(
                  value: true,
                  label: Text(l10n.completed),
                  icon: const Icon(Icons.check_circle_outline),
                ),
              ],
              selected: {_showCompleted},
              onSelectionChanged: (s) =>
                  setState(() => _showCompleted = s.first),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BannerAdWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goForm(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : visible.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _showCompleted
                              ? Icons.check_circle_outline
                              : Icons.note_add_outlined,
                          size: 80,
                          color: theme.colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showCompleted
                              ? l10n.emptyCompleted
                              : l10n.emptyActive,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: theme.colorScheme.outline,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(top: 8, bottom: 88),
                  itemCount: visible.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (_, index) {
                    final memo = visible[index];
                    return Dismissible(
                      key: Key(memo.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) => _confirmDelete(context),
                      onDismissed: (_) => _remove(memo),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: theme.colorScheme.error,
                        child: Icon(Icons.delete_forever,
                            color: theme.colorScheme.onError),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        leading: GestureDetector(
                          onTap: () => _toggle(memo),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: memo.isCompleted
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              border: Border.all(
                                color: memo.isCompleted
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline,
                                width: 2,
                              ),
                            ),
                            child: memo.isCompleted
                                ? Icon(Icons.check,
                                    size: 18,
                                    color: theme.colorScheme.onPrimary)
                                : null,
                          ),
                        ),
                        title: Text(
                          memo.content,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            decoration: memo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: memo.isCompleted
                                ? theme.colorScheme.outline
                                : null,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _fmt(memo.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.edit_outlined,
                              color: theme.colorScheme.primary),
                          onPressed: () => _goForm(memo: memo),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class MemoFormScreen extends StatefulWidget {
  const MemoFormScreen({super.key});

  @override
  State<MemoFormScreen> createState() => _MemoFormScreenState();
}

class _MemoFormScreenState extends State<MemoFormScreen> {
  Memo? _memo;
  late final TextEditingController _ctrl;
  bool _init = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      _init = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Memo) {
        _memo = args;
        _ctrl.text = args.content;
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final text = _ctrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.emptyContent)),
      );
      return;
    }
    final result = _memo != null
        ? _memo!.copyWith(content: text)
        : Memo(
            id: Memo.generateId(),
            content: text,
            isCompleted: false,
            createdAt: DateTime.now(),
          );
    if (mounted) Navigator.pop(context, result);
  }

  Future<void> _delete() async {
    if (_memo == null) return;
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dlg) => AlertDialog(
        title: Text(l10n.deleteMemo),
        content: Text(l10n.deleteConfirmPermanent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlg, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dlg, true),
            child: Text(l10n.delete,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final all = await MemoStorage.load();
    all.removeWhere((m) => m.id == _memo!.id);
    await MemoStorage.save(all);
    if (mounted) Navigator.pop(context, 'delete');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isEditing = _memo != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editMemo : l10n.addMemo),
        actions: [
          if (isEditing)
            IconButton(
              tooltip: l10n.delete,
              icon: Icon(Icons.delete_outline,
                  color: theme.colorScheme.error),
              onPressed: _delete,
            ),
        ],
      ),
      bottomNavigationBar: const BannerAdWidget(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _ctrl,
              maxLines: null,
              minLines: 10,
              autofocus: true,
              style: const TextStyle(fontSize: 16, height: 1.6),
              decoration: InputDecoration(
                hintText: l10n.hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerLowest,
              ),
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(l10n.save),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            if (isEditing) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _delete,
                icon: Icon(Icons.delete_forever_outlined,
                    color: theme.colorScheme.error),
                label: Text(l10n.deleteThisMemo,
                    style:
                        TextStyle(color: theme.colorScheme.error)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: theme.colorScheme.error),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add pubspec.yaml l10n.yaml lib/l10n/ lib/main.dart test/l10n_test.dart
git commit -m "feat: apply KO/EN i18n and real AdMob banner unit ID"
```

---

## Task 4: Update AndroidManifest with Real AdMob App ID

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml:9-10`

- [ ] **Step 1: Replace test AdMob app ID in AndroidManifest.xml**

Find this block (lines 8-10):
```xml
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-3940256099942544~3347511713"/>
```

Replace with:
```xml
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-4710152968528474~1950149136"/>
```

- [ ] **Step 2: Verify app builds (analyzer check)**

```bash
flutter analyze
```

Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add android/app/src/main/AndroidManifest.xml
git commit -m "feat: apply real AdMob app ID"
```

---

## Task 5: Configure Release Signing

**Files:**
- Modify: `android/app/build.gradle`
- Create: `android/key.properties` (manual — gitignored)
- Create: `.gitignore`

- [ ] **Step 1: Create .gitignore at project root**

```
# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.pub-cache/
.pub/
/build/

# Android
/android/app/debug
/android/app/profile
/android/app/release
android/local.properties

# Signing — never commit these
android/key.properties
*.jks
*.keystore

# IDE
.idea/
.vscode/
*.iml

# macOS
.DS_Store
```

- [ ] **Step 2: Generate keystore (MANUAL — run this yourself)**

Open a terminal and run:
```bash
keytool -genkey -v \
  -keystore ~/instant-memo-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias instant-memo
```

You will be prompted for:
- Keystore password (remember this)
- Key password (can be same as keystore password)
- Your name, organization, etc. (can fill with any values)

Note the full path to the generated `.jks` file.

- [ ] **Step 3: Create android/key.properties (fill in your values)**

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=instant-memo
storeFile=/Users/YOUR_USERNAME/instant-memo-release.jks
```

Replace `YOUR_KEYSTORE_PASSWORD`, `YOUR_KEY_PASSWORD`, and the storeFile path with your actual values. On Windows, use forward slashes or escape backslashes: `C:/Users/junyoung/instant-memo-release.jks`.

- [ ] **Step 4: Update android/app/build.gradle**

Replace the entire file with:

```groovy
def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader -> localProperties.load(reader) }
}

def flutterRoot = localProperties.getProperty('flutter.sdk')
if (flutterRoot == null) {
    throw new GradleException("Flutter SDK not found. Set flutter.sdk in local.properties.")
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode') ?: '1'
def flutterVersionName = localProperties.getProperty('flutter.versionName') ?: '1.0'

def keyProperties = new Properties()
def keyPropertiesFile = rootProject.file('key.properties')
if (keyPropertiesFile.exists()) {
    keyPropertiesFile.withReader('UTF-8') { reader -> keyProperties.load(reader) }
}

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

android {
    namespace 'com.appcreator.instant_memo'
    compileSdkVersion flutter.compileSdkVersion
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    kotlinOptions { jvmTarget = '1.8' }
    sourceSets { main.java.srcDirs += 'src/main/kotlin' }

    signingConfigs {
        release {
            keyAlias keyProperties['keyAlias']
            keyPassword keyProperties['keyPassword']
            storeFile keyProperties['storeFile'] ? file(keyProperties['storeFile']) : null
            storePassword keyProperties['storePassword']
        }
    }

    defaultConfig {
        applicationId 'com.appcreator.instant_memo'
        minSdkVersion flutter.minSdkVersion
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}

flutter { source '../..' }

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
}
```

- [ ] **Step 5: Commit (key.properties excluded by .gitignore)**

```bash
git add .gitignore android/app/build.gradle
git commit -m "feat: configure release signing"
```

---

## Task 6: Create GitHub Repo and Push

**Files:**
- No file changes — git and GitHub operations only

- [ ] **Step 1: Verify gh CLI is authenticated**

```bash
gh auth status
```

Expected: `Logged in to github.com as jykim1011`.
If not: run `gh auth login` and follow prompts.

- [ ] **Step 2: Initialize git repo in app directory (if not already)**

```bash
cd D:/app-creator-agent/apps/2026-05-24-instant-memo
git init
git add .
git commit -m "feat: initial instant memo app with KO/EN i18n and AdMob"
```

If `git init` says "Reinitialized existing Git repository", that's fine — just run `git add .` and commit.

- [ ] **Step 3: Create GitHub repo and push**

```bash
gh repo create instant-memo --public \
  --description "Quick memo app to capture fleeting thoughts. Flutter + AdMob." \
  --source=. --remote=origin --push
```

Expected output:
```
✓ Created repository jykim1011/instant-memo on GitHub
✓ Added remote https://github.com/jykim1011/instant-memo.git
✓ Pushed commits to https://github.com/jykim1011/instant-memo.git
```

- [ ] **Step 4: Verify on GitHub**

```bash
gh repo view instant-memo --web
```

Expected: Browser opens showing the repo with the pushed code.

---

## Task 7: Build Release AAB and Verify

**Files:**
- No file changes — build verification only

- [ ] **Step 1: Build release AAB**

```bash
cd D:/app-creator-agent/apps/2026-05-24-instant-memo
flutter build appbundle --release
```

Expected output (last lines):
```
✓ Built build/app/outputs/bundle/release/app-release.aab (XX.X MB).
```

If signing fails with "keystore file not found", verify the `storeFile` path in `android/key.properties` uses forward slashes: `C:/Users/junyoung/instant-memo-release.jks`.

- [ ] **Step 2: Confirm AAB file exists**

```bash
ls build/app/outputs/bundle/release/app-release.aab
```

Expected: file listed with size > 0.

---

## Play Store Submission Checklist

After completing the tasks above, submit via [play.google.com/console](https://play.google.com/console):

| Item | Status | Notes |
|------|--------|-------|
| AAB file | After Task 7 | `build/app/outputs/bundle/release/app-release.aab` |
| App name KO | Ready | 순간 메모 |
| App name EN | Ready | Instant Memo |
| Short description KO | Ready | 순간적인 생각을 빠르게 메모하세요 |
| Short description EN | Ready | Capture fleeting thoughts instantly |
| Full description KO/EN | Ready | See spec doc |
| App icon 512×512 | Manual | Create and upload |
| Screenshots (min 2) | Manual | Take from emulator or device |
| Privacy policy URL | Manual | Required due to AdMob — create a simple page |
| Content rating questionnaire | Manual | Complete in Play Console |
