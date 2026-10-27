# Nhập code thử cho admin — 21/10/2026

<!-- TIEN_DO_20261027_BEGIN -->
> **Trạng thái đối chiếu 27/10/2026, 09:48 UTC+7:** local chính `HunDino_MerchantWeapons_20261026.rbxl` **4.495.025 byte**, SHA256 `8626bc714aa7a0da39493ba1bbcc676a142038b2f8a2c06e602fe01d522229bf`; inspector **129.779 kiểm / 164 source**, đạt. Cloud có bằng chứng mới nhất **v14**, nguồn **4.481.440 byte**; sửa bố cục ống mới chỉ local, **chưa Publish**.
>
> Tính năng trong tài liệu này được đối chiếu cùng bản chính hiện hành; các file v2.x/SaveGame, tham số và kết quả thử cũ trong phần dưới là mốc lịch sử, không tự chứng nhận toàn bộ bản mới. Phạm vi còn chờ: P1-G toàn vòng, cloud kinh tế/cá thể/ống, nhiều client và thiết bị thật.
>
> [Báo cáo tiến độ toàn dự án và hôm nay](BAO_CAO_TIEN_DO_2026-10-27.md). Ghi chú này cập nhật trạng thái; số liệu/hash của từng mốc cũ bên dưới giữ nguyên theo phạm vi lúc kiểm.
<!-- TIEN_DO_20261027_END -->

