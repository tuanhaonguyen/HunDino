# BÁO CÁO CHI TIẾT TIẾN ĐỘ DỰ ÁN HUNDINO

**Ngày báo cáo:** 27/10/2026, chốt rà soát lúc 09:48 UTC+7. Các hoạt động phát sinh sau thời điểm này chưa nằm trong báo cáo.
**Đối tượng:** Chủ dự án.  
**Cơ sở:** Kiểm tra workspace, tài liệu tính năng, mã nguồn, manifest và các báo cáo kiểm thử đã lưu; đối chiếu dung lượng và SHA256 của bản game hiện tại.  
**Giới hạn:** Đợt lập báo cáo này không chạy lại gameplay, không xác minh trạng thái Roblox trực tiếp và không thực hiện lại các bộ kiểm thử lịch sử. Các kết quả Play/cloud dưới đây là kết quả được hồ sơ dự án ghi nhận tại từng mốc.

## 1. Nhận định chung

HunDino đã hình thành vòng chơi săn khủng long có thể thử nghiệm: vào sảnh và nhận base, chọn trang bị Người/Pet, luyện vũ khí, mua vật tư, khám phá hoặc nhận nhiệm vụ săn, chiến đấu với T-Rex, thu hoạch hoặc bắt sống, trở về quản lý nguyên liệu/cá thể, chế bẫy và nâng vũ khí. Kho cá thể, ống trưng bày và lớp lưu tiến trình đã có triển khai, vượt qua giai đoạn chỉ dựng cảnh và thử combat riêng lẻ.

**Đánh giá dành cho chủ dự án:** Có nền tảng gameplay tích hợp và nhiều bằng chứng kiểm thử theo hệ thống; chưa đủ cơ sở gọi bản hiện tại là bản sẵn sàng phát hành công khai. Bản local mới nhất đã qua inspector sửa đường đi tại 12 base. Roblox v14 đã phát hành và sửa lỗi tương thích biên nhận HelloHunDino; sửa bố cục ống mới hơn chỉ có trên local. Báo cáo khai thác sắt thất bại ngày 26/10 là một tồn đọng lịch sử cần đối soát riêng, không phải kết quả inspector mới nhất. Nghiệm thu toàn vòng trên cloud, nhiều client, cảm ứng và hiệu năng vẫn là các khoảng trống chính.

Không gán phần trăm hoàn thành vì dự án chưa có danh mục công việc với trọng số và tiêu chí đóng thống nhất. Trong báo cáo này:

| Nhãn | Ý nghĩa |
| --- | --- |
| Đã triển khai | Có mã, tài sản hoặc tích hợp được hồ sơ ghi nhận; không mặc nhiên đã kiểm đủ mọi môi trường. |
| Đã kiểm chứng trong phạm vi | Có bằng chứng thử đạt trên một phiên bản và phạm vi cụ thể. |
| Đang triển khai | Có thay đổi nhưng nghiệm thu chưa hoàn tất hoặc còn kiểm tra thất bại. |
| Chưa triển khai | Chưa có bằng chứng triển khai trong các nguồn đã đối chiếu. |

Nguồn tổng hợp: [thiết kế game](THIET_KE_GAME.md), [README](README.md), cùng hồ sơ tính năng liên kết ở các phần sau. Các mục lịch sử được đọc theo thời điểm, không dùng để phủ định triển khai mới hơn.

## 2. Bản game, lưu tiến trình và quản lý phiên bản

### 2.1. Phân biệt bản local, bản cloud và các mốc kiểm tra

| Mốc | Dung lượng / hash / kiểm chứng | Trạng thái |
| --- | --- | --- |
| **Local mới nhất, sửa đường đi 12 base** | **4.495.025 byte**, SHA256 `8626bc714aa7a0da39493ba1bbcc676a142038b2f8a2c06e602fe01d522229bf`; `Ok: true`, **129.779 kiểm / 164 source biên dịch** | Đã lưu native; hash và dung lượng được đối chiếu lại trong đợt báo cáo. **Sửa ống chưa Publish**. |
| Cloud **v14**, sửa tương thích hồ sơ | Nguồn 4.481.440 byte; SHA256 `b935ea091751b0391baa5640350ac6b29d273ee7801ddf831fa4192409e2219f`; **85.318 kiểm / 163 source** | Đã Publish 04:46:28 ngày 27/10 theo hồ sơ phát hành; Player xác nhận tải/lưu DataStore. |
| Cloud **v12**, phát hành trước sửa hồ sơ | Nguồn 4.480.005 byte; SHA256 `73bb353d2869484800e7c75a888389d453284b5a7fa42b8f63f412d27943ae9e` | Đã nạp lại cloud để xác nhận 163 source, 30 model quặng; v14 thay thế sau khi sửa lỗi tải hồ sơ. |
| Kiểm tra khai thác sắt ngày 26/10 | Cùng hash nguồn v12; `Ok: false`, bộ đếm **386** | Báo cáo lịch sử phát hiện Instance ngoài phạm vi cho phép. Chưa có báo cáo thay thế chính bộ inspector này trong nguồn đối chiếu. |
| Chế bẫy Inventory trước khai thác | 4.373.461 byte; SHA256 `10ff67e69b8d8151c35160d7c5a4b918d85d54dbe7b804c835a5c848f55a535a`; **83.656 kiểm / 157 script** | Mốc đã kiểm riêng, không phải file local hiện tại. |

File chơi/chỉnh tiếp vẫn là [HunDino_MerchantWeapons_20261026.rbxl](HunDino_MerchantWeapons_20261026.rbxl), mở qua [CHOI_CUA_HANG.cmd](CHOI_CUA_HANG.cmd) hoặc [CHOI_VA_LUU.cmd](CHOI_VA_LUU.cmd). Tên file giữ ngày 26/10 nhưng nội dung đã cập nhật 27/10; cần dùng hash để nhận dạng.

Inspector mới nhất giữ **49.221 Instance ngoài cụm ống**, **60 ống / 12.000 Part**, toàn bộ byte **70 thuộc tính Terrain**, và ghi `PersistenceUnchanged: true`. Kết quả này có phạm vi đối chiếu với baseline sửa ống, không thay cho một lần kiểm toàn bộ lịch sử thêm quặng. Không có cơ sở kết luận lỗi inspector cũ đồng nghĩa map hỏng; cũng không tự đánh dấu lỗi cũ đã giải quyết chỉ vì inspector mới đạt.

