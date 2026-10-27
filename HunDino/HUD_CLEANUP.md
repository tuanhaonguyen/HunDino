# Dọn HUD và chuyển lưu thủ công vào Cài đặt — 21/10/2026

<!-- TIEN_DO_20261027_BEGIN -->
> **Trạng thái đối chiếu 27/10/2026, 09:48 UTC+7:** local chính `HunDino_MerchantWeapons_20261026.rbxl` **4.495.025 byte**, SHA256 `8626bc714aa7a0da39493ba1bbcc676a142038b2f8a2c06e602fe01d522229bf`; inspector **129.779 kiểm / 164 source**, đạt. Cloud có bằng chứng mới nhất **v14**, nguồn **4.481.440 byte**; sửa bố cục ống mới chỉ local, **chưa Publish**.
>
> Thanh lưu thường trực đã bỏ, tự lưu và Save game trong Cài đặt giữ hoạt động. Cloud v14 đã có xác nhận Saved; chưa nghiệm thu mọi giao dịch.
>
> [Báo cáo tiến độ toàn dự án và hôm nay](BAO_CAO_TIEN_DO_2026-10-27.md). Ghi chú này cập nhật trạng thái; số liệu/hash của từng mốc cũ bên dưới giữ nguyên theo phạm vi lúc kiểm.
<!-- TIEN_DO_20261027_END -->

Đã sửa và thử phần hiển thị trong Studio để thanh máu không che giữa màn hình và bỏ thanh thông báo lưu thường trực. Cơ chế tự lưu trên server giữ nguyên; đã kiểm chứng tự lưu và nút Save game bằng DataStore riêng của Studio. **Đã lưu bản native [HunDino_HUDClean_20261021.rbxl](HunDino_HUDClean_20261021.rbxl) và đối chiếu thành công: 8.766 kiểm tra, 130 script biên dịch, không có khác biệt ngoài phạm vi cho phép.**

## Bốn source thay đổi

| Source | Thay đổi |
| --- | --- |
| `src/hunting/HuntQuest.client.luau` | BossHUD thu gọn còn `430 × 54`, mở lên `430 × 76` khi cần dòng suy yếu/bẫy; đặt ở y8 trong vùng GUI an toàn trên desktop. Hiện cả khi săn tự do (`InHunting=true`, chưa có `QuestState`); QuestHUD chỉ hiện trong lượt nhiệm vụ. Boss ẩn khi mục tiêu chết, đã bắt, đang thu hoạch hoặc người chơi mở menu. |
| `studio-pet-integration/Training.client.luau` | Thông báo `Notice` chỉ hiện tạm thời khi có sự kiện, không còn khung hướng dẫn thường trực giữa màn. Combo khi săn rút còn `420 × 52`; vẫn xem các chuỗi đầy đủ trong Túi đồ. Giữ bố cục gọn và dời bảng bay admin để tránh Boss. |
| `src/data/ProfileStatus.client.luau` | Bỏ ScreenGui `HunDinoProfileStatus` và thanh `SaveStatus`/nút `SaveNow`. Chỉ giữ `HunDinoProfileGate` khi chưa tải được hồ sơ hoặc có xung đột phiên; không giả cho chơi khi dữ liệu chưa sẵn sàng. |
| `src/dark-jungle/HubUI.luau` | Thêm **Cài đặt → Save game**, cạnh **Nhập code**. Trạng thái lưu và lỗi nằm trong Cài đặt; giữ ba tùy chọn hiển thị, độ nhạy cung và luồng nhập code hiện có. |

Boss mới thay phần máu nổi cũ khi ở khu săn, gồm cả săn tự do. Điều kiện hiển thị Boss tách khỏi QuestHUD; mở khu săn không yêu cầu nhận nhiệm vụ để thấy máu mục tiêu. Client tạm ẩn đúng `BillboardGui` có tên `DinosaurHealthbar` dưới mục tiêu và ghi nhớ giá trị `Enabled` ban đầu. Khi rời khu săn, đổi mục tiêu hoặc dọn client, giá trị được trả lại đúng cả hai trường hợp ban đầu `true` và `false`. Thao tác này chỉ đổi phần hiển thị phía client, không sửa trạng thái máu hay quest trên server.

