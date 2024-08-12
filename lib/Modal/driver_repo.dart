class Driver {
  final String name;
  final String email;
  final String gender;
  final String address;
  final String id;
  final String image;
  final String phone;

  Driver(
      {required this.name,
      required this.email,
      required this.gender,
      required this.address,
      required this.id,
      required this.image,
      required this.phone});

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
        name: map['name'],
        email: map['email'],
        gender: map['gender'],
        address: map['address'],
        id: map['id'],
        image: map['image'],
        phone: map['phone']);
  }
}
