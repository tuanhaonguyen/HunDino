# BÁO CÁO CHI TIẾT TIẾN ĐỘ DỰ ÁN HUNDINO

**Ngày báo cáo:** 27/10/2026, múi giờ UTC+7.  
**Đối tượng:** Chủ dự án.  
**Cơ sở:** Kiểm tra workspace, tài liệu tính năng, mã nguồn, manifest và các báo cáo kiểm thử đã lưu; đối chiếu dung lượng và SHA256 của bản game hiện tại.  
**Giới hạn:** Đợt lập báo cáo này không chạy lại gameplay, không xác minh trạng thái Roblox trực tiếp và không thực hiện lại các bộ kiểm thử lịch sử. Các kết quả Play/cloud dưới đây là kết quả được hồ sơ dự án ghi nhận tại từng mốc.

## 1. Nhận định chung

HunDino đã hình thành vòng chơi săn khủng long có thể thử nghiệm: vào sảnh và nhận base, chọn trang bị Người/Pet, luyện vũ khí, mua vật tư, khám phá hoặc nhận nhiệm vụ săn, chiến đấu với T-Rex, thu hoạch hoặc bắt sống, trở về quản lý nguyên liệu/cá thể, chế bẫy và nâng vũ khí. Kho cá thể, ống trưng bày và lớp lưu tiến trình đã có triển khai, vượt qua giai đoạn chỉ dựng cảnh và thử combat riêng lẻ.

**Đánh giá dành cho chủ dự án:** Có nền tảng gameplay tích hợp và nhiều bằng chứng kiểm thử theo hệ thống; chưa đủ cơ sở gọi bản hiện tại là bản sẵn sàng phát hành công khai. Bản game mới nhất đã thay đổi tiếp sau mốc chế bẫy được nghiệm thu, và kiểm tra bản lưu của đợt khai thác sắt chưa đạt. Nghiệm thu toàn vòng trên cloud, nhiều client, cảm ứng và hiệu năng vẫn là các khoảng trống chính.

Không gán phần trăm hoàn thành vì dự án chưa có danh mục công việc với trọng số và tiêu chí đóng thống nhất. Trong báo cáo này:

| Nhãn | Ý nghĩa |
| --- | --- |
| Đã triển khai | Có mã, tài sản hoặc tích hợp được hồ sơ ghi nhận; không mặc nhiên đã kiểm đủ mọi môi trường. |
| Đã kiểm chứng trong phạm vi | Có bằng chứng thử đạt trên một phiên bản và phạm vi cụ thể. |
| Đang triển khai | Có thay đổi nhưng nghiệm thu chưa hoàn tất hoặc còn kiểm tra thất bại. |
| Chưa triển khai | Chưa có bằng chứng triển khai trong các nguồn đã đối chiếu. |

Nguồn tổng hợp: [thiết kế game](THIET_KE_GAME.md), [README](README.md), cùng hồ sơ tính năng liên kết ở các phần sau. Các mục lịch sử được đọc theo thời điểm, không dùng để phủ định triển khai mới hơn.

## 2. Bản game, lưu tiến trình và quản lý phiên bản

### 2.1. Bản trên máy hiện tại

| Thuộc tính | Kết quả đối chiếu |
| --- | --- |
| Bản chính | [HunDino_MerchantWeapons_20261026.rbxl](HunDino_MerchantWeapons_20261026.rbxl) |
| Dung lượng hiện tại | **4.480.005 byte** |
| SHA256 hiện tại | `73bb353d2869484800e7c75a888389d453284b5a7fa42b8f63f412d27943ae9e` |
| Bằng chứng khớp bản hiện tại | [iron-mining-saved.json](assets/iron-mining/iron-mining-saved.json) khớp dung lượng và SHA256 |
| Kết quả kiểm tra mới nhất | **`Ok: false`, `Checks: 386`**; dừng vì `Unexpected instances outside the permitted mining additions` |
| Cách mở theo hướng dẫn | [CHOI_CUA_HANG.cmd](CHOI_CUA_HANG.cmd) hoặc [CHOI_VA_LUU.cmd](CHOI_VA_LUU.cmd), sau đó Play trong Studio |

Lỗi trên cho biết inspector phát hiện Instance ngoài phạm vi bổ sung được cho phép. **Chưa xác định nguyên nhân và chưa có cơ sở kết luận map hỏng.** Số 386 là bộ đếm tại thời điểm báo cáo thất bại, không phải chứng nhận cả đợt đã đạt.

