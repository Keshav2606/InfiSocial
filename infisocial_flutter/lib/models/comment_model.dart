class CommentModel {
  final String id;
  final String postId;
  final String content;
  final String commentedBy;
  final String commentOwnerUsername;
  final String? commentOwnerAvatar;

  CommentModel({
    required this.id,
    required this.postId,
    required this.content,
    required this.commentedBy,
    required this.commentOwnerUsername,
    this.commentOwnerAvatar,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['_id'],
      postId: json['postId'],
      content: json['content'],
      commentedBy: json['userId']['_id'],
      commentOwnerUsername: json['userId']['username'],
      commentOwnerAvatar: json['userId']['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'postId': postId,
      'userId': commentedBy,
      'content': content,
    };
  }
}