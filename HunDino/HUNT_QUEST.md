# Nhiệm vụ săn và bắt sống — nền P1-D, vật tư P1-E

<!-- TIEN_DO_20261027_BEGIN -->
> **Trạng thái đối chiếu 27/10/2026, 09:48 UTC+7:** local chính `HunDino_MerchantWeapons_20261026.rbxl` **4.495.025 byte**, SHA256 `8626bc714aa7a0da39493ba1bbcc676a142038b2f8a2c06e602fe01d522229bf`; inspector **129.779 kiểm / 164 source**, đạt. Cloud có bằng chứng mới nhất **v14**, nguồn **4.481.440 byte**; sửa bố cục ống mới chỉ local, **chưa Publish**.
>
> Tính năng trong tài liệu này được đối chiếu cùng bản chính hiện hành; các file v2.x/SaveGame, tham số và kết quả thử cũ trong phần dưới là mốc lịch sử, không tự chứng nhận toàn bộ bản mới. Phạm vi còn chờ: P1-G toàn vòng, cloud kinh tế/cá thể/ống, nhiều client và thiết bị thật.
>
> [Báo cáo tiến độ toàn dự án và hôm nay](BAO_CAO_TIEN_DO_2026-10-27.md). Ghi chú này cập nhật trạng thái; số liệu/hash của từng mốc cũ bên dưới giữ nguyên theo phạm vi lúc kiểm.
<!-- TIEN_DO_20261027_END -->

**Cập nhật lớp lưu 20/10/2026:** v2.4 đã nối dữ liệu tiến trình vào hồ sơ tài khoản; xem [PERSISTENCE.md](PERSISTENCE.md) và thiết kế mục 39. Kiểm logic/Studio test đã có; nghiệm thu cloud qua thoát/vào còn chờ game xuất bản. Các câu chỉ giữ trong phiên và số liệu dưới đây thuộc mốc trước lớp lưu.

**Đồng bộ tài liệu: 20/10/2026 — đối chiếu bản v2.4 đã lưu ngày 19/10/2026.**

Bản v2.4 hiện dùng vật tư sở hữu từ [P1-E](HUNT_ECONOMY.md); bắt thành công nhận thêm **một cá thể có mã riêng** trong [Inventory → Khủng long](SPECIMEN_COLLECTION.md). Kho cá thể tối đa 100; đầy vẫn săn tiêu diệt được nhưng máy chủ chặn bắt trước khi trừ thuốc. Dữ liệu chỉ giữ trong cùng máy chủ, **chưa lưu tài khoản hoặc trưng bày**.

Bản làm việc: **HunDino_DarkJungle_v2_4.rbxl**. P1-D nối tiếp Pet P1-C: nhận nhiệm vụ tại sảnh, săn T-Rex, đặt bẫy, cho uống thuốc ngủ, ghi kết quả và quay về. Mốc P1-D đã cài, thử trong Studio/Play và lưu bằng Studio, qua **139.055 kiểm tra** đọc/đối chiếu; đây là số của mốc nhiệm vụ trước P1-E/F, không phải tổng kiểm tra mới của bản cuối.

## Nhận nhiệm vụ

Tại sảnh trung tâm, cất vũ khí và dừng động tác. Nhấn **J**, nút **J · Nhiệm vụ**, hoặc giữ **G** gần bảng nhiệm vụ để mở bảng. Chọn **NHẬN NHIỆM VỤ · VÀO KHU SĂN**; máy chủ kiểm tra điều kiện rồi đưa người chơi đến trại săn.

Mỗi lượt có **40 phút**, mục tiêu **T-Rex · Không hệ, 1.200 HP**. Hạ gục hoặc bắt sống đều hoàn thành nhiệm vụ. Đồng hồ khu săn lấy giờ thực khi vào rồi chạy nhanh theo thiết kế; hạn nhiệm vụ được máy chủ tính riêng theo thời gian thực.

Bản thử đang dùng **một khủng long chung**, nên chỉ nhận **một lượt săn solo trên toàn máy chủ** tại một thời điểm. Khu săn phải trống trước khi nhận lượt mới. Người khác vẫn có thể ở sảnh hoặc bãi tập; khi chưa có nhiệm vụ đang chạy, lối vào thám hiểm khu săn vẫn dùng được. Bảng nhiệm vụ sẽ báo khi cần chờ khu săn trống.

## Bẫy sắt và thuốc ngủ

**P1-E đã thay vật tư miễn phí:** mỗi lượt tự mang tối đa **3 bẫy sắt và 3 thuốc ngủ đang sở hữu** từ kho thử. Mua thuốc và bẫy thô tại sảnh; chế bẫy sắt ở base từ 1 bẫy thô + 1 sắt. Đồ chưa dùng trả kho khi về, không cấp lại bộ mới. Không có vật tư vẫn săn tiêu diệt được. Xem [nguyên liệu và chế tạo](HUNT_ECONOMY.md).

