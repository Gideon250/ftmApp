class User {
  String? latitude;
  String? longtude;
  String? sId;
  String? name;
  String? email;
  String? password;
  String? address;
  String? status;
  String? type;
  int? iV;

  User(
      {this.latitude,
      this.longtude,
      this.sId,
      this.name,
      this.email,
      this.password,
      this.address,
      this.status,
      this.type,
      this.iV});

  User.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longtude = json['longtude'];
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    address = json['address'];
    status = json['status'];
    type = json['type'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['latitude'] = this.latitude;
    data['longtude'] = this.longtude;
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['password'] = this.password;
    data['address'] = this.address;
    data['status'] = this.status;
    data['type'] = this.type;
    data['__v'] = this.iV;
    return data;
  }
}
