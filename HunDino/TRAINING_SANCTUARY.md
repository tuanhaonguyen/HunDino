# HunDino — Bãi luyện tập v2.3

**Cập nhật lớp lưu 20/10/2026:** v2.4 đã nối dữ liệu tiến trình vào hồ sơ tài khoản; xem [PERSISTENCE.md](PERSISTENCE.md) và thiết kế mục 39. Kiểm logic/Studio test đã có; nghiệm thu cloud qua thoát/vào còn chờ game xuất bản. Các câu chỉ giữ trong phiên và số liệu dưới đây thuộc mốc trước lớp lưu.

**Đồng bộ tài liệu: 20/10/2026 — đối chiếu bản v2.4 đã lưu ngày 19/10/2026.**

Bãi tập v2.3 được kế thừa trong **v2.4** cùng sảnh 12 base và map săn H2.0. Hiện có model/VFX Pro, Người/Pet chọn trang bị độc lập, chuột trái tụ cung, lướt **72/0,5 giây/6 thể lực**, Pet P1-C, nhiệm vụ P1-D, kinh tế P1-E và kho cá thể P1-F bước đầu. Xem [bảng tài liệu hiện hành](README.md), [combo](COMBOS_V2_3.md) và [Inventory](INVENTORY.md).

Các kết quả ngày 07–09/10 và quy trình dựng cũ bên dưới giữ lịch sử; không dùng chúng để kết luận v2.4 đã hoàn thành lưu tài khoản, săn đội hoặc điện thoại.

**Đợt combo/UI 08/10/2026:** phạm vi và thông số mới ở [COMBOS_V2_3.md](COMBOS_V2_3.md), thay các mô tả combo/thể lực cũ bên dưới. Mỗi vũ khí có bốn chuỗi, có lướt nối và múa; mọi chi phí còn 30%. UI dùng bốn icon người dùng, Shop chưa giao dịch. Thiết kế cập nhật tại 25.8; việc dọn file ở [DON_DEP_DU_AN.md](DON_DEP_DU_AN.md).

Kiểm tra đợt này:

- Logic 28 chuỗi, ngắt/hết hạn, chống spam/thiếu thể lực, tiêu hao 30% và biên dịch source: đạt bằng `tools/test-weapon-combos.luau`.
- Studio chạy đủ 28 chuỗi ra đúng tên đòn cuối. Thử riêng lướt ngang rồi ngắm lại: kiếm/khiên, thương, song dao, cung có sát thương đòn cuối lần lượt 99/132/126/108.
- Chuột và phím thật: Trái → Q → Space → E búa ghi đúng Light, Heavy, Dodge, Finisher; gây tổng 246. Xếp thao tác sớm cuối đòn hoạt động, không cắt thời gian hồi.
- Giữ F 5 giây: thể lực 100 → 94; chạy Shift/W 3 giây: 100 → 91. Lướt tiêu hao 6 trong chuỗi.
- Bốn icon tải thành công; Túi đồ cuộn đủ bảy vũ khí, nhãn tiếng Việt không tràn; Cài đặt thay trạng thái và độ nhạy; Shop hiển thị Sắp mở; Play về trại đưa pet theo, cách chủ khoảng 5,1 studs.
- Sáu nhóm kiểm tra bãi tập và source nhúng sau lưu đạt. Không có lỗi gameplay trong Output ở các phiên kiểm tra. Cảm giác lướt và hoạt ảnh toàn thân vẫn cần phản hồi người dùng; chưa kiểm chứng 12 client hoặc điện thoại.
- **Đã sửa ngày 09/10/2026:** khôi phục tỷ lệ/vị trí của TempleApproach, căn đủ 10 mặt đường và 8 viền rêu. 110 điểm dò đều có nền; nhân vật đi tới đền rồi quay lại không kẹt. Sau lưu: cả sáu nhóm kiểm tra map và sáu nhóm bãi tập đạt. Chi tiết tại thiết kế mục 25.9.

Cập nhật ngày 08/10/2026, tiếp tục bản v2.3 người dùng đã lưu từ công việc ngày 07/10: mở rộng bãi tập, sửa chữ, thêm bộ bảy vũ khí và sửa camera cung.

## File để chơi và chỉnh tiếp

Mở [HunDino_DarkJungle_v2_4.rbxl](HunDino_DarkJungle_v2_4.rbxl) tại `C:/Users/khanh/OneDrive/Documents/ChatGPT/game roblox/HunDino/HunDino_DarkJungle_v2_4.rbxl` bằng Roblox Studio, rồi nhấn Play. Lưu tiếp bằng Studio ở định dạng `.rbxl` để giữ Terrain và tiếng Việt. v2.3/Desktop là mốc trước; không chép đè bản v2.4 bằng bản cũ. Backup `backups/HunDino_v2_3_user_6293a5ddc15f.rbxl` thuộc lần mở rộng bãi tập 08/10.