Nguồn: [base-clearance/saved-inspection.json](assets/base-clearance/saved-inspection.json), [profile-compat/saved-inspection.json](assets/profile-compat/saved-inspection.json), [iron-mining-saved.json](assets/iron-mining/iron-mining-saved.json), [bản ghi phát hành](PHAT_HANH_20261027.md), [bản lưu chế bẫy](assets/inventory-crafting/saved-inspection.json).

### 2.2. Roblox, lỗi hồ sơ đã sửa và hai kho dữ liệu

Game đích theo hồ sơ phát hành: **HunDino SaveGame**, PlaceId `103801986821599`, GameId `10772272829`. Bản cloud mới nhất được bằng chứng ghi nhận là **v14**. Đợt báo cáo này đọc bằng chứng lưu sẵn, không đăng nhập hoặc kiểm tra Roblox trực tiếp; không suy từ việc Publish ra game đã mở Public.

V12 từng từ chối hồ sơ có biên nhận HelloHunDino chứa `Consumables`, báo `Economy:InvalidProfile`. V14 sửa đúng ba module native hiện hành, giữ namespace/kho lưu và biên nhận, không reset hoặc cấp lại thưởng. Bộ logic tương thích có **46**, HelloHunDino **350**, nâng vũ khí **238**, khai quặng **402** kiểm tra đạt. Tổng 1.036 là số kiểm của bốn bộ được hồ sơ ghi nhận, không phải 1.036 lượt chơi thực.

| Môi trường / mốc | Bằng chứng | Giới hạn |
| --- | --- | --- |
| Studio qua launcher local | Lưu cài đặt qua Stop/Play và khởi động lại bộ lưu; file tiến trình local theo hướng dẫn vận hành | Tách DataStore; không dùng để chứng nhận cloud. |
| Roblox Player ngày 22/10 | Độ nhạy 100% → 75%, thoát/vào lại giữ 75% | Phép thử cài đặt. |
| Roblox Player v14 lúc 05:05:26 ngày 27/10 | `ProfileReady=true`, `Saved`, `DataStore`, không lỗi; revision 286, **210 xu**, độ nhạy **0,75**, còn biên nhận HelloHunDino | Là quan sát tài khoản tại mốc thử, không phải số dư mặc định hoặc số dư hiện thời của mọi người chơi. |
| Phiên Player mới sau xác nhận Saved | Đóng Player, vào lại đúng Place; không còn bảng lỗi, thấy cung/giáp/Pet đã lưu | Chưa đọc lại số dư qua console trong phiên thứ hai; chưa nghiệm thu mọi giao dịch/cá thể/ống. |
| TestMemory/fixture | Các bộ thử logic, tích hợp, Play theo từng tính năng | Không phải dữ liệu cloud thật. |

Kho local và cloud không tự đồng bộ. Ctrl+S lưu map/mã; Save game lưu tiến trình vào kho của phiên hiện hành. StoreName `HunDinoProfiles_v1`, StudioStoreName `HunDinoProfiles_Studio_v1`, Scope `accounts` được hồ sơ phát hành ghi là giữ nguyên.

Nguồn: [verification.json](assets/profile-compat/verification.json), [publish-20261027.json](assets/release/publish-20261027.json), [LUU_GAME.md](LUU_GAME.md). Ảnh đại diện `AvatarHundino.png` đã được xác định nhưng **chưa cập nhật icon**, theo bản ghi phát hành; đây là việc riêng còn mở.

### 2.3. Git và quy trình bàn giao

Commit mới nhất quan sát: **`677f3da` — Set up protected developer workflow and sync current HunDino project**; nhánh hiện tại **`developer`**. Workspace sạch trước đợt cập nhật báo cáo này. Nhận định cũ “256 mục chưa commit, commit cuối 18/10” đã hết hiệu lực với trạng thái hiện tại.

Đã có `.github`, `.githooks`, `scripts` và [HUONG_DAN_GIT.md](../HUONG_DAN_GIT.md). Theo hướng dẫn đã lưu, luồng là kiểm tra → push `developer` → PR → chủ repo duyệt → merge `main`; Git không tự Publish Roblox. Đợt báo cáo không chạy Actions, không xác minh lại cấu hình bảo vệ trên GitHub và không commit/push. Các sửa tài liệu của đợt này sẽ xuất hiện là thay đổi chưa commit.

## 3. Tiến độ chi tiết từng hệ thống

### 3.1. Sảnh, base và di chuyển

**Trạng thái: Đã kiểm chứng trong phạm vi các mốc đã lưu.**

- Đã có 12 base, phân ngẫu nhiên số còn trống khi vào máy chủ; dịch chuyển giữa base và sảnh, chọn base để ghé thăm, Pet đi cùng.
- Ghé base khác không đổi quyền sở hữu; bàn chế/nâng sử dụng quyền chủ base. Base là phân bổ theo phiên, không coi là số base cố định vĩnh viễn của tài khoản.
- Bằng chứng/cách dùng: [BASE_TRANSIT.md](BASE_TRANSIT.md), [MAP_DARK_JUNGLE.md](MAP_DARK_JUNGLE.md), mục tổng hợp trong [thiết kế](THIET_KE_GAME.md).
- **Cập nhật hôm nay:** đã chỉnh bố cục ống để chừa lối vào base; Play chọn đủ 12 base, đi ra 22,33–22,78 studs và giữ G về sảnh đều đạt với TestMemory; 252 mẫu hộp thân người không giao ống va chạm. Sửa này local, chưa Publish. Bằng chứng: [studio-play](assets/base-clearance/studio-play.json), [survey](assets/base-clearance/survey.json).
- **Còn chờ:** thử nhiều client thật, đặc biệt tình huống 12 người, người rời/vào và tương tác đồng thời. Việc tiếp theo là xác nhận không trùng quyền base, không thao tác được bàn/ống của người khác và Pet chuyển khu đúng.

### 3.2. Map săn Thung Lũng Sương Xám

**Trạng thái: Đã kiểm chứng trong phạm vi H2.0 và inspector sửa ống mới nhất; vẫn cần đối soát riêng báo cáo khai thác sắt lịch sử.**

