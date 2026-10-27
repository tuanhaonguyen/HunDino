# Mã HelloHunDino — 22/10/2026

Đã cài vào Studio và xuất bản lên [HunDino SaveGame](https://www.roblox.com/games/103801986821599/), PlaceId `103801986821599`. Studio xác nhận: `Published new changes in "HunDino SaveGame" to Roblox.`

Vào lại game, mở **Cài đặt → Nhập code**, nhập `HelloHunDino`, bấm **Đổi mã**. Mọi tài khoản đều nhận được **50 xu, 2 bẫy thô, 2 bẫy sắt và 2 thuốc ngủ**. Mỗi tài khoản nhận một lần; vào lại hoặc đổi máy không mở lại lượt nhận. Chấp nhận chữ hoa/thường và khoảng trắng đầu/cuối.

Server sở hữu phần thưởng. Toàn bộ quà và biên nhận `Economy.RedeemedCodes.HelloHunDino` được ghi trong cùng `CommitEconomy`; chỉ báo thành công khi xác nhận lưu. Kho đầy hủy toàn bộ gói và chưa đánh dấu nhận. Lỗi ghi giữ giao dịch chờ theo hệ thống lưu hiện có. Không xóa dấu mã khi lịch sử mua hàng ngắn hạn bị lược bỏ. Mã admin cũ giữ điều kiện và quà riêng.

Ba source thay đổi: `AdminRedeemPolicy`, `HuntEconomyRules`, `HuntEconomyService` trong `ServerScriptService.HuntingRuntime`. Source Studio gốc ở `backups/hello-code-20261022/studio-sources.json` và StringValue trong `ServerStorage.HelloCodeBackup_20261022`. Kế hoạch cài đã kiểm tra: `assets/redeem/hello-code/install.json`.

Bản lưu native mới: **HunDino_HelloHunDino_20261022.rbxl**, 4.373.484 byte. Đối chiếu ba source và backup đạt; 139 script biên dịch thành công. Báo cáo chỉ đọc: `assets/redeem/hello-code/saved.json`. Công cụ không ghi lại Place/Terrain.

Kiểm thử:

- `tools/test-hello-code.luau`: 243 kiểm tra đạt, gồm số thưởng, nhiều tài khoản, JSON/tải lại, nhập lại, giới hạn kho, dữ liệu sai, tương thích mã admin và lỗi trước/sau ghi.
- `tools/qa/hello-code.server.luau`: 127 kiểm tra/6 nhóm đạt trong Studio bằng dịch vụ thật với tài khoản/backend giả, gồm lưu trước phản hồi và yêu cầu đồng thời. Tự dọn fixture.
- `tools/test-admin-redeem.luau`: 346 kiểm tra đạt; biến thể `--savegame` cũng đạt 346.
- UI Studio: bấm Cài đặt → Nhập code, nhập `QA-INVALID-CODE`, nhận đúng lỗi từ server.

QA không gửi mã HelloHunDino cho tài khoản thật. Chưa thử nhận quà qua tài khoản thật trong Roblox Player; kiểm thử giữ lại lượt đầu cho người chơi. Các máy chủ Roblox đã chạy bản cũ cần kết thúc/được thay bằng máy chủ mới để dùng bản cập nhật.
