class ProjectUtils {
  final String id;
  final String image;
  final String title;
  final String subtitle;
  final String detail;
  final String projectType;
  final String category;
  final List<String> techStack;
  final String? androidLink;
  final String? iosLink;
  final String? webLink;
  final String? githubLink;
  final int order;

  const ProjectUtils({
    this.id = '',
    this.image = '',
    this.title = '',
    this.subtitle = '',
    this.detail = '',
    this.projectType = '',
    this.category = '',
    this.techStack = const [],
    this.androidLink,
    this.iosLink,
    this.webLink,
    this.githubLink,
    this.order = 0,
  });

  ProjectUtils copyWith({
    String? id,
    String? image,
    String? title,
    String? subtitle,
    String? detail,
    String? projectType,
    String? category,
    List<String>? techStack,
    String? androidLink,
    String? iosLink,
    String? webLink,
    String? githubLink,
    int? order,
  }) {
    return ProjectUtils(
      id: id ?? this.id,
      image: image ?? this.image,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      detail: detail ?? this.detail,
      projectType: projectType ?? this.projectType,
      category: category ?? this.category,
      techStack: techStack ?? this.techStack,
      androidLink: androidLink ?? this.androidLink,
      iosLink: iosLink ?? this.iosLink,
      webLink: webLink ?? this.webLink,
      githubLink: githubLink ?? this.githubLink,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'title': title,
      'subtitle': subtitle,
      'detail': detail,
      'projectType': projectType,
      'category': category,
      'techStack': techStack,
      'androidLink': androidLink,
      'iosLink': iosLink,
      'webLink': webLink,
      'githubLink': githubLink,
      'order': order,
    };
  }

  factory ProjectUtils.fromMap(Map<String, dynamic> map, {String? docId}) {
    final rawTech = map['techStack'];
    final parsedTech = <String>[];
    if (rawTech is List) {
      for (final item in rawTech) {
        if (item != null && item.toString().trim().isNotEmpty) {
          parsedTech.add(item.toString().trim());
        }
      }
    }

    String? cleanLink(dynamic val) {
      if (val == null) return null;
      final str = val.toString().trim();
      return str.isEmpty ? null : str;
    }

    return ProjectUtils(
      id: docId ?? (map['id'] ?? '').toString(),
      image: (map['image'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      subtitle: (map['subtitle'] ?? '').toString(),
      detail: (map['detail'] ?? '').toString(),
      projectType: (map['projectType'] ?? '').toString(),
      category: (map['category'] ?? '').toString(),
      techStack: parsedTech,
      androidLink: cleanLink(map['androidLink']),
      iosLink: cleanLink(map['iosLink']),
      webLink: cleanLink(map['webLink']),
      githubLink: cleanLink(map['githubLink']),
      order: (map['order'] is num) ? (map['order'] as num).toInt() : 0,
    );
  }
}

List<ProjectUtils> workProjectUtils = [];
List<ProjectUtils> hobbyProjectUtils = [];
