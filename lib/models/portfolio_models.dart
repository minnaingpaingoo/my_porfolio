class StatItem {
  final String value;
  final String label;

  const StatItem({
    this.value = '',
    this.label = '',
  });

  Map<String, dynamic> toMap() => {
        'value': value,
        'label': label,
      };

  factory StatItem.fromMap(Map<String, dynamic> map) {
    return StatItem(
      value: (map['value'] ?? '').toString(),
      label: (map['label'] ?? '').toString(),
    );
  }
}

class ProfileData {
  final String fullName;
  final String greeting;
  final String roleTitle;
  final String storybookSubtitle;
  final String bio;
  final String availabilityText;
  final bool isAvailable;
  final String avatarImage;
  final String resumeUrl;
  final String email;
  final String phone;
  final String location;
  final String footerText;
  final String selectedTemplate; // 'storybook', 'bento', or 'minimal'
  final List<StatItem> stats;
  final Map<String, String> snsLinks;

  const ProfileData({
    this.fullName = '',
    this.greeting = '',
    this.roleTitle = '',
    this.storybookSubtitle = '',
    this.bio = '',
    this.availabilityText = '',
    this.isAvailable = false,
    this.avatarImage = '',
    this.resumeUrl = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.footerText = '',
    this.selectedTemplate = 'storybook',
    this.stats = const [],
    this.snsLinks = const {},
  });

  ProfileData copyWith({
    String? fullName,
    String? greeting,
    String? roleTitle,
    String? storybookSubtitle,
    String? bio,
    String? availabilityText,
    bool? isAvailable,
    String? avatarImage,
    String? resumeUrl,
    String? email,
    String? phone,
    String? location,
    String? footerText,
    String? selectedTemplate,
    List<StatItem>? stats,
    Map<String, String>? snsLinks,
  }) {
    return ProfileData(
      fullName: fullName ?? this.fullName,
      greeting: greeting ?? this.greeting,
      roleTitle: roleTitle ?? this.roleTitle,
      storybookSubtitle: storybookSubtitle ?? this.storybookSubtitle,
      bio: bio ?? this.bio,
      availabilityText: availabilityText ?? this.availabilityText,
      isAvailable: isAvailable ?? this.isAvailable,
      avatarImage: avatarImage ?? this.avatarImage,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      footerText: footerText ?? this.footerText,
      selectedTemplate: selectedTemplate ?? this.selectedTemplate,
      stats: stats ?? this.stats,
      snsLinks: snsLinks ?? this.snsLinks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'greeting': greeting,
      'roleTitle': roleTitle,
      'storybookSubtitle': storybookSubtitle,
      'bio': bio,
      'availabilityText': availabilityText,
      'isAvailable': isAvailable,
      'avatarImage': avatarImage,
      'resumeUrl': resumeUrl,
      'email': email,
      'phone': phone,
      'location': location,
      'footerText': footerText,
      'selectedTemplate': selectedTemplate,
      'stats': stats.map((e) => e.toMap()).toList(),
      'snsLinks': snsLinks,
    };
  }

