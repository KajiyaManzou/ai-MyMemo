import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/memo_provider.dart';
import 'screens/memo_edit_screen.dart';
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
      ],
      child: MaterialApp(
      title: 'ai-MyMemo',
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemoProvider>().loadMemos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ai-MyMemo'),
      ),
      body: Consumer<MemoProvider>(
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
