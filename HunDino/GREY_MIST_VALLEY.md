# Thung Lũng Sương Xám — H2.0

**Đồng bộ tài liệu: 20/10/2026 — đối chiếu bản v2.4 đã lưu ngày 19/10/2026.**

Cảnh quan H2.0 được kế thừa trong [bản v2.4](HunDino_DarkJungle_v2_4.rbxl), đã nối [Pet P1-C](PET_COMPANION.md), [nhiệm vụ/bắt P1-D](HUNT_QUEST.md), [kinh tế P1-E](HUNT_ECONOMY.md) và [kho cá thể P1-F bước đầu](SPECIMEN_COLLECTION.md). H2 có **4.000 × 4.500 studs, 2.400 cây, 16 đường và 9 node/khu kỹ thuật**; tám sinh cảnh trong yêu cầu thiết kế không đồng nghĩa chín node tuần tra.

Hash, kích thước 4.163.257 byte và kết quả kiểm tra H2 bên dưới thuộc bản v2.3 tại thời điểm dựng cảnh quan. Bản v2.4 sau kho cá thể là 4.220.334 byte, báo cáo đối chiếu riêng tại tài liệu P1-F. [Thiết kế map gốc và bảng đối chiếu tiến độ](<../thiết kế map săn.md>).

Bản nâng cấp khu săn theo `thiết kế map săn.md`: mở rộng từ 1.620 × 1.620 lên **4.000 × 4.500 studs**, dựng địa hình thung lũng, rừng ôn đới đầu thu và dấu tích khai thác gỗ. Mở **`HunDino_DarkJungle_v2_4.rbxl`** trong Documents/ChatGPT/game roblox/HunDino để chơi bản chung có sảnh, base, bãi tập và khu săn mới.

## Cảnh quan và bố cục

Phong cách stylized realistic: cây có nhiều biến thể và tán tự nhiên, đá phủ rêu, gỗ bạc màu, nước xanh xám. Xanh thông và rêu làm nền; vàng lá thu xuất hiện thành cụm. Sương và ánh sáng tạo cảm giác bí hiểm nhưng vẫn giữ đường đi, thân cây và hình dáng khủng long dễ đọc.

Tọa độ thiết kế lấy tâm khu săn là `(0,0)`; **Bắc là Z dương**. Địa hình thấp ở phía Nam và nâng dần lên dãy núi phía Bắc, có hồ, đầm lầy, suối và thác. Trong Place chung, toàn khu được đặt lệch **`(0,0,6500)`**, tách khỏi sảnh.

| Vùng | Điểm nhận diện |
|---|---|
| Trạm kiểm lâm và bìa rừng phía Nam | Nhà gỗ có hiên, kho, biển chỉ đường, hàng rào, đèn vàng, nơi bắt đầu và về sảnh |
| Đồng cỏ và rừng thưa | Đồi thoải, cụm bạch dương, cỏ thu và Đồi Sồi Đơn Độc |
| Rừng thông già phía Tây | Thông cao nhiều lớp, dương xỉ, thân đổ, chòi trú và khoảng mở giữa rừng |
| Hồ trung tâm | Đảo có thông nhỏ, lối lội/đá dẫn ra đảo, bến gỗ và thuyền neo trang trí |
| Đầm lầy phía Đông | Liễu, lau sậy, nước nông, lối ván và chòi quan sát |
| Khu khai thác gỗ bỏ hoang | Xưởng cưa hỏng, nhà công nhân, gỗ xếp và tháp cũ |
| Thung lũng đá và suối phía Bắc | Đá chẻ, khe nước, cầu gỗ và thác cao khoảng 57 studs |
| Dãy núi và hang phía Bắc | Sườn đá cao, cửa hang và đỉnh núi nhạt màu để định hướng |

Đã rải **2.400 cây**, thêm cây điểm nhấn ở đảo/trạm, cùng cỏ/dương xỉ/lau và các cụm đá. Rừng thông phía Tây được làm dày hơn. Cây dùng mesh có vật liệu bề mặt; thư viện gồm **12 biến thể thông, 6 bạch dương, 6 sồi và 1 liễu**. Cây phân bố theo sinh cảnh, nhường chỗ cho đường, khoảng chiến đấu, nhà và các hướng nhìn quan trọng. Thân cây dùng collider đơn giản; tán lá không chặn di chuyển hoặc nuốt tia đánh.

Các nhánh đường dùng chung cao độ tại điểm nghỉ/ngã rẽ. Hành lang khủng long rộng 72 studs, nền đất lộ hẹp hơn; dốc lớn nhất đo trên đường là **17,433°**. Sườn núi phía Nam, Đông và Tây giúp khép không gian thung lũng.

