# Báo cáo Bài tập lớn: Phát triển Ứng dụng Di động với Flutter

## Thông tin sinh viên

* **Họ và tên:** Lưu Ngọc Anh Dương
* **MSSV:** 2221050572
* **Lớp:** DCCTCLC67B
* **Học phần:** Phát triển ứng dụng di động đa nền tảng / Thiết bị di động.

---

## 1. Giới thiệu Đề tài

**Tên ứng dụng:** Sổ Thu Chi Cá Nhân (Personal Expense Manager)

**Mô tả:**
Đây là ứng dụng giúp người dùng quản lý tài chính cá nhân một cách hiệu quả và trực quan. Ứng dụng cho phép ghi lại các khoản chi tiêu hàng ngày, phân loại chúng theo danh mục (Ăn uống, Đi lại, Mua sắm...) và tự động tính toán tổng số tiền đã chi tiêu trong tháng. Ứng dụng hoạt động offline hoàn toàn nhờ cơ sở dữ liệu cục bộ, đảm bảo dữ liệu luôn sẵn sàng ngay cả khi không có mạng.

---

## 2. Công nghệ và Thư viện sử dụng

Dự án được xây dựng dựa trên các công nghệ và thư viện sau:

* **Flutter & Dart:** Framework chính để xây dựng giao diện và logic ứng dụng.
* **Provider (`provider`):** Sử dụng để quản lý trạng thái (State Management), giúp tách biệt logic nghiệp vụ khỏi giao diện (UI) và cập nhật UI mượt mà khi dữ liệu thay đổi (ví dụ: cập nhật tổng tiền ngay khi thêm khoản chi).
* **Localstore (`localstore`):** Thư viện NoSQL database để lưu trữ dữ liệu cục bộ dưới dạng file JSON trên thiết bị. Giúp ứng dụng hoạt động offline và lưu trữ bền vững.
* **Intl (`intl`):** Sử dụng để định dạng hiển thị tiền tệ (Ví dụ: 50,000 đ) và xử lý ngày tháng.
* **GitHub Actions:** Thiết lập quy trình CI/CD để tự động build và chạy kiểm thử mỗi khi có mã nguồn mới được đẩy lên repository.

---

## 3. Các chức năng chính (CRUD & Logic)

Ứng dụng đáp ứng đầy đủ yêu cầu CRUD trên 2 đối tượng chính: **Khoản chi (Expense)** và **Danh mục (Category)**, có thiết lập quan hệ dữ liệu giữa hai đối tượng này.

### A. Quản lý Khoản chi (Expense)
* **Create (Tạo):** Thêm khoản chi mới với đầy đủ thông tin: Tiêu đề, Số tiền, Ghi chú, Ngày tạo, và chọn Danh mục từ danh sách có sẵn.
* **Read (Xem):**
    * Hiển thị danh sách các khoản chi chi tiết, sắp xếp theo thời gian mới nhất.
    * **Dashboard:** Hiển thị tổng số tiền đã chi tiêu (`totalSpent`) ngay trên đầu trang chủ.
* **Update (Sửa):** Cho phép sửa lại thông tin khoản chi (nhập sai tiền, chọn nhầm danh mục...) và cập nhật lại dữ liệu cũng như tổng tiền ngay lập tức.
* **Delete (Xóa):** Xóa khoản chi khỏi danh sách.

### B. Quản lý Danh mục (Category)
* **Create:** Thêm danh mục chi tiêu mới (ví dụ: Du lịch, Học phí, Tiền nhà...).
* **Read:** Hiển thị danh sách danh mục trong Menu điều hướng (Drawer).
* **Delete:** Xóa danh mục.
    * *Logic nâng cao:* Khi xóa một danh mục, hệ thống sẽ tự động xóa các khoản chi thuộc danh mục đó để đảm bảo tính toàn vẹn dữ liệu (Cascade Delete).

### C. Tính năng khác & UI/UX
* **Giao diện thân thiện:** Sử dụng Drawer cho menu, Dialog cho nhập liệu, màu sắc trực quan (Tiền hiển thị màu đỏ, Header màu xanh Teal).
* **Phản hồi người dùng:** Hiển thị thông báo (SnackBar) xác nhận khi người dùng Thêm/Sửa/Xóa thành công.
* **Hoạt động Offline:** Dữ liệu được lưu trữ bền vững trên máy, không bị mất khi tắt ứng dụng.

---

## 4. Video demo

https://github.com/user-attachments/assets/717f3c7d-38fb-4bc8-b06c-a1e06f39b35c



