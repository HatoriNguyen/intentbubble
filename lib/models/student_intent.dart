class StudentIntent {
  final String id, userId;
  final DateTime? createdAt;
  final String name, major, title, description, schedule;
  final String zaloPhone;
  final List<String> tags;
  final int match;
  final bool isPersistentBubble;
  final String matchRationale;

  const StudentIntent({
    this.id = '',
    this.userId = '',
    this.createdAt,
    required this.name,
    required this.major,
    required this.title,
    required this.description,
    required this.tags,
    required this.schedule,
    required this.match,
    this.zaloPhone = '',
    this.isPersistentBubble = true,
    this.matchRationale = '',
  });

  factory StudentIntent.fromJson(Map<String, dynamic> json) => StudentIntent(
    id: json['id']?.toString() ?? '',
    userId: json['userId']?.toString() ?? '',
    name: json['name'] as String? ?? 'Sinh viên',
    major: json['major'] as String? ?? 'Sinh viên FPTU',
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : <String>[],
    schedule: json['schedule'] as String? ?? 'Chưa cập nhật lịch',
    match: (json['match'] as num?)?.toInt() ?? 90,
    zaloPhone: json['zaloPhone'] as String? ?? '',
    isPersistentBubble: json['isPersistentBubble'] as bool? ?? true,
    matchRationale: json['matchRationale'] as String? ?? '',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'major': major,
    'title': title,
    'description': description,
    'tags': tags,
    'schedule': schedule,
    'match': match,
    'zaloPhone': zaloPhone,
    'isPersistentBubble': isPersistentBubble,
    'matchRationale': matchRationale,
    'createdAt': createdAt?.toIso8601String(),
  };
}

const sampleIntents = <StudentIntent>[
  StudentIntent(
    id: 'req_1',
    userId: 'u_vy',
    name: 'Trần Thảo Vy',
    major: 'Kỹ thuật phần mềm (SE) • K18',
    title: 'Tìm đồng đội Frontend ReactJS & UI/UX Figma',
    description: 'Nhóm mình cần 1 bạn chuyên Frontend ReactJS/Tailwind và thiết kế Figma UI/UX cho đồ án tốt nghiệp SWP391. Mục tiêu điểm 8.5+, làm việc nghiêm túc, không free-rider.',
    tags: ['SWP391', 'ReactJS', 'Figma', 'UI/UX'],
    schedule: 'Slot 3-4 (Chiều Thứ 3 / Thứ 5)',
    match: 94,
    zaloPhone: '0909 123 456',
    isPersistentBubble: true,
    matchRationale: '94% Cosine: Khớp trực tiếp môn SWP391. Bổ sung chéo kỹ năng Backend ↔ Frontend và chung ca học chiều.',
  ),
  StudentIntent(
    id: 'req_2',
    userId: 'u_tuan',
    name: 'Phạm Minh Tuấn',
    major: 'An toàn thông tin (IA) • K18',
    title: 'Ôn tập RSA & Public Key Cryptography tối nay',
    description: 'Có bạn nào học CRY303C muốn cùng nhau ôn tập khóa bất đối xứng RSA và giải bài tập thực hành tối nay từ 20:00 không?',
    tags: ['CRY303C', 'RSA', 'Diffie-Hellman', 'Security'],
    schedule: 'Online tối nay (20:00)',
    match: 92,
    zaloPhone: '0918 222 333',
    isPersistentBubble: true,
    matchRationale: '92% Ngữ nghĩa: AI tự động ánh xạ từ khóa "RSA" sang môn học CRY303C của Tuấn, cả hai cùng rảnh tối nay.',
  ),
  StudentIntent(
    id: 'req_3',
    userId: 'u_lan',
    name: 'Đỗ Thị Ngọc Lan',
    major: 'Digital Marketing • K18',
    title: 'Tìm nhóm kỹ thuật làm Slide Pitch & Tài chính EXE101',
    description: 'Sinh viên Marketing năm cuối tìm nhóm IT làm đồ án EXE101 để đồng hành mảng chiến lược GTM, nghiên cứu thị trường và thiết kế slide thuyết trình pitch deck.',
    tags: ['EXE101', 'Pitch Deck', 'Marketing', 'Financial Model'],
    schedule: 'Slot 1-2 (Sáng T2 / T4 / T6)',
    match: 91,
    zaloPhone: '0988 777 666',
    isPersistentBubble: true,
    matchRationale: '91% Bù trừ: Kết nối hoàn hảo giữa sinh viên IT làm MVP và sinh viên Kinh tế làm Pitch Deck & Mô hình tài chính.',
  ),
];