Mốc chế bẫy Inventory trước khai thác sắt có dung lượng **4.373.461 byte**, SHA256 `10ff67e69b8d8151c35160d7c5a4b918d85d54dbe7b804c835a5c848f55a535a`, đạt **83.656 kiểm tra / 157 script biên dịch**. Đây là mốc lịch sử được chứng minh riêng; không áp dụng kết quả nguyên trạng cho file 4.480.005 byte hiện tại. Nguồn: [hồ sơ chế bẫy](INVENTORY_CRAFTING.md), [kiểm tra bản lưu](assets/inventory-crafting/saved-inspection.json).

### 2.2. Bản Roblox và hai kho dữ liệu

Theo [LUU_GAME.md](LUU_GAME.md), bản Roblox riêng là **HunDino SaveGame**, PlaceId `103801986821599`, GameId `10772272829`. Hồ sơ ngày 22/10 ghi bản riêng dành cho PC, chưa mở Public; đợt báo cáo không kiểm tra lại trạng thái truy cập hiện nay. Các sửa gộp cửa hàng/cung/Pet và chế bẫy ngày 26/10 được ghi là **chưa Publish**; chưa có bằng chứng xuất bản đợt khai thác sắt.

| Môi trường | Kho lưu | Phạm vi đã có bằng chứng |
| --- | --- | --- |
| Studio qua launcher local | File tiến trình trên máy, hướng dẫn tại `local-save/profiles.json` | Lưu cài đặt qua Stop/Play và khởi động lại bộ lưu. |
| Roblox Player | DataStore của game Roblox | Độ nhạy 100% → 75%, thoát/vào lại vẫn 75% ngày 22/10. |
| Studio/TestMemory và backend thử | Kho thử riêng | Kiểm logic giao dịch, hồ sơ, lỗi ghi và các tính năng theo từng bộ thử. |

Hai kho local/cloud **không tự đồng bộ**. Ctrl+S lưu map/mã game; tiến trình người chơi do lớp lưu của phiên xử lý. Phép thử cài đặt cloud chưa chứng minh toàn bộ xu, nguyên liệu, cấp vũ khí, cá thể, ô trưng bày và thưởng săn đều bền vững trên cloud.

### 2.3. Khoảng cách giữa Git và workspace

Commit mới nhất quan sát được là **`7e07ca6` — “Cập nhật code”, 18/10/2026**. Tại thời điểm kiểm tra trước tạo báo cáo, `git status --porcelain` có **256 dòng thay đổi**, gồm tệp sửa và mục chưa được theo dõi. Con số này là số mục Git hiển thị, không phải số tính năng hoặc số tệp vật lý chính xác vì một thư mục chưa theo dõi có thể chứa nhiều tệp.

Nhiều tiến bộ sau 18/10 nằm trong workspace và các bản sao lưu, chưa được phản ánh đầy đủ bằng commit. Vì vậy không dùng lịch sử commit riêng lẻ để đánh giá tiến độ; đồng thời cần chốt một mốc Git có thể tái hiện sau khi xử lý kiểm tra bản lưu chưa đạt.

## 3. Tiến độ chi tiết từng hệ thống

### 3.1. Sảnh, base và di chuyển

**Trạng thái: Đã kiểm chứng trong phạm vi các mốc đã lưu.**

- Đã có 12 base, phân ngẫu nhiên số còn trống khi vào máy chủ; dịch chuyển giữa base và sảnh, chọn base để ghé thăm, Pet đi cùng.
- Ghé base khác không đổi quyền sở hữu; bàn chế/nâng sử dụng quyền chủ base. Base là phân bổ theo phiên, không coi là số base cố định vĩnh viễn của tài khoản.
- Bằng chứng/cách dùng: [BASE_TRANSIT.md](BASE_TRANSIT.md), [MAP_DARK_JUNGLE.md](MAP_DARK_JUNGLE.md), mục tổng hợp trong [thiết kế](THIET_KE_GAME.md).
- **Còn chờ:** thử nhiều client thật, đặc biệt tình huống 12 người, người rời/vào và tương tác đồng thời. Việc tiếp theo là xác nhận không trùng quyền base, không thao tác được bàn/ống của người khác và Pet chuyển khu đúng.

### 3.2. Map săn Thung Lũng Sương Xám

**Trạng thái: Đã kiểm chứng trong phạm vi H2.0; bản hiện tại cần đóng kiểm tra thay đổi khai thác sắt.**

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

### 3.8. Khai thác sắt mới

**Trạng thái: Đang triển khai, chưa nghiệm thu bản lưu.**

