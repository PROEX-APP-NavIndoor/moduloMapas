class UserModel {
  late String name;
  late String email;
  late String password;
  late String permission;
  late String id;
  late String token;

  UserModel(
      {this.email = "",
      this.password = "",
      this.name = "",
      this.permission = "NORMAL",
      this.id = "",
      this.token = ""});

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json["name"].toString();
    email = json["email"].toString();
    password = json["password"].toString();
    permission = json["permission"].toString();
    id = json["id"] ?? '';
    token = json["token"] ?? '';
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};
    json["name"] = name;
    json["email"] = email;
    json["password"] = password;
    json["role"] = permission;
    return json;
  }
}
