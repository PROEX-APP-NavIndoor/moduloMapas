class OrganizationModel {
  late String id;
  late String name;
  late String description;
  late String cep;
  late String state;
  late String city;
  late String neighborhood;
  late String street;
  late String number;

  OrganizationModel();

  OrganizationModel.fromJson(Map<String, dynamic> json) {
    id = json["id"] ?? "";
    name = json["name"];
    description = json["description"];
    cep = json["cep"];
    state = json["state"];
    city = json["city"];
    neighborhood = json["neighborhood"];
    street = json["street"];
    number = json["number"];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = <String, dynamic>{};
    json["name"] = name;
    json["description"] = description;
    json["cep"] = cep;
    json["state"] = state;
    json["city"] = city;
    json["neighborhood"] = neighborhood;
    json["street"] = street;
    json["number"] = number;
    return json;
  }
}
