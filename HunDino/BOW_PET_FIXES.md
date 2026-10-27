# Cung, Pet và hướng di chuyển — 26/10/2026

<!-- TIEN_DO_20261027_BEGIN -->
> **Trạng thái đối chiếu 27/10/2026, 09:48 UTC+7:** local chính `HunDino_MerchantWeapons_20261026.rbxl` **4.495.025 byte**, SHA256 `8626bc714aa7a0da39493ba1bbcc676a142038b2f8a2c06e602fe01d522229bf`; inspector **129.779 kiểm / 164 source**, đạt. Cloud có bằng chứng mới nhất **v14**, nguồn **4.481.440 byte**; sửa bố cục ống mới chỉ local, **chưa Publish**.
>
> Luật hiện hành: Pet một đòn 12 sát thương rồi về chủ chờ ít nhất 10 giây; cung 40–120 studs, E cấp 1 là 72 khi trúng đủ. Bản gộp đã nằm trong đợt phát hành 27/10; sửa ống local mới hơn chưa Publish.
>
> [Báo cáo tiến độ toàn dự án và hôm nay](BAO_CAO_TIEN_DO_2026-10-27.md). Ghi chú này cập nhật trạng thái; số liệu/hash của từng mốc cũ bên dưới giữ nguyên theo phạm vi lúc kiểm.
<!-- TIEN_DO_20261027_END -->

Bản chính theo lựa chọn người dùng là **HunDino_MerchantWeapons_20261026.rbxl**. Mở **CHOI_CUA_HANG.cmd** hoặc **CHOI_VA_LUU.cmd** rồi Play. Đã ghép các sửa chiến đấu với cửa hàng, nâng riêng bảy vũ khí và lưu tiến trình. Bản gộp chưa Publish; ứng dụng Roblox đang chạy sẽ chưa có cập nhật này. SaveGame giữ thêm bản sửa riêng làm mốc đối chiếu.

## Luật hiện hành

| Phần | Hành vi |
| --- | --- |
| Ngắm cung | Pet theo sau bên trái tại khoảng cách ngang 7, dọc 7 studs. Ray ngắm/bắn bỏ qua Pet. Pet ở gần camera được ẩn cục bộ khi ngắm/tụ, khôi phục khi ngừng ngắm. |
| Đi ngang khi bắn | Client gửi điểm đang ngắm; server tính lại hướng từ vị trí bắn hiện tại khi từng mũi rời cung. Server raycast, vật cản, tầm và sát thương vẫn quyết định kết quả. |
| Tam Tiễn E | Ba mũi hội tụ cùng điểm ngắm, cách nhau 0,12 giây; mỗi mũi có token riêng, gây 24 sát thương ở cấp 1. Cả ba trúng một mục tiêu: 72. Vật cản/trượt/vượt tầm vẫn có thể làm mũi tên không trúng. |
| Tầm cung | Không tụ: 40 studs. Tụ theo thời gian server: `40 + 80 × mức_tụ`; đầy lực 1,2 giây: 120 studs. Các đòn không tụ dùng 40, kể cả Q/E và combo không tụ. |
| Nâng cung | Giữ tăng 15% sát thương của đúng vũ khí. Cung cấp 2: mỗi tia E làm tròn thành 28, ba tia thành 84; cường hóa sau lướt vẫn tăng phát đầu theo luật cũ. |
| Hướng di chuyển | Giữ WASD theo camera Roblox. Khi ngắm, thân quay theo camera; ngừng ngắm khôi phục AutoRotate, không khôi phục giá trị false tạm của đòn cũ. Cung không ép root quay về hướng chụp từ trước lúc bắn. |
| Pet đánh khủng long | Một lần gây 12 sát thương trong mỗi lượt áp sát, kể cả vũ khí có nhiều mốc hoạt ảnh. Sau đòn quay về cạnh chủ; chờ ít nhất 10 giây từ đòn trước rồi mới tiếp cận lần nữa. Thời gian đi đường có thể làm khoảng giữa hai đòn dài hơn. |
| Bảo vệ bắt | Pet không bắt đầu hoặc hoàn tất đòn vào quái còn ≤10%. Lớp sát thương server đồng thời chặn/clamp đòn Pet tại đúng ngưỡng 10%; ở T-Rex 1.200 HP là 120 HP. Người chơi vẫn có thể tự hạ quái. Khi chủ cho uống thuốc, Pet tiếp tục dừng đánh. |
| Pet tự hồi | HP ≤25% thì rút khỏi vùng quái, chọn điểm xa hơn 40 studs nhưng trong 80 studs quanh chủ. Sau 5 giây không bị đánh, tại chỗ an toàn hồi 10 HP/giây, tối đa 100. Quái áp sát/vật cản có thể trì hoãn việc tới nơi an toàn. |
| Về sảnh/lượt mới | Pet đầy 100 HP, hết choáng. Hồi chiêu chữa cho chủ giữ nguyên. Đưa lại về trại trong cùng lượt săn đang tiếp tục không tự tạo một lượt mới để làm mới HP. |

