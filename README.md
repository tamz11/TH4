# TH4 - Mini E-Commerce App

## API đang dùng
- Endpoint: https://dummyjson.com/products?limit=100
- Service: lib/services/product_service.dart

## Phân công 4 người (khung nhóm)

| Thành viên | Phụ trách chính | Việc cụ thể | Kết quả cần bàn giao |
|---|---|---|---|
| Người 1 | Kiến trúc + State Management | Dựng cấu trúc thư mục `models/`, `screens/`, `widgets/`, `services/`, `providers/`; quản lý Provider toàn app; chuẩn hóa route và luồng dữ liệu | App chạy ổn định, state giỏ hàng đồng bộ liên màn hình |
| Người 2 | Home Screen + API | SliverAppBar sticky + Search bar, badge giỏ hàng, banner carousel, danh mục, grid sản phẩm, pull-to-refresh, infinite scroll | Màn hình Home giống UX sàn TMĐT và tải dữ liệu mượt |
| Người 3 | Product Detail + BottomSheet | Hero animation, slider ảnh, giá bán/giá gốc, mô tả xem thêm/thu gọn, BottomSheet chọn size/màu/số lượng, thêm vào giỏ + SnackBar | Luồng xem chi tiết và thêm vào giỏ hoàn chỉnh |
| Người 4 | Cart + Checkout + Orders | Checkbox item/chọn tất cả, tính tổng realtime, dismiss xóa, checkout, tạo đơn, tab lịch sử đơn, lưu giỏ offline | Luồng mua hàng khép kín và dữ liệu giỏ giữ khi mở lại app |

## Quy tắc làm việc nhóm
1. Mỗi người làm trên nhánh riêng: `feature/memberX-...`.
2. Commit nhỏ, rõ ý, mở PR vào `develop`.
3. Chỉ merge khi đã review chéo ít nhất 1 người.
4. File chung như `main.dart` hoặc provider lõi phải báo nhóm trước khi sửa.

## Checklist nghiệm thu nhanh
- AppBar trang chủ đúng format: `TH4 - Nhóm [Số nhóm]`.
- Có Hero animation.
- Có badge giỏ hàng cập nhật realtime.
- Có BottomSheet chọn size/màu/số lượng.
- Có pull refresh + infinite scroll.
- Giỏ hàng dùng Provider, không truyền list giỏ qua lại bằng Navigator.
