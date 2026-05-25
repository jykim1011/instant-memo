import 'package:flutter/material.dart';
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
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
