# Khôi phục tụ lực cung — 15/10/2026

<!-- TIEN_DO_20261027_BEGIN -->
> **Trạng thái đối chiếu 27/10/2026, 09:48 UTC+7:** local chính `HunDino_MerchantWeapons_20261026.rbxl` **4.495.025 byte**, SHA256 `8626bc714aa7a0da39493ba1bbcc676a142038b2f8a2c06e602fe01d522229bf`; inspector **129.779 kiểm / 164 source**, đạt. Cloud có bằng chứng mới nhất **v14**, nguồn **4.481.440 byte**; sửa bố cục ống mới chỉ local, **chưa Publish**.
>
> Tính năng trong tài liệu này được đối chiếu cùng bản chính hiện hành; các file v2.x/SaveGame, tham số và kết quả thử cũ trong phần dưới là mốc lịch sử, không tự chứng nhận toàn bộ bản mới. Phạm vi còn chờ: P1-G toàn vòng, cloud kinh tế/cá thể/ống, nhiều client và thiết bị thật.
>
> [Báo cáo tiến độ toàn dự án và hôm nay](BAO_CAO_TIEN_DO_2026-10-27.md). Ghi chú này cập nhật trạng thái; số liệu/hash của từng mốc cũ bên dưới giữ nguyên theo phạm vi lúc kiểm.
<!-- TIEN_DO_20261027_END -->

**Hiện hành 26/10/2026:** đã gộp vào **HunDino_MerchantWeapons_20261026.rbxl** theo lựa chọn người dùng. Tầm cung từ **40 → 120 studs** theo mức tụ; E hội tụ ba mũi **24 × 3 = 72** ở cấp 1, giữ nâng cấp riêng của cửa hàng. Sửa hướng bắn khi đi ngang, Pet che camera và hướng nhân vật khi xoay camera. Mở **CHOI_CUA_HANG.cmd** hoặc **CHOI_VA_LUU.cmd**; xem [BOW_PET_FIXES.md](BOW_PET_FIXES.md). Các thông số và tên bản cũ bên dưới ghi lịch sử từng mốc.

**Đồng bộ tài liệu: 20/10/2026 — đối chiếu bản v2.4 đã lưu ngày 19/10/2026.**

Điều khiển hiện hành trên [v2.4](HunDino_DarkJungle_v2_4.rbxl): **chỉ giữ/nhả chuột trái để tụ lực và bắn; Q đánh mạnh ngay, E kỹ năng; chuột phải ngắm**. Cất cung bằng R, chạy hoặc mở menu hủy tụ. Giữ bộ model/VFX [Pro](WEAPONS_PRO.md) và [combo](COMBOS_V2_3.md).

Phần dưới ghi quá trình sửa ngày 15/10: các phép đo tụ bằng Q là mốc đầu đã bị thay thế. Không dùng chúng làm hướng dẫn hiện hành hoặc kết quả thử lại trên v2.4.

## Hồ sơ sửa cung — 15/10/2026

**Điều chỉnh theo yêu cầu tiếp theo:** chỉ chuột trái tụ lực; Q bắn đòn mạnh ngay khi nhấn, E vẫn là kỹ năng. Server từ chối ChargeStart với Heavy. Đã kiểm tra Q thật không tụ lực, chuột trái vẫn tụ và combo HLS vẫn ra ba phát kết thúc. Các mô tả Trái/Q và hệ số tụ Q bên dưới là hồ sơ của lượt sửa đầu, đã được thay bằng điều khiển này.

Người dùng báo cung mất tụ lực sau cập nhật vũ khí. Bản đang mở trong Studio thiếu ChargeStart/ChargeRelease ở server và client, thiếu hàm tụ lực trong TrainingRules và cấu hình Bow.Charge. Source trong src/dark-jungle vốn có cơ chế này nhưng chưa có trong bản Studio đang mở.

Đã khôi phục riêng phần cung trên bản đang mở, giữ model/VFX Pro, thông số vũ khí, combo và các sửa khác. File lưu bằng Studio: `C:/Users/khanh/OneDrive/Documents/ChatGPT/game roblox/HunDino/HunDino_DarkJungle_v2_3.rbxl`.

- Giữ chuột trái hoặc Q để tụ, nhả để bắn; chạm nhanh vẫn bắn với lực thấp. Hiển thị TỤ LỰC % và ĐẦY LỰC.
- Đầy sau 1,2 giây. Hệ số tối đa: trái 3,6; Q 2,4. Giữ quá 4,2 giây tự nhả một phát.
- Server tính thời gian giữ và sát thương, tiêu hao thể lực đúng một lần khi bắt đầu. Token phát bắn tránh nhả trùng/nhả sai lượt; không nhận sát thương hay phần trăm lực do client gửi.
- Hủy khi cất, mở menu, mất focus, chạy, bị mất máu hoặc chết. Cất bằng R khi đang tụ được xử lý ngay trong cùng lần nhấn. Trong lúc tụ không nhận đòn đánh/đổi trang bị khác.
- Giữ điều khiển ngắm chuột phải, pet và VFX bảy vũ khí. VFX bắn chỉ bắt đầu khi nhả.

Source chính xác của bản đang mở ở `studio-pet-integration/Training.server.luau`, `Training.client.luau`, `TrainingRules.luau`, `Weapons.luau`. Không ghi đè source hiện đại hơn ở src/dark-jungle bằng bản này. Snapshot và map trước sửa nằm ở `backups/studio_before_bow_charge_restore_20261015.json` và `backups/HunDino_v2_3_before_bow_charge_restore_20261015.rbxl`; có thêm StringValue sao lưu trong ServerStorage.BowChargeRestoreBackup_20261015.

Kiểm tra:

- `tools/test-bow-charge-restore.luau`: biên dịch, tăng lực và giới hạn, chỉ trừ thể lực/nhả một lần, hủy và chặn hành động không hợp lệ. Dùng --saved để đối chiếu source đã lưu.
- Input thật qua Studio: HUD đầy lực xuất hiện khi giữ trái/Q. Với thông số của bản đang mở (trái 29, Q 66), phát đầy lực lần lượt gây 104 và 158. Phát chạm nhanh trong lượt thử gây 50, thấp hơn đầy lực.
- R khi giữ Q hủy tụ và cất, không bắn. Token sai bị chặn; hủy không bắn; giữ quá giới hạn gây đúng một phát 104; nhả lại không bắn thêm.
- Chết trong lúc tụ xóa Charging, hồi sinh bình thường và chỉ có một pet.
- Lần kiểm tra đầu dùng thông số sát thương của source khác và tọa độ input không phù hợp; đã kiểm tra lại bằng thông số của bản đang mở và input đúng vào viewport. Các lỗi đó thuộc lệnh kiểm tra tạm, không được lưu vào script game.

Cách thử hiện hành: R rút cung trong bãi tập, giữ chuột trái cho tới ĐẦY LỰC rồi nhả; Q bắn mạnh ngay, không tụ. Giữ chuột phải để ngắm trong khi tụ. Đây là hướng dẫn thử, không phải lượt kiểm chứng mới của đợt tài liệu.
