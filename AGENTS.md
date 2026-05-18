# Agent Rules - Flutter Frontend With Java Backend

## Phạm Vi Dự Án

Workspace gồm hai dự án chính:

- Backend: `SelfOrderingRestaurant`
- Frontend Flutter: `self_ordering_restaurant`

Backend hiện tại là Java Spring Boot 3.4.3, Java 21, Maven, Spring Web, Spring Security, JWT, OAuth2 Google, JPA/Hibernate, MySQL, GraphQL, WebSocket và các DTO request/response theo từng tính năng.

Frontend hiện tại là Flutter/Dart SDK `^3.11.1`, Material app, `flutter_lints`, cấu trúc đang có `lib/data/models`, `lib/data/services`, `lib/utils`, `lib/widgets`, `lib/views/<feature>`.

## Công Nghệ Frontend Đã Xác Nhận

Agent phải mặc định dùng các công nghệ/quy trình sau khi làm frontend:

- State management: GetX.
- HTTP client: Dio.
- Routing/navigation: Navigator mặc định của Flutter.
- Token storage: `flutter_secure_storage`.
- Môi trường chạy chính: Android emulator.
- Backend base URL mặc định cho Android emulator: `http://10.0.2.2:8080`.
- API style: dùng theo backend hiện tại; REST, GraphQL hoặc WebSocket tùy theo tính năng/backend contract đang có.
- UI design: MCP Figma đã cấu hình; khi làm UI phải lấy design từ Figma nếu có file/page/frame liên quan.
- Quy trình kiểm tra/chạy frontend: `flutter analyze`, sau đó `flutter run`.

## Nguyên Tắc Bắt Buộc Trước Khi Làm Tính Năng

Khi xây dựng bất kỳ tính năng frontend nào, agent phải bắt đầu từ backend thật, không tự suy diễn API.

1. Đọc controller/backend entrypoint liên quan trong `SelfOrderingRestaurant/src/main/java/com/example/SelfOrderingRestaurant`.
2. Xác định endpoint REST, GraphQL schema hoặc WebSocket path cần dùng.
3. Đọc các DTO request/response liên quan trong `Dto/Request`, `Dto/Response` và các enum liên quan trong `Enum`.
4. Đọc service backend nếu cần hiểu logic nghiệp vụ, validation, trạng thái, role, auth, pagination, upload file, error response.
5. Nếu API backend thiếu, sai hoặc không rõ contract, phải hỏi người dùng hoặc đề xuất sửa backend trước khi hard-code workaround ở frontend.
6. Frontend phải gọi backend thật tương ứng, không mock data cho luồng chính trừ khi người dùng yêu cầu mock/prototype.

## Quy Trình Triển Khai Một Tính Năng Flutter

Mỗi tính năng phải hoàn thành trọn luồng từ API đến UI:

1. API contract
   - Liên kết rõ endpoint REST/GraphQL/WebSocket backend đang dùng.
   - Ghi nhận method, path, params, request body, response body, auth header, multipart nếu có.
   - Đối với GraphQL, đọc `src/main/resources/graphql/*.graphqls` và resolver tương ứng.

2. DTO và model
   - Tạo DTO/model Dart theo response/request backend.
   - Đặt file trong `lib/data/models/<feature>/` hoặc theo cấu trúc feature hiện có nếu dự án đã chuẩn hóa sau này.
   - Có `fromJson`, `toJson` khi cần gửi/nhận JSON.
   - Tên field Dart theo camelCase, map đúng key JSON của backend.
   - Enum backend phải có enum Dart tương ứng hoặc mapper rõ ràng, không dùng string rải rác trong UI.

3. Service/API client
   - Tạo service trong `lib/data/services/<feature>/`.
   - Sử dụng Dio làm HTTP client chuẩn của dự án.
   - Service chỉ phụ trách giao tiếp backend, parse response, xử lý status code và ném lỗi có ý nghĩa.
   - Không gọi HTTP trực tiếp trong View.
   - Token JWT phải được gắn vào request protected endpoint bằng `Authorization: Bearer <token>`.
   - Token JWT/refresh token phải lưu và đọc qua `flutter_secure_storage`.
   - Multipart endpoint phải dùng đúng field name theo `@ModelAttribute` backend.
   - URL ảnh từ backend phải dùng đúng contract backend, ví dụ dish image hiện có có dạng `http://localhost:8080/uploads/dishes/<file>`.

