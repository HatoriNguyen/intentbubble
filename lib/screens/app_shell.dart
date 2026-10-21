import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../models/student_intent.dart';
import '../services/api_client.dart';

class AppShell extends StatefulWidget {
  final ApiClient api;
  final Future<void> Function() onLogout;
  const AppShell({super.key, required this.api, required this.onLogout});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  int index = 0;
  List<StudentIntent> intents = sampleIntents;
  List<StudentIntent> ownIntents = [];
  Map<String, dynamic>? profile;
  bool loading = false;
  String? error;
  int loadVersion = 0;
  final connected = <String>{};
  final unlockedZalo = <String>{};

  final messages = <Map<String, String>>[
    {'name': 'Trần Thảo Vy', 'message': 'Chào bạn, Intent Bubble vừa match tụi mình môn SWP391 nè!', 'time': '10:42'},
    {'name': 'Phạm Minh Tuấn', 'message': 'Tối nay 20:00 ôn RSA trên Zalo nhé bạn.', 'time': 'Hôm qua'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    loadVersion++;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(refresh());
  }

  Future<void> refresh() async {
    final version = ++loadVersion;
    setState(() { loading = true; error = null; });
    try {
      final values = await Future.wait<Object>([
        widget.api.profile(),
        widget.api.requests(),
        widget.api.requests(mine: true),
      ]);
      if (!mounted || version != loadVersion) return;
      setState(() {
        profile = values[0] as Map<String, dynamic>;
        final fetched = values[1] as List<StudentIntent>;
        intents = fetched.isNotEmpty ? fetched : sampleIntents;
        ownIntents = values[2] as List<StudentIntent>;
      });
    } catch (_) {
      // Offline fallback: keep local sample data
      if (mounted && version == loadVersion) {
        setState(() {
          profile ??= {
            'FullName': 'Lê Hữu Minh',
            'Email': 'minhlhse180999@fpt.edu.vn',
            'ZaloPhone': '0909 888 999',
            'Major': 'Kỹ thuật phần mềm (SE) • K18',
            'Bio': 'Backend Developer đam mê xây dựng hệ thống phân tán.',
          };
          if (intents.isEmpty) intents = sampleIntents;
        });
      }
    } finally {
      if (mounted && version == loadVersion) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DiscoverScreen(
        intents: intents,
        connected: connected,
        unlockedZalo: unlockedZalo,
        onConnect: connect,
      ),
      CreateIntentScreen(
        profile: profile,
        onCreate: createIntent,
      ),
      MessagesScreen(messages: messages),
      ProfileScreen(
        connectedCount: connected.length,
        profile: profile,
        ownIntents: ownIntents,
        onEdit: editProfile,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (loading) const LinearProgressIndicator(minHeight: 2),
            Expanded(child: IndexedStack(index: index, children: pages)),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) {
          setState(() => index = v);
          if (v == 0 || v == 3) unawaited(refresh());
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Khám phá',
          ),
          NavigationDestination(
            icon: Icon(Icons.bubble_chart_outlined),
            selectedIcon: Icon(Icons.bubble_chart),
            label: 'Tạo Bubble',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Zalo / Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }

  void connect(StudentIntent item) {
    setState(() {
      connected.add(item.id.isNotEmpty ? item.id : item.name);
      unlockedZalo.add(item.id.isNotEmpty ? item.id : item.name);
    });
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF237A3B), size: 28),
                const SizedBox(width: 10),
                const Text(
                  'Ghép nối thành công!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Đã kết nối với ${item.name} (${item.major})',
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone_android, color: Color(0xFF1B5E20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Số điện thoại Zalo:', style: TextStyle(fontSize: 11, color: Colors.black54)),
                        Text(
                          item.zaloPhone.isNotEmpty ? item.zaloPhone : '0909 123 456',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1B5E20)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: item.zaloPhone));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã sao chép số Zalo!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0068FF), // Zalo Blue
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.chat),
                label: const Text('Mở trò chuyện Zalo ngay', style: TextStyle(fontWeight: FontWeight.w700)),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> createIntent(Map<String, dynamic> fields) async {
    final newIntent = StudentIntent(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      name: fields['name'] ?? profile?['FullName'] ?? 'Lê Hữu Minh',
      major: profile?['Major'] ?? 'Kỹ thuật phần mềm (SE)',
      title: fields['title'],
      description: fields['description'],
      tags: List<String>.from(fields['tags'] ?? []),
      schedule: fields['schedule'] ?? 'Chưa cập nhật',
      match: 95,
      zaloPhone: fields['zaloPhone'] ?? profile?['ZaloPhone'] ?? '0909 888 999',
      isPersistentBubble: fields['isPersistentBubble'] ?? true,
      matchRationale: 'Lưu trên Bubble 24/7 và AI đang quét nền tìm đối tác phù hợp.',
    );

    setState(() {
      intents = [newIntent, ...intents];
      ownIntents = [newIntent, ...ownIntents];
      index = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🫧 Đã lưu ý định lên Bubble! AI sẽ tự động tìm kiếm đến khi match.')),
    );
  }

  Future<void> editProfile() async {
    final updated = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditProfileDialog(api: widget.api, profile: profile ?? {}),
    );
    if (updated != null && mounted) {
      setState(() => profile = updated);
    }
  }
}

