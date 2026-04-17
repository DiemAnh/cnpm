# BÁO CÁO PHÂN TÍCH SOURCE CODE
## Dự Án: BluemoonApp - Ứng Dụng Quản Lý Cộng Đồng

---

## I. GIỚI THIỆU

**Tên Dự Án:** BluemoonApp  
**Loại Dự Án:** Mobile Application (Flutter)  
**Mục Đích:** Ứng dụng di động để quản lý thông tin cộng đồng, bao gồm quản lý căn hộ, hóa đơn, người dùng và thông tin cá nhân.  
**Nền Tảng:** Flutter (iOS, Android)  
**Backend:** Spring Boot Java  

---

## II. PHÂN TÍCH KIẾN TRÚC HỆ THỐNG

### 2.1 Mô Hình Kiến Trúc Tổng Quan

```
┌─────────────────────────────────────────────────────────────┐
│                      BLUEMOONAPP (FLUTTER)                  │
├─────────────────────────────────────────────────────────────┤
│  UI Layer (Screens)                                         │
│  ├─ LoginScreen       (Đăng nhập)                           │
│  ├─ MainScreen        (Navigation chính)                    │
│  ├─ BillScreen        (Quản lý hóa đơn)                     │
│  ├─ ApartmentScreen   (Quản lý căn hộ)                      │
│  ├─ UserScreen        (Quản lý người dùng)                  │
│  └─ ProfileScreen     (Thông tin cá nhân)                   │
├─────────────────────────────────────────────────────────────┤
│  Business Logic Layer (Services)                            │
│  ├─ ApiService        (Gọi API)                             │
│  ├─ AuthService       (Xác thực)                            │
│  └─ SecureStorageService (Lưu trữ an toàn)                  │
├─────────────────────────────────────────────────────────────┤
│  Data Layer                                                 │
│  ├─ ApiConstants      (Định nghĩa endpoints)                │
│  └─ Models            (Định nghĩa kiểu dữ liệu)             │
├─────────────────────────────────────────────────────────────┤
│                    HTTP / REST API                          │
├─────────────────────────────────────────────────────────────┤
│              BACKEND (SPRING BOOT JAVA)                     │
│  localhost:9090                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Kiến Trúc Layers

**a) Presentation Layer (UI)**
- Các màn hình Flutter StatefulWidget
- Xử lý giao diện người dùng
- Quản lý state bằng setState

**b) Business Logic Layer**
- `ApiService`: Xử lý tất cả request HTTP (GET, POST, PUT, DELETE)
- `AuthService`: Quản lý đăng nhập/đăng xuất
- `SecureStorageService`: Lưu token JWT an toàn

**c) Data Layer**
- `ApiConstants`: Tập trung các endpoint API
- Model classes: Định nghĩa cấu trúc dữ liệu
- Secure Storage: Lưu JWT token

---

## III. CHI TIẾT CÁC COMPONENT CHÍNH

### 3.1 main.dart - Điểm Khởi Động Ứng Dụng

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}
```

**Chức Năng:**
- Cấu hình theme (màu xanh, Material Design 3)
- Định nghĩa routes ứng dụng
- Route `'/'`: LoginScreen (trang mặc định)
- Route `'/main'`: MainScreen (sau khi đăng nhập)

---

### 3.2 main_screen.dart - Navigation Chính

**Chức Năng:** BottomNavigationBar với 5 tab chính
- Bills (Hóa đơn)
- Apartments (Căn hộ)
- Users (Người dùng)
- Profile (Thông tin cá nhân)
- Settings (Cài đặt)

---

### 3.3 ApiConstants.dart - Configuration Endpoints

```dart
class ApiConstants {
  static const baseUrl = 'http://10.0.2.2:9090';
  
  // Endpoints
  static const login = '/api/auth/login';
  static const apartments = '/api/apartments/list';
  static const users = '/api/admin/users';
  static const bills = '/api/admin/bills';
  static const profile = '/api/user/home';
  
  // Dynamic endpoints
  static String adminGetApartmentById(String id) => 
      '/api/admin/apartment-list/edit-apartment/$id';
}
```

**Ưu Điểm:**
- Tập trung tất cả endpoints tại một chỗ
- Dễ bảo trì và cập nhật
- Hỗ trợ dynamic URL parameters

---

### 3.4 ApiService.dart - HTTP Client Wrapper

