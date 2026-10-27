# Pet đồng hành — P1-C

**Hiện hành 26/10/2026:** bản chính là **HunDino_MerchantWeapons_20261026.rbxl**, đã gộp cửa hàng với sửa cung/Pet/di chuyển. Pet đánh khủng long một lần rồi về chủ, chờ ít nhất 10 giây tính từ đòn trước; dừng tại ngưỡng bắt 10% HP. Tự hồi sau 5 giây an toàn không bị đánh, 10 HP/giây; dưới 25% rút ra xa. Về sảnh hoặc bắt đầu lượt săn mới hồi đầy, giữ nguyên hồi chiêu chữa chủ. Xem [BOW_PET_FIXES.md](BOW_PET_FIXES.md) và mục 42 thiết kế; số liệu kiểm P1-C phía dưới là lịch sử.

**Cập nhật lớp lưu 20/10/2026:** v2.4 đã nối dữ liệu tiến trình vào hồ sơ tài khoản; xem [PERSISTENCE.md](PERSISTENCE.md) và thiết kế mục 39. Kiểm logic/Studio test đã có; nghiệm thu cloud qua thoát/vào còn chờ game xuất bản. Các câu chỉ giữ trong phiên và số liệu dưới đây thuộc mốc trước lớp lưu.

**Đồng bộ tài liệu: 20/10/2026 — đối chiếu bản v2.4 đã lưu ngày 19/10/2026.**

Pet P1-C đã nối với nhiệm vụ/bắt P1-D: ngừng phát đòn và hủy đòn chưa trúng khi chủ cho uống thuốc ngủ. [Kinh tế P1-E](HUNT_ECONOMY.md) và [kho cá thể P1-F bước đầu](SPECIMEN_COLLECTION.md) đã triển khai sau mốc Pet; phần còn lại là ống trưng bày, lưu tài khoản và hồi quy P1-G. Chưa hoàn thành toàn bộ P1.

Bản làm việc hiện hành: **HunDino_MerchantWeapons_20261026.rbxl**. Mốc P1-C ban đầu dùng **HunDino_DarkJungle_v2_4.rbxl**, theo mục 23 và 24.12 của hồ sơ thiết kế. Các số dưới đây là cấu hình thử, chưa chốt cân bằng toàn game.

## Cách thử trên PC

Để thử trong nhiệm vụ, nhấn **J** tại sảnh nhận lượt săn; khi khu săn chưa có nhiệm vụ, vẫn có thể vào thám hiểm qua menu **Chơi**. Gây sát thương lên khủng long rồi quan sát Pet tiếp cận và hỗ trợ. Pet chỉ tham chiến cùng chủ, không tự mở trận từ xa.

Nhấn **H** hoặc nút **Gọi Pet hồi** để gọi Pet tới ném thuốc. HUD cho biết máu Pet, trạng thái và thời gian hồi kỹ năng. Các phím hiện hành giữ nguyên: **Q** đánh mạnh, **E** kỹ năng, **R** rút/cất, **F** đỡ, **G** tương tác, **V** nhảy, **Space** lướt và **I** trang bị.

| Phần | Cấu hình hiện hành |
| --- | --- |
| Máu Pet | 100; sát thương không hạ dưới 1 |
| Hỗ trợ đánh khủng long | 12 sát thương một lần áp sát, tầm 6 studs; về chủ rồi chờ ít nhất 10 giây từ đòn trước; kiểm tra vật cản, dừng tại 10% HP quái |
| Di chuyển | 18 studs/giây; tìm đường quanh vật cản |
| Choáng | Khi còn 1 HP: bất động 30 giây, rồi hồi đầy; đòn mới không kéo dài thời gian |
| Gọi hồi | Pet tới gần chủ, ném viên thuốc lớn trong 0,8 giây; tầm thử 3,8 studs |
| Lượng hồi cho chủ | 70% máu tối đa, không vượt trần |
| Hồi chiêu | 119 giây, chỉ bắt đầu khi thực sự cộng máu |
| Tự hồi | Sau 5 giây không bị đánh tại nơi an toàn, hồi 10 HP/giây; HP ≤25% chủ động rút xa quái hơn 40 studs |
| Về sảnh/lượt săn mới | 100 HP, hết choáng; không làm mới hồi chiêu chữa chủ |

Chủ đầy máu thì không tiêu kỹ năng. Chủ chết, Pet choáng hoặc bị chuyển khu trước khi hồi thì hủy thao tác; chưa hồi thì chưa bắt đầu hồi chiêu. Không xếp lệnh chờ để tự hồi sau khi đứng dậy. Máu Pet, thời gian choáng và hồi chiêu nằm trên máy chủ, tách khỏi mô hình nhân vật có thể được tạo lại; hồi sinh hoặc chuyển khu không dùng để làm mới kỹ năng. Hồi đầy sau choáng cũng không xóa hồi chiêu.

