import 'package:simple_store/simple_store.dart';

class User {
  final String name;
  final int age;

  User({required this.name, required this.age});

  factory User.fromJson(Map<String, dynamic> json) =>
      User(name: json['name'], age: json['age']);

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
      };
}

void main() async {

  Store.register<User>(User.fromJson);

 
   Store.save("user", User(name: "Ali", age: 30));

 
  final user = await Store.get("user");
  print("Name: ${user.name}, Age: ${user.age}");
}
