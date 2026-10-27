# HunDino SaveGame

**Bản sửa hiện hành 27/10/2026:** file `HunDino_MerchantWeapons_20261026.rbxl` và Roblox v14 đã sửa lỗi `Economy:InvalidProfile` khi tài khoản từng dùng HelloHunDino. Giữ nguyên kho lưu, biên nhận và tiến trình; máy chủ thật xác nhận tải sẵn sàng và lưu DataStore thành công. Xem `PHAT_HANH_20261027.md`.

## Chơi và lưu trên máy

Mở **CHOI_VA_LUU.cmd** hoặc **CHOI_CUA_HANG.cmd**. Từ 26/10/2026, cả hai bật bộ lưu chạy nền trên máy rồi mở bản chính **HunDino_MerchantWeapons_20261026.rbxl** bằng Roblox Studio theo lựa chọn người dùng. Bấm Play để chơi. Bản này đã gộp cửa hàng với các sửa cung/Pet/di chuyển, giữ cùng kho tiến trình. Lần sau tiếp tục mở bằng một trong hai launcher, kể cả sau khi khởi động lại máy.

- Map và mã game hiện hành: `HunDino_MerchantWeapons_20261026.rbxl`; `HunDino_SaveGame.rbxl` giữ làm mốc đối chiếu.
- Tiến trình từng người: `local-save/profiles.json` (tạo khi chạy bộ lưu).
- Bản dữ liệu trước lần ghi gần nhất: `local-save/profiles.previous.json`.
- Trong game: **Cài đặt → Save game**, chờ xác nhận **Đã lưu trên máy** rồi mới Stop. Tự lưu khoảng 3 giây và lưu các giao dịch kinh tế vẫn hoạt động.
- Stop rồi Play lại quá nhanh có thể phải chờ tối đa khoảng 10 giây để khóa phiên cũ hết hạn; game tự tải lại.
- Nếu báo chưa kết nối bộ lưu, mở CHOI_VA_LUU.cmd rồi bấm **THỬ TẢI LẠI**.

Bộ lưu chỉ nghe tại `127.0.0.1:18764`, không gửi dữ liệu lên mạng và không khởi động cùng Windows. CHOI_VA_LUU.cmd dùng Python đi kèm Codex trên máy này. Nếu chuyển dự án sang máy khác cần Python 3.10+ và sửa đường dẫn Python trong launcher. Không xóa thư mục local-save nếu muốn giữ tiến trình.

## Lưu trên Roblox

**Cập nhật 27/10/2026:** đã Publish bản chính `HunDino_MerchantWeapons_20261026.rbxl` vào đúng game dưới đây, **PlaceVersion 12**. Đã nạp lại bản cloud để xác nhận nội dung mới; không đổi StoreName/Scope và không reset dữ liệu tài khoản. Lần này xác nhận phát hành, không phải một lượt kiểm hồi quy toàn bộ gameplay/cloud persistence. Chi tiết: `PHAT_HANH_20261027.md`.

