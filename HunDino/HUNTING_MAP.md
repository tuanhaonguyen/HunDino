# Khu săn Rừng cổ — bản nối sảnh H1.2

**Đồng bộ tài liệu: 20/10/2026 — đối chiếu bản v2.4 đã lưu ngày 19/10/2026.**

Bản để chơi tiếp là [v2.4](HunDino_DarkJungle_v2_4.rbxl) với [Thung Lũng Sương Xám H2.0](GREY_MIST_VALLEY.md), **4.000 × 4.500 studs, 2.400 cây, 16 đường, 9 node**. Đã có tuần tra/nghỉ 60 giây, combat H1.3.1, Pet, nhiệm vụ/bắt, quặng/mổ/thưởng và kho cá thể trong phiên. Nhận nhiệm vụ bằng J ở sảnh; xem [nhiệm vụ](HUNT_QUEST.md) và [kho cá thể](SPECIMEN_COLLECTION.md).

File săn riêng H1.1 và nội dung bên dưới giữ làm nguồn/lịch sử; các thông số 1.620 × 1.620, Space nhảy và thời gian nghỉ 5/20/6/4 giây **không áp dụng bản chung v2.4**. Chưa có DataStore, ống trưng bày, săn đội hoặc nghiệm thu điện thoại.

## Hồ sơ H1.0–H1.2 và bản nguồn riêng

**Cảnh quan hiện hành H2.0 — 19/10/2026:** đã mở rộng thành Thung Lũng Sương Xám 4.000 × 4.500 studs trong bản chung; xem [GREY_MIST_VALLEY.md](GREY_MIST_VALLEY.md). Nội dung H1 bên dưới giữ làm hồ sơ lịch sử.

**Mốc nối sảnh 16/10/2026:** khu săn đã được ghép vào **HunDino_DarkJungle_v2_3.rbxl**. Mở bản sảnh này rồi **Play → Chơi → VÀO KHU SĂN · RỪNG CỔ**, hoặc giữ G tại cổng đá rêu bên trái sảnh. Người/Pet đi cùng, đồng hồ riêng, có nút/cổng về sảnh và tự về hết giờ. Xem [hướng dẫn bản nối và kết quả kiểm tra](HUNTING_LINK.md).

Phần dưới là hồ sơ **bản nguồn săn riêng H1.1**, vẫn giữ để xem/chỉnh cảnh quan độc lập; trạng thái chưa nối sảnh trong hồ sơ cũ chỉ áp dụng cho file nguồn đó.

## Bản nguồn H1.1

Ngày dựng và kiểm tra: **15/10/2026**.

File mở trong Roblox Studio: **HunDino_HuntingRainforest_v1.rbxl** tại thư mục này. H1.1 tiếp tục trên cùng file; mốc H1.0 trước thêm cây/vách đá và đi tuyến được giữ ở `backups/HuntingRainforest_before_density_routes_20261015.rbxl`, SHA256 `6335460f3a9b9e9fbb6b862f8289fe08c2297a1d8a6c3756e236514a9deb9395`.

Bản nguồn H1.1 có **1.423.660 byte**, SHA256 kiểm tra 16/10 `42b4bc4788825f2ce53d87f071140869c5a6fa9a6c0ec7cb717cfd89ee549b60`. Đọc kiểm tra đạt: 27 script biên dịch được, source runtime/cấu hình/bộ bổ sung khớp file làm việc, rig 255 part/bảy Motor6D/247 weld/một anchor còn nguyên. Ảnh: `assets/hunting/overview-h11.png`, `assets/hunting/forest-dividers-h11.png`.

Đây là bản khu săn riêng dựng từ phiên khủng long mẫu; không ghi đè `Dinosaur01_TRex_Visual.rbxl` hoặc map sảnh/bãi tập `HunDino_DarkJungle_v2_3.rbxl`. Bản sao con mẫu trước dựng nằm ở `backups/Dinosaur01_before_hunting_map_20261015.rbxl`; SHA256 bản gốc và bản sao cùng là `ff9c46ce1cb8b0be8d61b0eb7b3e624aed1e6e1ab33b09449174995ff9bcdb6a`.

## Đã dựng