```dart
class ApiService {
  final _client = http.Client();
  final _storage = SecureStorageService();

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _storage.readToken();
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> get(String path, {bool auth = false}) async {
    return await _client.get(
      _uri(path),
      headers: await _headers(auth: auth),
    );
  }

  Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    return await _client.post(
      _uri(path),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
  }
}
```

**Chức Năng:**
- Hỗ trợ CRUD: GET, POST, PUT, DELETE
- Quản lý Authorization header với JWT token
- Logging request/response status
- Error handling

---

### 3.5 UserScreen.dart - Đơn Vị Phân Tích Chi Tiết

```dart
class _UserScreenState extends State<UserScreen> {
  final ApiService _api = ApiService();
  List users = [];
  bool loading = false;

  // Load danh sách người dùng
  Future<void> loadUsers() async {
    setState(() => loading = true);
    final res = await _api.get(ApiConstants.users, auth: true);
    if (res.statusCode == 200) {
      setState(() {
        users = jsonDecode(res.body);
      });
    }
    setState(() => loading = false);
  }

  // Xóa người dùng
  Future<void> deleteUser(int id) async {
    final res = await _api.post(
      "${ApiConstants.deleteUser}/$id", 
      auth: true
    );
    if (res.statusCode == 200) {
      loadUsers(); // Reload danh sách
    }
  }

  // Điều hướng tới màn thêm người dùng
  void goAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddUserScreen()),
    );
    if (result == true) loadUsers();
  }

  // Điều hướng tới màn sửa người dùng
  void goEdit(Map item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditUserScreen(user: item),
      ),
    );
    if (result == true) loadUsers();
  }

  // UI: Danh sách người dùng
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadUsers),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: goAdd,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (_, i) {
                final u = users[i];
                return Card(
                  child: ListTile(
                    title: Row(
                      children: [
                        Text(u['name'] ?? ''),
                        Icon(
                          Icons.circle,
                          size: 12,
                          color: u['activation'] ? 
                            Colors.green : Colors.red,
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Role: ${u['role']}"),
                        Text("Name: ${u['fullName'] ?? ''}"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: u['canEdit'] == true
                              ? () => goEdit(u)
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outlined,
                              color: Colors.red),
                          onPressed: u['canEdit'] == true
                              ? () => confirmDelete(u['id'])
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
```

**Phân Tích Chi Tiết:**

| Thành Phần | Mô Tả | Chức Năng |
|-----------|-------|----------|
| **loadUsers()** | GET request tới `/api/admin/users` | Tải danh sách người dùng từ backend |
| **deleteUser(id)** | POST request tới `/api/admin/users/delete/{id}` | Xóa người dùng theo ID |
| **goAdd()** | Navigator.push tới AddUserScreen | Mở màn hình thêm người dùng mới |
| **goEdit(item)** | Navigator.push tới EditUserScreen | Mở màn hình chỉnh sửa người dùng |
| **UI - ListView.builder** | Hiển thị danh sách dạng card | Mỗi card hiển thị name, role, fullName, phone, status |
| **Status Indicator** | Icon.circle với màu |✅ Xanh = Active, ❌ Đỏ = Inactive |
| **Actions** | Edit/Delete buttons | Chỉ cho phép nếu `canEdit == true` |

---

### 3.6 BillScreen.dart - Tương Tự UserScreen

```dart
class _BillScreenState extends State<BillScreen> {
  final ApiService _api = ApiService();
  List bills = [];
  bool loading = false;

  Future<void> loadBills() async {
    setState(() => loading = true);
    final res = await _api.get(ApiConstants.bills, auth: true);
    if (res.statusCode == 200) {
      setState(() {
        bills = jsonDecode(res.body);
      });
    }
    setState(() => loading = false);
  }

  Future<void> deleteBill(int id) async {
    final res = await _api.post(
      "${ApiConstants.deleteBill}/$id",
      auth: true
    );
    if (res.statusCode == 200) {
      loadBills();
    }
  }
}
```

**Điểm Chung:**
- Cấu trúc CRUD giống UserScreen
- Endpoint khác: `/api/admin/bills`
- Hiển thị ListTile tương tự

---

### 3.7 ApartmentScreen.dart - Quản Lý Căn Hộ

