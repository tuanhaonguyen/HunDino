# PROMPT: THIẾT KẾ MAP ĐI SĂN “THUNG LŨNG SƯƠNG XÁM”

<!-- TIEN_DO_20261027_BEGIN -->
> **Trạng thái đối chiếu 27/10/2026, 09:48 UTC+7:** local chính `HunDino_MerchantWeapons_20261026.rbxl` **4.495.025 byte**, SHA256 `8626bc714aa7a0da39493ba1bbcc676a142038b2f8a2c06e602fe01d522229bf`; inspector **129.779 kiểm / 164 source**, đạt. Cloud có bằng chứng mới nhất **v14**, nguồn **4.481.440 byte**; sửa bố cục ống mới chỉ local, **chưa Publish**.
>
> Tính năng trong tài liệu này được đối chiếu cùng bản chính hiện hành; các file v2.x/SaveGame, tham số và kết quả thử cũ trong phần dưới là mốc lịch sử, không tự chứng nhận toàn bộ bản mới. Phạm vi còn chờ: P1-G toàn vòng, cloud kinh tế/cá thể/ống, nhiều client và thiết bị thật.
>
> [Báo cáo tiến độ toàn dự án và hôm nay](HunDino/BAO_CAO_TIEN_DO_2026-10-27.md). Ghi chú này cập nhật trạng thái; số liệu/hash của từng mốc cũ bên dưới giữ nguyên theo phạm vi lúc kiểm.
<!-- TIEN_DO_20261027_END -->

**Đồng bộ tài liệu: 20/10/2026 — đối chiếu bản v2.4 đã lưu ngày 19/10/2026.**

## Tiến độ thực tế — H2.0 trong bản chung v2.4

Mở [HunDino_DarkJungle_v2_4.rbxl](HunDino/HunDino_DarkJungle_v2_4.rbxl) trong thư mục Documents của dự án. Khu săn đã dựng và ghép cùng sảnh/base/bãi tập; bảng dưới phân biệt phần đã làm với yêu cầu còn chờ. Nội dung thiết kế gốc ở phần sau tiếp tục là định hướng, không phải danh sách tính năng đã hoàn thành.

| Nhóm yêu cầu | Trạng thái thực tế và giới hạn |
| --- | --- |
| Kích thước/tọa độ | Đã có 4.000 × 4.500 studs, Bắc là Z dương; khu săn đặt lệch `(0,0,6500)` trong Place chung |
| Địa hình và tám sinh cảnh | Đã dựng trạm kiểm lâm, đồng cỏ/rừng thưa, rừng thông Tây, hồ/đảo, đầm lầy Đông, xưởng gỗ bỏ hoang, khe suối/thác và núi/hang; không suy ra mọi kích thước/chi tiết yêu cầu gốc đã nghiệm thu |
| Cây và trang trí | 2.400 cây, thư viện 12 biến thể thông/6 bạch dương/6 sồi/1 liễu; có đá rêu, cây thấp, nhà gỗ, cầu/lối ván, bến và thuyền trang trí |
| Đường và tuần tra | 16 đường: 13 nhánh quái hai chiều + 3 đường người từ trạm; 9 node kỹ thuật A/B/C/R1–R5/Camp, 9 phương án tuần tra; 8 điểm quái nghỉ 60 giây thật. Tám sinh cảnh không phải tám node kỹ thuật |
| Đi lại/điểm nhấn | Đã thử đi bộ ra đảo theo lối nông và xuyên hang ra cửa sau; thác khoảng 57 studs; kiểm chứng tuyến tăng tốc đã có, chưa đi nghiệm thu mọi lối/độ cao của thiết kế gốc |
| Đồng hồ/ánh sáng | Giờ vào lấy UTC+7, chạy ×30; ánh sáng theo người đang săn, trả về trạng thái sảnh khi rời khu |
| Thú và theo dấu | Chỉ một T-Rex mẫu đã có tuần tra/combat; chưa có hươu, thỏ, lợn rừng, sói, gấu, đàn thú, dấu vết động hoặc hệ ổ thú theo từng loài. Hang/dấu tích mới là cảnh quan |
| Gameplay đã nối sau H2 | Pet hỗ trợ chiến đấu/hồi máu P1-C; nhiệm vụ solo/bẫy/bắt P1-D; quặng/vảy/mổ/thưởng/mua/chế/nâng P1-E; kho cá thể P1-F bước đầu |
| Âm thanh/hiệu ứng chi tiết | Không có bằng chứng nghiệm thu toàn bộ âm thanh theo sinh cảnh, tiếng thú định hướng hoặc mọi hiệu ứng lá/côn trùng trong yêu cầu gốc; giữ là mục cần đối chiếu |
| Trưng bày/lưu và mở rộng | Chưa có ống trưng bày hoặc DataStore; kho chỉ trong cùng máy chủ. Chế tạo trong Inventory chờ, bàn chế/nâng P1-E tại base đã có. Chưa có lái thuyền/AI leo vách/săn đội |
| Tối ưu và đầu ra thiết kế | Có source cấu hình/bộ dựng, ảnh cảnh quan và báo cáo kiểm chứng; chưa nghiệm thu 12 client, điện thoại/máy yếu hoặc đầy đủ bảy đầu ra của mục 16 như bộ hồ sơ hoàn công |

