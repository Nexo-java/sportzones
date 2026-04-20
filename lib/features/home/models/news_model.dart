class NewsModel {
  NewsModel({
    required this.title,
    required this.category,
    required this.date,
    required this.description,
    required this.imageUrl,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdBy = (createdBy == null || createdBy.trim().isEmpty)
           ? 'Admin'
           : createdBy.trim(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  final String title;
  final String category;
  final String date;
  final String description;
  final String imageUrl;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
}