  factory ProfileData.fromMap(Map<String, dynamic> map) {
    final rawStats = map['stats'];
    final parsedStats = <StatItem>[];
    if (rawStats is List) {
      for (final item in rawStats) {
        if (item is Map) {
          parsedStats.add(StatItem.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }

    final rawSns = map['snsLinks'];
    final parsedSns = <String, String>{};
    if (rawSns is Map) {
      rawSns.forEach((key, value) {
        parsedSns[key.toString()] = (value ?? '').toString();
      });
    }

    return ProfileData(
      fullName: (map['fullName'] ?? '').toString(),
      greeting: (map['greeting'] ?? '').toString(),
      roleTitle: (map['roleTitle'] ?? '').toString(),
      storybookSubtitle: (map['storybookSubtitle'] ?? '').toString(),
      bio: (map['bio'] ?? '').toString(),
      availabilityText: (map['availabilityText'] ?? '').toString(),
      isAvailable:
          map['isAvailable'] is bool ? map['isAvailable'] as bool : false,
      avatarImage: (map['avatarImage'] ?? '').toString(),
      resumeUrl: (map['resumeUrl'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      location: (map['location'] ?? '').toString(),
      footerText: (map['footerText'] ?? '').toString(),
      selectedTemplate:
          (map['selectedTemplate'] ?? 'storybook').toString().trim().isEmpty
              ? 'storybook'
              : (map['selectedTemplate'] ?? 'storybook').toString().trim(),
      stats: parsedStats,
      snsLinks: parsedSns,
    );
  }
}

class ExperienceItem {
  final String id;
  final String role;
  final String company;
  final String period;
  final bool isCurrent;
  final String description;
  final List<String> highlights;
  final int order;

  const ExperienceItem({
    this.id = '',
    this.role = '',
    this.company = '',
    this.period = '',
    this.isCurrent = false,
    this.description = '',
    this.highlights = const [],
    this.order = 0,
  });

  ExperienceItem copyWith({
    String? id,
    String? role,
    String? company,
    String? period,
    bool? isCurrent,
    String? description,
    List<String>? highlights,
    int? order,
  }) {
    return ExperienceItem(
      id: id ?? this.id,
      role: role ?? this.role,
      company: company ?? this.company,
      period: period ?? this.period,
      isCurrent: isCurrent ?? this.isCurrent,
      description: description ?? this.description,
      highlights: highlights ?? this.highlights,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'company': company,
      'period': period,
      'isCurrent': isCurrent,
      'description': description,
      'highlights': highlights,
      'order': order,
    };
  }

  factory ExperienceItem.fromMap(Map<String, dynamic> map, {String? docId}) {
    final rawHighlights = map['highlights'];
    final parsedHighlights = <String>[];
    if (rawHighlights is List) {
      for (final h in rawHighlights) {
        if (h != null && h.toString().trim().isNotEmpty) {
          parsedHighlights.add(h.toString().trim());
        }
      }
    }
    return ExperienceItem(
      id: docId ?? (map['id'] ?? '').toString(),
      role: (map['role'] ?? '').toString(),
      company: (map['company'] ?? '').toString(),
      period: (map['period'] ?? '').toString(),
      isCurrent: map['isCurrent'] == true,
      description: (map['description'] ?? '').toString(),
      highlights: parsedHighlights,
      order: (map['order'] is num) ? (map['order'] as num).toInt() : 0,
    );
  }
}

class EducationItem {
  final String id;
  final String degree;
  final String institution;
  final String period;
  final String honors;
  final List<String> coursework;
  final int order;

  const EducationItem({
    this.id = '',
    this.degree = '',
    this.institution = '',
    this.period = '',
    this.honors = '',
    this.coursework = const [],
    this.order = 0,
  });

  EducationItem copyWith({
    String? id,
    String? degree,
    String? institution,
    String? period,
    String? honors,
    List<String>? coursework,
    int? order,
  }) {
    return EducationItem(
      id: id ?? this.id,
      degree: degree ?? this.degree,
      institution: institution ?? this.institution,
      period: period ?? this.period,
      honors: honors ?? this.honors,
      coursework: coursework ?? this.coursework,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'degree': degree,
      'institution': institution,
      'period': period,
      'honors': honors,
      'coursework': coursework,
      'order': order,
    };
  }

  factory EducationItem.fromMap(Map<String, dynamic> map, {String? docId}) {
    final rawCourses = map['coursework'];
    final parsedCourses = <String>[];
    if (rawCourses is List) {
      for (final c in rawCourses) {
        if (c != null && c.toString().trim().isNotEmpty) {
          parsedCourses.add(c.toString().trim());
        }
      }
    }
    return EducationItem(
      id: docId ?? (map['id'] ?? '').toString(),
      degree: (map['degree'] ?? '').toString(),
      institution: (map['institution'] ?? '').toString(),
      period: (map['period'] ?? '').toString(),
      honors: (map['honors'] ?? '').toString(),
      coursework: parsedCourses,
      order: (map['order'] is num) ? (map['order'] as num).toInt() : 0,
    );
  }
}

class PlatformItem {
  final String id;
  final String title;
  final String subtitle;
  final String img;
  final int order;

  const PlatformItem({
    this.id = '',
    this.title = '',
    this.subtitle = '',
    this.img = '',
    this.order = 0,
  });

  PlatformItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? img,
    int? order,
  }) {
    return PlatformItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      img: img ?? this.img,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'img': img,
      'order': order,
    };
  }

  factory PlatformItem.fromMap(Map<String, dynamic> map, {String? docId}) {
    return PlatformItem(
      id: docId ?? (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      subtitle: (map['subtitle'] ?? '').toString(),
      img: (map['img'] ?? '').toString(),
      order: (map['order'] is num) ? (map['order'] as num).toInt() : 0,
    );
  }
}

class SkillItem {
  final String id;
  final String title;
  final String img;
  final String category;
  final int order;

  const SkillItem({
    this.id = '',
    this.title = '',
    this.img = '',
    this.category = '',
    this.order = 0,
  });

  SkillItem copyWith({
    String? id,
    String? title,
    String? img,
    String? category,
    int? order,
  }) {
    return SkillItem(
      id: id ?? this.id,
      title: title ?? this.title,
      img: img ?? this.img,
      category: category ?? this.category,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'img': img,
      'category': category,
      'order': order,
    };
  }

  factory SkillItem.fromMap(Map<String, dynamic> map, {String? docId}) {
    return SkillItem(
      id: docId ?? (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      img: (map['img'] ?? '').toString(),
      category: (map['category'] ?? '').toString(),
      order: (map['order'] is num) ? (map['order'] as num).toInt() : 0,
    );
  }
}

class ContactMessage {
  final String id;
  final String name;
  final String email;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  const ContactMessage({
    this.id = '',
    this.name = '',
    this.email = '',
    this.message = '',
    required this.createdAt,
    this.isRead = false,
  });

  ContactMessage copyWith({
    String? id,
    String? name,
    String? email,
    String? message,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return ContactMessage(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory ContactMessage.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parsedDate = DateTime.now();
    final rawDate = map['createdAt'];
    if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    }
    return ContactMessage(
      id: docId ?? (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      message: (map['message'] ?? '').toString(),
      createdAt: parsedDate,
      isRead: map['isRead'] == true,
    );
  }
}