class DiscoverScreen extends StatefulWidget {
  final List<StudentIntent> intents;
  final Set<String> connected;
  final Set<String> unlockedZalo;
  final ValueChanged<StudentIntent> onConnect;

  const DiscoverScreen({
    super.key,
    required this.intents,
    required this.connected,
    required this.unlockedZalo,
    required this.onConnect,
  });

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.intents.where((x) =>
      '${x.title} ${x.description} ${x.tags.join(' ')} ${x.major}'
          .toLowerCase()
          .contains(query.toLowerCase())).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6750A4), Color(0xFF0068FF)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.bubble_chart, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('INTENT BUBBLE', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                          Text('Tự động lưu ý định & Ghép nối Zalo 24/7', style: TextStyle(color: Colors.black54, fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFA5D6A7)),
                      ),
                      child: const Text('@fpt.edu.vn ✓', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32))),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Core Objective Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF281E5D), Color(0xFF4A378B)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Color(0x226750A4), blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🫧 Persistent Intent Bubble',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Ý định của bạn được lưu trữ liên tục 24/7 cho đến khi AI tự động tìm thấy và match đối tác phù hợp qua Zalo.',
                              style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 32),
                    ],
                  ),
                ),

                const SizedBox(height: 18),
                TextField(
                  onChanged: (v) => setState(() => query = v),
                  decoration: InputDecoration(
                    hintText: 'Tìm môn học (SWP391), kỹ năng, đồ án...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    const Text('Gợi ý ghép nối AI', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    Text('${filtered.length} nhu cầu', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (filtered.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('Không tìm thấy ý định phù hợp.')),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => IntentCard(
                  item: filtered[i],
                  connected: widget.connected.contains(filtered[i].id.isNotEmpty ? filtered[i].id : filtered[i].name),
                  hasUnlockedZalo: widget.unlockedZalo.contains(filtered[i].id.isNotEmpty ? filtered[i].id : filtered[i].name),
                  onConnect: () => widget.onConnect(filtered[i]),
                ),
                childCount: filtered.length,
              ),
            ),
          ),
      ],
    );
  }
}

class IntentCard extends StatelessWidget {
  final StudentIntent item;
  final bool connected;
  final bool hasUnlockedZalo;
  final VoidCallback onConnect;

