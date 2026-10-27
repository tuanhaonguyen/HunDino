# Bay xem map dành cho admin

**Đồng bộ tài liệu: 20/10/2026 — đối chiếu bản v2.4 đã lưu ngày 19/10/2026.**

Tiện ích bay tiếp tục dùng trên [bản v2.4](HunDino_DarkJungle_v2_4.rbxl), chỉ dành cho tài khoản được máy chủ cấp quyền. Khi bay, Pet chờ dưới đất; đặt bẫy, cho uống và mổ bị ngắt. Xem [nhiệm vụ/bắt](HUNT_QUEST.md), [kinh tế](HUNT_ECONOMY.md) và [Pet](PET_COMPANION.md) cho các tương tác đã nối sau mốc admin.

Các số 85/83.012 và hạn chế thử lệnh chat ở cuối là bằng chứng của đợt admin ngày 19/10; đợt đồng bộ này chỉ sửa tài liệu, không thử bay lại. Bản lưu mới nhất được đối chiếu tại [kho cá thể P1-F](SPECIMEN_COLLECTION.md).

Bản hiện hành: **HunDino_DarkJungle_v2_4.rbxl**, trong thư mục `Documents/ChatGPT/game roblox/HunDino`. Đây là tiện ích tạm để xem nhanh cảnh quan; nút **Bay xem map** nằm ở giữa phía trên màn hình và chỉ hiện cho tài khoản được cấp quyền.

Server cho phép **UserId 11605296816** và chủ experience nếu experience thuộc tài khoản cá nhân. Game thuộc nhóm không tự cấp quyền cho thành viên nhóm. Danh sách nằm trong [`src/admin/AdminFlyPolicy.luau`](src/admin/AdminFlyPolicy.luau); không cấp quyền chỉ vì đang chạy Studio.

Trong phiên thử hiện tại, Roblox báo chat không khả dụng tại khu vực của tài khoản. Khi gặp thông báo này, dùng nút **Bay xem map / Dừng bay**; lệnh `/fly` cần chat Roblox khả dụng.

| Thao tác | Nút hoặc phím |
| --- | --- |
| Bật/tắt bay | **Bay xem map / Dừng bay**, hoặc chat `/fly` |
| Bật / tắt rõ ràng | `/fly on` / `/fly off`; `/unfly` cũng tắt |
| Chọn tốc độ | Nút **80 / 160 / 260** studs/giây; mặc định **160** |
| Chọn tốc độ và bật bay | `/fly 80`, `/fly 160`, `/fly 260` |
| Di chuyển theo hướng camera | **W A S D** |
| Lên / xuống | **Space hoặc E** / **Ctrl trái hoặc Q** |
| Bay nhanh gấp đôi | Giữ **Shift trái** |
| Xoay camera | Điều khiển camera Roblox thông thường |

Màn hình cảm ứng có thêm nút **Lên / Xuống** khi bay. Mở chat, menu hoặc mất focus thì dừng nhận hướng di chuyển. Khi tắt bay, nhân vật được đưa về mặt đất phù hợp bên dưới; nếu phía dưới là nước hoặc nằm ngoài khu săn thì trở lại điểm bắt đầu bay. Chuyển khu hoặc hồi sinh sẽ kết thúc bay. Các hành động chiến đấu thông thường tạm dừng khi bay xem map.

**Tắt tạm:** dừng Play, mở `ServerScriptService.AdminFly.AdminFlyPolicy`, đổi `Enabled = true` thành `Enabled = false`, lưu rồi chạy Play lại. Bật lại bằng `true`.

**Gỡ hoàn toàn:** dừng Play và xóa đúng hai đối tượng trong Explorer:

1. Folder **`ServerScriptService.AdminFly`** — chứa `Main` và `AdminFlyPolicy`.
2. LocalScript **`StarterPlayer.StarterPlayerScripts.HunDinoAdminFly`**.

Lưu file và Play lại. Remote, lệnh chat và HUD được tạo lúc chạy nên không cần xóa thêm đối tượng đã lưu. Các nhánh kiểm tra `AdminFlying` trong code chiến đấu/di chuyển sẽ không hoạt động khi tiện ích đã gỡ.

Source chuẩn: [`AdminFly.server.luau`](src/admin/AdminFly.server.luau), [`AdminFly.client.luau`](src/admin/AdminFly.client.luau), [`AdminFlyPolicy.luau`](src/admin/AdminFlyPolicy.luau). Phần phối hợp với game nằm trong [`Training.server.luau`](studio-pet-integration/Training.server.luau), [`Training.client.luau`](studio-pet-integration/Training.client.luau) và [`DinosaurCombat.luau`](src/hunting/DinosaurCombat.luau).

Backup v2.4 trước khi thêm tiện ích: [`backups/Hub_v24_before_admin_fly_20261019.rbxl`](backups/Hub_v24_before_admin_fly_20261019.rbxl). Bản v2.3 trước thao tác được giữ riêng tại [`backups/Hub_before_admin_fly_20261019.rbxl`](backups/Hub_before_admin_fly_20261019.rbxl). Khôi phục backup sẽ đưa cả file về mốc đó; chỉ cần bỏ bay thì dùng hai thao tác xóa ở trên.

Công cụ kiểm tra source và quyền: `tools/test-admin-fly-policy.luau`. Đối chiếu bản Studio sau khi lưu: `tools/inspect-admin-fly-saved.luau`, báo cáo tại [`assets/hunting/admin-fly-saved.json`](assets/hunting/admin-fly-saved.json). Kiểm tra file đã lưu không thay thế việc thử bay và đáp trong Play.

Đã thử Play trong đúng bản v2.4: bật/tắt bằng nút, bay lên, WASD, Q hạ thấp, tốc độ 80/260, Shift tăng gấp đôi, đáp đất, đi bộ sau khi tắt và tự kết thúc khi chuyển về sảnh. Server từ chối tốc độ ngoài danh sách. Có **85 kiểm tra luật quyền/lệnh** và **83.012 kiểm tra bản lưu** đạt; 35.064 Part cùng 723 khớp nối của map được giữ nguyên. Lệnh chat đã đăng ký đúng alias nhưng chưa thử trọn luồng do giới hạn chat của Roblox. Chi tiết: [`assets/hunting/admin-fly-play.json`](assets/hunting/admin-fly-play.json).