- Đã dựng khu săn **4.000 × 4.500 studs**, có rừng thông, đồng cỏ, hồ/đảo, đầm lầy, trạm kiểm lâm, trại gỗ, suối/thác và núi/hang.
- Hồ sơ ghi 2.400 cây, mạng đường và các node A/B/C, R1–R5, Camp; khủng long nghỉ 60 giây. Ánh sáng/ngày đêm khi săn có đồng hồ ×30.
- Bằng chứng: [GREY_MIST_VALLEY.md](GREY_MIST_VALLEY.md), [kiểm tra H2](assets/hunting/grey-mist-validation.json), [bản lưu H2](assets/hunting/grey-mist-saved.json).
- **Còn chờ:** hiệu năng máy yếu/điện thoại, mọi vật cản tự nhiên và bờ nước; chưa có bằng chứng đầy đủ cho nhiều loài, hệ theo dấu động hoặc lái thuyền. Trước mở rộng cảnh quan, cần xác minh đợt thêm quặng bảo toàn map/Terrain đúng phạm vi.

### 3.3. Bãi tập, vũ khí, combo và nâng cấp

**Trạng thái: Đã kiểm chứng trong phạm vi các đợt vũ khí/cửa hàng.**

- Đã có **7 vũ khí × 4 combo = 28 combo**, model/VFX Pro, trang bị Người/Pet độc lập và lướt Dark Step.
- Bảy loại của Người có cấp riêng: Búa, Kiếm & khiên, Katana, Thương cán dài, Song dao, Cung, Rìu đại. Nâng cấp 2 tốn **2 xương + 2 sắt**, tăng **15% sát thương đúng loại**; không tăng toàn bộ bằng cấp búa.
- Cung có tầm **40 → 120 studs** theo tụ lực; Tam Tiễn cấp 1 đạt **3 × 24 = 72**, cấp 2 đạt **84** nếu cả ba tia trúng. Đã sửa đường bắn lúc đi ngang, hướng WASD theo camera và Pet che ngắm.
- Bằng chứng: [COMBOS_V2_3.md](COMBOS_V2_3.md), [WEAPONS_PRO.md](WEAPONS_PRO.md), [MERCHANT_WEAPON_UPGRADES.md](MERCHANT_WEAPON_UPGRADES.md), [BOW_PET_FIXES.md](BOW_PET_FIXES.md). Bộ nâng cấp có **238 kiểm tra**; phép thử cung và di chuyển có Studio input/native fixture được phân biệt trong hồ sơ.
- **Còn chờ:** cân bằng trận săn hoàn chỉnh, hoạt ảnh toàn thân theo phạm vi thiết kế, điều khiển cảm ứng và hồi quy combat trên đúng bản game cuối cùng sau khai thác sắt.

### 3.4. T-Rex và chiến đấu

**Trạng thái: Đã kiểm chứng trong phạm vi một khủng long mẫu.**

- T-Rex mẫu có **1.200 HP**, tuần tra/nghỉ, vùng trúng thân/đầu/chân và phản công người gây sát thương.
- Hồ sơ nhịp cắn ghi sát thương 24, báo trước **0,95 giây**, chu kỳ **3,5 giây**. Lướt dùng tốc độ đầu 72 trong 0,5 giây, tốn 6 thể lực, quãng đo khoảng 16,5–16,8 studs.
- Bằng chứng: [DINOSAUR_COMBAT.md](DINOSAUR_COMBAT.md), [combat-validation.json](assets/hunting/combat-validation.json), [DARK_STEP.md](DARK_STEP.md).
- **Còn chờ:** nhiều quái/loài, săn đội và cân bằng. Có vùng trúng không đồng nghĩa đã có hệ phá bộ phận; phép thử hỗ trợ HP/vị trí không thay thế một trận săn cân bằng từ đầu đến cuối. Việc tiếp theo là chơi toàn vòng bằng trang bị/tài nguyên bình thường.

### 3.5. Pet đồng hành

**Trạng thái: Đã kiểm chứng trong phạm vi đợt sửa Pet ngày 26/10.**

- Pet hỗ trợ **12 sát thương/lần áp sát**, sau đó về chủ và chờ ít nhất **10 giây** từ đòn trước. Đây là luật mới hơn mốc 12 sát thương/4 giây trong tài liệu P1-C cũ.
- Pet không hạ quái qua ngưỡng bắt sống **10% HP**; server chặn/clamp đòn Pet tại ngưỡng. Khi ngắm cung, Pet theo sau bên trái và có xử lý ẩn cục bộ gần camera.
- Pet có 100 HP, rút khi HP ≤25%, sau 5 giây an toàn hồi 10 HP/giây. Về sảnh hoặc lượt mới hồi đầy; không cấp lại hồi chiêu chữa chủ. Chữa chủ bằng H hồi 70% HP tối đa, hồi chiêu 119 giây.
- Bằng chứng: [BOW_PET_FIXES.md](BOW_PET_FIXES.md), [báo cáo bản gộp](assets/qa/bow-pet-merchant-saved.json), [PET_COMPANION.md](PET_COMPANION.md). Có fixture native **112 kiểm combat**, **144 kiểm Pet** và phép tìm đường vòng tường riêng đạt 4,38 giây.
- **Còn chờ:** mọi địa hình rừng và nhiều Pet đồng thời. Cần thử kẹt đường, đổi mục tiêu, ngưỡng bắt sống và hồi máu trong trận thực; không suy rộng phép thử tường mẫu thành nghiệm thu toàn map.

### 3.6. Nhiệm vụ, bắt sống và thu hoạch khám phá

**Trạng thái: Đã kiểm chứng trong phạm vi P1-D và đợt exploration loot.**