- Mã cấu hình đã có **30 điểm quặng cố định** phân bố trên thung lũng; các tham số là thao tác 2,2 giây, hồi quặng 300 giây, tầm 9 studs và tối đa 3 hit.
- Có mã xây node, hình quặng/cuốc, service và client, manifest cài đặt, cùng tệp test kinh tế. Sự tồn tại của mã/test không tự chứng minh hành vi đã chạy đạt.
- Bằng chứng trực tiếp: [IronMiningConfig.luau](src/hunting/IronMiningConfig.luau), [manifest cài đặt](assets/iron-mining/iron-mining-install.json), [inspector chưa đạt](assets/iron-mining/iron-mining-saved.json).
- Báo cáo inspector khớp file chính hiện tại nhưng trả `Ok: false` vì phạm vi Instance. Chưa tìm thấy báo cáo Play riêng cho khai thác sắt trong nhóm bằng chứng đã đối chiếu; không ghi nhận đợt này hoàn thành.
- **Việc tiếp theo:** xác định Instance chênh ngoài phạm vi, phân loại thay đổi dự kiến/ngoài ý muốn, xử lý đúng nguyên nhân; sau đó thử khai thác, ngắt thao tác, hồi quặng, chống nhận lặp và lưu nguyên liệu, rồi kiểm tra native save lại.

### 3.9. Kho cá thể và ống trưng bày

**Trạng thái: Đã triển khai; đã kiểm chứng trong phạm vi các đợt P1-F và P1-F.2.**

- Mỗi lần bắt có mã cá thể và thông tin riêng, kho tối đa **100 cá thể**, preview 3D. Khi kho đầy, chặn bắt thêm trước khi tiêu thuốc theo luật đã kiểm.
- Đã có **5 ống/base × 12 base = 60 ống**, đặt/chuyển/tháo cá thể; một cá thể chỉ ở một ống. Server kiểm chủ base, khoảng cách, vũ khí, phiên thao tác và sở hữu.
- `DisplaySlots` có schema lưu và xử lý hồ sơ cũ thiếu trường. Ống 1–4 xoay, ống 5 giữ hướng; chuyển động phía client có giới hạn khoảng cách cập nhật.
- Bằng chứng: [SPECIMEN_COLLECTION.md](SPECIMEN_COLLECTION.md), [BIO_TUBES.md](BIO_TUBES.md), [bio-tubes-release.json](assets/hunting/bio-tubes-release.json), [bản lưu ống](assets/hunting/bio-tubes-saved.json).
- QA ống ghi **258 kiểm server/TestMemory** và **535 kiểm client**; bản lưu v2.4 của đợt ống ghi `validation: passed`, **1.785.285 kiểm tra đối chiếu / 133 script biên dịch**, dung lượng **4.348.341 byte**. Đây chủ yếu là kiểm kỹ thuật/thuộc tính, không phải hàng triệu tình huống chơi độc lập. Đợt đó không chứng nhận riêng trường Terrain `VoxelGridAssetContentMap` mà parser chưa đọc được.
- **Còn chờ:** nghiệm thu trưng bày/cá thể qua phiên cloud mới và nhiều client, hiệu năng nhiều ống đầy. Không dùng báo cáo v2.4 để chứng nhận toàn bộ bản MerchantWeapons mới. Chưa có bằng chứng hoàn chỉnh cho bán/thả/trao đổi/nuôi/biến thể ngẫu nhiên.

### 3.10. Lưu tiến trình và độ an toàn giao dịch

**Trạng thái: Đã triển khai; đã kiểm chứng logic, local và một phần cloud.**

- Đã có lớp lưu trang bị Người/Pet, giáp, cài đặt, kinh tế, cấp vũ khí, cá thể, ô trưng bày và receipt theo các phần mở rộng hồ sơ.
- Có tự lưu, lưu khi thoát, khóa phiên, retry và khôi phục lượt săn đứt; giao dịch chỉ báo thành công sau xác nhận ghi. Lỗi tải không được biến thành hồ sơ trắng.
- Bằng chứng: [PERSISTENCE.md](PERSISTENCE.md), [LUU_GAME.md](LUU_GAME.md), [persistence-play.json](assets/data/persistence-play.json), [savegame-play.json](assets/data/savegame-play.json).
- Hồ sơ ghi bộ session store **160 kiểm tra / 11 nhóm**, thử lỗi ghi/retry và local qua khởi động lại. Cloud Player đã giữ cài đặt 75% qua thoát/vào lại ngày 22/10.
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
| 26/10 — khai thác sắt | Có mã/node và file chính mới 4.480.005 byte | Inspector khớp hash nhưng `Ok: false`; chưa đóng nghiệm thu. |

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

