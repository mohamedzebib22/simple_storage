
# 🧠 simple_store

> Flutter package for ultra-simple local storage of **any data type** using key-value format — with **zero boilerplate**.  
Save `int`, `double`, `String`, `List`, `Map`,`Object`,`List<Object>` or even custom objects with just one line.  
Supports: **Android, iOS, Windows, Linux, macOS**.

---

## 🚀 Installation

```bash
flutter pub add simple_store
```

---

## ✨ Features

✅ Save **any type of data** (primitives, List, Map, Object, List<Object>)  
✅ Cross-platform: Android, iOS, Windows, macOS, Linux  
✅ No box opening/closing  
✅ Auto JSON serialization  
✅ Key-based read/write  
✅ Fast and persistent  
✅ Single-line save/get syntax  
✅ Built-in offline caching for APIs  
✅ Supports List<CustomObject> without effort  

---

## 📦 Getting Started

### 🔐 Register your model (once in `main()`)

```dart
Store.register<User>(User.fromJson);
```

---

## 💾 Save & Get Examples

### 🔢 int

```dart
await Store.save("count", 5);
final count = await Store.get("count");
```

---

### 📝 String

```dart
await Store.save("username", "Mohamed");
final name = await Store.get("username");
```

---

### 👤 Object

```dart
await Store.save("user", User(name: "Ali", age: 25));
final user = await Store.get("user");
```

---

### 👥 List<Object>

```dart
await Store.save("users", [User(...), User(...)]);
final users = await Store.get("users");
```

---

### ❌ Delete a specific key

```dart
await Store.delete("username");
```

---

### 🧹 Clear all data

```dart
await Store.clear();
```

---

### 🔍 Check if key exists

```dart
final hasUser = await Store.contains("user");
```

---

## 📘 Example Model

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

## 🖥 Platform Paths

| Platform | Storage Path |
|----------|---------------|
| Android/iOS | App Documents Directory |
| Windows | %APPDATA%\SimpleStore\store.json |
| macOS/Linux | .simple_store/store.json in project path |

---

## 👨‍💻 Author

**Mohamed Zebib**  
Developed with ❤️ for simplicity and speed.

---

## 📄 License

MIT © Mohamed Zebib