- Nhiệm vụ J: lượt săn 40 phút, 3 lần hồi sinh; lần ngã thứ tư thất bại. B đặt bẫy; bắt khi quái còn sống, ≤10% HP và mắc bẫy; cất vũ khí rồi giữ G cho uống thuốc. Sau hoàn thành có 120 giây xem/thu hoạch hoặc về sớm.
- Vật tư thuộc sở hữu, mang tối đa 3 bẫy/3 thuốc theo luồng kinh tế; không dùng mô tả cấp miễn phí từ mốc thử ban đầu làm luật hiện hành.
- Khám phá không cần nhận nhiệm vụ để mổ: giữ G **1,5 giây**, tối đa **3 lần/người/xác** trong 120 giây. Có kiểm người tham gia và chống nhận lặp; khám phá không tự cấp thưởng nhiệm vụ/cá thể.
- Bằng chứng: [HUNT_QUEST.md](HUNT_QUEST.md), [SPECIMEN_COLLECTION.md](SPECIMEN_COLLECTION.md), [EXPLORATION_LOOT.md](EXPLORATION_LOOT.md), [exploration-loot-play.json](assets/hunting/exploration-loot-play.json).
- Đã có lần bắt thực và lần hạ/mổ thực được ghi nhận; một số QA dùng hỗ trợ vị trí/HP người hoặc sát thương thử, nên chưa chứng nhận cân bằng.
- **Còn chờ:** hồi quy toàn vòng bản mới, đủ 40 phút thực theo giới hạn hồ sơ, mọi bờ nước và săn đội. Luồng nhiệm vụ hiện theo mô hình một lượt solo/máy chủ với khủng long dùng chung.

### 3.7. Kinh tế, cửa hàng và Inventory/chế tạo

**Trạng thái: Đã kiểm chứng trong phạm vi cửa hàng và chế bẫy; nguồn sắt mới đang triển khai.**

- Đã có xu, da/răng/vảy/xương/sắt, bẫy và thuốc; mua vật tư, thưởng săn, mổ, chế bẫy và nâng vũ khí. Thương nhân và icon cửa hàng dùng cùng bảng giao diện.
- Inventory có năm tab **Người / Pet / Vật phẩm / Khủng long / Chế tạo**. Tab Chế tạo đã có công thức **1 bẫy thô + 1 sắt → 1 bẫy sắt**, không tốn xu.
- Có thể xem công thức từ xa; chế tại bàn base chủ, cất vũ khí và hồ sơ sẵn sàng. Server kiểm trạng thái/vị trí/nguyên liệu, token, snapshot và serial; lưu giao dịch trước xác nhận, chống yêu cầu lặp.
- Bằng chứng: [HUNT_ECONOMY.md](HUNT_ECONOMY.md), [MERCHANT_WEAPON_UPGRADES.md](MERCHANT_WEAPON_UPGRADES.md), [INVENTORY_CRAFTING.md](INVENTORY_CRAFTING.md), [studio-play chế bẫy](assets/inventory-crafting/studio-play.json).
- Thử UI/TestMemory: 2 bẫy thô/2 sắt/0 bẫy sắt → 1/1/1 → 0/0/2, xu giữ 80; khóa nút khi thiếu nguyên liệu hoặc đứng xa. Bộ handler chế bẫy có **22 kiểm tra**, hồi quy nâng vũ khí **238 kiểm tra** ở mốc đó.
- **Còn chờ:** không coi một công thức là hoàn thành toàn bộ chế tạo; chưa có bằng chứng đầy đủ cho hệ công thức mở rộng/nâng giáp. Cần kiểm nguồn quặng mới nối đúng kinh tế và lưu qua phiên trên bản cuối.

### 3.8. Khai thác sắt

**Trạng thái: Đã triển khai và có trong bản phát hành; kiểm logic đạt, Play toàn vòng và đối soát inspector lịch sử còn chờ.**

- Có **30 điểm quặng cố định**, cấu hình thao tác 2,2 giây, hồi quặng 300 giây, tầm 9 studs và tối đa 3 hit. Có builder, hình quặng/cuốc, service, client và manifest.
- Lần phát hành v12 đã mở lại từ cloud và xác nhận 30 model quặng. Bộ logic khai quặng **402 kiểm tra đạt** được ghi trong đợt tương thích hồ sơ v14; không đồng nghĩa đã Play đủ mọi điểm quặng.
- [Inspector ngày 26/10](assets/iron-mining/iron-mining-saved.json) vẫn là `Ok: false`, 386 kiểm trước khi dừng vì Instance ngoài phạm vi. Đó là báo cáo trên hash cũ; bản local hiện tại có inspector sửa ống mới hơn đạt. Hai báo cáo kiểm phạm vi khác nhau nên cần giữ cả hai, chưa tự đóng lỗi cũ.
- **Việc tiếp theo:** đối soát sai khác với baseline thêm quặng, ghi kết luận riêng; thử input khai thác, hủy thao tác, hồi quặng, chống nhận lặp và nguyên liệu qua phiên cloud. Hồ sơ chi tiết mới: [IRON_MINING.md](IRON_MINING.md).
- Nguồn: [cấu hình](src/hunting/IronMiningConfig.luau), [manifest](assets/iron-mining/iron-mining-install.json), [verification](assets/profile-compat/verification.json), [publish](assets/release/publish-20261027.json).

### 3.9. Kho cá thể và ống trưng bày

**Trạng thái: Đã triển khai; đã kiểm chứng trong phạm vi các đợt P1-F và P1-F.2.**

- Mỗi lần bắt có mã cá thể và thông tin riêng, kho tối đa **100 cá thể**, preview 3D. Khi kho đầy, chặn bắt thêm trước khi tiêu thuốc theo luật đã kiểm.
- Đã có **5 ống/base × 12 base = 60 ống**, đặt/chuyển/tháo cá thể; một cá thể chỉ ở một ống. Server kiểm chủ base, khoảng cách, vũ khí, phiên thao tác và sở hữu.
- `DisplaySlots` có schema lưu và xử lý hồ sơ cũ thiếu trường. Ống 1–4 xoay, ống 5 giữ hướng; chuyển động phía client có giới hạn khoảng cách cập nhật.
- Bằng chứng: [SPECIMEN_COLLECTION.md](SPECIMEN_COLLECTION.md), [BIO_TUBES.md](BIO_TUBES.md), [bio-tubes-release.json](assets/hunting/bio-tubes-release.json), [bản lưu ống](assets/hunting/bio-tubes-saved.json).
- QA ống ghi **258 kiểm server/TestMemory** và **535 kiểm client**; bản lưu v2.4 của đợt ống ghi `validation: passed`, **1.785.285 kiểm tra đối chiếu / 133 script biên dịch**, dung lượng **4.348.341 byte**. Đây chủ yếu là kiểm kỹ thuật/thuộc tính, không phải hàng triệu tình huống chơi độc lập. Đợt đó không chứng nhận riêng trường Terrain `VoxelGridAssetContentMap` mà parser chưa đọc được.
- **Cập nhật 27/10:** bố cục cụm ống và metadata dựng lại đã đồng bộ theo BioTubeGeometry.5 / TransitClearance.1; không đổi điểm dịch chuyển, giữ 60 ống và 12.000 Part. Inspector mới đạt 129.779 kiểm / 164 source; 252 mẫu tuyến đi không vướng ống. Sửa này chưa Publish.
- **Còn chờ:** nghiệm thu trưng bày/cá thể qua phiên cloud mới và nhiều client, hiệu năng nhiều ống đầy. Không dùng báo cáo v2.4 để chứng nhận toàn bộ bản MerchantWeapons mới. Chưa có bằng chứng hoàn chỉnh cho bán/thả/trao đổi/nuôi/biến thể ngẫu nhiên.

