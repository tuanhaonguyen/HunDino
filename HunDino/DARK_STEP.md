# Lướt Dark Step — 15/10/2026

<!-- TIEN_DO_20261027_BEGIN -->
> **Trạng thái đối chiếu 27/10/2026, 09:48 UTC+7:** local chính `HunDino_MerchantWeapons_20261026.rbxl` **4.495.025 byte**, SHA256 `8626bc714aa7a0da39493ba1bbcc676a142038b2f8a2c06e602fe01d522229bf`; inspector **129.779 kiểm / 164 source**, đạt. Cloud có bằng chứng mới nhất **v14**, nguồn **4.481.440 byte**; sửa bố cục ống mới chỉ local, **chưa Publish**.
>
> Tính năng trong tài liệu này được đối chiếu cùng bản chính hiện hành; các file v2.x/SaveGame, tham số và kết quả thử cũ trong phần dưới là mốc lịch sử, không tự chứng nhận toàn bộ bản mới. Phạm vi còn chờ: P1-G toàn vòng, cloud kinh tế/cá thể/ống, nhiều client và thiết bị thật.
>
> [Báo cáo tiến độ toàn dự án và hôm nay](BAO_CAO_TIEN_DO_2026-10-27.md). Ghi chú này cập nhật trạng thái; số liệu/hash của từng mốc cũ bên dưới giữ nguyên theo phạm vi lúc kiểm.
<!-- TIEN_DO_20261027_END -->

**Đồng bộ tài liệu: 20/10/2026 — đối chiếu bản v2.4 đã lưu ngày 19/10/2026.**

Trên [v2.4](HunDino_DarkJungle_v2_4.rbxl), Space lướt với **DodgeSpeed=72 / DodgeTime=0.5 / thực chi 6 thể lực**, không có bất tử. Phép đo Play H1.3.1 đã có khoảng **16,5–16,8 studs** trên nền thoáng; không suy ra mọi địa hình đạt cùng quãng. Xem [combat](DINOSAUR_COMBAT.md) cho nhịp cắn 0,95/3,5 giây. Các cấu hình 34→42 và phép đo 8,51→9,74 bên dưới là lịch sử ngày 15/10.

**Bản chung hiện hành H1.3.1 — 17/10/2026:** tăng mạnh quãng lướt theo yêu cầu né khủng long: `DodgeSpeed=72`, `DodgeTime=0.5` trong `studio-pet-integration/TrainingConfig.luau`, thực chi vẫn 6 thể lực. Tích phân đường giảm tốc cho 17,33 studs; đo client Play 16,55 studs, thử né ngang 16,77 studs không trúng cú cắn lượt hai. Đã thử cùng cảnh báo cắn mới 0,95 giây/chu kỳ 3,5 giây; `tools/test-dark-step.luau --saved` đạt. Bản `src/shared/TrainingConfig.luau` có các chế độ Evades riêng là nguồn khác, không cài thay cấu hình đang dùng của Studio. Các số dưới đây là mốc thử cũ 15/10.

Nhấn Space như trước. Quãng lướt được tăng nhẹ bằng cách đổi tốc độ đầu từ 34 lên 42, giữ nguyên thời gian 0,4 giây, đường giảm tốc và thể lực 6 điểm thực chi. Đo cùng sàn phẳng bằng vị trí lúc DodgeVelocity được tạo/xóa: trước 8,51 studs, sau 9,74 studs, tăng khoảng 14%. Khoảng đi thực tế còn tùy địa hình và va chạm.

Hiệu ứng gồm khói tối lúc xuất phát và dừng, dải tím tối ngắn, các bản sao bóng mờ theo tư thế/vị trí nhân vật tan dần trong 0,38 giây. Có tư thế chúi thân theo hướng lướt, hai tay đưa về sau và trả về hoạt ảnh thường khi kết thúc. Không làm nhân vật thật vô hình hoặc thêm bất tử.

Server chỉ phát dấu thời gian, hướng và sequence khi đòn lướt được chấp nhận. LocalScript `HunDinoDarkStep` dựng hiệu ứng cho người chơi gần camera, không tạo bản sao vật lý trên server. Bóng không va chạm, không raycast, không touch, không có script hoặc joint. Tối đa 64 part mỗi bóng, lấy mẫu khoảng 0,055 giây; toàn bộ bóng/khói được dọn tự động. Tắt Hiệu ứng đòn kết thúc trong Cài đặt cũng tắt phần khói/bóng Dark Step.

Mã hoạt ảnh hỗ trợ cả Motor6D và [AnimationConstraint](https://create.roblox.com/docs/reference/engine/classes/AnimationConstraint). Lớp tư thế dùng Transform giữa PreAnimation/PreSimulation để không cộng dồn lên hoạt ảnh mặc định. Đã kiểm tra trên avatar AnimationConstraint thực tế trong Studio.

## Mã và kiểm tra mốc đầu — 15/10/2026

- `src/dark-jungle/DarkStep.client.luau` → StarterPlayerScripts.HunDinoDarkStep.
- `studio-pet-integration/TrainingConfig.luau`: cấu hình mốc đầu 15/10 là DodgeSpeed=42, DodgeTime=0,4; hiện hành đã là 72 và 0,5 theo mục đầu.
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