Ở bố cục gọn (`rộng < 1000` hoặc `cao < 560` theo vùng GUI an toàn), Boss có tỷ lệ tối đa `0,74`; màn rộng từ 680 dùng tâm ngang `0,55`. Màn hẹp dưới 640 dời Boss xuống y56. Hướng dẫn combo phụ ẩn trong bố cục gọn. Các quy tắc bố cục không thay thế nghiệm thu cảm ứng trên thiết bị thật.

## Tự lưu và Save game

Server tiếp tục tự lưu theo cơ chế hồ sơ đã có, gồm lưu khi thoát và thử lại khi lỗi. Không hiện banner đang lưu/đã lưu thường trực khi đang chơi.

Nút `HubPanel.Body.SaveGame` gửi action `"Save"` qua `HunDinoProfileAction`, dùng giới hạn **5 giây** tương ứng với server. Nút khóa khi hồ sơ chưa sẵn sàng, đang tải/lưu/đóng, có xung đột hoặc dịch vụ chưa sẵn sàng; cũng khóa trong `TestMemory` để không báo nhầm rằng dữ liệu thử đã được lưu tài khoản. Trạng thái `Error` cho phép gửi lại yêu cầu lưu khi hồ sơ vẫn sẵn sàng.

UI chỉ xác nhận theo thuộc tính do server công bố (`ProfileSaveState`, `ProfileSavedAt`); gửi yêu cầu không đồng nghĩa đã lưu thành công. Khi chờ quá 12 giây mà chưa có xác nhận, Cài đặt báo chưa xác nhận và cho thử lại theo cooldown. Timer cùng các kết nối theo dõi của Cài đặt được ngắt khi đóng hoặc chuyển mục.

## Kiểm chứng đã có

Đã chạy native Studio Play ở viewport desktop **1453 × 768**. Các trạng thái khó tái hiện dùng **fixture phía client**, không tạo quest hoặc kết quả sở hữu giả trên server.

| Hạng mục | Kết quả |
| --- | --- |
| Boss thường | PASS: khung gọn, thanh HP và số máu đúng bố cục |
| Boss suy yếu và bẫy sắp hết | PASS: dòng cảnh báo/bẫy mở rộng; đếm ngược và cảnh báo vẫn hiển thị |
| Boss chết hoặc đã bắt | PASS: BossHUD ẩn |
| Mở menu | PASS: BossHUD ẩn khi menu chiếm màn hình |
| Rời khu săn, thanh máu cũ ban đầu bật | PASS: khôi phục `Enabled=true` |
| Rời khu săn, thanh máu cũ ban đầu tắt | PASS: giữ `Enabled=false` |
| Lưu trong `TestMemory` | PASS: Save game khóa, không báo đã lưu tài khoản |
| Hai source lưu/Cài đặt | Biên dịch Lune thành công |
| Boss trong săn tự do, chưa có `QuestState` | PASS trong lượt Play giả lập ngang tiếp theo; Boss hiện và QuestHUD ẩn |

Các fixture trên chỉ chứng minh cách hiển thị và khôi phục UI, không phải bằng chứng săn/hạ/bắt thật trong đợt này. Sau lượt `TestMemory` đã mở phiên Play mới với `ProfileStorageMode=DataStore`, trạng thái `Loaded` và `ProfileReady=true` để kiểm tra lưu thực.

### Lưu thực trong DataStore riêng của Studio