- Terrain thật với hồ trung tâm, ba bãi chính **A/B/C**, năm điểm nghỉ **R1–R5** và trại người chơi tách riêng.
- Giữ bố cục đã duyệt, nới mặt bằng từ 1.080 lên **1.620 × 1.620 studs** theo tỷ lệ con mẫu. Chiều cao vẫn theo bố cục gốc để giữ dốc nhẹ. Kích thước tiếp tục có thể chỉnh sau khi người dùng đi thử.
- **13 đường nối cho quái**, rộng **72 studs**, đi được hai chiều; gồm B ↔ R1, C ↔ B, C ↔ R5. Thêm hai đường người chơi từ trại tới R1/R4, rộng 24 studs. Các góc đường bo tròn và nền Terrain được san theo cả bề rộng hành lang.
- Cây rừng/cổ thụ, rễ, dây leo, đá rêu, dương xỉ, nấm sáng, lều/đèn/thùng đồ ở trại; khu R3 có cổng phế tích nằm ngoài đường đi. Đây là cảnh quan khối ban đầu, chưa coi là đồ họa hoàn thiện.
- **Một con khủng long mẫu hiện có đặt tại A**, giữ model/mesh/texture và rig. B/C có điểm đặt cho các con tiếp theo; chưa nhân bản ba con giống nhau.
- `ReplicatedStorage.HuntingMapConfig` chứa đủ chín tuyến của A/B/C và mạng đường hai chiều. H1.1 nối con mẫu ở A với bộ đi tuyến: nghỉ lúc xuất hiện, đi qua các khu, nghỉ giữa chặng, về A nghỉ rồi chọn vòng khác/đảo chiều. Chỉ có một con mẫu; chưa thêm con ở B/C.
- Đồng hồ môi trường UTC+7 bắt đầu theo giờ thực khi Play và chạy **30 lần** (2 phút thật = 1 giờ trong map). Ban đêm có ánh trăng/nền sáng và hiệu chỉnh nâng vùng tối để vẫn thấy đường. Bước này là runtime xem map; việc bắt đầu/dừng theo nhiệm vụ thật và phục hồi khi về sảnh sẽ nối sau.

## Cách xem

1. Mở `HunDino_HuntingRainforest_v1.rbxl`, bấm **Play**. Nhân vật xuất hiện ở trại, camera điều khiển bình thường.
2. **WASD** đi, **Shift** chạy, **Space** nhảy theo điều khiển Roblox trong bản khu săn riêng.
3. **M** mở/đóng bảng chọn khu, bấm A/B/C/R1–R5/Camp để tới khu xem nhanh. Tính năng này chỉ hoạt động trong Studio, không phải dịch chuyển miễn phí trong gameplay chính thức.
4. Đồng hồ góc phải hiển thị giờ rừng và khu gần nhất. Trong Edit, bản lưu để ánh sáng 14:00 cho dễ xem; Play khởi tạo lại bằng giờ thực UTC+7.
5. Con mẫu nghỉ khoảng **5 giây** lúc bắt đầu, quay theo lối rồi tự đi. HUD hiển thị khu vừa qua và khu tiếp theo. Thông số thử: 12 studs/giây; nghỉ về A 20 giây, R1–R5 6 giây, B/C 4 giây. Các thời gian này có thể chỉnh, chưa là cân bằng cuối. `RouteEnabled=false/true` trên model tạm dừng/tiếp tục.

Các nút F/G/R/C thử cắn/đi vòng/camera từ place khủng long đã cất trong ServerStorage và tắt. Giữ module rig và JawRuntime; `MotionRuntime` vòng tròn cũ được tắt để `DinosaurRouteController` điều khiển vị trí và dáng đi. Chưa có tự tấn công.

## Bổ sung và kiểm chứng H1.1

- Thêm **360 cây tán ba tầng, 150 cụm dương xỉ, 100 khối đá rêu** thành chín dải; các đoạn chia A/R2, R2/C, B/R3, B/R4, R1/R5 và quanh mép rừng có khe cho tuyến đi qua. Đá bám Terrain, cây tránh bãi chiến đấu, hồ và đường. Phần thêm có 4.786 BasePart; chưa tối ưu cho điện thoại/máy yếu.
- Không đổi Terrain hoặc hình học đường. Kiểm tra bản Edit sau bổ sung đạt **291/291**, 4.308 điểm dò nền và 1.266 truy vấn vật cản trên hành lang.
- Kiểm thử tăng tốc trên bản sao độc lập: **148/148**, sáu vòng đầy đủ (ba tuyến A × hai chiều), đúng thứ tự, trở về A nghỉ; không thiếu nền hoặc chạm vật trang trí trong **1.804 lần dò hộp bao toàn thân**. Dáng chân đạt khoảng 11°, sai lệch điểm chân so nền tối đa 0,193 stud. Bản sao kiểm thử được dọn, con mẫu gốc giữ vị trí trong Edit.
- Play bình thường: con mẫu đi A → R2, nghỉ và tiếp tục R2 → C; đo khoảng 36,49 studs sau ba giây, trạng thái được đồng bộ lên client và HUD. Không thấy lỗi runtime server/client trong lượt kiểm tra.
- Bộ đi theo các WalkSurface thật, bám cao độ và quay trước khi đi. Chưa né nhân vật/vật cản động, chưa đuổi hoặc đánh người chơi; các part của con mẫu vẫn không va chạm để thử rig.
- Hồ sơ kiểm tra: `assets/hunting/validation-h11.json`, `assets/hunting/routes-h11.json`. Mốc H1.0 bên dưới được giữ làm lịch sử.