Bằng chứng H2 có sẵn: **39.081 kiểm tra cảnh quan, 148 kiểm tra tuyến, 96 combat và 12 đồng hồ**, cùng Play/bản lưu H2; xem [GREY_MIST_VALLEY.md](HunDino/GREY_MIST_VALLEY.md). Bản lưu cuối sau kho cá thể qua **139.120 kiểm tra đọc/đối chiếu**, vẫn giữ 2.400 cây/16 đường/9 khu; xem [SPECIMEN_COLLECTION.md](HunDino/SPECIMEN_COLLECTION.md). Số phép kiểm tra không phải số tình huống chơi thực tế. Đợt 20/10 chỉ đồng bộ tài liệu, không thử gameplay mới.

Luồng hiện hành: **J tại sảnh → nhận nhiệm vụ → săn/hạ hoặc bắt → 120 giây thu hoạch → về sảnh**. Thám hiểm qua menu Chơi/cổng vẫn dùng được khi chưa có nhiệm vụ. Xem [nhiệm vụ](HunDino/HUNT_QUEST.md), [kinh tế](HunDino/HUNT_ECONOMY.md) và [thiết kế tổng](THIET_KE_GAME.md).

## Yêu cầu thiết kế gốc — đối chiếu với tiến độ phía trên

Hãy đóng vai một **chuyên gia thiết kế môi trường 3D, Level Designer và Environmental Artist chuyên nghiệp cho Roblox**. Thiết kế một bản đồ thế giới mở về khám phá thiên nhiên, theo dấu động vật và đi săn, với kích thước khoảng **4.000 studs theo chiều Đông – Tây × 4.500 studs theo chiều Bắc – Nam**.

Tôi cần một bản thiết kế có thể dùng làm tài liệu dựng map thực tế. Hãy mô tả từng khu vực, địa hình, công trình, thảm thực vật, đường đi, nguồn nước, nơi động vật xuất hiện và cấu trúc ổ thú. Mọi chi tiết phải liên kết thành một thế giới có chủ đích, có điểm nhấn thị giác và có trải nghiệm khám phá.

**1. Đề tài, chủ đề và cảm giác tổng thể**

Map có tên **“Thung Lũng Sương Xám”**, lấy cảm hứng từ vùng rừng núi ôn đới vào đầu mùa thu.

