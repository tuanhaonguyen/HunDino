# Khủng long nghỉ 60 giây và phản công H1.3 — 17/10/2026

**Đồng bộ tài liệu: 20/10/2026 — đối chiếu bản v2.4 đã lưu ngày 19/10/2026.**

Combat H1.3.1 hiện dùng trong [v2.4](HunDino_DarkJungle_v2_4.rbxl) trên H2.0: **1.200 HP**, cắn **24**, báo trước **0,95 giây**, chu kỳ bắt đầu cắn **3,5 giây**; nghỉ **60 giây thật** ở các điểm. Pet đã hỗ trợ đánh/hồi máu; nhiệm vụ đã có bắt khi quái sống **≤120 HP**, cùng mổ/thưởng và cá thể. Xem [Pet](PET_COMPANION.md), [nhiệm vụ](HUNT_QUEST.md), [kinh tế](HUNT_ECONOMY.md) và [kho cá thể](SPECIMEN_COLLECTION.md).

Số đo/hash các lượt H1.3/H1.3.1 bên dưới giữ đúng mốc; đợt này không đánh giá lại cân bằng hoặc thử combat mới.

**Cảnh quan H2.0 — 19/10/2026:** combat H1.3.1 được giữ trên Thung Lũng Sương Xám 4.000 × 4.500; kiểm tra tích hợp và đòn bắn/phản công trong Play đạt. Xem [map và bằng chứng H2](GREY_MIST_VALLEY.md). Các lượt đo cân bằng bên dưới vẫn thuộc mốc H1.3.1.

**Điều chỉnh hiện hành H1.3.1 — 17/10:** theo góp ý cú cắn/lướt quá nhanh/ngắn, báo trước tăng **0,65 → 0,95 giây**, chu kỳ bắt đầu hai đòn tăng **2,5 → 3,5 giây**. Lướt tăng tốc đầu **42 → 72**, thời lượng **0,4 → 0,5 giây**, vẫn tốn 6 thể lực. Đo client thực tế đi khoảng **16,5–16,8 studs** trên nền phẳng; né ngang ở cảnh báo lượt hai không nhận thêm cú cắn. Hành động vũ khí đang hồi vẫn khóa lướt như trước; lướt trễ không có bất tử.

96/96 kiểm tra combat và kiểm tra dash sau Save đạt; nguồn/hình học sau lưu khớp. Bằng chứng `assets/hunting/combat-pacing-h131.json`, `connected-saved.json`. Backup `backups/Hub_before_combat_pacing_20261017.rbxl`; bản mới 1.462.171 byte, SHA256 `9d78835d16b96b8b40432d98d143c91c1a8aa8544beea9aa1612155633e24010`. Số cân bằng/hash H1.3 bên dưới giữ làm hồ sơ trước điều chỉnh.

Mở **HunDino_DarkJungle_v2_4.rbxl** trong thư mục Documents hiện tại. Bản chung đã lưu bằng Roblox Studio, gồm sảnh, bãi tập và Thung Lũng Sương Xám. File săn riêng H1.1 không sửa trong đợt này.

## Cách thử

1. Play → nhấn J tại sảnh để nhận nhiệm vụ; hoặc Chơi → Vào khu săn để thám hiểm khi chưa có nhiệm vụ. Trong Studio có thể nhấn M chọn A khi đã cất vũ khí.
2. Con mẫu nghỉ **60 giây thực** ở điểm xuất phát và mọi lần dừng tại A/B/C/R1–R5. HUD hiển thị số giây còn lại. Đồng hồ sáng/tối vẫn chạy 30 lần; phút nghỉ này không bị chia theo giờ rừng.
3. Nhấn I chọn vũ khí khi đã cất, R rút/cất; chuột trái đánh thường, Q đánh mạnh, E kỹ năng. Cung giữ trái tụ lực, nhả để bắn. Thanh máu xuất hiện phía trên khủng long khi tới gần.
4. Khủng long không tự đánh người chỉ đi ngang. Đòn vũ khí trúng hợp lệ mới khiến nó đuổi người đánh. Khi hiện vùng màu cam và cảnh báo, chạy/lướt sang bên để tránh cú cắn. Đòn có vùng trúng thật, kiểm tra hướng và vật cản; một cú chỉ gây sát thương một lần.
5. Khi người bị đuổi rời khu săn, chết, chạy quá xa hoặc ngừng gây sát thương đủ lâu, khủng long bỏ mục tiêu và quay lại vị trí tuyến bị gián đoạn. Tiếp tục thời gian nghỉ còn lại nếu đang nghỉ.

## Thông số mẫu có thể chỉnh