4. Controller/state
   - Mỗi feature cần có GetX controller/state riêng trong `lib/controllers/<feature>/` hoặc `lib/features/<feature>/controllers/` nếu dự án thống nhất theo feature-first.
   - Controller giữ loading/error/data state, gọi service và expose action cho view.
   - View không chứa logic nghiệp vụ, parse JSON, xử lý token, hay điều kiện phức tạp.

5. View và widget
   - Views phải chia theo từng tính năng: `lib/views/<feature>/`.
   - Trước khi code UI, phải phân tích widget nào chỉ thuộc feature và widget nào có khả năng dùng lại ở nhiều view sau này.
   - Widget dùng lại phải tách vào `lib/core/widgets/` hoặc thư mục shared/core tương ứng; widget chỉ thuộc feature mới đặt trong `lib/features/<feature>/views/widgets/`.
   - Không dồn toàn bộ UI, state, service, model vào một file.
   - View chỉ lắp ghép UI và gọi controller/action.
   - Mỗi màn hình cần có loading state, empty state, error state và success/normal state khi phù hợp.

6. Theme, color, typography
   - Màu sắc, text style, spacing, radius, button style phải tách vào theme/shared constants.
   - Không hard-code màu và style lặp lại trong từng view.
   - Nếu thêm design token từ Figma, cập nhật vào theme/color/shared style trước rồi view sử dụng lại.

7. Kiểm thử và xác minh
   - Chạy `flutter analyze` sau khi sửa frontend.
   - Chạy test hiện có bằng `flutter test` nếu thay đổi logic/model/service/controller.
   - Khi có thay đổi backend liên quan, chạy Maven test/build phù hợp nếu khả thi.
   - Nếu không chạy được lệnh kiểm thử, phải ghi rõ lý do trong kết quả bàn giao.

## Cấu Trúc Flutter Mục Tiêu

dự án chọn feature-first, dùng cấu trúc:

```text
lib/
  core/
    config/
    network/
    storage/
    theme/
    widgets/
  features/
    <feature>/
      data/
        models/
        services/
      controllers/
      views/
        widgets/
```


## Tích Hợp Figma MCP

Khi thiết kế hoặc sửa UI:

1. Phải lấy thiết kế từ MCP Figma nếu người dùng cung cấp Figma file/page/frame.
2. Phải đọc token/style/component từ Figma trước khi code UI.
3. Nếu MCP Figma chưa khả dụng hoặc chưa có link Figma, phải hỏi người dùng để xác nhận cách lấy design.
4. UI tạo ra phải tách thành widget có tên rõ ràng, để dùng lại.
5. Không copy một màn hình Figma thành một file Flutter không có cấu trúc.
6. Asset từ Figma phải được đưa vào thư mục asset phù hợp và khai báo trong `pubspec.yaml`.

## Backend Contract Cần Chú Ý

Backend có các nhóm API và công nghệ sau:

- REST controllers trong `Controller/`, base path phổ biến: `/api`, `/api/auth`, `/api/admin`, `/api/staff`, `/api/payment`, `/api/notifications`.
- GraphQL order flow trong `src/main/resources/graphql/order.graphqls` và `GraphQL/Controller/OrderGraphQLController.java`.
- WebSocket notification path: `/ws/notifications`.
- Security dùng JWT Bearer token, role `ADMIN`, `STAFF`, `CUSTOMER`.
- Auth response trả về `accessToken`, `refreshToken`, `username`, `email`, `userType`, `staffId`.
- Một số endpoint public hiện có: auth, dishes, images, notifications, payment, receipts, GraphQL, WebSocket.
- Backend hiện hard-code một số localhost URL và CORS origin; khi mobile app cần gọi backend trên thiết bị thật/emulator, phải xác nhận base URL.

