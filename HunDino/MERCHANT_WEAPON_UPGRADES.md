# Sửa cửa hàng và cấp riêng từng vũ khí — 26/10/2026

<!-- TIEN_DO_20261027_BEGIN -->
> **Trạng thái đối chiếu 27/10/2026, 09:48 UTC+7:** local chính `HunDino_MerchantWeapons_20261026.rbxl` **4.495.025 byte**, SHA256 `8626bc714aa7a0da39493ba1bbcc676a142038b2f8a2c06e602fe01d522229bf`; inspector **129.779 kiểm / 164 source**, đạt. Cloud có bằng chứng mới nhất **v14**, nguồn **4.481.440 byte**; sửa bố cục ống mới chỉ local, **chưa Publish**.
>
> Cấp riêng bảy vũ khí và cửa hàng đã nằm trong đợt Publish 27/10, cloud v14 thêm sửa hồ sơ; các hash/kiểm tra cửa hàng bên dưới thuộc mốc triển khai riêng.
>
> [Báo cáo tiến độ toàn dự án và hôm nay](BAO_CAO_TIEN_DO_2026-10-27.md). Ghi chú này cập nhật trạng thái; số liệu/hash của từng mốc cũ bên dưới giữ nguyên theo phạm vi lúc kiểm.
<!-- TIEN_DO_20261027_END -->

**Bản chính hiện hành:** người dùng đã chọn ghép cung/Pet/di chuyển vào **HunDino_MerchantWeapons_20261026.rbxl**. Đã ghép và lưu native; mở **CHOI_CUA_HANG.cmd** hoặc **CHOI_VA_LUU.cmd**. Chi tiết bản gộp và kiểm chứng: [BOW_PET_FIXES.md](BOW_PET_FIXES.md), thiết kế mục 42. Chưa xuất bản bản gộp lên Roblox.

Theo lệnh tiếp theo ngày 26/10, **I → CHẾ TẠO** đã có công thức **1 bẫy thô + 1 sắt → 1 bẫy sắt**, giao dịch tại bàn base chủ. Bản lưu và bằng chứng mới nhất ở [INVENTORY_CRAFTING.md](INVENTORY_CRAFTING.md), thiết kế mục 43; các số liệu ghép bên dưới là mốc trước lần thêm công thức này.

Các số liệu cửa hàng dưới đây thuộc mốc trước khi ghép (4.368.355 byte). Bản cửa hàng trước ghép được giữ tại `backups/bow-pet-20261026/HunDino_MerchantWeapons_20261026.rbxl`.

## Hành vi đã sửa

- Icon Cửa hàng và quầy thương nhân dùng cùng một bảng, gồm **Vật tư & chế tạo** và **Nâng cấp vũ khí**. Bỏ bảng hướng dẫn cũ; sửa thứ tự ZIndex của nội dung và lớp nền. Danh sách đủ bảy vũ khí vừa trong bảng, không cắt hàng cuối.
- Mua bẫy thô/thuốc ngủ tại thương nhân; chế bẫy và nâng cấp tại bàn ở **base của chủ**. Có thể xem từ xa; nút giao dịch chỉ mở khi server xác nhận đúng vị trí, cất vũ khí, hồ sơ sẵn sàng và đủ tài nguyên.
- Búa, Kiếm & khiên, Katana, Thương cán dài, Song dao, Cung và Rìu đại có **cấp riêng của Người**. Mỗi loại lên cấp 2 bằng **2 xương + 2 sắt**, tăng **15% sát thương của đúng loại đó**. Không dùng cấp búa để tăng mọi vũ khí; Pet giữ luật sát thương hiện hành.
- `Economy.WeaponLevels` lưu bảy cấp; `HammerLevel` được giữ tương thích hồ sơ cũ. Dữ liệu cũ thiếu bảng cấp được chuyển an toàn, giữ xu, nguyên liệu, receipt, cá thể và cấp búa. Cấp búa được server cũ nâng hợp lệ vẫn được tiếp nhận; dữ liệu cấp không hợp lệ không trở thành hồ sơ trắng.
- Giao dịch nâng cấp do server kiểm tra vũ khí, token giao dịch, `SnapshotVersion`, operation serial, ngữ cảnh và khoảng cách. Lưu xác nhận trước khi báo thành công; không trừ tài nguyên lần hai khi gửi lại.
- Bỏ hoàn toàn thanh **Đã lưu / LƯU** thường trực trong ảnh 3. Server vẫn tự lưu và lưu khi giao dịch/thoát. Giữ bảng chặn khi chưa tải được hồ sơ để tránh ghi đè tài khoản thật; Save game trong Cài đặt vẫn có.