| Thuộc tính | Bản thử |
| --- | --- |
| Máu khủng long | 1.200 HP |
| Nghỉ ở mọi điểm | 60 giây thực |
| Sát thương cắn | 24 HP |
| Báo trước / cửa sổ trúng | 0,95 / 0,18 giây |
| Hồi chiêu cắn | 3,5 giây |
| Tốc độ đuổi / giới hạn xa điểm rời tuyến | 16 studs/giây / 260 studs |
| Ngừng bị đánh để bỏ mục tiêu | 25 giây |

Máu dùng chung cho một con mẫu trong máy chủ; vào thêm không tự hồi HP. Khi khu săn trống, luồng phiên đặt lại con mẫu và vị trí A. Trong nhiệm vụ P1-D, HP bằng 0 khóa Defeated, bắt thành công khóa Captured; AI/đòn đánh dừng theo kết quả, mở 120 giây thu hoạch rồi đóng lượt. Pet đã hỗ trợ đánh/hồi máu P1-C và dừng đánh khi cho uống. P1-E cấp thưởng/nguyên liệu, P1-F bước đầu cấp cá thể trong bộ nhớ; chưa có lưu tài khoản hoặc con thứ hai/thứ ba.

## Cấu trúc và kiểm chứng mốc H1.3/H1.3.1

- `src/hunting/DinosaurCombat.luau` tạo thanh máu và bốn hurtbox thân/đầu/hai chân, cùng hitbox cắn sát đất khi Play. Query-only, không đẩy/kẹt nhân vật; không lưu thêm part vào rig gốc. Thuộc tính `ShowCombatHitboxes=true` trên model chỉ dùng xem vùng trúng để chỉnh.
- `DinosaurCombatConfig.luau` chứa cân bằng mẫu. `ConnectedHuntingConfig.luau` đặt `RestSeconds=60`. `DinosaurRouteController.luau` là bộ duy nhất điều khiển thân/khớp, chuyển giữa tuần tra, phản công và trở về tuyến; kiểm tra nền, độ dốc, vách đá và vùng trại.
- Source cài cho vũ khí/UI là `studio-pet-integration/Training.server.luau`, `Training.client.luau`, `TrainingRules.luau` cùng `src/dark-jungle/EquipmentInventory.luau`. Server tính sát thương từ thông số vũ khí hiện có, xác minh khu săn, tầm đánh, góc/LOS và token chống trúng lặp; không có remote cho client tự gửi sát thương. Loạt cung ở khu săn cách nhau ít nhất 0,09 giây khi không có nhịp riêng.
- `tools/test-hunting-combat-rules.luau`: **6/6 nhóm đạt**, gồm cả bảy vũ khí, combo, tụ lực, cooldown và đổi trang bị.
- `tools/test-dinosaur-combat.luau`: **96/96 kiểm tra đạt** trên bản sao, đủ phút nghỉ ở cả tám khu, sát thương, cảnh báo, né, hồi chiêu, che khuất, người đi ngang, thoát phiên và chết/reset. Vì command context không được tạo Player, riêng bản sao module trong bài thử dùng table player; các kiểm tra phiên/nhân vật/biên/vùng trại vẫn chạy source thật. Module cài đặt không đổi guard Player; Play dùng người chơi thật kiểm tra đường nối vũ khí.
- Play thực: không đánh thì không bị tấn công; búa trừ **36**, cung tụ lực trừ **104**, loạt ba tên trừ đủ **72**. Khủng long đuổi và cắn người đánh; về sảnh trong đợt phản công hủy mục tiêu/đòn chờ và hồi trạng thái khi không còn ai săn. Nhân vật có hồi máu thông thường; bài thử cô lập xác nhận mỗi cú cắn trừ đúng 24.
- Đọc file sau Save đạt: **23.693 part toàn cảnh** khớp backup trước combat; rig vẫn 255 part, 21 MeshPart, 7 Motor6D, 247 WeldConstraint, một thân neo; 14 source không liên quan giữ nguyên so với trước nối sảnh, 14 source hiện hành khớp file làm việc, 44 script biên dịch được. Lune chỉ đọc; Terrain vẫn lưu native bằng Studio.

Chưa thử nhiều client thực, điện thoại hoặc cân bằng chiến đấu toàn game. Bản này kiểm chứng một người chơi trên PC; các thông số trừ 60 giây nghỉ là cấu hình mẫu để tiếp tục góp ý.

Kết quả: `assets/hunting/combat-validation.json`, `connected-saved.json`; ảnh `dinosaur-healthbar-h13.jpg`.

Backup trước sửa: `backups/Hub_before_dinosaur_combat_20261016.rbxl`, SHA256 `929616298209c19cd2f2ddcbf53ed2ee4afdd25f8b1e9fe3edc4ec58657efc54`.

Bản H1.3 đã lưu: **1.462.000 byte**, SHA256 `009525a65a74300cc9a968cfcfd2888757cfd64bbc0cf42c353209c878f98e89`.

Không đồng bộ cấu hình Rojo L0 hay chạy lại bộ dựng trên map đã sửa thủ công.
