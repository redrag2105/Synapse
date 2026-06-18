# Hướng Dẫn Cấu Trúc Code 3 Tầng (Clean Architecture)

Dự án được phân chia theo cấu trúc 3 tầng rõ rệt. Luồng giải thích dưới đây sẽ đi từ bề ngoài nhất (giao diện người dùng) rồi tiến dần vào các tầng logic bên trong.

Cấu trúc gồm 3 thư mục chính:
1. **Presentation** (UI + Controller)
2. **Domain**
3. **Data**

---

## 1. Tầng Presentation (Bề ngoài nhất)
Thư mục `presentation` là nơi tiếp xúc trực tiếp với người dùng. Nó được chia thành 2 thư mục con: `screens` và `controllers`.

### Thư mục `screens` (Chỉ chứa UI)
* **Quy tắc cốt lõi:** Nơi này chỉ và **bắt buộc chỉ có UI** (các cây widget).
* Tuyệt đối không để UI biết bất cứ thứ gì về business logic (nghiệp vụ).
* UI chỉ làm nhiệm vụ hiển thị và gọi hàm khi có tương tác.

**Ví dụ:** Trong giao diện có một nút Login, nó sẽ chỉ là một cái nút thuần túy gọi hàm từ Controller truyền vào:
```dart
ElevatedButton(
  // UI chỉ gọi hàm, không tự xử lý logic
  onPressed: controller.login, 
  child: const Text("Login"),
)