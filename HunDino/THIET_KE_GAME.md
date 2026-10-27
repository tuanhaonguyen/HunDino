# Hồ sơ thiết kế game Roblox săn khủng long

**Sửa nhận nguyên liệu Khám phá — 21/10/2026:** trên Place HunDino cloud (`103261391098991`), hạ T-Rex trong Khám phá cũng mở mổ xác: **R cất vũ khí, giữ G 1,5 giây**, tối đa **3 lượt/người/xác trong 120 giây**, đưa da/răng/vảy vào **I → Vật phẩm**. Người đã gây sát thương có phần riêng; không mở lại phần từ cùng xác khi rời/vào lại. Khám phá không dành bẫy/thuốc, cấp thưởng xu/xương của nhiệm vụ hoặc tăng thống kê nhiệm vụ. Đã kiểm luật **227/10 nhóm**, tích hợp native **25** và hồi quy mổ **121**; Play TestMemory thực nhận 2 da/1 vảy, giữ qua sảnh/tải lại hồ sơ thử. Đây không phải nghiệm thu DataStore thật. Source và bản sao native `HunDino_ExplorationLoot_20261021.rbxl` được ghi tại [EXPLORATION_LOOT.md](<C:/Users/khanh/OneDrive/Documents/ChatGPT/game roblox/HunDino/EXPLORATION_LOOT.md>); chưa Publish game live. Mục Chế tạo Inventory tiếp tục để sau.

Phiên bản hồ sơ: 0.44 — Cập nhật: 27/10/2026 — Sửa kẹt ống khi dịch chuyển đến 12 base — Giữ cửa hàng, chế tạo, chiến đấu, khai quặng và lưu tài khoản

**Bản đang làm theo lựa chọn người dùng:** **HunDino/HunDino_MerchantWeapons_20261026.rbxl** trong Documents. Mở **HunDino/CHOI_CUA_HANG.cmd** hoặc **HunDino/CHOI_VA_LUU.cmd** rồi Play. Giữ cửa hàng/nâng riêng bảy vũ khí, công thức bẫy sắt, sửa cung/Pet/di chuyển, khai quặng và lớp lưu hiện hành. Cloud đã phát hành v14 với sửa tương thích hồ sơ; riêng sửa ống tại **mục 44** mới lưu local, **chưa Publish**. SaveGame và v2.4 là các mốc cũ để đối chiếu.

**Lưu tiến trình — 20/10/2026:** đã nối lớp DataStore theo tài khoản vào trang bị Người/Pet, giáp từng ô, cài đặt, xu/nguyên liệu/vật tư, chế bẫy, nâng búa, kho cá thể, mã chống nhận trùng, thống kê săn và hồi chiêu hồi chủ của Pet. Mua/chế/nâng/thưởng ghi trước khi báo thành công; trang bị/cài đặt gom lưu sau 2 giây, tự lưu dự phòng 30 giây và lưu khi rời/đóng máy chủ. Có trạng thái tải/lưu/lỗi, nút lưu và thử tải lại. Xem **mục 39** và [PERSISTENCE.md](<C:/Users/khanh/OneDrive/Documents/ChatGPT/game roblox/HunDino/PERSISTENCE.md>).

**Giới hạn kiểm chứng hiện hành:** bản chính là file cục bộ (GameId/PlaceId = 0), dùng bộ lưu trên máy qua launcher; các phép thử sửa chiến đấu dùng TestMemory riêng. Bản Roblox SaveGame trước đó đã kiểm giữ độ nhạy qua thoát/vào ngày 22/10 (xem LUU_GAME.md), chưa thay cho hồi quy kinh tế/cá thể đầy đủ trên cloud hoặc nghiệm thu bản gộp mới. Khi tải thất bại, hệ thống tiếp tục chặn tiến trình thay vì tạo hồ sơ trắng. Săn đội, hồi quy P1-G toàn vòng và nghiệm thu điện thoại/nhiều client còn chờ; phạm vi từng mốc cũ được giữ tại phần tương ứng.

**Đọc nhanh:** mục 42 là sửa cung/Pet/di chuyển đã gộp; mục 41 là cửa hàng/cấp riêng bảy vũ khí; mục 39 là nền lưu tài khoản, mục 38 UI, mục 36 kho cá thể, mục 34 kinh tế, mục 33 nhiệm vụ/bẫy/bắt, mục 32 Pet, mục 31 H2 và mục 30 combat. Các câu “chỉ giữ trong phiên/chưa DataStore”, cấp búa duy nhất hoặc Pet đánh mỗi 4 giây tại mốc cũ là lịch sử; không thay quy tắc hiện hành ở mục mới. Mục 1–22 giữ định hướng; mục 23–24 giữ kế hoạch P1. Thông số thử chưa phải cân bằng toàn game.

**Bổ sung 21/10/2026:** mục 40 ghi **Cài đặt → Nhập code**, mã thử nhận một lần dành riêng cho admin. Cài trên bản Studio cloud `PlaceId 103261391098991`; bản local v2.4 ở trên giữ nguyên. Chi tiết bản lưu và cách dùng tại [ADMIN_TEST_CODE.md](<C:/Users/khanh/OneDrive/Documents/ChatGPT/game roblox/HunDino/ADMIN_TEST_CODE.md>); chưa xuất bản thay đổi lên game live.

| Phần | Hiện trạng | Cần làm tiếp |
| --- | --- | --- |
| Gameplay v2.4 | Sảnh/base, bãi tập, săn/bắt con mẫu, Pet và UI đã chơi thử PC | Cân bằng, hiệu năng, điện thoại và nhiều client |
| Kinh tế/kho | Mua, nhặt, mổ, thưởng, chế bẫy, cấp riêng bảy vũ khí và cá thể đã nối vào tài khoản | Hồi quy cloud toàn bộ bằng phiên/server mới |
| Trang bị/cài đặt | Vũ khí/giáp Người và Pet độc lập; tùy chọn UI/độ nhạy được lưu | Kiểm tra trên tài khoản đã xuất bản |
| Lớp lưu | UpdateAsync, khóa phiên, retry, receipt, recovery, shutdown và thông báo lỗi | Nghiệm thu DataStore thật, quota và shutdown nhiều người |
| Phần mở rộng | Một ống/năm ống, thêm công thức/cấp, săn đội, hệ/loài | Chưa triển khai; giữ yêu cầu đã thống nhất |
| P1-G | Có các bộ kiểm riêng từng hệ thống | Chưa nghiệm thu hồi quy toàn vòng game |

## 1. Cách đọc và cập nhật

- **Đã thống nhất:** yêu cầu người dùng nêu hoặc đồng ý; chỉ thay đổi khi trao đổi lại.
- **Đề xuất:** hướng giải quyết để thảo luận, chưa tự động trở thành yêu cầu.
- **Chưa chốt:** thiếu thông số hoặc còn nhiều cách hiểu; không tự đặt thành quyết định cuối cùng.
- Các số minh họa không phải thông số cân bằng chính thức.
- Khi có thay đổi: sửa trực tiếp mục liên quan, ghi quyết định vào nhật ký; không giữ các yêu cầu mâu thuẫn song song.
- Dùng tên viết tắt **MHW** cho Monster Hunter: World trong mọi trao đổi tiếp theo.
- Phân biệt thuật ngữ: **tiêu diệt/hạ thú** kết thúc mục tiêu; **choáng/gục tạm thời** chỉ làm quái mất khả năng hành động một lúc rồi tiếp tục chiến đấu. Các mục cũ dùng “hạ gục” đối lập với bắt giữ mang nghĩa kết thúc mục tiêu.
- Người làm game bắt đầu từ chưa biết lập trình và đồ họa: hướng dẫn theo từng bước, giải thích thuật ngữ, kiểm tra bản nhỏ trước khi mở rộng.
- Người dùng đã xác nhận **bắt đầu dự án**, đổi sảnh từ 16 xuống **12 người**, làm map/base và khu luyện tập trước. Nếu mở đợt gửi nội dung mới và yêu cầu đợi, tiếp nhận đến khi họ báo “xong” rồi mới tổng hợp. Hiện tại đã có yêu cầu triển khai/tiếp tục, không phải đang chờ.
- **Cấu hình thử:** lựa chọn/thông số do trợ lý đặt để bản thử có thể được thực hiện và đánh giá; chưa phải quyết định cuối cho toàn game. Các mục 1–22 giữ yêu cầu nền tảng; mục 23–24 ghi phạm vi rút gọn và lựa chọn thử. Đợt rà soát ngày 27/09 chỉ sửa hồ sơ, không tự khởi động việc viết code.
- Các câu “chưa chốt” trong phần toàn game có thể đã có phương án thử riêng cho P1. Khi làm P1 đọc cấu hình mục 23–24; không hiểu là phải hỏi lại mọi thông số trước khi thử, cũng không dùng số thử để kết luận toàn game đã chốt.

## 2. Tầm nhìn và vòng chơi

**Đã thống nhất:** Game Roblox lấy cảm hứng từ MHW, tập trung săn/bắt khủng long, nguyên liệu chế tạo, trang bị, sưu tầm và thể hiện chiến tích tại base cá nhân.

Vòng chơi dự kiến: chuẩn bị trang bị và pet → đi săn một mình hoặc theo đội → hạ gục/bắt giữ → nhận nguyên liệu và phần thưởng → nâng cấp → chọn chiến tích trưng bày → tiếp tục săn mục tiêu mới.

- Bắt giữ giúp sở hữu cá thể để sưu tầm và trưng bày.
- Người khác có thể tham quan base, xem khủng long, vũ khí và thành tích.
- Mục tiêu máy chủ mở tối đa 12 người; nhóm đi săn dự kiến 1–4 người. Chưa quyết định nhóm săn dùng chung bản đồ với sảnh hay có khu/phiên săn riêng.
- Chọn nhiệm vụ ở bảng trước khi vào map: săn thông thường cho phép tiêu diệt hoặc bắt mục tiêu; nhiệm vụ bắt sống yêu cầu bắt. Map có ba con để tự do săn, mục tiêu chính quyết định hoàn thành. Thời gian khoảng 40 phút; xem mục 20–21.
- Làm từng bản nhỏ có thể chơi và kiểm tra được; chưa xây toàn bộ nội dung cùng lúc.

## 3. Base, kho sưu tầm và lưu tiến trình

### Đã thống nhất

- Mỗi người có một base riêng.
- Kho sưu tầm tách khỏi phần trưng bày: có thể sở hữu nhiều hơn năm cá thể; trưng bày tối đa năm cá thể trong năm ống nghiệm.
- Tự chọn cá thể trưng bày, kể cả nhiều cá thể cùng loài nhưng khác màu/biến thể. Không bắt buộc một hệ hoặc một loài cho mỗi ống.
- Đổi cá thể trưng bày không làm mất cá thể cũ trong kho.
- Khủng long được thu nhỏ cho vừa ống; màu sắc, ngoại hình và hiệu ứng đặc biệt thể hiện sự khác biệt.
- Có một vị trí trưng bày **một vũ khí duy nhất** do chủ base chọn, trên tường hoặc vị trí phù hợp.
- Vũ khí nâng cấp cao, dùng nguyên liệu từ quái mạnh có thể có aura nhẹ.
- Lưu tiến trình và lựa chọn trưng bày theo tài khoản để dùng lại qua các lần vào game/máy chủ.

### Đề xuất để sảnh không quá lớn

- Kho là danh sách trong giao diện; không cần dựng phòng hoặc mô hình cho mọi cá thể đang sở hữu.
- Base dùng bố cục nhỏ: năm ống quanh tường, một chỗ vũ khí, vị trí giáp nếu bổ sung sau.
- Map hiện có đủ 12 base; L0 giữ bố cục này, thử tầm nhìn/đi lại và tải hiển thị trước khi mở cho 12 người thật.
- Nếu 12 base cùng sảnh quá chật/nặng, cân nhắc sảnh chung có lối vào base riêng. Chưa chốt phương án này.
- Chỉ cần lưu dữ liệu cá thể, vật phẩm và bố trí để dựng lại base; không cần lưu toàn bộ cảnh 3D.
- Lưu tiến trình thông thường và sao lưu/khôi phục khi lỗi là hai việc khác nhau; cần kiểm tra cả hai khi triển khai.

### Dữ liệu tối thiểu dự kiến phải lưu

- Cá thể sở hữu: mã riêng, loài, hệ, biến thể, màu, kích thước gốc và thông tin lần bắt cần thiết.
- Năm vị trí trưng bày tham chiếu tới các cá thể trong kho.
- Nguyên liệu, trang bị đã sở hữu, cấp nâng cấp, trang bị đang dùng và vũ khí được trưng bày.
- Pet, trang bị pet và thành tích săn.
- Bố trí base trong phạm vi cho phép; chưa thiết kế xây dựng base tự do.
- Cần thử thoát/vào lại, đổi máy chủ, lỗi lưu và nhận thưởng lặp; không hứa bảo toàn dữ liệu trước khi kiểm chứng.

**Chưa chốt:** dung lượng kho; sơ đồ sảnh/base; mức độ tùy chỉnh vị trí; hiển thị giáp; chính sách và cách khôi phục dữ liệu.

## 4. Loài, hệ và hình thái

### Đã thống nhất

- Tách **loài**, **hệ**, **cách di chuyển/hình thái** và **biến thể**; không xem rồng bay là đồng nghĩa với hệ rồng.
- Các hệ định hướng: **lửa, nước, sấm/điện, độc, rồng**. Ngoài ra có cá thể/loài **không hệ**.
- Khủng long hệ rồng có thể bay hoặc không bay. Các hệ khác cũng có thể có dạng đi bộ, bay, sống dưới nước.
- Một loài có thể có dạng không hệ và dạng có hệ; cách phân bố cụ thể chưa chốt.
- Dạng không hệ dễ săn hơn, cung cấp nguyên liệu cơ bản như xương, da, răng, vảy; không rơi lõi lửa hoặc nguyên liệu đặc trưng hệ tương tự.
- Nguyên liệu cơ bản vẫn là thành phần phụ để chế tạo/nâng cấp vũ khí có hệ, giúp người chơi kiếm phần nguyên liệu này nhanh hơn.
- Dạng có hệ là nguồn nguyên liệu đặc trưng cho vũ khí hệ tương ứng.
- Kỹ năng và cách đánh riêng của từng loài sẽ thiết kế trong phần riêng sau.

**Quy mô định hướng trước đó:** khoảng 1–2 loài mỗi nhóm khi mở rộng. Cần xác nhận lại số loài gốc, vì dạng không hệ và biến thể không nhất thiết là loài mới.

**Ví dụ minh họa:** Loài A không hệ → da/vảy/xương/nanh A. Loài A hệ lửa → có nguồn nguyên liệu lửa; công thức vũ khí lửa dùng nguyên liệu cơ bản cùng nguyên liệu hệ. Chưa xác định bảng rơi, công thức và tỉ lệ.

## 5. Hai loài giao chiến trong cuộc săn

### Yêu cầu đã thống nhất

- Chỉ kích hoạt giao chiến giữa hai loài khác nhau khi có trạng thái chiến đấu của người chơi được xác nhận; không tự cho chúng đánh nhau chỉ vì đứng gần ngoài cuộc săn.
- Trong giao chiến, cả hai vẫn có thể chuyển sang tấn công người chơi.
- Sát thương giữa quái làm giảm máu thực tế của mục tiêu, nhưng ở mức nhỏ để cuộc giao chiến kéo dài và tạo cơ hội bắt con đang yếu.
- Ví dụ người dùng: quái 1 có 100 máu, quái 2 đang bị săn còn 20 máu; một đòn giữa quái có thể gây 2–3 sát thương. Đây chỉ là ví dụ, chưa phải sát thương cố định hoặc phần trăm.

### Cần chốt trước khi lập trình

- Hai con cần cùng tham gia cuộc săn hay một con có thể đi ngang và tham gia?
- Điều kiện xác nhận chiến đấu, phạm vi phát hiện, thời gian duy trì và lúc kết thúc trạng thái.
- Cách chọn mục tiêu giữa người chơi và quái khác; thời gian giao chiến/tạm ngừng.
- Quái có được giết quái khác hay phải dừng ở một ngưỡng máu? Nếu giết được thì thưởng và nhiệm vụ xử lý thế nào?
- Sát thương của quái khác không tính thành đóng góp của người chơi; ngưỡng 10% chỉ tính sát thương người chơi và pet của họ theo mục 7.
- Sát thương nhỏ từng đòn vẫn có thể giết mục tiêu nếu đánh lâu; cần quyết định rõ, không mặc định rằng mục tiêu luôn sống để bắt.

**Phạm vi:** phát triển sau khi săn một quái, bắt giữ và nhận thưởng đã hoạt động ổn định.

## 6. Bắt giữ và phần thưởng

### Đã thống nhất

- Bắt quái còn sống khi máu **từ 10% trở xuống**: có dấu hiệu đi khập khiễng/chậm, đặt Iron Trap rồi dẫn quái vào, quái bị choáng cúi đầu, người chơi đến miệng cho uống thuốc ngủ. Công thức bẫy và giới hạn vật dụng ở mục 21; thời gian thao tác và điều kiện thất bại cụ thể chưa chốt.
- Bắt thành công nhận cá thể sưu tầm cùng nguyên liệu.
- Người dùng muốn **bắt nhận nhiều nguyên liệu hơn hạ gục**.
- **Số lượng nguyên liệu mặc định từ khủng long luôn là 1 đơn vị mỗi lượt rơi/mổ**, không phải 1 đơn vị cho toàn bộ cuộc săn. Loại nguyên liệu vẫn theo bảng rơi.
- Thưởng nguyên liệu khi bắt có **số lượt tương đương số lần mổ xác** của loại quái đó: 3/4/5 tùy loại. Áp dụng cơ chế tăng lượng đã nêu trên lượng gốc 1: **50% nhận 1, 50% nhận 2**, tính riêng từng lượt. Xem mục 20.
- Quy tắc mới thay ví dụ thưởng bắt ban đầu: không tự nhân đôi toàn bộ hoặc cộng thêm một gói thưởng bắt nữa lên các lượt đã tăng số lượng. Ngoại lệ tăng lượng cho nguyên liệu hiếm, nếu có, chưa được xác định.
- Khi đội bắt thành công, **mỗi người đủ điều kiện nhận một cá thể vào bộ sưu tập riêng**. Cách xác định điều kiện chi tiết và việc các bản cá thể có cùng màu/kích thước/biến thể chưa chốt.
- Loại nguyên liệu nhận có yếu tố ngẫu nhiên và có thể trùng qua nhiều lượt; tỉ lệ từng loại cần bảng riêng, số lượng gốc đã chốt là 1. Xác suất 50/50 tăng lượng khi bắt không phải xác suất rơi từng loại nguyên liệu.
- Sau lượt săn/bắt có bảng phần thưởng bổ sung: các loại xương như xương thường, cứng, mềm, rồng, hoặc vật phẩm khác để nâng vũ khí.
- Quy tắc không hệ không rơi nguyên liệu hệ phải áp dụng cả phần thưởng chính và bổ sung.
- Vật phẩm đã nhặt trong map, gồm vảy/đuôi và quặng đã đào, được giữ dù nhiệm vụ thắng hay thua. Việc giữ đồ đã nhặt không phụ thuộc hoàn thành mục tiêu; phạm vi ngưỡng 10% đối với quyền nhặt/mổ vẫn cần chốt.

### Đề xuất

- Mỗi người đủ điều kiện nhận phần thưởng cá nhân, tính ngẫu nhiên riêng; bảng thưởng trình bày rõ phần từ mục tiêu và phần bổ sung.
- Cho dạng không hệ rơi nguyên liệu cơ bản thường xuyên; sức mạnh vũ khí hệ vẫn yêu cầu săn nguồn nguyên liệu hệ.
- Đặt tên rõ cho thưởng bắt và thưởng hoàn thành để tránh vô tình nhân đôi nhiều lần.
- Chấp nhận bắt là phương án nhiều thưởng hơn theo ý người dùng; cân bằng bằng khâu chuẩn bị và thực hiện bắt. Không ép sửa thành hai cách có thưởng bằng nhau.

**Chưa chốt:** bảng loại nguyên liệu/xác suất và ngoại lệ tăng lượng với vật phẩm hiếm nếu có; ánh xạ từng nhóm quái với 3/4/5 lượt; ai được thao tác bắt; cách nhận thưởng bắt; xử lý hết chỗ kho. Đồ rơi trong map cần nhặt, quái bị tiêu diệt có thao tác mổ xác. Lượng mặc định từ khủng long là 1.

## 7. Săn đội, máu quái và điều kiện nhận thưởng

### Đã thống nhất

- Cho phép người mạnh săn cùng người mới.
- Mỗi người phải đạt ngưỡng **10%** để nhận thưởng. Sát thương đóng góp bằng **sát thương người chơi + sát thương pet của chính người chơi đó** lên mục tiêu săn; mẫu số dùng tính tỷ lệ còn cần chốt.
- **Hồi phục và các hành động hỗ trợ không cộng vào ngưỡng 10%.** Hồi phục là phần phụ của kỹ năng chiến đấu đồng hành, không thay thế yêu cầu gây sát thương.
- Máu quái tăng theo số thành viên 1, 2, 3, 4 để điều chỉnh độ khó.
- Ví dụ máu solo là 1.000; chưa chốt các mức máu đội. Không mặc định tăng tuyến tính.
- Mục tiêu là khuyến khích mọi người tham gia và chơi chung.

### Điểm cần cân bằng

- Nếu hiểu ngưỡng là 10% máu tối đa của quái sau điều chỉnh theo đội, cần ghi rõ trong giao diện và tính thống nhất.
- Người mạnh có thể kết thúc quá nhanh khiến người mới chưa đạt ngưỡng; tăng máu đơn thuần không giải quyết hết.
- Người dùng đã chọn chỉ tính sát thương của người chơi và pet; người chỉ hồi phục/hỗ trợ vẫn phải đạt ngưỡng sát thương để nhận thưởng. Không tự đổi sang điểm hỗ trợ khi cân bằng.
- Sát thương quái đánh nhau không thuộc sát thương của người chơi hoặc pet, nên không cộng vào đóng góp của thành viên.
- Nếu ngưỡng bắt là trước khi hết máu, tổng sát thương người chơi có thể gây sẽ thấp hơn máu tối đa; phải thử cùng quy tắc 10%.
- Cần xử lý người vào muộn, rời đội, mất kết nối và thay đổi số thành viên; tránh đổi máu/điều kiện tùy tiện giữa trận.
- Điều kiện thưởng nguyên liệu, cá thể bắt và hoàn thành nhiệm vụ có dùng chung một ngưỡng hay không chưa chốt.
- Quy tắc mới ở mục 20 bảo toàn vật phẩm đã nhặt khi thất bại; không tự tước lại đồ đã vào túi theo kết quả nhiệm vụ. Cần chốt riêng ngưỡng 10% áp dụng lúc nhặt/mổ và nhận thưởng cuối ra sao.

## 8. Cá thể hiếm, đột biến và trưng bày

### Đã thống nhất

- Người chơi tự do lựa chọn năm cá thể thể hiện cá tính; không khóa ống theo hệ/loài.
- Một loài gốc A có thể có nhiều chủng/biến thể: đột biến lửa, nguyên tố khác, thay đổi hình dạng như thêm gai và các ý tưởng sẽ phát triển tiếp.
- Có khác biệt về màu, kích thước và hiệu ứng; cá thể đặc biệt có ngoại hình/hiệu ứng nổi bật hơn trong ống nghiệm.
- Người dùng cho phép cùng phát triển thêm ý tưởng ở phần này; chưa chốt danh sách hoặc tỉ lệ hiếm.

### Đề xuất tổ chức

- Mỗi cá thể lưu các đặc điểm riêng thay vì dùng một nhãn hiếm duy nhất: loài gốc, hệ, đột biến, màu, kích thước.
- Phân biệt dạng hệ thông thường với đột biến hệ hiếm; không mặc định mọi quái có lửa là đột biến.
- Ngoại hình đặc biệt có thể nhận biết khi săn và giữ lại khi trưng bày.
- Có nhãn kích thước gốc vì mô hình đã thu nhỏ; giữ tương quan lớn/nhỏ trong giới hạn ống nếu phù hợp.
- Bản đầu chỉ một biến thể rõ nét; mở rộng sau khi chi phí làm mô hình/hoạt ảnh đã được kiểm chứng.

**Chưa chốt:** biến thể có đổi sức mạnh/kỹ năng hay chỉ ngoại hình; cách xuất hiện, xác suất, tổ hợp đặc điểm; cùng cá thể có giống nhau với mọi người trong đội không.

## 9. Vũ khí, giáp và thành tích

- **Đã thống nhất:** chỉ một vũ khí được chọn để trưng bày; có thể đổi; aura nhẹ cho các mốc nâng cấp phù hợp.
- **Hướng muốn phát triển:** trưng bày cả bộ giáp của người chơi. Chưa chốt số vị trí hoặc cách đặt.
- **Đã thống nhất:** phía trên ống nghiệm có thành tích săn nhanh nhất để thể hiện chiến tích cá nhân.
- **Đề xuất:** kỷ lục ghi rõ loài/biến thể, độ khó, solo/đội, bắt/hạ gục; không so chung các điều kiện khác nhau.
- **Cần chốt:** hiện thời gian bắt đúng cá thể trong ống hay kỷ lục tốt nhất của loài; thời điểm bắt đầu/kết thúc tính giờ.
- Đã có danh sách bảy loại vũ khí, trang bị khởi đầu và khung chiến đấu ở mục 18. Chuỗi đòn, công thức, cấp nâng cấp, chỉ số giáp và kỹ năng cụ thể từng vũ khí chưa chốt.

## 10. Pet khủng long đồng hành

### Đã thống nhất

- Người chơi có một pet khủng long nhỏ ngay khi mới vào game.
- Đây là thiết kế pet toàn game. Trong P1 chỉ làm theo chủ, đánh theo chu kỳ, gọi hồi và choáng; né/đỡ, chủ động thu hút quái, tự rút hồi và chế trang bị để sau P1 theo cấu hình thử mục 23.
- Pet hỗ trợ chiến đấu và hồi phục; là một hệ thống riêng với bộ sưu tập trong ống nghiệm. Chưa có yêu cầu biến mọi thú bắt được thành pet.
- Sát thương pet cộng vào đóng góp của chủ khi xét ngưỡng 10%; hồi phục chỉ là kỹ năng hỗ trợ, không cộng điểm nhận thưởng.
- Pet có ba mục trang bị: **vũ khí, mũ, giáp thân**; từng mục có thể chế tạo và trang bị.
- Pet có hai chế độ chính: **chiến đấu** và **về hồi máu cho chủ theo nút gọi**. Yêu cầu mới thay cách tự hồi khi chủ yếu máu trước đó; chưa có yêu cầu kết hợp thêm tự động.
- Pet chiến đấu có nhịp, không đánh liên tục; dùng vũ khí người chơi chế/trang bị và gây sát thương dựa trên chỉ số vũ khí. Có thể đỡ, thu hút chú ý của quái và né đòn cơ bản.
- Pet có máu riêng, khi gần hết máu có thể rút ra chỗ an toàn để tự hồi. Khi máu xuống **1**, pet **choáng bất động 30 giây**, không chết; hết thời gian hồi đầy máu và quay lại chiến đấu.
- Người chơi bấm nút gọi pet về hồi **70% máu tối đa của chủ**; pet mang viên thuốc lớn chạy đến, ném vào vùng đầu/miệng chủ. Màn hình có hồi chiêu; mốc **1 phút 59 giây (119 giây)** vẫn là thời gian đề xuất. Chi tiết chỉ số sẽ cân bằng khi làm game.
- Khi choáng, nút gọi hiện **“Pet đang hồi phục”** và thời gian choáng còn lại. Hồi đầy sau choáng không làm mới hồi chiêu kỹ năng hồi cho chủ.
- Khi chủ đang cho quái uống thuốc ngủ, pet tạm dừng đánh mục tiêu theo mục 21. Chi tiết hành vi và những điểm chưa chốt xem mục 22.

### Đề xuất cho bản thử

- Trạng thái tối thiểu: theo chủ → chiến đấu → hỗ trợ hồi phục → trở lại trạng thái phù hợp.
- Chia nhỏ: theo chủ và đánh theo chu kỳ trước, sau đó nối gọi hồi và choáng 30 giây trước bước thử bắt. Trang bị có thể chế, né/đỡ và tự rút lui để sau P1; xem phạm vi thử hiện hành ở mục 23–24.
- Cần xác định khoảng cách, thời gian thực hiện, thời điểm bắt đầu hồi chiêu, khả năng bị ngắt và xử lý chủ bị hạ gục. Lượng hồi đã đặt là 70% máu tối đa, kích hoạt bằng nút gọi.
- Kiểm tra hồi chiêu và tình trạng pet khi nhận lệnh, tránh bấm liên tục tạo nhiều lần hồi chồng nhau.

**Chưa chốt:** thời gian hồi chiêu cuối, thời điểm áp dụng hồi và các thông số chi tiết, ngưỡng/cách tự hồi của pet, đỡ/né/thu hút mục tiêu, loài pet, tác dụng mũ/giáp và cách xuất hiện ở base. Hồi chủ 70% máu tối đa, máu riêng và cơ chế 1 máu/choáng 30 giây đã chốt.

## 11. Lộ trình đề xuất và điều kiện hoàn thành

| Mốc | Phạm vi | Kiểm tra để qua mốc |
| --- | --- | --- |
| A — Săn thử | Một búa, một loài, khu nhỏ. P1-A/B làm người và quái; P1-C lần lượt thêm pet theo/đánh rồi gọi hồi/choáng | Đánh/né rõ ràng; pet cơ bản có đủ trước bước thử bắt P1-D |
| B — Vòng chơi đầu tiên | Suy yếu → bắt/hạ gục → nhận thưởng → một nâng cấp; kho, một ống, lưu tiến trình | Hoàn thành được cả lượt săn; thoát/vào vẫn giữ vật phẩm, cá thể và lựa chọn trưng bày |
| C — Định hình hệ thống | Dạng không hệ/có hệ, nguyên liệu cơ bản/đặc trưng; chiến đấu pet và ba ô trang bị tối thiểu | Nguồn nguyên liệu đúng; chế tạo/trang bị pet hoạt động; không nhận thưởng lặp |
| D — Base và cá thể | Năm ống tự chọn, màu/kích thước, một đột biến, một vũ khí trưng bày; giáp nếu đã chốt | Đổi trưng bày không mất thú; khách xem đúng; hiệu ứng không che thông tin |
| E — Săn đội | 2–4 người, điều chỉnh máu, điều kiện 10%, thưởng cá nhân nếu chốt, kỷ lục | Thử người mạnh/người mới, bắt sớm, rời đội và mất kết nối |
| F — Mở rộng | Giao chiến hai loài, thêm loài/hệ, bố trí máy chủ mục tiêu 12 người | Không phá cơ chế bắt/thưởng; kiểm tra tải với tối đa 60 cá thể trưng bày cùng pet và người chơi |

Các mốc A–F ở đây là lộ trình toàn game, khác các bước nhỏ P1-0 → P1-G ở mục 23. Không phải lịch hoặc cam kết thời gian. Cấu trúc dữ liệu và cách ghi giao dịch được chuẩn bị ở P1-0 bằng kho thử trong bộ nhớ; kết nối lưu tài khoản thật ở P1-F và kiểm tra lỗi tại P1-G. Không đợi đến cuối mới thiết kế dữ liệu, cũng không bắt người mới hoàn thiện DataStore ngay ngày đầu.

## 12. Quy tắc triển khai đề xuất

- Phân biệt rõ máy chủ 12 người với đội săn tối đa bốn người trong thiết kế.
- Sát thương, phần thưởng, sở hữu, đóng góp và thành tích cần được kiểm tra phía máy chủ khi lập trình.
- Không tạo toàn bộ mô hình trong kho ra thế giới; chỉ dựng các cá thể cần hiển thị.
- Kiểm tra tình huống đầy tải thay vì suy ra game chạy tốt chỉ từ số người cho phép.
- Khi làm đồ họa, ưu tiên nhận biết đòn đánh, cá thể và chiến tích; hiệu ứng phục vụ thông tin.
- Tra tài liệu Roblox hiện hành khi chọn giải pháp kỹ thuật cụ thể; tài liệu này mô tả thiết kế, chưa xác nhận hiệu năng hay API.
- Chưa thêm giao dịch, sinh sản, PvP, kiếm tiền, thế giới rộng hoặc hệ xây base tự do vào phạm vi đã chốt.

## 13. Những quyết định cần trao đổi tiếp

Ưu tiên gần cho P1: phạm vi nhỏ, nền tảng dữ liệu, cảm giác búa, AI một quái và quy trình bắt/thưởng. Mục 23–24 đưa ra cấu hình thử để kiểm tra; chưa có kết quả chơi thử.

Trước săn đội/giao chiến hai loài mới cần chốt mẫu số và phạm vi ngưỡng 10%, quái có được kết liễu nhau. Đã chốt đóng góp chỉ gồm sát thương người chơi và pet, không tính hồi phục/hỗ trợ; mỗi thành viên đủ điều kiện nhận một cá thể khi bắt. Những quyết định này chưa cản việc thử chiến đấu solo. Xem mục 24.5 về công thức đề xuất, không tự coi đó là quyết định đã chốt.

Sau đó: bố trí base/sảnh; chi tiết pet; thời gian cho uống và cách xử lý hành trang bắt ở mục 21; thời gian tính kỷ lục; danh sách loài và kỹ năng; biến thể và tỉ lệ; công thức trang bị. Hạn mức bẫy/thuốc theo số người đã chốt ở mục 21.

Không cần trả lời tất cả cùng lúc. Chỉ chốt phần cần cho mốc sắp làm.

## 14. Prompt dùng để tiếp tục công việc

> Hãy đọc THIET_KE_GAME.md trong thư mục dự án và dùng làm hồ sơ thiết kế hiện tại. Phân biệt yêu cầu đã thống nhất, đề xuất và phần chưa chốt. Tiếp tục từ mốc thực tế đã hoàn thành; đừng coi lộ trình là những gì đã được lập trình. Tôi là người mới: giải thích rõ từng bước. Khi tôi sửa ý tưởng, cập nhật mục liên quan và nhật ký quyết định, giữ những yêu cầu khác còn hiệu lực. Không tự đổi điều kiện thưởng, giới hạn trưng bày hoặc cơ chế pet. Với phần chưa chốt, hỏi điều thật sự cần trước khi làm phụ thuộc vào nó; vẫn tiếp tục phần độc lập. Sau mỗi mốc, ghi những gì đã làm, đã kiểm tra, hạn chế và việc tiếp theo vào chính tài liệu này.

Trạng thái hiện tại: **v2.4 có map H2, combat, Pet P1-C, nhiệm vụ/bắt P1-D, kinh tế P1-E và Inventory/Vật phẩm**, xem mục 33–35. Kho cá thể bắt sống P1-F đã thử bắt thực/giữ qua về sảnh và hồi sinh tại mục 36; Chế tạo trong Inventory tiếp tục chờ. Mở `HunDino/HunDino_DarkJungle_v2_4.rbxl`, đọc README/source và tiếp tục từ phần đang có; không dựng lại L0 hoặc ghi đè sửa map thủ công. P1-F còn phần trưng bày/lưu tài khoản; chỉ số thử không phải quyết định cuối, chưa có cảm ứng hoàn chỉnh. Chỉ đánh dấu hoàn thành sau khi có bằng chứng kiểm tra tương ứng.

## 15. Tiến độ và nhật ký

- **20/10/2026 — v0.39:** Đồng bộ 27 tài liệu Markdown hiện hành theo bản v2.4 đã lưu ngày 19/10. Cập nhật hướng dẫn mở bản Documents, trạng thái Pet/nhiệm vụ/kinh tế/kho cá thể và bảng đối chiếu map H2; phân biệt kết quả lịch sử với trạng thái mới. P1-F mới có kho cá thể trong cùng máy chủ, chưa ống/DataStore; Chế tạo trong Inventory, săn đội và nghiệm thu điện thoại còn chờ. Chỉ cập nhật tài liệu, không sửa source/map/backup/JSON và không chạy lại gameplay. Bảng tổng hợp ở mục 37.

- **19/10/2026 — v0.38:** Theo yêu cầu bắt đầu kho cá thể bắt sống, thêm Inventory → Khủng long, mã/số thứ tự/thời điểm riêng, xem 3D tĩnh và kho thử 100. Hồ sơ bộ nhớ v2 chuyển dữ liệu v1 không cấp lại tiền; một giao dịch bắt ghi cá thể cùng thưởng hiện có, chống lặp. Luật đạt 2.134 kiểm tra, preview native 4.858; Play bắt thực tạo đúng một con và giữ qua tự về sảnh/hồi sinh. Đã lưu native Studio. Mục Chế tạo trong Inventory, ống trưng bày và DataStore chưa làm trong bước này. Xem mục 36.

