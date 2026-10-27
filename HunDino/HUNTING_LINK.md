# Sảnh ↔ Rừng cổ H1.2 — 16/10/2026

<!-- TIEN_DO_20261027_BEGIN -->
> **Trạng thái đối chiếu 27/10/2026, 09:48 UTC+7:** local chính `HunDino_MerchantWeapons_20261026.rbxl` **4.495.025 byte**, SHA256 `8626bc714aa7a0da39493ba1bbcc676a142038b2f8a2c06e602fe01d522229bf`; inspector **129.779 kiểm / 164 source**, đạt. Cloud có bằng chứng mới nhất **v14**, nguồn **4.481.440 byte**; sửa bố cục ống mới chỉ local, **chưa Publish**.
>
> Tính năng trong tài liệu này được đối chiếu cùng bản chính hiện hành; các file v2.x/SaveGame, tham số và kết quả thử cũ trong phần dưới là mốc lịch sử, không tự chứng nhận toàn bộ bản mới. Phạm vi còn chờ: P1-G toàn vòng, cloud kinh tế/cá thể/ống, nhiều client và thiết bị thật.
>
> [Báo cáo tiến độ toàn dự án và hôm nay](BAO_CAO_TIEN_DO_2026-10-27.md). Ghi chú này cập nhật trạng thái; số liệu/hash của từng mốc cũ bên dưới giữ nguyên theo phạm vi lúc kiểm.
<!-- TIEN_DO_20261027_END -->

**Đồng bộ tài liệu: 20/10/2026 — đối chiếu bản v2.4 đã lưu ngày 19/10/2026.**

Bản chung hiện hành là [v2.4](HunDino_DarkJungle_v2_4.rbxl) trong Documents, nối sảnh/12 base/bãi tập với **H2.0 Thung Lũng Sương Xám 4.000 × 4.500**. Nhận nhiệm vụ bằng **J** tại sảnh; khi chưa có nhiệm vụ, menu Chơi/cổng G vẫn cho thám hiểm. Mỗi máy chủ chỉ có một lượt nhiệm vụ solo với một T-Rex chung. Trong nhiệm vụ, ba lần chết đầu về trại, lần thứ tư/hết 40 phút thì thất bại; ra biên giữ lượt, thắng có 120 giây rồi về sảnh.

Pet chiến đấu/hồi máu, bẫy/bắt, thưởng và kho cá thể đã nối; chưa có săn đội, ống trưng bày hoặc lưu tài khoản. Xem [H2](GREY_MIST_VALLEY.md), [nhiệm vụ](HUNT_QUEST.md), [kinh tế](HUNT_ECONOMY.md) và [cá thể](SPECIMEN_COLLECTION.md). Các mô tả chết về sảnh/chưa combat hoặc thưởng dưới đây chỉ áp dụng H1.2.

## Hồ sơ nối sảnh H1.2 — 16/10/2026

**Cảnh quan hiện hành H2.0 — 19/10/2026:** sảnh đã nối với Thung Lũng Sương Xám 4.000 × 4.500; vào bằng Chơi → Vào săn. Xem [bản nâng cấp và kiểm chứng mới](GREY_MIST_VALLEY.md). Nội dung và hash H1 bên dưới là lịch sử.

**Bản hiện hành đã lên H1.3:** nghỉ 60 giây tại mọi điểm, thanh máu/hitbox và phản công đã nối với vũ khí; xem [DINOSAUR_COMBAT.md](DINOSAUR_COMBAT.md). Các số kiểm tra và hash H1.2 bên dưới là hồ sơ của mốc ghép sảnh.

**Bản chung của mốc H1.2: `HunDino_DarkJungle_v2_3.rbxl`.** Đây là bản chung đã có sảnh, 12 base, bãi tập, khu săn và con mẫu tuần tra. File `HunDino_HuntingRainforest_v1.rbxl` vẫn là bản nguồn xem riêng H1.1.

## Cách đi và về

- Ở sảnh trung tâm: bấm biểu tượng **Chơi → VÀO KHU SĂN · RỪNG CỔ**, hoặc tới cổng đá rêu bên trái quảng trường và giữ **G**.
- Người chơi và Pet xuất hiện cùng ở trại săn. Base đang sở hữu, vũ khí và giáp được giữ; vũ khí được cất và động tác đang chạy được hủy khi chuyển khu.
- Về sảnh bằng nút **VỀ SẢNH TRUNG TÂM** ở bảng bên trái, menu Chơi, hoặc giữ **G** tại cổng ở trại săn. Hết thời gian cũng tự về cùng Pet.
- Điều khiển giữ theo bản sảnh: **Shift chạy, V nhảy, Space lướt**. **M** chọn khu xem nhanh chỉ khi đang ở rừng trong Studio; thao tác này đưa Pet đi cùng và không đặt lại đồng hồ lượt săn.

Thời gian thử mặc định **40 phút**; chỉnh `HuntDurationSeconds` trong adapter cấu hình nếu cần. Đây là thời lượng xem khu săn để nối luồng, chưa phải nhiệm vụ có mục tiêu/thưởng. Khủng long đã đi/nghỉ theo tuyến; chưa có đuổi, đánh, bắt giữ hoặc thưởng khi hạ.

## Thời gian và phiên đi săn