```dart
class _ApartmentScreenState extends State<ApartmentScreen> {
  final ApiService _api = ApiService();
  List apartments = [];
  bool loading = false;

  Future<void> loadApartments() async {
    setState(() => loading = true);
    final res = await _api.get(
      ApiConstants.apartments, 
      auth: true
    );
    if (res.statusCode == 200) {
      setState(() {
        apartments = jsonDecode(res.body);
      });
    }
    setState(() => loading = false);
  }

  Future<void> deleteApartment(int id) async {
    final res = await _api.post(
      "${ApiConstants.deleteApartment}/$id",
      auth: true
    );
    if (res.statusCode == 200) {
      loadApartments();
    }
  }
}
```

---

### 3.8 ProfileScreen.dart - Thông Tin Người Dùng

```dart
class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? profile;
  bool loading = false;

  Future<void> loadProfile() async {
    setState(() => loading = true);
    final res = await _api.get(
      ApiConstants.profile,
      auth: true
    );
    if (res.statusCode == 200) {
      setState(() {
        profile = jsonDecode(res.body);
      });
    }
    setState(() => loading = false);
  }
}
```

---

### 3.9 LoginScreen.dart - Xác Thực

```dart
class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  
  Future<void> _login() async {
    try {
      final token = await _auth.login(
        username: _user.text,
        password: _pass.text,
      );
      // Lưu token vào SecureStorage
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      // Hiển thị lỗi
    }
  }
}
```

---

## IV. LUỒNG DỮ LIỆU (Data Flow)

### 4.1 Luồng Đăng Nhập

```
User → LoginScreen
       ↓
   AuthService.login()
       ↓
   ApiService.post('/api/auth/login')
       ↓
   Backend xác thực
       ↓
   Trả về JWT Token
       ↓
   SecureStorageService.saveToken()
       ↓
   Navigator → MainScreen
```

### 4.2 Luồng Lấy Dữ Liệu (Load Users)

```
MainScreen (BottomNav) → Tab "Users"
       ↓
   UserScreen.initState() → loadUsers()
       ↓
   ApiService.get('/api/admin/users', auth: true)
       ↓
   Gửi header: 'Authorization: Bearer {token}'
       ↓
   Backend kiểm tra token, return danh sách
       ↓
   jsonDecode() → List<dynamic>
       ↓
   setState() → rebuild ListView.builder
       ↓
   Hiển thị Card cho mỗi user
```

### 4.3 Luồng Sửa Dữ Liệu (Edit User)

```
UserScreen (ListTile) → Tap Edit icon
       ↓
   Navigator.push → EditUserScreen(user: item)
       ↓
   User chỉnh sửa fields
       ↓
   Save button → ApiService.put() / post()
       ↓
   Backend cập nhật database
       ↓
   Return success (200)
       ↓
   Navigator.pop(result: true)
       ↓
   UserScreen.loadUsers() reload
       ↓
   ListView rebuild với dữ liệu mới
```

---

## V. CÔNG NGHỆ VÀ DEPENDENCIES

### 5.1 Frontend (Flutter)

| Dependency | Phiên Bản | Mục Đích |
|-----------|---------|---------|
| `flutter` | Latest | Framework UI |
| `http` | ^0.13.0 | HTTP Client |
| `flutter_secure_storage` | ^5.0.0 | Lưu JWT token an toàn |
| `freezed_annotation` | ^2.0.0 | Code generation |
| `json_serializable` | ^6.0.0 | JSON serialization |

### 5.2 Backend (Spring Boot)

| Dependency | Mục Đích |
|-----------|---------|
| Spring Boot Web | REST API |
| Spring Security | JWT Authentication |
| Spring Data JPA | Database ORM |
| MySQL Driver | Database |

---

## VI. CHIẾN LƯỢC CẬP NHẬT VÀ PHÁT TRIỂN

### 6.1 Mẫu CRUD cho Các Màn Hình Mới

Khi thêm màn hình quản lý mới (ví dụ: ReportScreen):

**Step 1:** Thêm endpoint vào ApiConstants
```dart
static const reports = '/api/admin/reports';
static const addReport = '/api/admin/reports/add';
```

**Step 2:** Tạo screen theo pattern UserScreen
```dart
class ReportScreen extends StatefulWidget { ... }

class _ReportScreenState extends State<ReportScreen> {
  Future<void> loadReports() async { ... }
  Future<void> deleteReport(int id) async { ... }
  void goAdd() async { ... }
  void goEdit(Map item) async { ... }
  @override Widget build(BuildContext context) { ... }
}
```