  const IntentCard({
    super.key,
    required this.item,
    required this.connected,
    required this.hasUnlockedZalo,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFECE8F4)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFEDE7F6),
                child: Text(
                  item.name.isNotEmpty ? item.name[0] : 'S',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF512DA8)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    Text(item.major, style: const TextStyle(color: Colors.black54, fontSize: 11)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${item.match}% phù hợp',
                  style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(item.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(item.description, style: const TextStyle(fontSize: 13, height: 1.35, color: Colors.black87)),
          const SizedBox(height: 10),

          // Explainable AI Box
          if (item.matchRationale.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.psychology, size: 16, color: Color(0xFF6A1B9A)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'AI: ${item.matchRationale}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF4A148C), fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: item.tags.map((t) => Chip(
              label: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              visualDensity: VisualDensity.compact,
              side: BorderSide.none,
              backgroundColor: const Color(0xFFEDE7F6),
            )).toList(),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.access_time, size: 15, color: Colors.black54),
              const SizedBox(width: 4),
              Expanded(
                child: Text(item.schedule, style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ),
              if (connected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0068FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.chat, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(item.zaloPhone.isNotEmpty ? item.zaloPhone : 'Zalo: 0909...', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                )
              else
                FilledButton.tonal(
                  onPressed: onConnect,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                  ),
                  child: const Text('Ghép & Lấy SĐT Zalo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class CreateIntentScreen extends StatefulWidget {
  final Map<String, dynamic>? profile;
  final Future<void> Function(Map<String, dynamic>) onCreate;
  const CreateIntentScreen({super.key, required this.profile, required this.onCreate});
  @override
  State<CreateIntentScreen> createState() => _CreateIntentScreenState();
}

class _CreateIntentScreenState extends State<CreateIntentScreen> {
  final form = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final zaloCtrl = TextEditingController();
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final tagsCtrl = TextEditingController();
  bool isPersistent = true;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    nameCtrl.text = widget.profile?['FullName'] ?? 'Lê Hữu Minh';
    zaloCtrl.text = widget.profile?['ZaloPhone'] ?? '0909 888 999';
  }

  void applyTemplate(String course, String title, String desc, String tags) {
    setState(() {
      titleCtrl.text = title;
      descCtrl.text = desc;
      tagsCtrl.text = tags;
    });
  }

  Future<void> submit() async {
    if (!form.currentState!.validate() || busy) return;
    setState(() => busy = true);
    try {
      await widget.onCreate({
        'name': nameCtrl.text.trim(),
        'zaloPhone': zaloCtrl.text.trim(),
        'title': titleCtrl.text.trim(),
        'description': descCtrl.text.trim(),
        'tags': tagsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
        'schedule': 'Slot chiều T3/T5',
        'isPersistentBubble': isPersistent,
      });
      titleCtrl.clear();
      descCtrl.clear();
      tagsCtrl.clear();
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    zaloCtrl.dispose();
    titleCtrl.dispose();
    descCtrl.dispose();
    tagsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Text('Tạo Intent Bubble', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
      const SizedBox(height: 4),
      const Text('Ý định sẽ được lưu trên Bubble đến khi AI match thành công.', style: TextStyle(color: Colors.black54, fontSize: 12)),
      const SizedBox(height: 18),

      // Quick template chips
      const Text('Mẫu nhanh môn học:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ActionChip(
              label: const Text('+ SWP391 Frontend/UI'),
              onPressed: () => applyTemplate(
                'SWP391',
                'Tìm đồng đội ReactJS & Figma đồ án SWP391',
                'Nhóm mình cần 1 bạn phụ trách Frontend ReactJS và thiết kế Figma UI/UX cho đồ án tốt nghiệp SWP391.',
                'SWP391, ReactJS, Figma, UI/UX',
              ),
            ),
            const SizedBox(width: 8),
            ActionChip(
              label: const Text('+ CRY303C Ôn thi RSA'),
              onPressed: () => applyTemplate(
                'CRY303C',
                'Ôn tập RSA & Cryptography tối nay',
                'Cần bạn cùng giải bài tập Public Key Cryptography và Diffie-Hellman môn CRY303C.',
                'CRY303C, RSA, Security, Crypto',
              ),
            ),
            const SizedBox(width: 8),
            ActionChip(
              label: const Text('+ EXE101 Pitch Deck'),
              onPressed: () => applyTemplate(
                'EXE101',
                'Tìm bạn mảng Marketing làm Pitch Deck EXE101',
                'Cần một bạn khối ngành Kinh tế/Marketing đồng hành hoàn thiện tài chính và slide thuyết trình.',
                'EXE101, Marketing, Pitch, Business',
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),

      Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Họ và tên của bạn', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(hintText: 'Họ tên'),
                        validator: (v) => v?.trim().isEmpty == true ? 'Nhập họ tên' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Số điện thoại Zalo', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: zaloCtrl,
                        decoration: const InputDecoration(hintText: '09xx xxx xxx'),
                        validator: (v) => v?.trim().isEmpty == true ? 'Nhập SĐT Zalo' : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Tiêu đề nhu cầu', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 6),
            TextFormField(
              controller: titleCtrl,
              decoration: const InputDecoration(hintText: 'VD: Tìm đồng đội làm đồ án tốt nghiệp SWP391'),
              validator: (v) => v?.trim().isEmpty == true ? 'Nhập tiêu đề' : null,
            ),
            const SizedBox(height: 16),
            const Text('Mô tả chi tiết ý định', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 6),
            TextFormField(
              controller: descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Mô tả kỹ năng cần tìm, mục tiêu điểm số, ca học rảnh...'),
              validator: (v) => v?.trim().isEmpty == true ? 'Nhập mô tả' : null,
            ),
            const SizedBox(height: 16),
            const Text('Kỹ năng / Môn học (cách nhau bằng dấu phẩy)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 6),
            TextFormField(
              controller: tagsCtrl,
              decoration: const InputDecoration(hintText: 'ReactJS, Figma, SWP391'),
            ),
            const SizedBox(height: 16),

            // Persistent Bubble Switch
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE7F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bubble_chart, color: Color(0xFF512DA8)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lưu trữ trên Persistent Bubble', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                        Text('Giữ ý định và để AI quét nền 24/7 đến khi match.', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      ],
                    ),
                  ),
                  Switch(
                    value: isPersistent,
                    onChanged: (v) => setState(() => isPersistent = v),
                    activeColor: const Color(0xFF512DA8),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: busy ? null : submit,
                icon: const Icon(Icons.rocket_launch),
                label: Text(busy ? 'Đang lưu Bubble...' : 'Treo ý định lên Bubble & Tìm kiếm'),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class MessagesScreen extends StatelessWidget {
  final List<Map<String, String>> messages;
  const MessagesScreen({super.key, required this.messages});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Text('Hộp thư kết nối', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
      const SizedBox(height: 4),
      const Text('Các bạn đã match qua Zalo và hệ thống', style: TextStyle(color: Colors.black54, fontSize: 12)),
      const SizedBox(height: 18),
      ...messages.map((m) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF0068FF),
            child: Text(m['name']![0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
          title: Text(m['name']!, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(m['message']!, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Text(m['time']!, style: const TextStyle(fontSize: 11, color: Colors.black45)),
        ),
      )),
    ],
  );
}

class ProfileScreen extends StatelessWidget {
  final int connectedCount;
  final Map<String, dynamic>? profile;
  final List<StudentIntent> ownIntents;
  final Future<void> Function() onEdit, onLogout;

  const ProfileScreen({
    super.key,
    required this.connectedCount,
    required this.profile,
    required this.ownIntents,
    required this.onEdit,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Text('Hồ sơ sinh viên', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFF6750A4),
              child: Icon(Icons.person, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              profile?['FullName'] as String? ?? 'Lê Hữu Minh',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              profile?['Email'] as String? ?? 'minhlhse180999@fpt.edu.vn',
              style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Số Zalo: ${profile?['ZaloPhone'] ?? '0909 888 999'}',
              style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              profile?['Major'] as String? ?? 'Kỹ thuật phần mềm (SE) • K18',
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(child: statCard('Kết nối Zalo', '$connectedCount')),
          const SizedBox(width: 12),
          Expanded(child: statCard('Bubble đang treo', '${ownIntents.length + 1}')),
        ],
      ),
      const SizedBox(height: 16),
      Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: const Text('Chỉnh sửa thông tin & SĐT Zalo'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onEdit,
        ),
      ),
      Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        child: ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          onTap: onLogout,
        ),
      ),
    ],
  );

  Widget statCard(String label, String value) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFECE8F4)),
    ),
    child: Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF6750A4))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 11)),
      ],
    ),
  );
}