Server xác nhận giờ vào UTC+7 và thời điểm bắt đầu. Ánh sáng rừng chạy trên riêng client của người đang săn, dùng thời gian đồng bộ từ server: **2 phút thật = 1 giờ rừng**. Khi về sảnh hoặc chết, phục hồi Lighting/Atmosphere/hiệu chỉnh màu của sảnh. Người ở sảnh không chịu ánh sáng của lượt săn khác.

Mỗi người có đồng hồ/lượt vào riêng. Con mẫu tuần tra dùng chung trong vùng rừng; người đầu tiên vào khởi động, người cuối cùng ra thì dừng và đưa con mẫu về A. Chưa tạo server riêng cho từng đội.

## Cách ghép

Hai khu nằm trong **cùng một Place**, dùng luồng dịch chuyển đang có. Rừng được đặt tại offset `(0,0,6500)` studs; vị trí sảnh, base, đền và bãi tập giữ nguyên. Không cần publish hoặc PlaceId khác để thử bằng Play.

- Địa hình được copy/paste bằng Studio thành bốn TerrainRegion 204 × 44 × 204 cells, tổng vùng 1.632 × 176 × 1.632 studs. Chỉ paste tại vùng rừng; không Clear hoặc dựng lại Terrain của sảnh.
- Dịch cả phần hình học và các thuộc tính đường `RouteStart`/`RouteEnd`. Adapter cộng offset cho node/đường/độ cao; không chạy lại BuildHuntingMap/EnhanceHuntingForest ở map chung.
- Tắt CampSpawn; chỉ LobbySpawn hoạt động. Hồi sinh quay về sảnh. Ra biên rừng hoặc rơi thấp được đưa về qua cùng luồng dọn trạng thái và Pet.
- Không cài runtime/HUD độc lập H1.1 vào map chung. Giữ điều khiển/camera của sảnh, thêm HUD và đồng hồ theo `InHunting`.
- Server xác minh khoảng cách với cổng, khu xuất phát, nhân vật còn sống, cooldown và trạng thái đang chuyển khu. Chỉ cho vào rừng từ gần sảnh; menu từ base yêu cầu về sảnh trước. Yêu cầu M chỉ nhận trong Studio và đang săn.

## Đã kiểm chứng

- **188/188** kiểm tra trực tiếp bản Edit đạt: địa hình tại chín khu và điểm ngoài đường, 718 đoạn mặt đường, offset thuộc tính, cổng và spawn.
- Play vào/về bằng nút thật và giữ G thật tại hai cổng. Pet ở gần nhân vật (~5,93 studs), base/vũ khí Pet và người không đổi. M chọn C giữ thời điểm vào ban đầu.
- Server vẫn giữ Lighting 16:06 trong khi client rừng chạy từ giờ thực khoảng 23:03. Sau khi về, clock/ambient/brightness khôi phục chính xác, HUD rừng ẩn, session bị xóa, con mẫu về A.
- Chết trong rừng → hồi sinh ở LobbySpawn với Pet; giữ base. Ra biên rừng → về sảnh an toàn. Thử hết giờ bằng cấu hình tạm 30 giây → tự về đúng; **đã phục hồi mặc định 2.400 giây trước Save**.
- Yêu cầu vào rừng từ base xa, đích sai kiểu và chọn khu M khi đang ở sảnh bị từ chối. Đi bãi tập/về sảnh vẫn hoạt động. Lượt kiểm tra không thấy lỗi server/client.
- Đọc bản sau Save: **15.066 part gốc** của DarkJungle và HunDinoL0 được giữ chính xác so với backup ngay trước ghép; 16 source không liên quan giữ nguyên; 10 source hiện hành khớp file làm việc; 34 script biên dịch được. Không dùng Lune ghi `.rbxl` vì chưa đọc đủ thuộc tính Terrain mới.

Chưa kiểm tra nhiều client thực, điện thoại hoặc hiệu năng mạng/máy yếu. Mô hình phiên hỗ trợ đồng hồ riêng, nhưng chưa có phòng săn riêng, nhóm hay thưởng/nhiệm vụ.

## File và bảo toàn bản cũ

- Backup sảnh ngay trước ghép: `backups/Hub_before_hunting_link_20261016.rbxl`, SHA256 `25472d3bef530441f3656c8e36eb51682bdd2d47a927e41b9ec6b31d954e9d71`.
- Bản chung đã lưu Studio: `HunDino_DarkJungle_v2_3.rbxl`, 1.452.607 byte, SHA256 `bd6a95fc8b72b2931fdf6ab69d7ddc163c6208153d9f39beba356b086c15075c`.
- Source đang cài: `studio-pet-integration/Training.server.luau`, `Training.client.luau`; `src/dark-jungle/HubUI.luau`, `Traversal.server.luau`; `src/hunting/HuntingSession.luau`, `ConnectedHuntingConfig.luau`, `ConnectedHuntingViewer.client.luau`, `DinosaurRouteController.luau`, `EnvironmentClock.luau`.
- Bản nguồn săn H1.1 được giữ. Các thay đổi hình học sảnh do người dùng làm trước đợt ghép (biển Welcome và đá) cũng được giữ theo backup mới; không khôi phục chúng về ảnh chụp cũ.
- Kiểm chứng: `assets/hunting/connected-validation.json`, `connected-play.json`, `connected-saved.json`; công cụ: `tools/validate-connected-hunt.luau`, `inspect-connected-hunt-saved.luau`, `add-hunting-link-portals.luau`.

Không đồng bộ `default.project.json` của L0 lên bản chung này; không chạy lại các bộ dựng cũ trên map đã sửa thủ công.