**Step 3:** Thêm vào MainScreen navigation

---

### 6.2 Sửa Lỗi Phổ Biến

| Vấn Đề | Nguyên Nhân | Giải Pháp |
|--------|-----------|---------|
| 401 Unauthorized | Token hết hạn/không valid | Refresh token hoặc đăng nhập lại |
| 403 Forbidden | Không có quyền truy cập | Kiểm tra role/permissions backend |
| 500 Server Error | Lỗi backend | Kiểm tra logs backend, database |
| UI không update | Quên setState() | Luôn gọi setState() sau async operation |
| Loading vô hạn | API không response | Thêm timeout, error handling |

---

## VII. CẤU TRÚC THƯ MỤC DỰ ÁN

```
bluemoonapp/
├── lib/
│   ├── main.dart                    # Điểm khởi động
│   ├── constants/
│   │   └── api_constants.dart       # Endpoints, baseUrl
│   ├── services/
│   │   ├── api_service.dart         # HTTP wrapper
│   │   ├── auth_service.dart        # Authentication
│   │   └── secure_storage_service.dart
│   ├── screens/
│   │   ├── main_screen.dart         # Navigation chính
│   │   ├── login_screen.dart        # Đăng nhập
│   │   ├── bill_screen.dart         # Quản lý hóa đơn
│   │   ├── apartment_screen.dart    # Quản lý căn hộ
│   │   ├── user_screen.dart         # Quản lý người dùng
│   │   ├── profile_screen.dart      # Thông tin cá nhân
│   │   ├── bill_screen_action/
│   │   │   ├── add_bill_screen.dart
│   │   │   └── edit_bill_screen.dart
│   │   ├── user_screen_action/
│   │   │   ├── add_user_screen.dart
│   │   │   └── edit_user_screen.dart
│   │   └── apartment_screen_action/
│   │       ├── add_apartment_screen.dart
│   │       └── edit_apartment_screen.dart
│   ├── models/
│   │   ├── auth_request.dart
│   │   └── auth_response.dart
│   └── utils/
│       └── api_host.dart            # Platform-specific host
├── android/                          # Android native config
├── ios/                              # iOS native config
└── pubspec.yaml                      # Dependencies
```

---

## VIII. KẾT LUẬN

### 8.1 Điểm Mạnh

✅ **Kiến Trúc Rõ Ràng:** Phân tách layers (UI, Business Logic, Data)  
✅ **Reusable Code:** ApiService, AuthService tái sử dụng được  
✅ **CRUD Pattern:** Các màn hình quản lý tuân theo cùng pattern  
✅ **JWT Security:** Sử dụng JWT + SecureStorage cho authentication  
✅ **Platform-Specific:** Hỗ trợ Android (10.0.2.2) và iOS (localhost)  

### 8.2 Cải Tiến Đề Xuất

🔧 **Error Handling:** Cần error handling toàn diện hơn (custom exceptions)  
🔧 **State Management:** Nên dùng Provider/Riverpod thay setState  
🔧 **Offline Support:** Thêm local database (Hive, SQLite)  
🔧 **Logging:** Sử dụng logger library thay print()  
🔧 **Testing:** Thêm unit tests và widget tests  
🔧 **Pagination:** Hỗ trợ phân trang cho danh sách lớn  

### 8.3 Tổng Kết

BluemoonApp là một ứng dụng quản lý cộng đồng được xây dựng với:
- **Frontend:** Flutter - cross-platform mobile app
- **Backend:** Spring Boot - REST API
- **Database:** MySQL
- **Authentication:** JWT tokens
- **Pattern:** MVC-style architecture

Codebase tuân theo các best practices Flutter và dễ dàng mở rộng thêm tính năng mới bằng cách:
1. Thêm endpoint vào ApiConstants
2. Tạo action screens (Add/Edit)
3. Tạo screen listing theo UserScreen pattern
4. Thêm vào MainScreen navigation

---

## IX. TÀI LIỆU THAM KHẢO

- Flutter Documentation: https://flutter.dev/docs
- Dart Language: https://dart.dev/guides
- HTTP Package: https://pub.dev/packages/http
- Flutter Secure Storage: https://pub.dev/packages/flutter_secure_storage
- Spring Boot: https://spring.io/projects/spring-boot


