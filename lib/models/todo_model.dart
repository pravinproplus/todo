class ToDoModel {
  int? id;
  String? title;
  String? description;
  bool? status;
  String? location;
  ToDoModel(
      {this.id, this.title, this.description, this.status, this.location});

  toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "status": status,
      "location": location
    };
  }

  fromJson(json) {
    return ToDoModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        status: json['status'],
        location: json['location']);
  }
}
