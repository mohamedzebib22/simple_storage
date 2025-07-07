import 'package:smart_store/smart_store.dart';

class User {
  final String name;
  final int age;

  User({required this.name, required this.age});

  factory User.fromJson(Map<String, dynamic> json) =>
      User(name: json['name'], age: json['age']);

  Map<String, dynamic> toJson() => {'name': name, 'age': age};
}

void main()  {
  // 1️⃣ Register the model (once)
  Store.register<User>(User.fromJson);

  // 2️⃣ Save a single object
  Store.save("user", User(name: "Ali", age: 30));

  // 3️⃣ Get the object
  final user = Store.get<User>("user");
  print("👤 Single user: ${user?.name}, Age: ${user?.age}");

  // 4️⃣ Save list of users
  List<User> modelList = [
    User(name: 'Ali', age: 25),
    User(name: 'Sara', age: 22),
    User(name: 'Youssef', age: 30),
    User(name: 'Nada', age: 19),
  ];
  Store.save("userList", modelList);

  // 5️⃣ Get list of users
  final users =  Store.getList<User>("userList");
  print("📋 List of users:");
  for (var u in users) {
    print("- ${u.name}, Age: ${u.age}");
  }
}
