# Nguyên liệu, thưởng và chế tạo — P1-E

**Cập nhật lớp lưu 20/10/2026:** v2.4 đã nối dữ liệu tiến trình vào hồ sơ tài khoản; xem [PERSISTENCE.md](PERSISTENCE.md) và thiết kế mục 39. Kiểm logic/Studio test đã có; nghiệm thu cloud qua thoát/vào còn chờ game xuất bản. Các câu chỉ giữ trong phiên và số liệu dưới đây thuộc mốc trước lớp lưu.

**Đồng bộ tài liệu: 20/10/2026 — đối chiếu bản v2.4 đã lưu ngày 19/10/2026.**

Kinh tế P1-E đã được nối với [kho cá thể P1-F bước đầu](SPECIMEN_COLLECTION.md): một lần bắt ghi một cá thể cùng nguyên liệu, xu/xương và vật tư còn lại, chống nhận lặp. Hồ sơ hiện là **DataVersion=2 / ServerMemory**, tối đa **100 cá thể**; chưa có DataStore hoặc ống trưng bày. Xem vật phẩm và cá thể trong Inventory; **Chế tạo trong Inventory vẫn là khung chờ**, bàn chế/nâng thử tại base tiếp tục hoạt động.

Bản chơi: **HunDino_DarkJungle_v2_4.rbxl**, nối tiếp nhiệm vụ/bắt sống P1-D. Kho dùng **bộ nhớ máy chủ**: đồ và xu giữ qua chết, đổi khu và nhiều lượt săn trong cùng máy chủ; chưa lưu tài khoản khi máy chủ kết thúc. Mỗi hồ sơ mới trong máy chủ có **80 xu**, không cấp lại khi hồi sinh hoặc nhận lượt mới.

## Chơi thử

1. Tại sảnh, đến **quầy tiếp tế** đối diện phía bảng nhiệm vụ, cất vũ khí, bấm **G**. Mua **bẫy thô 10 xu** hoặc **thuốc ngủ 10 xu**. Bẫy thô chưa đặt được.
2. Nhấn **J** nhận nhiệm vụ. Máy chủ tự chuyển tối đa **3 bẫy sắt + 3 thuốc ngủ đang sở hữu** từ kho sang lượt săn. Không có vật tư hoặc hết xu vẫn được săn tiêu diệt và nhặt quặng.
3. Sáu điểm quặng nằm ngoài vùng an toàn, theo vòng cung phía bắc trại. Đến gần, cất vũ khí, bấm **G**: mỗi điểm cho **1 sắt**, một lần/lượt. Khi quái lần đầu giảm qua 50% HP và vẫn sống, rơi **1 vảy** gần vị trí đó; phải tới nhặt, không tự cấp vào kho.
4. Hạ quái nhận **1 xương + 40 xu**. Trong 120 giây thu hoạch, đến sát thân/chân xác, cất vũ khí, **giữ G 1,5 giây** để mổ; tối đa **3 lượt**, mỗi lượt một nguyên liệu. Thả phím, di chuyển, bị đánh, rút vũ khí, chết, mở menu hoặc bay sẽ hủy lượt mổ chưa hoàn tất.
5. Bắt sống nhận **một cá thể riêng**, **ba lượt nguyên liệu** cùng **1 xương + 40 xu**; không có xác hoặc lượt mổ thêm. Tiếp tục dùng B/G để đặt bẫy/cho uống như P1-D.
6. Về **base của bạn**, đến bàn chế tạo cạnh bệ dịch chuyển, cất vũ khí, bấm **G**. **1 bẫy thô + 1 sắt → 1 bẫy sắt**; **2 xương + 2 sắt → búa cấp 2**, tăng sát thương búa của người chơi **15%**. Chỉ nâng một lần; không tăng sát thương Pet hoặc các vũ khí khác.

