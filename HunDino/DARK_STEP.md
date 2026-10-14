# Lướt Dark Step — 15/10/2026

Nhấn Space như trước. Quãng lướt được tăng nhẹ bằng cách đổi tốc độ đầu từ 34 lên 42, giữ nguyên thời gian 0,4 giây, đường giảm tốc và thể lực 6 điểm thực chi. Đo cùng sàn phẳng bằng vị trí lúc DodgeVelocity được tạo/xóa: trước 8,51 studs, sau 9,74 studs, tăng khoảng 14%. Khoảng đi thực tế còn tùy địa hình và va chạm.

Hiệu ứng gồm khói tối lúc xuất phát và dừng, dải tím tối ngắn, các bản sao bóng mờ theo tư thế/vị trí nhân vật tan dần trong 0,38 giây. Có tư thế chúi thân theo hướng lướt, hai tay đưa về sau và trả về hoạt ảnh thường khi kết thúc. Không làm nhân vật thật vô hình hoặc thêm bất tử.

Server chỉ phát dấu thời gian, hướng và sequence khi đòn lướt được chấp nhận. LocalScript `HunDinoDarkStep` dựng hiệu ứng cho người chơi gần camera, không tạo bản sao vật lý trên server. Bóng không va chạm, không raycast, không touch, không có script hoặc joint. Tối đa 64 part mỗi bóng, lấy mẫu khoảng 0,055 giây; toàn bộ bóng/khói được dọn tự động. Tắt Hiệu ứng đòn kết thúc trong Cài đặt cũng tắt phần khói/bóng Dark Step.

Mã hoạt ảnh hỗ trợ cả Motor6D và [AnimationConstraint](https://create.roblox.com/docs/reference/engine/classes/AnimationConstraint). Lớp tư thế dùng Transform giữa PreAnimation/PreSimulation để không cộng dồn lên hoạt ảnh mặc định. Đã kiểm tra trên avatar AnimationConstraint thực tế trong Studio.

## Mã và kiểm tra

- `src/dark-jungle/DarkStep.client.luau` → StarterPlayerScripts.HunDinoDarkStep.
- `studio-pet-integration/TrainingConfig.luau`: bản cấu hình chính xác của Studio, DodgeSpeed=42, DodgeTime=0,4.
- Server Training thêm các thuộc tính DarkStep khi lướt được chấp nhận. Bản nguồn hiện đại trong src/dark-jungle giữ hệ Evades riêng; DodgeSpeed/Travel.Speed của cấu hình hiện đại tăng 58→66, các chế độ lộn/chuỗi/cung vốn có được giữ.
- Play: Space thật, ghi nhận tối đa 7 bóng mờ đồng thời, 2 đám khói, tư thế có thay đổi và hồi về; không part hiệu ứng nào bật va chạm/query/touch. Sau 2 giây thư mục FX trống.
- Thử lướt liên tiếp trái/phải, tùy chọn tắt hiệu ứng và kiểm tra Output không có lỗi.
- `tools/test-dark-step.luau` kiểm tra quãng tăng vừa phải, thể lực/thời gian không đổi, chặn spam/hết thể lực, biên dịch và khớp nguồn đã lưu.

Chạy từ thư mục HunDino:

```powershell
./tools/lune/lune.exe run tools/test-dark-step.luau --saved
./tools/lune/lune.exe run tools/test-map-preservation.luau backups/HunDino_v2_3_before_dark_step_20261015.rbxl HunDino_DarkJungle_v2_3.rbxl
```

Backup: `backups/HunDino_v2_3_before_dark_step_20261015.rbxl`; ServerStorage.DarkStepBackup_20261015 chứa server/config trước sửa. Bản map được lưu trực tiếp qua Roblox Studio.