Khi admin bay xem map, Pet dừng hành động và chờ dưới đất; không thay đổi HP hoặc đặt lại đồng hồ để lấy thêm lượt hồi. Hình học map, tuyến nghỉ của khủng long, sát thương và nhịp cắn H1.3.1 giữ nguyên.

## Kiểm chứng mốc P1-C — 19/10/2026

**Đã đạt: 150 kiểm tra luật bằng Lune**, gồm thời điểm sát mốc 4/30/119 giây, sát thương vượt HP, choáng không bị kéo dài, hồi theo máu tối đa, chống hồi vượt trần, gửi lặp và dữ liệu không hợp lệ. Đây là kiểm tra thuần dữ liệu, không thay thế thử đi đường, hoạt ảnh, va chạm và thao tác thật trong Studio.

**Đã thử trong Studio/Play:** 79 kiểm tra controller với raycast/blockcast thật đạt; 29 kiểm tra runtime mô phỏng đạt. Pet chỉ đánh sau đòn mở của chủ, gây 12 sát thương; cú cắn làm Pet giảm tới 1 HP, bất động rồi hồi 100 HP sau 30,08 giây. Bấm hồi khi choáng không xếp lệnh chờ. Nút hồi và phím H đều hoạt động; đo trực tiếp cộng 70 HP và bắt đầu hồi chiêu 119 giây. Hồi sinh giữ đúng mốc hồi chiêu, admin bay làm Pet chờ dưới đất. Bãi tập vẫn ghi nhận người đánh 36 và Pet đánh 12. Có 96 kiểm tra combat khủng long và sáu nhóm luật vũ khí đạt.

Tìm đường native qua tường thử đạt: Pet đi vòng trong 4,38 giây, không xuyên tường, còn 0,67 stud tới điểm theo chủ. Đây là hình học thử cô lập; chưa chứng minh mọi vách/đá tự nhiên trong map đều đi qua được. Bằng chứng: [`assets/hunting/pet-companion-play.json`](assets/hunting/pet-companion-play.json), [`ảnh Pet choáng`](assets/hunting/pet-stunned-p1c.png).

**Đối chiếu bản lưu v2.4 đạt 91.867 kiểm tra:** 86 script biên dịch, 79 source cũ không liên quan giữ nguyên, toàn bộ 43.775 Part và 845 khớp nối trong Place giữ nguyên; riêng Workspace có 35.064 Part và 723 khớp. Tám source hiện hành khớp file làm việc. Map vẫn 4.000 × 4.500, 2.400 cây, chín node và 16 đường. Chỉ đọc file bằng Lune; lưu Terrain bằng Studio.

```powershell
.\tools\lune\lune.exe run tools/test-pet-combat-rules.luau
.\tools\lune\lune.exe run tools/test-pet-companion-controller.luau
.\tools\lune\lune.exe run tools/inspect-pet-companion-saved.luau
```

Inspector chỉ đọc bản v2.4 và backup trước P1-C, so sánh toàn bộ Part/khớp nối, source cũ và tám source chuẩn liên quan; báo cáo tại `assets/hunting/pet-companion-saved.json`. Backup: `backups/Hub_v24_before_pet_companion_20261019.rbxl`.

Máu/choáng/hồi chiêu chỉ giữ trong phiên máy chủ hiện tại; chưa lưu tài khoản qua lần thoát hoặc máy chủ khởi động lại. Đã kiểm chứng PC, chưa kiểm chứng nhiều người thật hay điều khiển chiến đấu cảm ứng hoàn chỉnh.

## Source và bước tiếp theo

- `src/hunting/PetCombatRules.luau`: thông số và quy tắc HP/choáng/hồi chiêu.
- `src/hunting/PetCompanionController.luau`: điều khiển Pet và kiểm tra hành động phía máy chủ.
- `src/hunting/PetCompanion.client.luau`: HUD, nút và phím H.
- `studio-pet-integration/Training.server.luau` và `src/hunting/DinosaurCombat.luau`: nối với người chơi và đòn khủng long.

P1-C chưa hoàn thành vòng săn P1. **Đã có P1-D nhiệm vụ/bẫy/bắt, P1-E mổ/nhặt/thưởng/mua/chế/nâng và phần kho cá thể bộ nhớ của P1-F. Một ống trưng bày, lưu tài khoản và hồi quy toàn vòng P1-G còn chờ.** Chưa thêm săn đội, điện thoại hoàn chỉnh, né/đỡ/thu hút của Pet, tự rút hồi hoặc chế trang bị Pet.