## Bãi tập mới

- Diện tích 460 × 420 studs, thay bãi nhỏ cũ trong cùng Place.
- Sân võ tròn lát đá có vòng đánh dấu khoảng cách, ba hình nộm cận chiến.
- Bốn làn cung với bia cách vạch bắn 30, 60, 90 và 120 studs.
- Nhà vũ khí mái xanh, bảy bệ trưng bày có thể chọn; giữ giá giáp và bảng xóa thống kê cá nhân.
- Thêm đường lát đá, hồ nhỏ, cây, đèn, viền sân và cổng quay về trại.
- Giữ sảnh 12 base, cảnh quan đảo chính và 23 mặt nước của v2.1. Sửa các bảng tiếng Việt bị sai mã còn trong file nguồn.

## Điều khiển

| Thao tác | Phím |
| --- | --- |
| Qua cổng, chọn vũ khí trên bệ, thay giáp, xóa thống kê | Giữ G gần đối tượng |
| Mở/đóng bảng chọn vũ khí | I hoặc nút trên màn hình; cất vũ khí trước |
| Rút/cất vũ khí | R |
| Đánh thường / mạnh / kỹ năng | Chuột trái / Q / E |
| Nhảy / lướt | V / Space |
| Chạy / ghim tâm | Shift / Ctrl |
| Ngắm khi đã rút cung | Giữ chuột phải |
| Giữ thế đỡ khi dùng kiếm & khiên | Giữ F |

I được chặn khỏi phím zoom mặc định Roblox; Space không kích hoạt nhảy mặc định.

Trong v2.3, R cất cung và Shift chạy hủy ngắm ngay; menu Esc được nhả chuột để thao tác. Tâm ngắm ẩn khi mở menu hoặc nhân vật chết.

Ngắm cung dùng camera lệch vai phải: nhân vật nằm bên trái khung hình, zoom chuyển mượt về 8,5 studs, FOV 58 và độ nhạy chuột bằng 65% mức trước đó. Tâm bắn đặt đúng giữa viewport, không bị lệch do thanh giao diện Roblox. Nhả chuột phải/cất cung/hồi sinh trả lại camera và độ nhạy trước khi ngắm; vẫn dùng xử lý vật cản của camera Roblox.

## Bộ vũ khí thử

| Vũ khí | Hành vi trong bản thử |
| --- | --- |
| Búa tạ | Giữ combo thường → mạnh → kỹ năng kết thúc |
| Kiếm & khiên | Ba đòn, mô hình khiên tay trái, thế đỡ tiêu thể lực |
| Katana | Kiếm và bao kiếm, nhịp đòn riêng |
| Thương cán dài | Tầm đánh cận chiến xa hơn, kỹ năng quét rộng |
| Song dao | Hai lưỡi, nhiều hit nhỏ và nhịp nhanh |
| Cung | Ngắm, bắn thường/mạnh, kỹ năng ba mũi; ngắm rồi lướt tăng sát thương một mũi tên kế tiếp trong 4 giây, không cộng dồn |
| Rìu đại hai lưỡi | Đòn chậm, sát thương và tiêu thể lực lớn |

Mỗi loại có mô hình, sát thương, tầm đánh, nhịp và thể lực riêng trong `src/dark-jungle/Weapons.luau`. Đây là **thông số thử**, chưa chốt cân bằng toàn game. Mô hình và chuyển động vũ khí dùng Part/weld để thử chơi, chưa phải bộ mesh/animation cuối. Khiên hiện có thế đỡ; chưa kiểm chứng giảm sát thương vì bãi tập chưa có địch tấn công. Cung dùng raycast máy chủ và hiệu ứng mũi tên bay, chưa mô phỏng đường đạn cong. Hình nộm bãi tập không phát thưởng; vòng săn hiện có thưởng P1-E. Chưa có PvP hoặc lưu trang bị theo tài khoản.

## Kiểm tra ngày 07/10/2026