### 3.10. Lưu tiến trình và độ an toàn giao dịch

**Trạng thái: Đã triển khai; kiểm chứng logic/local, cloud v14 tải và lưu hồ sơ thật sau sửa tương thích.**

- Đã có lớp lưu trang bị Người/Pet, giáp, cài đặt, kinh tế, cấp vũ khí, cá thể, ô trưng bày và receipt theo các phần mở rộng hồ sơ.
- Có tự lưu, lưu khi thoát, khóa phiên, retry và khôi phục lượt săn đứt; giao dịch chỉ báo thành công sau xác nhận ghi. Lỗi tải không được biến thành hồ sơ trắng.
- Bằng chứng: [PERSISTENCE.md](PERSISTENCE.md), [LUU_GAME.md](LUU_GAME.md), [persistence-play.json](assets/data/persistence-play.json), [savegame-play.json](assets/data/savegame-play.json).
- Hồ sơ ghi bộ session store **160 kiểm tra / 11 nhóm**, thử lỗi ghi/retry và local qua khởi động lại. Cloud Player đã giữ cài đặt 75% qua thoát/vào lại ngày 22/10.
- **Cập nhật hôm nay:** v14 chấp nhận lại biên nhận HelloHunDino cũ, cloud báo Saved/DataStore với 210 xu và cài đặt 75%; vào lại không còn lỗi, có trang bị đã lưu. Không reset hay cấp lại thưởng. Phiên vào lại chưa đọc lại số dư bằng console.
- **Còn chờ:** nghiệm thu cloud toàn vòng mua/chế/nâng/bắt/đặt ống, mất kết nối và chuyển server. Đây là điều kiện quan trọng để xác nhận tài sản người chơi bền vững sau phát hành.

### 3.11. UI, HUD và công cụ admin

**Trạng thái: Đã kiểm chứng trong phạm vi desktop và các công cụ thử.**

- UI đã dùng hệ màu Dark Hunter, năm tab Inventory, HUD Boss/Pet/nhiệm vụ, vòng giữ phím, Cài đặt → Save game/Nhập code. Thanh lưu thường trực đã bỏ, tự lưu vẫn hoạt động.
- Có căn bố cục desktop, HD 720 và giả lập màn hình ngang nhỏ. Fixture hiển thị trạng thái bắt/mổ/Pet không được tính thành lần chơi thật của các cơ chế đó.
- Admin có bay xem map theo quyền, nhiều mức tốc độ; mã thưởng admin kiểm tra phía server, dùng một lần. Giao diện nhập mã sai đã được thử bằng bàn phím thật cả Studio và Roblox Player; hồ sơ không ghi đã dùng mã admin thật để QA.
- Bằng chứng: [UI_MODERNIZATION.md](UI_MODERNIZATION.md), [HUD_CLEANUP.md](HUD_CLEANUP.md), [ADMIN_FLY.md](ADMIN_FLY.md), [ADMIN_TEST_CODE.md](ADMIN_TEST_CODE.md), [LUU_GAME.md](LUU_GAME.md).
- **Còn chờ:** cảm ứng/thiết bị thật, portrait theo phạm vi hỗ trợ sẽ chọn, thao tác đồng thời nhiều client. Cảnh báo asset `203785492` sai loại được ghi là tồn tại từ nền; cần đánh giá ảnh hưởng thực trước khi đóng, không quy cho đợt sửa mới khi chưa có bằng chứng.

## 4. Các mốc phát triển chính

| Mốc | Thành quả được hồ sơ ghi nhận | Giới hạn cần giữ khi đọc |
| --- | --- | --- |
| 02–08/10 | Khởi tạo, các bản Dark Jungle và combo vũ khí | Là nền lịch sử, chưa đại diện gameplay mới nhất. |
| 14–15/10 | Pet đứng/trang bị, Pro/Katana/cung, lướt, base ngẫu nhiên và dịch chuyển | Các tham số cung/Pet tiếp tục được sửa ngày 26/10. |
| 16–17/10 | Nối sảnh–khu săn, T-Rex phản công, chỉnh nhịp cắn/lướt | Chưa có toàn bộ kinh tế/bắt sống tại thời điểm đó. |
| 19/10 | Map H2, Pet P1-C, nhiệm vụ/bắt P1-D, kinh tế P1-E, kho cá thể bước đầu | Các mục “chưa lưu/chưa ống” đúng ở mốc đó, đã có triển khai tiếp theo. |
| 20/10 | UI và lớp lưu tài khoản | Kiểm logic/Studio chưa thay nghiệm thu DataStore thật. |
| 21/10 | Ống trưng bày, exploration loot, HUD và công cụ nhập code admin | Có các bằng chứng riêng; chưa suy ra tất cả đã có trên Roblox live. |
| 22/10 | SaveGame riêng, cloud giữ cài đặt, khôi phục giao diện nhập code | Cloud mới chứng minh phần cài đặt và luồng nhập mã sai. |
| 26/10 — cửa hàng | Nâng riêng bảy vũ khí, hợp nhất bảng cửa hàng | Mốc native 4.368.355 byte, inspector 523 kiểm/146 script. |
| 26/10 — gộp combat | Cung/Pet/di chuyển gộp vào MerchantWeapons | Mốc 4.372.018 byte, 83.644 kiểm/155 script; chưa Publish. |
| 26/10 — chế bẫy | Công thức Inventory dùng bàn base | Mốc 4.373.461 byte, 83.656 kiểm/157 script; chưa Publish. |
| 26/10 — khai thác sắt | Có mã/node và file mốc 4.480.005 byte | Inspector đợt đó `Ok: false`; giữ tồn đọng lịch sử. |
| 27/10 — phát hành v12 | Bản gộp có 30 model quặng đã Publish và nạp lại cloud | Chưa nghiệm thu mọi gameplay; phát sinh lỗi biên nhận hồ sơ cũ. |
| 27/10 — sửa v14 | Sửa ba module, 1.036 kiểm logic và 85.318 kiểm native đạt; Publish 04:46:28 | Player 05:05:26 tải/lưu DataStore thành công; rejoin xác nhận trực quan, chưa đọc lại số dư lần hai. |
| 27/10 — chừa đường base | Local 4.495.025 byte, 129.779 kiểm/164 source; Play đủ 12 base, 252 mẫu tuyến đi đạt | Chưa Publish sửa ống, chưa thử nhiều client hoặc Player với bố cục mới. |
| 27/10 — Git/tài liệu | Commit 677f3da, nhánh developer, workspace sạch trước đợt báo cáo | Đợt này cập nhật tài liệu, không commit/push/merge/Publish. |