| Vấn đề | Tác động tới quyết định của chủ dự án | Bước cần có |
| --- | --- | --- |
| Inspector khai thác sắt chưa đạt trên bản chính | Chưa chốt được bản tích hợp mới nhất có đúng phạm vi thay đổi | Xác định chênh lệch, xử lý nguyên nhân, native save và inspector đạt trên cùng hash. |
| Bằng chứng cloud giới hạn | Chưa đủ căn cứ xác nhận tài sản kinh tế/cá thể bền vững toàn vòng | Thử mua/chế/nâng/bắt/ống qua thoát/vào, mất kết nối và server mới. |
| Nhiều mốc tài liệu cũ còn ở README | Dễ hiểu nhầm phần đã làm hoặc chọn sai file | Sau khi ổn định bản, đồng bộ trạng thái và gắn bằng chứng đúng mốc. |
| Nhiệm vụ solo, một khủng long chung | Hạn chế trải nghiệm đồng thời và thiết kế săn đội | Nghiệm thu tương tác nhiều client hiện có; thiết kế săn đội thành đợt riêng. |
| Chưa nghiệm thu thiết bị thật/hiệu năng | Map lớn, cây, Pet và ống có thể ảnh hưởng trải nghiệm | Đo FPS, bộ nhớ và độ trễ trên cấu hình mục tiêu; chưa có số đo thì không tuyên bố đạt. |
| Workspace vượt xa commit cuối | Khó tái hiện và xác định bản nguồn tương ứng Place | Chốt manifest/hash/source và commit sau nghiệm thu; giữ dữ liệu cá nhân ngoài gói chia sẻ. |

## 6. Thứ tự công việc đề xuất và điều kiện hoàn thành

Các việc dưới đây là đề xuất ưu tiên, không phải các thay đổi đã thực hiện trong đợt báo cáo. Không gán lịch hoàn thành khi chưa có ước lượng và nguồn lực.

| Thứ tự | Công việc | Phụ thuộc | Điều kiện hoàn thành |
| --- | --- | --- | --- |
| 1 | Đóng kiểm tra khai thác sắt và chốt bản chính | Baseline, manifest và báo cáo chênh Instance | Giải thích/xử lý mọi chênh ngoài phạm vi; thử khai thác/nhận sắt/hồi quặng/lưu; inspector đạt trên cùng hash cuối, kiểm bảo toàn cảnh/Terrain đúng khả năng công cụ. |
| 2 | Hồi quy P1-G toàn vòng trên máy | Bản chính ổn định ở bước 1 | Từ hồ sơ thử sạch: mua → chế → nâng → săn → hạ/mổ hoặc bắt → kho/ống → lưu/tải lại; có cả thiếu tài nguyên, kho đầy, thất bại, hủy thao tác và replay; không thưởng/trừ lặp. |
| 3 | Nghiệm thu cloud trên bản riêng tư | Bản đã qua bước 2; xác nhận phiên bản xuất bản | Dùng tài khoản thử, xác nhận xu/nguyên liệu/vật tư/cấp vũ khí/cá thể/ô trưng bày/cài đặt giữ đúng qua phiên và mất kết nối; ghi Place, phiên bản, môi trường và kết quả. |
| 4 | Thử nhiều client và hiệu năng | Bản tích hợp ổn định; thiết bị/mức tải mục tiêu được chủ dự án chốt | Base/quyền, khủng long dùng chung, contributor, receipt và ống không xung đột; có số đo FPS/bộ nhớ/độ trễ và đối chiếu ngưỡng được thống nhất trước thử. |
| 5 | Nghiệm thu điều khiển thiết bị mục tiêu | Kết quả hiệu năng và phạm vi thiết bị được chốt | Chơi được toàn vòng bằng đầu vào thật, đọc/bấm được UI; giả lập bố cục chỉ là kiểm bổ sung. |
| 6 | Chốt tài liệu và mốc bàn giao | Các mục nghiệm thu tương ứng đã đóng | README chỉ đúng bản chính, ghi rõ local/cloud/Publish; manifest/hash và Git tái hiện được; danh sách lỗi còn mở có trạng thái rõ. |
| 7 | Mở rộng nội dung | Nền hiện tại đạt tiêu chí chất lượng đã chọn | Chủ dự án chọn đợt tiếp theo: nhiều loài/săn đội, Pet hoặc chế tạo nâng cao; mỗi đợt có tiêu chí riêng trước triển khai. |

**Điểm quyết định hiện tại:** ưu tiên xác minh và ổn định bản tích hợp mới nhất, sau đó đóng khoảng trống lưu cloud/toàn vòng. Các tính năng sẵn có đã đủ để thực hiện một đợt nghiệm thu sản phẩm có ý nghĩa; chưa nên dùng số lượng tính năng hoặc số kiểm tra lịch sử để thay cho kết quả nghiệm thu của đúng bản cuối.

## 7. Phạm vi của đợt lập báo cáo

Đợt này chỉ bổ sung tài liệu báo cáo Markdown. Không sửa mã, API, schema, giao diện, bản game hoặc dữ liệu người chơi; không chạy launcher, dùng mã thưởng, commit hay Publish Roblox. Những đề xuất khắc phục và phát triển ở trên chưa được thực thi.