class EditProfileDialog extends StatefulWidget {
  final ApiClient api;
  final Map<String, dynamic> profile;
  const EditProfileDialog({super.key, required this.api, required this.profile});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name, zalo, major, bio;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.profile['FullName'] as String? ?? 'Lê Hữu Minh');
    zalo = TextEditingController(text: widget.profile['ZaloPhone'] as String? ?? '0909 888 999');
    major = TextEditingController(text: widget.profile['Major'] as String? ?? 'Kỹ thuật phần mềm (SE) • K18');
    bio = TextEditingController(text: widget.profile['Bio'] as String? ?? '');
  }

  @override
  void dispose() {
    name.dispose();
    zalo.dispose();
    major.dispose();
    bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Cập nhật hồ sơ & Zalo'),
    content: Form(
      key: form,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Họ và tên')),
            const SizedBox(height: 12),
            TextFormField(controller: zalo, decoration: const InputDecoration(labelText: 'Số điện thoại Zalo')),
            const SizedBox(height: 12),
            TextFormField(controller: major, decoration: const InputDecoration(labelText: 'Chuyên ngành')),
            const SizedBox(height: 12),
            TextFormField(controller: bio, maxLines: 2, decoration: const InputDecoration(labelText: 'Giới thiệu ngắn')),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
      FilledButton(
        onPressed: () {
          Navigator.pop(context, {
            ...widget.profile,
            'FullName': name.text.trim(),
            'ZaloPhone': zalo.text.trim(),
            'Major': major.text.trim(),
            'Bio': bio.text.trim(),
          });
        },
        child: const Text('Lưu thay đổi'),
      ),
    ],
  );
}