Đây từng là một khu khai thác gỗ nhỏ, sau đó bị bỏ lại để thiên nhiên phát triển trở lại. Hiện tại chỉ còn một trạm kiểm lâm đang hoạt động, vài lán gỗ cũ, đường vận chuyển xuống cấp, cầu gỗ, tháp quan sát và những dấu tích sinh hoạt rải rác trong rừng.

Chủ đề xuyên suốt là **con người nhỏ bé giữa thiên nhiên rộng lớn**. Người chơi bắt đầu ở một khu an toàn, dễ quan sát, rồi đi sâu dần vào những vùng có địa hình phức tạp, tầm nhìn hạn chế và động vật khó tiếp cận hơn.

Bản đồ cần tạo được những cảm giác sau:

- Buổi sáng yên tĩnh, sương bám trên mặt hồ và len giữa các thân cây.
- Buổi trưa nhìn rõ các sườn núi, bãi cỏ và đường mòn.
- Chiều muộn có ánh nắng vàng xuyên qua tán lá, tạo những khoảng sáng đẹp.
- Ban đêm tối hơn rõ rệt, nghe tiếng cành cây, tiếng nước và tiếng động vật ở xa.
- Càng đi về phía Bắc, môi trường càng hoang vu, lạnh và khó đoán.

Không đưa thành phố, đường nhựa lớn, nhà cao tầng hoặc công trình hiện đại nổi bật vào map.

**2. Phong cách hình ảnh**

Sử dụng phong cách **stylized realistic**: hình khối rõ, đẹp khi nhìn từ xa, vật liệu có chiều sâu nhưng không quá nhiều chi tiết nhỏ gây rối.

Cây có thân hơi cong, rễ nổi và tán lá không đồng đều. Đá có mặt gãy lớn, cạnh được xử lý tự nhiên. Công trình gỗ cần có cột chịu lực, mái dốc, ván ghép, dấu bạc màu và những chỗ sửa chữa.

Bảng màu chính gồm:

- Xanh rêu và xanh thông đậm cho rừng.
- Xanh xám cho núi xa và các vùng nhiều sương.
- Nâu đất ẩm, nâu vỏ cây và màu gỗ cũ.
- Vàng cỏ khô, cam đất và đỏ nâu cho lá mùa thu.
- Xanh lục xám cho nước hồ và đầm lầy.

Màu vàng và cam xuất hiện thành từng cụm có chủ đích để dẫn mắt, không phủ đều toàn bản đồ. Các khu vực cần khác nhau về sắc độ nhưng vẫn thuộc cùng một thế giới.

**3. Kích thước, tọa độ và bố cục**

Quy ước tâm map là **X = 0, Z = 0**:

- Biên Tây: X = -2.000.
- Biên Đông: X = 2.000.
- Biên Nam: Z = -2.250.
- Biên Bắc: Z = 2.250.
- Trong tài liệu này, hướng Bắc là chiều Z dương.

Địa hình đi từ vùng thấp ở phía Nam lên vùng núi ở phía Bắc. Chênh lệch độ cao toàn map khoảng **500–650 studs**. Tránh làm toàn bộ mặt đất thành một mặt phẳng rồi đặt cây lên trên.

Chia map thành tám khu vực có ranh giới mềm, chuyển tiếp bằng địa hình và thảm thực vật:

| Khu vực | Vị trí tâm gần đúng | Phạm vi thiết kế tham khảo |
|---|---|---|
| Trạm kiểm lâm và bìa rừng | X = 0, Z = -1.900 | 700 × 550 studs |
| Đồng cỏ và rừng thưa phía Nam | X = -150, Z = -1.100 | 2.500 × 1.000 studs |
| Rừng thông già phía Tây | X = -1.250, Z = 0 | 1.200 × 1.900 studs |
| Hồ trung tâm | X = 100, Z = 100 | 1.100 × 850 studs |
| Đầm lầy phía Đông | X = 1.350, Z = -200 | 1.000 × 1.400 studs |
| Khu khai thác gỗ bỏ hoang | X = -650, Z = 950 | 800 × 650 studs |
| Thung lũng đá và suối phía Bắc | X = 450, Z = 1.050 | 1.400 × 900 studs |
| Dãy núi và hang phía Bắc | X = 0, Z = 1.850 | 3.500 × 750 studs |

