class Album {
  final int id;
  final String title;
  final String artist;
  final double? price;

  Album(
      {required this.id,
      required this.title,
      required this.artist,
      this.price});

  Album.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        title = res["title"],
        artist = res["artist"],
        price = res["price"];

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title' : title,
      'artist' : artist,
      'price' : price
    };
  }
}