## Kiểm chứng

- Studio Play dùng **TestMemory riêng**, không cấp/trừ vật phẩm hay ghi vào tài khoản thật: bấm icon, mua hai vật tư, chế bẫy, nâng đủ bảy loại, đối chiếu cấp/sát thương độc lập và badge Inventory. JSON round trip native giữ đủ bảy cấp.
- Phiên thử cuối xác nhận hàng thứ bảy hiển thị đầy đủ và bấm nâng Rìu đại được; refresh cửa hàng không chặn cú mua ngay sau đó. Năm yêu cầu sai token, sai phiên bản, sai serial, sai vũ khí hoặc đứng ở base khác đều không làm đổi dữ liệu.
- Bảng vừa viewport desktop và **HD 720 (1279×719/720)**, dùng `CoreUISafeInsets`; không có thanh lưu thường trực. Studio đã về viewport mặc định. Chưa chứng nhận thiết bị cảm ứng/portrait.
- Bài mới `test-weapon-upgrades.luau`: **238 kiểm tra** đạt trên cả source chuẩn và source biến thể đúng bản native, gồm qua lần tải của phiên server khác và replay sau tải lại.
- Hồi quy: kinh tế **2.272**, profile schema **682**, JSON/store round trip **549**, session store **160**, mã thưởng **243**, luật nhiệm vụ **231** kiểm tra đạt. `test-hunt-capture.luau` cần môi trường Studio, không chạy được trực tiếp dưới Lune; không dùng lần gọi đó để tuyên bố hồi quy bắt sống đầy đủ.
- Inspector chỉ đọc `inspect-merchant-saved.luau`: **523 kiểm tra / 146 script biên dịch**, fingerprint toàn bộ Workspace/Part/Joint khớp, giữ **47.064 BasePart thường** và **723 JointInstance/WeldConstraint**; **66 thuộc tính Terrain đọc được** khớp. Lune chưa hỗ trợ `Terrain.VoxelGridAssetContentMap`, không chứng nhận riêng thuộc tính đó. Place/Terrain chỉ được lưu native Studio.
- Cảnh báo asset `rbxassetid://203785492` sai loại xuất hiện sẵn trong bản nền; không thuộc lần sửa cửa hàng.

Bằng chứng: `assets/merchant-weapons/studio-play.json`, `saved-inspection.json`. Bản gốc và source trước sửa: `backups/merchant-weapons-20261026/`; bảy script nhúng cũ: `ServerStorage.MerchantWeaponsBackup_20261026`. Cờ TestMemory và script điều khiển QA đã được gỡ khỏi bản phát hành.

## Ghi chú kỹ thuật của lần gộp đã hoàn thành

Server sau ghép là `src/savegame/TrainingMerchant.server.luau`: giữ các sửa chiến đấu và dùng `economy:DamageMultiplier(s.Player,s.WeaponId)` cùng HuntEconomyService/Rules của cửa hàng. Sát thương cung lên hình nộm và khủng long đều nhận hệ số của đúng vũ khí; đã thử E cấp 1 = 72, cấp 2 = 84. Sáu script cửa hàng/UI/lưu khác giữ nguyên source của bản cửa hàng. Đã dừng QA, gỡ probe/cờ test và kiểm lại source, hình học, Terrain sau lưu; báo cáo tại `assets/qa/bow-pet-merchant-saved.json`.

Đối chiếu phối hợp hai chat ngày 26/10: `tools/audit-merged-merchant.luau` đạt **25 kiểm tra** trên tệp chính, xác nhận đủ sáu source cửa hàng, chín source chiến đấu, hệ số đúng vũ khí, HUD lưu ẩn và hai launcher cùng mở bản chính. `tools/test-weapon-upgrades.luau --saved HunDino_MerchantWeapons_20261026.rbxl` đạt **238 kiểm tra với luật kinh tế/schema lấy trực tiếp từ tệp đã lưu**. Inspector bản gộp được chạy lại và vẫn đạt **83.644 kiểm tra / 155 script**, SHA256 `6265cf48569a69fe28b7700704685d132fd3be4b569195378e5bc90d9325729e`; bản native không cần sửa thêm. Bằng chứng độc lập: `assets/merchant-weapons/merged-source-audit.json` và `merged-coordination-saved.json`. Bản gộp chưa Publish lên Roblox.
