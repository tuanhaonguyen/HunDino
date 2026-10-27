# Bộ bảy vũ khí Pro — 15/10/2026

**Đồng bộ tài liệu: 20/10/2026 — đối chiếu bản v2.4 đã lưu ngày 19/10/2026.**

Bộ bảy model/VFX Pro cho Người/Pet và mẫu trưng bày được kế thừa trong [v2.4](HunDino_DarkJungle_v2_4.rbxl). Người/Pet chọn vũ khí độc lập qua [Inventory](INVENTORY.md); [combo](COMBOS_V2_3.md) và [tụ lực cung](BOW_CHARGE_RESTORE.md) tiếp tục áp dụng. Chỉ chuột trái tụ lực cung, Q là đòn mạnh. [Pet P1-C](PET_COMPANION.md) hỗ trợ trong rừng; nâng búa P1-E +15% chỉ áp dụng búa của chủ, không tăng sát thương Pet hoặc vũ khí khác. Bảng model/VFX và kiểm chứng bên dưới thuộc mốc 15/10.

## Hồ sơ bộ Pro — 15/10/2026

Đã ghép bộ mẫu mới của người dùng vào game và lưu bằng Roblox Studio:
`C:/Users/khanh/OneDrive/Documents/ChatGPT/game roblox/HunDino/HunDino_DarkJungle_v2_3.rbxl`.
Đợt này tiếp tục từ bản đã có pet đứng và katana Pro. Bản Desktop không được ghi đè.

## Model và hiệu ứng

| Vũ khí | Nội dung theo mẫu | Hiệu ứng |
|---|---|---|
| Hammer | Đầu búa thép tối, viền đồng, gai, vòng cán, ngọc hai mặt | Xung kích xanh ngọc, Trail/Sparks |
| SwordShield | Kiếm hai cạnh và khiên nhiều lớp, lõi vàng | Sóng kiếm vàng, Trail/Sparks trên kiếm |
| Katana | Cán quấn đỏ, lưỡi hai đoạn cong, mũi Wedge | Kiếm khí xanh băng, Trail/Sparks |
| Glaive | Cán dài, đế nhọn, cổ thương, tua và lưỡi lớn | Xung kích đâm thẳng xanh ngọc |
| DualDaggers | Hai dao cùng bộ cán, chắn tay, lưỡi và mũi | Hai nhịp chém chéo tím; Trail/Sparks ở cả hai tay |
| Bow | Hai nhánh cung, ngọc ngắm, dây sáng xanh lá | Trail/Sparks và tên xanh lá |
| GreatAxe | Hai lưỡi thép tối, lõi vàng, mũi và cạnh dung nham | Vết nứt dung nham cam và Trail/Sparks |

- Model được dùng cho cả chủ, pet và bảy mẫu trưng bày trong nhà vũ khí. Giữ vỏ katana hiện có.
- Pet có các chỉnh tư thế: kiếm/katana xoay hông và chém chéo; thương xoay thân đâm; búa/rìu nhấc thân khi gồng; cung nghiêng thân ngắm. Song dao tiếp tục có hai nhịp tay xen kẽ.
- Chuẩn hóa tiến độ theo thời lượng thật của từng kiểu đánh, thay cho hằng 0,8 giây trong vòng biểu diễn mẫu. Kiếm/katana trở về tư thế nghỉ êm ở cuối đòn.
- Client dùng thời điểm đánh do server đồng bộ. VFX không có va chạm, hitbox hoặc sát thương thêm. Tắt khi nghỉ/đổi đồ, tuân theo ShowComboFX, tự dọn sau 0,3–0,5 giây.
- Tên cung dùng hiệu ứng Shot sẵn có, đổi sang xanh lá và bay tới điểm trúng thực tế; không tạo thêm mũi tên thứ hai cho cùng một lần bắn. Tên được buff vẫn dùng màu vàng để giữ dấu hiệu hiện có.
- Giữ sát thương, thể lực, combo, khoảng cách và chu kỳ đánh của game. Pet vẫn có tổng 12 sát thương mỗi đợt; song dao chia thành hai mốc.
- Không thêm sân khấu hoặc vòng pet tự biểu diễn vào map.

## Source và sao lưu

- `src/dark-jungle/WeaponsPro.luau`: builder thuần tạo từng Model có PrimaryPart, Main/Offhand và Weld. Template trong ServerStorage và mô hình trưng bày được neo; bản trang bị được bỏ neo qua code hiện có.
- `WeaponVFX.luau`, `WeaponEffects.client.luau`: hiệu ứng riêng và bộ điều phối chung. LocalScript hiện hành trong Studio là **HunDinoWeaponEffects**, thay cho HunDinoKatanaEffects.
- `PetAnimator.luau`: tư thế theo vũ khí và profile thời lượng/mốc trúng dùng chung với VFX.
- `studio-pet-integration/Training.server.luau` và `Training.client.luau`: source chính xác của bản đang mở. Source ở `src/dark-jungle` cũng được cập nhật phần tích hợp, giữ các tính năng khác vốn có trong thư mục.
- Module KatanaPro và file KatanaEffects cũ được giữ làm lịch sử; LocalScript katana riêng không còn chạy. Hồ sơ KATANA_PRO.md và test-katana-upgrade.luau dành cho mốc trước bộ mẫu mới. Dùng **tools/test-weapons-pro.luau** để kiểm tra bản hiện tại.
- Map trước sửa: `backups/HunDino_v2_3_before_weapons_pro_20261015.rbxl`; code trước sửa: `backups/studio_before_weapons_pro_20261015.json`. Có thêm bản sao template, display và source sửa trong `ServerStorage.WeaponsProBackup_20261015`.

## Đã kiểm tra

- Lune: biên dịch source; dựng cả bảy model, kiểm tra PrimaryPart, Weld, Trail/Attachment; giữ kiểm tra mốc trúng khi khung hình dài, hủy đòn và destroy.
- Studio: gắn đủ bảy vũ khí vào pet, không trùng Weld/Motor6D, đúng số Trail/Sparks, profile khớp thời lượng đánh.
- Play qua remote chọn đồ hiện có: cả bảy có Trail trên chủ/pet. Sáu vũ khí cận chiến sinh VFX riêng; song dao có bốn VFX cho hai nhịp của chủ và pet, cả hai tay đều có Trail. Cung có hai tên thật của chủ/pet.
- Mỗi lượt thử pet gây đúng 12 sát thương. Trail tắt sau đòn; tắt ShowComboFX không sinh VFX kỹ năng; không còn hiệu ứng tạm sau khi dọn.
- Hồi sinh chỉ còn một pet. Bộ theo dõi tạm của lượt kiểm tra đầu có lỗi đọc Handle trong khi nhân vật đang được dựng lại; mã game không dùng bộ theo dõi này. Đã kiểm tra lại hồi sinh ở phiên Play mới, không phát sinh lỗi client.
- Sau lưu bằng Studio, test-weapons-pro đạt: source và template đúng, vỏ katana còn nguyên; 14.727 phần map ngoài bảy mô hình trưng bày giữ nguyên. Fingerprint trong Studio là 1196573492 trước/sau sửa.
- Chưa kiểm tra nhiều client hoặc hiệu năng khi 12 pet cùng đánh. Lune chỉ đọc map để kiểm tra, không ghi lại Terrain.

Thử trong Play: tới bãi tập, R cất, I chọn vũ khí, R rút rồi đánh hình nộm để pet tham gia.
