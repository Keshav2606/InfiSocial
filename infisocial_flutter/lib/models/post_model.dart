enum MediaType { image, video }

class Post {
  const Post({
    this.postId = '',
    this.caption = '',
    this.mediaType = 'image',
    required this.mediaUrl,
    required this.postedBy,
  });

  final String postId;
  final String caption;
  final String mediaType;
  final String mediaUrl;
  final String postedBy;
}
