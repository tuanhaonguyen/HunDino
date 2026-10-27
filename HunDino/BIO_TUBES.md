# Ống nghiệm sinh học — P1-F.2

<!-- TIEN_DO_20261027_BEGIN -->
> **Trạng thái đối chiếu 27/10/2026, 09:48 UTC+7:** local chính `HunDino_MerchantWeapons_20261026.rbxl` **4.495.025 byte**, SHA256 `8626bc714aa7a0da39493ba1bbcc676a142038b2f8a2c06e602fe01d522229bf`; inspector **129.779 kiểm / 164 source**, đạt. Cloud có bằng chứng mới nhất **v14**, nguồn **4.481.440 byte**; sửa bố cục ống mới chỉ local, **chưa Publish**.
>
> Đã sửa đường vào 12 base, đồng bộ metadata dựng lại; 60 ống/12.000 Part giữ nguyên. Play 12 base và 252 mẫu đường đi đạt; sửa mới chỉ local.
>
> [Báo cáo tiến độ toàn dự án và hôm nay](BAO_CAO_TIEN_DO_2026-10-27.md). Ghi chú này cập nhật trạng thái; số liệu/hash của từng mốc cũ bên dưới giữ nguyên theo phạm vi lúc kiểm.
<!-- TIEN_DO_20261027_END -->

Mỗi Base có 5 ống trong `Workspace.SpecimenTubeDisplays.Base1..Base12`.
Đội hình theo thứ tự trái sang phải là **1, 2, 5, 3, 4** theo mặt trước cụm.
Mỗi base có vị trí/góc cụm riêng để chừa đường từ bệ dịch chuyển tới SpawnPad và sảnh.
Các công trình, Terrain, cảnh quan, bản đồ săn và rig gốc được giữ nguyên.

## Sử dụng

1. Về Base được phân cho mình, cất vũ khí bằng **R**.
2. Đến gần bảng điều khiển ống và nhấn **G**.
3. Trong **Inventory → Khủng long**, chọn cá thể rồi nhấn nút đặt vào ống.
4. Chọn ống khác để chuyển cá thể, hoặc tháo khỏi ống. Cá thể luôn được giữ trong kho.

Mỗi cá thể chỉ xuất hiện trong một ống. Khi chuyển, ô cũ được giải phóng;
cá thể bị thay thế vẫn thuộc sở hữu người chơi. Máy chủ kiểm tra Base, khoảng
cách, trạng thái vũ khí, phiên thao tác và quyền sở hữu trước khi ghi dữ liệu.

## Hình học và chuyển động

- 19,2 studs cao; bệ danh nghĩa 12 studs, bát giác, 8 chân chống và ống bơm.
- Kính gồm 24 tấm quanh thành rỗng; dung dịch trong để đọc được hình khối cá thể.
- Đầu đa tầng: vòm ngoài, 2 vòng Neon, 24 lá tản nhiệt, 4 giằng, 8 vòi cố định.
- Clone đúng T-Rex hiện có; chuẩn hóa hướng nhìn và thu phóng cả đuôi để vừa vòng xoay.
- 14 điểm bám bề mặt, đầu nối kim loại và dây uốn; 4 dây truyền dịch xanh.
- Ống 1–4 xoay 10°/giây; ống 5 giữ nguyên hướng. Nhấp nhô ±0,12 studs.
- Injector quay cùng cá thể nhưng giữ nguyên chiều cao; đầu dây theo thân khi nhấp nhô.
- Client cập nhật chuyển động ở khoảng cách tối đa 240 studs, 30/15 khung/giây.
- Mô hình trong kho xoay 12°/giây; kéo chuột để xoay/nghiêng ±65°, nghỉ 1,5 giây rồi tự xoay lại.

## Nguồn và dựng lại

- `src/hunting/BioTubeGeometry.luau`: hình học tĩnh, 200 Part/ống.
- `src/hunting/BioTubeSpecimen.luau`: cá thể và 14 dây nối.
- `src/hunting/BioTubeMotion.client.luau`: chuyển động phía client.
- `src/hunting/BioTubeService.luau`: cụm tại 12 Base, tương tác, đồng bộ trưng bày.
- `assets/hunting/BioTubeDisplays.rbxm`: 60 ống rỗng, chỉ hình học mới.
- `tools/build-bio-tube-art.luau`: dựng lại asset; không ghi hay tái xuất Place/Terrain.
- `bio-tubes.project.json`: đồng bộ có giới hạn, giữ đối tượng ngoài phạm vi.

