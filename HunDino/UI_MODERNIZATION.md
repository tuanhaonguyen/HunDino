# Modern Dark Hunter UI — 20/10/2026

**Cập nhật lớp lưu 20/10/2026:** v2.4 đã nối dữ liệu tiến trình vào hồ sơ tài khoản; xem [PERSISTENCE.md](PERSISTENCE.md) và thiết kế mục 39. Kiểm logic/Studio test đã có; nghiệm thu cloud qua thoát/vào còn chờ game xuất bản. Các câu chỉ giữ trong phiên và số liệu dưới đây thuộc mốc trước lớp lưu.

**Trạng thái: đã cài vào đúng v2.4, thử native Studio Play, lưu bằng Ctrl+S và đối chiếu bản lưu thành công ngày 20/10/2026.** Bản lưu hiện có **4.250.777 byte**, 120 script biên dịch được và đủ chín source UI khớp mã nguồn. Desktop thử ở **1.453 × 808**; đã căn bố cục khi giả lập điện thoại ngang, chưa nghiệm thu toàn bộ gameplay cảm ứng.

## Phạm vi UI đã cài

- `UITheme`: nền (16,20,26), trong suốt 0,12, góc 14 px, viền đồng 1,5 px/gradient; thẻ (26,32,42), hover vàng kim 0,15 s Quad.Out. Máu xanh lục bảo; thể lực/tụ cung xanh băng; cảnh báo cam đỏ.
- Inventory giữ năm tab. Người/Pet có bục tối, đặt lại góc nhìn, cấp vũ khí, bốn chuỗi phím, badge giáp đang mặc và số mảnh bộ. Vật phẩm có lọc và tách kho/đang mang; cá thể có thời gian UTC+7, hệ, biến thể, kích thước, GUID và nguồn lượt săn.
- Boss lên giữa phía trên, cảnh báo suy yếu, thanh giữ bẫy và nhấp nháy/rung nhẹ trong ba giây cuối. Nhiệm vụ bên phải; Pet bên trái phía dưới, có vòng hồi chiêu 119 giây và trạng thái dừng đánh khi bắt.
- Vòng giữ phím giữa tâm đọc mốc thời gian do server công bố: B đặt bẫy 1 giây, G mổ 1,5 giây, G cho uống 3 giây. Các client hiện có tiếp tục sở hữu input/hủy thao tác; vòng hiển thị không gửi yêu cầu hoặc trao thưởng.
- Đổi màu Hub, quầy tiếp tế/bàn chế hiện có và HUD thể lực/cung. Bỏ các khung thông tin trùng/chồng khi đang săn.

Tab Chế tạo vẫn chờ; không mở giao dịch từ xa hoặc trưng bày. Không triển khai DataStore, phòng thủ giáp, săn đội hay sửa server/map trong bước UI này.

Giữ bảy source UI hiện có; thêm `ReplicatedStorage.Shared.UITheme` và `StarterPlayer.StarterPlayerScripts.HunDinoHoldProgress`. Installer đối chiếu baseline trước khi cài và lưu bảy source gốc vào `ServerStorage.UIBackup_20261020`; không tự lưu Place. Gói nguồn [HunDinoUIModernization.rbxm](assets/ui/HunDinoUIModernization.rbxm) chỉ chứa source, không chứa map/Terrain; danh sách cài tại [ui-modernization-install.json](assets/ui/ui-modernization-install.json).

## Play thực: hành động do server xác nhận

Các kết quả dưới đây được thực hiện trong native Studio Play với UI desktop **1.453 × 808**. Có hỗ trợ đưa nhân vật tới quầy/nguyên liệu/bàn chế để giảm thời gian di chuyển; khi thử hồi máu, Pet được đưa vào khoảng cách 2 studs với chủ. Đây là kiểm tra kết nối UI và hành động, không phải đo nhịp chơi, cân bằng hoặc khả năng tìm đường tự nhiên.

