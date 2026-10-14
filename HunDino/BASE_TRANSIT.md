# Điểm dịch chuyển base ↔ sảnh trung tâm — 15/10/2026

Đã thêm vào bản Studio trong Documents/ChatGPT/game roblox/HunDino/HunDino_DarkJungle_v2_3.rbxl.

- **Ở base:** đến bệ tròn viền xanh ngọc, giữ G để về sảnh trung tâm. Mỗi base có một bệ, nằm phía hướng vào trung tâm, cách SpawnPad khoảng 26 studs.
- **Ở sảnh:** bệ chọn base nằm bên trái điểm xuất hiện, gần bảng chào. Giữ G, chọn Base 01–12 trên bảng. Base của bạn được tô vàng và ghi CỦA BẠN; các ô hiện tên chủ hoặc Chưa có chủ.
- Có thể ghé cả base trống và base người khác. Dịch chuyển không đổi quyền sở hữu. Pet được đưa tới cùng và hủy đòn đang chờ.
- Cất vũ khí và dừng động tác trước khi dịch chuyển. Điểm chọn chỉ hoạt động khi đứng gần bệ; bảng đóng khi đi xa, chết hoặc sau 60 giây.

Các bệ dùng ProximityPrompt giữ G 0,6 giây, không tự dịch chuyển khi đi ngang nên không gây vòng lặp. Server xác minh khoảng cách, nhân vật còn sống, trạng thái đang chuyển khu và số base nguyên 1–12. Trước khi chuyển xa, server yêu cầu tải vùng đích rồi đặt nhân vật và Pet lên sàn. Các bệ là model Persistent để vẫn tìm được điểm đến khi map bật StreamingEnabled.

## Mã và kiểm tra

- `tools/add-base-transit.luau`: script Edit bổ sung 13 bệ vào HunDinoL0.BaseTransit, không xây lại map.
- `src/dark-jungle/BaseTransitMenu.luau`: bảng chọn 12 base.
- Server/client Training đã nối vào hệ thống menu, chuyển khu và Pet hiện có. Nguồn khớp bản đang lưu: `studio-pet-integration/Training.server.luau`, `Training.client.luau`.
- Play: giữ G và chọn ô thật để đi tới đủ 12 base, quay lại trung tâm từ từng base; kiểm tra vị trí nhân vật, Pet, InTraining và BaseId đều đạt.
- Raycast tại cả 12 điểm đến xác nhận đứng trên đúng Ground của base. Thử số base sai, yêu cầu từ xa và chọn khi chưa mở bảng đều bị từ chối.
- Lượt Play cuối dùng mã hoàn thiện không có lỗi Output. Bản đồ gốc được so sánh trong `tools/test-base-transit.luau`, chỉ loại trừ các bệ mới khi so sánh hình học.

Chạy từ thư mục HunDino:

```powershell
./tools/lune/lune.exe run tools/test-base-transit.luau
./tools/lune/lune.exe run tools/test-random-base.luau
./tools/lune/lune.exe run tools/test-equipment-inventory.luau --saved
```

Backup map trước sửa: `backups/HunDino_v2_3_before_base_transit_20261015.rbxl`. Studio còn có ServerStorage.BaseTransitBackup_20261015 chứa nguồn server/client cũ.
