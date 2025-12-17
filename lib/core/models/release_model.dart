class Release {
  final String id;
  final String title;
  final String coverImage;
  final List<SubModule> subModules;

  Release({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.subModules,
  });

  factory Release.fromJson(Map<String, dynamic> json) {
    return Release(
      id: json['release_id'] as String,
      title: json['title'] as String,
      coverImage: json['cover_image'] as String,
      subModules: (json['sub_modules'] as List<dynamic>)
          .map((e) => SubModule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'release_id': id,
      'title': title,
      'cover_image': coverImage,
      'sub_modules': subModules.map((e) => e.toJson()).toList(),
    };
  }
}

class SubModule {
  final String id;
  final String title;
  final String type; // 'chat_stream' or 'redacted_doc'
  final List<dynamic>? chatScript; // For chat_stream
  final String? content; // For redacted_doc
  final int xpReward;
  final List<String>? specificTags;

  SubModule({
    required this.id,
    required this.title,
    required this.type,
    this.chatScript,
    this.content,
    this.xpReward = 0,
    this.specificTags,
  });

  factory SubModule.fromJson(Map<String, dynamic> json) {
    return SubModule(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      chatScript: json['chat_script'] as List<dynamic>?,
      content: json['content'] as String?,
      xpReward: json['xp_reward'] as int? ?? 0,
      specificTags: (json['specific_tags'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'title': title,
      'type': type,
      'xp_reward': xpReward,
    };
    if (specificTags != null) {
      data['specific_tags'] = specificTags;
    }
    if (chatScript != null) {
      data['chat_script'] = chatScript;
    }
    if (content != null) {
      data['content'] = content;
    }
    return data;
  }
}
