class PostImage {
  final int id;
  final String imagePath;
  final int position;

  PostImage({required this.id, required this.imagePath, required this.position});
  factory PostImage.fromJson(Map<String, dynamic> json){
    return PostImage(
      id: json['id'],
      imagePath: json['image_path'],
      position: json['position']
    );
  }
}