**Cập nhật SaveGame 22/10/2026:** đã khôi phục **Cài đặt → Nhập code** vào `HunDino_SaveGame.rbxl` và bản Roblox riêng [HunDino SaveGame](https://www.roblox.com/games/103801986821599/). Luật ghép với kinh tế SaveGame đạt 346 kiểm tra / 11 nhóm; đã thử nhập mã sai qua UI và nhận lỗi server trong cả Studio lẫn Roblox Player, không sử dụng mã admin thật. Đã sửa lớp nền đóng bảng khi bấm ô nhập. Bản SaveGame bật LocalFile khi chạy Studio; Roblox Player dùng DataStore cloud. Các số liệu và Place của đợt 21/10 bên dưới là mốc lịch sử.

Mã: **`HUNDINO-ADMIN-500`**. Chỉ tài khoản **tunzdangcap / UserId 11605296816** được nhận. Mã cấp **500 xu** và **10 da, 10 răng, 10 vảy, 10 xương, 10 sắt**; không cấp bẫy hoặc thuốc. Không cho tài khoản khác nhận dù biết mã hoặc gửi remote trực tiếp.

Thử trên Place **HunDino đang mở trong Studio** (`PlaceId 103261391098991`): **Play → Cài đặt → Nhập code → nhập mã → Đổi mã**. Chờ thông báo máy chủ xác nhận; xu/nguyên liệu cập nhật trong **I → Vật phẩm**. Trạng thái đang tải/lỗi lưu sẽ khóa thao tác. Nếu chưa xác nhận lưu, dùng trạng thái lưu để thử lại và kiểm tra kho; không tự cộng thưởng ở client.

## Dùng một lần

Server kiểm UserId, chuẩn hóa khoảng trắng đầu/cuối và chữ hoa/thường; chỉ nhận chuỗi tối đa 64 byte. Client không được gửi số thưởng, tài khoản đích hoặc dấu đã dùng. Giới hạn một yêu cầu mỗi giây. Mã và tài khoản được cấu hình trong module chỉ có ở server, không có trong HubUI/ReplicatedStorage.

Phần thưởng cùng biên nhận `Economy.RedeemedCodes.AdminTest20261021` đi qua một `CommitEconomy`. Chỉ trả thành công sau khi lớp lưu xác nhận ghi. Dấu dùng mã tồn tại qua đăng nhập lại và không bị xóa khi 64 biên nhận mua/chế cũ hết hạn. Đổi chuỗi mã mà giữ cùng CodeId không cho nhận lại.

Hồ sơ v1/v2 cũ chỉ được thêm ledger rỗng khi trường chưa có; ledger có sẵn nhưng sai sẽ bị từ chối. Không reset tiến trình. Nếu bất kỳ số dư nào vượt giới hạn, toàn bộ gói bị hủy và mã chưa được đánh dấu dùng. Lỗi lưu giữ candidate chờ xác nhận gồm cả thưởng và biên nhận; không tách hai phần thành hai lần ghi.

Studio dùng store thử riêng `HunDinoProfiles_Studio_v1`, game live dùng `HunDinoProfiles_v1`. Đây là hai môi trường dữ liệu riêng theo cấu hình persistence hiện có. Không reset record hoặc tiêu thụ mã trên tài khoản thật để kiểm thử. Không thêm nút reset mã.

## Mã nguồn và kiểm tra

- `src/dark-jungle/HubUI.luau`: nút/subpage Nhập code, ô nhập, chờ phản hồi và thông báo.
- `src/hunting/AdminRedeemPolicy.luau`: mã thử, UserId và gói thưởng phía server.
- `src/hunting/HuntEconomyService.luau`: action `RedeemCode`, rate limit, quyền và phản hồi `CodeResult`.
- `src/hunting/HuntEconomyRules.luau`: giao dịch nguyên tử, migration và ledger mã đã dùng.
- `tools/test-admin-redeem.luau`: **346 kiểm tra / 11 nhóm đạt** bằng backend giả; quyền, thưởng, nhập lại, JSON, 70 giao dịch, overflow và lỗi trước/sau ghi.
- Các bộ kiểm kinh tế **2.272 / 35 nhóm**, schema **682 / 13 nhóm**, roundtrip **549 / 6 nhóm**, ProfileStore **160 / 11 nhóm** đạt.
- `tools/qa/admin-redeem.server.luau`: **156 kiểm tra / 6 nhóm đạt trong Studio**, dùng phương thức service thật với player/backend giả, tự dọn fixture. Kiểm quyền, payload lỗi, ghi trước phản hồi, dùng lại/đăng nhập lại, lỗi trước/sau ghi và yêu cầu đồng thời; không truy cập tài khoản thật.
- UI Play desktop **1.453 × 808**: bấm thật Cài đặt → Nhập code; ô rỗng khóa Đổi mã; nhập `QA-INVALID-CODE` và nhận lỗi từ server; Quay lại giữ đủ cài đặt cũ. Tài khoản admin sau thử vẫn **80 xu / 0 mỗi nguyên liệu**. Mã thật chưa được gửi.

Backup ba source gốc lấy trực tiếp từ Studio: `backups/redeem-admin-20261021/`, cùng ba StringValue trong `ServerStorage.AdminCodeBackup_20261021`. Bản sao Place native trước cài: `backups/Hub_before_admin_redeem_20261021.rbxl`, **4.262.220 byte**.

Sau khi Studio bị lag và mở lại, Place cloud thiếu `BioTubeService` dù source kinh tế gốc đã gọi module đó. Đã khôi phục đúng ba module chuẩn `BioTubeGeometry`, `BioTubeSpecimen`, `BioTubeService` để hệ thống kinh tế khởi động lại. Không chèn asset hoặc sửa hình học Edit; các ống được code sẵn dựng ở bản Play, không lưu vào cảnh nền. Đây là sửa phụ thuộc khởi động, không phải lượt nghiệm thu tính năng trưng bày.

Kế hoạch cuối gồm **bảy source**: ba source sửa, module mã mới và ba phụ thuộc khôi phục tại `assets/redeem/admin-redeem-install.json`. Các công cụ chuẩn bị/kiểm tra chỉ viết mã hoặc báo cáo, không xuất lại Place/Terrain.

## Bản lưu cuối

Đã Stop Play, lưu bằng native Studio, bấm Ctrl+S trên Place đang mở và Download a Copy thành **`HunDino_AdminTest_20261021.rbxl`**, **4.285.326 byte**. SHA-256:

`926f6b57297fe1ea103985cc26ec56a8e96414b7fb34657b64887632b687c8da`

[Báo cáo bản lưu](assets/redeem/admin-redeem-saved.json) ở chế độ `native-save` đạt: **8.683 kiểm tra, 129 script biên dịch, bảy source chuẩn khớp và ba backup gốc khớp**. Đối chiếu **61.208 instance hiện có / 5.334.543 lượt đọc/so thuộc tính**, không có khác biệt ngoài source được cho phép. Thuộc tính reflection không đọc được được liệt kê; không coi mỗi lượt đọc là một thuộc tính engine đã đọc thành công. `HistoryId` là metadata lịch sử Studio được loại; không có thay đổi số node `FilteredSelection` (0 → 0).

Giữ **43.775 Part / 845 Joint**, riêng Workspace **35.064 Part / 723 Joint**. Mọi payload thuộc tính Terrain nhị phân có hash giống bản sao trước cài, gồm dữ liệu voxel Lune không giải mã. Inspector chỉ đọc, không ghi Place/Terrain. Cấu hình `StudioMemoryTest=false`, không có override hoặc probe QA trong bản Edit cuối. Bằng chứng Play: [admin-redeem-play.json](assets/redeem/admin-redeem-play.json).

Snapshot trên là bản sao riêng của Place cloud dùng trong đợt này; file local `HunDino_DarkJungle_v2_4.rbxl` không bị ghi đè. Dữ liệu tài khoản nằm trong DataStore, không nằm trong snapshot `.rbxl`. Để thử mã với lưu tài khoản, dùng Place cloud đang mở trong Studio.

**Trạng thái:** đã cài, thử Studio và đối chiếu bản lưu thành công. Mã thật chưa sử dụng; để admin tự nhận lần đầu. Chưa Publish lên game live.