| Thao tác | Điều kiện và thời gian |
| --- | --- |
| Đặt bẫy | Cất vũ khí; giữ **B** hoặc nút đặt bẫy đủ **1 giây**, đứng yên trên nền phù hợp ngoài vùng an toàn của trại |
| Vị trí bẫy | Vòng bẫy bán kính **4 studs** nằm trước mặt; cần đủ mặt đất bằng, không bị vật cản che hoặc vướng mép nước |
| Bẫy chờ | Tồn tại **60 giây**; chỉ có một bẫy đang hoạt động của lượt săn |
| Quái mắc bẫy | Dụ quái bước vào vòng; bị giữ **13 giây**, kể cả khi còn trên 10% HP |
| Cho uống thuốc | Quái còn sống, **HP ≤10%** — với con mẫu là **1–120/1.200 HP** — và đang mắc bẫy |
| Vị trí cho uống | Đến dấu sáng tại miệng mục tiêu, cách không quá **4 studs**; cất vũ khí, giữ **G** hoặc nút cho uống đủ **3 giây** |

HUD cho biết số vật tư, HP mục tiêu, thời gian giữ bẫy và tiến độ thao tác. Khi chỉ còn 3 giây giữ bẫy, đồng hồ đổi màu cảnh báo. Cần bắt đầu cho uống đủ sớm để hoàn tất trước khi quái thoát.

Thả phím/nút, di chuyển, nhận sát thương, rút vũ khí, đổi khu, chết, mở menu hoặc bay admin sẽ hủy thao tác đang giữ. Bẫy chỉ bị trừ khi đặt thành công; thuốc chỉ bị trừ khi bắt sống thành công. Bẫy đã đặt rồi hết hạn vẫn là một bẫy đã sử dụng. Pet tạm dừng hỗ trợ khi chủ đang cho uống thuốc, tránh hạ mục tiêu giữa thao tác.

Bắt sống thành công khóa kết quả một lần, khủng long thu nhỏ trong khoảng 2 giây rồi ẩn. P1-E ghi nguyên liệu/gói thưởng; P1-F bước đầu ghi thêm một cá thể riêng trong cùng giao dịch. Cá thể giữ qua về sảnh/hồi sinh trong cùng máy chủ; chưa lưu theo tài khoản qua phiên mới.

## Hồi sinh và kết thúc

Trong lúc săn, người chơi có **3 lượt hồi sinh tại trại** sau khoảng **5 giây**. Máu khủng long, mã lượt săn và hạn nhiệm vụ được giữ nguyên; hồi sinh không tạo lượt mới, không cấp lại vật tư và không đặt lại 40 phút. **Ngã lần thứ 4** hoặc hết thời hạn thì thất bại, hiện lý do rồi trở về sảnh.

Hạ gục hoặc bắt sống thành công chuyển sang **120 giây xem hiện trường**. Hạn nhiệm vụ dừng ảnh hưởng đến kết quả, còn **đồng hồ môi trường/ngày đêm vẫn chạy ×30 đến khi rời khu săn**, theo mục 26 của hồ sơ thiết kế. Người chơi có thể tiếp tục đi lại hoặc chọn **VỀ SẢNH NGAY**. Hồi sinh trong khoảng này giữ kết quả, số lần chết của phần nhiệm vụ và mốc kết thúc 120 giây. Khi hết thời gian, máy chủ đưa người chơi về sảnh. Rời cuộc săn trước khi có kết quả sẽ ghi nhận bỏ cuộc.

Trong 120 giây, P1-E cho mổ xác tối đa ba lượt, giữ G 1,5 giây/lượt, và nhặt quặng/vảy còn lại. Hạ hoặc bắt nhận 1 xương/40 xu; bắt còn có ba lượt nguyên liệu riêng. Kho nguyên liệu và kho cá thể đều ở bộ nhớ máy chủ; phần cá thể P1-F đã có, ống trưng bày và lưu tài khoản chưa làm. Các kiểm chứng P1-D dưới đây giữ mốc nền trước khi nối kinh tế/cá thể; xem [P1-E](HUNT_ECONOMY.md) và [P1-F bước đầu](SPECIMEN_COLLECTION.md) cho bằng chứng tiếp nối.

## Kiểm chứng lịch sử P1-D — trước kinh tế và kho cá thể