Nhấn **I** hoặc biểu tượng Túi đồ, chọn **VẬT PHẨM** để xem xu, da/răng/vảy/xương/sắt, bẫy thô/bẫy sắt/thuốc ngủ và phần đang mang đi săn. Không còn nút kho nguyên liệu bên ngoài. Tab Chế tạo trong Inventory hiện chỉ là khung chờ; bàn tại base bên dưới giữ bản thử P1-E. Mua cần ở gần thương nhân; chế/nâng cần ở đúng base của mình. Xem kho ở xa không cấp quyền giao dịch.

## Bảng nguyên liệu và kết quả

| Nguồn | Kết quả trong bản thử |
| --- | --- |
| Mỗi lượt mổ | Da 50%, răng 25%, vảy 25%; lượng 1 |
| Mỗi lượt nguyên liệu bắt sống | Chọn loại như trên, rồi độc lập xét lượng 1/2 với xác suất 50% mỗi lượng |
| Hoàn thành săn thường | 1 xương + 40 xu, một lần; tách với mổ/bắt |
| Quặng | 6 điểm × 1 sắt, không tạo lại do hồi sinh |
| Vảy giữa trận | Một vảy khi lần đầu qua 50% và còn sống; phải nhặt |
| Thất bại hoặc bỏ cuộc | Giữ đồ đã nhặt/mổ hợp lệ; không có gói hoàn thành mới |
| Trở về | Vật tư chưa dùng trả kho một lần; không tự cấp quặng/vảy/lượt mổ chưa nhặt |

Đây là bảng rơi thử theo thiết kế P1, chưa phải cân bằng toàn game. P1-F bước đầu đã thêm cá thể sở hữu trong bộ nhớ máy chủ; **chưa có ống trưng bày hoặc lưu tài khoản**.

## Quyền máy chủ và giao dịch

Máy chủ quyết định vị trí/tầm, trạng thái, thời gian mổ, công thức, số lượng và ngẫu nhiên. Client chỉ gửi thao tác. Giao dịch mua/chế/nâng dùng mã thao tác do máy chủ cấp, kiểm tra lại vị trí và phiên bản kho; gửi lại mã cũ không mua hoặc nâng thêm.

Mỗi nguồn quặng/vảy/mổ và gói thưởng có mã gắn với người, lượt săn và cá thể. Nguyên liệu cùng dấu nhận được cập nhật trong một thao tác không nhường luồng; thử lại trả kết quả đã ghi, không quay ngẫu nhiên lại. Bắt sống hiện ghi cả cá thể có mã riêng, số vật tư còn lại, nguyên liệu và gói thưởng cùng một giao dịch. Máy chủ kiểm tra kho đầy trước khi trừ thuốc; không tạo cá thể khi hạ quái. Trả đồ dư khi về cũng có dấu riêng, tránh vừa giữ trong lượt cũ vừa cộng kho.

Giữ tối đa 64 giao dịch cửa hàng và 8 lượt đã đóng gần nhất; số thứ tự tăng dần từ chối mã cũ đã dọn. Lượt đang chạy giữ toàn bộ dấu nguồn. Các dấu này chỉ bảo vệ trong bộ nhớ máy chủ; chưa thay cho lưu bền vững.

## Kiểm chứng mốc P1-E — trước kho cá thể