Các phạm vi trên có thể giao nhau ở vùng chuyển tiếp; không xây thành tám ô vuông riêng biệt.

**4. Khu 1 — Trạm kiểm lâm và điểm bắt đầu**

Đặt trạm kiểm lâm ở phía Nam trên một nền đất cao nhẹ, nhìn được về thung lũng nhưng không nhìn thấy toàn bộ map.

Khu trạm gồm:

- Một nhà gỗ chính khoảng 65 × 45 studs, có hiên trước.
- Một kho dụng cụ khoảng 35 × 25 studs.
- Một sân đất khoảng 120 × 100 studs.
- Một chòi hướng dẫn, bảng bản đồ và bảng nhiệm vụ.
- Một bãi tập sử dụng trang bị hướng vào sườn đất, tách khỏi đường ra vào.
- Một đống củi, bồn nước, bàn sơ chế vật phẩm và chỗ nghỉ.
- Hàng rào thấp chỉ bao quanh một phần khu trạm.
- Hai cột đèn ánh sáng vàng và một đống lửa nhỏ.

Mái nhà màu xanh xám đã bạc, tường gỗ nâu ấm, chân móng bằng đá. Bổ sung máng nước, thùng gỗ, dây treo áo mưa, dấu giày và vệt bánh xe để công trình có dấu hiệu được sử dụng.

Có ba lối rời trạm:

1. Lối chính đi thẳng ra đồng cỏ, dễ đi và dễ định hướng.
2. Lối phía Tây vào rừng thông, hẹp hơn và nhiều bóng tối.
3. Lối phía Đông dẫn tới một cầu gỗ nhỏ và vùng đất ẩm.

Trong khoảng 250 studs quanh khu trạm không có thú săn mồi chủ động tấn công. Từ sân trạm, người chơi phải thấy được một ngọn núi đặc trưng và một phần tháp quan sát để ghi nhớ phương hướng.

**5. Khu 2 — Đồng cỏ và rừng thưa phía Nam**

Đây là nơi người chơi học đọc dấu vết và tiếp cận động vật.

Tạo địa hình bằng những đồi thoải cao khoảng 15–45 studs, xen giữa là các lòng trũng. Bố trí ba bãi cỏ chính với kích thước khác nhau, ngăn cách bởi cụm cây và gò đất.

Thảm thực vật gồm:

- Cỏ ngắn trên đường động vật thường đi.
- Cỏ cao ở rìa bãi và vùng đất thấp.
- Cụm bạch dương thân trắng.
- Một số cây sồi tán rộng.
- Bụi dâu rừng, hoa nhỏ và cây non.
- Gốc cây mục, cành gãy và đá thấp.

Động vật phù hợp là thỏ, hươu và lợn rừng. Hươu có thể ăn ở khoảng trống rồi rút về bìa rừng khi bị làm kinh động. Lợn rừng ưu tiên vùng có bụi rậm và đất bị xới.

Thiết kế một điểm đặc trưng là **“Đồi Sồi Đơn Độc”**: một cây sồi lớn đứng trên đồi, tán rộng, nhìn được từ nhiều nơi ở phía Nam. Dưới gốc có đá phủ rêu và một đoạn hàng rào cũ.

Hang thỏ nằm ở sườn gò khô, gần bụi cây. Lối vào nhỏ, có đất mới đào và vài đường cỏ bị ép xuống. Không đặt hang giữa bãi trống hoàn toàn.

**6. Khu 3 — Rừng thông già phía Tây**

Đây là vùng rừng có cảm giác sâu và lâu đời nhất.

