class User {
  final int? id;
  final String name;
  final String address;
  final String password;

  User({this.id, required this.name, required this.address, required this.password});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'password': password,
    };
  }
}