Đã tạo bản riêng **HunDino SaveGame**: [Mở game](https://www.roblox.com/games/103801986821599/) · [Creator Dashboard](https://create.roblox.com/dashboard/creations/experiences/10772272829/overview). Có thể mở nhanh bằng **CHOI_TREN_ROBLOX.url**. PlaceId `103801986821599`, GameId `10772272829`, thuộc tài khoản chủ dự án `11605296816`. Tạo mới với PC, chưa mở Public. Không cập nhật đè các game HunDino cũ.

Đã thử bằng ứng dụng **Roblox Player VNG**, sau khi chủ dự án tự đăng nhập: đổi độ nhạy **100% → 75%**, thấy xác nhận lưu lúc **00:41:39 UTC+7**, thoát và mở lại đúng Place; phiên vào lại vẫn hiện **75%**, hồ sơ sẵn sàng và xác nhận lưu lúc **00:43:07 UTC+7 ngày 22/10/2026**. Cài đặt thử 75% được giữ để người chơi xem kết quả. Đây là nghiệm thu cloud cho cài đặt, chưa phải kiểm hồi quy toàn bộ xu/nguyên liệu/bắt sống.

Khi chạy game đã xuất bản bằng ứng dụng Roblox, cùng hệ thống dùng `HunDinoProfiles_v1` trong DataStore của chính game đó. Bản SaveGame đã bật `StudioLocalFileEnabled`, nên khi Play trong Studio sẽ dùng bộ lưu trên máy, kể cả khi mở Place đã xuất bản. Nếu chủ động tắt cờ này để thử DataStore trong Studio, game dùng kho thử riêng `HunDinoProfiles_Studio_v1` và cần quyền Studio API.

Hai kho không tự đồng bộ: vật phẩm thử trên máy không tự cộng sang tài khoản Roblox. Nút Save game lưu vào kho của phiên đang chạy. Ctrl+S chỉ lưu mã/map.

## Kiểm chứng

- Bộ lưu file: 5 phép thử đạt (khởi động lại giữ dữ liệu, backup, tranh chấp ghi, file hỏng, dữ liệu không hợp lệ và giao thức HTTP).
- Kho hồ sơ chung: 160 kiểm tra / 11 nhóm đạt.
- Studio thực: LocalFile tải thành công, đổi độ nhạy 100% → 50%, Save xác nhận; Stop/Play và khởi động lại bộ lưu vẫn đọc lại 50%.
- Đã xử lý tự thử lại khóa phiên local sau khi Stop/Play nhanh.
- Bản native Studio sau khôi phục Nhập code: 406 kiểm tra, 139 script biên dịch, 47.064 Part trong Workspace giữ cùng fingerprint với bản trước sửa; 66 thuộc tính Terrain đọc được khớp. Lune không đọc được kiểu mới `Terrain.VoxelGridAssetContentMap`, nên không chứng nhận thuộc tính đó. File được lưu bằng Studio, không ghi lại bằng Lune.
- Cloud thực: cài đặt 75% giữ qua thoát/vào lại; không dùng TestMemory hay LocalFile cho phép thử này. Chưa kiểm đầy đủ các giao dịch kinh tế/cá thể trên cloud.
- Nhập code: 346 kiểm tra / 11 nhóm đạt với luật kinh tế ghép vào đúng bản SaveGame. Trong Studio và Roblox Player đều đã bấm Cài đặt → Nhập code, nhập `QA-INVALID-CODE` và nhận lỗi từ server. Đã sửa lớp nền đóng bảng khi bấm ô nhập; thử nhập bằng bàn phím thật trong Roblox Player thành công. Cài đặt cloud 75% vẫn còn sau vào lại. Mã admin thật chưa sử dụng.
- Báo cáo: `assets/data/savegame-saved.json`, `assets/data/savegame-play.json`, `assets/data/savegame-redeem-saved.json`, `assets/data/savegame-redeem-play.json`.

File v2.4 gốc được giữ nguyên. ProfileConfig chuẩn mặc định tắt LocalFile; chỉ bản HunDino_SaveGame đã bật rõ ràng. Chế độ TestMemory vẫn tắt.

## Nhập code đã khôi phục — 22/10/2026

Bản SaveGame trước sửa được tạo từ v2.4 chưa có giao diện Nhập code. Đã bổ sung lại **Cài đặt → Nhập code** cạnh **Save game**, cùng kiểm tra và lưu biên nhận nhận thưởng phía server. Đã lưu vào `HunDino_SaveGame.rbxl` và xuất bản đến đúng Place `103801986821599`, gồm sửa lỗi lớp nền đóng ô nhập. Cần thoát/vào lại game để nhận giao diện mới. Dữ liệu chơi hiện có được giữ nguyên; hai kho local/cloud vẫn tách riêng.

Bản trước sửa và bản sao tiến trình nằm trong `backups/savegame-before-redeem-20261022/`. Mã dành cho admin và quy tắc dùng một lần xem `ADMIN_TEST_CODE.md`.
