# smart_store
Flutter package for ultra-simple local data storage in key-value format - with zero boilerplate.  
Supports saving any type: `int`, `double`, `String`, `List`, `Map`, `Object`, `List<Object>`... all with just one line.  
Fully cross-platform: Android, iOS, Windows, macOS, Linux.

---
## Installation
```bash
flutter pub add simple_store
```
---
## Features
- Save any type: primitives, List, Map, Object, List<Object>
- Works on Android, iOS, Windows, macOS, Linux
- No need to open/close boxes or databases
- No async/await needed for get/save
- Automatic JSON (de)serialization
- In-memory caching for faster reads
- Store.init() loads the cache once
- Simple key-value usage
- Supports custom models & List<CustomModel>
---
## Getting Started
Initialization (Required)  
Call `Store.init()` once before accessing stored data (usually in `main()`):
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Store.init(); // Required before using get()
  Store.register<User>(User.fromJson); // Register custom model
  runApp(MyApp());
}
```
---
### Register your model (once in `main()`)
```dart
Store.register<User>(User.fromJson);
```
---
## Save & Get Examples
### int
```dart
Store.save("count", 5); // No await
final count = Store.get<int>("count");
```
---
### String
```dart
Store.save("username", "Mohamed");
final name = Store.get<String>("username");
```
---
### Object
```dart
Store.save("user", User(name: "Ali", age: 25));
final user = Store.get<User>("user");
```
---
### List<Object>
```dart
Store.save("users", [User(...), User(...)]);
// You must use getList to deserialize list:
final users = Store.getList<User>("users");
```
---
### Delete a specific key
```dart
Store.delete("username");
```
---
### Clear all data
```dart
Store.clear();
```
---
### Check if key exists
```dart
final hasUser = Store.contains("user");
```
---
## Example Model
```dart
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
```
---
## Platform Paths
| Platform     | Storage Path                             |
|--------------|------------------------------------------|
| Android/iOS  | App Documents Directory                  |
| Windows      | %APPDATA%\SimpleStore\store.json       |
| macOS/Linux  | .simple_store/store.json in project path |
---
## Author
**Mohamed Zebib**  
Developed with love for simplicity and speed.

---
## License
MIT © Mohamed Zebib