## Quy Tắc Giao Tiếp API

- Không hard-code base URL trong từng service. Dùng config tập trung, ví dụ `core/config/api_config.dart`.
- Android emulator là môi trường chính và phải dùng base URL mặc định `http://10.0.2.2:8080`, trừ khi người dùng đổi cấu hình.
- Thiết bị thật cần IP LAN của máy chạy backend; web/desktop có thể dùng `http://localhost:8080`.
- Phải xử lý token hết hạn bằng refresh token nếu tính năng auth đã được xác nhận.
- Phải xử lý lỗi 400/401/403/404/500 và hiển thị thông báo thân thiện ở UI.
- Không nuốt lỗi trong service/controller.
- Không để UI phụ thuộc vào message tiếng Việt/English từ backend để quyết định logic; dùng status code, field hoặc enum.

## Quy Tắc Code Flutter

- Tuân thủ `flutter_lints` và format Dart.
- Sử dụng GetX cho controller/state/reactive state.
- Sử dụng Navigator mặc định cho điều hướng, không thêm `go_router` hay router package khác nếu chưa được yêu cầu.
- Widget nên nhỏ, có trách nhiệm rõ ràng.
- Không dùng biến global để lưu state nghiệp vụ.
- Không truyền Map động qua nhiều tầng nếu có thể tạo model/DTO.
- Không để logic xử lý ngày giờ, tiền tệ, enum status nằm trong Text widget.
- Không thêm package mới nếu package đó không cần thiết; nếu cần thêm, phải nói rõ lý do.
- Các package mặc định được phép dùng cho frontend là `get`, `dio`, `flutter_secure_storage`; nếu chưa có trong `pubspec.yaml` thì agent có thể thêm khi tính năng cần.
- Không thay GetX/Dio/Navigator/`flutter_secure_storage` bằng package khác nếu chưa được người dùng xác nhận.

## Quy Tắc Code Backend Khi Cần Sửa

- Giữ đúng pattern hiện có: Controller -> Service -> Repository -> Entity/DTO.
- DTO request/response phải nằm đúng namespace `Dto/Request/...` và `Dto/Response/...`.
- Không trả entity JPA trực tiếp cho frontend nếu đã có DTO pattern.
- Endpoint mới phải cân nhắc security rule trong `SecurityConfig`.
- Nếu thêm endpoint cho Flutter, phải cập nhật CORS/base URL/security nếu cần.
- Kiểm tra ảnh hưởng tới REST, GraphQL và WebSocket nếu tính năng liên quan order/payment/notification.

## Những Việc Agent Phải Hỏi Trước Khi Tiếp Tục Nếu Chưa Rõ

Agent phải hỏi người dùng trước khi code nếu các điểm sau chưa được xác nhận trong yêu cầu tính năng cụ thể:

- Link Figma file/page/frame nào là source of truth cho UI của tính năng đang làm?
- Tính năng đang làm cần dùng endpoint REST, GraphQL hay WebSocket nào nếu backend có nhiều cách cho cùng một luồng?
- Base URL có khác `http://10.0.2.2:8080` không?
- Có cần thêm package ngoài các package mặc định `get`, `dio`, `flutter_secure_storage` không?
- Có cần sửa backend hay chỉ được tích hợp backend hiện có?

## Definition Of Done

Một tính năng chỉ được xem là hoàn thành khi:

- Đã đọc và bám đúng API backend thật.
- Đã có DTO/model/service/controller/view/widget cần thiết.
- View gọi backend thật, không dùng mock data cho luồng chính.
- UI được tách widget/theme/color đúng chuẩn Flutter.
- Luồng thành công, loading, empty và error được xử lý.
- Auth/token/role được xử lý nếu endpoint yêu cầu.
- Đã chạy `flutter analyze`.
- Đã chạy `flutter run` khi cần xác minh UI/luồng trên Android emulator, hoặc ghi rõ vì sao không chạy được.
- Kết quả bàn giao nêu rõ file đã sửa, API đã dùng và các việc còn cần xác nhận.