Nguồn: [thiết kế](THIET_KE_GAME.md), [hồ sơ cửa hàng](MERCHANT_WEAPON_UPGRADES.md), [gộp combat](BOW_PET_FIXES.md), [chế bẫy](INVENTORY_CRAFTING.md), [ống](BIO_TUBES.md), [khai thác sắt](assets/iron-mining/iron-mining-saved.json).

## 5. Chất lượng và những khoảng trống nghiệm thu

### 5.1. Cách hiểu bằng chứng

| Loại bằng chứng | Có thể kết luận | Không đủ để kết luận |
| --- | --- | --- |
| Test logic/handler với dữ liệu giả | Quy tắc, tính toán, chống lặp, xử lý lỗi trong tập thử | UI/va chạm/địa hình hoặc cloud thật hoạt động đầy đủ. |
| Fixture native/TestMemory | Tích hợp engine và hành vi trong kịch bản kiểm soát | Một trận săn cân bằng hoặc dữ liệu tài khoản thật bền vững. |
| Input thật trong Studio | Luồng thao tác đã hoạt động trên cấu hình thử | Toàn bộ thiết bị, mạng và multiplayer. |
| Inspector native save | Source/biên dịch/đối chiếu thuộc tính trong phạm vi và file cụ thể | Gameplay đúng toàn bộ hoặc mọi bản sửa sau đó được bảo toàn. |
| Roblox Player qua phiên mới | Hành vi cloud cụ thể được thử đã giữ qua phiên | Các trường dữ liệu và giao dịch chưa được thử cũng đều đạt. |

Không cộng số kiểm tra của các bộ thành một tổng “tình huống chơi đã đạt”; các bộ có thể lặp cùng dữ liệu và đếm từng thuộc tính. Không tuyên bố đã chạy lại các bộ trong đợt viết báo cáo này.

### 5.2. Tồn đọng ưu tiên

| Vấn đề | Trạng thái thực tế | Việc tiếp theo |
| --- | --- | --- |
| Lỗi hồ sơ HelloHunDino trên v12 | Đã sửa ở v14; có Player/DataStore/rejoin được ghi nhận | Hồi quy thêm mọi giao dịch/cá thể qua phiên mới, không coi lỗi tải còn mở. |
| Kẹt ống tại điểm đến base | Đã sửa local, Play 12 base và inspector đạt | Đưa đúng bản sửa lên cloud trong một đợt phát hành riêng rồi thử Player; đợt tài liệu không Publish. |
| Inspector khai thác sắt cũ | Chưa có kết luận thay thế chính phép kiểm cũ; không phải inspector mới nhất | Xác định chênh và ghi kết luận có baseline/hash rõ; không chỉ sửa nhãn báo cáo. |
| Cloud chưa hồi quy toàn vòng | Đã có bằng chứng hồ sơ thật rộng hơn phép thử cài đặt cũ | Thử xu, nguyên liệu, cấp, bắt, ống, mất kết nối và chống nhân đôi. |
| Nhiều client/thiết bị/hiệu năng | Chưa có nghiệm thu đủ phạm vi | Đo và thử trên cấu hình mục tiêu, nhiều người/Pet/ống; săn đội là phạm vi riêng. |
| Icon game | Chưa đổi theo hồ sơ phát hành | Cập nhật/kiểm duyệt icon trong đợt riêng; không ghi đã xong. |
| Tài liệu nhiều mốc | Đã đồng bộ đầu tài liệu và báo cáo trong đợt này | Giữ số liệu lịch sử, đọc snapshot hiện hành trước; tiếp tục cập nhật theo hash/phiên bản. |

## 6. Thứ tự công việc đề xuất và điều kiện hoàn thành

Không tự gán phần trăm hoặc thời hạn. Các hoạt động phát triển dưới đây chưa được thực hiện trong đợt cập nhật tài liệu.

| Thứ tự | Công việc | Điều kiện hoàn thành |
| --- | --- | --- |
| 1 | Chốt bàn giao bản local sửa base và đối soát lịch sử quặng | Nhận dạng hash 8626bc…229bf; inspector mới khớp; ghi kết luận chênh của inspector khai thác cũ với đúng baseline, không đánh đồng các bộ kiểm. |
| 2 | Hồi quy P1-G trên bản local cuối | Mua → chế → nâng → săn → hạ/mổ hoặc bắt → kho/ống → lưu/tải; thử hủy, thiếu đồ, kho đầy, thất bại và replay bằng hồ sơ thử; không trừ/phát lặp. |
| 3 | Phát hành sửa ống và nghiệm thu cloud | Dùng đúng bản đã qua hồi quy, ghi phiên bản Publish; Player không kẹt tại 12 base; kinh tế/cá thể/ô trưng bày giữ qua phiên mới và mất kết nối. |
| 4 | Nhiều client, thiết bị thật và hiệu năng | Không xung đột base/quyền/receipt; có số đo FPS, bộ nhớ, độ trễ và điều khiển thật trên thiết bị mục tiêu. |
| 5 | Hoàn tất icon và bàn giao | Icon được lưu/kiểm duyệt; tài liệu, manifest, hash, mốc Git và phiên bản cloud chỉ rõ phần còn khác nhau. |
| 6 | Mở rộng nội dung | Chọn đợt nhiều loài/săn đội/Pet/chế tạo sau khi nền hiện tại đạt tiêu chí; không coi kế hoạch là tính năng đã có. |