- **767 kiểm tra luật / 23 nhóm** đạt: khởi tạo, mua/chế/nâng nguyên tử, các nguồn thưởng, quay thưởng ổn định, trả đồ, hết xu, thiếu nguyên liệu, mã lặp/cũ và giới hạn sổ giao dịch.
- **121 kiểm tra tích hợp / 21 tình huống** đạt với controller bản sao, Humanoid, raycast và va chạm thật: mổ đủ thời gian, ngắt, ba lượt, quặng/vảy một lần, khoảng cách, vật cản và dọn đối tượng.
- **231 kiểm tra nhiệm vụ** và **96 kiểm tra combat** tiếp tục đạt.
- Play: mua bẫy thô trừ 10 xu; gửi lại mã cũ vẫn chỉ một bẫy. Nhặt đủ 6 quặng, hạ quái nhận 1 xương/40 xu, mổ đủ ba lượt; bấm tiếp không có lượt thứ tư. Về sảnh trả lại bình chưa dùng.
- Một lượt bỏ cuộc sau nhặt thêm quặng giữ sắt, xương và xu đã có; không cộng gói thắng. Chế bẫy trừ đúng một bẫy thô và một sắt; lượt sau mang đúng bẫy đã chế và thuốc đã mua.
- Bắt sống ở 120 HP tiêu đúng một bẫy/một thuốc, nhận ba lượt nguyên liệu và gói cố định. Sau hai lượt thắng, nâng búa trừ đúng 2 xương/2 sắt; gửi lại mã nâng không trừ thêm. Đòn Light thực tế tăng từ 36 lên **41,4**.
- Sau sửa prompt vảy, đã thử lại bằng source cuối trong phiên Play mới: 80 xu/cấp 1/không vật tư vẫn vào săn, nhặt bằng G được 1 sắt/1 vảy. Bỏ cuộc giữ cả hai, xu vẫn 80 và không có xương thưởng.

Bản lưu native Studio đạt **139.088 kiểm tra đọc/đối chiếu**, **108 script** biên dịch và **21 source chuẩn** khớp; 92 source cũ không liên quan giữ nguyên. Giữ toàn bộ **43.775 Part/845 khớp**, trong Workspace **35.064 Part/723 khớp**. Bốn nguồn mới và sáu bản sao source cũ đã được kiểm tra riêng. Các phép đếm này xác nhận bản lưu và hình học, không phải 139.088 tình huống chơi.

Các lượt chiến đấu thử có hỗ trợ đặt vị trí và tạm tăng HP nhân vật lên 1.000 trong Play để lặp lại tình huống; đã trả về 100. Không sửa HP quái để cấp thưởng. Đây là kiểm chứng hệ thống, chưa đánh giá cân bằng hoặc trải nghiệm điện thoại/săn đội. Terrain không bị sửa bởi các harness.

```powershell
.\tools\lune\lune.exe run tools/test-hunt-economy-rules.luau
.\tools\lune\lune.exe run tools/test-hunt-quest-rules.luau
.\tools\lune\lune.exe run tools/inspect-hunt-economy-saved.luau
```

`tools/test-hunt-harvest.luau` và `tools/test-dinosaur-combat.luau` chạy nội dung trong Studio qua MCP `execute_luau` ở Edit/Server. Không chạy các harness dùng Instance bằng Lune. Báo cáo: `assets/hunting/hunt-economy-play.json` và `hunt-economy-saved.json`. Backup trước P1-E: `backups/Hub_v24_before_hunt_economy_20261019.rbxl`.

## Source

- `HuntEconomyRules.luau`: hồ sơ, giao dịch, thưởng, nguồn vật tư và nâng búa.
- `HuntEconomyService.luau`: kho bộ nhớ, kiểm tra giao dịch, thương nhân và bàn tại 12 base.
- `HuntHarvestController.luau`: quặng/vảy trong map, giữ mổ và kiểm tra vật lý.
- `HuntEconomy.client.luau`: kho, mua/chế, thông báo và giữ G mổ.

Các file này nằm trong `src/hunting`. Training, QuestService, Quest UI, HubUI và callback sát thương của khủng long nối chúng vào vòng săn. P1-F đã có kho cá thể trong bộ nhớ; phần tiếp theo còn một ống và lưu tài khoản trong môi trường thử riêng, rồi hồi quy P1-G. Bộ luật mới đạt 2.134 kiểm tra/31 nhóm theo báo cáo P1-F, bao gồm 767 kiểm tra kinh tế cũ; đây là bằng chứng sẵn có, không phải lượt chạy lại của đợt tài liệu.