- **19/10/2026 — v0.35:** Triển khai P1-D trên v2.4: bảng nhiệm vụ J/G, lượt săn solo 40 phút, 3 bẫy/3 thuốc thử, B giữ 1 giây đặt bẫy, G giữ 3 giây bắt quái sống ≤10% HP trong bẫy. Ba lần chết đầu giữ lượt/HP/hạn, lần thứ tư thất bại; thành công có 120 giây xem hiện trường, ngày/đêm vẫn chạy tới khi về sảnh. Đã bắt sống trong Play, thử hồi sinh/thất bại và tự về sau 120 giây; bản lưu qua 139.055 kiểm tra. Xem mục 33; chưa triển khai mổ/nhặt/thưởng/kho cá thể/DataStore.

- **21/09/2026 — v0.1:** Tổng hợp trao đổi, tạo hồ sơ chung. Chưa có code hoặc bản game chạy được.
- Xác nhận năm ô trưng bày tự do, kho lớn hơn phần trưng bày; bỏ ràng buộc một hệ/một loài mỗi ống.
- Làm rõ hệ rồng tách khỏi khả năng bay; thêm dạng không hệ làm nguồn nguyên liệu cơ bản.
- Ghi yêu cầu giao chiến giữa hai loài trong cuộc săn, thưởng bắt cao hơn, sát thương tối thiểu 10% và máu tăng theo đội.
- Thêm pet có ngay từ đầu, hồi phục và ba mục trang bị; ghi hướng trưng bày giáp.
- **21/09/2026 — v0.2:** Ghi nhận phản hồi “ok” theo phương án vừa đề xuất: cộng thêm nguyên liệu khi bắt; mỗi thành viên đủ điều kiện nhận một cá thể vào kho riêng. Giữ các con số thưởng và quy tắc chi tiết ở trạng thái chưa chốt; các đề xuất khác chưa được tự động chuyển thành yêu cầu.
- **Bước hiện tại — 28/09:** phát triển sảnh/luyện tập L0 từ map có sẵn; đã kiểm tra tự động, chưa kiểm chứng bằng Play. Tiếp tục từ mục 25, chưa mở vòng săn P1.
- **21/09/2026 — v0.3:** Người dùng xác nhận ngưỡng 10% tính tổng sát thương người chơi và pet của họ. Hồi phục là phần phụ của kỹ năng đồng hành, không tính đóng góp nhận thưởng. Cập nhật đồng bộ phần săn đội, giao chiến giữa quái và pet; mẫu số tỷ lệ vẫn chưa chốt.
- **21/09/2026 — v0.4:** Rà soát mức độ sẵn sàng theo yêu cầu người dùng; thêm đánh giá ở mục 16. Không đổi các yêu cầu đã chốt, chưa triển khai game.
- **21/09/2026 — v0.5:** Nhận phần làm rõ điều khiển: PC và điện thoại, camera tự do, tấn công theo hướng di chuyển hoặc theo tâm ngắm. Thêm mục 17; chi tiết phím đã được thay thế bằng quyết định v0.8.
- **21/09/2026 — v0.6:** Người dùng đồng ý bổ sung góp ý điều khiển: đứng yên ở chế độ tự do giữ hướng di chuyển cuối; thả chuột phải về chế độ trước đó; cung ngắm cao/thấp theo tâm, cận chiến chủ yếu quay hướng trên mặt đất; điện thoại có nút bật/tắt ngắm. Bố trí nút, hỗ trợ ngắm và chi tiết từng vũ khí vẫn chưa chốt. Tiếp tục chờ các phần làm rõ khác.
- **21/09/2026 — v0.7:** Nhận phần vũ khí/chiến đấu: trang bị khởi đầu, bảy loại vũ khí, ba dạng hành động tấn công, đỡ khiên, dấu hiệu báo đòn, né lộn và lướt cung, hai trạng thái rút/cất, thể lực. Thêm mục 18; đánh dấu xung đột phím Shift và các thông số chưa chốt. Chưa lập trình, chưa tổng hợp toàn đợt.
- **21/09/2026 — v0.8:** Theo yêu cầu người dùng, loại bỏ sự phụ thuộc vào Shift Lock mặc định: PC yêu cầu tắt tính năng này trong cài đặt; Shift chạy, Ctrl ghim tâm riêng, chuột phải giữ ngắm, điện thoại có nút lock riêng. Chốt tự cất trước khi chạy, hồi thể lực theo trạng thái, buff cung một lần không cộng dồn và lướt lại chỉ làm mới thời gian. Thêm mục 19 về nghỉ sau đòn, đánh bộ phận, choáng/gục tăng dần và các phương án rụng đuôi. Các số minh họa và đề xuất cân bằng chưa phải thông số cuối.
- **21/09/2026 — v0.9:** Người dùng làm rõ cân bằng song dao/búa: song dao đánh nhanh nhưng sát thương mỗi đòn thấp hơn nhiều; búa có sát thương đòn/combo kỹ năng mạnh để bù tốc độ. Ghi định hướng này, không kết luận meta đã cân bằng khi chưa thử. Phân biệt sát thương với số lần quay xác suất rụng đuôi; chưa tự chọn phương án rụng đuôi hoặc thông số chống gục liên tục.
- **21/09/2026 — v0.10:** Làm rõ combo búa là chuỗi hành động mở ra combo/chiêu đặc biệt, không chỉ tổng các đòn độc lập. Ví dụ người dùng: thường → mạnh → thường → kỹ năng → kỹ năng. Ghi nguyên tắc và ví dụ, chưa khóa chuỗi cuối, thời gian nối hoặc hiệu ứng chiêu.
- **21/09/2026 — v0.11:** Nhận phần thắng/thua: bảng nhiệm vụ, một mục tiêu chính, ba quái trong map, khoảng 40 phút, giới hạn tử vong chung khi săn đội và hồi sinh ở điểm bắt đầu. Ghi bảo toàn đồ đã nhặt dù thua; mổ xác 3/4/5 lần tùy loại, bắt nhận số lượt tương đương và xét tăng lượng từng lượt. Đồng bộ mục 6/7, thêm mục 20; số lượng gốc làm rõ ở v0.12, mốc thất bại ở v0.13.
- **21/09/2026 — v0.12:** Người dùng sửa số lượng mặc định từ khủng long luôn là 1. Cập nhật mổ/rơi và ví dụ thưởng bắt: lượng gốc 1, cơ chế 50/50 giữ 1 hoặc tăng lên 2; số lượt 3/4/5 không đổi. Không áp quy tắc này sang quặng hoặc gói thưởng nhiệm vụ riêng chưa thiết kế.
- **21/09/2026 — v0.13:** Chốt thành công có 2 phút thu hoạch rồi tự về sảnh, hoặc chọn về sớm. Chốt chết quá ba lần: ba lần đầu hồi sinh ở điểm bắt đầu, lần tử vong thứ tư báo thất bại và cả đội về sảnh; tổng số lần tính chung đội. Thay các mô tả “ba mạng” dễ gây nhầm, giữ quy tắc bảo toàn đồ đã nhặt.
- **22/09/2026 — v0.14:** Nhận quy trình bắt: thương nhân bán Trap, kết hợp quặng sắt chế Iron Trap; quái còn sống và máu ≤10% đi khập khiễng; dẫn vào bẫy gây choáng/cúi đầu rồi cho uống thuốc ngủ. Giới hạn mang 3 Iron Trap và 3 bình ngủ, hết cơ hội bẫy không tự làm thua nhiệm vụ săn thông thường; nhiệm vụ bắt sống có điều kiện thất bại liên quan. Thêm mục 21, cập nhật điều kiện thắng theo loại nhiệm vụ; giới hạn theo người/đội và thời điểm thất bại cụ thể còn cần xác nhận.
- **22/09/2026 — v0.15:** Người dùng đồng ý pet của người cho uống tạm dừng đánh mục tiêu. Chốt choáng bẫy 13 giây, quái gầm gừ/rên nhẹ; ghi mốc cất vũ khí 1 giây và dự kiến chạy tới đầu khoảng 2 giây. Thời gian cho uống, cảnh báo gần hết bẫy và hạn mức vật dụng theo người/đội vẫn chưa chốt.
- **22/09/2026 — v0.16:** Nhận chi tiết pet: đánh có nhịp bằng trang bị, đỡ/thu hút quái/né cơ bản; tự rút hồi khi yếu; còn 1 máu thì choáng 30 giây, không chết, sau đó đầy máu tái chiến. Hồi cho chủ chuyển sang nút gọi có hiển thị hồi chiêu; 1:59 là mốc đề xuất, lượng hồi chưa chốt. Cập nhật mục 10 và thêm mục 22, giữ quy tắc pet ngừng đánh khi chủ cho uống thuốc ngủ.
- **22/09/2026 — v0.17:** Chốt hạn mức mỗi người theo số thành viên: solo 3 bẫy/3 bình, đội hai 2/2, đội ba hoặc bốn 1/1; giảm lượng mang dư trước khi vào map, sau trận chuẩn bị hành trang lại. Chốt nút báo pet đang hồi phục khi choáng và hồi đầy không làm mới kỹ năng. Pet hồi chủ 70% máu tối đa, chạy tới với viên thuốc lớn rồi ném vào vùng đầu; thông số/hoạt ảnh chi tiết bàn khi triển khai. Cách xử lý đồ dư trong kho vẫn cần xác định.
- **22/09/2026 — v0.18:** Người dùng chốt bẫy/bình ru ngủ mang vượt hạn mức được tự trả về kho trước khi vào map; không xóa hoặc tiêu hao phần vượt hạn mức. Quy tắc với đồ chưa dùng sau trận vẫn để bàn riêng.
- **22/09/2026 — v0.19:** Người dùng yêu cầu dừng mở rộng ý tưởng và chuyển sang thiết kế bản thử. Thêm mục 23: solo, PC kiểm tra trước, một búa có combo, một quái đi bộ không hệ, pet, săn/bắt, một nâng cấp và một ống trưng bày có lưu. Thông số mới là cấu hình thử của trợ lý; không chuyển các đề xuất cũ thành yêu cầu toàn game. Đã cập nhật trạng thái giai đoạn, chưa viết code.
- **27/09/2026 — v0.20:** Người dùng gửi đủ 12 ảnh góp ý và báo “xong”. Đối chiếu với file thực: mục 23 đã có trong v0.19, nhận xét thiếu mục này chỉ đúng với đoạn trích bị cắt. Thêm bảng trạng thái và mục 24; làm rõ vòng đời nhiệm vụ, tình huống bắt, ghi thưởng, kho/lưu, quyền máy chủ, nhịp búa, trạng thái AI và tiêu chí kiểm tra. Đề xuất đưa nền tảng dữ liệu lên P1-0 và giảm phần pet nâng cao trong P1. Không đổi yêu cầu đã chốt; thông số mới vẫn là cấu hình thử, chưa lập trình.
- **27/09/2026 — v0.21:** Nhận đủ đợt góp ý thứ hai: 12 ảnh, trong đó 12 mục nhận xét kèm phần ngoài phạm vi/kết luận. Đối chiếu với cả file vì người góp ý chỉ thấy đoạn cắt giữa mục 19. Sửa câu “chưa chọn vũ khí”; giữ bảng phím đang có; chia P1-0 → P1-G với tiêu chí hoàn thành từng bước. Đề xuất P1 bắt buộc PC, combo N → H → K kết thúc, một đòn quái; combo dài/đánh bộ phận/thêm đòn/nhiệm vụ bắt sống/điện thoại để sau P1. Dùng bộ nhớ thử trước, DataStore tại P1-F; bổ sung phân loại dữ liệu, mã thưởng theo lượt nhận và checklist hồi quy. Giữ pet hồi 70%, choáng 30 giây, bẫy 13 giây, chết thứ tư và đồ nhặt giữ khi thua. Không tự chốt góp ý thành yêu cầu toàn game; chưa viết code.

- **28/09/2026 — v0.22:** Người dùng chốt đổi 16 → 12 người, bắt đầu dự án và ưu tiên map/base + bãi luyện tập. Đọc HunDino1.rbxl hiện có: 12 base, 3539 đối tượng và script mẫu. Tạo bản sao nguyên vẹn, xuất bản phát triển L0.1 với source búa/giáp mẫu/hình nộm/pet cơ bản/cổng chuyển khu. Chín nhóm kiểm tra tự động đạt; thao tác Studio bị lỗi nên chưa xác nhận Play. Giữ P1 để nối sau; chưa mở hệ thống săn, thưởng hoặc lưu.

- **09/10/2026 — v0.23:** Đồng bộ hồ sơ với game v2.3: Dark Jungle 12 base, bãi tập lớn, bảy vũ khí/28 combo, thể lực còn 30%, lướt/camera cung, bốn UI và sửa đường TempleApproach. Thay trạng thái L0 cũ bằng kết quả đã thử Studio; phân biệt tính năng thử, phần chưa triển khai và việc chưa kiểm chứng. Giữ nguyên các quyết định toàn game còn mở.

- **15/10/2026 — v0.24:** Người dùng yêu cầu duyệt demo 3D khu săn trước khi dựng Roblox; thiên nhiên bí hiểm nhưng không quá tối. Chốt lấy giờ thực khi vào khu săn rồi tăng tốc 2 phút thật/giờ trong map từ khi bắt đầu nhiệm vụ. Chi tiết tại mục 26; bố cục và trang trí vẫn là đề xuất.

- **15/10/2026 — v0.25:** Người dùng yêu cầu mỗi khủng long có 8 khu để di chuyển qua lại: 3 khu hiện tại là khu chính, 5 khu còn lại là điểm đi qua/nghỉ chân. Mở rộng demo và ghi tại mục 26.4; bố trí 8 khu dùng chung là cách hiểu thử, chưa chốt lịch AI hoặc thời gian nghỉ. Chưa dựng vào Roblox.

- **15/10/2026 — v0.26:** Người dùng chỉ định vòng A → R2 → C → R3 → B → R4 → R5 → R1 → A, nghỉ ở điểm xuất phát, cho đảo chiều/đi nhánh ngắn B → R1 và áp dụng nhiều tuyến cho cả ba con. Bổ sung mạng đường và các tuyến xem thử tại mục 26.5; chưa triển khai AI trong Roblox.

- **15/10/2026 — v0.27:** Người dùng xác nhận “được tôi thấy rất ổn rồi” sau demo nhiều tuyến hai chiều. Ghi nhận duyệt phương án ý tưởng tại mục 26.6 để làm cơ sở dựng khung map; không coi kích thước thử, lịch AI hoặc hiệu năng đã được kiểm chứng.

- **16/10/2026 — v0.30:** Ghép Rừng cổ vào bản sảnh v2.3, nối menu/cổng G đi–về với Pet; clock riêng, hồi sinh/ra biên/hết giờ về sảnh. 188 kiểm tra Edit và Play đạt; 15.066 part gốc giữ nguyên, 34 script biên dịch. Xem mục 29 và HUNTING_LINK.md.
- **15/10/2026 — v0.29:** Bổ sung 360 cây, 150 cụm dương xỉ, 100 khối đá thành chín dải chia khu và nối con mẫu đi/nghỉ/đảo tuyến. Kiểm tra map 291/291, sáu vòng tuyến 148/148; xem mục 28. Mốc H1.0 được sao lưu trước sửa.
- **15/10/2026 — v0.28:** Theo yêu cầu bắt đầu tạo map sau khi có khủng long mẫu, dựng và lưu khung Rừng cổ H1.0 riêng bằng Studio. Có Terrain, 8 khu + trại, 13 đường quái hai chiều + hai đường trại, con mẫu giữ rig ở A, cây/đá/phế tích/nấm sáng và đồng hồ 30 lần. 288 kiểm tra live và Play đi lại đạt; chi tiết/giới hạn tại mục 27. Không ghi đè map sảnh hoặc place model gốc.

## 16. Đánh giá mức độ sẵn sàng — 21/09/2026

**Lưu ý cập nhật 28/09:** phần đánh giá dưới đây dành cho vòng săn. Ưu tiên triển khai đã chuyển sang sảnh/luyện tập L0 ở mục 25.

**Đánh giá của trợ lý:** định hướng đủ rõ để bước sang thiết kế bản thử; chưa đủ chi tiết để lập trình toàn bộ game. Cân bằng, độ vui và hiệu năng chưa thể xác nhận khi chưa có bản chơi được.

### Phần đã vững về định hướng

- Vòng săn/bắt → nhận nguyên liệu → chế tạo/nâng cấp → săn tiếp có mục tiêu liên tục.
- Bản sắc riêng nằm ở sưu tầm cá thể, năm ống tự chọn và base thể hiện chiến tích.
- Hệ/loài/hình thái đã được tách; nguồn nguyên liệu cơ bản và nguyên liệu hệ có vai trò khác nhau.
- Pet có từ đầu; đóng góp chỉ tính sát thương người chơi cộng pet, không tính hồi phục.
- Có lộ trình và phân biệt rõ quyết định với đề xuất.

### Phần có cấu hình P1 và việc cần kiểm chứng

| Quyết định | Nội dung cần làm rõ |
| --- | --- |
| Điều khiển và chiến đấu | P1 đã chọn búa, bảng phím PC, combo ngắn và chỉ số thử ở mục 23; cần kiểm chứng bằng chơi. Sáu vũ khí còn lại và điều khiển điện thoại để mốc sau |
| Một cuộc săn hoàn chỉnh | P1 một quái/nhiệm vụ săn thường; đã có luồng tại 24.3, cần thử vào/ra, hết giờ, chết thứ tư và kết thúc đồng thời. Ba quái/nhiệm vụ bắt sống để sau |
| Bắt giữ | Có cấu hình uống 3 giây và bảng thất bại tại 24.4; kiểm chứng bẫy 13 giây, ngắt thao tác, đồ tiêu hao và pet ngừng đánh |
| Pet tối thiểu | P1-C có theo/đánh, choáng 30 giây, gọi hồi 70%, hồi chiêu thử 119 giây; thử hành vi và UI. Tự rút hồi để sau P1 |
| Tiến trình đầu tiên | P1-E/F có công thức nâng, nguồn nguyên liệu, kho/ống/lưu; cần chơi và kiểm tra lỗi thực tế trước khi kết luận hoạt động |

### Phần cần chốt trước khi hoàn thiện săn đội

- Mẫu số của 10%: máu tối đa sau điều chỉnh theo đội hay đại lượng khác.
- Máu quái theo số người, vào/rời trận, đặc điểm cá thể trao cho cả đội.
- Quan hệ sảnh 12 người và khu săn 1–4 người.
- Giao chiến hai loài: việc kết liễu và ảnh hưởng tới nhiệm vụ/phần thưởng.

### Đề xuất thứ tự tiếp theo

- Tạm giữ phạm vi hệ thống hiện tại; tập trung thiết kế chiến đấu cho một vũ khí và một loài trước.
- Dùng mô hình đơn giản để kiểm tra cảm giác đánh, né, bắt và hồi phục; đầu tư hình ảnh sau khi vòng chơi hoạt động.
- Sau P1-G có thể thử đồng bộ cơ bản hai người trước khi mở rộng; săn đội đầy đủ thuộc mốc E của lộ trình toàn game. Đây là đề xuất hiện hành thay cách thử hai người ngay ở giai đoạn A/B trước đó.
- Chưa cần chốt mọi loài, hiệu ứng hoặc tỷ lệ hiếm để bắt đầu; cần kiểm chứng người chơi có muốn săn lại sau một lượt hay không.

