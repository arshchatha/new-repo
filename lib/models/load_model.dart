class LoadModel {
  int? id;
  String title;
  String description;
  String postedBy;
  String type;

  LoadModel({
    this.id,
    required this.title,
    required this.description,
    required this.postedBy,
    required this.type,
  });

  factory LoadModel.fromMap(Map<String, dynamic> map) {
    return LoadModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      postedBy: map['postedBy'],
      type: map['type'],
    );
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'title': title,
      'description': description,
      'postedBy': postedBy,
      'type': type,
    };
    if (id != null) map['id'] = id;
    return map;
  }
}
