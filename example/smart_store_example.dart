import 'package:flutter/material.dart';
import 'package:smart_store/smart_store.dart';

/// 👤 Example user model
class User {
final String name;
final int age;

User({required this.name, required this.age});

factory User.fromJson(Map<String, dynamic> json) =>
User(name: json['name'], age: json['age']);

Map<String, dynamic> toJson() => {'name': name, 'age': age};
}

void main() async {
WidgetsFlutterBinding.ensureInitialized();

// ✅ 1) Initialize the store
await Store.init();

// ✅ 2) Register custom models (only once)
Store.register<User>(User.fromJson);

// ✅ 3) Save a single custom object
Store.save("user", User(name: "Ali", age: 30));

// ✅ 4) Get the custom object (no await needed)
final user = Store.get("user");
if (user != null) {
print("👤 User: ${user.name}, Age: ${user.age}");
}

// ✅ 5) Save a list of custom objects
final userList = [
User(name: "Ali", age: 25),
User(name: "Sara", age: 22),
User(name: "Youssef", age: 30),
];
Store.saveList("userList", userList);

// ✅ 6) Get the list of custom objects
final users = Store.getList<User>("userList");
print("📋 List of users:");
for (var u in users) {
print("- ${u.name}, Age: ${u.age}");
}

// ✅ 7) Save primitive values (String, int, bool, etc.)
Store.save("token", "abc123token");
Store.save("isLoggedIn", true);

// ✅ 8) Get primitive values
final token = Store.get<String>("token");
final isLoggedIn = Store.get<bool>("isLoggedIn");
print("🔐 Token: $token");
print("✅ Is Logged In: $isLoggedIn");

// ✅ 9) Save a list of primitive values
final messages = ["Hello", "Welcome", "Goodbye"];
Store.saveList("messages", messages);

// ✅ 10) Get a list of primitives
final loadedMessages = Store.getList<String>("messages");
print("📨 Messages:");
for (var msg in loadedMessages) {
print("- $msg");
}

// ✅ 11) Check if a key exists
if (Store.contains("user")) {
print("🔍 Key 'user' exists in cache");
}

// ✅ 12) Delete a single key
Store.delete("token");

// ✅ 13) Clear all stored data
// Store.clear(); // Uncomment to delete all saved data
}