Dùng thông cao khoảng 80–140 studs làm tầng cây chính, xen các cây thấp hơn để tránh tán rừng đồng đều. Khoảng cách giữa thân cây thay đổi theo cụm: có đoạn thoáng cho người chơi quan sát và có đoạn dày tạo cảm giác bị bao quanh.

Nền rừng gồm lá kim, rêu, đất nâu sẫm và đá lộ thiên. Dương xỉ mọc ở nơi ẩm, cây bụi tập trung quanh khoảng sáng. Bố trí cây đổ, thân cây rỗng, gốc cây bật rễ và các tảng đá lớn.

Các địa điểm cần có:

- Một khe suối hẹp có thể đi qua bằng thân cây đổ.
- Một lán trú mưa khoảng 25 × 20 studs.
- Một hốc đá nhỏ để nghỉ hoặc quan sát.
- Một khoảng rừng cháy cũ có thân cây đen và cây non mọc lại.
- Một cây thông cổ thụ có rễ nổi, dùng làm mốc tìm đường.

Đặt một ổ sói trong vùng đất cao, khô, cách đường chính khoảng 180–250 studs.

Đường tiếp cận ổ phải có diễn biến:

1. Từ đường mòn, người chơi phát hiện dấu chân ở một vũng bùn.
2. Dấu chân dẫn tới một khúc cây có vết cào.
3. Sau khúc cây là lối nhỏ đi vòng qua hai tảng đá.
4. Địa hình mở ra một khoảng sân đất trước ổ.
5. Cửa ổ nằm dưới bộ rễ lớn cạnh vách đá.

Ổ có cửa chính khoảng 12 × 10 studs, khoang trong khoảng 30 × 25 studs và một lối phụ hẹp về phía sau. Trước cửa có cỏ bị giẫm, lông mắc trên bụi cây và dấu chân chồng lên nhau.

**7. Khu 4 — Hồ trung tâm**

Hồ là điểm nhận diện quan trọng nhất của map, có hình bất đối xứng, nhiều vịnh nhỏ và bờ cong.

Mặt nước chính dài khoảng 900 studs, rộng khoảng 600 studs, sâu khoảng 12–55 studs. Đường bờ nằm trong phạm vi lớn hơn để có đủ không gian cho bãi cỏ, đá và đường đi.

Chia bờ hồ thành bốn kiểu:

- Bờ Nam thoải, có sỏi và bãi cỏ cho động vật xuống uống.
- Bờ Tây nhiều đá, cây lớn và bóng râm.
- Bờ Đông có lau sậy, đất bùn và nước nông.
- Bờ Bắc tiếp giáp vách đá thấp và cửa suối.

Có một đảo nhỏ khoảng 110 × 75 studs, trên đảo có vài cây thông, đá lớn và một điểm quan sát kín. Có thể đến đảo bằng thuyền hoặc một tuyến nước nông được thiết kế rõ ràng; không để người chơi vô tình mắc kẹt giữa hồ.

Một cầu tàu gỗ cũ nằm ở bờ Nam, dài khoảng 45 studs, có cọc buộc thuyền và mái che nhỏ.

Tạo ít nhất ba điểm động vật uống nước, mỗi điểm có đường tới và đường rút riêng. Dấu chân tập trung ở đất ẩm. Các bãi uống nước phải có vật che cho cả người chơi lẫn động vật để việc tiếp cận có chiều sâu.

**8. Khu 5 — Đầm lầy phía Đông**

Đầm lầy mang màu xanh xám, ánh sáng dịu và có nhiều lớp che khuất tầm nhìn.

Địa hình gồm các vũng nước nông, ụ đất khô, rễ cây nổi và lạch nước nhỏ. Phần lớn nước sâu khoảng 1–5 studs; các vũng sâu hơn cần có khác biệt về màu nước và bờ để người chơi nhận biết.

Cây cối gồm:

- Liễu có cành rủ.
- Cây thân cong mọc sát nước.
- Lau sậy cao khoảng 8–14 studs.
- Cỏ nước, dương xỉ và bụi cây thấp.
- Cây chết đứng, thân cây phủ rêu và nấm ở chân gỗ mục.