Đối chiếu: Capcom mô tả vòng lặp MHW là thu nguyên liệu từ quái để làm trang bị phục vụ mục tiêu tiếp theo, cùng các hệ thống chuẩn bị, vũ khí và săn đội. Tham khảo: [Hướng dẫn MHW của Capcom](https://news.capcomusa.com/lets/browse/15-tips-on-playing-the-monster-hunter-world-beta). Các đánh giá và đề xuất bên trên dành riêng cho dự án này, không phải yêu cầu sao chép toàn bộ MHW.

## 17. Làm rõ từng phần — Điều khiển và hướng tấn công

**Trạng thái:** phần điều khiển nền tảng đã được ghi nhận. Các chi tiết chưa chốt giữ nguyên; cấu hình điều khiển rút gọn của bản thử ở mục 23.

### Điều khiển hiện hành — đã thống nhất

- Game chơi được trên **máy tính và điện thoại**. Người dùng định hướng trải nghiệm máy tính thuận tiện/hấp dẫn hơn; điều khiển điện thoại vẫn cần được thiết kế để chơi được.
- Góc nhìn tự do, không khóa vào mục tiêu.
- Có vũ khí cung; quy tắc hướng tấn công áp dụng cho tất cả vũ khí, kể cả cung. **P1 đã chọn búa** trong cấu hình thử; cung để mốc sau.
- Ở chế độ tự do thông thường, người chơi di chuyển bằng W/A/S/D theo hướng nào thì tấn công theo hướng đó.
- Trên PC, người dùng yêu cầu người chơi **tắt Shift Lock mặc định của Roblox trong cài đặt**. Game không dùng tính năng mặc định này để xác định hướng tấn công hoặc kích hoạt ngắm/buff cung. Đây là yêu cầu thiết kế; cách hướng dẫn/kiểm tra cài đặt sẽ xác minh khi triển khai.
- **Giữ Shift:** yêu cầu chạy nhanh; nếu đang rút vũ khí thì tự thực hiện hoạt ảnh cất trước khi chạy.
- **Nhấn Ctrl:** bật/tắt chế độ ghim tâm riêng của game, dùng hướng tâm giữa màn hình để tấn công.
- **Giữ chuột phải:** ngắm theo tâm, độc lập hướng di chuyển. Tính năng này được giữ theo xác nhận của người dùng, không dựa vào Shift Lock mặc định.
- Thả chuột phải trở về chế độ ghim tâm riêng nếu Ctrl đang bật; nếu không thì trở về tự do.
- Điện thoại có nút lock riêng để bật/tắt ghim tâm; vị trí nút và thao tác ngắm cung cụ thể chưa chốt.
- Đỡ khiên dùng nút riêng, không dùng chung chuột phải đã dành cho ngắm; phím cụ thể chưa chốt.

### Cách hiểu hiện tại

Hai cách xác định hướng: **theo hướng di chuyển** và **theo hướng tâm ngắm**. Chế độ ghim tâm Ctrl/nút lock và thao tác giữ chuột phải không tự khóa hoặc tự bám khủng long. Phân biệt ghim camera với trạng thái ngắm của cung; chưa mặc định chỉ bật Ctrl là đủ kích hoạt lướt ngắm/buff cung.

| Trạng thái | Hướng tấn công |
| --- | --- |
| Tự do, đang di chuyển | Theo hướng di chuyển của nhân vật |
| Ghim tâm riêng bật bằng Ctrl/nút lock | Theo hướng tâm giữa màn hình |
| Đang giữ chuột phải | Theo tâm ngắm, độc lập hướng di chuyển |
| Tự do, đứng yên | Giữ hướng di chuyển cuối; xoay camera quan sát không tự đổi hướng đánh |

### Góp ý đã được người dùng đồng ý

- Khi đứng yên ở chế độ tự do, giữ hướng nhân vật/hướng di chuyển cuối để xoay camera quan sát không tự đổi hướng đánh.
- Thả chuột phải không làm mất lựa chọn ghim tâm riêng đã bật bằng Ctrl.
- Với cung, cho hướng ngắm theo tâm có cả độ cao để bắn mục tiêu trên cao; với cận chiến, hướng tâm chủ yếu điều khiển hướng quay trên mặt đất. Không mặc định nhân vật nghiêng toàn thân theo camera.
- Điện thoại có nút **bật/tắt ghim tâm giữa màn hình**. Cần di chuyển, vùng vuốt camera, vị trí nút và cách vào trạng thái ngắm cung sẽ thiết kế sau; chưa chốt hỗ trợ ngắm tự động.

### Góp ý còn để thảo luận

- Đổi chế độ có dấu hiệu rõ trên tâm ngắm; tránh dùng hiệu ứng lớn che mục tiêu.

### Còn cần làm rõ

- Cung ở chế độ tự do (không dùng tâm ngắm) xử lý độ cao của hướng bắn thế nào; quy tắc đứng yên giữ hướng cuối đã chốt.
- Có được vừa đi vừa ra mọi đòn không; hướng đòn được chốt lúc bắt đầu hay còn đổi trong lúc ra đòn/kéo cung. Bàn cùng thiết kế vũ khí sau.
- Chuột phải có thay đổi góc camera/phóng gần không; ghim tâm bằng Ctrl có cùng hiệu ứng camera hay chỉ ghim hướng.
- Bố trí điều khiển điện thoại và việc người dùng có muốn hỗ trợ ngắm hay không.
- Trạng thái ngắm cung khi dùng Ctrl/nút lock: chỉ ghim tâm hay đồng thời ngắm vũ khí. Cần làm rõ trước khi gắn điều kiện buff cung; không tự bỏ cơ chế giữ chuột phải đã thống nhất.

## 18. Làm rõ từng phần — Trang bị, vũ khí và chiến đấu

**Trạng thái:** yêu cầu nền tảng đã được ghi nhận. Góp ý và câu hỏi bên dưới chưa tự trở thành quyết định. Vật dụng bắt giữ ở mục 21; cấu hình vòng săn P1 ở mục 23. Bãi tập hiện đã có bảy vũ khí/28 combo; cấu hình triển khai và phím hiện hành ở mục 25, chưa chốt cân bằng toàn game.

### Túi đồ và trang bị khởi đầu — đã thống nhất

- Chọn/trang bị giáp và vũ khí qua túi đồ.
- Người chơi mới được cấp một bộ giáp cơ bản với chỉ số khởi đầu để đi săn.
- Trong túi có bản cơ bản của **tất cả các loại vũ khí** thuộc danh sách hiện tại để người chơi lựa chọn.
- Cấp một lượng nhỏ vật phẩm tiêu dùng; loại, số lượng và cơ chế sẽ bàn riêng sau.
- Chưa chốt bộ giáp có những ô nào, vũ khí tự trang bị ban đầu, có đổi trang bị giữa cuộc săn hay không.

### Danh sách vũ khí hiện tại — đã thống nhất

| Loại | Ngoại hình và vai trò người dùng mô tả |
| --- | --- |
| Cung | Tấn công tầm xa; có né lướt khi ngắm và đòn đầu sau lướt được tăng sát thương |
| Kiếm thường + khiên tròn | Một bộ vũ khí; khiên đỡ đòn khủng long, tiêu hao thể lực và chịu ảnh hưởng tùy loại đòn |
| Kiếm dài / katana | Kiếm có vỏ; hoạt ảnh rút kiếm là một phần chuyển trạng thái |
| Thương/giáo cán dài (tên tạm) | Hình dáng tham chiếu vũ khí Quan Vũ; cần mẫu hình sau để xác định lưỡi đao và dáng cán đúng ý người dùng |
| Song dao | Hai dao, đánh nhanh; sát thương mỗi đòn thấp hơn nhiều so với búa; chưa thiết kế chuỗi đòn hoặc kỹ năng |
| Búa tạ | Đầu búa lớn, thân/cán to như khúc củi; chuỗi đòn kết hợp kỹ năng mở ra combo đặc biệt, là phần quan trọng của sức mạnh vũ khí; cần tạo cảm giác đòn đánh có lực |
| Rìu đại hai lưỡi | Hai mảng lưỡi ở hai bên; tấn công mượt, thiên về sức tấn công |

Danh sách trên là phạm vi định hướng game. **Bãi tập v2.3 đã có đủ bảy vũ khí, mỗi loại bốn combo** theo yêu cầu mới, xem mục 25. Kế hoạch vòng săn P1 tại mục 23 vẫn dùng búa để kiểm chứng với quái trước; sáu loại còn lại đã có mẫu luyện tập nhưng chưa được cân bằng/tích hợp vào săn.

**Định hướng cân bằng đã nêu:** song dao dùng nhiều đòn nhẹ; búa có sát thương mỗi đòn cao hơn và có chuỗi thao tác mở combo đặc biệt. Người dùng muốn cả hai có chỗ đứng trong cách chơi hiệu quả. Đánh giá búa phải xét cả khả năng thực hiện combo đặc biệt, không chỉ tốc độ và sát thương đánh thường. Chỉ số, thời gian combo, thể lực, khả năng đánh trúng và cơ hội ra đòn cần thử trước khi xác nhận cân bằng.

### Combo búa — nguyên tắc đã làm rõ, chuỗi cụ thể là ví dụ

- Kết hợp đánh thường, đánh mạnh và sử dụng kỹ năng theo chuỗi để thực hiện combo đặc biệt.
- Ví dụ người dùng: **đánh thường → đánh mạnh → đánh thường → kỹ năng → dùng kỹ năng lần nữa → combo đặc biệt**. Đây là minh họa cách hệ thống hoạt động, chưa phải chuỗi cuối bắt buộc.
- Cần ghi nhận tiến trình combo để phân biệt việc dùng kỹ năng trong chuỗi và dùng kỹ năng độc lập; không coi ví dụ là hai lần dùng cùng một chiêu độc lập chỉ cộng sát thương.
- Chưa chốt bước kỹ năng cuối tự biến thành chiêu kết thúc hay mở thêm hành động; không tự thêm lần bấm thứ sáu.
- Chưa chốt thời gian nối, có cần đánh trúng để tiến combo không, điều kiện ngắt/reset, tương tác né/cất vũ khí, thể lực và hồi chiêu.
- Chưa chốt số lần trúng, sát thương, tác động bộ phận hoặc khả năng gây choáng của chiêu đặc biệt; không mặc định chỉ có một hit.
- Các vũ khí khác sẽ thiết kế riêng; chưa áp dụng chuỗi ví dụ của búa cho toàn bộ vũ khí.
- Riêng P1 dùng cấu hình ngắn N → H → K kết thúc tại mục 23; các câu “chưa chốt” ở đây nói về thiết kế toàn game. Chuỗi năm lần bấm của v0.20 là phương án mở rộng sau khi chuỗi ngắn hoạt động, không còn là điều kiện hoàn thành P1.
- Tham khảo cấu hình dài v0.20 cho sau P1: N → H → N → K → K kết thúc, tổng 332 sát thương / 64 thể lực / 4,10 giây động tác nếu giữ các chỉ số đòn hiện tại. Không dùng các tổng này để kiểm tra combo ngắn P1.

### Khung hành động và đỡ đòn — đã thống nhất

- Mỗi vũ khí có **đánh thường, đánh mạnh, kỹ năng riêng**. Chưa chốt số kỹ năng, chuỗi đòn, phím bấm, hồi chiêu và sát thương.
- Khiên tròn đỡ được đòn khủng long; đỡ thành công mất thể lực.
- Đỡ đòn bắn lửa bị đẩy lùi. Chưa chốt đòn này có gây sát thương xuyên khiên hay hiệu ứng lửa không.
- Đỡ đòn mạnh vẫn mất một lượng máu nhỏ tính theo vài phần trăm máu tối đa; chưa chốt phần trăm, đẩy lùi hoặc giới hạn.
- Chưa chốt góc đỡ, đỡ đúng thời điểm, khả năng đỡ mọi loại đòn hoặc tình huống không đủ thể lực.

### Dấu hiệu báo đòn và né — đã thống nhất

- Khủng long có động tác báo trước để người chơi kịp né/đỡ. Ví dụ há miệng khoảng 1–2 giây rồi lao tới cắn; không mặc định mọi đòn hoặc mọi loài đều dùng thời gian này.
- Sau đòn có khoảng nghỉ để phản công; ví dụ nghỉ 5 giây sau đòn lao cắn. Phân biệt khoảng nghỉ này với trạng thái choáng/gục do đánh bộ phận ở mục 19.
- Né thông thường là lộn theo hướng di chuyển cuối cùng.
- Riêng cung, khi đang ngắm, né là lướt nhanh theo hướng di chuyển cuối cùng. Người dùng gọi là backstep nhưng mô tả cho phép lướt theo hướng, không mặc định chỉ lùi ra sau.
- Khi vừa giữ ngắm vừa lướt, **chỉ đòn tấn công đầu tiên của cung sau lướt** được tăng sát thương.
- Buff chỉ có một lượt sử dụng, không cộng dồn sát thương hoặc số lượt bắn. Hết thời gian thì mất; bắn phát đầu tiên thì tiêu thụ buff.
- Lướt hợp lệ thêm khi buff còn tồn tại chỉ **làm mới thời gian hiệu lực**, không cộng thêm thời gian vào thời lượng còn lại và không tăng mức buff. Giá trị thời lượng chưa chốt.
- Các trường hợp né còn lại dùng lộn. Ngắm/lướt/buff cung không phụ thuộc Shift Lock mặc định; điều kiện tương đương cho Ctrl và điện thoại còn cần làm rõ ở mục 17.
- Chưa chốt khoảng cách, thời lượng né, có thời gian miễn sát thương hay không, mức tăng sát thương và thời gian hiệu lực của đòn cung sau lướt.

### Hai trạng thái vũ khí — đã thống nhất

| Trạng thái | Hành vi |
| --- | --- |
| Rút vũ khí | Sẵn sàng chiến đấu; không chạy nước rút; muốn chạy nhanh phải trở về trạng thái cất |
| Cất vũ khí | Có thể giữ Shift để chạy nhanh; được dùng vật phẩm tiêu dùng và tương tác vật phẩm trên bản đồ/vật phẩm mang theo |

- Chỉ trạng thái cất vũ khí mới dùng vật phẩm tiêu dùng và thực hiện các tương tác vật phẩm nói trên.
- Đổi qua lại giữa hai trạng thái có độ trễ theo hoạt ảnh: lấy cung từ lưng, rút katana khỏi vỏ, cất vũ khí tương ứng.
- Người dùng đã nêu **cất vũ khí mất 1 giây** khi tính khoảng xử lý bắt giữ ở mục 21; thời gian rút và ngoại lệ theo từng loại vũ khí chưa được nêu riêng.
- Giữ Shift khi đang rút vũ khí tự yêu cầu cất; phải hoàn thành độ trễ/hoạt ảnh cất rồi mới chạy nhanh. Không bỏ qua hoạt ảnh để chạy ngay.
- Chưa chốt có né khi cất được không, có ngắt hoạt ảnh rút/cất hay dùng vật phẩm không, và đổi trạng thái trong lúc đang ra đòn xử lý thế nào.
- Đặt bẫy và dùng thuốc ngủ ở mục 21 tuân theo quy tắc dùng vật phẩm khi đã cất vũ khí; chưa có ngoại lệ được yêu cầu. Cần chốt có tự cất khi chọn dùng vật phẩm hay phải cất trước.

### Thể lực — đã thống nhất

- Dùng thể lực cho tấn công bằng vũ khí, né, chạy nhanh khi giữ Shift và đỡ bằng khiên.
- Chạy nhanh vừa dùng để di chuyển vừa là cách thoát đòn khủng long, nhưng vẫn tuân theo điều kiện trạng thái cất vũ khí.
- Khi cất vũ khí, thể lực hồi khi đã ngừng các hành động tấn công/chạy nhanh. Không mặc định hồi trong lúc đang chạy nhanh.
- Khi rút vũ khí, thể lực hồi sau khi dừng tấn công và né; không bắt buộc cất mới được hồi.
- Quy tắc hồi trong lúc giữ khiên/đỡ đòn và độ trễ trước khi bắt đầu hồi còn cần chốt.
- Chưa chốt thể lực tối đa, chi phí từng động tác, tốc độ/độ trễ hồi và hành vi khi không đủ thể lực.

### Góp ý để thảo luận

- Ánh xạ thêm phím đánh thường/đánh mạnh/kỹ năng/đỡ/né/rút cất chủ động, giữ nguyên Shift/Ctrl/chuột phải đã chốt.
- Hoạt ảnh, âm thanh và sát thương quái cần khớp với ba phần báo đòn → tấn công → nghỉ sau đòn đã thống nhất.
- Kiểm tra tình huống cạn thể lực vẫn có đường thoát, tránh người chơi bị kẹt trong chuỗi đòn không thể phản ứng.
- Cảm giác búa/rìu có lực nên đến từ hoạt ảnh, âm thanh, phản ứng trúng đòn và nhịp dừng ngắn phù hợp; cần thử để giữ được tính mượt mà mong muốn.
- Hệ thống trang bị khởi đầu cần tránh cấp lặp mỗi lần đăng nhập; chi tiết lưu và cấp phát sẽ xử lý khi triển khai.

### Việc cần làm rõ trước khi lập trình phần này

- Phím đỡ cho kiếm/khiên còn mở; P1 búa đã có Space né, E kỹ năng và xử lý giữ/thả Shift khi đang đánh/cất tại 24.10.
- Búa đã được chọn cho P1 và có phím/đòn/combo/chỉ số tại mục 23–24; việc tiếp theo khi triển khai là kiểm chứng cấu hình này, không chọn lại vũ khí. Các vũ khí còn lại giữ trong lộ trình.
- Thể lực P1 đã có cấu hình ở mục 23; đỡ thiếu thể lực và hồi khi giữ khiên cần thiết kế trước khi thêm kiếm/khiên.
- Điều kiện ngắm cung giữa chuột phải, chế độ ghim tâm Ctrl và điện thoại; buff có mất khi cất/đổi vũ khí hoặc ngừng ngắm không.
- Búa P1 dùng chốt hướng/đi chậm/không hủy động tác tại 24.10; các vũ khí khác sẽ thiết kế riêng.

## 19. Làm rõ từng phần — Nghỉ sau đòn, bộ phận và choáng/gục của boss

**Trạng thái:** thiết kế bộ phận cho toàn game đã được ghi nhận; P1 v0.21 chỉ có một đòn cắn và máu tổng, chưa làm gục đầu/chân/đuôi. Các số bên dưới là ví dụ hoặc cấu hình mở rộng, không phải yêu cầu hoàn thành P1.

### Nhịp tấn công — đã thống nhất

- Đòn boss có ba phần: báo trước → thực hiện đòn → nghỉ/hồi sau đòn để người chơi phản công.
- Ví dụ đòn lao cắn: há miệng khoảng 1–2 giây, lao cắn, sau đó có thể nghỉ khoảng 5 giây.
- Trong khoảng nghỉ, người chơi có thể tấn công liên tục trong giới hạn hành động/thể lực của mình.
- Chưa chốt mọi đòn có khoảng nghỉ bao lâu, boss có di chuyển/phòng thủ trong khoảng nghỉ không, và thời gian hồi chiêu từng kỹ năng khác thời gian nghỉ thế nào.

### Tấn công bộ phận — đã thống nhất

- Boss có các vùng riêng, ví dụ đầu, chân trái, chân phải, cánh, đuôi; danh sách tùy hình thể loài.
- Tích đủ sát thương vào từng bộ phận có thể kích hoạt phản ứng của quái.
- **Đầu:** gây choáng đứng.
- **Chân:** gây gục nằm.
- Trong lúc choáng/gục, người chơi có cơ hội tiếp tục tấn công; sau đó boss phục hồi và chiến đấu tiếp.
- Thời gian mất khả năng hành động tăng theo số lần kích hoạt: ví dụ lần đầu 1 giây, lần hai 2–3 giây, các lần sau lâu hơn. Chưa có công thức hoặc mức trần.
- Phản ứng cụ thể khi đánh cánh chưa được thiết kế.
- Chưa chốt số lần tăng thời gian tính chung toàn boss hay riêng đầu/chân/từng bộ phận; không tự coi hai trường hợp là tương đương.

### Đuôi và nguyên liệu — yêu cầu cùng các phương án chưa chọn

- Đánh vào đuôi có thể làm đuôi rụng; người chơi nhặt làm nguyên liệu nâng cấp vũ khí.
- Người dùng đưa **hai phương án thay thế**, chưa chọn cách cuối:
  - Theo xác suất khoảng **2–30%**. Giữ nguyên số người dùng viết; chưa rõ xác suất tính mỗi đòn trúng hay mỗi lần đạt ngưỡng bộ phận.
  - Sau khoảng **2–3 lần đạt ngưỡng/gây gục do đánh đuôi** thì rụng.
- Chưa chốt phản ứng của đuôi trước khi rụng, mức sát thương yêu cầu, loại vũ khí có thể làm rụng, cách chia phần nhặt cho đội và đòn quét đuôi thay đổi sau khi mất đuôi.
- Điều kiện cất vũ khí để nhặt vật phẩm trong mục 18 vẫn áp dụng, trừ khi người dùng thay đổi sau.
- Đuôi đã nhặt được giữ kể cả khi thất bại theo mục 20; ngưỡng 10% có giới hạn quyền nhặt trước đó không vẫn cần chốt, không tự tước vật phẩm đã nhặt khi thua.

### Đề xuất cân bằng — chưa tự áp dụng

- Giữ **máu tổng** và **tiến độ tác động từng bộ phận** thành hai giá trị riêng. Một đòn giảm máu tổng một lần đồng thời ghi nhận tiến độ vào đúng bộ phận, tránh vô tình trừ hai lần sát thương vào máu tổng.
- Thời gian choáng/gục có thể tăng như người dùng muốn nhưng nên có mức trần. Sau mỗi lần, có thể tăng ngưỡng gây gục hoặc có khoảng chống gục lại ngắn khi đứng dậy, tránh boss bị giữ nằm liên tục đến chết.
- Cần quyết định cách ghi nhận sát thương bộ phận khi boss đang gục: vẫn trừ máu nhưng không tự kéo dài vô hạn trạng thái gục đang có.
- Với đuôi, có thể dùng ngưỡng tích lũy sát thương hoặc xác suất như các phương án đã nêu. Nếu chọn cùng xác suất cố định mỗi lần trúng, số lần trúng sẽ ảnh hưởng số cơ hội; cần xét cả đòn thường và toàn bộ combo đặc biệt của từng vũ khí. Chưa biết số hit/hiệu ứng combo búa nên không kết luận song dao có lợi hơn về rụng đuôi hoặc chiến đấu tổng thể. Phương án cuối chưa chốt.
- Mỗi boss chỉ cho rụng đuôi và tạo phần thưởng đuôi một lần; cách chia cá nhân cho đội bàn riêng để tránh tranh nhặt. Đây là đề xuất, chưa chốt.
- Cân bằng thời gian nghỉ sau đòn cùng thời gian choáng/gục và sát thương đội bốn người; tránh boss mất gần hết thời gian chiến đấu vì liên tục bị khống chế.

Phương án số của v0.20 được giữ để tham khảo **sau P1**, chưa bật trong bản đầu:

- Đầu tích 250 gây choáng đứng, chân tích 300 gây gục; lần lượt 1 → 2 → 3 giây, trần 3, đếm riêng đầu/chân; mỗi lần ngưỡng tăng 25%.
- Trong choáng/gục và 2 giây sau đứng dậy không tích tiến độ gục mới, vẫn nhận sát thương máu.
- Lao cắn: báo 1,5 giây, gây 30, nghỉ 5 giây. Quét đuôi: báo 1,2 giây, gây 22, nghỉ 2 giây. Cần cân bằng lại khi thêm, không coi số này đã được chơi thử.

### Việc cần làm rõ khi triển khai cơ chế này

- Chọn phương án rụng đuôi; nếu dùng xác suất, chốt sự kiện được quay xác suất.
- Ngưỡng từng bộ phận và ảnh hưởng số người; sát thương pet/quái khác có góp vào ngưỡng không.
- Quy tắc tăng và giới hạn thời gian choáng/gục, ngắt hoặc nối tiếp trạng thái khi nhiều bộ phận đồng thời đủ ngưỡng.
- Điều kiện bắt hiện là còn sống, máu ≤10%, trúng Iron Trap và được cho uống thuốc ngủ ở mục 21. Choáng/gục do bộ phận không tự thay thế điều kiện trúng bẫy.

## 20. Làm rõ từng phần — Nhiệm vụ, thắng/thua và giữ chiến lợi phẩm

**Trạng thái:** yêu cầu toàn game được giữ bên dưới; nhiệm vụ săn thường solo đã có trong **P1-D tại mục 33**, dùng đồ thử, chưa có thưởng/kho/lưu. Không tự lấp các điểm chưa chốt bằng quy tắc của MHW; cấu hình dùng thử được tách ở mục 23–24.

### Nhiệm vụ và bản đồ — đã thống nhất

- Trước khi vào map, chọn ở bảng nhiệm vụ; mục tiêu chính là một loài khủng long. Có nhiệm vụ săn thông thường và nhiệm vụ yêu cầu bắt sống.
- Map có **ba con khủng long** để người chơi tự do săn; chưa xác định chúng nhất thiết thuộc ba loài khác nhau hoặc có hồi sinh/thay thế không.
- **Nhiệm vụ săn thông thường:** tiêu diệt hoặc bắt thành công mục tiêu chính đều thắng. Săn con khác không tự thay thế mục tiêu chính; hết bẫy vẫn có thể tiếp tục tiêu diệt mục tiêu.
- **Nhiệm vụ bắt sống:** phải bắt được mục tiêu chính. Hết khả năng bắt theo giới hạn vật dụng là điều kiện thất bại người dùng nêu; xử lý khi đội còn vật dụng và khi lỡ giết mục tiêu xem mục 21.
- Thời gian cho một nhiệm vụ dự kiến **khoảng 40 phút**; chưa chốt chính xác thời điểm bắt đầu đếm hoặc cách xử lý hết giờ.
- Chu kỳ sáng/tối khu săn khởi tạo từ giờ thực và tăng tốc **2 phút thật = 1 giờ trong map** từ lúc bắt đầu nhiệm vụ; xem mục 26. Đồng hồ môi trường không làm ngắn thời lượng nhiệm vụ hoặc thu hoạch.

### Giới hạn tử vong và hồi sinh — đã thống nhất

- Solo được tiếp tục sau ba lần tử vong đầu tiên; **lần tử vong thứ tư thì thất bại**.
- Khi đi đội, tổng tử vong tính **chung cả đội**, không phải riêng từng người và không tăng theo số thành viên.
- Ba lần tử vong đầu: thành viên vừa chết hồi sinh ở điểm bắt đầu map, cuộc săn tiếp tục.
- Lần thứ tư: báo nhiệm vụ thất bại, **cả đội quay về sảnh**; không bắt đầu thêm một lượt chiến đấu sau lần hồi sinh thứ tư.
- Ví dụ A chết hai lần, B chết một lần: tổng ba, nhiệm vụ vẫn tiếp tục. Bất kỳ ai chết thêm một lần: tổng bốn, cả đội thất bại.
- Không gọi quy tắc này là “chết ba lần thua” hoặc “ba mạng tính cả mạng ban đầu”.
- Chưa thiết kế cứu người trước khi chết; không mặc định cơ chế cứu đã có hoặc bị cấm.

### Sau thành công và quay về — đã thống nhất

- Hoàn thành mục tiêu chính **đúng điều kiện loại nhiệm vụ** sẽ mở **2 phút (120 giây)** để thu hoạch/mổ xác/nhặt đồ trước khi rời map. Tiêu diệt không được tính thắng nhiệm vụ bắt sống.
- Hết 2 phút tự động quay về sảnh; có lựa chọn quay về sớm.
- Chưa chốt lựa chọn về sớm áp dụng riêng người chọn hay cả đội; không tự cho trưởng đội đưa mọi người về.
- Thất bại do lần tử vong thứ tư: báo thất bại và về sảnh; khoảng thu hoạch 2 phút được quy định cho thành công, chưa có yêu cầu áp dụng cho thất bại.
- Vật phẩm đã nhặt vẫn được giữ theo quy tắc bên dưới.

### Vật phẩm đã nhặt — đã thống nhất

- Trong lúc chiến đấu có xác suất rơi vảy; đuôi có thể rụng theo cơ chế sẽ chốt ở mục 19.
- Map có quặng xuất hiện để người chơi đào lấy vật phẩm; vị trí, số lượng và tái xuất hiện chưa chốt.
- **Toàn bộ vật phẩm đã nhặt được mang về dù nhiệm vụ thắng hay thua**, gồm vảy, đuôi, quặng và đồ đã thu vào túi khác.
- Quy tắc này bảo toàn đồ đã nhặt; chưa quy định tự thu gom những món còn nằm dưới đất lúc kết thúc.
- Không đồng nhất đồ đã nhặt với gói thưởng hoàn thành chưa nhận; phần thưởng thất bại và thành công cần trình bày rõ.

### Tiêu diệt và mổ xác — đã thống nhất

- Khi tiêu diệt thành công, người chơi được mổ xác để lấy nguyên liệu.
- Giới hạn mổ là **3, 4 hoặc 5 lần**, tùy loại thường/có hệ/biến dị. Người dùng chưa chỉ định rõ bảng ghép nhóm với số lượt; không tự khóa thường = 3, có hệ = 4, biến dị = 5.
- Mỗi lượt mổ nhận **1 đơn vị** của nguyên liệu được chọn theo bảng rơi. Loại vật phẩm có thể trùng; ví dụ hai lượt cùng ra da thì tổng là 2 da.
- Chưa chốt số lần mổ là riêng mỗi người hay chung xác, giới hạn thời gian mổ, và điều kiện 10% để được mổ.

### Bắt giữ và lượt thưởng tương đương — đã thống nhất

- Bắt thành công nhận nguyên liệu qua **số lượt tương đương giới hạn mổ của loại quái đó**: 3/4/5 lượt; không mổ xác con còn sống.
- Số lượng cơ bản mỗi lượt là **1**. Theo cơ chế tăng lượng khi bắt đã nêu: **50% nhận 1, 50% nhận 2**, xét riêng từng lượt.
- Ví dụ bốn lượt cơ bản là 1 răng, 1 da, 1 da, 1 vảy; khi bắt có thể nhận 2 răng, 1 da, 2 da, 1 vảy, hoặc may mắn cả bốn lượt đều được 2.
- Không dùng một kết quả 50/50 cho toàn bộ gói và không tăng thêm số lượt khi lượng một lượt được tăng.
- Đây là cơ chế tăng lượng của thưởng bắt, không cộng chồng một gói “thưởng bắt thêm” chưa được định nghĩa. Phần thưởng hoàn thành bổ sung như xương ở mục 6 vẫn là phần riêng cần bảng cụ thể.
- Quy tắc lượng gốc 1 áp dụng nguyên liệu từ khủng long; xác suất rơi loại hiếm khác xác suất tăng lượng. Không tự mở rộng sang quặng hoặc gói thưởng nhiệm vụ bổ sung chưa thiết kế.
- “May mắn” đang chỉ kết quả ngẫu nhiên; chưa có yêu cầu thêm chỉ số Luck hay trang bị tăng xác suất.
- Quy tắc nhận cá thể cho mỗi người đủ điều kiện khi bắt vẫn giữ nguyên. Chưa chốt cá thể bắt từ quái phụ được giữ thế nào nếu sau đó nhiệm vụ chính thất bại.

### Góp ý để thảo luận

- Hiển thị rõ tổng tử vong **của cả đội**, mốc thất bại là lần thứ tư, thời gian nhiệm vụ và mục tiêu chính; tránh người chơi hiểu thành giới hạn riêng mỗi người.
- Sau thắng, hiển thị đếm ngược 2 phút và lựa chọn về sớm để người chơi biết thời gian còn lại cho thu hoạch.
- Bảng kết quả phân biệt đồ đã thu trong map, nguyên liệu mổ/thưởng bắt và thưởng hoàn thành; tránh tạo cảm giác mất đồ khi nhiệm vụ thất bại.
- Hết thời gian mà chưa hoàn thành mục tiêu thì thất bại là phương án đề xuất, cần người dùng xác nhận.

### Còn cần chốt

- Xử lý hết 40 phút và thứ tự khi thắng/chết/hết giờ xảy ra gần đồng thời; đã chốt mốc thất bại do tử vong ở lần thứ tư.
- Trong 2 phút sau thắng có tiếp tục săn quái phụ được không; tử vong còn tính hay có thể đảo kết quả thành công không; đồng hồ nhiệm vụ 40 phút có còn tác động không.
- Lựa chọn về sớm áp dụng riêng từng người hay cả đội; giữ thưởng và số lượt mổ còn lại khi chọn về sớm thế nào.
- Phần thưởng quái phụ, mổ xác trước khi nhiệm vụ chính kết thúc, giữ cá thể bắt phụ khi thua và cách áp dụng đóng góp 10% theo từng con.
- Số lượt mổ/thưởng bắt cụ thể theo nhóm; bảng nguyên liệu, quyền nhặt/mổ theo người và điều kiện nhận thưởng bổ sung.
- Xử lý rời nhiệm vụ chủ động/mất kết nối; chưa mặc định giống thắng hoặc thua thông thường.

## 21. Làm rõ từng phần — Thương nhân, chế bẫy và bắt sống

**Trạng thái:** bắt sống thử đã được lập trình và kiểm chứng trong **P1-D tại mục 33**; thương nhân/chế bẫy/thưởng bắt có ở **P1-E mục 34**. Kho cá thể bộ nhớ P1-F đã thử bắt thực và giữ qua sảnh/hồi sinh ở mục 36; chưa có ống trưng bày hoặc lưu tài khoản. Các thông số thiếu vẫn để mở cho toàn game, cấu hình thử ở mục 23–24.

### Thương nhân và chế tạo — đã thống nhất

- Có thương nhân bán hàng, ví dụ bình hồi máu và vật dụng tên **Trap**.
- Mua Trap, kết hợp quặng sắt nhặt/đào được để chế **Iron Trap**, là bẫy dùng bắt khủng long.
- Phân biệt Trap mua làm thành phần chế tạo với Iron Trap đã hoàn thiện; chưa chốt tên hiển thị tiếng Việt.
- Công thức định tính: **Trap + quặng sắt → Iron Trap**; chưa chốt số lượng nguyên liệu, giá tiền, nơi/thời gian chế.
- Thuốc ngủ/bình ru ngủ là vật dụng bắt riêng; nguồn mua/chế và công thức chưa được người dùng chỉ định.
- Chưa mở rộng thiết kế các vật phẩm tiêu dùng khác ngoài thông tin đã nêu.

### Quy trình bắt — đã thống nhất

1. Vào chiến đấu và đánh mục tiêu đến khi **còn sống, máu ≤10%**. Chưa quyết định hiển thị con số máu cho người chơi.
2. Dấu hiệu nhận biết: khủng long đi chậm, kéo lê/khập khiễng một chân.
3. Người chơi đặt **Iron Trap** và dẫn đúng con muốn bắt vào bẫy.
4. Trúng bẫy, khủng long bị choáng **13 giây**, gầm gừ/rên nhẹ và **cúi đầu xuống** để người chơi tiếp cận miệng.
5. Người chơi dùng **thuốc ngủ, đổ vào miệng** qua thao tác/hoạt ảnh; đây không phải tự bắt ngay khi chạm bẫy hoặc ném thuốc từ xa. Khi bắt đầu cho uống, **pet của người thực hiện tạm dừng tấn công mục tiêu**.
6. Hoàn tất bắt thì xử lý cá thể sở hữu và nguyên liệu theo mục 6/20; số liều và điều kiện hoàn tất thao tác cần chốt.

Đặt bẫy/cho uống là dùng vật phẩm nên tuân theo trạng thái cất vũ khí ở mục 18. Mức máu đủ bắt không thay thế bước bẫy và thuốc; gục do bộ phận cũng không tự thay thế bẫy.

### Thời gian xử lý và pet — đã thống nhất

- Thời gian choáng/giữ mục tiêu của Iron Trap là **13 giây tính từ lúc quái trúng bẫy**, không phải thời gian bẫy nằm trên đất chờ quái.
- Trong trạng thái này, quái cúi đầu và gầm gừ/rên nhẹ. Chưa chốt tín hiệu riêng báo sắp hết thời gian, không tự thêm đồng hồ hiển thị.
- Người dùng dành khoảng **1 giây cất vũ khí + khoảng 2 giây chạy đến đầu**, còn khoảng 10 giây để thao tác và xử lý tình huống. Hai giây di chuyển là ước lượng tùy khoảng cách, không phải hoạt ảnh kéo người chơi tới đầu.
- Thời gian cho uống cụ thể chưa chốt; 10 giây còn lại không mặc định là thời gian bắt buộc giữ nút.
- Pet của người cho uống tạm dừng đánh đúng mục tiêu từ lúc chủ bắt đầu thao tác; không mặc định toàn bộ pet/người chơi trong đội tự ngừng tấn công.
- Chưa chốt lúc pet đánh lại nếu thao tác bị ngắt hoặc bẫy hết hiệu lực; bắt thành công thì không còn tấn công cá thể đã bắt.

### Giới hạn và thất bại — đã thống nhất về nguyên tắc

- Giới hạn **mỗi người**, xác định theo số thành viên đội khi vào map:

| Số người | Iron Trap mỗi người | Bình ru ngủ mỗi người | Tổng bẫy / tổng bình tối đa của đội |
| --- | --- | --- | --- |
| 1 (solo) | 3 | 3 | 3 / 3 |
| 2 | 2 | 2 | 4 / 4 |
| 3 | 1 | 1 | 3 / 3 |
| 4 | 1 | 1 | 4 / 4 |

- Mang dư thì hệ thống tự giảm số lượng được mang vào map về hạn mức và **trả toàn bộ phần dư về kho trước khi vào map**. Phần dư không bị xóa hoặc tiêu hao.
- Xong trận người chơi **trang bị/chuẩn bị lại vật dụng cho lượt sau**. Không có yêu cầu tự cấp miễn phí số đã dùng hoặc tháo toàn bộ vũ khí/giáp.
- Dùng hết số Iron Trap được mang thì người đó không còn bẫy để tiếp tục bắt; solo thất bại ba bẫy là hết bẫy. Chưa có cơ chế hoàn trả/tái sử dụng bẫy được chốt.
- Giới hạn cơ hội đến từ lượng vật dụng mang theo; không thêm bộ đếm thất bại độc lập ngoài lượng vật dụng.
- Với nhiệm vụ săn thông thường, hết bẫy hoặc bắt thất bại không tự kết thúc nhiệm vụ; có thể tiếp tục săn/tiêu diệt. Giới hạn tử vong và thời gian vẫn áp dụng.
- Với nhiệm vụ bắt sống, mất hết khả năng bắt là lý do thất bại theo yêu cầu người dùng. Chưa chốt thời điểm báo thua nếu chỉ một người hết bẫy trong khi đồng đội còn bẫy/thuốc.
- Chưa chốt lúc trừ bẫy/thuốc, thời gian bẫy đặt trên đất chờ mục tiêu, bẫy đặt hụt có thu lại được không, và một lần bắt cần bao nhiêu bình. Thời gian giữ quái sau khi kích hoạt đã chốt là 13 giây.

### Góp ý để thảo luận

- Có thể đánh dấu vị trí tương tác ở miệng và dùng thay đổi âm thanh/hoạt ảnh khi gần hết 13 giây để dễ đọc tình huống; đây là góp ý chưa chốt, không mặc định thêm thanh đếm ngược.
- Quái bay/dưới nước cần dấu hiệu suy yếu và tư thế trúng bẫy phù hợp hình thể; thiết kế đi khập khiễng/cúi đầu hiện phù hợp bản thử quái đi bộ.
- Tránh cho chế thêm hoặc tiếp tế trong map vượt giới hạn cơ hội bắt đã định; cần chốt quy tắc mang Trap thô/quặng, chế tại map và quay trại trước khi triển khai.
- Nhiệm vụ bắt sống nên báo thất bại nếu mục tiêu bị giết; đây là đề xuất xử lý kết thúc, còn yêu cầu đã chắc chắn là giết không được tính thắng.
- Hạn mức cá nhân đã chốt; đề xuất nhiệm vụ bắt sống không thua chỉ vì một người hết khi đồng đội vẫn có thể bắt. Cách kết luận thất bại toàn đội chưa chốt.
- Đề xuất hiển thị số vật dụng được mang và số đã trả kho trước khi vào map. Việc trả phần dư về kho đã chốt, chỉ cách thông báo còn là đề xuất.

### Cần làm rõ trước khi triển khai

- Có được đặt bẫy giúp và cho uống giúp nhau không; cách xử lý vật dụng chưa dùng sau trận và việc vào/rời đội có làm đổi hạn mức không. Phần vượt hạn mức trước khi vào map đã chốt trả kho.
- Thời gian đặt bẫy và cho uống; điều kiện ngắt, tiêu hao khi thất bại và lúc pet trở lại chiến đấu. Thời gian giữ quái đã chốt là 13 giây.
- Điều gì được tính bẫy thất bại: hết thời gian, quái thoát, sai con đi vào, máu chưa đủ thấp hoặc thao tác thuốc bị ngắt.
- Quái trên 10% máu có bị bẫy giữ tạm thời không; có thể dùng thuốc sớm không; nếu quái hồi máu thì kiểm tra điều kiện lúc nào.
- Nguồn thuốc ngủ, số liều, giá/công thức và giới hạn tiếp tế/chế trong cuộc săn.
- Cách kết thúc nhiệm vụ bắt sống khi hết vật dụng hoặc mục tiêu chết, trong khi bảo toàn đồ đã nhặt theo quy tắc chung.

## 22. Làm rõ từng phần — Chiến đấu và hồi phục của pet

**Trạng thái:** phần pet đã được ghi nhận. Hai chế độ chính là chiến đấu và hồi cho chủ; rút lui, tự hồi, choáng là tình trạng bên trong. Cấu hình pet bản thử ở mục 23.

### Chế độ chiến đấu — đã thống nhất về hành vi

- Pet lao vào tham gia nhưng **không tấn công liên tục**; có nhịp hành động như một đồng hành chiến đấu.
- Cầm vũ khí do người chơi chế tạo hoặc trang bị; sát thương dựa trên chỉ số vũ khí. Chưa chốt công thức và hệ số riêng của pet.
- Có thể đỡ đòn, thu hút sự chú ý của khủng long và né các đòn cơ bản. Chưa chốt tần suất, điều kiện, khả năng đỡ theo vũ khí hoặc cách quái chọn mục tiêu.
- Pet có máu riêng. Khi gần hết máu, có thể tự chạy ra vùng an toàn để hồi cho bản thân; ngưỡng rút, vùng an toàn, lượng hồi và thời gian tự hồi chưa chốt.
- Sát thương pet vẫn cộng vào đóng góp của chủ cho ngưỡng 10%; đỡ, né và hồi không được quy thành sát thương.

### Khi pet còn 1 máu — đã thống nhất

- Khi máu xuống **1**, pet bị choáng **30 giây**, không cử động và không chết.
- Không tiếp tục chiến đấu hoặc di chuyển về chủ trong lúc bất động.
- Hết 30 giây, pet **hồi đầy máu** rồi tái giao tranh.
- Trong lúc choáng, nút gọi hồi báo **“Pet đang hồi phục”** cùng thời gian choáng còn lại; không thể gọi pet thực hiện hồi trong lúc bất động.
- Hồi đầy sau choáng **không làm mới hồi chiêu kỹ năng hồi cho chủ**. Theo dõi riêng thời gian choáng và hồi chiêu kỹ năng.
- Pet không chết nên lần choáng này không phải một lần tử vong của người chơi trong bộ đếm thất bại chung.
- Cần triển khai để đòn sát thương lớn không vượt qua mốc 1 và làm chết pet trái thiết kế. Chưa chốt phản ứng khi tiếp tục bị đánh trong lúc choáng; không tự cho kéo dài/reset 30 giây.

### Chế độ hồi máu cho chủ — đã thống nhất và thông số đề xuất

- Có **nút gọi pet về hồi máu**. Đây là kích hoạt chủ động; thay mô tả cũ tự hồi khi chủ yếu máu.
- Màn hình hiển thị thời gian hồi chiêu của lần hồi cho chủ.
- Người dùng đề xuất khoảng **1 phút 59 giây = 119 giây** cho mỗi lần; ghi là mốc thử, chưa khóa thành thông số cuối.
- Lượng hồi cho chủ là **70% tổng máu tối đa**, không phải 70% máu đang thiếu. Các chỉ số cụ thể sẽ thống kê/cân bằng lúc làm game.
- Khi nhận lệnh, pet mang một **viên thuốc rất lớn**, chạy/lao tới chủ và ném thuốc vào miệng. Về hình ảnh, chỉ cần ném tới vùng đầu người chơi, không cần hoạt ảnh miệng chi tiết.
- Chưa chốt thời gian chạy/ném, thời điểm cộng máu, hồi một lần hay theo thời gian, phạm vi, ngắt khi bị tấn công và lúc bắt đầu đếm hồi chiêu.
- Tự hồi của pet, hồi đầy sau choáng và kỹ năng hồi cho chủ là ba cơ chế khác nhau; không tự dùng chung hồi chiêu hoặc lượng hồi.

### Liên hệ với bắt giữ — giữ nguyên quyết định trước

- Khi chủ bắt đầu cho mục tiêu uống thuốc ngủ, pet của chủ tạm ngừng đánh mục tiêu đó.
- Chưa chốt có nhận lệnh gọi hồi trong lúc chủ đang cho uống không, hoặc phải chờ hoàn thành/hủy thao tác; không tự ngắt việc bắt của người chơi.
- Pet khác trong đội chưa có quy tắc tự ngừng theo chủ đang bắt.

### Góp ý để thảo luận

- Đề xuất giới hạn máu sau hồi ở máu tối đa, không tạo máu vượt trần; ví dụ tối đa 100, đang 20 thì hồi thêm 70 thành 90, đang 60 thì hồi tới 100.
- Thu hút chú ý nên có thời lượng/giới hạn, không mặc định pet giữ mục tiêu mãi khiến chủ không cần né/đỡ.
- Kiểm tra khả năng hồi khi pet đang tự rút lui: cần chọn ưu tiên rõ giữa tự bảo toàn và lệnh chủ; không tự quyết trước khi người dùng làm rõ.

### Còn cần chốt

- Xác nhận mốc hồi chiêu 119 giây; thời gian gọi về/ném, thời điểm cộng 70% máu tối đa và lúc bắt đầu hồi chiêu.
- Ngưỡng pet tự rút, lượng/tốc độ tự hồi, điều kiện quay lại và hành vi nếu không tìm được chỗ an toàn.
- Ưu tiên lệnh gọi khi pet đang đánh, đỡ, né, tự hồi hoặc bị choáng; có xếp lệnh chờ hay yêu cầu gọi lại không.
- Quái có tiếp tục chọn pet đang choáng không; sát thương nhận khi choáng có tác động tới đồng hồ hay không.
- Trang bị pet ảnh hưởng máu/phòng thủ/khả năng hồi thế nào; chỉ sát thương theo vũ khí đã được nêu.

## 23. Thiết kế bản thử đầu tiên — cấu hình thử P1

**Thứ tự mới ngày 28/09:** hoàn thiện và chơi thử sảnh/luyện tập L0 ở mục 25 trước. Nội dung P1 dưới đây là bước nối tiếp; những phần búa/điều khiển/pet đã làm ở L0 được tái sử dụng sau khi kiểm chứng.

**Cập nhật trạng thái 20/10:** bản v2.4 đã có P1-D nhiệm vụ/bắt (mục 33), P1-E mổ/nhặt/thưởng/kinh tế (mục 34), Inventory/Vật phẩm (mục 35) và kho cá thể P1-F bước đầu (mục 36). P1-F còn một ống và lưu tài khoản; P1-G chưa nghiệm thu. Các bảng phạm vi/thông số P1 dự kiến giữ để tham khảo; phím dùng bảng đã cập nhật dưới đây, chỉ số triển khai xem mục 25/30/32–37.

### Mục tiêu, hai mốc kiểm tra và phạm vi

**Yêu cầu giai đoạn:** dừng mở rộng hệ thống lớn, làm một bản nhỏ để kiểm chứng săn/bắt và cảm giác chiến đấu. **Mọi lựa chọn rút gọn/thông số mới dưới đây là đề xuất cấu hình thử của trợ lý**, chưa phải quyết định cuối toàn game.

- **P1 tối thiểu — xong P1-0 đến P1-D:** trên PC có thể điều khiển, đánh/né, dùng pet và tiêu diệt/bắt một quái. Chỉ là mốc kiểm chứng chiến đấu/bắt; chưa có đủ tiến trình kinh tế, trưng bày và lưu qua lần thoát.
- **P1 đầy đủ — xong P1-0 đến P1-G:** thêm thưởng, nâng búa, cá thể, kho, một ống và lưu tài khoản đã kiểm tra. Chỉ mốc này mới được gọi là hoàn thành P1.
- **Hai nền tảng:** game đầy đủ vẫn phải chơi được trên PC và điện thoại. Cấu hình P1 hiện đề xuất chỉ bắt buộc chuột/bàn phím; cảm ứng hoàn chỉnh để mốc tiếp theo. Thiết kế hành động độc lập với phím để sau đó gắn nút điện thoại; phải thử lại UI/camera/nhắm/né khi thêm cảm ứng.

| Phần | Làm trong P1 đầy đủ | Để sau P1 |
| --- | --- | --- |
| Người chơi | Solo trên PC | Săn đội 2–4 người, kiểm tra đóng góp 10%, điện thoại hoàn chỉnh |
| Vũ khí | Một búa, ba dạng đòn, combo ngắn N → H → K kết thúc, một cấp nâng | Chuỗi búa dài, sáu loại còn lại, đỡ khiên và ngắm/lướt cung |
| Quái | Một loài đi bộ không hệ, tên tạm A, một đòn cắn có báo trước/nghỉ | Thêm đòn, đầu/chân gây gục, đuôi, ba quái/map, quái giao chiến, hệ/biến thể |
| Pet | Theo chủ, đánh theo chu kỳ, máu riêng/choáng 30 giây, gọi hồi 70% | Né/đỡ, chủ động thu hút quái, tự rút hồi, chế/trang bị pet |
| Nhiệm vụ | Săn thường: tiêu diệt HOẶC bắt mục tiêu đều thắng; trại, đồng hồ, tử vong và thu hoạch | Nhiệm vụ chỉ được bắt sống; bản đồ nhiều mục tiêu |
| Tiến trình/base | Kho, thương nhân, chế bẫy, một nâng cấp, một ống tự chọn, lưu | Năm ống, tham quan base, trưng bày vũ khí/giáp và kỷ lục hoàn chỉnh; sảnh 12 base làm trước ở L0 |
| Hình ảnh | Khối/hoạt ảnh đơn giản, đọc được báo đòn, hướng đánh, trúng đòn, khập khiễng/cúi đầu | Hiệu ứng và mô hình hoàn thiện |

Không xóa yêu cầu toàn game khi đưa chúng ra ngoài P1. Nhiệm vụ bắt sống, nhiều đòn và ngưỡng gục từng có trong cấu hình v0.20 nay là phương án sau P1; không bật âm thầm trong các bước đầu.

### Quy tắc nền tảng giữ nguyên

- Tắt Shift Lock mặc định; Shift chạy, Ctrl ghim tâm riêng, chuột phải giữ ngắm. Tự cất đủ 1 giây trước khi chạy; hướng tự do theo hướng di chuyển/hướng cuối khi đứng yên.
- Đánh/né/chạy tiêu hao thể lực. Dùng vật phẩm và tương tác vật phẩm khi đã cất vũ khí.
- Quái còn sống, máu ≤10% mới được bắt; đi khập khiễng. Iron Trap giữ 13 giây, cúi đầu; người đến miệng cho uống. Pet chủ dừng đánh từ lúc bắt đầu cho uống.
- Solo mang tối đa 3 bẫy + 3 bình; phần dư trả kho. Mỗi lượt chuẩn bị hành trang lại.
- Ba lần chết đầu hồi sinh; lần thứ tư thất bại. Giữ đồ đã nhặt khi thua. Thành công có 120 giây thu hoạch hoặc chọn về sớm.
- Nguyên liệu quái gốc 1/lượt; bắt quay độc lập 50% lượng 1 hoặc 50% lượng 2 mỗi lượt.
- Pet hồi 70% máu tối đa; còn 1 máu thì bất động 30 giây rồi đầy máu. Hồi đầy không làm mới hồi chiêu kỹ năng; nút báo “Pet đang hồi phục”.

### Một lượt chơi khi P1 đầy đủ

1. Vào base, tải hồ sơ và nhận đồ đầu một lần; chọn búa, xem kho/pet.
2. Mua Trap/thuốc, lấy sắt trong lượt săn nếu cần, chế Iron Trap ở base; chọn đồ mang. Không cần bẫy để vào săn thường.
3. Nhận nhiệm vụ săn A tại bảng; kiểm tra hành trang và vào trại. Bắt đầu đồng hồ khi nhân vật sẵn sàng điều khiển.
4. Né đòn cắn, phản công bằng búa/combo, gọi pet hồi; tiêu diệt hoặc dẫn quái yếu vào bẫy rồi cho uống.
5. Ghi kết quả một lần: tiêu diệt mở ba lượt mổ; bắt nhận ba lượt nguyên liệu và một cá thể. Có gói thưởng nhiệm vụ riêng.
6. Thu hoạch 120 giây hoặc về sớm. Nếu thua, về với đồ đã nhặt. Đồ mang chưa dùng trả kho theo cấu hình thử.
7. Nâng búa/chọn cá thể vào ống; sau xác nhận lưu, thoát/vào vẫn có tiến trình.

### Bảng phím PC hiện hành v2.4 — cập nhật 20/10/2026

| Thao tác | Hành động |
| --- | --- |
| WASD / chuột | Di chuyển / camera |
| Chuột trái | Đánh thường N |
| Q | Đánh mạnh H |
| E | Kỹ năng K; đúng chuỗi thì thành chiêu kết thúc |
| Space / V | Lướt / nhảy |
| R | Rút/cất vũ khí |
| Giữ Shift / Ctrl / giữ chuột phải | Chạy / bật-tắt ghim tâm / ngắm theo hướng tâm |
| H | Gọi Pet hồi máu |
| G / giữ B | Tương tác/nhặt/mổ/cho uống / đặt bẫy; F giữ khiên khi dùng kiếm & khiên |
| I / J | Inventory / bảng nhiệm vụ tại sảnh |

Bảng trên thay cấu hình phím dự kiến v0.20: Q mạnh, R rút/cất, H gọi Pet, G tương tác và B đặt bẫy. v2.4 kế thừa cả bảy vũ khí/28 combo; cung giữ chuột phải ngắm, chỉ chuột trái tụ lực, Q mạnh ngay. Bản nhiệm vụ vẫn một lượt solo với một T-Rex. UI có hỗ trợ nút cảm ứng ở một số thao tác nhưng chưa nghiệm thu điện thoại. Các bảng búa/quái P1 dự kiến bên dưới là cấu hình thiết kế 27/09; thông số triển khai mới đọc mục 25/30/32–36 và bảng tổng hợp 37, không cài ngược số cũ.

### Búa và combo ngắn dùng thử

P1-A làm từng đòn độc lập trước, rồi mới nối **N → H → K**. Khi đúng hai bước N → H, lần K tiếp theo chính là chiêu kết thúc; ngoài chuỗi K là kỹ năng thường. Chuỗi dài **N → H → N → K → K** giữ làm phương án sau P1 theo ý tưởng tại mục 18.

| Hành động | Sát thương gốc | Thể lực | Tổng động tác |
| --- | ---: | ---: | ---: |
| N — vung ngang | 36 | 8 | 0,55 giây |
| H — bổ búa | 70 | 16 | 1,10 giây |
| K thường — hất búa | 50 | 12 | 0,70 giây |
| K kết thúc — nện đất | 140 | 20 | 1,20 giây |

- Nối đòn trong 1 giây từ lúc động tác trước hết; không bắt buộc trúng để tiến chuỗi, vẫn phải trúng để gây sát thương. Không nhận nút đòn mới khi đang trong động tác; chưa làm hàng đợi nút.
- Bấm sai thì thực hiện đòn độc lập hợp lệ và reset chuỗi; nếu nút đó là N thì bắt đầu lại từ N. Thiếu thể lực không ra đòn, không tiến chuỗi.
- Né, cất, chết, ngắt hành động hoặc quá thời gian nối thì reset. Bị trừ máu nhẹ không tự reset nếu không bị ngắt.
- P1 cho mỗi đòn chạy hết động tác trước khi né/đánh tiếp, chưa làm hủy thu đòn. Khóa hướng từ đầu pha gây sát thương. Phân chia pha/vùng trúng ở 24.10.
- Combo ngắn trúng đủ ba đòn: **246 sát thương, 44 thể lực, tối thiểu 2,85 giây** chưa tính khoảng nối. Đây là tổng lý thuyết, không phải tốc độ gây sát thương thực tế.
- Chưa có hồi chiêu riêng của K trong cấu hình thử; thời gian động tác, thể lực và chuỗi giới hạn việc lặp.

### Người chơi, quái và pet dùng thử

| Thành phần | Cấu hình P1 |
| --- | --- |
| Người chơi | 100 máu; giáp đầu cố định, sát thương quái dưới đây là lượng thực nhận |
| Thể lực | Tối đa 100; hồi 20/giây sau 0,75 giây không tiêu hao |
| Né / chạy | Né tốn 20, dài 0,55 giây, thử miễn sát thương 0,15 giây giữa động tác; chạy tốn 10/giây, cạn thì đi thường |
| Rút / cất | Rút thử 1 giây; cất 1 giây theo yêu cầu đã nêu |
| Quái A | 2.400 máu; đủ bắt khi 0 < máu ≤240; không tự hồi máu |
| Một đòn cắn | Báo 0,8 giây → cửa sổ gây 18 sát thương dài 0,30 giây → nghỉ 1,5 giây; mỗi đòn trúng mỗi nạn nhân tối đa một lần |
| Pet cơ bản | 100 máu; đánh 12 mỗi 4 giây trong tầm thử 6 studs; đồ cố định |
| Gọi pet hồi | Tới cách chủ khoảng 3 studs, ném thuốc trong 0,8 giây; hồi 70% máu tối đa, không vượt trần; hồi chiêu thử 119 giây từ khi máu được hồi |

Trong P1 quái nhận sát thương máu tổng, chưa có tích ngưỡng đầu/chân hoặc gục do bộ phận. P1-B chỉ làm một đòn cắn; các phương án quái đầy đủ tại mục 19 để sau. Pet làm ở P1-C theo thứ tự theo/đánh → máu/choáng → gọi hồi; P1-D nối ngừng đánh khi cho uống. Pet choáng không bị kéo dài/reset do đòn mới; chủ hồi sinh không làm mới hồi chiêu pet. Chi tiết tại 24.12.

### Bắt, kết thúc và tiến trình

- Công thức thử: 1 Trap + 1 sắt → 1 Iron Trap, chỉ chế ở base. Đặt 1 giây; xong mới trừ bẫy, không thu lại; chưa kích hoạt thì tồn tại 60 giây.
- **Giữ lựa chọn v0.20:** quái trên 10% vẫn có thể mắc bẫy 13 giây, nhưng không được cho uống/bắt. Đây là cấu hình thử, không lấy ví dụ “trên 10% không kích hoạt bẫy” trong ảnh làm thay đổi mặc định.
- Giữ tương tác 3 giây tại miệng để cho uống; hoàn tất khi quái vẫn sống/đủ ngưỡng/bẫy còn hiệu lực mới trừ một bình. Bị ngắt thì không trừ bình, đồng hồ bẫy vẫn chạy. Xem 24.4.
- P1 chỉ săn thường: hết bẫy/thuốc vẫn được tiếp tục tiêu diệt. Nhiệm vụ bắt sống và quy tắc hết khả năng bắt được giữ ở mục 21/24.4 cho mốc sau P1.
- Hết 40 phút chưa hoàn thành thì thua. Hoàn thành khóa kết quả và chuyển sang 120 giây thu hoạch; không đổi thành thua do chết sau đó. Thao tác kết thúc sau hạn không tính thành công; đúng hạn thì thử ưu tiên kết quả hợp lệ.
- Quái cho ba lượt mổ, mỗi lượt 1,5 giây và lượng gốc 1. Bắt cho ba lượt chọn loại rồi xét lượng 1/2 độc lập, không có xác để mổ.
- Loại nguyên liệu thử: da 50%, răng 25%, vảy 25% mỗi lượt; gói hoàn thành riêng là 1 xương thường + 40 xu. Thua không có gói này nhưng giữ đồ đã nhặt.
- Sáu điểm quặng/lượt, mỗi điểm 1 sắt, không tái tạo. Vật rơi thử giữa trận theo 24.6, không cần cơ chế đánh bộ phận.
- Thương nhân bán Trap 10 xu, thuốc ngủ 10 xu. Hồ sơ mới nhận 80 xu một lần; bình hồi khác để sau, hồi P1 dùng pet.
- Búa cấp 2 cần 2 xương + 2 sắt, sát thương tăng 15%. Không thu phí vào săn; hết xu vẫn săn thường/đào quặng để tiến triển.
- Mỗi lần bắt tạo cá thể A có mã riêng, chưa biến thể. Một ống tham chiếu cá thể trong kho; đổi không mất cá thể cũ.
- Trước P1-F dùng dữ liệu kiểm tra trong bộ nhớ, hiển thị rõ không lưu qua lần thoát; không dùng để đánh giá đã có lưu bền vững. P1-F kết nối lưu hồ sơ thật trong môi trường thử riêng; P1-G kiểm tra lỗi và hồi quy.

### Thứ tự thực hiện — không bắt đầu đồng thời tất cả

| Bước | Làm ở bước này | Chưa đưa vào | Điều kiện qua bước |
| --- | --- | --- | --- |
| P1-0 | Kiểm tra Studio, project/cấu trúc thư mục, định nghĩa dữ liệu, kho thử trong bộ nhớ và giao diện đọc/ghi có thể thay thế | DataStore thật, UI đẹp, bản đồ hoàn thiện | Dữ liệu thử khởi tạo được; cùng mã giao dịch chỉ áp một lần trong phiên; biết rõ dừng phiên thì mất dữ liệu thử |
| P1-A | Nhân vật, camera/phím, búa N/H/K, né/thể lực, mục tiêu đứng yên; nối combo ngắn sau khi từng đòn ổn | AI đuổi/đánh, pet, bẫy, thưởng thật | Rút/cất đúng; từng đòn chỉ trừ máu một lần; đúng N/H/K mới ra kết thúc; không đánh/né khi thiếu thể lực |
| P1-B | AI một quái: phát hiện, đuổi, báo/cắn/nghỉ, chết, trở về khi mất mục tiêu | Đầu/chân/đuôi, nhiều đòn/quái, bẫy, hệ/biến thể | Quái có báo đòn/nhịp nghỉ; né được; chết thì không gây sát thương tiếp; mắc kẹt không làm reset máu hoặc tạo quái mới |
| P1-C | Pet theo/đánh trước, rồi máu/choáng và gọi hồi | Né/đỡ/thu hút, tự rút hồi, chế đồ pet | Pet không đánh xuyên tường; hồi không vượt trần; choáng đúng 30 giây, độc lập hồi chiêu 119 giây thử |
| P1-D | Lượt săn thường, quái yếu, bẫy/thuốc, bắt, chết thứ tư, hết giờ/thu hoạch; dùng vật dụng thử | Nhiệm vụ chỉ bắt sống, kinh tế/cá thể lưu lâu dài | Đúng điều kiện mới bắt; ngắt/hết bẫy xử lý đúng; khóa kết quả một lần; pet dừng đánh khi cho uống |
| P1-E | Mổ/nhặt/thưởng có mã, thương nhân/chế bẫy, kho nguyên liệu, nâng búa | Cá thể trưng bày, DataStore thật, bảng rơi phức tạp | Chơi hai lượt trong phiên để nâng; thua giữ đồ nhặt; gửi lại yêu cầu không nhân đồ; hết xu vẫn đi săn được |
| P1-F | Cá thể/kho/một ống; thay lớp kho thử bằng lưu tài khoản ở môi trường test | Năm ống, tham quan base, dữ liệu người chơi thật | Sau xác nhận lưu, thoát/vào còn đồ/cấp/cá thể/ống; tải lỗi không ghi đè; giao dịch có dấu chống lặp cùng dữ liệu |
| P1-G | Kiểm tra lỗi và hồi quy toàn vòng chơi; lưu, mất kết nối, nhận trùng, quyền máy chủ | Săn đội, điện thoại hoàn chỉnh, mở rộng nội dung | Checklist 24.13 đạt với bằng chứng; lỗi mất/nhân đồ chưa giải quyết thì chưa đánh dấu P1 hoàn thành |

Vật dụng cấp phục vụ P1-D chỉ nằm trong chế độ kiểm tra; P1-E thay bằng nguồn mua/chế hợp lệ, không mang vật dụng debug sang hồ sơ lưu. **Cập nhật 19/10:** nền tảng đánh/né/AI đã có ở L0/H1, Pet cơ bản P1-C ở mục 32 và nhiệm vụ/bắt P1-D ở mục 33. Thông số mới tại mục 25/30/32/33 thay số thử cũ tương ứng. Kho/giao dịch thử và P1-E đã triển khai tại mục 34; kho cá thể P1-F bước đầu tại mục 36, phần một ống/lưu và P1-G chưa hoàn thành; không coi P1-D là hoàn thành toàn bộ P1. Kiểm tra lại phần đã làm sau mỗi bước, tập trung vào các liên hệ vừa thay đổi.

### Định nghĩa hoàn thành P1 đầy đủ

| Hệ thống | Có thể bấm thử và xác nhận khi |
| --- | --- |
| Búa/thể lực | Rút/cất, N/H/K và combo ngắn hoạt động; một đòn một lần sát thương; hết thể lực từ chối hành động; ngừng tiêu hao thì hồi đúng |
| Quái | Phát hiện/đuổi/báo/cắn/nghỉ rõ; chết/bị bắt dừng AI; chỉ một kết quả cuối; không cần đánh bộ phận để qua P1 |
| Pet | Theo và đánh có nhịp; không đánh xuyên vật cản; gọi hồi 70%, choáng 30 giây; ngừng đánh lúc cho uống |
| Bẫy/bắt | Không có bẫy thì không đặt; một bẫy chỉ kích hoạt một lần; giữ 13 giây; chỉ bắt quái sống ≤10% và uống xong trong hạn |
| Nhiệm vụ/thưởng | Chết thứ tư/hết giờ xử lý đúng; thắng có 120 giây; hạ và bắt không thưởng trùng; đồ nhặt giữ khi thua |
| Nâng cấp/kho | Đủ nguyên liệu mới nâng, trừ/cộng một lần; đồ dư về kho đúng; cá thể có mã riêng |
| Ống/lưu | Chọn/đổi đúng cá thể; không mất cá thể cũ; thoát/vào sau lưu còn nguyên liệu, cấp búa và ống; xử lý lỗi không cấp trùng |
| Trải nghiệm PC | Người mới hiểu báo đòn/lý do thất bại, thực hiện combo và hoàn thành một lượt săn mà không cần sửa dữ liệu |

Mục tiêu trải nghiệm một lượt đầu khoảng 3–6 phút là giả thuyết để cân bằng, không thay đồng hồ 40 phút. Không rút ngắn âm thầm bẫy 13 giây, choáng pet 30 giây, thu hoạch 120 giây trong bản chơi; mô phỏng thời gian chỉ cho kiểm tra kỹ thuật tách biệt.

### Tình trạng bàn giao

Đã có sảnh/bãi tập, map H2, combat H1.3.1 và Pet P1-C chơi thử PC trong v2.4. Nhiệm vụ/bắt P1-D và kho/thưởng/chế tạo P1-E đã triển khai tại mục 33–34. Kho cá thể trong phiên P1-F đã có tại mục 36; một ống/lưu tài khoản còn chờ, nghiệm thu toàn vòng thuộc P1-G. Không lấy kiểm tra ngoài Studio hoặc mốc Pet làm bằng chứng hoàn thành toàn bộ P1.

## 24. Đối chiếu hai đợt góp ý và quy tắc kỹ thuật bản thử — 27/09/2026

### 24.1. Kết quả đối chiếu với file thực tế

Đã nhận đủ hai đợt, mỗi đợt 12 ảnh; chỉ xử lý sau khi người dùng báo “xong”. Đây là góp ý, không tự động thành quyết định của người dùng. Người góp ý chỉ thấy bản trích: đợt đầu đến mục 20, đợt hai cắt giữa mục 19. File thực tế đã có đầy đủ mục 20–24, không cần thêm mục trùng vì bản trích bị cắt.

**Đợt đầu, v0.20:** xác nhận mục 23 đã có; thêm bảng trạng thái, vòng đời nhiệm vụ/bắt, công thức 10% đề xuất, giao dịch thưởng, kho/lưu, quyền máy chủ, nhịp búa, AI và chia bước pet. Nhật ký mục 15 giữ lịch sử. Các quy tắc bên dưới được cập nhật theo phạm vi P1 hiện hành.

**Đợt hai — 12 điểm nhận xét:**

| Điểm | Góp ý | Đối chiếu và xử lý v0.21 |
| --- | --- | --- |
| 1 | Câu “chưa chọn”, pet/lộ trình chưa đồng bộ | Sửa mục 17–18: đã chọn búa; gắn nhãn pet toàn game ở mục 10; đồng bộ bước tại mục 11 |
| 2 | Định nghĩa hoàn thành cụ thể | v0.20 đã có tiêu chí bước; thêm bảng hoàn thành từng hệ thống ngay cuối mục 23 |
| 3 | P1 quá lớn, cần chia 0–G | Chia lại P1-0 → G, việc làm/chưa làm/điều kiện qua bước; P1 tối thiểu đến D khác P1 đầy đủ đến G |
| 4 | Ranh giới PC/điện thoại | Đề xuất P1 bắt buộc PC, cảm ứng là mốc sau; giữ yêu cầu game đầy đủ có hai nền tảng |
| 5 | Bảng phím búa | Đã có và không trùng E kỹ năng/F tương tác; giữ R mạnh, X rút/cất, Q pet thay vì đổi theo bảng minh họa trong ảnh |
| 6 | Combo dài khó làm ngay | Đề xuất N → H → K kết thúc cho P1; giữ N → H → N → K → K cho mở rộng. Làm từng đòn trước khi nối |
| 7 | AI ít trạng thái | Một đòn cắn; chưa đầu/chân/đuôi. Weak là cờ song song, không bắt quái phải yếu trước khi chết |
| 8 | Bảng bắt thất bại | Đã có ở 24.4; giữ trên 10% vẫn bị bẫy giữ nhưng không bắt, không tự đổi theo ví dụ trong ảnh |
| 9 | Mã lượt chống thưởng trùng | Đã có mã lượt/mục tiêu/giao dịch; bổ sung mẫu mã có số lượt mổ/nguồn nhặt để không chặn thưởng hợp lệ |
| 10 | Dữ liệu phiên/tài khoản | Thêm bảng tại 24.7; mã lượt và đồ mang có phần cần lưu đối soát, không xóa tất cả khi thoát |
| 11 | Lỗi lưu và kho thử trước | Chuẩn bị cấu trúc ở P1-0, dùng bộ nhớ; nối DataStore ở F. Tải lỗi không tạo hồ sơ trắng, ghi lỗi không âm thầm xóa thưởng |
| 12 | Test lỗi và hồi quy | 24.13 thành checklist chưa đánh dấu, có bước/thao tác/kết quả mong đợi; không tuyên bố đã test |

Phần ngoài phạm vi và kết luận trong ảnh đã được đưa vào mục 23–24. Không mở thêm hệ thống lớn trước bản nhỏ. Những thay đổi phạm vi mới vẫn là cấu hình thử của trợ lý, chưa phải chốt toàn game.

### 24.2. Phạm vi P1 sau mốc sảnh/luyện tập L0

Mục 23 xác định cấu hình và thứ tự; mục 24 giải thích vận hành/kiểm tra. P1 đầy đủ không có nghĩa game đầy đủ.

- **P1 tối thiểu 0–D:** PC, búa/combo ngắn, một quái/một đòn, pet cơ bản, săn thường hạ hoặc bắt; dữ liệu thử trong bộ nhớ.
- **P1 đầy đủ 0–G:** thêm thưởng, thương nhân/chế bẫy, nâng cấp, cá thể/một ống và lưu qua lần thoát đã kiểm tra.
- **Ngoài nghiệm thu vòng săn P1:** điện thoại hoàn chỉnh, săn đội/10%, ba quái/map, quái giao chiến, hệ/biến thể, nhiều đòn quái, đầu/chân/đuôi, nhiệm vụ chỉ bắt sống, năm ống, tham quan base, kỷ lục và pet nâng cao. Bảy vũ khí/combo dài và sảnh 12 base đã có trong bãi tập v2.3; việc cân bằng chúng cho săn và kiểm chứng đủ 12 người vẫn chưa làm.
- **Còn mở toàn game:** máu theo đội/phạm vi thưởng 10%, quái kết liễu nhau, đuôi, chia biến thể, bố trí base; chỉ cần giải quyết trước mốc liên quan.
- Chưa nghiệm thu toàn bộ vòng săn P1. Nền tảng bảy vũ khí/28 combo, thể lực, UI, sảnh, map và combat đã có; Pet cơ bản P1-C được kiểm tra tại mục 32, nhiệm vụ/bắt P1-D tại mục 33. Kho/giao dịch, thưởng và nâng búa thử đã có ở P1-E (mục 34); kho cá thể bộ nhớ P1-F đã thử tại mục 36, phần trưng bày và lưu còn lại để sau. Kho bộ nhớ không chứng minh lưu qua lần thoát; PC đạt không có nghĩa điện thoại đã được kiểm tra.

### 24.3. Vòng đời nhiệm vụ dùng thử

Luồng: **Sảnh → Chuẩn bị → Đang săn → Thành công/Thu hoạch hoặc Thất bại → Ghi kết quả/Trả đồ dư → Sảnh**. Chỉ một lượt đang hoạt động cho một người. Mỗi lượt có `QuestRunId`, mục tiêu có `MonsterInstanceId`; không chỉ nhận diện bằng tên loài. P1-D dựng luồng với đồ thử; E nối kinh tế, F mới lưu qua lần thoát. Nhiệm vụ chỉ bắt sống để sau P1.

| Giai đoạn | Quy tắc thử và điều kiện chuyển |
| --- | --- |
| Sảnh/Chuẩn bị | Chọn săn thường tại bảng. Kiểm tra hồ sơ sẵn sàng, đồ sở hữu/hạn mức và chỗ cho cá thể khi đã có kho. Chuyển đồ từ kho sang hành trang, giữ tổng sở hữu; lỗi vào map hoàn trả một lần. P1-D dùng kho thử |
| Vào map | P1 dùng cùng một place với khu sảnh và khu săn tách bằng ranh giới; máy chủ đưa nhân vật tới trại. Một quái A xuất hiện ở điểm cố định, có tên và dấu mục tiêu. Chỉ bắt đầu đồng hồ 40 phút khi nhân vật sẵn sàng điều khiển |
| Đang săn | Mục tiêu được ghi rõ trên UI; không đổi mục tiêu giữa lượt. Ba lần chết đầu hồi sinh trại, lần thứ tư thất bại. Thử hồi sinh sau 5 giây, đầy máu/thể lực, giữ đồ đã nhặt và lượng vật dụng còn lại; không tạo lại quặng/quái |
| Ranh giới | Trại là vùng an toàn, quái không gây sát thương xuyên ranh giới vào trại. Người ra ngoài vùng hợp lệ được đưa về trại; không tự tính một lần chết và không tạo đồ mới. Đồng hồ vẫn chạy. Quái vượt phạm vi thì quay về theo 24.11, giữ máu hiện tại |
| Hoàn thành mục tiêu | P1 săn thường: tiêu diệt hoặc bắt đều thắng. Khóa kết quả một lần, ngừng đồng hồ và các đòn còn chờ. Nhiệm vụ bắt sống áp quy tắc riêng sau P1 |
| Thu hoạch | Chạy 120 giây; có nút về sớm. Xác còn để mổ tối đa ba lượt P1; thú đã bắt đổi sang trạng thái bất động, sau hoạt ảnh thu gọn thử 2 giây thì ẩn, không tạo xác để mổ. Cá thể thuộc kho dữ liệu, không phụ thuộc mô hình còn trên map |
| Thất bại | P1: chết lần thứ tư hoặc hết giờ; không có 120 giây thu hoạch, về sảnh sau bảng kết quả. Giữ đồ đã nhặt, không cấp gói hoàn thành. Hết bẫy/thuốc không làm thua săn thường |
| Trở về | Ghi phần thưởng hợp lệ, trả vật dụng chưa dùng về kho một lần, đóng lượt. Hiện trạng thái lưu nếu chưa xác nhận xong. Không mở lượt mới khi giao dịch kết thúc lượt trước còn chưa rõ kết quả |

- Khi success đã khóa, chết trong thu hoạch không đổi kết quả; thử cho hồi tại trại và đồng hồ thu hoạch tiếp tục. Vật phẩm chưa nhặt/mổ khi về sớm hoặc hết 120 giây không tự được cấp.
- Dùng thời gian máy chủ. Chỉ nhận hoàn tất thao tác trong hạn; thao tác bắt đầu trước hạn nhưng kết thúc sau hạn không được tính thắng. Nếu hoàn thành đúng thời điểm hết hạn, thử ưu tiên mục tiêu hoàn tất hợp lệ; sự kiện đến muộn không được lùi thời gian để thắng.
- Khi hoàn thiện **phần lưu tài khoản của P1-F**, người chủ động rời lượt/mất kết nối không nối lại cuộc săn; lần vào sau về sảnh, giữ dữ liệu đã ghi thành công và xử lý đồ mang còn lại theo bản ghi chuyến săn. Không tạo lại mục tiêu cũ để nhận thưởng lần hai. **Hiện kho cá thể P1-F bước đầu vẫn là bộ nhớ máy chủ**, chưa bảo đảm giữ qua lần thoát/máy chủ mới; UI phải ghi rõ. Giới hạn khi máy chủ lỗi trước lúc lưu xem 24.8.
- **Ngoài P1:** giết quái phụ không hoàn thành mục tiêu chính; cần chốt thưởng quái phụ trước map ba quái. Mục tiêu chính bị quái khác kết liễu là tình huống còn mở, không tự gán thắng/thua. Chưa có hai tình huống này trong P1 một quái.

### 24.4. Bắt giữ: kiểm tra và xử lý thất bại

Giữ yêu cầu đã chốt: quái **còn sống, máu ≤10%**, bẫy giữ **13 giây**, pet chủ ngừng đánh khi bắt đầu cho uống. Cấu hình P1: đặt 1 giây; cho uống 3 giây; hoàn tất mới trừ bình. Khoảng cách thử tối đa 4 studs (đơn vị khoảng cách Roblox) đến điểm miệng; điều chỉnh theo kích thước mô hình khi chơi.

| Tình huống | Xử lý thử |
| --- | --- |
| Bẫy đặt sai: trên không, trong vật cản, ngoài khu săn hoặc quá xa | Máy chủ từ chối, không trừ bẫy; hiển thị vị trí không hợp lệ. Thử giới hạn vị trí đặt trong 5 studs từ nhân vật, trên mặt đất đi được |
| Hủy đặt trước khi xong | Không tạo bẫy, không trừ vật dụng. Đặt xong mới trừ một Iron Trap, gắn mã bẫy với lượt và người đặt |
| Quái còn trên 10% trúng bẫy | Vẫn bị giữ 13 giây; chưa cho uống hợp lệ. Nếu hạ xuống ngưỡng khi bẫy còn thời gian thì được bắt đầu thao tác |
| Người chưa cất vũ khí/không có thuốc/ở ngoài tầm | Không bắt đầu cho uống; báo điều kiện thiếu. Không tự bỏ qua độ trễ cất 1 giây |
| Đang cho uống thì bị đánh, né, rút vũ khí, chết hoặc rời tầm | Hủy thao tác, chưa trừ bình; bẫy tiếp tục đếm phần thời gian còn lại. Muốn thử lại phải giữ tương tác đủ 3 giây từ đầu |
| Bẫy hết 13 giây trước khi uống xong | Hủy thao tác; quái thoát, không bắt, không trừ bình. Bẫy đã dùng không được trả lại. UI hiện thời gian bẫy còn lại, cảnh báo ở 3 giây cuối |
| Quái bị đánh trong bẫy | P1 không tự miễn sát thương/miễn chết. Nếu máu về 0 trước khi bắt hoàn tất thì xử lý tiêu diệt; không đồng thời cấp thưởng bắt. Pet kiểm tra trạng thái ngừng đánh cả lúc phát đòn lẫn lúc áp sát thương |
| Đặt bẫy cuối | P1 săn thường tiếp tục kể cả hết khả năng bắt. Nếu bẫy còn chờ/đang giữ mục tiêu và còn thuốc thì vẫn thử bắt được; không báo hết cơ hội chỉ vì túi đã hết bẫy |
| Hai yêu cầu bắt/tiêu diệt cùng tới | Máy chủ chỉ cho một chuyển trạng thái cuối: Captured hoặc Defeated. Kiểm tra lại sống, ngưỡng, bẫy và thuốc ở thời điểm hoàn tất; không chỉ kiểm tra lúc bắt đầu |
| Bắt xong nhưng mất kết nối | Phần thưởng/cá thể đã ghi thì nhận lại từ hồ sơ, không quay thưởng lại. Phần chưa xác nhận ghi được xử lý bằng cùng mã giao dịch; không hứa phục hồi được dữ liệu chưa từng được lưu |

**Sau P1, nhiệm vụ bắt sống:** giết mục tiêu thì thua; hết khả năng bắt khi không còn thuốc, hoặc không còn bẫy trong túi VÀ không có bẫy hợp lệ còn chờ/đang giữ mục tiêu. Săn đội cần xét vật dụng cả đội, chưa áp vào P1 săn thường.

**Trước săn đội mới chốt:** ai có quyền cho uống; người đặt bẫy và cho uống khác nhau; pet đồng đội có dừng không; vật dụng còn lại được xét cả đội thế nào. Đề xuất cho mọi thành viên còn sống, đủ điều kiện thao tác được hỗ trợ bắt, còn quyền nhận thưởng xét riêng theo đóng góp. Đây chưa phải quyết định của người dùng.

### 24.5. Ngưỡng 10% — đề xuất cho mốc săn đội

**Đã chốt:** chỉ cộng sát thương người chơi và pet của họ, không cộng hồi phục. **Chưa chốt:** mẫu số, loại thưởng bị ràng buộc và trường hợp rời đội. P1 solo chưa dùng quy tắc này để khóa thưởng.

Phương án đề xuất:

`Đủ đóng góp ⇔ sát thương máu thực nhận từ người chơi và pet của họ ≥ 0,10 × máu tối đa mục tiêu sau khi điều chỉnh theo đội lúc bắt đầu lượt.`

- Chốt đội và máu tối đa trước khi bắt đầu; không thay mẫu số giữa lượt khi ai đó rời/đến. Tham gia giữa lượt và tăng/giảm máu theo đội cần thiết kế riêng trước khi bật tính năng đó.
- Chỉ cộng lượng thật sự trừ vào máu mục tiêu sau giảm sát thương; không cộng phần đánh vượt máu còn lại, không cộng lần hai cho thanh bộ phận. Sát thương quái gây cho nhau không thuộc người chơi.
- Sát thương trước lúc bắt vẫn được tính. Đòn của pet gắn chủ sở hữu ở máy chủ; thử dừng phát đòn mới khi chủ chết, đòn đã phát hợp lệ trước đó vẫn tính nếu thực sự trúng. Khi thêm sát thương theo thời gian/phản sát thương phải gán nguồn trước, không suy đoán từ người đứng gần.
- Khóa bảng đóng góp tại thời điểm mục tiêu bị bắt/tiêu diệt, không đợi người bấm nhận thưởng. Nếu về sau cho nhận khi mất kết nối, cần lưu bảng đã khóa cùng kết quả.
- Ví dụ: mục tiêu 2.400 máu thì ngưỡng là 240; người gây 200 và pet gây 40 đạt ngưỡng. Khi bắt ở 10% máu, không đổi mẫu số thành 90% máu đã mất.
- **Cần quyết định trước săn đội:** ngưỡng khóa nguyên liệu quái, cá thể, gói nhiệm vụ hay cả ba; người không đạt có giữ đồ tự nhặt hay không. Yêu cầu hiện hành là giữ đồ đã nhặt khi thua, không tự mở rộng ngưỡng để tịch thu đồ đó. Quyền thao tác bắt và quyền nhận thưởng phải được xét riêng.

### 24.6. Phần thưởng và chống nhận lặp

Tách theo nguồn. Mẫu mã: `PlayerId + QuestRunId + SourceInstanceId + RewardType + ClaimIndex`; máy chủ tạo/kiểm tra, bấm lại không tạo mã mới. Nguồn là mã quái khi mổ/bắt, mã quặng/vật rơi khi nhặt hoặc mã lượt với gói nhiệm vụ. `ClaimIndex` phân biệt mổ 1, 2, 3; không chặn nhầm lượt 2/3 vì cùng loại thưởng. Bắt trọn gói dùng một mã cố định, ghi ba kết quả nguyên liệu và một cá thể bên trong.

Bảng sau mô tả P1 đầy đủ: P1-E chỉ thử nguyên liệu/kinh tế; P1-F thêm cá thể và lưu bền vững. Chưa có cá thể ở E thì chưa đánh dấu tiêu chí bộ sưu tập hoàn thành.

| Nguồn | Dữ liệu/kết quả cần ghi |
| --- | --- |
| Tiêu diệt mục tiêu | `MonsterDefeated`: khóa trạng thái quái; săn thường mở các lượt mổ, chưa tự cấp toàn bộ nguyên liệu. Nhiệm vụ bắt sống sau P1 dùng phương án thất bại, không mở giai đoạn mổ |
| Mổ xác | `CarveGranted`: một mã cho mỗi người/lượt mổ 1–3; hoàn tất tương tác mới cấp một nguyên liệu gốc 1 |
| Bắt thành công | `CaptureGranted`: ba lượt nguyên liệu độc lập và một cá thể P1; mỗi lượt chọn loại rồi xét 50% lượng 1 / 50% lượng 2. Không tạo thêm lượt mổ |
| Hoàn thành nhiệm vụ | `QuestBonusGranted`: 1 xương + 40 xu P1, một lần khi nhiệm vụ thành công, riêng với nguyên liệu mổ/bắt |
| Nhặt trên map | `PickupGranted`: mã quặng/vật rơi và người nhặt; chỉ cấp một lần. Đồ đã nhặt thuộc tiến trình kể cả thất bại nhiệm vụ |
| Chế tạo/nâng cấp | `CraftOrUpgradeCommitted`: trừ nguyên liệu và thêm sản phẩm/cấp trang bị trong cùng giao dịch, không gọi là thưởng nhiệm vụ |

- P1-E minh họa vật rơi bằng **một vảy gốc 1 khi quái lần đầu giảm qua 50% máu và vẫn sống**; phải nhặt, có mã riêng/cờ tạo một lần. Không cần đánh bộ phận; đây là nguồn thử có kiểm soát, chưa chốt tỷ lệ rơi toàn game. Nhặt vảy không dùng lượt mổ; đuôi để sau P1.
- Mỗi hồ sơ có danh sách giao dịch đã ghi. Trước F dấu này chỉ trong bộ nhớ; từ F lưu bền vững cùng thay đổi sở hữu. Khi thử lại cùng mã: trả kết quả cũ, không cấp lại và không quay lại ngẫu nhiên. Mã cá thể, loại/lượng thưởng phải được tạo một lần và giữ ổn định khi thử lưu lại.
- Trong P1 solo, kết quả bắt, thuốc bị tiêu hao, cá thể, nguyên liệu bắt và gói nhiệm vụ có thể cùng nằm trong một lần cập nhật hồ sơ. Các lượt mổ/nhặt về sau là giao dịch riêng. Không để Captured và Defeated cùng phát thưởng cho một quái.
- Ghi thay đổi sở hữu **cùng dấu giao dịch** trong một cập nhật hồ sơ; không ghi “đã thưởng” trước rồi để bước cấp vật phẩm ở nơi khác. Xử lý nối tiếp các giao dịch của một hồ sơ.
- UI hiển thị “đang ghi nhận” khi chưa xác nhận lưu; bấm lại chỉ xem trạng thái. Khi kết quả ghi chưa rõ, kiểm tra cùng mã trước khi thử lại; không tạo thưởng thay thế có mã mới.
- Không xóa dấu giao dịch của lượt còn có thể được gửi lại. Chỉ dọn theo chính sách lưu trữ khi lượt đã đóng và máy chủ có thể từ chối yêu cầu cũ; không để danh sách tăng mãi không giới hạn.
- Khi mở săn đội, mỗi người nhận có dấu riêng và cần cơ chế tiếp tục cấp phần còn thiếu. Không giả định cập nhật nhiều hồ sơ khác nhau là một giao dịch nguyên tử duy nhất.

### 24.7. Kho, dữ liệu phiên và dữ liệu tài khoản

| Lớp | Ví dụ | Cách xử lý |
| --- | --- | --- |
| Chỉ trong phiên | HP người/quái, thể lực, vị trí, AI, bẫy/đồng hồ, combo, pet, đóng góp đang tích | Giữ trên máy chủ; không ghi DataStore từng khung hình/đòn; không nối lại trận cũ |
| Tiến trình tài khoản | Xu, nguyên liệu, kho vật dụng, trang bị/cấp búa, cá thể/ống, cờ đã cấp đồ đầu | Kho thử trước F; từ F ghi khi có thay đổi có ý nghĩa, chỉ báo đã lưu sau xác nhận |
| Đối soát chuyến săn | Mã lượt, đồ chuyển khỏi kho/còn lại, kết quả và dấu giao dịch | Từ F phải lưu phần cần thiết để trả đồ/không cấp trùng; không bỏ hết vì thuộc một chuyến săn |

Mã lượt dùng cả trong phiên và dấu thưởng đã lưu; đồ mang có trạng thái chơi tạm nhưng thay đổi quyền sở hữu cần ghi nhận. Không lưu cả thế giới để nối lại cuộc săn. Kỷ lục là tiến trình tài khoản khi triển khai sau P1; hiện chưa chốt cách tính.

| Nhóm hồ sơ | Trường dự kiến |
| --- | --- |
| Phiên bản/hồ sơ | `DataVersion`, `Revision`, `StarterGranted`, thông tin phiên máy chủ đang giữ hồ sơ |
| Kinh tế/vật dụng | `Coins`, `Materials[itemId]`, `StoredConsumables[itemId]` — số lượng nguyên không âm |
| Trang bị | Danh sách sở hữu, `EquippedWeaponId`, `HammerUpgradeLevel`, giáp/pet cơ bản đã cấp |
| Cá thể | `OwnedSpecimens[specimenId]` gồm loài, biến thể, kích thước, thời điểm bắt và mã lượt nguồn; P1 dùng ngoại hình cơ bản cố định |
| Trưng bày | `DisplaySlot1 = specimenId` hoặc trống; mã phải thuộc kho người đó |
| Chuyến săn/giao dịch | `ActiveRun` gồm mã lượt, đồ mang còn lại, kết quả đang chờ; các dấu giao dịch cần phục hồi/chống lặp |

- Hồ sơ bộ nhớ P1-E ban đầu `DataVersion = 1`; **hiện P1-F bước đầu là `DataVersion = 2`, `StorageMode = ServerMemory`**, thêm kho cá thể/số thứ tự và chuyển hồ sơ v1 hợp lệ mà không cấp lại 80 xu (mục 36). Đây là phiên bản cấu trúc dữ liệu, độc lập hồ sơ thiết kế 0.39. Khi làm lưu tài khoản, chỉ cấp đồ đầu khi chắc chắn chưa có hồ sơ, không cấp vì tải lỗi; cấp đồ và `StarterGranted` cùng giao dịch.
- Nguyên liệu xếp chồng theo mã loại; cá thể luôn có mã riêng. UI phân biệt cá thể cùng loài bằng thứ tự/ngày bắt và mã rút gọn. Thay cá thể trưng bày chỉ đổi tham chiếu, không di chuyển/xóa sở hữu.
- Kho cá thể thử từ P1-F tối đa 100; kiểm tra/dành chỗ trước lượt có thể bắt. Đầy thì báo trước: vẫn săn tiêu diệt nhưng không bắt thêm. Nhiệm vụ bắt sống sau P1 cần chặn vào khi hết chỗ. Đây là hạn mức thử, không phải giới hạn toàn game.
- P1 chưa có bán/thả/xóa cá thể hoặc giao dịch giữa người chơi. Nếu dữ liệu ống tham chiếu mã không tồn tại, để ống trống và ghi lỗi; không tự tạo một cá thể mới.
- Không âm thầm bỏ phần thưởng khi gặp đầy kho hoặc dữ liệu bất thường. Giữ giao dịch ở trạng thái chờ xử lý, báo rõ; không đánh dấu đã cấp. Giới hạn số lượng nguyên liệu/tiền cần được kiểm tra về kiểu và miền giá trị ở máy chủ, không lấy số người chơi gửi làm số lượng thật.
- Đồ mang dư trước chuyến săn trả kho theo quyết định đã chốt. Đồ chưa dùng sau chuyến săn trả kho là cấu hình P1; không nhân đôi bằng cách vừa giữ trong hành trang cũ vừa cộng lại kho.

### 24.8. Lưu, lỗi và khôi phục

Mục tiêu là giữ tiến trình và tránh cấp lặp; đây là thiết kế cần kiểm chứng, không phải cam kết không bao giờ mất dữ liệu.

**Trình tự:** P1-0 định nghĩa hồ sơ/lớp đọc ghi và dùng bảng trong bộ nhớ máy chủ, không cần dịch vụ MemoryStore và chưa nối DataStore. P1-E thử kinh tế trong phiên; P1-F bước đầu thêm cá thể nhưng **vẫn dùng bộ nhớ**. Phần P1-F tiếp theo mới thay lớp lưu bằng DataStore ở bản game test riêng; P1-G thử lỗi. Không tự chuyển sang hồ sơ tạm rồi ghi đè tài khoản thật khi tải lỗi; chế độ dữ liệu thử phải chọn rõ, không trộn đồ debug.

Các quy tắc dưới đây áp dụng khi kết nối lưu tài khoản từ P1-F:

1. **Tải trước khi chơi:** một hồ sơ chính cho mỗi tài khoản. Nếu tải lỗi, báo đang thử lại và khóa giao dịch/đi săn; không dùng hồ sơ trắng để ghi đè dữ liệu thật. Nếu thử lại vẫn lỗi, cho người chơi quay lại sau với thông báo rõ.
2. **Một máy chủ ghi:** giữ quyền sử dụng hồ sơ theo phiên có thời hạn, gia hạn khi còn hoạt động và kiểm tra quyền ở mọi lần ghi. Nếu mất quyền thì dừng sửa tiến trình; không để máy chủ cũ ghi đè máy chủ mới. Không chỉ dựa vào sự kiện người chơi rời game.
3. **Ghi nối tiếp:** dùng cơ chế cập nhật có kiểm tra dữ liệu hiện tại, như `UpdateAsync`, cho thay đổi cần bảo vệ khỏi ghi đè. Hàm cập nhật có thể được gọi lại; không quay thưởng, tạo mã mới hoặc gây hiệu ứng bên ngoài trong hàm đó. Có hàng đợi theo từng hồ sơ, kiểm tra phiên/revision và dấu giao dịch.
4. **Thời điểm lưu:** ghi giao dịch khi cấp đồ đầu, nhặt/mổ, hoàn tất bắt/thưởng, mua/chế/nâng cấp, chuyển đồ đi/về và đổi trưng bày. Thử tự lưu theo chu kỳ 60 giây cho trạng thái còn bẩn, có giãn thời điểm giữa người chơi; lưu khi rời/đóng máy chủ là bổ sung. Không lưu từng đòn đánh; khi mật độ nhặt tăng cần gom ghi và kiểm tra hạn mức dịch vụ.
5. **Lỗi tạm thời:** thử lại có thời gian chờ tăng dần và độ lệch ngẫu nhiên, có giới hạn; ưu tiên hoàn tất giao dịch cũ. Chưa chắc đã ghi hay chưa thì đọc/đối chiếu dấu giao dịch, không cấp mới. Khi hàng đợi không thể tiến, khóa thêm giao dịch kinh tế và báo người chơi.
6. **Thoát đột ngột:** lần vào sau đọc hồ sơ và bản ghi lượt còn dang dở; trả vật dụng chưa tiêu hao theo bản ghi đã lưu, xử lý kết quả đã ghi mà UI chưa hiển thị. Không tiếp tục chiến đấu ở lượt cũ. Dữ liệu chỉ có trong bộ nhớ lúc máy chủ sập có thể chưa phục hồi được; kiểm tra cửa sổ này trước mở chơi thật.
7. **Nâng cấu trúc:** chuyển lần lượt từ phiên bản cũ sang mới, giữ trường chưa thay đổi và kiểm tra dữ liệu sau chuyển. Tạo điểm khôi phục trước đợt đổi lớn, thử trên bản sao; không lấy dữ liệu người chơi thật làm dữ liệu kiểm tra.
8. **Sao lưu/khôi phục:** sử dụng phiên bản dữ liệu có sẵn theo chính sách Roblox và quy trình lưu bản sao trước thay đổi lớn. Khôi phục bằng người quản trị khi hồ sơ không còn phiên đang ghi; ghi lý do, nguồn phiên bản và kết quả đối chiếu. Việc khôi phục cả hồ sơ phải xét các giao dịch sau mốc đó để tránh tạo lại đồ đã dùng.

Giới hạn cần ghi trong kết quả thử: lưu khi thoát có thể không chạy khi máy chủ lỗi; `UpdateAsync` không tự giải quyết tất cả việc ghi cũ, quay thưởng lại hoặc tranh quyền phiên. Chỉ hiển thị “đã lưu” sau xác nhận ghi thành công. Chưa có cơ chế nào trong mục này được triển khai hoặc thử lỗi thực tế.

### 24.9. Máy chủ quyết định, máy người chơi gửi thao tác

Máy người chơi xử lý nút, camera, dự đoán hoạt ảnh và hiển thị; máy chủ giữ dữ liệu thật. Mục đích là cùng một quy tắc áp dụng cho mọi người, kể cả khi yêu cầu gửi trễ hoặc bị gửi lặp.

| Yêu cầu từ máy người chơi | Máy chủ phải kiểm tra trước khi chấp nhận |
| --- | --- |
| Đánh/né/chạy | Nhân vật sống, vũ khí đang trang bị, trạng thái hợp lệ, thể lực, nhịp đòn, thứ tự combo; kiểm tra hướng/khoảng cách và va chạm trước khi tính sát thương |
| Đặt bẫy/cho uống | Đang trong đúng lượt, đã cất vũ khí, còn vật dụng, vị trí/tầm, mặt đất, quái sống và đủ ngưỡng, bẫy còn hiệu lực, thời lượng thao tác |
| Gọi pet | Chủ/pet đúng sở hữu, trạng thái, hồi chiêu, không có lệnh trùng, chủ còn sống tại lúc nhận hồi |
| Nhặt/mổ | Vật hoặc xác còn hợp lệ, người ở đủ gần, tương tác đã xong, lượt nhận còn lại và mã giao dịch chưa xử lý |
| Mua/chế/nâng | Gần điểm tương tác, công thức/giá do máy chủ chọn, đủ tiền/nguyên liệu, giới hạn cấp và giao dịch hợp lệ |
| Trưng bày/nhận kết quả | Mã cá thể thuộc người chơi; kết quả lấy từ bản ghi máy chủ. Nút nhận không quyết định lượng/loại thưởng |

Máy chủ tự quyết định máu quái, lượng sát thương, phần trăm đóng góp, thời gian, vật phẩm/cá thể và kết thúc nhiệm vụ. Kiểm tra kiểu dữ liệu, số hữu hạn, miền giá trị và giới hạn tần suất yêu cầu; khoảng cách phải dùng vị trí được máy chủ kiểm tra, không tin vị trí tùy ý do client gửi. Không để client tự báo “đã gây 1.000 sát thương” rồi cộng thẳng.

### 24.10. Búa: pha đòn và vùng trúng P1

Chỉ pha gây sát thương được xét trúng. Giữ phím/chỉ số mục 23; P1 làm hết động tác trước khi nhận đòn/né kế tiếp, chưa hủy hoạt ảnh hoặc đệm nút.

| Đòn | Chuẩn bị | Gây sát thương | Thu đòn | Tổng |
| --- | ---: | ---: | ---: | ---: |
| N | 0,20 giây | 0,10 giây | 0,25 giây | 0,55 giây |
| H | 0,45 giây | 0,15 giây | 0,50 giây | 1,10 giây |
| K thường | 0,25 giây | 0,10 giây | 0,35 giây | 0,70 giây |
| K kết thúc | 0,45 giây | 0,20 giây | 0,55 giây | 1,20 giây |

- Vùng thử: thể tích quanh đầu búa bán kính 2 studs quét theo cung; điểm trúng tối đa 8 studs từ nhân vật, không xuyên vật cản. Hiện vùng debug để so với hoạt ảnh.
- Mỗi mã đòn chỉ trừ máu một lần trên mỗi mục tiêu dù chạm nhiều phần/khung hình. P1 chưa tích thanh bộ phận; thêm về sau vẫn không trừ máu lần hai.
- Được quay trong chuẩn bị, khóa hướng từ pha gây sát thương. Thể lực trừ khi chấp nhận đòn, không hoàn vì hụt. Thử cho đi chậm 50% tốc độ thường trong đòn, không chạy nhanh; điều chỉnh khi chơi.
- N → H → K kết thúc: **246 sát thương / 44 thể lực / 2,85 giây động tác**. K ngoài chuỗi gây 50; K → K không tự mở kết thúc.
- Giữ Shift lúc đang đánh: chờ hết đòn, nếu còn giữ thì cất đủ 1 giây rồi chạy. Thả trước khi đòn hết thì không tự cất; thả giữa lúc cất vẫn hoàn tất cất nhưng không chạy. Đây là cách xử lý thử.
- Chuỗi dài, hủy thu đòn, nhiều hit và gây gục để sau P1. Chưa kết luận cân bằng với sáu vũ khí chưa làm.

### 24.11. AI quái: giới hạn trạng thái P1

**P1-B:** Idle → Chase → Warning → Attack → Recovery → Chase, thêm Return khi mất mục tiêu và Defeated khi chết. Phát hiện là điều kiện chuyển, chưa cần trạng thái riêng. **P1-D:** thêm Trapped, Captured và cờ Weak.

**Yếu máu là cờ song song:** quái có thể chết từ mọi trạng thái còn sống, không bắt buộc Weak trước Defeated. P1 chưa có gục bộ phận, quái giao chiến, nhiều mục tiêu, chạy sang khu khác, biến thể/nguyên tố.

| Trạng thái | Quy tắc thử |
| --- | --- |
| Idle — chờ | Người sống trong khu săn, trong 60 studs và không bị vật cản kín che thì Chase. Bị người đánh hợp lệ cũng giao chiến |
| Chase — đuổi | Theo người solo; ≤8 studs có tầm/đường đánh thì Warning. Mất mục tiêu 10 giây hoặc xa điểm xuất hiện hơn 120 studs thì Return |
| Warning — báo | Báo cắn 0,8 giây, chốt hướng trước pha trúng; sang Attack nếu chưa ngắt, không xoay vô hạn bám người đã né |
| Attack — cắn | Cửa sổ 0,30 giây gây 18 sát thương, mỗi nạn nhân tối đa một lần; tiếp đến Recovery |
| Recovery — nghỉ | Nghỉ 1,5 giây, vẫn nhận sát thương; xong thì Chase/Return |
| Return — về vùng | Không hồi máu/đổi mã. Kẹt không tiến triển 5 giây thì thử đặt về điểm an toàn, giữ HP và hủy đòn cũ; vẫn tái giao chiến trong vùng hợp lệ |
| Trapped — bẫy | Hủy đòn đang dở, cúi đầu 13 giây. Bắt hợp lệ → Captured; HP 0 → Defeated; hết bẫy → Chase/Return. Một bẫy không kích hoạt lại; bẫy mới không nối/reset thời gian khi quái đang mắc bẫy |
| Captured / Defeated | Kết quả loại trừ nhau, dừng AI/đòn chưa áp sát thương; chỉ có tương tác hậu kết quả hợp lệ |

Weak bật khi 0 < HP ≤10% MaxHP: khập khiễng, thử đi còn 60% tốc độ, hiện dấu đủ bắt; không tự tắt chiến đấu. Vùng cắn phải khớp hoạt ảnh khi xem trực tiếp.

Ưu tiên: kết quả đã khóa → chết → bẫy/bắt → hành vi thường. Đòn hẹn giờ phải kiểm tra lại trạng thái trước khi trừ máu. Chủ chết thì quái về vùng, HP không reset; không cho đứng trong trại đánh xuyên ra khi quái không thể đáp trả.

### 24.12. Pet: phần bắt buộc và phần để sau

- **P1-C, bước nhỏ 1:** theo chủ, đánh 12 mỗi 4 giây trong tầm 6 studs. C dùng mục tiêu thử hiện tại, D gắn mục tiêu vào lượt săn; chỉ đánh khi chủ giao chiến, không mở trận xa. Kiểm tra tầm/vật cản trước khi trừ máu; đi vòng khi đường bị chắn, không xuyên tường.
- **P1-C, bước nhỏ 2:** máu 100, sát thương không hạ dưới 1; ở 1 thì choáng 30 giây, đòn mới không reset thời gian; đứng dậy đầy máu.
- **P1-C, bước nhỏ 3:** gọi hồi 70% tối đa có trần máu, hồi chiêu thử 119 giây, UI báo. Chưa đủ ba bước thì chưa hoàn thành C.
- **P1-D:** nối cho uống; dừng phát đòn và hủy sát thương pet chưa xảy ra lên mục tiêu đang bắt. Hủy cho uống thì pet trở lại hành vi phù hợp. Không nhận lệnh hồi mới trong lúc chủ cho uống.
- Chủ chết/pet choáng trước khi hồi thì hủy lệnh; chưa hồi chưa bắt đầu hồi chiêu. Thuốc áp máu một lần; đầy máu thì báo không cần hồi. Choáng/hồi sinh chủ không reset kỹ năng, không xếp lệnh chờ để tự hồi ngay khi đứng dậy.
- Chủ chết thì pet ngừng phát đòn, theo về trại khi có thể; nếu đang choáng vẫn chờ hết. Ưu tiên: choáng → ngừng đánh khi chủ cho uống → lệnh hồi → đánh/theo.
- **Sau P1:** tự tìm chỗ an toàn hồi, né/đỡ/thu hút và chế/đổi vũ khí-mũ-giáp. Giữ ở mục 22; không yêu cầu để qua P1-C.

### 24.13. Checklist lỗi và hồi quy — cập nhật P1-C/D ngày 19/10/2026

Sau mỗi bước thử phần mới và chạy lại trường hợp cũ bị ảnh hưởng. P1-G chạy toàn bộ mục thuộc P1; không đánh dấu đạt chỉ vì đã viết code/mô tả. Ghi bản build/bước, thao tác, mong đợi, thực tế, đạt/lỗi và cách tái hiện. Lưu qua lần thoát chỉ kiểm tra được từ P1-F với hồ sơ test riêng.

Các dấu đạt P1-C/D bên dưới dựa trên kiểm chứng nêu tại mục 32–33, có phân biệt luật/controller và Play thật. Chưa chơi chờ đủ 40 phút thật, chưa xác nhận điện thoại; các mục kinh tế/lưu vẫn để trống. Các dòng P1-A/B giữ checklist toàn phạm vi P1, không thay báo cáo combat hiện hành tại mục 30.

**P1-A/B — chiến đấu và AI:**

- [ ] Một đòn chạm nhiều phần/nhiều khung hình: chỉ giảm máu một lần đúng lượng; đánh hụt không giảm.
- [ ] Spam nút khi đang ra đòn: không vượt nhịp hoặc chạy nhiều đòn đồng thời.
- [ ] N → H → K đúng hạn ra kết thúc; sai/quá hạn/K → K không ra; thiếu thể lực không tiến chuỗi.
- [ ] Cạn thể lực không đánh/né; chạy cạn thì đi; sau 0,75 giây ngừng tiêu hao hồi 20/giây, không vượt 100.
- [ ] Giữ/thả Shift ở các thời điểm 24.10 không bỏ qua cất 1 giây, không chạy khi đang rút vũ khí.
- [ ] Quái báo/cắn/nghỉ rõ; người đã né ra ngoài vùng trúng không bị đánh vì vị trí cũ lúc báo.
- [ ] Quái chết/đòn ngắt trước khi trúng: đòn hẹn giờ không gây thêm sát thương.
- [ ] Quái kẹt/mất mục tiêu: về vùng với cùng mã/HP, không tái tạo quặng/vật rơi để farm.

**P1-C/D — pet, bắt và nhiệm vụ:**

- [x] Pet theo/đánh đúng nhịp, không đánh xuyên tường, mỗi chu kỳ chỉ trừ máu một lần — kiểm chứng P1-C tại mục 32.
- [x] Gọi hồi nhiều lần chỉ có một lệnh; hồi 70% tối đa, không vượt trần — luật/controller và Play P1-C.
- [x] Đòn lớn không làm pet chết; choáng đủ 30 giây, đòn mới không kéo dài; đứng dậy không reset kỹ năng — P1-C.
- [x] Chủ chết/pet choáng lúc mang thuốc: hủy đúng, không hồi người chết; hồi sinh không làm mới kỹ năng — P1-C.
- [x] Hết bẫy/đặt sai/hủy đặt: không tạo bẫy hoặc trừ nhầm; đặt xong trừ đúng một — luật/controller P1-D; đặt thật trong Play.
- [x] Quái >10% vẫn có thể bị giữ nhưng không cho uống; sống đúng 10% được; HP 0 không bắt — luật/controller; Play bắt tại 84 HP.
- [x] Một bẫy kích hoạt một lần, giữ đúng 13 giây; bẫy mới không nối thời gian trên quái đang bị giữ — luật/controller P1-D.
- [x] Ra xa/bị đánh/hết bẫy trước uống xong: hủy không trừ bình; thử lại cần đủ 3 giây từ đầu — luật/controller; Play bẫy đầu hết hạn không mất thuốc.
- [x] Pet ngừng cả đòn đang chuẩn bị khi cho uống; hủy thao tác thì trở lại hành vi phù hợp — tích hợp/controller P1-D và Play.
- [x] Bắt/tiêu diệt đồng thời khóa một kết quả — luật P1-D; thưởng/mổ đã kiểm chứng ở P1-E (mục 34), ghi cá thể cùng giao dịch ở P1-F bước đầu (mục 36).
- [x] Ba lần chết đầu tiếp tục, thứ tư thua — Play giữ cùng mã/hạn và HP 1.152 qua ba lần đầu, lần thứ tư về sảnh.
- [x] Hết hạn 2.400 giây thua; hết bẫy/thuốc không làm thua săn thường — luật Lune, chưa chờ đủ 40 phút thật.
- [x] Hoàn thành đúng/sau hạn theo 24.3 — kiểm tra biên thời gian bằng luật P1-D.
- [x] Thắng có 120 giây rồi tự về, không đổi kết quả hoặc mốc thời gian vì chết sau đó — Play `Captured` qua hồi sinh và tự về sảnh.
- [x] Nút về sớm được thử sau hạ mục tiêu: `Harvest/Defeated` → `Closed/Defeated`, về sảnh và phục hồi con mẫu; không đổi kết quả.
- [x] Ra ngoài biên nhiệm vụ trở về trại, giữ mã lượt, hạn và số lần chết — Play P1-D.

**P1-E/F — thưởng, nâng cấp, cá thể:**

- [x] Ba lượt mổ nhận đủ ba phần; gửi lại lượt 1 không cấp thêm/không chặn lượt 2–3; không có lượt 4 — luật/controller và Play P1-E.
- [x] Bắt nhận ba lượt nguyên liệu, lượng độc lập và gói nhiệm vụ riêng một lần — luật và Play P1-E.
- [x] Bắt cấp đúng một cá thể riêng — P1-F bước đầu tại mục 36; luật đạt và native Play nhận đúng một GUID, giữ qua tự về sảnh/hồi sinh. Chỉ trong bộ nhớ máy chủ, chưa lưu tài khoản.
- [x] Cùng mã nhặt/giao dịch gửi lại không tăng đồ; mã các điểm quặng khác nhau vẫn nhận riêng — luật/controller P1-E, Play sáu quặng và mã mua cũ.
- [x] Nhặt rồi thua giữ đồ; trả đồ mang dư/chưa dùng một lần, gọi kết thúc/về sảnh lần hai không cộng lại — luật P1-E; Play trả thuốc và giữ sắt/vảy khi bỏ cuộc.
- [x] Thiếu nguyên liệu không nâng; đủ thì trừ/tăng cấp một lần; hết xu vẫn săn thường — luật P1-E; Play nâng cấp và nhận săn khi không có vật tư.
- [ ] Đổi ống đúng mã cá thể và giữ con cũ trong kho; đầy báo trước, không tự xóa/cấp lại.
- [ ] Từ F, sau xác nhận lưu, thoát/vào giữ vật liệu, cấp búa, cá thể/ống; không cấp bộ đầu lần nữa.

**P1-F/G — lỗi dữ liệu, quyền máy chủ, hồi quy:**

- [ ] Tải lỗi không tạo hồ sơ trắng để ghi đè, không cấp thưởng/nâng cấp vào tài khoản chưa tải.
- [ ] Ghi lỗi/chưa rõ kết quả: có thông báo/log, giữ giao dịch chờ; thử lại cùng mã không quay lại thưởng/nhân đồ.
- [ ] Ngắt kết nối trước/sau ghi thưởng/chế/nhặt: đối soát dữ liệu đã lưu, không cấp lại. Ghi rõ trường hợp chưa lưu có thể mất, không báo “đã lưu” giả.
- [ ] Hai phiên cùng xin hồ sơ/quyền phiên hết hạn: chỉ phiên hợp lệ ghi, phiên cũ không ghi đè.
- [ ] Chuyển phiên bản/khôi phục chỉ trên hồ sơ test; không trộn vật dụng debug/dữ liệu người chơi thật.
- [ ] Yêu cầu từ xa, sai sở hữu, giả lượng thưởng, sai kiểu hoặc spam: máy chủ từ chối, tiến trình thật không đổi.
- [ ] Chơi lại PC toàn vòng sau thay đổi liên quan: hồ sơ → săn/hạ hoặc bắt → thắng/thua → về → nâng/ống → lưu/vào lại; lỗi đã sửa không tái xuất hiện.

**Không phải điều kiện P1:** combo dài, bộ phận/đuôi, nhiệm vụ chỉ bắt sống, săn đội/10%, quái giao chiến, điện thoại. Mốc cảm ứng sau P1 phải thử riêng nút/camera/thao tác, không suy từ PC đạt.

### 24.14. Tài liệu kỹ thuật tham chiếu

Tra cứu ngày 27/09/2026; dùng làm căn cứ cho thiết kế kỹ thuật, không biến ví dụ tài liệu thành lời bảo đảm bản game đã hoạt động.

- [Roblox — Client-server boundary](https://create.roblox.com/docs/scripting/security/client-server-boundary): kiểm tra dữ liệu, ngữ cảnh và tần suất yêu cầu tại máy chủ.
- [Roblox — Data stores](https://create.roblox.com/docs/cloud-services/data-stores): lưu bền vững, cập nhật dữ liệu và các giới hạn dịch vụ cần kiểm tra khi triển khai.
- [Roblox — Player data and purchasing](https://create.roblox.com/docs/cloud-services/data-stores/player-data-purchasing): quản lý dữ liệu người chơi, khóa phiên, xử lý lỗi và ghi dữ liệu theo thứ tự. Phần P1 bên trên là thiết kế riêng, chưa dùng mã ví dụ này để tuyên bố sẵn sàng phát hành.


## 25. Nền tảng kế thừa — sảnh Dark Jungle 12 base và bãi luyện tập v2.3 trong v2.4

### 25.1. Quyết định và giới hạn hiện hành

**Đã chốt bởi người dùng:** sảnh 12 người, mỗi người một base; ưu tiên map, khu luyện tập, vũ khí, giáp, đòn đánh, hình nộm và pet trước hệ thống săn. Tiếp tục bản v2.3 đã lưu, cải thiện cảnh quan theo hướng dark fantasy jungle. Bộ bãi tập mở rộng thành bảy vũ khí, mỗi loại bốn combo, có nối lướt và chuỗi múa; giảm tiêu hao thể lực xuống còn 30% mức cũ; dùng bốn icon Shop, Settings, Play, Inventory do người dùng tạo.

**Phạm vi bản thử:** trại và bãi tập trong cùng Place, chuyển qua cổng G hoặc UI Chơi. Vũ khí/giáp/pet hiện là mô hình thử; hiệu ứng combo chưa phải bộ animation toàn thân hoàn chỉnh. Sảnh có 12 base nhưng chưa kiểm chứng đủ 12 client; cần kiểm tra MaxPlayers = 12 khi xuất bản.

**Chưa triển khai trong giai đoạn này:** nhiệm vụ săn, quái săn thực, bẫy/bắt, phần thưởng/rơi đồ, chế/nâng cấp, tiền/giao dịch, kho cá thể/ống nghiệm, DataStore, quái giao chiến, hệ/biến thể, pet hồi/choáng và trang bị pet đầy đủ, điều khiển điện thoại hoàn chỉnh. Những yêu cầu này vẫn giữ trong hồ sơ.

Đoạn trên ghi phạm vi lịch sử L0/v2.3; bản hiện hành v2.4 đã có combat, Pet, nhiệm vụ/bắt, kinh tế và kho cá thể bộ nhớ ở mục 30–36. Chưa ống trưng bày/DataStore/săn đội/điện thoại hoàn chỉnh. Bảng 25.2 giữ nội dung nền tảng ở mốc bãi tập, không thay trạng thái hiện hành tại mục 37.

### 25.2. Nội dung đã triển khai trong v2.3

| Phần | Hiện trạng | Giới hạn |
| --- | --- | --- |
| Map chính | Dark Jungle có 12 base, đường nối, cây cổ thụ, khu đền, ba tầng thác và mặt nước | Thẩm mỹ/hiệu năng còn cần đánh giá; không coi đã hoàn thiện đồ họa |
| Đường đền | Sửa 10 WalkSurface và 8 MossEdging của TempleApproach; khôi phục tỷ lệ/vị trí nối tuyến | Đã đi thử hai chiều; chi tiết 25.9 |
| Base trong phiên | Gán base trống và trả khi người chơi rời | Chưa có lưu bố trí/cá thể; chưa thử 12 client |
| Bãi tập | 460 × 420 studs; sân võ ba hình nộm; bốn làn cung 30/60/90/120 studs; nhà vũ khí, hồ, cây, đèn và cổng về | Cùng Place; chưa có quái tấn công |
| Vũ khí | Búa, kiếm & khiên, katana, thương cán dài, song dao, cung, rìu đại hai lưỡi; mỗi loại bốn combo, tổng 28 | Thông số và hoạt ảnh thử; chưa cân bằng săn |
| Combo/lướt | Máy chủ xác nhận chuỗi, nhịp, thể lực và sát thương; có nối lướt, nhiều hit và chuỗi múa | Không thêm i-frame; cảm giác cần người dùng thử |
| Cung | Camera lệch vai phải, chuyển zoom/FOV mượt, tâm giữa viewport; hủy ngắm khi cất/chạy/mở menu phù hợp | Bắn raycast; chưa mô phỏng đạn cong |
| Giáp/khiên | Giáp ngoại hình mẫu; F giữ thế đỡ với kiếm & khiên | Chưa kiểm chứng giảm sát thương do bãi chưa có địch tấn công |
| Pet | Theo chủ, đánh hình nộm theo nhịp và đi cùng khi chuyển khu | Chưa có hồi chủ/choáng/trang bị nâng cao; không khẳng định mọi đường đi đều hết kẹt |
| UI | Bốn icon mở Túi đồ, Chơi, Cài đặt, Cửa hàng; HUD thể lực/combo/sát thương; chữ tiếng Việt qua kiểm tra UTF-8 | Túi đồ/cài đặt trong phiên; Shop chỉ xem, ghi Sắp mở |
| Dữ liệu | Trang bị thử, base và thống kê hoạt động trong phiên | Chưa lưu tài khoản, không có giao dịch hoặc thưởng săn |

### 25.3. Điều khiển và thông số thử hiện hành

| Thao tác | Phím/điều kiện |
| --- | --- |
| Di chuyển / chạy | WASD / Shift; chạy sau cất vũ khí |
| Rút/cất / chọn vũ khí | R / I hoặc Túi đồ; chọn khi cất và ở bãi tập |
| Thường / mạnh / kỹ năng | Chuột trái / Q / E |
| Nhảy / lướt | V / Space; Space không đồng thời nhảy mặc định |
| Ghim tâm / ngắm cung | Ctrl / giữ chuột phải khi rút cung |
| Giữ khiên | F với kiếm & khiên |
| Tương tác | Giữ G gần cổng, giá giáp, giá vũ khí hoặc bảng thống kê |
| Chuyển trại ↔ bãi tập | Cổng hoặc Chơi; phải cất vũ khí/dừng động tác |

- Bảy vũ khí có bốn chuỗi mỗi loại. Bảng 28 chuỗi, sát thương, số hit và thể lực đòn cuối ở [COMBOS_V2_3.md](<C:/Users/khanh/OneDrive/Documents/ChatGPT/game roblox/HunDino/COMBOS_V2_3.md>); đây là cấu hình thử hiện tại.
- Nối trong 1,35 giây sau đòn; cho nhập sớm một thao tác trong 0,2 giây cuối. Lướt giữ chuỗi; chuỗi có bước lướt sẽ ghi nhận bước đó. Cất/đổi, giữ khiên, chạy, nhảy, chuyển khu, chết hoặc hết hạn ngắt chuỗi.
- Chi phí thể lực nhân 0,30 đúng một lần, tức còn 30% mức cũ: lướt 6; chạy 3/giây; khiên 1,2/giây. Búa thường/mạnh/kỹ năng: 2,4/4,8/3,6. Đòn cuối theo bảng combo.
- Thể lực tối đa 100, hồi 20/giây sau 0,75 giây nghỉ. Lướt hiện dùng tốc độ đầu **72 studs/giây** trong **0,5 giây**, thực chi **6 thể lực**, không có bất tử; đo Play H1.3.1 khoảng **16,5–16,8 studs** trên nền thoáng (mục 30.1). Cấu hình 34/0,4 là mốc bãi tập cũ.
- Camera cung lệch vai phải, zoom 8,5 studs, FOV 58; độ nhạy ngắm cơ sở 65%, có tùy chọn trong Cài đặt. Nhả ngắm/cất/hồi sinh trả camera; menu Esc nhả chuột.
- Hình nộm tự hồi để luyện, không phát thưởng. Pet và giáp vẫn là mẫu trong bãi tập.

### 25.4. Kiểm chứng hiện tại

**Đã kiểm tra và đạt đến 09/10/2026:**

- Logic 28 combo, ngắt/hết hạn/thiếu thể lực và biên dịch source. Trong Studio, cả 28 chuỗi ra đúng đòn cuối; thử riêng bốn đòn cuối tầm hẹp/tầm xa sau lướt có sát thương.
- Phím/chuột thật Trái → Q → Space → E với búa ghi đúng chuỗi, tổng sát thương 246. Giữ khiên 5 giây tiêu 6; chạy 3 giây tiêu 9 thể lực.
- Bốn icon tải được, UI mở và thao tác được, chọn vũ khí/cài đặt/chuyển khu hoạt động; pet theo khi về trại. Kiểm tra UTF-8 của source/UI đạt.
- TempleApproach: 110 điểm dò có nền đỡ; đi đủ 10 đoạn tới đền và quay lại không cần nhảy hoặc dịch chuyển giữa tuyến.
- Sau lưu bằng Studio: sáu nhóm kiểm tra cấu trúc map và sáu nhóm bãi tập đạt; không có vật cản đường được bộ kiểm tra phát hiện. Không có lỗi gameplay trong Output ở các phiên đã thử.

**Chưa xác nhận:** tải đủ 12 client, điện thoại, hiệu năng trên máy yếu, bộ hoạt ảnh toàn thân, cảm giác lướt/camera theo đánh giá người dùng và cân bằng chiến đấu với quái thật. Các kiểm tra trên không chứng minh vòng săn hoặc lưu tiến trình đã hoàn thành.

### 25.5. File làm việc và cách tiếp tục

- Map mở/chỉnh tiếp trong Studio: **C:/Users/khanh/OneDrive/Documents/ChatGPT/game roblox/HunDino/HunDino_DarkJungle_v2_4.rbxl**. v2.3/Desktop là mốc trước, không dùng thay bản v2.4.
- Source, công cụ, tài liệu và bản map đồng bộ: **C:/Users/khanh/OneDrive/Documents/ChatGPT/game roblox/HunDino**. Giữ định dạng .rbxl; không dùng bản L0/v2.2/v2.3 làm đầu vào thay thế v2.4.
- Hash lịch sử của mốc v2.3 sau sửa TempleApproach (không phải hash v2.4 hiện hành): 07cf65d9cb5432aef1ea254a16f032c395ad5db6b4618615cc6455858fa74593. Đây là dấu mốc đối chiếu, sẽ đổi khi lưu thêm.
- Hai bản hồ sơ đồng bộ hiện tại là THIET_KE_GAME.md tại thư mục gốc dự án và HunDino/THIET_KE_GAME.md, cùng nội dung v0.39. Không ghi bản Desktop trong đợt này. Phiên bản hồ sơ độc lập với phiên bản map v2.4.
- Training server/client/cấu hình khớp Studio ở studio-pet-integration; các module hiện hành dùng từ src/dark-jungle, src/hunting và src/admin. Không chép toàn bộ nhánh Training khác đè lên bản Studio. Không đồng bộ default.project.json dành cho L0 vào map hiện tại; không dựng lại toàn map bằng bộ dựng cũ.
- Lưu bằng Studio để giữ Terrain; Lune chỉ dùng đọc/kiểm tra bản map hiện tại. Luôn bảo toàn sửa thủ công mới nhất trước khi đồng bộ file.
- Bản trước sửa đường đền: backups/HunDino_v2_3_before_temple_8c866132b89a.rbxl. Danh sách file có thể dọn tại DON_DEP_DU_AN.md; chưa xóa file.
- Kết quả thử chi tiết: TRAINING_SANCTUARY.md, COMBOS_V2_3.md và Training_v2_3_release.json.

### 25.6. Cập nhật phạm vi luyện tập v2.2 — 07/10/2026

Theo yêu cầu mới của người dùng, mở rộng bãi tập và đưa cả bảy vũ khí tại mục 18 vào để lựa chọn, thử đòn trên hình nộm. Giới hạn búa đầu tiên ở L0/P1 trước đây là lịch sử triển khai; không còn giới hạn bộ vũ khí của **bãi tập v2.2**.

- Bãi tập 460 × 420 studs, sân võ ba hình nộm, bốn làn cung 30/60/90/120 studs, nhà vũ khí, giá giáp, hồ/cây/đèn trang trí và cổng đi/về. Sảnh giữ 12 base.
- Bảy mẫu: búa, kiếm & khiên, katana, thương cán dài, song dao, cung, rìu đại hai lưỡi. Có mô hình, thường/mạnh/kỹ năng, thể lực và nhịp riêng. Búa giữ chuỗi thử thường → mạnh → kỹ năng kết thúc. Cung có ngắm và buff một mũi sau ngắm/lướt.
- I chọn vũ khí khi đang cất và ở bãi tập; R rút/cất, chuột trái/Q/E đánh, V nhảy, Space lướt, G tương tác. Kiếm & khiên dùng F giữ thế đỡ thử; chưa có giảm sát thương từ địch vì bãi chưa có địch tấn công.
- Thông số/hoạt ảnh này phục vụ thử nghiệm, không tự chốt combo đầy đủ, cân bằng, cơ chế kỹ năng cuối hoặc kiến trúc nhiệm vụ săn. Trang bị/giáp/pet vẫn chưa có dữ liệu lưu tài khoản.
- File tại mốc lịch sử này: **HunDino_DarkJungle_v2_2.rbxlx trên Desktop/game roblox/HunDino**; bản phát triển hiện đã chuyển sang v2.4 trong Documents theo 25.5. Source hiện hành ở Documents/ChatGPT/game roblox/HunDino; xem TRAINING_SANCTUARY.md để đọc kết quả kiểm tra và cách cập nhật an toàn. Không dùng bản L0 hoặc đồng bộ cấu hình Rojo cũ vào map mới.

### 25.7. Tiếp tục bản người dùng v2.3 — 08/10/2026

- File làm việc mới: **HunDino_DarkJungle_v2_3.rbxl** tại Desktop/game roblox/HunDino, do người dùng lưu từ v2.2. Tiếp tục nội dung hiện có, không dựng lại map hoặc quay về L0.
- Giữ bãi tập lớn, bảy vũ khí, giáp/pet mẫu và camera cung lệch vai. Ngắm chuyển mượt, tâm giữa màn hình trùng tia bắn; R cất cung hoặc Shift chạy sẽ hủy ngắm. Menu Esc được nhả chuột.
- Dùng định dạng Roblox Place `.rbxl` cho bản chỉnh tiếp: bản XML cũ có trường hợp bảng tiếng Việt bị đổi mã khi Studio lưu. Source và hướng dẫn hiện hành ở Documents/ChatGPT/game roblox/HunDino. Mọi thông số vũ khí vẫn chỉ là thử nghiệm.

### 25.8. Combo, lướt và bốn nút nhanh — 08/10/2026

**Yêu cầu mới:** mỗi vũ khí có bốn combo, có chuỗi kết hợp lướt và chuỗi múa; giảm mọi tiêu hao thể lực còn 30% mức trước; làm lướt bớt khựng. Dùng bộ icon Shop, Settings, Play, Inventory do người dùng tạo. Từ giai đoạn này cập nhật hồ sơ cùng mỗi đợt triển khai.

**Cấu hình bãi tập đã triển khai thử:** bảy vũ khí, tổng 28 chuỗi. Búa có chuỗi ngắn Trái → Q → E và chuỗi dài Trái → Q → Trái → E → E. Mỗi loại thêm Trái → Space → E và một chuỗi múa riêng. Danh sách đầy đủ, số hit, mức tiêu hao đòn kết thúc: [COMBOS_V2_3.md](<C:/Users/khanh/OneDrive/Documents/ChatGPT/game roblox/HunDino/COMBOS_V2_3.md>). Những câu chưa chốt ở mục 18 và giới hạn búa đầu tiên ở P1 là định hướng/lịch sử toàn game; không giới hạn bãi tập hiện tại.

- Chờ đòn trước hết động tác rồi nối trong 1,35 giây; cho nhập sớm một đòn trong 0,2 giây cuối. Máy chủ vẫn quyết định thời gian, thể lực và sát thương.
- Lướt giữ tiến trình combo; nếu chuỗi có bước lướt thì ghi nhận bước đó. Chuỗi không cần lướt vẫn tiếp tục được sau lướt. Cất/đổi, giữ khiên, chạy, nhảy, chuyển khu, chết hoặc hết hạn ngắt tiến trình. Đánh hụt vẫn có thể nối trong cấu hình thử.
- Mọi chi phí nhân 0,30 đúng một lần: chạy 3/giây, lướt 6/lần, khiên 1,2/giây. Hồi 20/giây, tối đa 100, trễ hồi 0,75 giây giữ nguyên. Thông số cũ tại 25.3 là lịch sử.
- Lướt vẫn 0,4 giây nhưng giảm tốc từ 34 về 16, không hạ tốc độ đi bộ xuống 8 trong lướt, giữ vận tốc theo hướng đi khi kết thúc. Không thêm i-frame.
- Hoạt ảnh mới là chuyển động vũ khí/vệt đòn; bộ animation toàn thân và cân bằng săn thật chưa chốt.

| Nút | Nội dung hiện tại | Chưa triển khai |
|---|---|---|
| Inventory / Túi đồ | Bảy vũ khí miễn phí trong phiên, xem bốn chuỗi mỗi loại; trang bị trong bãi tập khi cất | Kho tài khoản, chiến lợi phẩm, lưu DataStore |
| Play / Chơi | Chuyển trại ↔ bãi tập, đưa pet theo; yêu cầu cất/dừng động tác; cổng G vẫn hoạt động | Bảng nhiệm vụ săn và ghép đội |
| Settings / Cài đặt | Bật/tắt hướng dẫn, số sát thương, hiệu ứng combo; độ nhạy ngắm 100/75/50% | Lưu cài đặt qua phiên, điều khiển điện thoại đầy đủ |
| Shop / Cửa hàng | Giao diện bình hồi, bộ bẫy, thuốc ngủ; ghi rõ Sắp mở | Mua bán, tiền, giá và cấp vật phẩm |

**Quản lý file:** tiếp tục cùng tên `HunDino_DarkJungle_v2_3.rbxl`; giữ bản trước sửa và đồng bộ tài liệu. Chưa xóa lịch sử. Danh sách file giữ/có thể dọn và đối chiếu bản trùng ở [DON_DEP_DU_AN.md](<C:/Users/khanh/OneDrive/Documents/ChatGPT/game roblox/HunDino/DON_DEP_DU_AN.md>).

**Kiểm chứng:** 28 chuỗi đã ra đúng đòn kết thúc trong Studio; kiểm tra nhập sớm/lướt bằng phím thật, thể lực chạy/khiên, bốn UI và chuyển trại/pet đạt. Kết quả sau lưu ở TRAINING_SANCTUARY.md. Bản Desktop đầu vào có 10 miếng đường TempleApproach không khớp điểm tuyến cũ; lỗi đã tồn tại trước đợt combo/UI. Đợt đó giữ nguyên hình học; lỗi đã được sửa sau theo yêu cầu người dùng ngày 09/10/2026, xem 25.9.

### 25.9. Sửa đường vào đền TempleApproach — 09/10/2026

- Theo yêu cầu sửa lỗi đã ghi nhận ở 25.8, tiếp tục trên bản v2.3 hiện hành.
- Nguyên nhân: cả Model TempleApproach bị thu nhỏ còn khoảng 0,877 lần và dịch khỏi tuyến gốc, trong khi RouteStart/RouteEnd vẫn giữ điểm nối cũ. Khôi phục tỷ lệ 1 và căn tuyến theo các điểm này.
- Đã sửa đủ 10 WalkSurface cùng 8 MossEdging. Mặt đường rộng 20 studs, dày 2 studs, các đoạn nối chồng 1,2 studs; giữ Anchored và CanCollide.
- Kiểm chứng trong Studio: 110 điểm dò mặt đường đều có nền đỡ; nhân vật đi đủ 10 đoạn tới đền rồi quay về, không nhảy hoặc dịch chuyển giữa tuyến, không kẹt.
- Sau khi lưu bằng Studio: sáu nhóm kiểm tra map đạt, không có vật cản đường được phát hiện; sáu nhóm kiểm tra bãi tập/source cũng đạt. Cảnh báo bộ đọc Lune về thuộc tính Terrain chưa hỗ trợ chỉ xuất hiện khi đọc kiểm tra; không dùng Lune ghi lại map.
- Lỗi TempleApproach ghi tại 25.8 đã giải quyết. File tiếp tục dùng HunDino_DarkJungle_v2_3.rbxl trên Desktop; bản Documents được đồng bộ. Có bản sao trước sửa trong backups/HunDino_v2_3_before_temple_8c866132b89a.rbxl.
- Công cụ sửa riêng: tools/repair-temple-approach.luau, chỉ chạy trong Studio Edit; không dựng lại toàn map.

### 25.10. Việc còn mở và bước tiếp theo

**Giai đoạn hiện tại là v2.4, đến kho cá thể P1-F bước đầu.** Đã có sảnh/bãi tập, H2, combat/Pet, nhiệm vụ/bắt, kinh tế và bộ sưu tập trong cùng máy chủ; chưa hoàn thành toàn bộ P1.

1. P1-F còn chọn cá thể vào một ống trưng bày và lớp lưu tài khoản trong môi trường test riêng; không coi kho bộ nhớ là đã lưu bền vững.
2. Chế tạo trong Inventory tiếp tục là khung chờ; bàn chế/nâng thử P1-E tại base đã có, không tự mở thêm giao dịch theo tab.
3. P1-G còn hồi quy toàn vòng, lỗi lưu/mất kết nối/chống trùng. Săn đội, nhiều client thật, điện thoại và hiệu năng máy yếu cần nghiệm thu riêng.
4. Tiếp tục thu phản hồi vũ khí/lướt/camera/cảnh quan/hoạt ảnh; thông số thử chưa phải cân bằng hoặc đồ họa cuối.

**Chưa chốt toàn game vẫn giữ nguyên:** thông số/cân bằng vũ khí với quái, cơ chế săn đội và đóng góp 10%, chi tiết các loài/hệ/bộ phận, phần thưởng/công thức, kho/trưng bày, pet nâng cao và các mục đang gắn nhãn còn mở. Thông số thử v2.3 không tự thay các quyết định này.

Đợt đồng bộ hồ sơ này chỉ cập nhật trạng thái, hướng dẫn và dẫn chiếu; không thay đổi map, mã nguồn hoặc tự triển khai thêm hệ thống.

## 26. Ý tưởng khu săn và chu kỳ ngày/đêm — 15/10/2026

### 26.1. Phạm vi hiện tại

- **Đã thống nhất:** làm demo 3D có thể xem và chỉnh để góp ý trước; chỉ dựng vào Roblox sau bước duyệt ý tưởng. Không coi demo là map chơi được, AI, va chạm hoặc đường đi đã kiểm chứng.
- **Đã thống nhất:** thiên nhiên bí hiểm hơn nhưng không quá tối. Sáng/tối thay đổi theo thời gian trong cuộc săn; ban đêm vẫn cần đọc được đường đi, quái và động tác chiến đấu.
- **Đề xuất trong demo:** rừng lòng chảo, hồ trung tâm, trại phía nam, ba bãi săn quanh hồ và đường nối thành vòng; phế tích phụ. Tăng cây cổ thụ, rễ bạnh, dây leo, dương xỉ, sương nhẹ và nấm sáng ven đường. Chưa chốt bố cục, kích thước, màu hay mức sáng cuối cùng.
- Mẫu thử dùng khung 1.080 × 1.080 studs; giữ thao tác người dùng đã thử: trại rộng 120 studs, mật độ cây 70%. Đây là giá trị bản xem, không phải thông số map chính thức.

### 26.2. Đồng hồ và ánh sáng — yêu cầu người dùng

1. Khi vào khu săn, đồng hồ/ánh sáng khởi tạo theo giờ thực tại thời điểm vào. Ví dụ ngoài đời 14:00 thì trong map bắt đầu là 14:00; giữ cả phần phút.
2. Khi nhiệm vụ bắt đầu, **mỗi 2 phút thật tương ứng 1 giờ trong map**: thời gian môi trường chạy nhanh gấp 30 lần. Không đồng bộ lại giờ thực liên tục để ghi đè đồng hồ đang tăng tốc.
3. Giờ trong map = giờ khởi tạo + thời gian thật từ khi bắt đầu nhiệm vụ × 30; chuyển qua nửa đêm bình thường.
4. Sáng/tối đổi dần qua ban ngày, hoàng hôn, ban đêm và bình minh. Ban đêm giữ ánh sáng nền đủ quan sát; đề xuất ánh trăng, nấm sáng và đèn trại làm điểm định hướng.
5. Đồng hồ tăng tốc áp dụng cho lượt ở khu săn đến khi rời khu săn về sảnh trung tâm; lượt săn tiếp theo khởi tạo lại theo giờ thực lúc vào. Không mang giờ tăng tốc của cuộc săn áp lên sảnh.
6. Ví dụ vào 14:00: sau 2 phút săn → 15:00; 8 phút → 18:00; 20 phút → 00:00 hôm sau; 40 phút → 10:00 hôm sau. Cuộc săn 40 phút đi qua **20 giờ trong map**.
7. Đây là đồng hồ môi trường, không rút ngắn thời lượng nhiệm vụ, hồi chiêu, bẫy 13 giây, choáng pet 30 giây hoặc 120 giây thu hoạch. Hoàn thành sớm vẫn có giai đoạn thu hoạch rồi về sảnh như mục 20.

### 26.3. Lựa chọn thử và điểm còn mở

- Demo lấy giờ thực theo **UTC+7**, có ô đổi giờ vào và thanh tiến độ 0–40 phút để xem ánh sáng. Nút xem nhanh chỉ trình diễn 1 giây = 1 phút săn; phép quy đổi trong lượt săn vẫn là 2 phút thật/giờ trong map.
- Demo chưa mô phỏng nhiệm vụ thắng/thua hoặc chuyển về sảnh. Mốc 40 phút là giới hạn thanh xem thử, không mặc định nhiệm vụ luôn thành công ở phút 40.
- **Đề xuất kỹ thuật:** một đồng hồ chung do máy chủ giữ cho mỗi lượt săn; các thành viên cùng lượt thấy cùng giờ, không dùng đồng hồ môi trường riêng theo từng máy.
- **Chưa chốt:** múi giờ khởi tạo khi đội có người ở nhiều múi giờ, xử lý chờ trước lúc bắt đầu nhiệm vụ, mức sáng nền cuối cùng và ánh sáng của sảnh. Việc tiếp tục đồng hồ qua 120 giây thu hoạch đến khi rời khu săn là cách hiểu hiện tại theo yêu cầu, cần đối chiếu khi triển khai.

**Trạng thái:** cập nhật bản xem ý tưởng và hồ sơ; chưa sửa place `.rbxl`, source gameplay hoặc hệ thống Lighting trong Roblox Studio.

### 26.4. Tám khu di chuyển cho mỗi khủng long

**Đã thống nhất theo yêu cầu người dùng:** mỗi con khủng long có **8 khu để di chuyển qua lại**, gồm **3 khu chính hiện tại** và **5 khu phụ để đi qua/nghỉ chân**. Không chỉ giới hạn mỗi con ở một bãi chính.

**Mạng khu dùng trong bản xem:** cả ba con đều tiếp cận được cùng một mạng 8 khu, với các tuyến qua A/B/C và R1–R5 như yêu cầu tại mục 26.5. Trại người chơi tách riêng, không tính vào 8 khu của thú. Chưa thiết kế thêm lãnh thổ hoặc điểm nghỉ dành riêng cho từng loài.

| Khu | Vai trò | Cảnh quan đang đề xuất |
| --- | --- | --- |
| A | Chính | Bãi ven hồ rộng, dễ quan sát giao chiến |
| B | Chính | Rừng đá, khoảng trống ở giữa |
| C | Chính | Tổ/bãi cao phía bắc |
| R1 | Nghỉ chân | Gốc cổ thụ, rễ bạnh và bóng tán |
| R2 | Nghỉ chân | Hõm đá phủ rêu, lối vào/ra hai phía |
| R3 | Nghỉ chân | Tận dụng khu phế tích sẵn có |
| R4 | Nghỉ chân | Bờ suối/vũng nước nhỏ |
| R5 | Nghỉ chân | Lùm dương xỉ ven hồ |

- Demo cho chọn con A/B/C, tuyến và chiều đi để xem mô hình chuyển khu. Mỗi con có thể tiếp cận đủ 8 khu; gồm vòng đi đủ 8 khu và nhánh ngắn quay về nghỉ theo mục 26.5. Không yêu cầu mọi tuyến ngắn đều phải đi qua đủ 8 khu.
- Mạng đường có vòng quanh hồ và nhánh rẽ; không hiểu tuyến mẫu là lịch bắt buộc hoặc yêu cầu mỗi con phải ghé đủ 8 khu trong một nhiệm vụ.
- **Đề xuất:** giữ lối chuyển khu và mặt nền đủ thoáng cho thân/đuôi thú, người chơi đuổi theo và pet; giữ cửa ra/vào các điểm nghỉ. Cần thử va chạm, quay đầu và tìm đường thật khi dựng Roblox.
- **Chưa chốt:** điều kiện đổi khu khi bị săn, thời gian ở mỗi khu, nghỉ/ngủ/uống nước, hồi máu tại điểm nghỉ và tần suất các con gặp nhau. Điểm nghỉ không tự đồng nghĩa vùng an toàn, hồi máu hoặc không thể giao chiến.
- Khung 1.080 × 1.080 studs và kích thước khu vẫn là giá trị phác thảo; sẽ điều chỉnh theo tỷ lệ thú và khoảng cách di chuyển sau góp ý.

**Trạng thái:** đã mở rộng bản xem ý tưởng; chưa triển khai AI di chuyển hoặc sửa map Roblox.

### 26.5. Nhiều tuyến hai chiều và nghỉ ở điểm xuất phát

**Đã thống nhất theo yêu cầu người dùng:**

- Con A xuất hiện ở khu A và nghỉ chân trước khi đi. Tuyến được chỉ định: **A → R2 → C → R3 → B → R4 → R5 → R1 → A**.
- Có thể đi đảo chiều và chọn nhánh khác. Ví dụ người dùng: từ A đi **R1 → R5 → R4 → B**, sau đó đi **thẳng B → R1 → A** để về nghỉ; không bắt buộc hoàn thành trọn vòng qua đủ 8 khu mỗi lần.
- Áp dụng nguyên tắc cho cả ba con: con A/B/C có điểm xuất phát tương ứng A/B/C, nghỉ lúc xuất hiện, đi qua các khu theo nhiều tuyến rồi có thể quay về điểm xuất phát nghỉ chân.
- Người dùng cho phép tạo thêm đường nối và tuyến khác. Không khóa cả ba con vào một vòng duy nhất hoặc một chiều cố định.

**Đường nối thêm trong demo:** B ↔ R1 men bờ nam hồ; C ↔ B qua sườn đông; C ↔ R5 qua bờ tây. Đây là đường nối trực tiếp giữa hai khu, không đòi dừng ở các khu khác trên đường. Các nhánh cũ vẫn đi được hai chiều.

**Các lộ trình xem thử:** vòng đủ 8 khu của A giữ đúng yêu cầu; các tuyến B/C và các nhánh chéo là đề xuất của trợ lý trong phạm vi người dùng cho phép. Mỗi hàng đều có thể đảo chiều.

| Con | Loại tuyến | Lộ trình |
| --- | --- | --- |
| A | Vòng đủ 8 khu — người dùng chỉ định | A → R2 → C → R3 → B → R4 → R5 → R1 → A |
| A | Nhánh ngắn theo ví dụ người dùng | A → R1 → R5 → R4 → B → R1 → A |
| A | Đường chéo đề xuất | A → R5 → C → B → R1 → A |
| B | Vòng đủ 8 khu | B → R4 → R5 → R1 → A → R2 → C → R3 → B |
| B | Nhánh ngắn | B → R1 → A → R5 → R4 → B |
| B | Đường chéo | B → C → R2 → A → R1 → R5 → B |
| C | Vòng đủ 8 khu | C → R3 → B → R4 → R5 → R1 → A → R2 → C |
| C | Nhánh ngắn | C → R5 → R1 → A → R2 → C |
| C | Đường chéo | C → B → R1 → R5 → C |

- Demo có 3 lựa chọn tuyến và chiều thuận/ngược cho từng con. Đổi tuyến xem thử sẽ đưa riêng con được chọn về điểm xuất phát; đây là thao tác xem phương án, không phải quy tắc dịch chuyển trong gameplay.
- Demo hiển thị nghỉ trước khi đi và sau khi về điểm xuất phát; nhấn nút để chuyển sang chặng tiếp theo. Chưa tự đặt thời gian nghỉ, xác suất chọn tuyến hay lịch bắt buộc.
- **Đề xuất khi lập trình sau:** AI chọn nhánh trên mạng đường hai chiều, có thể đổi hướng; ưu tiên theo hành vi và tình huống cuộc săn. Chưa chốt đổi tuyến lúc nào, quy tắc tránh lặp, phản ứng khi bị săn hoặc cơ chế hồi phục khi nghỉ.
- Chưa kiểm chứng bề rộng, độ dốc, va chạm, tìm đường cho thân/đuôi quái trên Roblox; vị trí và hình dáng các đường mới vẫn có thể chỉnh trong giai đoạn duyệt bố cục.

**Trạng thái:** cập nhật demo và hồ sơ; chưa dựng đường hoặc AI này trong Roblox Studio.

### 26.6. Duyệt bản ý tưởng — 15/10/2026

Người dùng xác nhận bản demo hiện tại ổn sau khi xem bố cục và các tuyến bổ sung. **Đã duyệt ở mức ý tưởng** để làm cơ sở dựng khung map Roblox:

- Rừng cổ có thiên nhiên bí hiểm nhưng vẫn đủ sáng để quan sát; hồ làm mốc định hướng, có cây lớn, rễ, dây leo, dương xỉ, sương nhẹ và nấm sáng.
- Mạng 8 khu dùng chung cho ba con: A/B/C là ba khu chính và điểm xuất phát tương ứng; R1–R5 là năm điểm đi qua/nghỉ chân; trại người chơi tách riêng.
- Nghỉ ở điểm xuất phát, di chuyển theo nhiều tuyến hai chiều và có thể quay về nghỉ; giữ hai tuyến A người dùng chỉ định và các đường nối B ↔ R1, C ↔ B, C ↔ R5 trong bản xem.
- Giờ môi trường lấy giờ thực lúc vào khu săn, tăng tốc từ khi nhiệm vụ bắt đầu theo tỷ lệ 2 phút thật = 1 giờ trong map; giữ mức sáng ban đêm đủ nhìn đường và giao chiến.

Kích thước 1.080 × 1.080 studs, bề rộng khu/đường, mật độ cây 70% và hình học chi tiết vẫn là giá trị thử để điều chỉnh theo tỷ lệ quái và trải nghiệm trong Roblox. Thời gian nghỉ, lựa chọn tuyến của AI, điều kiện đổi khu khi bị săn và các điểm còn mở ở 26.3–26.5 chưa tự được chốt bằng việc duyệt hình ảnh.

Bước triển khai kế tiếp là dựng khung địa hình và đường nối theo bản ý tưởng này, giữ sảnh/bãi tập v2.3 hiện có, rồi kiểm tra tỷ lệ, độ dốc, va chạm và không gian quay đầu trước khi làm chi tiết. Đợt xác nhận này chỉ cập nhật hồ sơ; chưa sửa place hoặc source Roblox.

## 27. Khung map săn Rừng cổ H1.0 — 15/10/2026

**Yêu cầu mới:** đã có một con khủng long thử nghiệm; chuyển từ duyệt ý tưởng sang tạo map. Thực hiện trên phiên `Dinosaur01_TRex_Visual.rbxl` đang mở và Save As sang file khu săn riêng trước khi dựng. Không tự đưa thêm ba loài hoặc nhân bản ba con giống nhau.

### 27.1. Bản làm việc và phạm vi đã dựng

- Mở **C:/Users/khanh/OneDrive/Documents/ChatGPT/game roblox/HunDino/HunDino_HuntingRainforest_v1.rbxl**. Đã lưu bằng Studio; SHA256 `6335460f3a9b9e9fbb6b862f8289fe08c2297a1d8a6c3756e236514a9deb9395`, dung lượng 1.210.141 byte.
- Giữ nguyên file `Dinosaur01_TRex_Visual.rbxl` và map sảnh/bãi tập `HunDino_DarkJungle_v2_3.rbxl`. Bản sao trước dựng: `HunDino/backups/Dinosaur01_before_hunting_map_20261015.rbxl`.
- Dựng Terrain/hồ, tám khu quái A/B/C/R1–R5, trại người chơi, cây/cổ thụ/rễ/dây leo/dương xỉ, đá rêu/phế tích và nấm sáng dẫn đường. Đây là khung cảnh có thể chỉnh, chưa là đồ họa hoàn thiện.
- Nới mặt bằng theo tỷ lệ con mẫu: **1.620 × 1.620 studs**, đường quái rộng **72 studs**. Giữ bố cục từ demo, cao độ nhẹ, bo góc và san nền theo bề rộng đường.
- Đủ **13 đường quái hai chiều + hai đường trại**. Cấu hình giữ chín lộ trình và các nhánh B ↔ R1, C ↔ B, C ↔ R5. Đã có node/waypoint để nối AI sau.
- Con mẫu đặt ở A, giữ 255 BasePart/21 MeshPart/bảy Motor6D/247 WeldConstraint/một thân gốc Anchored. Tắt và cất bộ điều khiển xem khủng long F/G/R/C cũ; giữ module/runtime rig trên model, không tự bật đi vòng cũ.
- Runtime ánh sáng lấy giờ thực UTC+7 khi Play và tăng tốc 30 lần; có sáng/tối, ánh trăng/nền sáng và hiệu chỉnh nâng vùng tối. **Đây là đồng hồ xem map; chưa nối bắt đầu/kết thúc nhiệm vụ thật hoặc về sảnh**. Trong Edit để 14:00 cho dễ xem.
- Play có camera nhân vật bình thường, Shift chạy; M mở bảng chọn khu xem nhanh chỉ trong Studio. Bảng này không phải cơ chế dịch chuyển chính thức của cuộc săn.

### 27.2. Kết quả kiểm chứng và giới hạn

- 288/288 kiểm tra live đạt; 4.308 điểm dò nền trên tâm/hai bên đường không phát hiện hố hoặc lệch mặt quá ngưỡng. Độ dốc mặt nền lớn nhất đo được 18,82°; không thấy vật trang trí có va chạm chắn hành lang 40 × 50 studs đã dò.
- Play đi từ A tới R2 và qua tuyến C–R5, kết thúc với 100 máu. Phím M và bấm chọn C hoạt động; camera Custom, bộ GUI mẫu cũ không còn chiếm điều khiển; nhật ký lỗi client lượt cuối rỗng.
- Đo tỷ lệ đồng hồ qua hai giây thực được xấp xỉ 30 lần. Đã xem cảnh ban ngày và ban đêm; mức sáng vẫn cần phản hồi người dùng.
- Đọc file sau Save: source/runtime khớp file làm việc sau chuẩn hóa xuống dòng; 25 script biên dịch được, rig con mẫu nguyên vẹn. Lune chỉ đọc vì chưa hỗ trợ đầy đủ thuộc tính Terrain `VoxelGridAssetContentMap`; lưu map bằng Studio.
- **Chưa làm:** AI quái tự chạy/nghỉ/đảo tuyến, đấu/bắt quái, nhiệm vụ/phần thưởng/lưu, kết nối khu săn riêng tới sảnh. Mạng đường đi được với người chơi không chứng minh AI của quái đã tìm đường được.
- **Chưa kiểm chứng:** nhiều client, điện thoại, hiệu năng máy yếu và độ vừa của mọi loại quái tương lai. Kích thước/mật độ cây là cấu hình thử có thể sửa.

Tài liệu chi tiết/cách xem: `HunDino/HUNTING_MAP.md`. Source: `HunDino/src/hunting/`. Kết quả và ảnh: `HunDino/assets/hunting/`. Tiếp tục chỉnh trên file H1.0 đã lưu; không chạy lại bộ dựng L0 hoặc ghi lại Terrain bằng Lune.

## 28. Rừng dày, vách đá ngăn khu và khủng long đi tuyến H1.1 — 15/10/2026

Người dùng thấy map còn thoáng và con mẫu chưa di chuyển; yêu cầu bổ sung cây/vách đá chia không gian và cho con mẫu đi lại. Tiếp tục trên `HunDino_HuntingRainforest_v1.rbxl`; sao lưu trước sửa tại `HunDino/backups/HuntingRainforest_before_density_routes_20261015.rbxl`.

- Bổ sung **360 cây nhiều tầng tán, 150 cụm dương xỉ và 100 khối đá rêu** thành chín dải; các dải nội bộ chia A/R2, R2/C, B/R3, B/R4, R1/R5 và vùng R5/R4. Giữ khe đi qua, bãi chiến đấu và hồ; không sửa Terrain/đường hiện có.
- Con mẫu duy nhất ở A tự tuần tra: vòng đủ tám khu giữ đúng `A → R2 → C → R3 → B → R4 → R5 → R1 → A`, rồi lần lượt thử hai nhánh còn lại và đổi chiều mỗi vòng. Giữ bộ hàm/rig cũ, tắt MotionRuntime đi vòng tròn, dùng DinosaurRouteController điều khiển thân cùng sáu khớp; JawRuntime vẫn giữ.
- Thông số thử có thể sửa: nghỉ đầu 5 giây, tốc độ 12 studs/giây; về A nghỉ 20 giây, điểm R nghỉ 6 giây, B/C nghỉ 4 giây. Quay theo đường trước khi tiến, bám nền và dừng nếu thiếu đất. Đây là giá trị thực hiện để xem thử, chưa chốt cân bằng game.
- HUD thêm khu khủng long vừa qua/đang tới và trạng thái nghỉ. Phím M tiếp tục chọn khu trong Studio. Mở Play và chờ khoảng năm giây để thấy con mẫu bắt đầu.
- **Kiểm chứng:** 291/291 kiểm tra map đạt; sáu vòng A (ba tuyến × hai chiều) trên bản sao đạt 148/148, đúng thứ tự, về A nghỉ, không thiếu nền hoặc giao vật cản trong 1.804 lần dò hộp bao toàn thân. Play thường xác nhận đi A → R2 rồi tiếp tục C; đo khoảng 36,49 studs/ba giây, client nhận trạng thái và không có lỗi runtime ở lượt kiểm tra.
- **Còn lại:** tuần tra hiện chưa né vật cản động, đuổi/đánh người chơi hoặc phản ứng khi bị săn; chưa có nhiệm vụ/phần thưởng/bắt giữ hoặc nối về sảnh. Chưa thử hiệu năng điện thoại/máy yếu/nhiều client sau khi tăng cây. Không tự thêm con mới ở B/C.

Source thêm: `DinosaurRouteController.luau`, `EnhanceHuntingForest.luau` trong `HunDino/src/hunting/`. Hồ sơ chi tiết/cách chỉnh: `HunDino/HUNTING_MAP.md`; kết quả: `assets/hunting/validation-h11.json`, `routes-h11.json`, `saved-place.json`.

## 29. Nối sảnh ↔ khu săn H1.2 — 16/10/2026

Người dùng yêu cầu liên kết map đi săn với sảnh. Đã thực hiện trên bản `HunDino/HunDino_DarkJungle_v2_3.rbxl`, sao lưu ngay trước ghép tại `backups/Hub_before_hunting_link_20261016.rbxl`.

- **Vào:** Chơi → VÀO KHU SĂN · RỪNG CỔ, hoặc giữ G tại cổng đá rêu bên trái sảnh. **Về:** nút trong HUD, menu Chơi hoặc cổng G tại trại săn. Dùng cùng luồng travel để cất vũ khí/hủy động tác, tải vùng đích và chuyển cả Pet; giữ base/trang bị.
- Ghép khu săn vào **cùng Place** tại offset `(0,0,6500)`, giữ vị trí các khu cũ. Copy Terrain bằng bốn vùng native, dịch cả node/đường và thuộc tính waypoint. Không Clear Terrain hoặc xây lại sảnh. File săn H1.1 giữ riêng làm nguồn; không cần PlaceId khác để thử Play.
- Clock theo từng người: lấy giờ vào UTC+7 do server cấp, tăng tốc 30 lần trên client đang săn; về sảnh/chết thì phục hồi Lighting/Atmosphere/màu. Người ở sảnh không chịu clock săn. Pet và điều khiển bản sảnh giữ Shift chạy, V nhảy, Space lướt.
- Lượt xem thử mặc định **40 phút** có thể chỉnh, hết giờ tự về cùng Pet; chưa phải nhiệm vụ có mục tiêu/thưởng. Người đầu tiên vào khởi động tuần tra con mẫu; người cuối ra thì dừng và phục hồi về A. Chết/hồi sinh hoặc ra biên cũng dọn phiên và về sảnh. M chỉ chọn khu trong Studio khi đang săn, không khởi động lại đồng hồ.
- **Kiểm tra:** 188/188 Edit; đi–về bằng UI/cổng G thật; Pet và base/trang bị giữ đúng; client clock rừng tách server/sảnh và phục hồi chính xác. Chết/ra biên/timeout đạt; timeout thử với 30 giây rồi đã phục hồi 2.400 giây trước Save. Yêu cầu từ base xa/đích sai/M ngoài rừng bị từ chối; bãi tập vẫn đi–về được; không thấy lỗi runtime ở lượt kiểm tra.
- Đọc file sau Save: 15.066 part gốc và 16 source không liên quan giữ nguyên so với backup ngay trước ghép; 10 source hiện hành khớp, 34 script biên dịch. Các chỉnh Welcome/đá có sẵn của người dùng không bị trả về snapshot cũ.
- **Còn lại:** combat săn, đuổi/bắt quái, nhiệm vụ/thưởng/lưu và server săn riêng theo đội; chưa thử nhiều client thực, điện thoại hoặc máy yếu.

Chi tiết/file kiểm chứng/source tại `HunDino/HUNTING_LINK.md`. Bản chung đã lưu bằng Studio; không dùng Lune ghi file có Terrain và không đồng bộ bộ dựng L0 lên bản này.

## 30. Nghỉ một phút, thanh máu và phản công H1.3 — 17/10/2026

Người dùng yêu cầu mỗi chỗ dừng chân nghỉ một phút, thêm thanh máu/hitbox tấn công và cho khủng long đánh lại người đã tấn công nó. Tiếp tục trên bản chung `HunDino/HunDino_DarkJungle_v2_3.rbxl`; giữ bản săn riêng H1.1. Backup ngay trước sửa: `HunDino/backups/Hub_before_dinosaur_combat_20261016.rbxl`.

- **Đã thống nhất và triển khai:** A/B/C/R1–R5, kể cả điểm xuất phát, đều nghỉ **60 giây thực**. Không quy đổi theo đồng hồ rừng tăng tốc. HUD đếm giây còn lại; mạng tuyến và các lựa chọn chiều đi giữ nguyên. Đây thay thế các số nghỉ mẫu 5/20/6/4 giây ở mốc H1.1 trong bản chung.
- Con mẫu có thanh máu cập nhật theo sát thương và bốn vùng trúng tại thân, đầu, hai chân để người đứng mặt đất đánh được. Vùng cắn sát đất báo cam trước, đỏ khi hoạt động; kiểm tra hướng, khoảng cách, vật cản và overlap nhân vật thật; mỗi lần cắn chỉ trừ máu một lần.
- Bình thường chỉ tuần tra/nghỉ; người đi ngang không gây chú ý. Đòn vũ khí hợp lệ kích hoạt đuổi/phản công người đánh. Có thể né sang bên trong nhịp báo trước. Khi mất mục tiêu, ra xa, ngừng bị đánh lâu, người chết hoặc về sảnh thì bỏ đuổi; trở lại vị trí tuyến đã gián đoạn và tiếp tục phần nghỉ còn lại.
- **Cân bằng mẫu có thể sửa:** 1.200 HP; cắn 24 HP; báo trước 0,65 giây, vùng trúng hoạt động 0,18 giây, hồi chiêu 2,5 giây; đuổi 16 studs/giây, giới hạn 260 studs và bỏ đuổi sau 25 giây không bị đánh. Không tự coi các số này là cân bằng toàn game đã duyệt.
- Đã nối bảy vũ khí/cung và bộ combo hiện có với sát thương server trong khu săn; túi đồ dùng được khi cất vũ khí. Giữ cơ chế tụ lực cung; loạt tên có nhịp để mọi mũi hợp lệ được nhận. Không có remote nhận sát thương tự khai từ client.
- Máu con mẫu dùng chung trong server. Người đầu vào khởi động, người cuối ra khôi phục A/đầy máu; người mới vào khi vẫn còn người săn không hồi lại máu. HP 0 dừng AI đến khi phiên reset. Pet chỉ theo cùng; chưa hỗ trợ đánh quái. Chưa thêm khủng long B/C, hoạt cảnh chết, bắt giữ, nhiệm vụ, thưởng hoặc lưu tiến trình.
- **Kiểm chứng:** 96/96 bài kiểm tra bản sao đạt, đủ 60 giây tại cả tám khu, hurtbox/thanh máu, trúng/né/cooldown/LOS, người đi ngang, thoát và chết/reset. Bài thử dùng adapter Player trên module bản sao vì command context thiếu WritePlayer; source cài đặt giữ guard Player thật. Sáu nhóm luật vũ khí đạt. Play với người thật: búa trừ 36, cung tụ lực trừ 104, ba tên trừ đủ 72; khủng long phản công, về sảnh hủy đòn/mục tiêu và reset khi phiên hết người. Ảnh native xác nhận thanh máu hiển thị.
- Đọc file sau Save: toàn bộ **23.693 part** cảnh khớp backup trước combat; rig vẫn 255 part/21 MeshPart/7 Motor6D/247 WeldConstraint/một thân neo. 14 source hiện hành khớp file làm việc, 44 script biên dịch; 14 source không liên quan giữ nguyên so với trước ghép sảnh. Lưu native Studio, không ghi Terrain bằng Lune.

Hồ sơ chi tiết/cách thử: `HunDino/DINOSAUR_COMBAT.md`; bằng chứng: `assets/hunting/combat-validation.json`, `connected-saved.json`, `dinosaur-healthbar-h13.jpg`. Chưa thử nhiều client thực, điện thoại hoặc cân bằng trận săn hoàn chỉnh.

### 30.1. Chậm cú cắn và kéo dài quãng lướt H1.3.1 — 17/10/2026

Người dùng thấy đòn khủng long quá nhanh, muốn chậm thêm 0,3 giây, nghỉ giữa đòn lâu hơn và lướt xa hơn để né. Đã tăng báo trước **0,65 → 0,95 giây**, chu kỳ bắt đầu đòn **2,5 → 3,5 giây**. Thời gian nghỉ ở điểm vẫn 60 giây thực; sát thương cắn và hitbox giữ nguyên.

Lướt hiện hành dùng cấu hình Studio chính xác: tốc độ đầu **42 → 72 studs/giây**, thời lượng **0,4 → 0,5 giây**; vẫn thực chi 6 thể lực, giữ đường giảm tốc/VFX và các điều kiện đang bận/hết thể lực. Quãng lý thuyết 9,87 → 17,33 studs; client Play đo **16,55 studs**, lượt né ngang **16,77 studs** không tăng số lần trúng cắn. Đo cảnh báo 0,9504 giây và chu kỳ 3,5153 giây. Lướt đang bị khóa trong hồi động tác vũ khí hoặc lướt quá trễ vẫn có thể trúng; không thêm bất tử.

96/96 kiểm tra combat đạt; kiểm tra dash, nguồn cấu hình/server/VFX sau Save đạt. Bằng chứng `HunDino/assets/hunting/combat-pacing-h131.json`. Backup `HunDino/backups/Hub_before_combat_pacing_20261017.rbxl`. Lưu bản chung bằng Studio; không thay file rừng riêng hoặc nguồn Evades hiện đại khác với bản đang cài.

## 31. Thung Lũng Sương Xám H2.0 — 19/10/2026

Người dùng yêu cầu nâng cấp cảnh quan dựa trên `thiết kế map săn.md` và xác nhận **mở rộng thành 4.000 × 4.500 studs theo prompt**, thay cho khung 1.620 × 1.620 cũ. Đã chuyển thành thung lũng ôn đới đầu thu, thiên nhiên bí hiểm nhưng vẫn dễ quan sát. Phía Bắc là +Z, map săn vẫn đặt ở offset (0, 0, 6500) để tiếp tục nối cùng sảnh.

Tám vùng gồm trạm kiểm lâm phía Nam, đồng cỏ/rừng thưa, rừng thông già phía Tây, hồ trung tâm có đảo, đầm lầy phía Đông, trại gỗ bỏ hoang, khe đá/suối có thác và dãy núi có hang phía Bắc. Công trình, bến gỗ, đường ván, dấu tích và đá/cây giúp phân biệt vùng và tạo điểm khám phá; các vật cảnh này chưa phải nhiệm vụ hoặc vật phẩm có thưởng.

Giữ 9 node (Camp, A/B/C, R1–R5), 13 đường khủng long hai chiều và 9 lịch trình đã duyệt; bổ sung 3 lối người chơi từ trạm. Đường khủng long có hành lang đi 72 studs, phần đất lộ hẹp hơn và cây/đá nằm ngoài khoảng trống của toàn thân con mẫu. Độ cao đường được làm liên tục qua điểm nghỉ và ngã rẽ. Cảnh dùng Terrain gốc của Studio cùng cây mesh nhiều biến thể, đá PBR, bụi dương xỉ và cỏ.

Giữ đúng nghỉ **60 giây thực** tại mọi điểm; 1.200 HP, cắn 24 sát thương, báo trước 0,95 giây và chu kỳ đòn 3,5 giây. Lướt và điều kiện phản công vẫn theo H1.3.1. Đồng hồ vào map lấy giờ UTC+7, sau đó chạy ×30; 2 phút thực = 1 giờ trong map, phiên thử 40 phút. Ánh sáng, màu Terrain/nước và hiệu ứng màu của sảnh được khôi phục khi quay về. Pet tiếp tục đi cùng.

Map và source được lưu trong bản chung `HunDino/HunDino_DarkJungle_v2_3.rbxl`; rừng H1.3.1 cũ được lưu ở ServerStorage và có backup file trước nâng cấp. Không ghi Terrain qua Lune, không thay hình học sảnh/base và không dựng lại project L0. File săn riêng H1.1 giữ nguyên. Nguồn tài sản, cách chơi và kết quả kiểm chứng H2 được ghi tại `HunDino/GREY_MIST_VALLEY.md` và `HunDino/assets/hunting/grey-mist-*.json`.

Đã kiểm tra lại sau khi mở file native đã lưu: 39.081 kiểm tra địa hình/cảnh quan và 26.259 kiểm tra bản lưu đạt; 2.400 cây, 578 mẫu khoảng trống toàn thân không bị cảnh cản. 148 kiểm tra tuần tra/6 vòng thử, 96 kiểm tra combat và 12 kiểm tra đồng hồ đạt. Play thật xác nhận lối ra đảo, xuyên hang, đòn bắn trúng/phản công, quay về sảnh cùng Pet và phục hồi môi trường. Giữ nguyên 15.089 phần sảnh/base/cổng và rig con mẫu.

## 32. Pet đồng hành P1-C và bay xem map — 19/10/2026

Người dùng yêu cầu làm tiếp theo thiết kế sau khi dựng map. Chọn bước **P1-C** theo thứ tự mục 23–24.12, tái sử dụng Pet đứng, vũ khí và hoạt ảnh đã có; không dựng lại sảnh hoặc đổi nhịp combat vừa duyệt. Bản làm việc hiện hành là **HunDino_DarkJungle_v2_4.rbxl**. Backup trước bước này: `HunDino/backups/Hub_v24_before_pet_companion_20261019.rbxl`.

- Pet trong khu săn chỉ tham chiến sau sát thương hợp lệ của chủ; hỗ trợ **12 sát thương mỗi 4 giây**, tầm **6 studs**, kiểm tra vật cản cả lúc phát đòn lẫn lúc trúng. Vũ khí có hai hit chia cùng tổng 12. Sát thương Pet được ghi riêng và gắn với chủ; chưa triển khai quyền thưởng săn đội.
- Di chuyển bám mặt đất, kiểm tra bề rộng thân, dốc/nước/khe; gặp vật cản thì tìm đường vòng bất đồng bộ. Không dịch chuyển Pet xuyên vách để đuổi mục tiêu. Chuyển khu vẫn đặt cả chủ và Pet tới điểm đến theo luồng travel hiện có.
- Pet có **100 HP**, cú cắn dùng cùng hitbox/thời điểm đang hoạt động của khủng long; mỗi cú chỉ trừ Pet một lần. Máu xuống **1** thì bất động **30 giây**, đòn mới không làm lại đồng hồ, sau đó hồi đầy. Pet không chết vĩnh viễn.
- **H hoặc nút Gọi Pet hồi:** tới gần chủ trong khoảng thử 3,8 studs, mang viên thuốc lớn rồi ném **0,8 giây**; hồi **70% máu tối đa**, có trần. Hồi chiêu **119 giây** bắt đầu khi thực sự cộng máu. Đầy máu không tiêu kỹ năng; chết/chuyển khu/choáng/bay hủy thao tác chưa hoàn tất, không xếp lệnh chờ.
- HP, choáng và hồi chiêu nằm trong bộ nhớ máy chủ theo người chơi, giữ qua đổi nhân vật/hồi sinh và chuyển khu. Hồi đầy sau choáng không làm mới kỹ năng. **Chưa lưu các dữ liệu này qua lần thoát hoặc máy chủ khởi động lại.**
- HUD giữa đáy hiển thị HP, trạng thái và đếm hồi; có thanh HP trên Pet của chủ. H là phím mới dùng thử; giữ Q đánh mạnh, E kỹ năng, R rút/cất, F đỡ, G tương tác, V nhảy, Space lướt, I trang bị theo bản đang chơi.

Đã kiểm tra **150 luật dữ liệu**, **29 tình huống controller mô phỏng**, **79 kiểm tra tích hợp với truy vấn va chạm thật**; 96 kiểm tra combat khủng long và sáu nhóm luật vũ khí tiếp tục đạt. Play với người thật: chủ mở đòn 36, Pet gây 12 và tiếp tục hỗ trợ; cú cắn đưa Pet tới 1 HP, hồi đầy sau **30,08 giây**. Phím H/nút hồi hoạt động, đo cộng **70 HP** với hồi chiêu **119 giây**; chết/hồi sinh giữ mốc hồi chiêu. Bãi tập vẫn có người/Pet đánh hình nộm. Tìm đường native qua tường thử đạt, không xuyên tường; chưa khảo sát hết mọi vật cản tự nhiên hoặc nhiều client/điện thoại.

Bản lưu v2.4 qua **91.867 kiểm tra**, 86 script biên dịch, 79 source cũ không liên quan giữ nguyên. Giữ toàn bộ **43.775 Part/845 khớp** trong Place, gồm **35.064 Part/723 khớp trong Workspace**; hình học map, 2.400 cây, mạng đường và rig khủng long không đổi. Lune chỉ đọc để đối chiếu; Terrain được lưu native Studio. Chi tiết và giới hạn: `HunDino/PET_COMPANION.md`; bằng chứng tại `HunDino/assets/hunting/pet-companion-*.json`.

Tiện ích admin ở mốc trước tiếp tục có nút **Bay xem map** và lệnh `/fly`: tốc độ 80/160/260, Shift tăng gấp đôi, Space/E lên và Ctrl/Q xuống. Chỉ tài khoản được server cấp quyền thấy nút/dùng được. Khi bay, Pet chờ dưới đất và giữ HP/hồi chiêu. Chat của tài khoản thử hiện bị Roblox giới hạn theo khu vực nên dùng nút. Có thể xóa riêng hai đối tượng theo `HunDino/ADMIN_FLY.md`.

**Sau P1-C đã có P1-D** (mục 33), **P1-E thưởng/kinh tế** (mục 34) và **kho cá thể P1-F bước đầu** (mục 36). Chưa có ống hoặc DataStore; không gọi mốc này là hoàn thành toàn bộ P1.

## 33. Nhiệm vụ săn và bắt sống P1-D — 19/10/2026

Người dùng yêu cầu tiếp tục giai đoạn tiếp theo theo thiết kế. P1-D tái sử dụng bản **HunDino_DarkJungle_v2_4.rbxl**, map H2, combat H1.3.1 và Pet P1-C; không dựng lại map hoặc đổi phím chiến đấu. Backup: `HunDino/backups/Hub_v24_before_hunt_quest_20261019.rbxl`. Cách thử chi tiết tại `HunDino/HUNT_QUEST.md`.

### 33.1. Luồng đang có

- Tại sảnh, cất vũ khí và dừng động tác; nhấn **J**, nút nhiệm vụ hoặc giữ **G** gần bảng để xem/nhận nhiệm vụ. Server kiểm tra người chơi và vị trí, chỉ bắt đầu đồng hồ khi nhân vật đã vào khu săn và sẵn sàng điều khiển.
- Nhiệm vụ săn thường **T-Rex · Không hệ**, **40 phút thật**, **1.200 HP**; hạ hoặc bắt đều ghi kết quả thành công. Chỉ một lượt solo trên toàn máy chủ vì dùng một con mẫu chung. Khu săn phải trống để nhận lượt; người khác chờ ở sảnh/bãi tập. Khi không có nhiệm vụ, vẫn có thể thám hiểm khu săn theo lối cũ.
- Mỗi lượt có mã nhiệm vụ và mã cá thể mục tiêu riêng, giữ qua hồi sinh. **Hiện hành P1-E:** mang tối đa **3 bẫy sắt + 3 thuốc ngủ đang sở hữu** từ kho; đồ dư trả kho một lần khi đóng lượt. Không còn cấp bộ miễn phí. Thử P1-D ban đầu dùng 3/3 chỉ là lịch sử kiểm chứng.
- **Giữ B 1 giây** để đặt bẫy khi cất vũ khí, đứng yên trên nền phù hợp ngoài vùng an toàn. Vòng bán kính **4 studs**, cần đủ nền và không vướng vật cản/nước; xong mới trừ bẫy. Mỗi lần chỉ có một bẫy hoạt động, chờ tối đa **60 giây**.
- Quái bước vào bẫy thì bị giữ **13 giây**, kể cả khi còn trên 10% HP. Chỉ cho uống khi quái còn sống, **0 < HP ≤120/1.200**, đang mắc bẫy; tới dấu sáng tại miệng cách **≤4 studs**, **giữ G 3 giây**. Thả/ngắt/ra xa/bị đánh/rút vũ khí/chuyển khu/chết/bay sẽ hủy; chưa thành công thì chưa trừ thuốc. Pet dừng phát đòn và hủy đòn chưa trúng khi chủ cho uống.
- Bắt thành công khóa `Captured` một lần, thu nhỏ khoảng **2 giây** rồi ẩn. Tiêu diệt khóa `Defeated`; không đồng thời có hai kết quả. P1-E cấp nguyên liệu/gói thưởng; P1-F bước đầu ghi thêm một cá thể riêng trong cùng giao dịch. Kho đầy chặn bắt trước khi trừ thuốc; chỉ lưu bộ nhớ máy chủ.

### 33.2. Tử vong, đồng hồ và quay về

Ba lần chết đầu hồi sinh tại trại sau khoảng **5 giây**, giữ HP quái, mã lượt, vật tư và hạn nhiệm vụ. Lần thứ tư thất bại; hết 40 phút cũng thất bại. Rời chủ động trước khi hoàn thành ghi bỏ cuộc. Trạng thái thao tác/bẫy được dọn khi kết thúc lượt.

Thành công dừng ảnh hưởng của hạn nhiệm vụ, mở **120 giây xem hiện trường** và có nút về sớm. Chết sau thành công vẫn hồi sinh tại trại, không đảo kết quả, không tăng số chết của phần nhiệm vụ hoặc làm mới 120 giây. Hết 120 giây tự về sảnh, đóng lượt và khôi phục con mẫu để lượt sau dùng.

**Ngày/đêm vẫn tăng tốc ×30 trong cả 120 giây sau thắng**, theo mục 26.2, tới khi thật sự rời khu săn. Dừng đồng hồ nhiệm vụ không dừng đồng hồ môi trường. Trở về khôi phục ánh sáng/màu Terrain/nước của sảnh.

### 33.3. Kiểm chứng mốc P1-D và giới hạn — trước kinh tế/cá thể

- **231 kiểm tra luật** và **163 kiểm tra controller/24 tình huống** đạt. Biên 2.400 giây được thử bằng luật; chưa chờ đủ 40 phút thật. Trường hợp lấy mẫu nước Terrain thật được bỏ qua vì không tìm thấy mẫu hồ phù hợp, nên chưa xác nhận mọi bờ hồ bằng Play. **96 kiểm tra combat** và **6 nhóm luật vũ khí** đạt sau tích hợp.
- Play dùng bảng/nút nhận nhiệm vụ, lệnh đánh Light qua kiểm tra server, B đặt bẫy và G cho uống: bắt ở **84 HP**, thuốc từ **3 còn 2**. Bẫy đầu hết hạn không mất thuốc. Ba lần chết đầu giữ cùng mã/hạn và HP quái **1.152**; lần thứ tư trở về với thất bại.
- Chết trong 120 giây sau bắt giữ cùng kết quả/mốc hết giờ. Đã chờ tự nhiên hết **120 giây**: về sảnh với `Closed/Captured`, con mẫu phục hồi tỉ lệ **3,716** và bỏ cờ Captured. Các lượt kiểm tra có hỗ trợ đặt vị trí và tạm tăng HP người lên 1.000 trong Play để lặp lại tình huống; không đưa các thiết lập này vào bản lưu hoặc coi là đánh giá cân bằng chiến đấu.
- Đã hạ quái qua đòn **Light được server kiểm tra**: HP 0 → `Harvest/Defeated`, vật tư còn 3 bẫy/3 thuốc. Bấm nút **VỀ SẢNH NGAY** trên HUD → `Closed/Defeated`, về sảnh, số người săn về 0, con mẫu hồi **1.200 HP** và kích thước gốc. HP người dùng thử đã trả về **100**.
- Đưa nhân vật ra biên trong nhiệm vụ → trở về trại với cùng mã/hạn, không tăng số lần chết. Trong Harvest đo **19,76944 → 19,84167 giờ** qua **8,713 giây**, xác nhận ánh sáng tiếp tục theo tốc độ ×30 khi đồng hồ nhiệm vụ đã dừng.
- **Bản lưu native Studio đạt 139.055 kiểm tra đọc/đối chiếu**, **98 script** biên dịch, **78 source cũ không liên quan** giữ nguyên; **17 source chuẩn** khớp. Giữ toàn bộ **43.775 Part/845 khớp**, trong Workspace **35.064 Part/723 khớp**. Map vẫn **4.000 × 4.500**, **2.400 cây**, **9 node**, **16 đường**, rig con mẫu giữ **255 Part/7 Motor6D/247 weld/1 anchor**. Có backup tám source được sửa; Lune chỉ đọc Place, Terrain lưu bằng Studio. Báo cáo: `HunDino/assets/hunting/hunt-quest-saved.json`.

Mốc P1-D khi kiểm chứng chưa có kinh tế/cá thể; **hiện P1-E đã có mổ/nhặt/thưởng/mua/chế/nâng/kho nguyên liệu và P1-F bước đầu đã có kho cá thể**. Chưa có ống trưng bày hoặc DataStore. UI có nút giữ bằng chuột/cảm ứng nhưng chưa kiểm chứng chơi điện thoại hoặc nhiều client thật. Thông số và giới hạn solo là cấu hình bản thử; không tự thay yêu cầu săn đội hay giới hạn toàn game.

**Tiến độ nối tiếp:** P1-E đã triển khai ở mục 34, Inventory/Vật phẩm ở mục 35 và kho cá thể P1-F bước đầu ở mục 36. P1-F còn một ống/lưu tài khoản, sau đó P1-G hồi quy. Không coi P1-D là hoàn thành toàn bộ P1 hoặc game sẵn sàng phát hành.

## 34. Nguyên liệu, thưởng và chế tạo P1-E — 19/10/2026

Bản hiện hành vẫn là **HunDino_DarkJungle_v2_4.rbxl**. Backup trước thay đổi: `HunDino/backups/Hub_v24_before_hunt_economy_20261019.rbxl`. Tái sử dụng sảnh, base, map H2 và vòng nhiệm vụ P1-D; các quầy/bàn/nguồn nhặt tạo khi chạy, không đổi hình học map đã duyệt. Hướng dẫn hiện hành tại `HunDino/HUNT_ECONOMY.md`.

### 34.1. Vòng tiến trình đang có

- Mỗi hồ sơ mới trong bộ nhớ máy chủ nhận **80 xu một lần**, bắt đầu không có nguyên liệu hoặc vật tư. Hồi sinh/nhận lượt mới không cấp lại. Cùng máy chủ giữ tiến trình qua nhiều lượt; kết thúc máy chủ thì dữ liệu thử mất, chưa có DataStore.
- Quầy tiếp tế ở sảnh bán **bẫy thô 10 xu**, **thuốc ngủ 10 xu**. Nhận nhiệm vụ tự chuyển tối đa **3 bẫy sắt và 3 thuốc đang sở hữu** sang hành trang lượt; hết đồ/xu vẫn được săn tiêu diệt và nhặt quặng. Đồ chưa dùng trả kho một lần khi lượt đóng, kể cả thất bại; lỗi vào map hoàn trả phần đã dành.
- Mỗi lượt có **6 quặng sắt**, nằm trên nền thật ngoài vùng an toàn ở vòng cung phía bắc trại; mỗi điểm bấm G nhận **1 sắt**, không hồi lại do chết. Quái lần đầu qua 50% HP mà vẫn sống rơi **1 vảy** gần vị trí đó. Phải thực sự nhặt; không cấp đồ chưa nhặt khi về sớm/hết giờ.
- Hạ quái mở **3 lượt mổ**, đứng gần thân/chân xác, cất vũ khí, giữ **G 1,5 giây** mỗi lượt. Hủy do thả, di chuyển, bị đánh, rút vũ khí, chết, menu hoặc bay không mất lượt. Mỗi lượt hoàn tất mới quay một loại: **da 50%, răng 25%, vảy 25%**, lượng 1.
- Bắt sống không có xác/lượt mổ; cấp **ba lượt nguyên liệu độc lập**, mỗi lượt chọn loại như trên, rồi lượng 1/2 với xác suất 50% mỗi lượng. Hạ hoặc bắt còn có gói riêng **1 xương + 40 xu**, một lần. Thua/bỏ cuộc không có gói hoàn thành; đồ đã nhặt được giữ.
- Bàn chế tạo chỉ dùng tại **base của chính người chơi**: **1 bẫy thô + 1 sắt → 1 bẫy sắt**; **2 xương + 2 sắt → búa cấp 2**, tăng 15% sát thương búa người chơi. Không tăng Pet hoặc vũ khí khác; cấp 2 là trần thử.
- Phần xem đồ hiện đã chuyển vào **Inventory → Vật phẩm** theo mục 35; không còn nút KHO NGUYÊN LIỆU bên ngoài. Giao dịch vẫn phải gần đúng điểm. Dữ liệu hiện chỉ trong máy chủ, chưa lưu tài khoản.

### 34.2. Chống nhận lặp và phạm vi dữ liệu

Các thay đổi kho cùng dấu giao dịch được cập nhật nguyên tử trong bộ nhớ, không nhường luồng giữa trừ/cộng và ghi dấu. Server tạo mã người/lượt/cá thể/nguồn/lượt mổ, chọn giá/công thức và ngẫu nhiên. Gửi lại nguồn đã nhận trả kết quả cũ, không quay lại hoặc cấp thêm. Mua/chế/nâng dùng token do server cấp và phiên bản kho, kiểm tra lại vị trí/đủ tiền/nguyên liệu.

Lượt đang chạy giữ đủ dấu nguồn; giữ tối đa 64 giao dịch cửa hàng và 8 lượt đóng gần nhất. Số thứ tự tăng dần từ chối yêu cầu cũ đã dọn. Không tạo nguồn mới khi hồi sinh. Vật tư bắt sống cùng nguyên liệu/gói kết quả được ghi trong một giao dịch; trả đồ dư có dấu riêng. Bảng bộ nhớ này là lớp thử để thay bằng lưu P1-F, chưa bảo vệ dữ liệu qua máy chủ sập hoặc kết thúc.

### 34.3. Kiểm chứng

- **767 kiểm tra luật / 23 nhóm** đạt: cấp đầu, vật tư mang/trả, nguồn riêng, mổ/bắt/thưởng, nguyên tử thiếu đồ/đầy kho, kết quả không đảo, mã lặp, dấu cũ và dọn có giới hạn. **121 kiểm tra controller / 21 tình huống** với truy vấn vật lý thật đạt; **231 kiểm tra nhiệm vụ** và **96 kiểm tra combat** tiếp tục đạt.
- Play dùng nút mua và gửi lại token: một bẫy thô chỉ trừ 10 xu một lần. Nhặt đủ 6 quặng; hạ quái nhận 1 xương/40 xu, mổ đủ ba lượt; lần thứ tư không cấp. Về sảnh trả lại thuốc chưa dùng. Một lượt bỏ cuộc sau nhặt thêm quặng giữ tiến trình, không có gói thắng mới.
- Chế một bẫy trừ một bẫy thô/một sắt; lượt sau mang đúng 1 bẫy/1 thuốc. Bắt ở **120 HP**, tiêu đúng hai vật dụng, nhận ba lượt nguyên liệu và gói thắng. Hai lượt thắng cho đủ hai xương; nâng búa trừ đúng **2 xương/2 sắt**, token cũ không trừ thêm. Đòn Light được server kiểm tra gây **41,4** thay cho 36.
- Đã thử lại trong phiên Play mới với source cuối: **80 xu, búa cấp 1, 0 bẫy/thuốc** vẫn nhận nhiệm vụ; nhặt 1 sắt và vảy rơi bằng G; bỏ cuộc giữ **1 sắt/1 vảy**, xu vẫn 80, xương 0. Vảy dùng kiểm tra tường phía server để thân quái không che mất prompt. Đây cũng xác nhận dữ liệu chưa lưu giữa hai phiên máy chủ.
- Các lượt chiến đấu có hỗ trợ đặt vị trí nhân vật và tăng HP tạm lên 1.000 trong Play để lặp tình huống, đã trả về 100; không sửa HP quái để nhận thưởng. Chưa nghiệm thu cân bằng, săn đội hoặc điện thoại.

Bản lưu native Studio đạt **139.088 kiểm tra đọc/đối chiếu**, **108 script** biên dịch, **21 source chuẩn** khớp và **92 source cũ không liên quan** giữ nguyên. Giữ **43.775 Part/845 khớp**, gồm **35.064 Part/723 khớp trong Workspace**. Có sáu backup source cũ được đối chiếu đúng và đúng bốn source hệ thống mới. Inspector chỉ đọc `HunDino/tools/inspect-hunt-economy-saved.luau`; báo cáo `HunDino/assets/hunting/hunt-economy-saved.json`, bằng chứng Play `hunt-economy-play.json`. Không xuất lại Place/Terrain bằng Lune.

**Tiến độ P1-F:** kho cá thể bộ nhớ đã triển khai tại mục 36; còn một ống, kết nối lớp lưu trong môi trường test riêng và xác nhận thoát/vào còn đồ. P1-G mới nghiệm thu lỗi/lưu và hồi quy toàn vòng; P1-E không phải game hoàn thiện hoặc đã lưu tài khoản.
## 35. Inventory: Vật phẩm và tab Chế tạo chờ — 19/10/2026

Người dùng yêu cầu theo dõi toàn bộ đồ qua Inventory, bỏ phần kho nguyên liệu độc lập bên ngoài; thêm mục Chế tạo nhưng chưa triển khai phần này trong Inventory. Bản v2.4 giữ hệ thống P1-E hiện có, chỉ tích hợp phần xem đồ và khung giao diện. Backup: `HunDino/backups/Hub_v24_before_inventory_items_20261019.rbxl`. Hướng dẫn: `HunDino/INVENTORY_ITEMS.md`.

- Nhấn **I** hoặc biểu tượng Túi đồ. Thanh trên có **Người / Pet / Vật phẩm / Chế tạo**. Hai mục trang bị giữ vũ khí, giáp và xem trước nhân vật; Vật phẩm là dữ liệu dùng chung của người chơi, không tách một kho Pet riêng.
- Vật phẩm gồm toàn bộ loại hiện đã có: **da, răng, vảy, xương, sắt, bẫy thô, bẫy sắt, thuốc ngủ**. Hiển thị mô hình biểu tượng, mô tả, số lượng và xu/cấp búa; lọc Tất cả/Nguyên liệu/Vật tư săn.
- Tổng bẫy sắt/thuốc = phần dự trữ + phần còn lại trong lượt đang chạy; ghi rõ **Trong túi / Mang đi săn**. Chỉ dùng snapshot có phiên bản từ máy chủ, không cộng các thuộc tính nhiệm vụ cũ sau trả đồ. Mở Inventory lấy lại snapshot và hủy thao tác giữ đang diễn ra; không đổi quyền mua/chế hoặc tự cấp đồ.
- **Chế tạo trong Inventory chỉ là khung “Chưa triển khai”**, chưa công thức, nút thao tác hoặc giao dịch. Bàn chế/nâng tại base từ P1-E vẫn giữ mốc thử cũ; không tự triển khai thêm theo tab mới.
- Bỏ nút **KHO NGUYÊN LIỆU** độc lập và dòng tổng nguyên liệu trên HUD mổ. Giữ thông báo nhặt đồ và thanh tiến trình mổ theo hành động. Inventory nổi trên HUD admin/Pet khi mở và trả lớp hiển thị/camera khi đóng.

Đã thử Play mua bẫy/thuốc, nhận vật tư vào lượt, nhặt quặng, bỏ cuộc/trả vật tư rồi mở Inventory: thuốc vẫn tổng 1 qua chuyển đi/trả về, sắt hiển thị 1; snapshot cũ không ghi đè. Bộ lọc đúng 5 nguyên liệu/3 vật tư; tab Chế tạo có 0 nút giao dịch; Pet/giáp/xem trước tiếp tục chạy. Source cuối mở Inventory ở lớp 100 và đóng về lớp 0/camera Custom, không có nút kho ngoài. Đây là kiểm chứng PC, chưa thử điện thoại đầy đủ.

Ba source sửa: `EquipmentInventory`, `HuntEconomyService`, `HunDinoEconomy` client; có ba backup source khớp bản trước. Không đổi hình học map, luật thưởng, giá/công thức, AI hoặc dữ liệu lưu. Inspector chỉ đọc `tools/inspect-inventory-items-saved.luau`; báo cáo `assets/hunting/inventory-items-saved.json` và `inventory-items-play.json`. Dữ liệu vật phẩm vẫn chỉ giữ trong máy chủ.

Bản lưu Inventory đã đạt **139.097 kiểm tra đọc/đối chiếu**, **111 script** biên dịch và **22 source chuẩn** khớp. Giữ **105 source cũ không liên quan** cùng toàn bộ **43.775 Part/845 khớp**, trong Workspace **35.064 Part/723 khớp**; ba bản sao source trước sửa khớp baseline. Bản v2.4 đã được lưu native Studio và để ở Edit.

## 36. Kho cá thể bắt sống — bước đầu P1-F — 19/10/2026

Người dùng chọn làm kho cá thể trước và để Chế tạo trong Inventory làm sau. Bản v2.4 tái sử dụng vòng bắt P1-D, kho/thưởng P1-E và giao diện mục 35. Giai đoạn này chỉ thêm bộ sưu tập trong bộ nhớ máy chủ; chưa làm ống tại base, vòng đời nuôi hoặc lưu tài khoản. Backup: `HunDino/backups/Hub_v24_before_specimen_collection_20261019.rbxl`. Hướng dẫn: `HunDino/SPECIMEN_COLLECTION.md`.

### 36.1. Sở hữu và cách xem

- **I → KHỦNG LONG** trong Inventory. Một lần bắt sống thành công tạo đúng một cá thể; hạ quái không tạo. Danh sách hiện số lượng `n / 100`, tên **T-Rex #001…**, mã rút gọn và thời điểm bắt theo **UTC+7**, con nhận gần nhất xếp trước. Trang chi tiết hiện mã đầy đủ và xoay được mô hình 3D tĩnh bằng kéo chuột.
- P1 dùng ngoại hình cố định: `SpeciesId=TRex`, `Name=T-Rex`, `Variant=Normal`, `Element=None`, `SizeScale=1` tương ứng Thường/Không hệ/100%. Chưa sinh biến thể, hệ hoặc kích thước ngẫu nhiên. Bản xem trước chỉ có hình dáng, không có AI/vùng đánh; tạo lúc chạy, không thêm hình học bản lưu.
- Mỗi bản ghi có GUID riêng, `Serial` tăng theo lần ghi thành công, `CapturedAt` từ máy chủ, `SourceRunId` và `SourceMonsterId`. Hai con cùng loài vẫn là hai cá thể riêng; đổi lựa chọn trong UI chỉ đổi con đang xem.
- **Tối đa 100 cá thể thử.** Khi đầy vẫn nhận nhiệm vụ săn thường/hạ quái, nhưng không bắt thêm. Máy chủ kiểm tra chỗ trước thao tác và ngay trước ghi bắt, không tiêu thuốc hoặc đổi kết quả khi đầy; không xóa cá thể cũ để nhường chỗ.
- Kho giữ qua về sảnh, hồi sinh và các lượt trong cùng máy chủ. Chưa có DataStore; máy chủ/phiên Play mới không mang bộ sưu tập cũ sang. Không báo đã lưu tài khoản.
- **Chế tạo trong Inventory vẫn là khung chờ**, chưa thêm công thức/nút giao dịch; bàn chế/nâng thử ở base thuộc mốc P1-E được giữ nguyên. Chưa có ống trưng bày, thả/bán/xóa/trao đổi hoặc nuôi lớn.

### 36.2. Tính nguyên tử và chuyển dữ liệu

Hồ sơ `DataVersion=2` thêm `OwnedSpecimens` và `SpecimenSerial`. Hồ sơ v1 hợp lệ được sao chép/chuyển phiên bản, giữ toàn bộ xu, nguyên liệu, vật tư, cấp búa, lượt đang chạy và dấu giao dịch; không cấp lại 80 xu. Hồ sơ sai định dạng bị từ chối thay vì tự tạo kho mới.

Một giao dịch bắt chứa đúng một cá thể, tăng số thứ tự, ba kết quả nguyên liệu, gói xương/xu hiện có, vật tư còn lại và dấu hoàn tất. Gửi lại cùng lượt trả đúng cá thể/thưởng cũ, không quay lại hoặc trừ thuốc lần nữa. Kiểm tra nguồn/mã riêng ngăn một quái tạo hai cá thể, kể cả sau khi dấu lượt gần đây được dọn. UI dùng snapshot có phiên bản, bản sao của kho máy chủ; dữ liệu UI không quyết định sở hữu.

### 36.3. Kiểm chứng đang có

- **2.134 kiểm tra luật / 31 nhóm đạt**, giữ toàn bộ 767 kiểm tra kinh tế cũ. Có hai mã cá thể, thứ tự tăng, replay sau đóng lượt, 100 lần bắt độc lập, kho đầy không mất vật tư/không khóa nhánh tiêu diệt, chuyển v1 không reset, metadata sai/nguồn trùng và sửa bản sao không sửa kho gốc.
- Controller bẫy/bắt **195 kiểm tra / 27 tình huống đạt**. Mẫu nước Terrain thật được bỏ qua vì không có vị trí hồ phù hợp; chưa xác nhận toàn bộ bờ nước.
- Preview native đạt **4.858 kiểm tra**, **255 Part/21 MeshPart**, không thay đổi con gốc; giữ metadata nhập `RBX_` được engine bảo vệ và loại bỏ trạng thái gameplay khỏi bản xem trước.
- Native Play đi từ 80 xu, mua bẫy thô/thuốc, nhặt quặng, dùng bàn chế hiện có rồi nhận lượt. Đòn búa hợp lệ gây **1.080 sát thương**, để quái **120 HP**, không đặt HP quái để nhận thưởng. Giữ B/G bắt → `Harvest/Captured`, đúng **1 cá thể**, **100 xu, 1 xương, 3 răng, 1 vảy**. Tự hết 120 giây về sảnh và chết/hồi sinh vẫn đúng GUID `275d20fb-baee-4a26-9bd2-d58f3480ba73`. Có hỗ trợ đặt vị trí/tạm tăng HP người lên 1.000 để thử, đã trả 100; chưa đánh giá cân bằng.
- Kéo xoay hoạt động, camera trả `Custom`; mục Chế tạo vẫn chờ và dọn preview. Phiên máy chủ mới có **0 cá thể/80 xu** đúng phạm vi chưa lưu tài khoản. Khung cuối sau sửa căn đầu/đuôi được thử bằng snapshot **chỉ để xem** sau restart, không ghi cá thể lên server: cả tám góc hộp bao nằm trong khung trước/sau xoay, tỷ lệ ngang/dọc sau xoay **0,678/0,862**; **29 tài nguyên nạp, 0 lỗi**. Không tính fixture xem mẫu là lần bắt thực thứ hai.

Sáu source cũ được sao lưu trong `ServerStorage.SpecimenCollectionBackup_20261019`; thêm module `SpecimenPreviewModel`, không dựng lại map. Đã lưu source cuối bằng native Studio vào v2.4, **4.220.334 byte**, để ở Edit. Bản lưu đạt **139.120 kiểm tra**, **118 script** biên dịch, **23 source chuẩn** khớp, **105 source cũ không liên quan** giữ nguyên và **6 backup** khớp baseline; đúng sáu source sản xuất sửa/một module mới. Giữ toàn bộ **43.775 Part/845 khớp**, trong Workspace **35.064 Part/723 khớp**; map H2 **4.000 × 4.500, 2.400 cây, 16 đường, 9 khu**, rig **255 Part/21 MeshPart/7 Motor6D/247 weld/1 anchor**. Inspector chỉ đọc `HunDino/tools/inspect-specimen-collection-saved.luau`, báo cáo `HunDino/assets/hunting/specimen-collection-saved.json`; không xuất lại Place/Terrain bằng Lune. Bằng chứng Play tại `HunDino/assets/hunting/specimen-collection-play.json` phân biệt lần bắt thực và fixture xem mẫu. Chưa nghiệm thu nhiều client/điện thoại, trưng bày hoặc lưu qua máy chủ mới. Phần tiếp theo P1-F còn ống trưng bày và lớp lưu tài khoản; tab Chế tạo tiếp tục chờ yêu cầu.


## 37. Tổng hợp trước UI: v2.4 và đồng bộ hồ sơ v0.39 — 20/10/2026

Đối chiếu bản game đã lưu ngày **19/10/2026**; đây là đợt cập nhật tài liệu trước bước UI ở mục 38, không thêm tính năng hoặc chạy lại gameplay. Các số trong mục này giữ làm mốc lịch sử; trạng thái UI/bản lưu mới xem mục 38. Hai bản THIET_KE_GAME.md ở gốc dự án và HunDino giữ cùng nội dung. README là chỉ mục các tài liệu chuyên đề; bản thiết kế map săn giữ yêu cầu gốc và thêm bảng đối chiếu H2.

| Nhóm đã làm | Hiện trạng | Giới hạn còn lại |
| --- | --- | --- |
| Sảnh và base | 12 base, gán ngẫu nhiên số trống, giữ trong phiên; dịch chuyển base ↔ trung tâm, Pet đi cùng; sửa đường đền | Chưa nghiệm thu 12 client hoặc lưu bố trí/trưng bày tài khoản |
| Bãi tập/vũ khí | Bãi 460 × 420, 7 vũ khí × 4 combo, model/VFX Pro, cung chuột trái tụ/Q mạnh, camera lệch vai | Chưa animation toàn thân/cân bằng cuối; nâng búa P1-E +15% chỉ áp dụng búa chủ |
| Inventory/trang bị | Người/Pet độc lập vũ khí và 5 vị trí giáp, kéo xoay preview; Vật phẩm và Khủng long cùng snapshot có phiên bản | Giáp thử ngoại hình; Chế tạo trong Inventory chỉ là khung chờ |
| Map săn H2.0 | 4.000 × 4.500, 2.400 cây, 16 đường, 9 node/khu kỹ thuật, đồng hồ UTC+7 ×30; giữ sảnh | Chưa thêm nhiều loài/hệ/theo dấu động, lái thuyền hoặc nghiệm thu điện thoại/máy yếu |
| T-Rex/combat | Một con mẫu 1.200 HP, nghỉ 60 giây; cắn 24, báo 0,95 giây/chu kỳ 3,5; lướt 72 trong 0,5 giây, tốn 6 | Không i-frame; chưa đánh bộ phận, nhiều quái hoặc săn đội |
| Admin/Pet | Bay có kiểm tra quyền; Pet đánh 12/4 giây, HP100/choáng30 giây, gọi hồi70% bằng H/hồi chiêu119 giây; dừng đánh khi cho uống | Dữ liệu Pet trong phiên; chưa Pet nâng cao/hiệu năng 12 Pet |
| Nhiệm vụ P1-D | Một lượt solo/máy chủ, 40 phút, 3 lần hồi sinh; bẫy B/cho uống G khi quái sống ≤120 HP; thắng có 120 giây thu hoạch | Chưa nhiệm vụ chỉ bắt sống; chưa chờ đủ 40 phút thật, chưa kiểm chứng mọi bờ nước |
| Kinh tế P1-E | 80 xu đầu, vật tư sở hữu, quặng/vảy/mổ/thưởng; mua/chế bẫy/nâng búa ở đúng điểm; trả đồ/chống trùng | Chưa DataStore; icon Shop mẫu chưa thành cửa hàng giao dịch, bàn base đã có |
| Cá thể P1-F bước đầu | Một mã mỗi lần bắt, tối đa 100, metadata/preview 3D; giữ qua về sảnh/hồi sinh cùng máy chủ; kho đầy chặn bắt trước mất thuốc | Chưa ống/chọn vào base, lưu tài khoản, bán/thả/xóa/trao đổi/nuôi/biến thể ngẫu nhiên |

**Còn chờ:** phần một ống và lưu tài khoản của P1-F, hồi quy P1-G, Chế tạo trong Inventory, săn đội, nhiều client thật, điện thoại và hiệu năng máy yếu. Không đánh dấu toàn bộ P1 hoàn thành; lưu file Studio không đồng nghĩa lưu tiến trình tài khoản.

**Căn cứ hiện có:** bản v2.4 có **4.220.334 byte**; `specimen-collection-saved.json` ghi **139.120 kiểm tra**, **118 script** biên dịch, **23 source chuẩn** khớp, giữ **43.775 Part/845 khớp** và riêng Workspace **35.064 Part/723 khớp**. Hồ sơ `DataVersion=2`, `StorageMode=ServerMemory`, `MaxOwnedSpecimens=100`; báo cáo Play ghi rõ một lần bắt thực và fixture chỉ xem, không có DataStore. Số kiểm tra là phép đọc/đối chiếu hoặc kiểm tra luật theo từng báo cáo, không phải số tình huống chơi mới. Các số/hash H1/H2/P1-C/D/E giữ nhãn lịch sử tương ứng.

Đợt này cập nhật đúng **27 file Markdown hiện hành**, giữ nguyên file trong backups, mã nguồn, bản game và JSON. Không chạy bộ dựng cũ, không đồng bộ default.project.json L0 lên bản chung. Danh mục tài liệu và thay đổi của từng file nằm trong README.

## 38. Hiện đại hóa UI — 20/10/2026

Bước đầu của yêu cầu “Modernize HunDino UI and gameplay” tập trung vào giao diện trên đúng bản v2.4. Đã sửa bảy source UI và thêm `UITheme` cùng `HunDinoHoldProgress`; không sửa source server, luật chiến đấu, giá/công thức, thưởng hoặc dữ liệu sở hữu. Backup Place trước cài: `HunDino/backups/Hub_v24_before_ui_modernization_20261020.rbxl`. Bảy source gốc được giữ trong `ServerStorage.UIBackup_20261020` và `HunDino/backups/ui-modernization-20261020/`. Hướng dẫn/bằng chứng đầy đủ: `HunDino/UI_MODERNIZATION.md`.

### 38.1. Bảng màu và Inventory

- Khung nền **RGB (16,20,26)**, trong suốt **0,12**, góc **14 px**, viền đồng **(165,135,65), 1,5 px** và gradient. Thẻ **(26,32,42)**, góc **8 px**; hover vàng **(235,195,95)** trong **0,15 giây Quad.Out**. HP xanh **(46,204,113)**, thể lực/tụ lực xanh **(52,172,224)**, cảnh báo **(235,95,45)**.
- **I → Người / Pet / Vật phẩm / Khủng long / Chế tạo**. Trang bị Người/Pet vẫn độc lập. Preview có bục tối và nút đặt lại góc nhìn; bốn chuỗi combo có phím rõ ràng. Cấp nâng búa hiển thị theo dữ liệu chủ sở hữu, không tự tăng cấp Pet/vũ khí khác. Giáp có badge món đang mặc và số mảnh bộ.
- Vật phẩm lọc toàn bộ/nguyên liệu/vật tư săn, tách phần trong kho và đang mang theo snapshot server. Khủng long giữ danh sách cá thể, mô hình 3D tĩnh kéo xoay, thời điểm UTC+7, hệ, biến thể, kích thước, GUID và nguồn lượt săn.
- **Chế tạo trong Inventory tiếp tục chờ**, chưa thêm công thức/nút giao dịch. Bàn chế/nâng tại base và quầy tiếp tế giữ hoạt động P1-E hiện có. Không thêm ống trưng bày, DataStore hoặc giao dịch cá thể.

### 38.2. HUD và vòng tiến độ

Boss ở giữa phía trên; còn sống và ≤10% HP thì hiện trạng thái suy yếu để bắt. Thời gian mắc bẫy có thanh riêng, ba giây cuối dùng cảnh báo cam đỏ nhấp nháy/rung nhẹ. Nhiệm vụ ở bên phải với thời gian, lượt hồi sinh và gợi ý B/G; Pet ở bên trái phía dưới với HP, choáng, dừng đánh khi bắt và vòng hồi chiêu gọi hồi 119 giây. Hub, quầy tiếp tế/bàn chế, HUD thể lực và tụ cung dùng cùng bảng màu.

Vòng giữa tâm theo thời gian hành động do server công bố: **B đặt bẫy 1 giây**, **G cho uống 3 giây**, **G mổ 1,5 giây**. Module vòng chỉ trình bày, không gửi remote hoặc trao thưởng. Client nhiệm vụ/kinh tế hiện có tiếp tục xử lý giữ/thả và hủy thao tác; không đổi phím hoặc điều kiện gameplay.

### 38.3. Phạm vi kiểm chứng đợt UI

- **Play desktop 1.453 × 808:** xem đủ năm tab, bộ lọc đúng ba vật tư săn, giáp Pet Kim loại `5/5`; đổi Katana cho Người rồi Kiếm/khiên cho Pet xác nhận hai phần độc lập, sau đó trả cả hai về Búa. Thực mua bẫy thô/thuốc (`80 → 60 xu`), nhặt một sắt, bỏ lượt trả thuốc dư, chế một bẫy sắt tại base chủ, giữ B đặt bẫy thật và gọi Pet H hồi chủ từ `30 → 100 HP`/hiện hồi chiêu `118 giây`. Có hỗ trợ vị trí khi thử, không dùng kết quả này để kết luận cân bằng hoặc tìm đường tự nhiên.
- **Fixture phía client chỉ kiểm tra hiển thị:** Boss `120/1.200 HP`, bẫy còn `2,8 giây`, vòng cho uống đến `100%`, vòng mổ có mẫu `88%`, Pet choáng ở `1 HP`, cá thể mẫu `#001` và kéo/reset preview. Fixture không ghi cá thể hoặc kết quả bắt/mổ lên server; dữ liệu mẫu được khôi phục/dọn khi Stop. Không tính là lần bắt sống/thu hoạch thật trong đợt này.
- **Bố cục màn hình ngang nhỏ:** Device Simulator preset iPhone 17 Pro/LandscapeLeft, camera thực tế `750 × 381`, vùng GUI an toàn `750 × 323`. Đã căn Boss/Pet/nhiệm vụ và giữ Inventory trong màn hình, rút gọn tiêu đề/hướng dẫn combo phụ. Đây là thử bố cục giả lập; chưa nghiệm thu đầy đủ cảm ứng, thiết bị thật hoặc kích thước nút mobile.
- **Offline:** chín source UI biên dịch, 45 lệnh remote giữ nguyên action/payload; gói source thử DryRun/cài trong bộ nhớ/backup/chặn v2.3 đạt. Bộ kiểm Inventory và hunting source đạt; luật kinh tế `2.134/31 nhóm`, nhiệm vụ `231/15 nhóm`, Pet `150` đạt. Test vũ khí Pro lịch sử còn lỗi so baseline v2.3 tại dòng 40; giữ nguyên test, không dùng lỗi đó làm kết quả bảo toàn map của bước UI.

Đã Stop Play, trả viewport mặc định, lưu bằng **native Roblox Studio** vào `HunDino_DarkJungle_v2_4.rbxl` và xác nhận Studio ở Edit. Bản lưu **4.250.777 byte**, SHA256 `d360c3763761c85156b6eb4cc4f3cd14be5941aa84ddad312dc9ac5ef7d040ab`. Inspector chỉ đọc `HunDino/tools/inspect-ui-modernization-saved.luau` đạt ở chế độ **`native-save`**: **8.784 kiểm tra**, **120 script biên dịch**, **9 source chuẩn khớp**, **7 backup khớp**. Giữ **43.775 Part/845 khớp**, riêng Workspace **35.064 Part/723 khớp**; hash các thuộc tính Terrain nhị phân giữ nguyên.

Bộ đối chiếu so **61.193 Instance**, **5.334.152 lượt thuộc tính**, thuộc tính tùy chỉnh và tag, không ghi nhận khác biệt thuộc tính ngoài phạm vi source UI đã cho phép. Báo cáo có danh sách thuộc tính reflection không đọc được; số lượt đối chiếu không có nghĩa mọi thuộc tính engine đều đã đọc thành công. Hai ngoại lệ được ghi rõ: `HistoryId` là lịch sử chỉnh sửa native; các Instance rỗng `FilteredSelection` trực tiếp dưới DataModel là metadata chọn của Studio, số lượng **5 → 4**, không phải đối tượng gameplay. Không mở ngoại lệ cho Part, Joint, Terrain hoặc source server.

Báo cáo bản lưu: `HunDino/assets/hunting/ui-modernization-saved.json`; bằng chứng Play: `HunDino/assets/ui/ui-modernization-play.json`. Không dùng Lune xuất lại Place/Terrain, không đồng bộ `default.project.json` L0.

Phần tiếp theo vẫn là Chế tạo trong Inventory khi được yêu cầu, ống trưng bày/lưu tài khoản của P1-F và hồi quy P1-G. Bước UI không hoàn thành thay các phần đó; gameplay cảm ứng đầy đủ và nhiều client còn chờ.

## 39. Lưu tiến trình tài khoản — 20/10/2026

Yêu cầu của người dùng: trang bị đã đổi, đồ đã chế tạo/nâng cấp và tiến trình kiếm được phải dùng tiếp ở lần vào game sau. Triển khai trên bản v2.4 hiện có, giữ phạm vi gameplay và luật kinh tế P1-E/P1-F. Tài liệu vận hành đầy đủ: [PERSISTENCE.md](<C:/Users/khanh/OneDrive/Documents/ChatGPT/game roblox/HunDino/PERSISTENCE.md>).

### 39.1. Dữ liệu được lưu

- Vũ khí Người/Pet riêng biệt; năm ô giáp Đầu/Thân/Tay/Eo/Chân của từng bên; ba tùy chọn hướng dẫn/số sát thương/hiệu ứng và độ nhạy ngắm 100/75/50%.
- Xu, da/răng/vảy/xương/sắt, bẫy thô/bẫy sắt/thuốc ngủ, cấp búa và dấu cấp tiền khởi đầu một lần. Công thức hiện có là bẫy sắt và nâng búa cấp 2 +15%; không tự coi các nâng cấp vũ khí/giáp khác đã được làm.
- Từng cá thể với GUID/serial/thời điểm/nguồn bắt; giữ giới hạn hiện tại 100. Toàn bộ RunSerial/OperationSerial/SpecimenSerial, receipt, claims và lịch sử lượt gần nhất để không cấp lại đồ.
- Thống kê săn thắng/thất bại/bắt và hạn hồi chiêu hồi chủ của Pet theo Unix. Máu/thể lực hiện tại, combo, AI/quái, bẫy đang đặt, đồng hồ nhiệm vụ, số base được bốc và vị trí là dữ liệu phiên; khi vào lại dựng ở sảnh.

### 39.2. Giao dịch và vòng đời

- Tải/kiểm schema/khóa tài khoản trước khi dựng trang bị hoặc cấp kho. Chỉ tạo mặc định khi khóa tài khoản chưa tồn tại thật; lỗi đọc, dữ liệu lỗi hoặc phiên bản mới hơn không được đặt lại.
- Hồ sơ tài khoản DataVersion=1 bọc Economy.DataVersion=2; codec chuyển khóa receipt số thưa thành chuỗi khi ghi và trả lại số khi tải. Migration giữ receipt/cá thể, không cấp lại 80 xu.
- Mua/chế/nâng/nhặt/mổ/thưởng dùng bản giao dịch tách, ghi thành công rồi mới công bố số dư/kết quả. Lỗi không rõ đã ghi hay chưa giữ cùng commit ID và bản chờ, khóa giao dịch mới, thử lại đúng thao tác; không tạo mã mới để phát bù.
- Trang bị/cài đặt lưu sau 2 giây gom thao tác; tự lưu dự phòng mỗi 30 giây và có Lưu thủ công giới hạn 5 giây. PlayerRemoving đóng lượt/trả vật tư rồi lưu; BindToClose thực hiện song song cho các tài khoản và chờ trong thời gian đóng server.
- UpdateAsync có khóa phiên 120 giây, kiểm revision, retry 4 lần có trễ tăng dần. Khóa hết hạn không cho server cũ ghi đè; hồ sơ chưa sẵn sàng/lưu lỗi hiển thị rõ trên UI.
- Lượt săn bị đứt không tiếp tục con quái cũ: đóng bản ghi lượt và trả đúng vật tư chưa dùng một lần; đồ nhặt/thưởng/cá thể đã ghi vẫn còn. Không quay thưởng lại. Vật tư đặt bẫy được ghi trước khi tạo bẫy có tác dụng.

### 39.3. Môi trường và kiểm chứng

- Live: HunDinoProfiles_v1; Studio: HunDinoProfiles_Studio_v1; cùng scope accounts, khóa player_UserId. Không dùng kho live để thử Studio.
- Cấu hình QA bộ nhớ mặc định tắt; chỉ bật tạm trong Play khi kiểm, có nhãn rõ không lưu qua Stop/Play. File native không chứa cờ QA hoặc probe runtime.
- Kiểm dữ liệu: repository 160, schema 597, roundtrip JSON 547 kiểm tra đạt. Harness dịch vụ trong engine 65 kiểm tra/10 nhóm đạt; luật nhiệm vụ 231, kinh tế 2.134 và kiểm controller bắt trong engine 195 đạt (mẫu nước được báo skip vì không tìm thấy điểm mẫu).
- Studio test giữ Cung của Người, Katana của Pet, giáp Xương/Da, tùy chọn 50%/tắt số sát thương qua save/release/load. Hai lần mua ghi 80 → 60 xu, 1 bẫy thô/1 thuốc, đúng 2 receipt. Chèn 4 lỗi ghi: chưa báo mua sớm, retry không nhân đôi. Hồi chủ thực giữ cùng hạn cooldown sau tải lại.
- Kiểm bản native bằng tools/inspect-persistence-saved.luau đối chiếu source/cấu hình/hình học/Terrain. Bằng chứng ở assets/hunting/persistence-saved.json; không dùng bằng chứng UI v0.40 thay kết quả này.
- **Cloud còn chờ:** xuất bản game riêng tư, kiểm DataStore thật và thoát/vào bằng phiên/server mới. Chưa gọi P1-F lưu cloud hoặc P1-G toàn vòng hoàn thành trước khi đạt checklist trong PERSISTENCE.md.

### 39.4. File và phạm vi giữ nguyên

Map tiếp tục cùng tên HunDino_DarkJungle_v2_4.rbxl trong Documents. Bản trước cài: backups/Hub_v24_before_persistence_20261020.rbxl. Nguồn lớp lưu ở src/data; server chuẩn tích hợp ở studio-pet-integration/Training.server.luau. Chỉ cài source và module/UI dữ liệu mới, không dựng lại map hoặc ghi Terrain bằng Lune. Không xóa bản cũ hoặc tạo nút reset tài khoản.

## 40. Nhập code thử dành riêng cho admin — 21/10/2026

Theo yêu cầu người dùng, thêm **Nhập code** trong **Cài đặt** để admin thử trước. Mã **`HUNDINO-ADMIN-500`** chỉ tài khoản **tunzdangcap / UserId 11605296816** được nhận: **500 xu, 10 da, 10 răng, 10 vảy, 10 xương và 10 sắt**. Không cấp bẫy hoặc thuốc. Cách dùng: **Cài đặt → Nhập code → nhập mã → Đổi mã**, sau đó xem **I → Vật phẩm**. Tài liệu vận hành: [ADMIN_TEST_CODE.md](<C:/Users/khanh/OneDrive/Documents/ChatGPT/game roblox/HunDino/ADMIN_TEST_CODE.md>).

### 40.1. Quyền và một lần nhận

Server kiểm UserId và mã; client chỉ gửi chuỗi mã, không được quyết định phần thưởng hoặc tài khoản nhận. Có giới hạn tần suất, chặn lúc hồ sơ chưa tải/lưu lỗi và phản hồi kết quả từ máy chủ. Tài khoản khác không được nhận dù biết mã hoặc gọi remote trực tiếp.

Phần thưởng và dấu **`Economy.RedeemedCodes.AdminTest20261021`** được ghi cùng một giao dịch **`CommitEconomy`**. Chỉ báo thành công sau khi lớp lưu xác nhận; lỗi ghi không cộng riêng thưởng hoặc dùng riêng mã. Dấu dùng mã được giữ qua tải lại và qua việc dọn các receipt mua/chế cũ. Không có nút reset mã; đổi chuỗi mã mà giữ cùng CodeId không cho nhận thêm. Studio và game live tiếp tục dùng hai store riêng theo cấu hình persistence.

### 40.2. Cài trên bản Studio đang mở

Sau khi nối lại phiên Studio bị lag, bản đang mở là cloud **`PlaceId 103261391098991`**. Bản sao native trước cài: **`HunDino/backups/Hub_before_admin_redeem_20261021.rbxl`**, **4.262.220 byte**. Ba source cũ được giữ trong **`ServerStorage.AdminCodeBackup_20261021`** và **`HunDino/backups/redeem-admin-20261021/`**. Cài ba source sửa và bốn module mới; đã lưu bằng Studio, chưa xuất bản thay đổi lên game live.

Bản xuất native sau cài: [HunDino_AdminTest_20261021.rbxl](<C:/Users/khanh/OneDrive/Documents/ChatGPT/game roblox/HunDino/HunDino_AdminTest_20261021.rbxl>), **4.285.326 byte**, SHA256 **`926f6b57297fe1ea103985cc26ec56a8e96414b7fb34657b64887632b687c8da`**. Giữ bản này riêng với file local v2.4 và bản sao trước cài.

Bản cloud này đã có `HuntEconomyService` phụ thuộc `BioTubeService` nhưng thiếu module. Khôi phục ba module chuẩn `BioTubeGeometry`, `BioTubeSpecimen` và `BioTubeService` để dịch vụ khởi động; chỉ ghi source, không dựng hoặc sửa map đã biên tập. Trong Play, logic module hiện có dựng 60 ống theo 12 base tại runtime; kết quả này không thay cho nghiệm thu đầy đủ tính năng trưng bày. File **`HunDino_DarkJungle_v2_4.rbxl`** cục bộ giữ nguyên vì có thể khác bản cloud do các sửa mỹ thuật ở chat khác.

### 40.3. Kiểm chứng và trạng thái mã thật

- Offline **346 kiểm tra / 11 nhóm** đạt: quyền, đúng gói thưởng, nhận lại, chuyển dữ liệu/JSON, dọn receipt, giới hạn số dư và lỗi trước/sau ghi.
- Trong Studio, **156 kiểm tra / 6 nhóm** dùng method dịch vụ thật với player/store giả đạt; không dùng kết quả này để khẳng định DataStore cloud thật đã nghiệm thu.
- Đã bấm **Cài đặt → Nhập code**, gửi mã sai **`QA-INVALID-CODE`** và nhận từ chối; nút **Quay lại** hoạt động. Tài khoản admin thật vẫn **80 xu, cả năm loại nguyên liệu bằng 0**, dấu mã chưa dùng. Không tiêu thụ mã thật để làm QA.

Inspector **`native-save`** đạt **8.683 kiểm tra**, **129 script biên dịch**, **7 source chuẩn khớp** và **3 backup source gốc khớp**. Đối chiếu **61.208 Instance hiện có / 5.334.543 lượt đọc và so thuộc tính**, không phát hiện khác biệt ngoài source đã cho phép; báo cáo liệt kê rõ các thuộc tính reflection không đọc được. Giữ **43.775 Part / 845 khớp**, riêng Workspace **35.064 Part / 723 khớp**, cùng hash dữ liệu thuộc tính Terrain nhị phân. `HistoryId` được loại khỏi metadata lịch sử chỉnh sửa; `FilteredSelection` ở gốc đều bằng 0 trước/sau. Báo cáo: **`HunDino/assets/redeem/admin-redeem-saved.json`**. Inspector chỉ đọc, không xuất lại Place/Terrain bằng Lune.

Báo cáo Play nằm ở **`HunDino/assets/redeem/admin-redeem-play.json`**. Phạm vi đợt này là mã thử riêng admin; không mở mã cho mọi người, không đổi luật thưởng săn và không coi hồi quy P1-G hoặc lưu cloud qua phiên mới đã hoàn tất.

## 41. Cửa hàng và nâng cấp riêng bảy vũ khí — 26/10/2026

Đã sửa giao diện thương nhân/icon thành một bảng Vật tư & chế tạo / Nâng cấp vũ khí; sửa lớp nền che chữ và hiển thị đủ bảy hàng. Mỗi vũ khí của Người giữ cấp riêng trong Economy.WeaponLevels, nâng lên cấp 2 bằng 2 xương + 2 sắt, tăng 15% sát thương chỉ cho đúng vũ khí đó. Giữ HammerLevel tương thích dữ liệu cũ; server kiểm token, SnapshotVersion, operation serial và vị trí tại bàn base chủ. Bỏ thanh Đã lưu/LƯU trên HUD, giữ tự lưu ngầm và chặn khi chưa tải được tài khoản.

Bản native cửa hàng trước gộp: HunDino_MerchantWeapons_20261026.rbxl, 4.368.355 byte. Người dùng đã chọn ghép sửa chiến đấu vào chính file này để dùng tiếp; kết quả hiện hành ở mục 42. Sao lưu cửa hàng tại backups/merchant-weapons-20261026/ và bảy script gốc trong ServerStorage.MerchantWeaponsBackup_20261026; bản ngay trước gộp tại backups/bow-pet-20261026/. Chưa Publish bản gộp.

Đã thử giao dịch bằng UI trong Studio/TestMemory riêng, nâng đủ bảy loại và Inventory hiển thị đúng cấp; native JSON round trip giữ cấp. Đạt 238 kiểm tra mới cho cấp riêng, lưu qua phiên mới, chống replay và chuyển dữ liệu; hồi quy kinh tế, schema, session store, JSON round trip, mã thưởng và luật nhiệm vụ đều đạt. Desktop và HD 720 vừa màn hình, cả bảy vũ khí không bị cắt; Studio đã trở về viewport mặc định. Inspector đọc bản lưu đạt 523 kiểm tra, 146 script biên dịch, fingerprint Workspace/Part/Joint giữ nguyên, 66 thuộc tính Terrain đọc được khớp. Lune chưa đọc được VoxelGridAssetContentMap nên không chứng nhận riêng thuộc tính đó; chỉ Studio native lưu Place/Terrain. Không dùng tài khoản thật để cấp nguyên liệu QA và đã gỡ cờ TestMemory/script thử khỏi bản lưu.

Chi tiết phạm vi, hạn chế và cách gộp an toàn: HunDino/MERCHANT_WEAPON_UPGRADES.md. Bằng chứng: HunDino/assets/merchant-weapons/studio-play.json và saved-inspection.json. Chưa coi đây là nghiệm thu đầy đủ bắt sống hoặc lưu cloud trên Roblox Player.

## 42. Gộp MerchantWeapons với sửa cung, Pet và di chuyển — 26/10/2026

Người dùng chọn **“Ghép vào MerchantWeapons mới rồi dùng bản đó”**. Bản chính từ đây là **HunDino_MerchantWeapons_20261026.rbxl**, mở bằng **CHOI_CUA_HANG.cmd** hoặc **CHOI_VA_LUU.cmd**. Cả hai bật bộ lưu cục bộ hiện có rồi mở cùng bản Studio. Không đổi namespace hoặc xóa dữ liệu tài khoản. Các thử nghiệm của đợt này dùng TestMemory riêng, không cấp/trừ đồ trên hồ sơ thật. Tài liệu vận hành: [BOW_PET_FIXES.md](<C:/Users/khanh/OneDrive/Documents/ChatGPT/game roblox/HunDino/BOW_PET_FIXES.md>).

### 42.1. Cung và di chuyển

- **Pet khi ngắm/tụ:** theo sau bên trái, lệch ngang 7 và lùi 7 studs; bỏ Pet khỏi ray ngắm/bắn. Phần Pet gần camera được ẩn cục bộ khi ngắm/tụ và khôi phục khi ngừng ngắm.
- **Bắn khi đi ngang:** client gửi điểm ngắm; server tính hướng từ vị trí bắn hiện tại của từng mũi, kiểm vật cản/tầm/sát thương. Điểm client chỉ là ý định ngắm, không phải quyền xác nhận trúng.
- **E Tam Tiễn:** ba mũi hội tụ, cách nhau 0,12 giây; mỗi mũi có mã đòn riêng, cùng trúng một mục tiêu gây **24 × 3 = 72** ở cấp 1. Vẫn chặn nhận lại cùng mã mũi tên và giữ cooldown đòn thường. Vật cản, trượt hoặc vượt tầm vẫn có thể làm một mũi không trúng.
- **Tầm:** không tụ **40 studs**, đầy lực sau **1,2 giây là 120 studs**; nội suy `40 + 80 × mức_tụ` theo thời gian server. Q/E và combo không tụ dùng 40 studs. Điều khiển giữ/nhả chuột trái, Q/E và ngắm chuột phải giữ nguyên.
- **Cấp riêng:** giữ hệ số +15% của đúng vũ khí từ mục 41, áp dụng cho cung lên cả hình nộm và khủng long. E cung cấp 2 làm tròn 28 mỗi mũi, tổng **84** nếu trúng đủ. Không thay cân bằng vũ khí khác.
- **W và camera:** giữ di chuyển tương đối camera; thân theo camera khi ngắm, trả AutoRotate khi ngừng ngắm. Không dùng lại giá trị false tạm của đòn cũ hoặc ép hướng root về hướng bắn đã chụp trước đó.

### 42.2. Pet trong khu săn

- Một lần áp sát chỉ gây **một đòn 12 sát thương**, kể cả vũ khí có nhiều mốc hoạt ảnh. Sau đòn về cạnh chủ, chờ ít nhất **10 giây tính từ đòn trước** mới tiếp cận tiếp; đi đường có thể kéo dài khoảng giữa hai đòn.
- Không mở đòn hoặc hoàn tất đòn khi quái còn ≤10% HP. Lớp sát thương server đồng thời clamp đòn Pet tại ngưỡng này (T-Rex 1.200 HP dừng ở 120); người chơi vẫn có thể hạ quái. Tiếp tục dừng đánh khi chủ cho uống thuốc ngủ.
- **Tự hồi:** sau 5 giây không bị đánh, tại nơi an toàn hồi 10 HP/giây, tối đa 100. Khi HP ≤25%, chủ động rút ra xa quái hơn 40 studs, chọn điểm trong 80 studs quanh chủ và chỉ trở lại đánh khi hồi đủ. Vật cản/quái áp sát có thể trì hoãn tới chỗ an toàn.
- HP còn 1 vẫn choáng 30 giây rồi đầy theo luật cũ. Về sảnh hoặc bắt đầu lượt săn mới đầy 100 HP/hết choáng; chuyển vị trí trong cùng lượt săn đang tiếp tục không được coi là lượt mới. Tự hồi/choáng/chuyển khu đều **giữ nguyên hạn hồi kỹ năng chữa chủ** (70% HP tối đa, 119 giây).

### 42.3. Kiểm chứng và bản lưu

- Play trên nhân vật với input thật: E cấp 1 làm hình nộm 1.000 → 928; tầm không tụ/nửa lực/đầy đo 40,01 / 81,19 / 120 studs. Giữ D ở tốc độ 8 vẫn trúng mặt mục tiêu. Phép thử đi ngang dùng camera QA giữ tâm vào đích để tách lỗi đường bắn khỏi rê chuột; không thêm tự khóa mục tiêu vào game.
- Giữ W và xoay camera ba hướng: 32 mẫu tự do có dot hướng đi/camera = 1, thân/hướng đi tối thiểu 0,961; 32 mẫu ngắm/tụ đều bằng 1. Pet gần camera có 119/119 Part được ẩn rồi khôi phục đủ. Không cần video để thực hiện phép tái tạo này.
- Pet 80 HP chưa hồi ở 4,5 giây, đạt 94,64 sau 6,5 giây; Pet 1 HP/choáng về sảnh rồi vào lượt mới đều đạt 100, giữ cùng hạn chữa chủ. Native rig/controller với mục tiêu cố định xác nhận đòn ở 1000,25 và 1011,75, 135 mẫu chờ tại chủ; rút cách quái 47,50 studs rồi hồi đầy. Tìm đường vòng tường riêng đạt 4,38 giây, không xuyên tường; không suy rộng thành mọi địa hình tự nhiên.
- Trên chính bản MerchantWeapons sau ghép, Play E cấp 1 đạt 72, cấp 2 đạt 84. Bộ native combat **112**, Pet sortie **144** đạt; hồi quy thêm hình học cung **56**, luật Pet **159**, controller doubles **29**, controller engine **83**, sáu nhóm combat và tụ lực đạt. Đây là các bộ kiểm riêng, không cộng thành số tình huống chơi độc lập.

Lưu bằng **native Roblox Studio**, không xuất lại Place bằng Lune. File chính **4.372.018 byte**, SHA256 `6265cf48569a69fe28b7700704685d132fd3be4b569195378e5bc90d9325729e`. Inspector chỉ đọc đạt **83.644 kiểm tra / 155 script biên dịch**, chín source cài và tám source backup khớp; source không liên quan giữ nguyên. Toàn bộ fingerprint Workspace giữ **47.064 Part / 723 khớp nối**; cả 70 thuộc tính Terrain nhị phân giữ nguyên byte, gồm VoxelGridAssetContentMap mà Lune chưa giải mã. Đã gỡ probe và cờ QA.

Server bản chính: `src/savegame/TrainingMerchant.server.luau`; client: `src/savegame/Training.client.luau`; bộ luật cài từ `studio-pet-integration/Weapons.luau`, `TrainingRules.luau`; Pet/combat từ `src/hunting`; hình học cung `src/dark-jungle/BowBallistics.luau`. Không lấy các biến thể source khác ghi đè toàn bộ bản chính. Backup trước ghép: `backups/bow-pet-20261026/` và `ServerStorage.BowPetBackup_20261026`. Bằng chứng: `assets/qa/bow-pet-play.json`, `bow-pet-merchant-install.json`, `bow-pet-merchant-saved.json`.

**Chưa Publish bản gộp**, chưa nghiệm thu điện thoại, multiplayer, mọi địa hình, bắt sống toàn vòng hoặc cloud Roblox Player cho đợt này. Cảnh báo asset 203785492 sai loại có từ bản nền; không dùng kết quả kiểm source thay cho nghiệm thu các phần còn chờ của P1-G.

## 43. Công thức bẫy sắt trong Inventory — 26/10/2026

Theo yêu cầu mới, đã mở công thức tại I → CHẾ TẠO: **1 bẫy thô + 1 sắt → 1 bẫy sắt**. Hiển thị mô hình bẫy, số nguyên liệu hiện có/yêu cầu, thanh đủ/thiếu, số bẫy trong kho và nút chế một bẫy. Xem được từ xa; giao dịch chỉ mở khi gần bàn chế tạo tại base chủ, đã cất vũ khí, không trong lượt săn và hồ sơ sẵn sàng. Server kiểm token, SnapshotVersion, OperationSerial; dùng CraftTrap hiện hành và lưu xác nhận trước khi báo thành công. Không tốn xu; không trừ một phần hoặc nhận trùng do gửi lại.

Đã thử input thật trong Studio/TestMemory riêng: 2 bẫy thô/2 sắt → chế hai lần → 2 bẫy sắt, hết nguyên liệu; xu giữ 80. Nút khóa khi thiếu nguyên liệu và khi rời bàn dù đủ nguyên liệu. Handler server với dữ liệu giả đạt 22 kiểm tra; cấp riêng bảy vũ khí từ bản native đạt 238 kiểm tra; chín source chiến đấu cùng UI/lưu giữ đúng qua 25 kiểm tra đối chiếu. Không ghi tài khoản thật.

Đã backup bản chính tại backups/inventory-crafting-20261026/ và hai script trong ServerStorage.InventoryCraftBackup_20261026. File chính MerchantWeapons lưu native Studio: 4.373.461 byte, SHA256 10ff67e69b8d8151c35160d7c5a4b918d85d54dbe7b804c835a5c848f55a535a. Inspector chỉ đọc đạt 83.656 kiểm tra / 157 script biên dịch, hai source sửa khớp, giữ 47.064 Part/723 khớp và toàn bộ byte của 70 thuộc tính Terrain. Cờ/script QA đã gỡ. Chưa Publish lên Roblox. Xem HunDino/INVENTORY_CRAFTING.md và assets/inventory-crafting/ để biết cách dùng, phạm vi và bằng chứng.

## 44. Chừa đường dịch chuyển và đi lại tại toàn bộ 12 base — 27/10/2026

Ảnh Base 3 cho thấy nhân vật đáp trong ống. Kiểm bản chính và các mốc cũ tìm được đều còn cụm ống v4 chồng điểm đến tại Base 3, 5, 6, 10. Base 11 từng dời thủ công nhưng metadata trưng bày vẫn trỏ vị trí cũ. Chưa tìm được bản cũ đã sửa đủ 12 base.

Đã dùng `BioTubeGeometry.5 / TransitClearance.1`, điều chỉnh cụm 3–7, 9–10, 12 để chừa đường từ sảnh qua bệ đến SpawnPad; giữ bố cục an toàn tại 1, 2, 8, 11. Đồng bộ mã dựng lại, vị trí 60 ống và `StaticOrigin`/`ClusterOrigin`/anchor. Giữ toàn bộ 12.000 Part của ống và thuộc tính va chạm; không dời điểm dịch chuyển. Tâm ống cách tuyến đi ít nhất 10 studs. Asset art-only và bộ dựng asset dùng cùng module hình học.

Play thực tế với TestMemory riêng: giữ G mở bảng, bấm từng Base 1–12, xác nhận điểm đến không chạm ống, đi ra 22,33–22,78 studs rồi giữ G về sảnh; cả 12 đạt và giữ quyền sở hữu base. Sau chỉnh pivot cuối 0,025 studs theo Y, dò lại 252 mẫu hộp thân người trên 12 tuyến không giao ống có va chạm. Không dùng hồ sơ thật để thử. Cờ/script QA đã gỡ.

Lưu native Studio vào bản chính: **4.495.025 byte**, SHA256 `8626bc714aa7a0da39493ba1bbcc676a142038b2f8a2c06e602fe01d522229bf`. Inspector chỉ đọc đạt **129.779 kiểm tra / 164 source biên dịch** (thêm module backup); các source gameplay/lưu khác giữ nguyên. Fingerprint 49.221 instance ngoài cụm ống và byte của toàn bộ 70 trường Terrain khớp backup. Backup tại `HunDino/backups/base-clearance-20261027/` và `ServerStorage.BaseClearanceBackup_20261027`.

Bằng chứng: `HunDino/assets/base-clearance/studio-play.json`, `survey.json`, `saved-inspection.json`; kiểm lại bằng `HunDino/tools/inspect-base-clearance-saved.luau`. Chi tiết vận hành: `HunDino/BIO_TUBES.md`. **Sửa ống này chưa Publish**; cloud v14 là mốc trước sửa. Chưa kiểm nhiều người cùng lúc hoặc Roblox Player với bố cục mới.