- **231 kiểm tra luật** đạt: thời hạn, ba lượt hồi sinh/lần ngã thứ tư, điều kiện HP, bẫy/thuốc, thao tác bị ngắt, khóa kết quả và đóng lượt.
- **163 kiểm tra controller trong 24 tình huống** đạt. Trường hợp dùng nước Terrain thật được bỏ qua vì lần lấy mẫu hồ hiện tại không tìm thấy điểm phù hợp; chưa coi đây là kiểm chứng trực tiếp đầy đủ cho mọi bờ hồ của map.
- **96 kiểm tra combat khủng long** và **6 nhóm luật vũ khí** đạt sau tích hợp.
- Đã thao tác bảng và nút nhận nhiệm vụ trong Play: bắt đầu lượt 40 phút, cấp đúng 3 bẫy và 3 thuốc. Đã thử đặt bẫy, giữ mục tiêu, hết hạn bẫy và bắt sống ở **84 HP**; thuốc giảm từ 3 còn 2, kết quả chuyển sang `Captured` và hiện 120 giây.
- Đã thử bốn lần ngã: ba lần đầu giữ cùng lượt, cùng hạn và HP khủng long; lần thứ tư kết thúc với kết quả thất bại và trở về sảnh. Hồi sinh sau khi đã bắt sống vẫn giữ kết quả và mốc xem hiện trường.
- Đã chờ tự nhiên đủ **120 giây sau bắt sống**: tự về sảnh với kết quả `Closed/Captured`, không còn người trong lượt săn; con mẫu phục hồi tỉ lệ gốc **3,716** và bỏ cờ Captured.
- Đã hạ mục tiêu bằng đòn **Light qua kiểm tra server**: HP về 0, chuyển `Harvest/Defeated`, bẫy/thuốc vẫn 3/3. Bấm nút **VỀ SẢNH NGAY** trên HUD trả về `Closed/Defeated`; lượt đóng, con mẫu hồi 1.200 HP và kích thước gốc.
- Ra ngoài biên trong nhiệm vụ đưa người chơi về trại, giữ mã lượt, hạn và số lần chết. Đo trong Harvest: giờ môi trường **19,76944 → 19,84167** qua **8,713 giây**, phù hợp tốc độ 2 phút thật/giờ trong map.

Các phép thử Play có hỗ trợ đặt vị trí nhân vật và tạm tăng HP người lên **1.000** để lặp lại tình huống chiến đấu, đã phục hồi **100 HP**; đây không phải thay đổi bản lưu hoặc kiểm chứng cân bằng toàn cuộc săn. Biên hết hạn được kiểm tra bằng luật, **chưa chờ đủ 40 phút thật**. UI giữ có hỗ trợ cảm ứng nhưng chưa chơi thử trên điện thoại hoặc với nhiều client thật.

**Bản lưu đã đạt 139.055 kiểm tra**, **98 script** biên dịch; **17 source chuẩn** khớp và **78 source cũ không liên quan** giữ nguyên. Giữ toàn bộ **43.775 Part/845 khớp** trong Place, gồm **35.064 Part/723 khớp trong Workspace**; map vẫn 4.000 × 4.500 studs, 2.400 cây, 9 node và 16 đường. Có backup tám source được sửa. Lune chỉ đọc/đối chiếu; Place/Terrain được lưu bằng Studio.

```powershell
.\tools\lune\lune.exe run tools/test-hunt-quest-rules.luau
.\tools\lune\lune.exe run tools/inspect-hunt-quest-saved.luau
```

`tools/test-hunt-capture.luau` và `tools/test-dinosaur-combat.luau` là harness dùng API Roblox: chạy nội dung trong Studio qua MCP `execute_luau` ở Edit/Server, không chạy trực tiếp bằng Lune. Hai harness dùng bản sao và dọn các đối tượng thử khi kết thúc. Báo cáo Play và tích hợp tại `assets/hunting/hunt-quest-play.json`.

Backup trước P1-D: `backups/Hub_v24_before_hunt_quest_20261019.rbxl`. Inspector của mốc P1-D chỉ đọc bản v2.4 và backup, đối chiếu source cùng hình học cũ; source nhiệm vụ đã được sửa tiếp ở P1-E/F nên không dùng số cũ làm kết quả chạy lại trên bản cuối. Báo cáo gốc tại `assets/hunting/hunt-quest-saved.json`.

## Source

- `src/hunting/HuntQuestRules.luau`: cấu hình và luật lượt săn, kết quả, hồi sinh, bẫy và thuốc.
- `src/hunting/HuntQuestService.luau`: bảng nhiệm vụ, lượt solo, chuyển khu, hồi sinh và quay về.
- `src/hunting/HuntCaptureController.luau`: kiểm tra nền, vật cản, khoảng cách, giữ phím và thao tác bắt sống trên máy chủ.
- `src/hunting/HuntQuest.client.luau`: bảng nhiệm vụ, HUD, nút và phím J/B/G; chỉ gửi yêu cầu thao tác.

Các điểm tích hợp nằm trong Training, HuntingSession, combat/tuyến khủng long và Pet; máy chủ sở hữu vật tư, thời gian, sát thương và kết quả. Phím đánh/cung/Pet hiện hành giữ nguyên. Nút giữ bằng chuột và cảm ứng đã có trong UI, nhưng chưa xác nhận đầy đủ trải nghiệm chơi trên điện thoại.