- Kiểm tra tự động: quy tắc cả bảy vũ khí, combo búa, đổi vũ khí, thiếu thể lực/thế đỡ, hình học bãi tập, UTF-8 và biên dịch code nhúng.
- Trong Studio Play: chọn kiếm & khiên/cung bằng giao diện, rút/cất và gây sát thương. Đòn mạnh kiếm gây 47; chuỗi ba đòn búa 246, katana 176, thương 177, song dao 138, rìu 230 khi đủ thể lực.
- Cung bằng chuột/Q/E: tổng 119 ở bia thẳng hướng; bắn xa 120 studs gây 29; có tường chắn gây 0. Sau ngắm/lướt, hai phát thường lần lượt 36 và 29, buff hết sau phát đầu.
- Thế đỡ chặn yêu cầu tấn công, nhả F kết thúc thế đỡ. Cổng G đưa người/pet qua lại; về trại pet cách chủ khoảng 5 studs. Không có lỗi gameplay trong Output ở phiên kiểm tra.
- Camera cung: xác nhận tâm ngắm trùng điểm chiếu bia (sai lệch dưới 0,01 pixel trong phép đo), bấm chuột trái gây 29 sát thương; di chuyển ngang giữ góc lệch vai. Nhả ngắm trả FOV 70, offset 0, zoom 0,5–128 và độ nhạy 1 trong cấu hình thử. Thêm tường sau lưng khiến camera tiến gần lại; chết/hồi sinh khi đang ngắm không kẹt zoom hay độ nhạy.
- Chưa kiểm thử đủ 12 người, điện thoại hoặc cảm giác cân bằng cuối. Pet giữ hành vi thử cũ, chưa có tìm đường vòng hoàn chỉnh.

Kiểm tra bổ sung 08/10/2026 trên bản `.rbxl` v2.3:

- Mở lại đúng file người dùng: đủ bảy vũ khí, bãi tập và chuỗi tiếng Việt nguyên vẹn. 12 nhóm kiểm tra source/cấu trúc đạt.
- I mở bảng chọn: khoảng cách camera trước/sau đều khoảng 12,5 studs, không bị zoom mặc định.
- Cung đang ngắm ở FOV 58, offset vai (2,6; 0,65; 0): nhấn R cất hoặc giữ Shift/W để chạy trả FOV 70 và offset 0. Độ nhạy trở về 1 trong cấu hình thử.
- Đang ghim tâm bằng Ctrl, mở Esc: menu mở, chuột về Default, tâm ngắm ẩn. Không có lỗi gameplay trong Output.
- Sau lưu lại v2.3 bằng Studio, kiểm tra UTF-8 và code nhúng khớp source đạt. Không ghi lại file bằng bộ dựng cũ.

## Source và quy trình dựng lịch sử — không dùng để cập nhật v2.4

`tools/build-training-sanctuary.luau` chỉ tạo khu tập và mẫu vũ khí. `tools/merge-training-sanctuary.py` ghép vào bản v2.1 Desktop, sao lưu nguồn theo SHA256, bảo toàn hình học lobby/đảo và sửa mã chữ. Không dùng công cụ này để ghi đè các chỉnh sửa mới trong v2.2; nó kiểm tra hash bản dựng trước khi thay đầu ra. Kết quả nằm trong `TrainingSanctuary_manifest.json`.

Các lệnh sau ghi lại quy trình dựng/kiểm tra bãi tập ở mốc cũ; **không chạy bộ dựng hoặc merge lên v2.4**. Khi cần sửa bản hiện hành, chỉnh đúng source trong Studio và lưu native. Lệnh lịch sử chạy từ thư mục HunDino trong Documents:

```powershell
.\tools\lune\lune.exe run tools/build-training-sanctuary.luau
# Chạy tools/merge-training-sanctuary.py bằng Python, rồi:
.\tools\lune\lune.exe run tools/test-training-sanctuary.luau HunDino_DarkJungle_v2_3.rbxl
.\tools\lune\lune.exe run tools/test-dark-jungle.luau HunDino_DarkJungle_v2_3.rbxl
```

`tools/build-dark-jungle.luau` vẫn là bộ dựng toàn đảo từ đầu, không dành cho cập nhật map đang chỉnh thủ công. Không đồng bộ cấu hình Rojo L0 cũ vào v2.2.

Với v2.3, cập nhật script qua Studio rồi lưu bằng Studio để bảo toàn các thuộc tính Terrain mới. Không dùng Lune để đọc rồi ghi lại toàn file: bộ đọc kiểm tra hiện báo chưa hỗ trợ `Terrain.VoxelGridAssetContentMap`. Cảnh báo này không xuất hiện trong Studio và không làm mất dữ liệu khi chỉ đọc để kiểm tra.

Tham chiếu API camera: [Roblox Camera](https://create.roblox.com/docs/reference/engine/classes/Camera), [Humanoid.CameraOffset](https://create.roblox.com/docs/reference/engine/classes/Humanoid#CameraOffset). Các giá trị góc nhìn bên trên là cấu hình thử của HunDino.