## Luồng chơi được giữ lại

- Từ sảnh: mở **Chơi → Vào khu săn**, hoặc giữ **G** tại cổng săn. Người chơi và Pet đến trạm kiểm lâm.
- Nhận nhiệm vụ bằng **J** tại sảnh; khi khu săn chưa có nhiệm vụ, menu Chơi/cổng vẫn cho thám hiểm. Trong nhiệm vụ, ba lần chết đầu hồi sinh tại trại, lần thứ tư hoặc hết 40 phút thì thất bại; ra biên đưa về trại, giữ lượt. Thắng mở 120 giây thu hoạch/về sớm. Luồng về sảnh và phục hồi ánh sáng dùng chung; chi tiết ở HUNT_QUEST.md.
- Giữ điều khiển: **R** rút/cất vũ khí, **I** túi đồ, chuột trái đánh nhẹ, **Q** đánh nặng, **E** kỹ năng, **Shift** chạy, **V** nhảy, **Space** lướt. **M** chọn điểm xem nhanh chỉ dùng trong Studio.

Giờ vào rừng lấy theo **giờ thực UTC+7**. Sau đó đồng hồ rừng chạy nhanh **30 lần: 2 phút thật = 1 giờ trong rừng**. Một lượt tối đa **40 phút thật**, tương đương 20 giờ trong rừng. Ánh sáng đổi riêng trên client người đang săn và phục hồi khi về sảnh. Mỗi người có giờ bắt đầu riêng; khu săn và con khủng long mẫu vẫn dùng chung.

Mạng tuần tra giữ **9 node: A/B/C, R1–R5 và Camp**; trong đó 8 node là nơi khủng long ghé. Có **13 tuyến nối hai chiều dành cho khủng long**, **3 đường từ trạm dành cho người chơi** và **9 phương án tuần tra** chia cho A/B/C. Ví dụ tuyến đầy đủ của A vẫn là `A → R2 → C → R3 → B → R4 → R5 → R1 → A`; vị trí và độ cao được chuyển sang cảnh quan mới.

Hiện chỉ có **1 khủng long thử nghiệm**. Thông số chiến đấu được giữ:

| Thông số | Giá trị |
|---|---|
| Nghỉ tại mỗi điểm, kể cả lúc xuất hiện | 60 giây thật |
| Máu | 1.200 HP, có thanh máu và hitbox nhận đòn |
| Sát thương cắn | 24 |
| Báo trước cú cắn | 0,95 giây |
| Khoảng cách tối thiểu giữa hai lần bắt đầu cắn | 3,5 giây |
| Lướt né | Tốc độ ban đầu 72 studs/giây, giảm tốc trong 0,5 giây; thực tế khoảng 16,5 studs trên nền thoáng, tốn 6 thể lực |

Khủng long tuần tra bình thường và chỉ phản công sau khi bị đánh. Nó nhắm người tấn công, có cảnh báo trước đòn, rồi trở về tuyến khi bỏ đuổi. Về sảnh hủy đòn đang chờ; người cuối cùng rời khu sẽ kết thúc lượt tuần tra và đặt lại con mẫu. Phạm vi an toàn của trạm là 250 studs.

Các nhà gỗ, xưởng cưa, thuyền, biển, dấu tích và hang phục vụ cảnh quan/định hướng. Riêng đợt dựng cảnh quan H2.0 không bổ sung gameplay mới. Trên v2.4 hiện đã có Pet hỗ trợ chiến đấu, nhiệm vụ/bắt, quặng/vảy/mổ/thưởng và kho cá thể từ các bước P1-C/D/E/F. **Chưa có loài thú mới, đàn thú, lái thuyền hoặc AI leo vách**; hang/ổ và dấu tích cảnh quan không chứng minh có thú cư trú hay hệ theo dấu động.

## Nguồn hình ảnh và cách dựng

Các mẫu công khai từ Roblox Creator Store được làm sạch toàn bộ Lua trước khi đưa vào thư viện. Giữ thuộc tính credit trên template và bản sao sinh ra; giữ mesh và SurfaceAppearance để bảo toàn vật liệu.