Bố trí một tuyến cầu ván rộng 8–10 studs, dài tổng cộng khoảng 220–300 studs. Cầu có đoạn nghiêng, ván bạc màu và tay vịn chỉ xuất hiện ở những chỗ nguy hiểm.

Các điểm khám phá gồm một chòi quan sát chim, chiếc thuyền mắc cạn, lán cũ trên cọc và một gò đất khô nằm sâu trong đầm.

Lợn rừng có điểm nghỉ trong bụi rậm trên gò cao. Đường tới nơi nghỉ bắt đầu bằng dấu đất bị ủi, bùn bắn lên gốc cây và những đoạn lau bị gãy. Người chơi có hai hướng tiếp cận: đường gần xuyên qua bùn gây nhiều tiếng động, hoặc đường vòng dài hơn trên nền đất chắc.

**9. Khu 6 — Khu khai thác gỗ bỏ hoang**

Khu này kể câu chuyện quá khứ của thung lũng.

Các hạng mục gồm:

- Nhà xưởng gỗ khoảng 80 × 55 studs.
- Nhà nghỉ công nhân khoảng 50 × 30 studs.
- Kho dụng cụ nhỏ.
- Bãi gỗ cũ và giá đỡ đã đổ.
- Một bệ máy cưa phủ rêu.
- Đường xe vận chuyển có vệt lún.
- Trạm gác nhỏ và bảng tên đã bạc.

Mái xưởng bị sập một phần để ánh sáng chiếu xuống bên trong. Cỏ mọc giữa ván sàn, cây non mọc sát tường, một số thân gỗ đã mục.

Thiết kế ít nhất ba lối đi qua khu này: xuyên nhà xưởng, vòng theo bãi gỗ và đi men sườn đồi. Đống gỗ phải có cách kê hợp lý, tạo chỗ quan sát nhưng không chặn toàn bộ tuyến di chuyển.

Có thể bố trí cáo trú dưới nền kho cũ. Dấu vết dẫn tới ổ gồm lông mắc trên khe ván, dấu chân nhỏ và lối cỏ thấp chạy men chân tường.

**10. Khu 7 — Thung lũng đá và hệ thống suối**

Đây là vùng chuyển từ rừng sang núi. Địa hình nhiều bậc, có vách đá và các khe nhìn dài.

Một dòng suối bắt nguồn từ phía Bắc, chảy qua thung lũng rồi đổ vào hồ trung tâm. Suối có:

- Đoạn hẹp chảy giữa đá.
- Bãi sỏi rộng.
- Vũng nước yên.
- Một thác cao khoảng 45–60 studs.
- Một đoạn cầu gỗ vượt dòng.
- Một chỗ nước cạn có thể đi bộ qua.

Đường mòn không chạy song song với suối suốt chiều dài. Có đoạn lên sườn cao, có đoạn xuống sát nước và có đoạn bị đá che khuất.

Tạo **“Khe Đá Chẻ”** bằng hai vách đá cao, giữa có một lối đi khoảng 15–20 studs. Khi ra khỏi khe, người chơi nhìn thấy thác nước và sườn núi phía Bắc, tạo khoảnh khắc mở cảnh.

Bổ sung một hốc đá quan sát bãi uống nước phía dưới. Hốc có hai đường ra để tránh trở thành chỗ người chơi bị dồn vào góc.

**11. Khu 8 — Dãy núi phía Bắc và hang gấu**

Đây là khu vực khó tiếp cận nhất, có độ cao khoảng 350–650 studs so với vùng thấp.

Tầng chân núi có thông dày. Lên cao, cây thấp và thưa dần; gần đỉnh chủ yếu là đá, cỏ ngắn và cây bụi chịu lạnh. Có thể thêm ít sương giá ở nơi khuất nắng nếu phù hợp mỹ thuật.

