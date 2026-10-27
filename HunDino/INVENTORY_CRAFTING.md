# Chế bẫy sắt trong Inventory — 26/10/2026

<!-- TIEN_DO_20261027_BEGIN -->
> **Trạng thái đối chiếu 27/10/2026, 09:48 UTC+7:** local chính `HunDino_MerchantWeapons_20261026.rbxl` **4.495.025 byte**, SHA256 `8626bc714aa7a0da39493ba1bbcc676a142038b2f8a2c06e602fe01d522229bf`; inspector **129.779 kiểm / 164 source**, đạt. Cloud có bằng chứng mới nhất **v14**, nguồn **4.481.440 byte**; sửa bố cục ống mới chỉ local, **chưa Publish**.
>
> Công thức bẫy sắt Inventory đã có trong bản phát hành 27/10. Số 83.656 kiểm/157 script là mốc chế bẫy 26/10, không phải số kiểm của local mới nhất.
>
> [Báo cáo tiến độ toàn dự án và hôm nay](BAO_CAO_TIEN_DO_2026-10-27.md). Ghi chú này cập nhật trạng thái; số liệu/hash của từng mốc cũ bên dưới giữ nguyên theo phạm vi lúc kiểm.
<!-- TIEN_DO_20261027_END -->

Trong bản chính **HunDino_MerchantWeapons_20261026.rbxl**, mở **I → CHẾ TẠO**. Công thức: **1 bẫy thô + 1 sắt → 1 bẫy sắt**. Trang hiển thị mô hình bẫy sắt, số nguyên liệu `Hiện có / 1`, thanh đủ/thiếu nguyên liệu, số bẫy sắt trong kho và nút **CHẾ TẠO 1 BẪY SẮT**.

Có thể xem công thức từ xa. Nút chỉ hoạt động khi đứng gần bàn chế tạo tại base của chủ, đã cất vũ khí bằng R, không ở lượt săn và hồ sơ sẵn sàng. Mỗi lần bấm chế một bẫy; không tốn xu. Vật tư chế ra vào kho, không cộng vào phần đang mang trong chuyến săn cũ.

Server dùng công thức `CraftTrap` đã có; Inventory gửi token, SnapshotVersion và OperationSerial. Server kiểm lại vị trí, chủ base, trạng thái và nguyên liệu; lưu giao dịch trước khi xác nhận. Yêu cầu lặp/cũ hoặc thiếu một nguyên liệu không được trừ một phần hay nhận bẫy lần hai. Không mở thêm công thức nâng giáp/vũ khí hoặc chế tạo nhanh từ xa.

Đã thử bằng input thật trong Studio với TestMemory riêng: 2 bẫy thô/2 sắt/0 bẫy sắt → lần một 1/1/1 → lần hai 0/0/2; xu giữ 80, Revision tăng đúng hai lần. Nút khóa khi hết nguyên liệu và khi đứng xa bàn dù có đủ nguyên liệu. Không ghi tài khoản thật; cờ và script QA đã được gỡ trước lưu.

Kiểm tự động: `tools/test-inventory-crafting.luau` đạt 22 kiểm tra với handler server thật và dữ liệu giả (gồm sai token, snapshot/serial cũ, base khác, đang cầm vũ khí, đang săn và hồ sơ chưa sẵn sàng). Hồi quy nâng riêng bảy vũ khí lấy mã từ tệp đã lưu đạt 238 kiểm tra; đối chiếu các script chiến đấu/cửa hàng đạt 25 kiểm tra.

Backup trước sửa: `backups/inventory-crafting-20261026/`; hai script cũ giữ trong `ServerStorage.InventoryCraftBackup_20261026`. Bản chính được lưu bằng Roblox Studio native, **4.373.461 byte**, SHA256 `10ff67e69b8d8151c35160d7c5a4b918d85d54dbe7b804c835a5c848f55a535a`. Inspector đọc bản lưu đạt **83.656 kiểm tra / 157 script biên dịch**, chỉ hai source thay đổi, giữ fingerprint **47.064 Part / 723 khớp** và byte của **70 thuộc tính Terrain**, gồm VoxelGridAssetContentMap. Lune chỉ đọc, không xuất lại Place.

Bằng chứng: `assets/inventory-crafting/studio-play.json`, `saved-inspection.json`, `install.json`. Chưa Publish thay đổi này lên Roblox. Mở `CHOI_VA_LUU.cmd` hoặc `CHOI_CUA_HANG.cmd` để dùng đúng bản chính trên máy.