## Kiểm tra mốc H1.0

- **288/288 kiểm tra live đạt**: tám khu quái + một trại; đủ 13 đường quái + hai đường trại; chín tuyến và chiều ngược nối được trên mạng đường thật.
- **4.308 điểm dò nền** trên tâm và hai bên đường có nền đỡ, không có hố hoặc mặt đường lệch ngưỡng. Độ dốc mặt nền lớn nhất đo được **18,82°**; không phát hiện Decor có va chạm chắn hành lang kiểm tra 40 × 50 studs.
- Trong Play, nhân vật đi từ A tới R2 và qua tuyến C–R5 bằng công cụ điều khiển nhân vật, kết thúc với 100 máu. Đã dùng phím M và bấm chuột chọn C; bảng đóng và nhân vật tới đúng khu.
- Camera Custom, không còn GUI khủng long mẫu chiếm camera; nhật ký lỗi client ở lượt Play cuối rỗng.
- Đo hai giây thực: tỷ lệ đồng hồ **30,000000000000428 lần** (sai số số thực). Đã xem cảnh ban ngày và ban đêm sau khi nâng vùng tối.
- File sau Save bằng Studio được đọc kiểm tra lại: 25 script biên dịch được, source cấu hình/runtime khớp file làm việc, con mẫu còn **255 BasePart, 21 MeshPart, bảy Motor6D, 247 WeldConstraint, một phần gốc Anchored**.

Kết quả: `assets/hunting/validation.json`, `assets/hunting/saved-place.json`. Ảnh: `assets/hunting/overview.png`, `assets/hunting/night-play.png`.

Lune phát cảnh báo đọc thuộc tính Terrain `VoxelGridAssetContentMap` chưa hỗ trợ. Công cụ kiểm tra chỉ đọc; **không dùng Lune ghi lại file map có Terrain**. Kiểm chứng nền/va chạm thực hiện trực tiếp trong Studio; lưu map bằng Studio.

## Phần tiếp theo được ghi ở mốc H1.1 — đối chiếu hiện hành ở đầu tài liệu

- Người dùng đi thử và chỉnh cảm giác quy mô, mật độ cây, màu/vách đá và các bãi chiến đấu.
- Bộ đi tuyến hiện là tuần tra theo mạng đường đã dựng. Còn phản ứng khi bị săn, đuổi người chơi, chiến đấu, né vật cản động và chọn tuyến theo tình huống. Chưa coi đây là AI săn hoàn chỉnh.
- Nối lựa chọn nhiệm vụ, vào khu săn và về sảnh Dark Jungle. **Hiện chưa kết nối file khu săn riêng với sảnh**, chưa có thưởng/bắt giữ/chiến đấu nhiệm vụ ở map này.
- Chưa thử nhiều client, điện thoại hoặc hiệu năng máy yếu. Bản cây/đá hiện tại là khung cảnh có thể chỉnh, chưa là mốc tối ưu cuối.

## Nguồn và công cụ

- `src/hunting/HuntingMapConfig.luau`: khu, độ cao, đường, tuyến và tỷ lệ ngày/đêm.
- `src/hunting/BuildHuntingMap.luau`: các bước dựng riêng trong Edit; không chạy lại trên bản đã có sửa thủ công. Không dùng bộ dựng L0 để thay map này.
- `src/hunting/EnvironmentClock.luau`, `HuntingMapRuntime.server.luau`, `HuntingMapViewer.client.luau`: runtime xem map.
- `src/hunting/DinosaurRouteController.luau`: tuần tra theo đường thật, đi/nghỉ và dáng đi con mẫu.
- `src/hunting/EnhanceHuntingForest.luau`: bổ sung cụm rừng và vách đá, chỉ thay phần `Decor.ForestEnhancement` do module này tạo.
- `tools/validate-hunting-map.luau`: kiểm tra vật lý và mạng đường trực tiếp trong Studio, chỉ đọc.
- `tools/test-hunting-route.luau`: chạy sáu tổ hợp tuyến/chiều trên bản sao tạm, kiểm tra nghỉ/dáng đi/nền/vật cản rồi dọn bản sao.
- `tools/inspect-hunting-map-saved.luau`: đọc file sau lưu, kiểm tra cấu trúc/rig/source, không ghi `.rbxl`.