| Hạng mục | Quan sát trong Play |
| --- | --- |
| Inventory | Cả năm tab hiển thị; bộ lọc Vật tư săn có đúng `RawTrap`, `IronTrap`, `SleepPotion`; giáp Pet Kim loại hiển thị `5/5` |
| Trang bị độc lập | Đổi Người sang Katana giữ Pet dùng Búa; đổi Pet sang Kiếm/khiên giữ Người dùng Katana. Đã trả cả hai về Búa sau kiểm tra |
| Mua vật tư | Thực mua một bẫy thô và một thuốc ngủ; xu giảm từ `80` xuống `60` |
| Nhặt và trả vật tư | Thực nhặt quặng nhận `+1 sắt`; bỏ lượt săn thứ nhất trả lại thuốc chưa dùng |
| Chế tại Base | Thực chế một bẫy sắt tại bàn chế ở Base từ bẫy thô và sắt; không mở thao tác chế trong Inventory |
| Giữ B đặt bẫy | Lượt săn thứ hai thực đặt bẫy: ảnh vòng giữ ghi nhận `42%`, mẫu cuối `100%`; server chuyển sang bẫy chờ và số bẫy còn `0` |
| H gọi Pet hồi máu | Thực gọi H khi chủ `30 HP`; sau hỗ trợ Pet đến gần, máu tăng lên `100 HP` và HUD ghi hồi chiêu còn `118 giây` |

## Play thực: fixture chỉ kiểm tra hiển thị

Các trường hợp sau dùng **fixture phía client**, không tạo dữ liệu sở hữu hoặc kết quả bắt/mổ trên server. Chúng kiểm tra phần trình bày của các trạng thái khó tái hiện trong cùng lượt; không được coi là bằng chứng hoàn thành vòng bắt sống hoặc thu hoạch thật.

| Fixture | Quan sát |
| --- | --- |
| Boss suy yếu | `120 / 1.200 HP`, badge bắt sống và màu cảnh báo xuất hiện |
| Bẫy sắp hết | Còn `2,8 giây`, cảnh báo cam đỏ nhấp nháy/rung nhẹ |
| Cho uống thuốc | Vòng giữ 3 giây đến `100%`; Pet hiện trạng thái ngừng đánh khi đang bắt |
| Mổ xác | Vòng giữ 1,5 giây có mẫu `88%` |
| Pet choáng | `1 HP`, nút gọi Pet bị khóa và trạng thái phục hồi `30 giây` |
| Cá thể mẫu | DTO mẫu `#001` hiển thị mô hình 3D, metadata và ngày UTC+7; kéo chuột thật đổi camera, nút đặt lại khôi phục đúng góc gốc |

DTO cá thể ban đầu đã được khôi phục sau kiểm tra; fixture `#001` không nằm trong `OwnedSpecimens` của server. Bộ quan sát DTO tạm thời là `StringValue` dưới `PlayerGui`, chỉ tồn tại trong Play và bị dọn khi Stop. Chưa tuyên bố đã bắt sống hoặc mổ xác thật trong đợt UI này.

## Màn hình ngang nhỏ

Đã dùng preset **iPhone 17 Pro**, LandscapeLeft, trong Device Simulator. Kích thước camera thực tế của lượt thử là **750 × 381**, vùng GUI an toàn **750 × 323**. Đã sửa chồng Boss/Pet/thống kê và thu gọn các khung theo vùng GUI an toàn: Boss ở y66–139, Pet y141–231, nhiệm vụ y132–311; Inventory nằm trọn trong vùng màn hình. Hướng dẫn combo phụ ẩn ở bố cục gọn; vẫn xem bốn chuỗi trong Inventory. Tiêu đề rút gọn để giữ dòng Base.

Đây là kiểm tra bố cục giả lập, chưa phải nghiệm thu thao tác cảm ứng trên thiết bị thật; một số nút khi co nhỏ chưa đạt kích thước bấm mong muốn cho bản mobile đầy đủ. Sau thử đã dừng Play và trả Studio về viewport mặc định. Output có cảnh báo asset/CoreGui Roblox; không thấy lỗi runtime từ các script UI mới.

Bằng chứng thao tác và phân biệt fixture: [ui-modernization-play.json](assets/ui/ui-modernization-play.json).

## Kiểm tra offline đã chạy

