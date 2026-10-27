# Pet đứng — cập nhật 14/10/2026

<!-- TIEN_DO_20261027_BEGIN -->
> **Trạng thái đối chiếu 27/10/2026, 09:48 UTC+7:** local chính `HunDino_MerchantWeapons_20261026.rbxl` **4.495.025 byte**, SHA256 `8626bc714aa7a0da39493ba1bbcc676a142038b2f8a2c06e602fe01d522229bf`; inspector **129.779 kiểm / 164 source**, đạt. Cloud có bằng chứng mới nhất **v14**, nguồn **4.481.440 byte**; sửa bố cục ống mới chỉ local, **chưa Publish**.
>
> Rig/trang bị đứng là nền; Pet hiện đã đồng hành và combat theo sửa 26/10. Bố cục ống base vừa sửa local không đổi rig Pet.
>
> [Báo cáo tiến độ toàn dự án và hôm nay](BAO_CAO_TIEN_DO_2026-10-27.md). Ghi chú này cập nhật trạng thái; số liệu/hash của từng mốc cũ bên dưới giữ nguyên theo phạm vi lúc kiểm.
<!-- TIEN_DO_20261027_END -->

**Đồng bộ tài liệu: 20/10/2026 — đối chiếu bản v2.4 đã lưu ngày 19/10/2026.**

Rig Pet đứng/hoạt ảnh được kế thừa trong [v2.4](HunDino_DarkJungle_v2_4.rbxl). Người/Pet đã chọn vũ khí và giáp **độc lập** trong [Inventory](INVENTORY.md). [Pet P1-C](PET_COMPANION.md) hiện có tìm đường quanh vật cản, hỗ trợ đánh 12 mỗi 4 giây, 100 HP/choáng 30 giây và gọi hồi 70% bằng H, hồi chiêu 119 giây; giữ dữ liệu trong cùng máy chủ. Pet dừng đánh khi chủ cho uống thuốc bắt. Các câu dùng chung vũ khí/chưa tìm đường bên dưới chỉ mô tả mốc 14/10.

## Hồ sơ rig và kiểm chứng — 14/10/2026

Đã sửa và lưu bằng Roblox Studio vào bản đang mở của người dùng:
`C:/Users/khanh/OneDrive/Documents/ChatGPT/game roblox/HunDino/HunDino_DarkJungle_v2_3.rbxl`.
Bản Desktop không được ghi đè trong đợt này.

## Hoạt động hiện tại

- Thay mô hình pet cũ bằng PetStanding: mũ, giáp, 12 Motor6D và điểm gắn vũ khí hai tay.
- Server tạo pet và vũ khí; LocalScript HunDinoPetAnimation chạy tư thế trong PreSimulation cho các pet đã tải. Client không nhân bản pet hoặc quyết định sát thương.
- Có tư thế chờ, vung chân khi theo chủ, chuyển động đầu/đuôi và bốn kiểu đánh của PetAnimator.
- Pet dùng cùng loại vũ khí với chủ; đổi bằng chức năng chọn vũ khí hiện có. Giữ tổng Config.PetDamage và Config.PetInterval. Song dao chia tổng sát thương thành hai mốc trúng.
- Server kiểm tra mục tiêu, trạng thái người chơi, khoảng cách và vật cản tại mỗi mốc trúng. Đòn cung của chủ cũng đặt mục tiêu cho pet; cung pet dùng hiệu ứng Shot hiện có.
- Dò mặt đất để đặt chân khi xuất hiện, theo chủ, chuyển khu và được đưa về trại sau khi rơi. Chưa bổ sung tìm đường vòng vật cản.
- Khớp gắn vũ khí nằm trong mô hình vũ khí, tự bị xóa khi đổi. Mốc trúng được xử lý cả khi cập nhật vượt hết thời lượng đòn đánh.

## Source và bản sao

- Module/LocalScript dùng chung: `src/dark-jungle/PetStanding.luau`, `PetAnimator.luau`, `PetPlacement.luau`, `PetAnimation.client.luau`.
- Code Training và Traversal chính xác của bản Studio vừa lưu: `studio-pet-integration/Training.server.luau`, `studio-pet-integration/Traversal.server.luau`.
- Source Training trong `src/dark-jungle` vốn có những cập nhật khác với bản người dùng đang mở. Đã thêm cùng tích hợp pet vào source này, giữ các cập nhật khác; không dùng nó ghi đè toàn bộ Training trong Studio.
- Map trước sửa: `backups/HunDino_v2_3_before_standing_pet_20261014.rbxl`.
- Code Studio trước sửa: `backups/studio_before_standing_pet_20261014.json`, đồng thời có StringValue trong `ServerStorage.PetIntegrationBackup_20261014`.
- Source thư mục trước sửa: `backups/source_before_standing_pet_20261014.json`.
- Không dùng default.project.json của L0 để đồng bộ map hiện tại.

## Đã kiểm tra

- Lune: biên dịch các file sửa, bind rig đầy đủ/chưa tải hết, bốn kiểu đánh với khung hình thường và khung hình dài, không lặp mốc trúng, hủy đòn và destroy.
- Studio: bảy vũ khí dựng/gắn thành công, đổi qua lại không tích Motor6D, mốc trúng không mất khi Update vượt thời lượng đòn.
- Play: hoạt ảnh client có Transform khác identity; pet theo chủ khoảng 12 studs; chọn đủ bảy vũ khí qua remote hiện có; hồi sinh chỉ có một pet.
- Play: búa gây 12 sát thương; song dao gây tổng 12; cung gây thêm 12 và có vũ khí trên tay trái. Chuyển trại/bãi tập hoạt động, chân về trại khớp mặt đất, Output không có lỗi.
- Trước/sau sửa trong Studio: 14.784 BasePart, 15.611 Workspace descendants và fingerprint hình học 607621414 giữ nguyên.
- File lưu bằng Studio được đối chiếu với map sao lưu bằng test-map-preservation.luau; toàn bộ phần hình học và số instance Workspace được giữ nguyên. Lune chỉ đọc file, không ghi lại Terrain.
- Chưa chạy phiên nhiều client; không đánh dấu kiểm chứng nhiều người chơi hoặc hiệu năng 12 pet.

Thử lại trong Studio bằng Play, chọn vũ khí như trước, đánh hình nộm để pet tham gia. Pet hiện là bản hoạt ảnh thử để tiếp tục chỉnh cảm giác chuyển động và tư thế từng vũ khí.