**Ưu tiên hiện tại:** bản local đã có kiểm bản lưu đạt; bước tiếp theo là đóng hồi quy toàn vòng và khoảng cách local–cloud, đồng thời đối soát minh bạch phép kiểm khai thác lịch sử. Không tiếp tục mô tả dự án như chưa từng Publish hoặc chỉ mới kiểm cài đặt cloud.

## 7. Công việc đã thực hiện trong đợt báo cáo hôm nay

- Đọc lại các tài liệu cấp gốc và tài liệu tính năng, các nhóm mã nguồn/công cụ/tài sản; kiểm kê cấu trúc tệp trong phụ lục bên dưới. Không tuyên bố đã đọc từng dòng của mọi tệp nhị phân, backup hoặc thư viện.
- Đối chiếu SHA256/dung lượng bản game với inspector sửa base mới nhất; đọc bằng chứng phát hành v12/v14, sửa hồ sơ và Play 12 base.
- Cập nhật báo cáo hiện tại, các tài liệu tiến độ/tính năng cấp gốc và hai bản thiết kế tổng; thêm hồ sơ khai thác sắt để tách trạng thái triển khai, kiểm logic và tồn đọng inspector.
- Giữ nguyên mã, bản game, dữ liệu người chơi và báo cáo JSON lịch sử. Không chạy gameplay/test lịch sử, không truy cập tài khoản/cloud, không commit/push/merge hoặc Publish trong đợt này.

## 8. Kiểm kê toàn bộ nhóm tệp và tài liệu

Phụ lục là kiểm kê tại máy, phục vụ tìm đúng nguồn và phạm vi tiến độ. Số tệp không đo chất lượng hoặc mức hoàn thành. Thư viện/runtime, `.git`, cache, báo cáo CI tạm và kho tiến trình cá nhân không được tính vào sản phẩm; backup được thống kê riêng và giữ nguyên.

| Nhóm tệp | Số tệp tại thời điểm rà soát | Vai trò / cách đọc tiến độ |
| --- | --- | --- |
| Assets / manifest / bằng chứng / source xuất | 166 | Đọc hash, phiên bản và phạm vi; JSON kiểm thử cũ không bị sửa để làm đẹp kết quả. |
| Backup lịch sử (giữ nguyên) | 139 | Đối chiếu/khôi phục theo mốc; không cập nhật nội dung backup. |
| Biến thể tích hợp Studio | 6 | Nguồn vũ khí/Training có vai trò trong tích hợp; không mặc nhiên thay bằng biến thể cùng tên trong src. |
| Bản Place / model Roblox | 24 | Các bản game/model; bản chính nhận dạng bằng hash, bản cũ không phải bản phát hành mới nhất. |
| Công cụ dựng / kiểm thử / inspector | 137 | Có file test không tự chứng minh test đã chạy đạt; chỉ ghi kết quả có báo cáo. |
| Cấu hình / launcher / ảnh / thiết kế và tệp khác | 19 | Gồm project/config, launcher, ảnh và Blender; tài sản local không đồng nghĩa đã triển khai/publish. |
| Mã nguồn src | 88 | Các hệ gameplay, dữ liệu, UI/admin; có biến thể theo bản nhúng, không ghi đè Place từ default.project.json khi chưa đối chiếu. |
| Quy trình Git / kiểm tra / CI | 15 | scripts, workflow và hook đã có; đợt báo cáo không chạy pipeline hoặc đổi quy trình. |
| Tài liệu Markdown | 43 | Đã đồng bộ trạng thái ở tài liệu cấp gốc; tài liệu backup giữ lịch sử. |

Tổng kiểm kê: **637 tệp** trong phạm vi trên, gồm backup; không đọc dữ liệu tiến trình cá nhân. Không tính file khóa Studio. Các số là snapshot khi cập nhật báo cáo, không cam kết mọi tệp đã được kiểm nội dung.

### 8.1. Phân công nguồn theo hệ thống

| Nhóm nguồn | Chức năng / trạng thái |
| --- | --- |
| `src/admin` | 3 tệp; Bay admin, kiểm quyền; đã triển khai. |
| `src/client` | 2 tệp; Entrypoint/client Training nền; đối chiếu biến thể nhúng trước dùng. |
| `src/server` | 3 tệp; Entrypoint/server nền; không mặc định là server đang nhúng bản chính. |
| `src/shared` | 3 tệp; Luật/cấu hình chung nền. |
| `src/dark-jungle` | 21 tệp; Vũ khí, Inventory, UI, trang bị và di chuyển; đã triển khai theo mốc tính năng. |
| `src/dinosaur` | 6 tệp; Rig/chuyển động/hàm khủng long mẫu; nền cho T-Rex tích hợp. |
| `src/hunting` | 42 tệp; Map, combat, nhiệm vụ, kinh tế, Pet, bắt/mổ, quặng và ống; nghiệm thu theo hệ thống ở mục 3. |
| `src/data` | 6 tệp; Hồ sơ, store/schema/local, cloud đã có kiểm thực v14 nhưng chưa toàn vòng. |
| `src/savegame` | 2 tệp; Biến thể Training cho bản SaveGame/MerchantWeapons; giữ tích hợp cung/Pet và cấp riêng. |
| `studio-pet-integration` | 6 tệp; Biến thể Weapons/TrainingRules/Training dùng trong bản tích hợp; không thay nguyên bộ bằng nhánh cũ. |

### 8.2. Chỉ mục toàn bộ tài liệu tiến độ cấp gốc

Mỗi tài liệu bên dưới đã có khối trạng thái hiện hành; phần bên dưới khối giữ nội dung tính năng và số liệu lịch sử. Hai bản thiết kế tổng giống hệt byte. Các Markdown trong backup không được đồng bộ.

