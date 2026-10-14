# Nâng cấp katana theo mẫu — 15/10/2026

Đã sửa và lưu bằng Studio vào `HunDino_DarkJungle_v2_3.rbxl` trong thư mục Documents hiện tại. Có map sao lưu trước sửa tại `backups/HunDino_v2_3_before_katana_20261015.rbxl`; code Studio trước sửa tại `backups/studio_before_katana_20261015.json`. Trong Studio có bản sao katana, mẫu trưng bày và code sửa trong `ServerStorage.KatanaUpgradeBackup_20261015`.

## Nội dung đã ghép

- Model Main theo mẫu người dùng: cán đen, bốn vòng quấn đỏ, Kashira/Fuchi vàng, chắn tay hai lớp, Habaki, lưỡi hai đoạn cong nhẹ và mũi WedgePart. Lưỡi xanh Neon; 16 BasePart và 15 Weld.
- Main mới được dùng cho người chơi, pet và Display_Katana trong nhà vũ khí. Giữ vỏ kiếm hiện có, không thay các vũ khí còn lại.
- Pet chém với xoay thân ±0,45 rad và tay nghiêng theo tiến độ đòn như công thức mẫu. Giữ thời lượng 0,8 giây và mốc sát thương 45%.
- SlashTrail, SlashSparks và sóng kiếm xanh có PointLight được dựng phía client. Sóng bay 14 studs trong 0,35 giây rồi dọn sau 0,4 giây.
- Katana người chơi có Trail/Sparks và sóng theo windup/thời lượng đòn hiện hành; pet bật hiệu ứng theo thời điểm đánh đồng bộ từ server. Hiệu ứng tắt khi hết đòn hoặc đổi kiếm, và tuân theo ShowComboFX.
- Sóng chỉ là hình ảnh, không có va chạm/hitbox hay sát thương thêm. Không chạy vòng biểu diễn tự động của file mẫu.

Source mới: `src/dark-jungle/KatanaPro.luau`, `KatanaEffects.client.luau`. Đã cập nhật PetAnimator và Training.server (chỉ đánh dấu thời điểm VFX và tránh thêm Weld trùng). `studio-pet-integration/Training.server.luau` tiếp tục là source chính xác của bản đang mở; source Training ở `src/dark-jungle` giữ các cập nhật khác vốn có trong thư mục.

## Kiểm tra

- Biên dịch các source sửa đạt. Studio dựng/gắn katana pet với đúng 16 phần, 15 Weld và một Motor6D; đổi sang búa không còn Trail katana.
- Play: katana mới trên cả chủ và pet, vỏ kiếm còn nguyên. Một đòn thử tạo hai sóng (chủ/pet); Trail đã bật trong đòn và tắt khi nghỉ, không còn sóng sau khi dọn. Pet có xoay thân khoảng 0,466 rad.
- Sát thương thử giữ nguyên: chủ đánh thường 31, pet 12. Tắt ShowComboFX không sinh sóng; đổi vũ khí dọn sạch VFX. Output không có lỗi.
- Sau lưu: `tools/test-katana-upgrade.luau` xác nhận source/model/hiệu ứng được lưu, vỏ kiếm và sáu vũ khí khác giữ nguyên. 14.775 phần map ngoài mẫu trưng bày katana khớp bản sao lưu. Terrain chỉ được Studio lưu, Lune chỉ đọc kiểm tra.
- Chưa kiểm tra phiên nhiều client hoặc đánh giá hiệu năng nhiều pet cùng chém.

Thử trong Play: tới bãi tập, cất vũ khí bằng R, nhấn I chọn Katana rồi R rút. Đánh hình nộm để xem katana của chủ và pet.
