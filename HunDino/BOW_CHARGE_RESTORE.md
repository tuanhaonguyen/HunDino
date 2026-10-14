# Khôi phục tụ lực cung — 15/10/2026

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

Thử lại: R rút cung trong bãi tập, giữ chuột trái hoặc Q cho tới ĐẦY LỰC rồi nhả. Giữ chuột phải để ngắm trong khi tụ.