| Tài sản | Tác giả và nguồn |
|---|---|
| Thông Ponderosa | Letaij — [130515502281374](https://create.roblox.com/store/asset/130515502281374) |
| Bạch dương | Letaij — [11351912067](https://create.roblox.com/store/asset/11351912067) |
| Sồi | Letaij — [98950444096614](https://create.roblox.com/store/asset/98950444096614) |
| Liễu | NORTHPORTINATOR — [131598559195257](https://create.roblox.com/store/asset/131598559195257) |
| Đá rêu PBR | EchoShadow064Fir3635 — [78043214487511](https://create.roblox.com/store/asset/78043214487511) |

Source chính nằm trong `src/hunting/`: `GreyMistValleyConfig.luau` định nghĩa địa hình và tuyến; `ConnectedHuntingConfig.luau` cộng offset vào bản chung; `BuildGreyMistValley.luau`, `ValleyLandmarks.luau`, `ValleyArtKit.luau` dựng cảnh; `ValleyDressing.luau` bổ sung đảo/trạm/hang/lớp cây thấp; `EnvironmentClock.luau` điều khiển ánh sáng. Combat, phiên săn và vũ khí tiếp tục dùng các module hiện hành.

Trong Studio, bộ dựng chỉ chạy ở **Edit**, dưới **`ServerStorage.GreyMistBuild`**. Terrain được ghi bằng API gốc của Studio và giới hạn trong hình chữ nhật khu săn; sảnh/base và Terrain bên ngoài được giữ. Không dùng Lune để ghi lại `.rbxl`. Không chạy lại bộ dựng H1 hoặc đồng bộ project L0 lên bản chung đã nâng cấp.

`HunDino_HuntingRainforest_v1.rbxl` vẫn là bản lịch sử H1.1 xem riêng. Các số kiểm chứng và hash trong `HUNTING_LINK.md`, `HUNTING_MAP.md` thuộc các mốc cũ; tài liệu này mô tả H2.0.

## Kiểm chứng mốc cảnh quan H2.0 — bản v2.3 ngày 19/10/2026

- **Edit và mở lại file đã lưu:** 39.081/39.081 kiểm tra đạt; 1.152 tile Terrain, 9 node, 16 đường, 2.400 cây. 578 mẫu khoảng trống toàn thân khủng long không gặp vật cản cảnh quan. Báo cáo `assets/hunting/grey-mist-validation.json`.
- **Tuần tra:** 148 kiểm tra đạt, chạy đủ 3 lịch trình của con mẫu A theo cả hai chiều, tổng 6 vòng. Tổng 5.917 lần dò nền và 5.917 lần dò khoảng trống; không hụt nền hoặc mắc cảnh. Sai lệch chân–nền lớn nhất dưới 0,19 stud. Bài thử rút ngắn nghỉ và tăng tốc mô phỏng; cấu hình chơi thật vẫn nghỉ 60 giây. Báo cáo `grey-mist-routes.json`.
- **Combat/đồng hồ:** 96/96 kiểm tra tích hợp combat, 12 kiểm tra đồng hồ và 6 nhóm luật vũ khí đạt. Kiểm tra 14:00 → 15:00 sau 120 giây, qua ngày sau 40 phút, UTC+7 và khôi phục màu/ánh sáng. Báo cáo `grey-mist-combat.json`, `grey-mist-clock.json`.
- **Play thật:** vào từ nút Chơi, đến trạm; xem R4 và C; đi bộ từ bờ ra đảo không phải bơi và xuyên hang ra cửa sau. Con mẫu bắt đầu đi sau nghỉ; bắn trúng gây 29 sát thương và kích hoạt phản công. Về sảnh giữ Base 5, Pet cách người khoảng 5,93 studs, tắt HUD săn, khôi phục đồng hồ/màu nước/cỏ/hiệu ứng sảnh và reset con mẫu về 1.200 HP. Lượt vào/đánh/về được thử lại sau khi mở bản lưu. Báo cáo `grey-mist-play.json`.
- **Sau Save:** 26.259 kiểm tra đạt; 75 script biên dịch, 16 nguồn chính khớp file nguồn, 37 script ngoài phạm vi giữ nguyên. Toàn bộ **15.089 phần sảnh/base/cổng**, 8.348 phần rừng cũ lưu trữ và rig khủng long được bảo toàn. Báo cáo `grey-mist-saved.json`; tổng hợp `grey-mist-release.json`.

File native của mốc H2.0 v2.3 đã lưu: **4.163.257 bytes**. SHA256: `5e5323c4d59bfe1c815b1cb68674dc62106fb801904ad19711342358e5010521`.

Ảnh Studio trong `assets/hunting/`: `lake-and-valley-h2.jpg`, `old-pine-forest-h2.jpg`, `ranger-station-h2.jpg`. Ảnh dùng ánh sáng xem cảnh lúc 15:00; khi chơi, map lấy giờ thực lúc vào.

Hiệu năng nhiều client, điện thoại và máy yếu cần lượt đo riêng; số cây hoặc ảnh xem trước không thay thế kết quả đó.
