class AppUser {
  final String uid;
  final String email;
  final String name;
  final String height;
  final double weight;
  final int age;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.height,
    required this.weight,
    required this.age,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'height': height,
      'weight': weight,
      'age': age,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      height: map['height'] ?? '',
      weight: double.parse(map['weight'] ?? ''),
      age: int.parse(map['age'] ?? ''),
    );
  }
}
