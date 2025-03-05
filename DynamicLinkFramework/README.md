# 📌 DynamicLink iOS Framework

**DynamicLink** là một Framework iOS mạnh mẽ giúp bạn tạo và xử lý các **Deep Links** một cách dễ dàng. Với **DynamicLink**, bạn có thể chia sẻ nội dung, tạo short link, theo dõi trạng thái mở app, và cung cấp trải nghiệm liền mạch cho người dùng.

## ✨ Tính năng nổi bật
✅ **Thêm siêu dữ liệu vào đường liên kết** để chia sẻ qua mạng xã hội.  
✅ **Tạo URL liên kết ngắn (Short Link)** dễ dàng.  
✅ **Hỗ trợ mở lại ứng dụng qua Deep Link (Reopen Deeplink).**  
✅ **Theo dõi cài đặt ứng dụng từ Deep Link (Install App from Deeplink).**  
✅ **Xác định lần đầu mở ứng dụng từ Deep Link (First Open Link).**  
✅ **Trải nghiệm ngữ cảnh linh hoạt thông qua nội dung được liên kết sâu trong ứng dụng.**  
✅ **Dẫn người dùng đến đúng App Store hoặc Play Store chỉ bằng một lần nhấp.**  

---

## 🚀 Cài đặt
### 1️⃣ **CocoaPods**
Thêm vào `Podfile` của bạn:
```ruby
pod 'DynamicLink'
```
Sau đó chạy lệnh:
```sh
pod install
```

### 2️⃣ **Swift Package Manager (SPM)**
1. Mở **Xcode** → **File** → **Swift Packages** → **Add Package Dependency**
2. Nhập URL:
   ```
   https://github.com/your-repo/DynamicLink.git
   ```
3. Chọn phiên bản mới nhất và nhấn **Add Package**.

---

## 🛠 Hướng dẫn sử dụng
### **1️⃣ Tạo Short Link**
```swift
import DynamicLink

DynamicLinkManager.shared.createShortLink(parameters: [
    "title": "Chia sẻ bài viết!",
    "url": "https://yourapp.com/post/123"
]) { result in
    switch result {
    case .success(let shortLink):
        print("🔗 Short link: \(shortLink)")
    case .failure(let error):
        print("❌ Lỗi tạo short link: \(error.localizedDescription)")
    }
}
```

### **2️⃣ Xử lý Deep Link**
```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return DynamicLinkManager.shared.handleDeepLink(url)
}
```

### **3️⃣ Kiểm tra First Open / Reopen**
```swift
DynamicLinkManager.shared.checkDeepLinkStatus { status in
    switch status {
    case .firstOpen:
        print("🚀 Lần đầu mở từ deep link")
    case .reopen:
        print("🔄 Ứng dụng được mở lại từ deep link")
    case .none:
        print("ℹ️ Không có deep link nào")
    }
}
```

---

## 📚 Tài liệu
- **[Hướng dẫn chi tiết](https://your-repo.github.io/DynamicLink)**
- **[API Reference](https://your-repo.github.io/DynamicLink/API)**

---

## 📩 Hỗ trợ
Nếu bạn gặp vấn đề, vui lòng tạo một [Issue](https://github.com/your-repo/DynamicLink/issues) hoặc liên hệ với chúng tôi qua email: `support@yourapp.com`

---

## 💡 Bản quyền
© 2025 YourCompany. Framework được phát hành theo giấy phép **MIT License**.