Đặt một đỉnh núi đặc trưng có hình chóp lệch và một mảng đá sáng màu. Người chơi nhìn thấy đỉnh này từ trạm kiểm lâm, hồ và đồng cỏ.

Hang gấu nằm ở sườn núi, gần nguồn nước nhưng tránh sát tuyến đi bộ chính.

Cấu trúc hang:

- Sân đá trước cửa khoảng 45 × 35 studs.
- Cửa hang khoảng 18 × 16 studs.
- Đoạn vào dài khoảng 25 studs, hơi cong.
- Khoang chính khoảng 45 × 35 studs, trần cao khoảng 20 studs.
- Nền có đất, lá khô và đá nhỏ.
- Một khe sáng trên cao giúp đọc được hình khối bên trong.
- Một ngách phụ đủ rộng để tạo tình huống di chuyển.

Có ba tuyến tiếp cận:

1. **Tuyến chính:** đi theo đường sườn núi, dễ nhận ra nhưng dễ bị phát hiện.
2. **Tuyến vòng:** đi qua rừng thấp phía Tây, dài hơn và có nhiều vật che.
3. **Tuyến trên cao:** đi qua gờ đá để quan sát sân hang; cần điểm lên xuống rõ ràng.

Trước khi đến hang, người chơi phải gặp lần lượt các dấu hiệu: thân cây bị cào, bụi cây bị ép, dấu chân lớn ở nền đất mềm và một vị trí nghỉ gần suối.

**12. Hệ thống đường đi và nhịp khám phá**

Tạo một tuyến vòng chính nối:

**Trạm kiểm lâm → đồng cỏ → hồ → khu khai thác gỗ → thung lũng đá → đầm lầy → trạm kiểm lâm.**

Từ tuyến vòng tách ra các đường vào rừng thông và dãy núi.

Quy mô đường:

- Đường vận chuyển cũ: rộng khoảng 18–24 studs.
- Đường mòn chính: rộng khoảng 10–14 studs.
- Đường săn phụ: rộng khoảng 5–8 studs.
- Lối động vật: rộng khoảng 2–4 studs, thể hiện bằng cỏ thấp và đất bị giẫm.

Không để đường chạy thẳng quá dài. Dùng khúc cua, gò đất, cây lớn và vách đá để chia tầm nhìn.

Cứ khoảng 250–400 studs trên tuyến khám phá nên có một thay đổi đáng chú ý: bãi đất mở, cây cổ thụ, cầu nhỏ, dấu vết, điểm nhìn, công trình hoặc nguồn nước. Giữa những điểm này cần có khoảng yên tĩnh để map giữ được cảm giác hoang dã.

Các khu lớn có ít nhất hai lối tiếp cận. Lối tắt cần tạo được lợi ích rõ ràng sau khi người chơi khám phá.

**13. Nguyên tắc bố trí động vật và ổ**

Không rải động vật ngẫu nhiên khắp bản đồ. Mỗi loài có vùng hoạt động nối giữa ba nhu cầu: **ăn, uống và nghỉ**.

- Hươu: đồng cỏ, bìa rừng và bờ hồ.
- Thỏ: gò khô, bụi thấp và rừng thưa.
- Lợn rừng: đất ẩm, bụi dày và rìa đầm.
- Cáo: rừng thưa và khu công trình bỏ hoang.
- Sói: rừng thông, sườn đá và đường di chuyển của hươu.
- Gấu: chân núi, suối và vùng có bụi quả.

Mỗi ổ hoặc điểm nghỉ cần có **vị trí hợp lý, dấu vết dẫn tới, khoảng quan sát và đường rút**. Dấu vết phải phản ứng với bề mặt: rõ ở bùn, khó thấy trên đá, thể hiện qua cỏ bị ép ở đồng cỏ.

Không để động vật xuất hiện ngay trước mắt người chơi. Vị trí xuất hiện cần được che bởi địa hình, cây cối hoặc khoảng cách phù hợp.