| Kiểm tra | Kết quả |
| --- | --- |
| `tools/test-ui-modernization.luau` | 9 source biên dịch; 45 lệnh remote giữ nguyên action/payload; hai source trình bày mới không gửi remote |
| `tools/test-ui-modernization.luau --package` | Gói cài đọc lại đạt; DryRun không ghi; mô phỏng cài trong bộ nhớ tạo đủ 7 backup/2 source mới, đúng 9 source; chặn v2.3 trước khi thay đổi. Đây chưa phải Play trong Studio |
| `tools/test-equipment-inventory.luau` | Đạt; catalog, 5 vị trí, 40 preview giáp Người/Pet |
| `tools/check-hunting-sources.luau` | Toàn bộ source khu săn biên dịch |
| `tools/test-hunt-economy-rules.luau` | 2.134 kiểm tra / 31 nhóm đạt |
| `tools/test-hunt-quest-rules.luau` | 231 kiểm tra / 15 nhóm đạt |
| `tools/test-pet-combat-rules.luau` | 150 kiểm tra đạt |
| `tools/test-weapons-pro.luau` | Chưa đạt: dòng 40 so map v2.3 hiện có với backup trước vũ khí ngày 15/10; báo `unrelated scene modified`. Đây là baseline lịch sử, không phải phép kiểm map của bước UI này; giữ nguyên test |
| Inspector `--baseline` trước cài | File v2.4 và backup khi đó giống hệt `4.220.334 byte`; 118 script cũ biên dịch. Đây là bằng chứng baseline trước cài, không phải kết quả inspector sau khi lưu UI |
| Inspector `--report` sau lưu native | Đạt ở chế độ `native-save`: 8.784 kiểm tra, 61.193 instance hiện có đối chiếu, 5.334.152 lượt đọc/đối chiếu thuộc tính; không phát hiện khác biệt ngoài source UI được cho phép và metadata Studio đã ghi riêng. 120 script biên dịch, chín source chuẩn khớp và bảy backup source gốc đúng |

Backup Place: `backups/Hub_v24_before_ui_modernization_20261020.rbxl`.
Backup bảy source trước sửa: `backups/ui-modernization-20261020/`.

## Bản lưu đã xác nhận

[ui-modernization-saved.json](assets/hunting/ui-modernization-saved.json) hiện có `mode: native-save`, `validation: passed`. SHA-256 bản lưu:

`d360c3763761c85156b6eb4cc4f3cd14be5941aa84ddad312dc9ac5ef7d040ab`

Giữ **43.775 Part / 845 Joint** trên toàn Place; riêng Workspace **35.064 Part / 723 Joint**. Inspector đối chiếu các thuộc tính reflection đọc được, attributes, tags và source ngoài phạm vi UI. Những thuộc tính Lune không đọc được được liệt kê trong báo cáo; không tính chúng là đã đọc thành công. Mọi payload thuộc tính Terrain trong file native được băm trực tiếp và giống baseline, gồm cả dữ liệu voxel mà Lune không giải mã được. Inspector không ghi Place hoặc giải mã/ghi lại Terrain.

Hai ngoại lệ được ghi rõ: `HistoryId` là lịch sử chỉnh sửa của Studio; các instance gốc `FilteredSelection|Instance` do Studio quản lý giảm từ 5 xuống 4. Chúng đều rỗng, không có con, attributes hoặc tags, `Archivable=true`, `SourceAssetId=-1`; không phải đối tượng gameplay. Không áp dụng ngoại lệ này cho instance khác. Sau khi loại metadata đó và hai source mới/bảy backup, **61.193 instance hiện có** giữ nguyên các giá trị đối chiếu.

Đã dừng Play; kết nối v2.4 hiện ở chế độ Edit. Mở `HunDino_DarkJungle_v2_4.rbxl`, bấm **Play → I** để xem Inventory mới.

## Giới hạn của đợt kiểm tra UI

- Trang bị độc lập và bố cục desktop/điện thoại ngang đã thử trong phạm vi ghi ở trên; thao tác cảm ứng đầy đủ và thiết bị thật còn chờ.
- Đã quan sát vòng đặt bẫy thật và trạng thái reset vòng mổ bằng fixture. Các nhánh đổi menu, chết, mất focus và tổ hợp hủy thao tác chưa được thử đầy đủ theo ma trận Play; mã hiển thị có điều kiện ẩn cho các trạng thái này.
- Bắt sống/mổ xác thật, nhiều client và hồi quy P1-G chưa nghiệm thu trong đợt UI. Các fixture được phân biệt với hành động server ở bảng phía trên.

Không đồng bộ `default.project.json` của L0, không dùng Lune ghi file Place/Terrain.

Không cài lại gói lên Place đã có UI mới nếu chưa đối chiếu trạng thái source hiện hành; installer kiểm baseline và sẽ chặn source đã thay đổi.
