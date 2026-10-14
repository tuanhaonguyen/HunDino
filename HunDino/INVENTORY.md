# Túi đồ Người và Pet — 15/10/2026

Đã lưu trực tiếp bằng Roblox Studio vào `HunDino_DarkJungle_v2_3.rbxl` trong Documents/ChatGPT/game roblox/HunDino.

Cất vũ khí rồi bấm I hoặc icon Túi đồ trong bãi tập. Chọn Người/Pet, sau đó chọn Vũ khí/Giáp. Danh sách vũ khí chỉ hiện tên bảy loại; hướng dẫn combo tiếp tục nằm trên HUD chiến đấu.

Mục Giáp theo bố cục ảnh tham khảo: nhân vật 3D bên trái, các bộ giáp ở giữa, món đang chọn phóng lớn bên phải. Mỗi hàng có năm ô từ trái sang phải: Đầu, Thân, Tay, Eo, Chân. Bốn bộ mẫu là Thợ săn, Da, Kim loại, Xương. Có dấu đánh dấu món đang mặc, xem trước khi trang bị và tháo từng vị trí. Mục Pet dùng cùng bố cục với mô hình pet.

**Xoay xem trước:** giữ chuột trái trong khung nhân vật rồi kéo trái/phải để xoay ngang, kéo lên/xuống để nghiêng góc nhìn. Áp dụng cho Người và Pet; hỗ trợ kéo bằng một ngón tay trên cảm ứng. Đã bỏ hai nút xoay cũ. Góc nghiêng giới hạn ±65°; thả chuột, đóng túi hoặc mất focus thì dừng kéo. Chuyển camera trực tiếp để xoay mượt, không dựng lại mô hình mỗi lần chuột di chuyển. Đã kiểm tra kéo chéo, thả chuột ngoài khung và giới hạn nghiêng trong Studio. Backup module trước sửa: `backups/EquipmentInventory_before_drag_20261015.luau` và StringValue cùng tên trong ServerStorage.

Chọn ô để xem trước, bấm TRANG BỊ để mặc. Vũ khí và năm món giáp của Người/Pet được chọn độc lập; thay vũ khí của chủ không đổi vũ khí pet. Giáp hiện là mô hình thử ngoại hình, chưa có chỉ số phòng thủ, cấp nâng, chế tạo hoặc giá tiền. Lựa chọn giữ khi hồi sinh trong cùng phiên; chưa lưu tài khoản qua DataStore.

## Mã nguồn

- **Giáp Pet mới 15/10/2026:** đã thay mẫu đơn giản bằng toàn bộ 128 chi tiết trong bốn bộ giáp người dùng gửi. Thợ săn/Da giữ sừng tự nhiên; Kim loại/Xương ẩn sừng, tháo mũ hiện lại sừng. Giáp cẳng tay và các tấm/gai đuôi theo đúng khớp. Icon và preview dùng cùng dữ liệu với món mặc thật. ID `Training` hiện có được giữ làm bí danh của `Hunter` để tương thích túi đồ. Bảng giáp Người tiếp tục dùng mẫu riêng.

- `src/dark-jungle/ArmorEquipment.luau`: bộ giáp, năm vị trí, lắp trên người/pet và tạo preview.
- `src/dark-jungle/EquipmentInventory.luau`: UI, viewport nhân vật/món đồ và yêu cầu trang bị.
- `studio-pet-integration/Training.server.luau`, `Training.client.luau`: nguồn chính xác đã lưu trong Studio. Bản `src/dark-jungle` cũng đã ghép cùng UI/trang bị, giữ các tính năng riêng vốn có.

Server kiểm tra target, loại trang bị, slot và ID; chỉ thay đồ khi ở bãi tập và cất vũ khí. Giáp gắn trên nhân vật không tạo va chạm hoặc neo nhân vật.

## Kiểm tra

- Play Studio: mở I, đổi tab, chọn/mặc/tháo giáp, preview Người/Pet; trang bị người Katana và pet Cung độc lập.
- Thay đủ năm món cho từng target, kiểm tra mười lựa chọn riêng, hồi sinh giữ lựa chọn và chỉ có một pet.
- Bốn mươi preview giáp (2 target × 4 bộ × 5 vị trí), kiểm tra danh mục và biên dịch mã đạt.
- Kiểm tra file `.rbxl` đã lưu khớp hai module mới và server/client; bộ bảy vũ khí Pro và tụ lực cung đạt. Q vẫn đánh mạnh, tụ lực chỉ giữ/nhả chuột trái.
- So với backup trước sửa: giữ nguyên 14.808 phần map và số instance Workspace. Output Studio không có lỗi trong lượt Play cuối.

Chạy từ thư mục HunDino:

```powershell
./tools/lune/lune.exe run tools/test-equipment-inventory.luau --saved
./tools/lune/lune.exe run tools/test-pet-armors.luau
./tools/lune/lune.exe run tools/test-bow-charge-restore.luau --saved
./tools/lune/lune.exe run tools/test-weapons-pro.luau
./tools/lune/lune.exe run tools/test-map-preservation.luau backups/HunDino_v2_3_before_inventory_split_20261015.rbxl HunDino_DarkJungle_v2_3.rbxl
```

Backup: `backups/HunDino_v2_3_before_inventory_split_20261015.rbxl`; nguồn trước sửa trong `backups/studio_before_inventory_split_20261015.json` và `backups/source_before_inventory_split_20261015.json`. Studio cũng có `ServerStorage.InventorySplitBackup_20261015`.

Backup trước giáp Pet mới: `backups/HunDino_v2_3_before_pet_armors_20261015.rbxl`, `backups/ArmorEquipment_before_pet_armors_20261015.luau` và StringValue cùng tên trong ServerStorage. Đã thử cả bốn bộ × năm món trong Play, đổi mũ qua nút UI, mặc/tháo riêng với Người không bị đổi, kiểm tra weld sau di chuyển đạt. `test-pet-armors.luau` kiểm tra đủ 128 part, màu/vật liệu, kích thước/offset, khớp gắn, phối bộ và ẩn/hiện sừng.