HP xuống 1 vẫn choáng 30 giây rồi đầy máu theo luật cũ. Kỹ năng chữa chủ vẫn hồi 70% HP tối đa và hồi chiêu 119 giây; tự hồi/choáng/chuyển khu không cấp lại lượt chữa này. Chưa đổi cân bằng sát thương các vũ khí khác.

## Bản lưu và source

- Nguồn cũ trước sửa: `backups/bow-pet-20261026/` gồm SaveGame, MerchantWeapons và bản AutoRecovery ngày 22/10 đã kiểm tra.
- Trong mỗi Place sửa có `ServerStorage.BowPetBackup_20261026`, lưu tám script cũ; thêm một ModuleScript hình học `ReplicatedStorage.Shared.BowBallistics`.
- Server bản chính: `src/savegame/TrainingMerchant.server.luau`; client: `src/savegame/Training.client.luau`. Bộ luật đang cài lấy từ `studio-pet-integration/Weapons.luau` và `TrainingRules.luau`; controller Pet/combat ở `src/hunting`.
- Manifest bản chính: `assets/qa/bow-pet-merchant-install.json`; manifest mốc SaveGame: `assets/qa/bow-pet-install.json`. Không dùng default.project.json để ghi đè bản này.
- Không đổi namespace lưu hoặc dữ liệu tài khoản. Mọi thử Play dùng TestMemory được bật rõ và gỡ trước lưu; không chỉnh kho local/cloud của người dùng.

## Kiểm chứng

Đã thử trên nhân vật Play ở nền SaveGame: E ba mũi làm hình nộm 1.000 → 928 HP; nhấn nhanh/nửa lực/đầy lực cho tia dài 40,01 / 81,19 / 120 studs. Giữ D khi bắn tại tốc độ 8 studs/giây vẫn trúng mặt TargetRing đang ngắm. Phép thử dùng camera QA giữ tâm vào mục tiêu để tách sai lệch do đường bắn khỏi thao tác rê chuột; game không thêm tự khóa mục tiêu.

Giữ W liên tục và xoay camera qua ba hướng: 32 mẫu tự do có dot hướng di chuyển với camera = 1, dot thân với hướng đi tối thiểu 0,961; 32 mẫu ngắm/tụ đều bằng 1. Pet gần camera có 119/119 Part được ẩn rồi khôi phục đủ. Chưa nhận video; lỗi được tái tạo bằng input thật trong Studio.

Play HP Pet: 80 HP giữ nguyên ở 4,5 giây, đạt 94,64 sau 6,5 giây; 1 HP/đang choáng → về sảnh 100 → vào lượt mới 100. Mốc hồi chữa chủ giữ nguyên qua hai lần chuyển.

Trên bản MerchantWeapons đã gộp, E cấp 1 đạt 72; cấp 2 có hệ số 1,15 và đạt 84. Kiểm fixture native trên chính bản gộp đạt **112 kiểm combat** và **144 kiểm Pet**, dùng rig/animator, ray/blockcast thật với mục tiêu cố định thích nghi: đòn Pet lúc 1000,25 và 1011,75; Pet chờ tại chủ qua 135 mẫu, rút cách mục tiêu 47,50 studs rồi hồi đủ 100. Đây không phải thử mọi vách/đá trong rừng. Tìm đường vòng tường native riêng đạt 4,38 giây, không xuyên tường.

Hồi quy thêm: 56 kiểm hình học/tầm cung, 159 kiểm luật Pet, 29 kiểm controller với doubles, 83 kiểm controller engine, sáu nhóm luật combat/vũ khí và hồi quy tụ lực đều đạt. Các số là các bộ riêng, không cộng thành số tình huống chơi độc lập.

Bằng chứng: `assets/qa/bow-pet-play.json`, `bow-pet-saved.json` và `bow-pet-merchant-saved.json`. Inspector chỉ đọc, đối chiếu source, biên dịch, fingerprint Part/Joint và hash toàn bộ thuộc tính Terrain nhị phân, gồm kiểu VoxelGridAssetContentMap mà Lune chưa giải mã. Place chỉ lưu bằng Studio.

Mốc ghép chiến đấu trước khi thêm công thức Inventory: **4.372.018 byte**, SHA256 `6265cf48569a69fe28b7700704685d132fd3be4b569195378e5bc90d9325729e`. Inspector đạt **83.644 kiểm tra / 155 script biên dịch**, chín source cài và tám backup gốc khớp; source không liên quan giữ nguyên. Workspace giữ **47.064 Part / 723 khớp nối**; 70 thuộc tính Terrain nhị phân, gồm nội dung voxel, giữ nguyên byte. Không còn cờ hoặc probe QA. Bản chính hiện đã thêm công thức bẫy sắt; xem số liệu mới tại [INVENTORY_CRAFTING.md](INVENTORY_CRAFTING.md). Chín source chiến đấu vẫn khớp sau lần thêm công thức.

Chưa nghiệm thu điện thoại, multiplayer, mọi địa hình hoặc bản Roblox live cho đợt sửa này. Cảnh báo asset 203785492 sai loại có sẵn trong bản nền; một lượt khởi động Studio có lỗi timeout CoreGui, lượt thử sau khởi động lại chạy được input và gameplay.