| Hạng mục | Quan sát thực |
| --- | --- |
| Tự lưu | Không bấm Save trước; `ProfileSavedAt` tự tăng từ `1792583937` lên `1792583968` sau khoảng 31 giây |
| Save game | Bấm nút thật trong Cài đặt khi `Active=true`; server đổi `ProfileSavedAt` từ `1792583968` lên `1792584005` và trả trạng thái `Saved` |
| Xác nhận và cooldown | Cài đặt hiện giờ lưu `19:00:05 UTC+7`; nút khóa với chữ `SAVE GAME · 4s`, đúng giới hạn 5 giây |
| Không còn HUD lưu | Kiểm tra `NoSaveHUD=true`; không tạo lại thanh lưu trên màn chơi |

Đây là ghi/xác nhận trên **DataStore riêng của Studio**, không phải kho live. **Chưa thử thoát và vào lại để kiểm chứng tải lại dữ liệu** trong đợt dọn HUD này.

### Bố cục giả lập điện thoại ngang

Đã chạy native Device Simulator với preset **iPhone 17 Pro**, ngang: viewport **750 × 381**, vùng GUI an toàn **750 × 323**. Fixture phía client đặt `InHunting=true`, `QuestState=nil`: Boss hiện, QuestHUD ẩn. Boss thường có kích thước thực **318,20 × 39,96**, vị trí **(253,4; 8)**; khi suy yếu/bẫy mở lên **318,20 × 56,24**. Combo phụ ẩn và bảng bay admin ở **(12; 56)**. Sau kiểm tra đã khôi phục các thuộc tính và dừng Play.

Đây là nghiệm thu bố cục giả lập và điều kiện hiển thị. Chưa nghiệm thu gameplay cảm ứng trên thiết bị thật hoặc hồi quy nhiều client.

## Bản native và đối chiếu cuối

[HunDino_HUDClean_20261021.rbxl](HunDino_HUDClean_20261021.rbxl) có **4.307.744 byte**, SHA-256 `DB5E9BB423F6CCA6557E54A15BE7B26897D8EE30251235B644C69CD0F4338B20`. File được sao chép nguyên byte từ bản xuất native Studio bằng **Download a Copy**, [HunDino_ExplorationLoot_20261021.rbxl](HunDino_ExplorationLoot_20261021.rbxl), do chat **“Demo map săn và chức năng map”** xuất từ cùng Studio. Vì vậy bản này cũng chứa phần exploration của đợt làm song song, không phải snapshot chỉ có bốn source HUD.

Inspector cuối có trạng thái **validation passed**, đạt **8.766 kiểm tra** và biên dịch **130 script**. Cả **11 source chuẩn** khớp chính xác, gồm bốn source HUD và đúng bảy source exploration đồng thời được liệt kê trong phạm vi đối chiếu. Đã kiểm bốn backup UI và sáu backup exploration; không chấp nhận thay đổi đồng thời ngoài danh sách này.

Đối chiếu **61.216 Instance đã có / 5.334.744 lượt đọc thuộc tính**, không phát hiện khác biệt ngoài phạm vi. Giữ **43.775 Part / 845 khớp**, riêng Workspace **35.064 Part / 723 khớp**. Dữ liệu Terrain nhị phân giữ nguyên; bản Place do Studio xuất native, không serialize Terrain lại bằng công cụ ngoài. Bằng chứng đầy đủ tại [báo cáo bản lưu](assets/ui/hud-cleanup/saved.json) và [báo cáo Play](assets/ui/hud-cleanup/play.json). Không sửa hoặc đồng bộ masterdoc trong đợt dọn HUD này.

Còn chờ phép thử riêng thoát/vào để kiểm chứng tải lại dữ liệu sau Save game, nghiệm thu cảm ứng trên thiết bị thật và nhiều client. Chưa Publish thay đổi lên game live.

Xem thêm [hồ sơ UI trước](UI_MODERNIZATION.md), [cơ chế lưu tài khoản](PERSISTENCE.md) và [mã thử admin](ADMIN_TEST_CODE.md). Các số đo và bản lưu ở tài liệu trước giữ đúng mốc lịch sử của chúng.
