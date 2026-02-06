import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note {
  @HiveField(0)
  final String? title;

  @HiveField(1)
  final String? content;

  @HiveField(2)
  final String contentJson;

  @HiveField(3)
  final List<String>? tags;

  @HiveField(4)
  final DateTime dateCreated;

  @HiveField(5)
  DateTime dateModified;

  @HiveField(6)
  final String id;

  @HiveField(7)
  bool needsSync;

  @HiveField(8)
  bool isDeleted;

  Note({
    required this.id,
    required this.contentJson,
    required this.dateCreated,
    required this.dateModified,
    this.title,
    this.content,
    this.tags,
    this.needsSync = true,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'contentJson': contentJson,
      'tags': tags ?? [],
      'dateCreated': dateCreated,
      'dateModified': dateModified,
      'isDeleted': isDeleted,
    };
  }

  factory Note.fromMap(
    Map<String, dynamic>? map, {
    required String id,
  }) {
    final data = map ?? const <String, dynamic>{};

    return Note(
      id: id,
      title: data['title'] as String?,
      content: data['content'] as String?,
      contentJson: data['contentJson'] as String? ?? '',
      tags: (data['tags'] as List?)?.cast<String>(),
      dateCreated: data['dateCreated'],
      dateModified: data['dateModified'],
      isDeleted: data['isDeleted'] as bool? ?? false,
      needsSync: false,
    );
  }

  Note copyWith({
    String? title,
    String? content,
    String? contentJson,
    List<String>? tags,
    DateTime? dateModified,
    bool? needsSync,
    bool? isDeleted,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      contentJson: contentJson ?? this.contentJson,
      tags: tags ?? this.tags,
      dateCreated: dateCreated,
      dateModified: dateModified ?? DateTime.now(),
      needsSync: needsSync ?? this.needsSync,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
