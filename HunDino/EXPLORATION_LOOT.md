# Mổ lấy nguyên liệu khi Khám phá — 21/10/2026

Đã sửa trên Place cloud **HunDino** đang mở (`103261391098991`). Trước đây Khám phá có chiến đấu nhưng chỉ luồng nhận nhiệm vụ mới tạo controller mổ và sổ thưởng. Nay không cần nhận nhiệm vụ J để lấy nguyên liệu từ xác.

## Cách dùng

1. **Chơi → Khám phá Thung Lũng Sương Xám**, tham gia gây sát thương bằng vũ khí hoặc Pet.
2. Sau khi hạ T-Rex, đến gần xác, nhấn **R** cất vũ khí.
3. Giữ **G 1,5 giây** hoặc giữ nút Mổ xác, tối đa **3 lần/người/xác** trong **120 giây** sau khi hạ.
4. Mỗi lần nhận một phần da/răng/vảy ngẫu nhiên vào **I → Vật phẩm**.

Di chuyển, rút vũ khí, bị đánh, bay admin hoặc thả nút ngắt thao tác chưa xong và không mất lượt. Người vào sau khi quái chết hoặc không gây sát thương không được lấy từ xác đó. Người đã tham gia có phần mổ riêng; rời/vào lại cùng xác không mở thêm lượt.

Khám phá không dành bẫy/thuốc, tự cộng xu/xương thưởng nhiệm vụ, tăng thống kê nhiệm vụ hoặc cấp cá thể. Nguyên liệu đã lấy qua lớp lưu hiện hành. Nhiệm vụ J và bãi tập giữ luật cũ; chưa thêm chế tạo Inventory.

## Cách ghi nhận

`ExplorationHarvestService` ghi người tham gia từ đòn hợp lệ, gắn encounter vào đúng vòng quái và tạo run kinh tế `Mode="Exploration"` riêng cho người nhận. Ba claim mổ dùng receipt hiện có, ghi trước khi báo thành công và giữ cùng mã khi thử lại sau lỗi lưu. Đóng/phục hồi run khám phá không tăng số nhiệm vụ thất bại. Khi người chơi ngắt kết nối, runtime được dọn sau thao tác đang ghi; phục hồi hồ sơ xử lý ledger còn dang dở.

## Kiểm chứng

- Kinh tế khám phá: **227 kiểm tra / 10 nhóm đạt**. Hồi quy kinh tế **2.272 / 35**, schema **682 / 13**, roundtrip **549 / 6**, store **160 / 11** đạt.
- Mổ cũ: **121 kiểm tra / 21 tình huống native đạt**. Tích hợp khám phá: **25 kiểm tra native đạt**, gồm nhiều contributor, người vào muộn, reset, rời/vào lại, hủy mổ, chờ lưu và ngắt kết nối khi profile không còn sẵn sàng.
- Play thật bằng **TestMemory bật tạm**: vào Khám phá, đòn búa hợp lệ gây **1.200 sát thương**, hạ T-Rex rồi giữ G ba lần nhận **2 da + 1 vảy**, hiện đúng trong Inventory. Lần thứ tư không tăng. Về sảnh đóng run; vào lại quái reset 1.200 HP và không có quyền mổ. Save/release/load trên backend thử giữ ba nguyên liệu. Xu vẫn 80, xương và ba thống kê săn vẫn 0.

QA hỗ trợ đặt vị trí và tạm tăng HP người lên 1.000, đã trả 100; không đặt HP quái hoặc dùng mã admin. Không ghi vào tài khoản thật và không coi TestMemory là nghiệm thu DataStore thật. Override đã gỡ khỏi Edit.

Nguồn: `src/hunting/ExplorationHarvestService.luau`, `HuntQuestService.luau`, `HuntHarvestController.luau`, `HuntEconomyRules.luau`, `HuntEconomyService.luau`, `HuntEconomy.client.luau`, `src/data/ProfileSchema.luau`.

Backup native trước sửa: `backups/Hub_before_exploration_loot_20261021.rbxl` (**4.285.326 byte**); sáu source giữ tại `backups/exploration-loot-20261021/` và `ServerStorage.ExplorationLootBackup_20261021`. Bản xuất mới `HunDino_ExplorationLoot_20261021.rbxl` (**4.307.744 byte**, SHA256 `db5e9bb423f6cca6557e54a15be7b26897d8ee30251235b644c69cd0f4338b20`); bằng chứng `assets/hunting/exploration-loot-play.json`, đối chiếu `assets/hunting/exploration-loot-saved.json`. Công cụ chỉ đọc Place/Terrain, không ghi lại bằng Lune.

Studio được dùng chung với lượt dọn HUD: bản sao này giữ thêm bốn source HUD và bốn backup tương ứng. Inspector kiểm riêng từng source chuẩn cùng nội dung gốc, thuộc tính `OriginalPath` của backup; không coi đó là source do sửa khám phá tạo ra. Chạy `prepare-exploration-loot-install.luau`, sau đó `include-shared-hud-validation.luau` để tạo lại inspector cho bản kết hợp. Kiểm nhanh bản native đạt **27 checks / 130 script biên dịch**, xác nhận bảy source khám phá, bốn source HUD, các backup và đã gỡ override thử.

Đối chiếu native cuối **PASS**: toàn bộ scene hiện có giữ nguyên ngoài những source đã xác nhận; không có khác biệt thuộc tính ngoài phạm vi. Giữ **43.775 Part / 845 Joint**, trong Workspace **35.064 Part / 723 Joint**, cùng hash các payload Terrain nhị phân. Bảy source khám phá và bốn source HUD khớp bản chuẩn; sáu backup khám phá và bốn backup HUD khớp nguồn trước sửa. Training server giữ nguyên. Báo cáo chi tiết và số lượt kiểm tra nằm trong `assets/hunting/exploration-loot-saved.json`.

Đã lưu trong Studio; chưa Publish lên game live. Chưa thử nhiều client thật hoặc điện thoại.
