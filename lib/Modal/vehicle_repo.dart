
class Vehicle {
  final String feat;
  final String id;
  final String modal;
  final int seat;

  Vehicle(
      {required this.feat,
      required this.id,
      required this.modal,
      required this.seat});

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
        feat: map['feat'],
        id: map['id'],
        modal: map['modal'],
        seat: map['seat']);
  }
}
