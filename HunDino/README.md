# HunDino — Dark Jungle và bãi tập

<!-- TIEN_DO_20261027_BEGIN -->
> **Trạng thái đối chiếu 27/10/2026, 09:48 UTC+7:** local chính `HunDino_MerchantWeapons_20261026.rbxl` **4.495.025 byte**, SHA256 `8626bc714aa7a0da39493ba1bbcc676a142038b2f8a2c06e602fe01d522229bf`; inspector **129.779 kiểm / 164 source**, đạt. Cloud có bằng chứng mới nhất **v14**, nguồn **4.481.440 byte**; sửa bố cục ống mới chỉ local, **chưa Publish**.
>
> Báo cáo tổng hợp đã cập nhật toàn bộ hệ thống, kiểm kê tệp và danh sách việc còn lại. Các số liệu/ghi chú “chưa Publish” trong phần mốc 26/10 bên dưới giữ ý nghĩa lịch sử.
>
> [Báo cáo tiến độ toàn dự án và hôm nay](BAO_CAO_TIEN_DO_2026-10-27.md). Ghi chú này cập nhật trạng thái; số liệu/hash của từng mốc cũ bên dưới giữ nguyên theo phạm vi lúc kiểm.
<!-- TIEN_DO_20261027_END -->

**Git / push code:** xem [HUONG_DAN_GIT.md](../HUONG_DAN_GIT.md). Làm việc trên `developer`; `main` yêu cầu kiểm tra và chủ repo duyệt qua PR.

**Sửa kẹt ống khi dịch chuyển — 27/10/2026:** bản chính `HunDino_MerchantWeapons_20261026.rbxl` đã chỉnh bố cục 60 ống tại 12 base và mã dựng lại. Thử giữ G/chọn từng base/đi ra/về sảnh đủ 12 base đạt; 252 mẫu hộp thân người không vướng ống. Lưu native, giữ map ngoài cụm ống, Terrain và các source gameplay/lưu hiện hành. **Sửa ống này chưa Publish**; cloud v14 còn bố cục cũ. Xem [chi tiết](BIO_TUBES.md).

**Sửa tải hồ sơ sau phát hành — 27/10/2026:** bản Roblox **v14** và file chính `HunDino_MerchantWeapons_20261026.rbxl` đã nhận lại biên nhận HelloHunDino cũ. Máy chủ thật xác nhận `ProfileReady=true`, `Saved`, `DataStore`; hồ sơ vẫn có 210 xu, độ nhạy 75% và biên nhận mã đã dùng. Không reset/cấp lại thưởng. Bản lưu native đạt 85.318 kiểm tra, 163 script biên dịch, giữ hình học và toàn bộ 70 trường Terrain. Chi tiết và giới hạn kiểm chứng: [bản ghi phát hành](PHAT_HANH_20261027.md).