**14. Ánh sáng, âm thanh và hiệu ứng môi trường**

Thiết kế ánh sáng để giữ được hình khối và khả năng đọc đường đi:

- Sáng sớm có sương thấp ở hồ và thung lũng.
- Rừng thông tối hơn đồng cỏ nhưng vẫn thấy được nền đường.
- Đầm lầy có sương dày hơn ở các lạch nước.
- Núi xa nhạt và xanh hơn nhờ phối cảnh khí quyển.
- Ban đêm dùng ánh trăng nhẹ và các điểm sáng tại trạm, lán hoặc tháp.

Âm thanh thay đổi theo khu vực: chim ở đồng cỏ, gió qua tán thông, côn trùng ở đầm, nước chảy gần suối, tiếng gỗ cũ trong nhà xưởng. Âm thanh của động vật cần giúp người chơi nhận biết phương hướng.

Hiệu ứng lá rơi, bụi phấn, côn trùng và sương chỉ xuất hiện tại nơi phù hợp, với mật độ tiết chế.

**15. Ranh giới map và yêu cầu dựng trong Roblox**

Che ranh giới bằng núi, vách đá, rừng dày và khe vực. Bên ngoài vùng chơi có thể đặt các lớp núi nền đơn giản để tạo cảm giác thế giới tiếp tục kéo dài.

Dùng Terrain cho khối địa hình lớn, nền đất và nước. Dùng bộ module cho nhà gỗ, cầu, hàng rào và công trình bỏ hoang. Chuẩn bị nhiều biến thể cây, đá và bụi để hạn chế cảm giác lặp.

Các yêu cầu khi dựng:

- Kiểm tra kích thước bằng nhân vật Roblox ngay từ giai đoạn blockout.
- Giữ khoảng trống di chuyển dưới tán cây.
- Dùng va chạm đơn giản cho cây và đá trang trí.
- Chỉ thêm chi tiết dày ở vùng người chơi có thể tiếp cận.
- Thiết kế nội thất cho những công trình có thể bước vào.
- Tổ chức map theo từng vùng để thuận tiện quản lý và tối ưu tải.
- Kiểm tra đường đi, tầm nhìn và khả năng di chuyển của động vật trước khi hoàn thiện trang trí.

**16. Yêu cầu đầu ra**

Hãy trình bày bản thiết kế đủ rõ để một nhóm dựng map có thể bắt tay thực hiện, gồm:

1. Sơ đồ nhìn từ trên xuống có hướng Bắc, tọa độ, vùng địa hình và tuyến đường.
2. Bản mô tả chi tiết từng khu vực và vùng chuyển tiếp.
3. Danh sách cây, đá, công trình, đồ trang trí và biến thể cần dựng.
4. Vị trí các ổ thú, dấu vết và đường tiếp cận.
5. Bảng độ cao chính, cầu, thác và điểm vượt nước.
6. Một hành trình mẫu từ trạm kiểm lâm tới hang gấu, mô tả những gì người chơi thấy trên đường.
7. Thứ tự thực hiện: **blockout → địa hình → đường và nước → công trình → cây lớn → vùng động vật → chi tiết → ánh sáng → tối ưu**.

Ưu tiên hoàn thiện hình dáng địa hình, tuyến di chuyển và các điểm nhận diện trước. Mọi đồ vật được thêm vào cần phục vụ ít nhất một mục đích: tạo cảnh đẹp, dẫn đường, kể chuyện, che tầm nhìn, hỗ trợ theo dấu hoặc tạo tình huống chơi.

**Kết quả cần là một thung lũng săn bắn có bản sắc riêng: đứng ở từng khu vực đều cảm nhận được sự khác biệt, đi sâu hơn luôn có điều để khám phá, và toàn bộ diện tích 4.000 × 4.500 studs tạo thành một thế giới liền mạch.**