Profile `DataVersion = 2` lưu `DisplaySlots` cùng kho hiện có. JSON dùng khóa
chuỗi cho các ô thưa; khi đọc, schema xác minh và chuyển về chỉ số 1–5.
Hồ sơ cũ chưa có `DisplaySlots` được thêm bảng trống mà không xóa tiến trình.

## Sao lưu và kiểm tra

### Sửa kẹt khi đến base — 27/10/2026

Bản chính `HunDino_MerchantWeapons_20261026.rbxl` dùng **BioTubeGeometry.5 / TransitClearance.1**.
Đã kiểm các bản v2.4, SaveGame, CodeFix, BeforeClose, HelloHunDino, bản chính và AutoRecovery:
các bản có ống đều còn vị trí chồng điểm đến ở Base 3, 5, 6, 10. Base 11 từng được
dời thủ công nhưng `StaticOrigin` còn ở vị trí cũ. Không tìm được bản cũ đã sửa đủ 12 base.

Đã điều chỉnh cụm tại Base 3–7, 9–10, 12, giữ bố cục an toàn tại Base 1, 2, 8, 11;
đồng bộ `ClusterOrigin`, `StaticOrigin`, anchor cá thể và mã dựng lại. Giữ hình học,
va chạm của 60 ống/12.000 Part. Không đổi điểm dịch chuyển.
Tâm mỗi ống cách tuyến đi vào base ít nhất 10 studs.

- Backup trước sửa: `backups/base-clearance-20261027/`; module gốc trong `ServerStorage.BaseClearanceBackup_20261027`.
- Play với TestMemory riêng: giữ G mở bảng thật, chọn đủ 12 base, đi ra 22,33–22,78 studs,
  giữ G về sảnh; không bị ống cản, quyền sở hữu base giữ nguyên. Không sửa hồ sơ thật.
- Sau chỉnh pivot cuối (0,025 studs theo trục Y), dò lại 252 hộp thân người trên 12 tuyến: không giao ống có va chạm.
- Bản native đạt 129.779 kiểm tra / 164 source biên dịch (gồm module backup mới);
  giữ 49.221 instance ngoài cụm ống và toàn bộ byte của 70 thuộc tính Terrain.
- File chính 4.495.025 byte, SHA256 `8626bc714aa7a0da39493ba1bbcc676a142038b2f8a2c06e602fe01d522229bf`.
- Bằng chứng: `assets/base-clearance/studio-play.json`, `survey.json`, `saved-inspection.json`.
  Inspector chỉ đọc: `tools/inspect-base-clearance-saved.luau`. Đã gỡ cờ/script QA khỏi bản lưu.

**Đã lưu local; chưa Publish sửa ống này lên Roblox.** Bản cloud v14 là mốc trước sửa.

Bản gốc trước triển khai:
`backups/Hub_v24_before_5_specimen_tubes_20261021.rbxl`.
Script gốc được giữ trong `ServerStorage.SpecimenTubesBackup_20261021`
và `backups/specimen_tubes_20261021/scripts`.

Các fixture `tools/qa/bio-tubes.*` chỉ phục vụ Studio Play với `TestMemory`;
không được đóng gói vào bản lưu cuối. Bản lưu cuối dùng
`src/data/ProfileConfig.luau` với `StudioMemoryTest=false`.

Chạy inspector sau native Save:

```powershell
.\tools\lune\lune.exe run tools/inspect-bio-tubes-saved.luau
```

Inspector chỉ đọc Place, kiểm tra bảo toàn hình học/khớp/nguồn và ghi báo cáo
`assets/hunting/bio-tubes-saved.json`. Terrain được lưu bằng Roblox Studio;
Lune không được dùng để serialize Place vì parser chưa hỗ trợ hết dữ liệu Terrain.
