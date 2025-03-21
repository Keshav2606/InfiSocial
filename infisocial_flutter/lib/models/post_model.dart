enum MediaType { image, video }

class PostModel {
  final String postId;
  final String content;
  final String mediaType;
  final String mediaUrl;
  final List<String> likes;
  final List<String> comments;
  final String postedBy;
  final String postOwnerUsername;
  final String? postOwnerAvatar;

  const PostModel({
    this.postId = '',
    this.content = '',
    this.mediaType = 'image',
    required this.likes,
    required this.comments,
    required this.mediaUrl,
    required this.postedBy,
    required this.postOwnerUsername,
    this.postOwnerAvatar,
  });

  // Factory method to create a Post from a Map (useful for Firebase or API responses)
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      postId: json['_id'] ?? '',
      content: json['content'] ?? '',
      mediaType: json['mediaType'] ?? 'image',
      mediaUrl: json['mediaUrl'] ?? '',
      likes: List<String>.from(json['likes']),
      comments: List<String>.from(json['comments']),
      postedBy: json['postedBy']['_id'] ?? '',
      postOwnerUsername: json['postedBy']['username'] ?? 'username',
      postOwnerAvatar: json['postedBy']['avatarUrl'],
    );
  }

  // Convert a Post object to a Map (useful for Firestore or API requests)
  Map<String, dynamic> toJson() {
    return {
      '_id': postId,
      'content': content,
      'mediaType': mediaType,
      'mediaUrl': mediaUrl,
      'likes': likes,
      'comments': comments,
      'postedBy': postedBy,
    };
  }
}
