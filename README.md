# Self Ordering Restaurant - Flutter Mobile App

## Giới thiệu

Ứng dụng di động dành cho khách hàng trong hệ thống Nhà Hàng Tự Order.

## Chức năng hệ thống

### Khách hàng (Customer)

* Quét mã QR bàn ăn.
* Xem thực đơn và thông tin món ăn.
* Thêm món vào giỏ hàng.
* Tạo đơn hàng trực tiếp trên ứng dụng.
* Theo dõi trạng thái đơn hàng theo thời gian thực.
* Thanh toán bằng mã QR.
* Gửi đánh giá và phản hồi.
* Gửi yêu cầu hỗ trợ tới nhân viên.
* Nhận thông báo từ hệ thống.

### Nhân viên (Staff)

* Nhận và xử lý đơn hàng từ khách hàng.
* Cập nhật trạng thái chế biến món ăn.
* Cập nhật trạng thái đơn hàng.
* Hỗ trợ khách hàng thanh toán tại bàn.
* Nhận và xử lý yêu cầu gọi nhân viên từ khách hàng.
* Quản lý bàn ăn.
* Xem lịch sử đơn hàng.
* Nhận thông báo thời gian thực qua WebSocket.
* Thực hiện chấm công Check-in / Check-out bằng nhận diện khuôn mặt.
* Quản lý các thông báo liên quan đến công việc.

### Quản trị viên (Admin)

* Quản lý nhân viên.
* Quản lý món ăn và danh mục món ăn.
* Quản lý nguyên liệu và nhà cung cấp.
* Quản lý bàn ăn.
* Quản lý khách hàng.
* Theo dõi và quản lý đơn hàng.
* Theo dõi doanh thu và thống kê hoạt động nhà hàng.
* Quản lý lịch làm việc nhân viên.
* Quản lý thông báo hệ thống.
* Phân quyền người dùng và kiểm soát truy cập.

## Công nghệ sử dụng

### Frontend

* Flutter
* Dart
* GetX
* Dio
* WebSocket

### Backend kết nối

* Java Spring Boot
* GraphQL
* REST API
* JWT Authentication
* WebSocket Notification
* MySQL


## Yêu cầu môi trường

| Công nghệ      | Phiên bản        |
| -------------- | ---------------- |
| Flutter        | 3.41.4           |
| Dart SDK       | 3.11.1           |
| Android Studio | Hedgehog trở lên |
| JDK            | 17 hoặc mới hơn  |

Kiểm tra phiên bản Flutter:

## Cài đặt project

### Clone source code
git clone https://github.com/hoanglam0905/restaurant-self-order-app

cd self_ordering_restaurant

### Cài đặt dependencies
flutter pub get

### Chạy ứng dụng
flutter run

## Dependencies chính:

```text
dio: ^5.9.0
flutter_secure_storage: ^9.2.4
get: ^4.7.2
http: ^1.6.0
qr_flutter: ^4.1.0
url_launcher: ^6.3.2
shared_preferences: ^2.5.5
mobile_scanner: ^7.2.0
app_links: ^7.0.0
path_provider: ^2.1.5
open_filex: ^4.7.0
camera: ^0.12.0+1
flutter_local_notifications: ^21.0.0
```
## Cấu hình Backend

Ứng dụng kết nối tới Backend đã được triển khai trên Render.

## Backend Configuration

Backend URL:
https://selforderingrestaurant-635x.onrender.com
(chi tiết repo Backend: https://github.com/HoangDinhBui/SelfOrderingRestaurant)

REST API:
https://selforderingrestaurant-635x.onrender.com/api

GraphQL API:
https://selforderingrestaurant-635x.onrender.com/graphql

WebSocket:
wss://selforderingrestaurant-635x.onrender.com/ws/notifications

### Lưu ý

* Backend được triển khai trên Render.
* Thiết bị chạy ứng dụng cần có kết nối Internet.
* Không cần cài đặt hoặc chạy Backend cục bộ.
* Nếu Backend đang ở trạng thái ngủ (sleep), request đầu tiên có thể mất khoảng 30–60 giây để khởi động lại dịch vụ.


## Database

Hệ thống hiện đang sử dụng database đã được triển khai trên môi trường production.

Do cơ sở dữ liệu đang được host trực tuyến và chứa dữ liệu dùng chung của hệ thống, nhóm không cung cấp thông tin truy cập trực tiếp.

Để đánh giá hệ thống, giảng viên có thể sử dụng backend đã deploy tại:

https://selforderingrestaurant-635x.onrender.com

Tài khoản test:

Admin:
email: admin@example.com
password: admin

Staff:
email: hoangdb2@gmail.com
pass: password123

Customer:
email: damhoanglamdam@gmail.com
password: 123456789

## Quyền truy cập ứng dụng

Ứng dụng sử dụng các quyền:

* Camera (quét QR)
* Internet
* Notification

## Chạy web admin đã deploy
Phải có tài khoản Vercel
Truy cập link: https://self-ordering-restaurant-nzoodv1pu-hoang-s-projects15.vercel.app/login
Yêu cầu quyền truy cập
Đăng nhập bằng tài khoản cho bên dưới

## Chạy Admin Web Local

### Clone source

git clone: https://github.com/HoangDinhBui/SelfOrderingRestaurant

### Cài đặt dependencies

npm install

### Chạy project

npm run dev

### Truy cập

http://localhost:5173/login

## Cấu trúc thư mục

```text
lib/
├── app/
├── core/
├── features/
│   ├── customer/
│   │   ├── auth/
│   │   ├── feedback/
│   │   ├── home/
│   │   │   ├── controllers/
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   └── services/
│   │   │   └── views/
│   │   ├── menu/
│   │   ├── notifications/
│   │   ├── order/
│   │   ├── reservation/
│   │   ├── settings/
│   │   └── welcome/
│   │
│   └── staff/
│       ├── dish_management/
│       ├── face_scan/
│       ├── history_management/
│       ├── notification_management/
│       ├── realtime/
│       ├── settings_management/
│       ├── table_management/
│       └── staff_navigation_shell.dart
│
└── main.dart
```
## Kiểm tra source code
flutter analyze

## Nhóm thực hiện
1. ĐÀM HOÀNG LAM MSSV: 6451071039 Lớp: CQ.64.CNTT
2. BÙI ĐÌNH HOÀNG MSSV: 6451071025 Lớp: CQ.64.CNTT
3. TRẦN VĂN MINH TÚ MSSV: 6451071083 Lớp: CQ.64.CNTT
4. TRẦN THỊ MỸ DUNG MSSV: 6451071008 Lớp: CQ.64.CNTT
