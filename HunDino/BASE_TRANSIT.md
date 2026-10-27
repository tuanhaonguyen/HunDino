# Điểm dịch chuyển base ↔ sảnh trung tâm — 15/10/2026

<!-- TIEN_DO_20261027_BEGIN -->
> **Trạng thái đối chiếu 27/10/2026, 09:48 UTC+7:** local chính `HunDino_MerchantWeapons_20261026.rbxl` **4.495.025 byte**, SHA256 `8626bc714aa7a0da39493ba1bbcc676a142038b2f8a2c06e602fe01d522229bf`; inspector **129.779 kiểm / 164 source**, đạt. Cloud có bằng chứng mới nhất **v14**, nguồn **4.481.440 byte**; sửa bố cục ống mới chỉ local, **chưa Publish**.
>
> Play đủ 12 base bằng bảng G thật đạt sau khi chừa lối cụm ống; không đổi điểm dịch chuyển. Quyền số base vẫn theo phiên; ô trưng bày thuộc lớp hồ sơ, không đồng nghĩa lưu số base vĩnh viễn.
>
> [Báo cáo tiến độ toàn dự án và hôm nay](BAO_CAO_TIEN_DO_2026-10-27.md). Ghi chú này cập nhật trạng thái; số liệu/hash của từng mốc cũ bên dưới giữ nguyên theo phạm vi lúc kiểm.
<!-- TIEN_DO_20261027_END -->

**Cập nhật 27/10/2026:** bản chính `HunDino_MerchantWeapons_20261026.rbxl` đã sửa cụm ống
đè điểm đến tại Base 3, 5, 6, 10 và kiểm đủ 12 base. Không đổi bệ/điểm dịch chuyển;
đổi bố cục ống và metadata để chừa lối đi. Play chọn từng base, đi ra và giữ G về sảnh
đều đạt; kiểm hộp thân người trên 252 mẫu không vướng ống. Bản sửa đã lưu local,
chưa Publish. Xem [ống nghiệm](BIO_TUBES.md). Phần dưới ghi lại triển khai dịch chuyển ban đầu.

Các bệ dịch chuyển 12 base ↔ sảnh tiếp tục dùng trong [v2.4](HunDino_DarkJungle_v2_4.rbxl) tại Documents/ChatGPT/game roblox/HunDino. Base được bốc ngẫu nhiên trong các số còn trống, giữ qua hồi sinh trong phiên và trả khi thoát; ghé base khác không đổi quyền sở hữu. Bàn chế/nâng P1-E chỉ giao dịch tại base của chủ; xem [kinh tế](HUNT_ECONOMY.md). Số base thuộc phiên; dữ liệu cá thể và ô trưng bày đã có lớp lưu tài khoản. Đoạn này không chứng nhận toàn vòng trưng bày qua phiên cloud mới.

## Hồ sơ triển khai và kiểm chứng — 15/10/2026

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
