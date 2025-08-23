import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/memo_provider.dart';
import 'providers/category_provider.dart';
import 'providers/search_provider.dart';
import 'screens/memo_edit_screen.dart';
import 'screens/category_list_screen.dart';
import 'widgets/memo_list_item.dart';

void main() {
  runApp(const MyMemoApp());
}

class MyMemoApp extends StatelessWidget {
  const MyMemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MemoProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: MaterialApp(
      title: 'ai-MyMemo',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
        Locale('en', 'US'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MemoListScreen(),
      ),
    );
  }
}

class MemoListScreen extends StatefulWidget {
  const MemoListScreen({super.key});

  @override
  State<MemoListScreen> createState() => _MemoListScreenState();
}

class _MemoListScreenState extends State<MemoListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemoProvider>().loadMemos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _currentSearchQuery = '';
    });
    context.read<MemoProvider>().loadMemos();
  }

  void _clearSearch() {
    setState(() {
      _currentSearchQuery = '';
    });
    _searchController.clear();
    context.read<MemoProvider>().loadMemos();
  }

  void _onSearchChanged(String query) {
    setState(() {
      // 入力変更時にUI更新（履歴の表示を更新するため）
    });
    
    if (query.isEmpty) {
      setState(() {
        _currentSearchQuery = '';
      });
      context.read<MemoProvider>().loadMemos();
    }
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      setState(() {
        _currentSearchQuery = query.trim();
      });
      context.read<SearchProvider>().addToSearchHistory(query.trim());
      context.read<MemoProvider>().searchMemos(query.trim());
    }
  }

  void _showFavorites() {
    context.read<MemoProvider>().getFavoriteMemos();
  }

  void _showAllMemos() {
    context.read<MemoProvider>().loadMemos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'メモを検索...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
                autofocus: true,
                onChanged: _onSearchChanged,
                onSubmitted: _onSearchSubmitted,
              )
            : const Text('ai-MyMemo'),
        actions: [
          if (!_isSearching) ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _startSearch,
              tooltip: '検索',
            ),
            IconButton(
              icon: const Icon(Icons.category),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoryListScreen(),
                  ),
                );
              },
              tooltip: 'カテゴリー管理',
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'categories':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoryListScreen(),
                      ),
                    );
                    break;
                  case 'favorites':
                    _showFavorites();
                    break;
                  case 'all':
                    _showAllMemos();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'all',
                  child: Row(
                    children: [
                      Icon(Icons.list),
                      SizedBox(width: 8),
                      Text('すべてのメモ'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'favorites',
                  child: Row(
                    children: [
                      Icon(Icons.favorite),
                      SizedBox(width: 8),
                      Text('お気に入り'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'categories',
                  child: Row(
                    children: [
                      Icon(Icons.category),
                      SizedBox(width: 8),
                      Text('カテゴリー管理'),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.backspace_outlined),
              onPressed: _clearSearch,
              tooltip: '検索をクリア',
            ),
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _stopSearch,
              tooltip: '検索を終了',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // 検索履歴表示
          if (_isSearching)
            Consumer<SearchProvider>(
              builder: (context, searchProvider, child) {
                final suggestions = searchProvider.getSuggestions(_searchController.text);
                if (suggestions.isEmpty) return const SizedBox.shrink();
                
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Text(
                          '検索履歴',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      ...suggestions.take(5).map((suggestion) => ListTile(
                        leading: const Icon(Icons.history, size: 20, color: Colors.grey),
                        title: Text(
                          suggestion,
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => searchProvider.removeFromSearchHistory(suggestion),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        onTap: () {
                          _searchController.text = suggestion;
                          _onSearchSubmitted(suggestion);
                        },
                      )),
                      if (suggestions.length > 5)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: TextButton(
                            onPressed: () => searchProvider.clearSearchHistory(),
                            child: const Text(
                              '履歴をクリア',
                              style: TextStyle(fontSize: 12, color: Colors.red),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          // メモ一覧
          Expanded(
            child: Consumer<MemoProvider>(
              builder: (context, memoProvider, child) {
          if (memoProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (memoProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'エラーが発生しました',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    memoProvider.error!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      memoProvider.clearError();
                      memoProvider.loadMemos();
                    },
                    child: const Text('再試行'),
                  ),
                ],
              ),
            );
          }

          if (!memoProvider.hasMemos) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_add,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'メモはまだありません',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '右下の＋ボタンでメモを作成しましょう',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await memoProvider.loadMemos();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: memoProvider.memos.length,
              itemBuilder: (context, index) {
                final memo = memoProvider.memos[index];
                return MemoListItem(
                  memo: memo,
                  searchQuery: _currentSearchQuery.isNotEmpty ? _currentSearchQuery : null,
                  onTap: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MemoEditScreen(memo: memo),
                      ),
                    );
                    
                    if (result == true && context.mounted) {
                      memoProvider.loadMemos();
                    }
                  },
                  onFavoriteToggle: () async {
                    await memoProvider.toggleFavorite(memo.id!);
                  },
                );
              },
            ),
          );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => const MemoEditScreen(),
            ),
          );
          
          if (result == true && context.mounted) {
            context.read<MemoProvider>().loadMemos();
          }
        },
        tooltip: '新しいメモを作成',
        heroTag: "main_add_memo_button",
        child: const Icon(Icons.add),
      ),
    );
  }
}