| Tài liệu | Nội dung / vai trò |
| --- | --- |
| [ADMIN_FLY.md](<ADMIN_FLY.md>) | Bay xem map dành cho admin |
| [ADMIN_TEST_CODE.md](<ADMIN_TEST_CODE.md>) | Nhập code thử cho admin — 21/10/2026 |
| [BAO_CAO_TIEN_DO_2026-10-27.md](<BAO_CAO_TIEN_DO_2026-10-27.md>) | BÁO CÁO CHI TIẾT TIẾN ĐỘ DỰ ÁN HUNDINO |
| [BASE_TRANSIT.md](<BASE_TRANSIT.md>) | Điểm dịch chuyển base ↔ sảnh trung tâm — 15/10/2026 |
| [BIO_TUBES.md](<BIO_TUBES.md>) | Ống nghiệm sinh học — P1-F.2 |
| [BOW_CHARGE_RESTORE.md](<BOW_CHARGE_RESTORE.md>) | Khôi phục tụ lực cung — 15/10/2026 |
| [BOW_PET_FIXES.md](<BOW_PET_FIXES.md>) | Cung, Pet và hướng di chuyển — 26/10/2026 |
| [COMBOS_V2_3.md](<COMBOS_V2_3.md>) | Combo, thể lực và giao diện v2.3 |
| [DARK_STEP.md](<DARK_STEP.md>) | Lướt Dark Step — 15/10/2026 |
| [DINOSAUR_01.md](<DINOSAUR_01.md>) | Khủng long đầu tiên — mẫu ngoại hình 15/10/2026 |
| [DINOSAUR_COMBAT.md](<DINOSAUR_COMBAT.md>) | Khủng long nghỉ 60 giây và phản công H1.3 — 17/10/2026 |
| [DON_DEP_DU_AN.md](<DON_DEP_DU_AN.md>) | File đang dùng và kế hoạch dọn HunDino |
| [EXPLORATION_LOOT.md](<EXPLORATION_LOOT.md>) | Mổ lấy nguyên liệu khi Khám phá — 21/10/2026 |
| [GREY_MIST_VALLEY.md](<GREY_MIST_VALLEY.md>) | Thung Lũng Sương Xám — H2.0 |
| [HELLOHUNDINO_CODE.md](<HELLOHUNDINO_CODE.md>) | Mã HelloHunDino — 22/10/2026 |
| [HUD_CLEANUP.md](<HUD_CLEANUP.md>) | Dọn HUD và chuyển lưu thủ công vào Cài đặt — 21/10/2026 |
| [HUNT_ECONOMY.md](<HUNT_ECONOMY.md>) | Nguyên liệu, thưởng và chế tạo — P1-E |
| [HUNT_QUEST.md](<HUNT_QUEST.md>) | Nhiệm vụ săn và bắt sống — nền P1-D, vật tư P1-E |
| [HUNTING_LINK.md](<HUNTING_LINK.md>) | Sảnh ↔ Rừng cổ H1.2 — 16/10/2026 |
| [HUNTING_MAP.md](<HUNTING_MAP.md>) | Khu săn Rừng cổ — bản nối sảnh H1.2 |
| [INVENTORY.md](<INVENTORY.md>) | Túi đồ Người và Pet — 15/10/2026 |
| [INVENTORY_CRAFTING.md](<INVENTORY_CRAFTING.md>) | Chế bẫy sắt trong Inventory — 26/10/2026 |
| [INVENTORY_ITEMS.md](<INVENTORY_ITEMS.md>) | Inventory — Vật phẩm và mục Chế tạo |
| [IRON_MINING.md](<IRON_MINING.md>) | Khai thác sắt — trạng thái 27/10/2026 |
| [KATANA_PRO.md](<KATANA_PRO.md>) | Nâng cấp katana theo mẫu — 15/10/2026 |
| [LUU_GAME.md](<LUU_GAME.md>) | HunDino SaveGame |
| [MAP_DARK_JUNGLE.md](<MAP_DARK_JUNGLE.md>) | HunDino — Dark Jungle DJ.2.3 |
| [MERCHANT_WEAPON_UPGRADES.md](<MERCHANT_WEAPON_UPGRADES.md>) | Sửa cửa hàng và cấp riêng từng vũ khí — 26/10/2026 |
| [PERSISTENCE.md](<PERSISTENCE.md>) | Lưu tiến trình tài khoản HunDino — 20/10/2026 |
| [PET_COMPANION.md](<PET_COMPANION.md>) | Pet đồng hành — P1-C |
| [PET_STANDING.md](<PET_STANDING.md>) | Pet đứng — cập nhật 14/10/2026 |
| [PHAT_HANH_20261027.md](<PHAT_HANH_20261027.md>) | Phát hành HunDino — 27/10/2026 |
| [README.md](<README.md>) | HunDino — Dark Jungle và bãi tập |
| [SPECIMEN_COLLECTION.md](<SPECIMEN_COLLECTION.md>) | Kho cá thể bắt sống — bước đầu P1-F |
| [TEST_DARK_JUNGLE_V2_1.md](<TEST_DARK_JUNGLE_V2_1.md>) | Kiểm tra HunDino Dark Jungle v2.1 |
| [THIET_KE_GAME.md](<THIET_KE_GAME.md>) | Hồ sơ thiết kế game Roblox săn khủng long |
| [TRAINING_SANCTUARY.md](<TRAINING_SANCTUARY.md>) | HunDino — Bãi luyện tập v2.3 |
| [UI_MODERNIZATION.md](<UI_MODERNIZATION.md>) | Modern Dark Hunter UI — 20/10/2026 |
| [WEAPONS_PRO.md](<WEAPONS_PRO.md>) | Bộ bảy vũ khí Pro — 15/10/2026 |
| [HUONG_DAN_GIT.md](<../HUONG_DAN_GIT.md>) | Hướng dẫn Git cho HunDino |
| [THIET_KE_GAME.md](<../THIET_KE_GAME.md>) | Hồ sơ thiết kế game Roblox săn khủng long |
| [thiết kế map săn.md](<../thiết kế map săn.md>) | PROMPT: THIẾT KẾ MAP ĐI SĂN “THUNG LŨNG SƯƠNG XÁM” |

### 8.3. Phân biệt tệp thiết kế và sản phẩm

Các file `.blend` và ảnh ở gốc là tài sản nguồn thiết kế; không có phép kiểm nào trong đợt này chứng nhận đã đưa toàn bộ chúng vào Place. AvatarHundino.png có bằng chứng được chọn làm nguồn icon nhưng hồ sơ phát hành ghi chưa đổi icon. Backup, model rời, JSON fixture, bản `.rbxl` lịch sử và source xuất từ Studio không tự trở thành tính năng mới của bản cloud.
