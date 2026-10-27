# Inventory — Vật phẩm và mục Chế tạo

<!-- TIEN_DO_20261027_BEGIN -->
> **Trạng thái đối chiếu 27/10/2026, 09:48 UTC+7:** local chính `HunDino_MerchantWeapons_20261026.rbxl` **4.495.025 byte**, SHA256 `8626bc714aa7a0da39493ba1bbcc676a142038b2f8a2c06e602fe01d522229bf`; inspector **129.779 kiểm / 164 source**, đạt. Cloud có bằng chứng mới nhất **v14**, nguồn **4.481.440 byte**; sửa bố cục ống mới chỉ local, **chưa Publish**.
>
> Tab Chế tạo đã có công thức bẫy sắt, tab Khủng long có cá thể và chọn ống. Các mục “khung chờ/chưa lưu” bên dưới mô tả mốc ban đầu.
>
> [Báo cáo tiến độ toàn dự án và hôm nay](BAO_CAO_TIEN_DO_2026-10-27.md). Ghi chú này cập nhật trạng thái; số liệu/hash của từng mốc cũ bên dưới giữ nguyên theo phạm vi lúc kiểm.
<!-- TIEN_DO_20261027_END -->

**Cập nhật lớp lưu 20/10/2026:** v2.4 đã nối dữ liệu tiến trình vào hồ sơ tài khoản; xem [PERSISTENCE.md](PERSISTENCE.md) và thiết kế mục 39. Kiểm logic/Studio test đã có; nghiệm thu cloud qua thoát/vào còn chờ game xuất bản. Các câu chỉ giữ trong phiên và số liệu dưới đây thuộc mốc trước lớp lưu.

**Đồng bộ tài liệu: 20/10/2026 — đối chiếu bản v2.4 đã lưu ngày 19/10/2026.**

Inventory hiện có **Người / Pet / Vật phẩm / Khủng long / Chế tạo**. Vật phẩm và Khủng long dùng snapshot có phiên bản từ cùng hồ sơ bộ nhớ v2; chuyển vật tư vào lượt săn/trả về không tính hai lần. [Kho cá thể](SPECIMEN_COLLECTION.md) giữ qua hồi sinh/về sảnh trong cùng máy chủ; chưa lưu tài khoản. Các phép đo 139.097 ở cuối thuộc mốc Vật phẩm; bản lưu mới nhất sau kho cá thể có 139.120 kiểm tra theo báo cáo riêng.

Bản v2.4 đã gom phần xem vật phẩm vào **Inventory/Túi đồ** theo yêu cầu ngày 19/10/2026. Nhấn **I** hoặc biểu tượng **Túi đồ**, chọn **VẬT PHẨM**.

**Bổ sung kho cá thể P1-F — 19/10/2026:** thanh Inventory có thêm **KHỦNG LONG**. Mỗi lần bắt sống nhận một T-Rex với mã/số thứ tự riêng; xem thời điểm bắt UTC+7, Thường/Không hệ/kích thước 100% và xoay mô hình 3D tĩnh. Tổng kho thử tối đa 100; đầy vẫn săn hạ quái được, thao tác bắt bị chặn trước khi tiêu thuốc. Đã thử bắt thực, tự về sảnh và hồi sinh giữ cùng mã; phiên mới có 0 cá thể, **chưa lưu tài khoản**. Tab Chế tạo vẫn để chờ. Xem [hướng dẫn và kiểm chứng P1-F bước đầu](SPECIMEN_COLLECTION.md); các kết quả kiểm tra ở cuối tài liệu này thuộc mốc Vật phẩm trước đó.

- Da, răng, vảy khủng long; xương; sắt.
- Bẫy thô, bẫy sắt và thuốc ngủ.
- Số xu, cấp búa và số lượng từng món; bộ lọc Tất cả/Nguyên liệu/Vật tư săn.

Bẫy sắt và thuốc hiển thị **tổng đang sở hữu**, đồng thời ghi rõ **Trong túi / Mang đi săn**. Vật tư chuyển vào lượt săn hoặc trả về không bị tính hai lần. Số lượng lấy từ cùng một snapshot có phiên bản của máy chủ, cập nhật sau mua, nhặt, mổ, thưởng và tiêu hao; bỏ qua snapshot cũ. Đây là màn hình theo dõi, không có thao tác tự cấp hay dùng vật phẩm.

Tab **CHẾ TẠO** hiện chỉ có thông báo **Chưa triển khai**, chưa có công thức, nút chế hoặc giao dịch trong Inventory. Bản thử bàn chế tạo tại base từ P1-E vẫn giữ nguyên. Người/Pet, vũ khí/giáp và xem trước trang bị tiếp tục dùng như trước.

Đã bỏ nút **KHO NGUYÊN LIỆU** ở ngoài và dòng tổng nguyên liệu trên HUD mổ. Tiến trình mổ và thông báo nhặt đồ vẫn xuất hiện theo hành động. Inventory nằm trên HUD admin/Pet khi mở, đóng thì khôi phục lớp hiển thị và camera.

Kho hiện vẫn dùng bộ nhớ máy chủ của P1-E, chưa lưu tài khoản. Xem `HUNT_ECONOMY.md` cho nguồn vật phẩm và luật giao dịch.

Đã thử Play: tám món ban đầu; mua bẫy/thuốc cập nhật 1/1 và 60 xu; mang một thuốc vào săn vẫn tổng 1, trả về vẫn tổng 1; nhặt sắt hiển thị 1 và giữ khi bỏ cuộc. Snapshot cũ không ghi đè số mới. Bộ lọc hiện đúng 5 nguyên liệu/3 vật tư; Người/Pet/giáp xem trước vẫn hoạt động. Mục Chế tạo có 0 nút giao dịch. Source cuối đã thử lớp Inventory 100 khi mở và khôi phục 0 khi đóng, camera Custom. Chưa thử điện thoại đầy đủ.

Source: `src/dark-jungle/EquipmentInventory.luau`, `src/hunting/HuntEconomy.client.luau`, `src/hunting/HuntEconomyService.luau`. Backup: `backups/Hub_v24_before_inventory_items_20261019.rbxl` và ba source trong `ServerStorage.InventoryItemsBackup_20261019`. Báo cáo Play tại `assets/hunting/inventory-items-play.json`; inspector chỉ đọc bản lưu ghi `inventory-items-saved.json`.

Bản lưu native Studio đã qua **139.097 kiểm tra đọc/đối chiếu**, **111 script** biên dịch, **22 source chuẩn** khớp; **105 source cũ không liên quan** giữ nguyên và ba backup được đối chiếu đúng. Toàn bộ **43.775 Part/845 khớp** giữ nguyên, gồm **35.064 Part/723 khớp trong Workspace**. Không ghi lại Place/Terrain bằng Lune.