**Mốc xuất bản v12 trước sửa hồ sơ — 27/10/2026:** `HunDino_MerchantWeapons_20261026.rbxl` đã cập nhật vào [HunDino SaveGame](https://www.roblox.com/games/103801986821599/), Place `103801986821599`, **phiên bản 12**. Đã mở lại từ Roblox, xác nhận 163 source và 30 điểm quặng của bản mới; chế độ TestMemory tắt. Các ghi chú “Chưa Publish” bên dưới là trạng thái ở từng mốc trước lần xuất bản này. Ảnh `AvatarHundino.png` đã được xác định; thao tác đổi icon đang chờ truy cập Creator Dashboard bằng trình duyệt được cấp quyền. Xem [bản ghi phát hành](PHAT_HANH_20261027.md).

**Công thức bẫy sắt trong Inventory — 26/10/2026:** **I → CHẾ TẠO → 1 bẫy thô + 1 sắt → 1 bẫy sắt**. Có số nguyên liệu đang có và nút chế tạo; đứng gần bàn ở base của bạn, cất vũ khí bằng R để bấm. Đã thử hai lần chế liên tiếp, khóa khi thiếu nguyên liệu/đứng xa, lưu native vào bản chính MerchantWeapons và đối chiếu bảo toàn map/Terrain. Chưa Publish. Xem [cách dùng và kiểm chứng](INVENTORY_CRAFTING.md).

**Bản chính đã gộp cung/Pet/di chuyển — 26/10/2026:** mở [CHOI_CUA_HANG.cmd](CHOI_CUA_HANG.cmd) hoặc [CHOI_VA_LUU.cmd](CHOI_VA_LUU.cmd), rồi Play trong [HunDino_MerchantWeapons_20261026.rbxl](HunDino_MerchantWeapons_20261026.rbxl). Giữ cửa hàng và cấp riêng bảy vũ khí. Tam Tiễn cấp 1 gây **3 × 24 = 72** khi cả ba mũi trúng; cung tụ từ **40 → 120 studs**. Pet đứng sau bên trái khi ngắm, đánh khủng long một lần rồi về chủ chờ **10 giây**, bảo vệ ngưỡng bắt **10% HP**, tự hồi và đầy máu khi về sảnh/lượt mới. Đã thử W khi xoay camera trong cả ngắm/tụ và tự do. Chi tiết: [BOW_PET_FIXES.md](BOW_PET_FIXES.md), thiết kế mục 42. Đã lưu native; chưa Publish bản gộp lên Roblox.

**Mốc cửa hàng trước khi gộp — 26/10/2026:** thương nhân/icon dùng cùng giao diện; mỗi vũ khí của Người có cấp riêng, nâng tại bàn base; bỏ thanh Đã lưu/LƯU trên HUD và giữ tự lưu ngầm. Đã thử Studio desktop/HD 720, kiểm giao dịch và bảo toàn map; inspector ở mốc này đạt **523 kiểm tra / 146 script biên dịch**. Các sửa chiến đấu hiện đã gộp vào bản chính ở trên; xem [chi tiết cửa hàng](MERCHANT_WEAPON_UPGRADES.md).

**SaveGame đã khôi phục Nhập code — 22/10/2026:** mở **Cài đặt → Nhập code**, cạnh **Save game**. Đã lưu bản trên máy và xuất bản bản Roblox SaveGame (Place `103801986821599`); đã thử nhập mã sai bằng bàn phím thật và nhận phản hồi server trong Roblox Player. Thoát/vào lại để nạp cập nhật. Tiến trình hiện có được giữ nguyên. Xem [hướng dẫn SaveGame](LUU_GAME.md).

**Lưu tiến trình trên máy:** hai launcher ở đầu trang đều mở bản chính MerchantWeapons và bật bộ lưu. Dữ liệu thật nằm ở `local-save/profiles.json`, giữ qua Stop/Play và khởi động lại bộ lưu. Nhánh DataStore cho Roblox tiếp tục được giữ; hai kho tách riêng. [HunDino_SaveGame.rbxl](HunDino_SaveGame.rbxl) là mốc cũ để đối chiếu. Xem [cách dùng và kiểm chứng](LUU_GAME.md). File v2.4 gốc bên dưới được giữ nguyên.

**Bản Roblox riêng:** [HunDino SaveGame](https://www.roblox.com/games/103801986821599/), GameId `10772272829`. Đã thử đổi độ nhạy 100% → 75%, cloud xác nhận lưu, thoát/vào lại vẫn 75% trong Roblox Player ngày 22/10/2026. Phép thử này xác nhận lưu cài đặt; chưa thay cho hồi quy toàn bộ kinh tế/cá thể trên cloud.

**Nguyên liệu khi Khám phá — 21/10/2026:** đã nối hạ T-Rex → **R cất vũ khí → giữ G 1,5 giây mổ**, tối đa **3 lượt/người/xác** trong 120 giây; nguyên liệu hiện tại **I → Vật phẩm**, không cần nhận nhiệm vụ J. Đã thử hạ/mổ thật, chặn lượt thứ tư và giữ đồ qua sảnh/tải lại hồ sơ thử. Cài trên Place HunDino cloud đang mở; bản sao [HunDino_ExplorationLoot_20261021.rbxl](HunDino_ExplorationLoot_20261021.rbxl). Xem [hướng dẫn và bằng chứng](EXPLORATION_LOOT.md). Chưa Publish thay đổi lên game live.

**Dọn HUD — 21/10/2026:** đã thu gọn thanh máu Boss, bỏ thanh thông báo lưu thường trực và thêm **Cài đặt → Save game** cạnh Nhập code. Đã thử desktop/giả lập ngang, xác nhận tự lưu và Save game trên DataStore riêng của Studio. Bản native [HunDino_HUDClean_20261021.rbxl](HunDino_HUDClean_20261021.rbxl) đã lưu và đối chiếu đạt **8.766 kiểm tra / 130 script biên dịch**, giữ cảnh/Terrain; bốn source HUD cùng bảy source exploration đồng thời khớp mã chuẩn. Phép thử riêng thoát/vào sau Save game và nghiệm thu thiết bị thật/nhiều client còn chờ; chưa Publish. Xem [phạm vi và kiểm chứng](HUD_CLEANUP.md).

**Hiện hành: hồ sơ v0.44 — bản chính MerchantWeapons đã sửa kẹt ống khi đến 12 base; giữ cửa hàng, chế tạo, chiến đấu, khai quặng và lớp lưu tài khoản.**

**Nhập code thử admin — 21/10/2026:** **Cài đặt → Nhập code**, mã **`HUNDINO-ADMIN-500`** dành riêng cho **tunzdangcap / 11605296816**, nhận một lần **500 xu + mỗi loại da/răng/vảy/xương/sắt 10 cái**. Đã cài và thử trên bản Studio cloud `PlaceId 103261391098991`; tài khoản admin thật chưa dùng mã. Bản xuất riêng: [HunDino_AdminTest_20261021.rbxl](HunDino_AdminTest_20261021.rbxl), **4.285.326 byte**, đối chiếu native đạt **8.683 kiểm tra / 129 script biên dịch**. Bản local v2.4 liên kết bên dưới giữ nguyên, không phải bản cài mã mới. Xem [cách dùng, bản lưu và kiểm chứng](ADMIN_TEST_CODE.md), thiết kế mục 40. Chưa xuất bản thay đổi lên game live.

**Lưu tiến trình:** trang bị Người/Pet, giáp, cài đặt, xu/nguyên liệu/vật tư, chế/nâng hiện có, cá thể và receipt đã nối DataStore; có tự lưu, lưu khi thoát, retry/khóa phiên và khôi phục lượt đứt. Xem [hướng dẫn chi tiết](PERSISTENCE.md), thiết kế mục 39. Đã kiểm logic/Studio TestMemory; **còn phải nghiệm thu cloud trên game đã xuất bản**. File local hiện GameId/PlaceId=0 sẽ báo chưa tải được hồ sơ, không tạo kho tạm rồi giả báo đã lưu.

**Bản để mở/chỉnh tiếp:** [HunDino_DarkJungle_v2_4.rbxl](HunDino_DarkJungle_v2_4.rbxl) tại `Documents/ChatGPT/game roblox/HunDino`; ngày bản game 20/10/2026. [Hồ sơ v0.41](THIET_KE_GAME.md) giữ cùng nội dung với bản ở thư mục cha; mục 39 ghi lớp lưu; mục 38 giữ bước hiện đại hóa UI.

**Đã có:** sảnh/12 base ngẫu nhiên và dịch chuyển, bãi tập 7 vũ khí/28 combo, Pro/cung/lướt, T-Rex/combat, H2.0, bay admin, Pet P1-C, nhiệm vụ/bắt P1-D, kinh tế P1-E và kho cá thể P1-F bước đầu. UI dùng bảng màu Dark Hunter, Inventory đủ năm tab **Người / Pet / Vật phẩm / Khủng long / Chế tạo**, HUD Boss/Pet/nhiệm vụ và vòng tiến độ giữ phím. **Còn chờ:** hồi quy P1-G, cloud toàn vòng kinh tế/cá thể/ống, săn đội và nghiệm thu điện thoại/nhiều client. Ống trưng bày và công thức bẫy sắt Inventory đã triển khai; cloud v14 đã kiểm tải/lưu hồ sơ thực. Bàn chế/nâng P1-E tại base đã có.

**Bản lưu UI hiện hành:** **4.250.777 byte**, lưu bằng Roblox Studio; phạm vi cài là bảy source UI sửa và hai source trình bày mới. Đã thử năm tab, trang bị độc lập, mua/nhặt/chế vật tư, giữ B đặt bẫy và gọi Pet hồi máu trong Play desktop; đã căn bố cục giả lập màn hình ngang nhỏ. Trạng thái bắt/mổ, Pet choáng và cá thể mẫu dùng fixture phía client để kiểm hiển thị, không tính là bắt/mổ thật trong đợt UI. Xem [phạm vi, bản lưu và kiểm chứng UI](UI_MODERNIZATION.md).

**Đối chiếu bản lưu UI đạt:** inspector `native-save` có **8.784 kiểm tra**, **120 script biên dịch**, **9 source chuẩn khớp** và **7 backup khớp**; giữ **43.775 Part/845 khớp**, riêng Workspace **35.064 Part/723 khớp**, cùng dữ liệu Terrain nhị phân. Báo cáo so sánh **61.193 Instance / 5.334.152 lượt thuộc tính**, không phát hiện khác biệt ngoài source UI được phép; danh sách thuộc tính không đọc được và ngoại lệ metadata native được ghi rõ trong [báo cáo](assets/hunting/ui-modernization-saved.json). Metadata chọn rỗng `FilteredSelection` ở gốc do Studio quản lý giảm `5 → 4`; `HistoryId` được loại khỏi đối chiếu lịch sử chỉnh sửa.

**Dữ liệu hiện hành:** hồ sơ tài khoản DataVersion=1 bọc kinh tế DataVersion=2, tối đa 100 cá thể; đã cài persistence, còn chờ nghiệm thu cloud. Các số liệu bản lưu UI bên trên là mốc trước lớp lưu. Bản lưu sau kho cá thể ngày 19/10 có 4.220.334 byte, 139.120 kiểm tra đọc/đối chiếu, 118 script biên dịch và 23 source chuẩn khớp là mốc lịch sử trước UI.

## Tài liệu hiện hành và đợt đồng bộ trước UI

Hồ sơ UI mới: [UI_MODERNIZATION.md](UI_MODERNIZATION.md). Danh mục 27 tài liệu bên dưới ghi đợt đồng bộ trước UI; các hồ sơ cũ giữ nguyên số liệu/hash theo mốc. Hai bản thiết kế tổng giữ giống nhau. File trong `backups/` không thuộc đợt sửa tài liệu.

| File | Nội dung cập nhật chính |
| --- | --- |
| [THIET_KE_GAME.md ở thư mục gốc](../THIET_KE_GAME.md) | Hồ sơ 0.40; mục 38 là UI hiện hành, mục 37 giữ đợt tổng hợp trước UI |
| [THIET_KE_GAME.md trong HunDino](THIET_KE_GAME.md) | Bản đồng bộ giống hệt hồ sơ ở gốc |
| [thiết kế map săn.md](<../thiết kế map săn.md>) | Đối chiếu yêu cầu map gốc với H2 đã dựng và phần còn chờ |
| [README.md](README.md) | Trạng thái hiện hành, chỉ mục 27 tài liệu, phân biệt lịch sử |
| [MAP_DARK_JUNGLE.md](MAP_DARK_JUNGLE.md) | v2.4/base/sảnh hiện hành, nhãn lịch sử đảo cũ |
| [TRAINING_SANCTUARY.md](TRAINING_SANCTUARY.md) | File chơi Documents v2.4, nền tảng mới và quy trình dựng lịch sử |
| [COMBOS_V2_3.md](COMBOS_V2_3.md) | Combo kế thừa, lướt mới, UI và nâng búa |
| [WEAPONS_PRO.md](WEAPONS_PRO.md) | Pro trên v2.4, Người/Pet độc lập và phạm vi nâng búa |
| [KATANA_PRO.md](KATANA_PRO.md) | Katana lịch sử và VFX chung hiện hành |
| [BOW_CHARGE_RESTORE.md](BOW_CHARGE_RESTORE.md) | Chỉ chuột trái tụ lực; Q mạnh ngay; phép thử Q cũ là lịch sử |
| [DARK_STEP.md](DARK_STEP.md) | Lướt 72/0,5 giây/6 thể lực và nhãn phép đo cũ |
| [BASE_TRANSIT.md](BASE_TRANSIT.md) | Base ↔ sảnh v2.4, base phiên và bàn chế chủ |
| [INVENTORY.md](INVENTORY.md) | Người/Pet độc lập và đủ các mục Inventory |
| [INVENTORY_ITEMS.md](INVENTORY_ITEMS.md) | Vật phẩm/Khủng long, snapshot và kiểm chứng từng mốc |
| [PET_STANDING.md](PET_STANDING.md) | Rig kế thừa, trang bị độc lập và Pet P1-C |
| [PET_COMPANION.md](PET_COMPANION.md) | Dừng đánh khi bắt và tiến độ nhiệm vụ/kinh tế/cá thể |
| [DINOSAUR_01.md](DINOSAUR_01.md) | Model riêng so với T-Rex tích hợp combat/bắt |
| [DINOSAUR_COMBAT.md](DINOSAUR_COMBAT.md) | Nhịp cắn hiện hành và liên hệ Pet/bắt/thưởng |
| [HUNTING_MAP.md](HUNTING_MAP.md) | H2/v2.4 so với file nguồn H1 riêng |
| [HUNTING_LINK.md](HUNTING_LINK.md) | Luồng nhiệm vụ/về trại hiện hành và hồ sơ H1.2 |
| [GREY_MIST_VALLEY.md](GREY_MIST_VALLEY.md) | H2 kế thừa trên v2.4 và gameplay đã nối |
| [ADMIN_FLY.md](ADMIN_FLY.md) | Bay với Pet/bẫy/bắt/mổ và bằng chứng riêng |
| [HUNT_QUEST.md](HUNT_QUEST.md) | Vật tư sở hữu, bắt cấp cá thể và giới hạn kho |
| [HUNT_ECONOMY.md](HUNT_ECONOMY.md) | Giao dịch cấp cá thể/hồ sơ v2 và phần F còn lại |
| [SPECIMEN_COLLECTION.md](SPECIMEN_COLLECTION.md) | Kho cá thể bước đầu, bản lưu cuối và phần chưa có |
| [DON_DEP_DU_AN.md](DON_DEP_DU_AN.md) | File v2.4/dung lượng hiện hành; kiểm kê cũ giữ lịch sử |
| [TEST_DARK_JUNGLE_V2_1.md](TEST_DARK_JUNGLE_V2_1.md) | Báo cáo lịch sử, hướng dẫn sang bằng chứng hiện hành |

## Các mốc triển khai — số kiểm chứng giữ đúng thời điểm

Các đoạn ngày 19/10 mô tả từng bước nối tiếp; số đo/hash và vật tư thử của mốc cũ không thay trạng thái hiện hành ở trên. Các hướng dẫn L0.1 ở cuối chỉ dành cho bản L0.1.

**Kho cá thể bắt sống — bước đầu P1-F, 19/10/2026:** **I → KHỦNG LONG** xem mỗi T-Rex đã bắt theo mã riêng, số thứ tự, thời điểm UTC+7 và mô hình 3D tĩnh có thể xoay. Một lần bắt ghi một cá thể cùng thưởng hiện có; kho thử tối đa 100, đầy thì vẫn săn tiêu diệt được và không trừ thuốc để bắt thêm. Đã thử bắt thực, tự về sảnh sau 120 giây và hồi sinh vẫn giữ cùng cá thể; phiên máy chủ mới trở về kho rỗng. **Chưa lưu tài khoản, chưa làm ống trưng bày**; tab Chế tạo trong Inventory tiếp tục để chờ. Đã lưu native Studio, luật kho đạt 2.134 kiểm tra và preview đạt 4.858 kiểm tra; [phạm vi, bản lưu và bằng chứng](SPECIMEN_COLLECTION.md).

**Inventory/Vật phẩm — 19/10/2026:** nhấn **I → VẬT PHẨM** để xem toàn bộ nguyên liệu săn, bẫy và thuốc ngủ, số xu cùng phần đang mang đi săn. Đã bỏ nút kho nguyên liệu bên ngoài; tab **CHẾ TẠO** mới chỉ là khung chờ theo yêu cầu. Người/Pet và vũ khí/giáp giữ nguyên. Xem [hướng dẫn](INVENTORY_ITEMS.md).
**Nguyên liệu và chế tạo P1-E — 19/10/2026:** bản v2.4 đã nối kho thử trong phiên, 80 xu khởi đầu, sáu quặng sắt/lượt, vảy rơi, ba lượt mổ, nguyên liệu bắt sống và thưởng 1 xương/40 xu. Mua bẫy thô/thuốc tại sảnh; chế bẫy và nâng búa +15% tại base của bạn. Đồ nhặt giữ khi thua, đồ mang dư trả kho; các giao dịch có dấu chống lặp. Thay vật tư miễn phí P1-D bằng vật tư sở hữu; **chưa lưu tài khoản**. Xem [hướng dẫn và kiểm chứng](HUNT_ECONOMY.md). Các mục cũ bên dưới giữ lịch sử.
**Nhiệm vụ săn và bắt sống P1-D — 19/10/2026:** bản v2.4 đã cài, thử Play và lưu: nhấn **J** tại sảnh để nhận lượt săn T-Rex **40 phút**, giữ **B** đặt bẫy và giữ **G** cho uống thuốc khi quái còn ≤10% HP, đang mắc bẫy. Có **3 lượt hồi sinh**, ngã lần thứ 4 thì thất bại; hoàn thành có 120 giây xem hiện trường hoặc về sớm, ngày/đêm tiếp tục chạy đến khi rời map. Đã thử bắt/hạ, hồi sinh, ra biên và quay về; bản lưu đạt **139.055 kiểm tra**. Ở mốc P1-D ban đầu cấp 3 bẫy + 3 thuốc thử; **hiện P1-E mang tối đa 3/3 đồ sở hữu**, có thưởng, và P1-F bước đầu thêm cá thể. Chưa lưu tài khoản. Một lượt solo trên máy chủ do dùng chung một khủng long. Xem [cách thử, thông số và giới hạn kiểm chứng](HUNT_QUEST.md).

**Pet đồng hành P1-C — 19/10/2026:** đã cài và thử trong bản v2.4: Pet hỗ trợ đánh 12 sát thương mỗi 4 giây, có 100 HP, choáng 30 giây và gọi hồi bằng **H** hoặc nút riêng; hồi 70% máu tối đa, hồi chiêu thử 119 giây, giữ qua hồi sinh. Đã thử chiến đấu, hồi máu, choáng và tìm đường vòng tường; bản lưu qua 91.867 kiểm tra giữ nguyên cảnh. Xem [cách thử, thông số và kiểm chứng](PET_COMPANION.md). Nhiệm vụ/bắt P1-D, thưởng/kinh tế P1-E và kho cá thể P1-F bước đầu đã nối tiếp; lưu tài khoản còn chờ. Dữ liệu Pet hiện chỉ trong phiên máy chủ.

**Bay xem map dành cho admin — 19/10/2026:** bản Studio hiện hành là **`HunDino_DarkJungle_v2_4.rbxl`** trong thư mục Documents của dự án. Tài khoản được cấp quyền có nút **Bay xem map** hoặc chat **`/fly`**, ba mức tốc độ 80/160/260 và Shift tăng tốc gấp đôi. Xem [quyền admin, điều khiển và cách gỡ tiện ích tạm](ADMIN_FLY.md). Bản v2.3 được giữ làm mốc trước; các tên v2.3 trong lịch sử bên dưới thuộc các lần cập nhật cũ.

**Thung Lũng Sương Xám H2.0 — 19/10/2026:** khu săn mở rộng **4.000 × 4.500 studs** theo file `thiết kế map săn.md`: rừng thông, đồng cỏ đầu thu, hồ có đảo, đầm lầy, trạm kiểm lâm, trại gỗ bỏ hoang, khe suối/thác và núi có hang. Giữ các tuyến A/B/C và R1–R5, nghỉ 60 giây, combat H1.3.1 và đồng hồ thực ×30. Mở bản chung trong Documents rồi **Play → Chơi → VÀO SĂN**; xem [cảnh quan, nguồn tài sản và kiểm chứng](GREY_MIST_VALLEY.md). Các mục H1 bên dưới là lịch sử.

**Chỉnh nhịp né H1.3.1 — 17/10/2026:** cú cắn báo trước 0,95 giây (+0,3), chu kỳ hai lần tấn công 3,5 giây (+1). Lướt xa khoảng 16,5–16,8 studs trong Play, vẫn tốn 6 thể lực. Đã lưu/kiểm tra bản chung; xem [thông số hiện hành](DINOSAUR_COMBAT.md).

**Khủng long phản công H1.3 — 17/10/2026:** trên bản chung **HunDino_DarkJungle_v2_3.rbxl trong Documents**, mọi điểm nghỉ A/B/C/R1–R5 đều 60 giây thực. Con mẫu có thanh máu 1.200 HP, vùng trúng thân/đầu/chân và cú cắn có báo trước; chỉ đuổi/đánh người đã gây sát thương. Vũ khí và cung hiện có đã dùng được trong rừng. Đã thử Play, 96 kiểm tra tích hợp và 6 nhóm luật vũ khí đạt; xem [cách thử và thông số](DINOSAUR_COMBAT.md). Chưa có bắt giữ, nhiệm vụ hoặc thưởng.

**Đã nối sảnh ↔ Rừng cổ H1.2 — 16/10/2026:** mở **HunDino_DarkJungle_v2_3.rbxl trong Documents/ChatGPT/game roblox/HunDino**, bấm **Play → Chơi → VÀO KHU SĂN · RỪNG CỔ**, hoặc giữ **G** tại cổng đá rêu bên trái sảnh. Pet đi cùng, giữ base/trang bị; về bằng nút bên trái hoặc cổng ở trại săn. Đồng hồ rừng riêng từng người chạy 30 lần, về sảnh khôi phục ánh sáng. Bản thử mặc định 40 phút và tự về khi hết giờ. Combat được bổ sung ở H1.3 bên trên; nhiệm vụ/thưởng chưa có. Xem [hướng dẫn và kiểm chứng bản nối](HUNTING_LINK.md). File săn riêng H1.1 giữ làm bản nguồn; [hồ sơ cảnh quan](HUNTING_MAP.md).

**Lướt Dark Step — mốc 15/10/2026:** Space từng tăng quãng khoảng 14% trong phép đo sàn phẳng; hiệu ứng khói/bóng/tư thế được giữ. **Hiện hành H1.3.1:** tốc độ đầu 72 trong 0,5 giây, tốn 6 thể lực, đo khoảng 16,5–16,8 studs; xem tài liệu liên kết. Xem [hồ sơ và kiểm tra](DARK_STEP.md).

**Dịch chuyển base ↔ sảnh — 15/10/2026:** mỗi base có bệ giữ G để về trung tâm; bệ tại sảnh mở bảng chọn Base 1–12, đánh dấu base của bạn và hiện tên chủ. Pet đi cùng, ghé base khác không đổi quyền sở hữu. Xem [cách dùng và kiểm tra](BASE_TRANSIT.md).

**Nhận base ngẫu nhiên — 15/10/2026:** khi vào server, bốc một số từ 1–12. Số đã có chủ bị loại khỏi lượt bốc, tiếp tục bốc trong các số còn lại đến khi gặp base trống. Mỗi lượt tối đa 12 lần; đủ chủ thì báo server đầy. Base được giữ khi hồi sinh và trả lại khi thoát; chưa lưu quyền sở hữu qua phiên. Đã kiểm tra không trùng, còn đúng một base trống và kín cả 12 base bằng `tools/test-random-base.luau`; chạy Play xác nhận số base và biển chủ đồng bộ. Backup trước sửa: `backups/HunDino_v2_3_before_random_base_20261015.rbxl`.

**Túi đồ Người/Pet — 15/10/2026:** mỗi phần có Vũ khí chỉ hiện tên và Giáp gồm năm ô Đầu/Thân/Tay/Eo/Chân. Xem trước nhân vật bên trái, bảng giáp ở giữa, món đang chọn bên phải; trang bị Người/Pet độc lập. Đã lưu bản Studio trong Documents. Xem [cách dùng và kết quả kiểm tra](INVENTORY.md).

**Khôi phục tụ lực cung — 15/10/2026:** chỉ giữ chuột trái để tụ, nhả để bắn; **Q giữ nguyên là đòn mạnh**, E là kỹ năng. HUD phần trăm/đầy lực và kiểm tra thời gian giữ trên server đã được ghép vào bản Studio trong Documents. Xem [hồ sơ sửa và cách thử](BOW_CHARGE_RESTORE.md).

**Bộ bảy vũ khí Pro — 15/10/2026:** đã cập nhật model, tư thế pet và VFX theo mẫu mới. Bản chứa các cập nhật pet/vũ khí vừa lưu bằng Studio nằm trong **Documents/ChatGPT/game roblox/HunDino/HunDino_DarkJungle_v2_3.rbxl**. Xem [nội dung và kiểm tra](WEAPONS_PRO.md); dùng `tools/test-weapons-pro.luau` cho bản này. Đường dẫn Desktop bên dưới là hồ sơ của mốc trước.

**Cập nhật combo/UI v2.3:** 7 vũ khí × 4 combo, nối chuỗi qua lướt, tiêu hao thể lực còn 30%. Bốn icon Cửa hàng/Cài đặt/Chơi/Túi đồ đã nối với UI. Xem [cách thử 28 combo](COMBOS_V2_3.md), [thiết kế hiện hành mục 25.8](THIET_KE_GAME.md) và [danh sách file có thể dọn](DON_DEP_DU_AN.md). Icon Shop vẫn là giao diện xem/Sắp mở; giao dịch P1-E đã có tại quầy tiếp tế ở sảnh và bàn chế/nâng tại base chủ.

**Bản đang phát triển: `HunDino_DarkJungle_v2_4.rbxl` trong `Documents/ChatGPT/game roblox/HunDino`.** Tiếp tục từ bản người dùng lưu ngày 08/10/2026; các đường dẫn Desktop ở tài liệu cũ là lịch sử. Giữ chữ tiếng Việt khi lưu bằng định dạng Roblox Place `.rbxl`. Bãi tập rộng 460 × 420 studs, có sân võ, bốn làn cung và **bảy loại vũ khí**. Cất vũ khí rồi nhấn **I** để chọn; **R** rút/cất, **V** nhảy, **Space** lướt. Cung có góc ngắm lệch vai, giữ chuột phải để ngắm. Xem [hướng dẫn và kết quả thử](TRAINING_SANCTUARY.md).

**Không đồng bộ `default.project.json` vào Dark Jungle:** cấu hình này dành cho L0, sẽ thay code chuyển khu và điều khiển mới bằng code cũ. Không dựng lại map khi chưa lưu các sửa thủ công sang file riêng.

**Sửa đường đền 09/10/2026:** đã căn lại 10 mặt đường TempleApproach cùng 8 viền rêu; đi thử hai chiều và kiểm tra map/bãi tập sau lưu đều đạt. Hồ sơ tại mục 25.9.

## Tài liệu bản L0.1 cũ

Các hướng dẫn bên dưới dành riêng cho L0.1, không phải cách cập nhật map Dark Jungle.

File để mở trong **Roblox Studio → File → Open from File**: **HunDino_L0.rbxlx**. Bấm **F5 / Play** để chạy. Đây là bản phát triển từ `HunDino1.rbxl` của bạn; file Desktop được giữ nguyên.

## Phần đã tạo

- Giữ 12 base, thác, đường đi và cây cảnh; thêm sân đón, cổng và biển số/chủ base. 14 cây/đá vướng sân đón được dời sang mép rừng trong bản phát triển.
- Vào game ở sân đón; mỗi người được gán một base trống trong phiên. Máy chủ thử từ chối người thứ 13. Cấu hình số người của game trên Roblox vẫn cần đặt 12 khi xuất bản.
- Đứng gần cổng, giữ **G** để đi/về bãi tập. Bãi tập hiện là khu tách vị trí trong **cùng một Place**, chưa phải map/server riêng qua TeleportService.
- Búa thử với ba đòn, combo thường → mạnh → kỹ năng; thể lực, rút/cất, chạy và lướt thử.
- Ba hình nộm có số sát thương; hết máu tự đầy lại. Không trao nguyên liệu/phần thưởng.
- Giáp mẫu gắn trên nhân vật; giá trang bị cho mặc/tháo. Chưa có chỉ số phòng thủ/chế tạo.
- Pet mô hình khối theo chủ và đánh hình nộm chủ vừa đánh theo chu kỳ. Chưa có hoạt ảnh chân, tìm đường vòng, gọi hồi, máu/choáng hay trang bị pet.

## Điều khiển PC

| Thao tác | Phím |
| --- | --- |
| Di chuyển / xoay camera | WASD / chuột phải mặc định Roblox |
| Rút hoặc cất búa | R, mất 1 giây |
| Đánh thường / mạnh / kỹ năng | Chuột trái / Q / E |
| Combo thử | Chuột trái → Q → E, chờ đòn trước kết thúc |
| Chạy | Giữ Shift; tự cất búa trước nếu đang rút |
| Lướt thử | Space, tốn thể lực; chưa có động tác lộn/i-frame |
| Ghim tâm tự tạo | Ctrl; Shift Lock mặc định đã tắt |
| Cổng / thay giáp / xóa thống kê tập | Giữ G gần đối tượng; cất búa trước khi thay giáp/reset |

Chỉ kiểm tra PC ở mốc này; chưa có nút cảm ứng. Thông số trong `src/shared/TrainingConfig.luau` đều là cấu hình thử. Pet không thay đổi luật đóng góp 10% của game tương lai.

## Trạng thái kiểm tra

Đã chạy **9 nhóm kiểm tra tự động bằng Lune**, gồm biên dịch Luau, combo và hết thể lực, chặn đánh quá nhanh, hồi thể lực, bảo toàn số đối tượng map gốc/12 base, điểm spawn và đối chiếu code nhúng. **Chưa xác nhận bằng Play trong Studio**: công cụ điều khiển cửa sổ bị lỗi nhập liệu/foreground trong phiên làm việc này. Chưa đánh dấu bản L0 hoàn thành hoặc sẵn sàng mở cho người chơi.

Checklist cần chơi thử:

- [ ] Mở file không báo lỗi tải; Play không có lỗi đỏ trong Output.
- [ ] Xuất hiện ở sân đón, đi qua cổng bằng G và quay về được.
- [ ] R rút/cất đủ trễ; Shift không bỏ qua cất; nhả Shift dừng chạy.
- [ ] Đánh đúng tầm/hướng làm hiện số; đứng xa/sau tường không trúng.
- [ ] Combo đúng ra 140 ở đòn kết thúc; spam không đánh nhanh hơn nhịp.
- [ ] Thể lực giảm/hồi; không đánh/lướt khi thiếu; Space không vừa nhảy vừa lướt.
- [ ] Đổi giáp, reset thống kê, hồi sinh nhân vật không nhân đôi búa/pet.
- [ ] Pet theo chủ qua cổng, đánh theo chu kỳ; kiểm tra chỗ dễ mắc cây/tường.
- [ ] Local server 2 người: base khác nhau; thống kê riêng; người rời trả base.
- [ ] Thử đủ 12 người; đọc biển, độ sáng, lối đi và tốc độ khung hình.

## File và cách tiếp tục

- `THIET_KE_GAME.md`: hồ sơ thiết kế, đọc **mục 25** trước khi làm tiếp.
- `HunDino_original.rbxl`: bản sao nguyên vẹn của map Desktop, SHA256 `3416378401F1338B1C33A125FC15F9BB49DF0D0AB87D75A6FCE42067731090FC`.
- `HunDino_original.rbxlx`: bản chuyển sang XML để kiểm tra; không sửa map này.
- `HunDino_L0.rbxlx`: map phát triển chứa code, mở trực tiếp không cần Rojo.
- `src/server/Training.server.luau`: cấp base, búa, giáp, hình nộm, pet, chuyển khu.
- `src/client/Training.client.luau`: điều khiển, camera và giao diện.
- `tools/build-map.luau`: dựng lại L0 từ bản sao gốc + source. **Dựng lại sẽ ghi đè file L0**, vì vậy lưu mọi sửa map thủ công sang tên khác trước; không chạy lại nếu đang có chỉnh sửa map cần giữ.
- `tools/test-training.luau`: bộ kiểm tra ngoài Studio.

Chạy từ thư mục này, sau khi đã lưu các thay đổi map thủ công ở file riêng:

```powershell
.\tools\lune\lune.exe run tools/build-map.luau --rebuild
.\tools\lune\lune.exe run tools/test-training.luau
```

`default.project.json` chỉ đồng bộ code, để nguyên các đối tượng ngoài phạm vi. Không dùng `rojo build` để thay cho map có cảnh: cấu hình này không chứa hình học bản đồ. Mở L0 trước rồi dùng Rojo nếu cần đồng bộ source.

Lune 0.10.5 tải từ [kho chính thức](https://github.com/lune-org/lune/releases/tag/v0.10.5), kiểm tra SHA256 archive `ad0305f5cc6d7ff20996644b40bf7de0de613812f431ca241456e16f9fc89cda`; nằm riêng trong `tools/lune`, không cài hệ thống. Định dạng map dùng [thư viện Roblox của Lune](https://lune-org.github.io/docs/api-reference/roblox/). Quy tắc xác thực server theo [Roblox Creator Hub](https://create.roblox.com/docs/scripting/security/client-server-boundary).
