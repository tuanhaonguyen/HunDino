# Kho cá thể bắt sống — bước đầu P1-F

<!-- TIEN_DO_20261027_BEGIN -->
> **Trạng thái đối chiếu 27/10/2026, 09:48 UTC+7:** local chính `HunDino_MerchantWeapons_20261026.rbxl` **4.495.025 byte**, SHA256 `8626bc714aa7a0da39493ba1bbcc676a142038b2f8a2c06e602fe01d522229bf`; inspector **129.779 kiểm / 164 source**, đạt. Cloud có bằng chứng mới nhất **v14**, nguồn **4.481.440 byte**; sửa bố cục ống mới chỉ local, **chưa Publish**.
>
> Đã nối lưu tài khoản và 5 ống/base; sửa đường đi ống đạt local 27/10. Chưa nghiệm thu toàn vòng cá thể/ô trưng bày qua phiên cloud mới.
>
> [Báo cáo tiến độ toàn dự án và hôm nay](BAO_CAO_TIEN_DO_2026-10-27.md). Ghi chú này cập nhật trạng thái; số liệu/hash của từng mốc cũ bên dưới giữ nguyên theo phạm vi lúc kiểm.
<!-- TIEN_DO_20261027_END -->

**Cập nhật lớp lưu 20/10/2026:** v2.4 đã nối dữ liệu tiến trình vào hồ sơ tài khoản; xem [PERSISTENCE.md](PERSISTENCE.md) và thiết kế mục 39. Kiểm logic/Studio test đã có; nghiệm thu cloud qua thoát/vào còn chờ game xuất bản. Các câu chỉ giữ trong phiên và số liệu dưới đây thuộc mốc trước lớp lưu.

**Đồng bộ tài liệu: 20/10/2026 — đối chiếu bản v2.4 đã lưu ngày 19/10/2026.**

Đây là trạng thái P1-F mới nhất dùng cho đợt đồng bộ: **đã có kho cá thể trong phiên, chưa có ống trưng bày hoặc lưu tài khoản**. Bằng chứng hiện có gồm [Play](assets/hunting/specimen-collection-play.json) và [đối chiếu bản lưu](assets/hunting/specimen-collection-saved.json): 139.120 kiểm tra, 118 script biên dịch, file v2.4 **4.220.334 byte**. Đợt 20/10 chỉ đối chiếu tài liệu/source/báo cáo, không chạy lại gameplay hoặc coi dữ liệu xem mẫu là lần bắt mới.

Theo [thiết kế tổng](THIET_KE_GAME.md), phần tiếp theo còn một ống, lớp lưu tài khoản và hồi quy P1-G; tab Chế tạo trong Inventory tiếp tục chờ yêu cầu.

Bản đang phát triển: **HunDino_DarkJungle_v2_4.rbxl**, ngày 19/10/2026. Mở **I → KHỦNG LONG** trong Inventory để xem cá thể đã bắt. Đây là kho trong bộ nhớ máy chủ, **chưa lưu tài khoản**; quay về sảnh và hồi sinh trong cùng phiên giữ bộ sưu tập, sang máy chủ/phiên Play mới thì bắt đầu lại.

Mỗi lần bắt sống thành công nhận **một cá thể riêng**, cùng ba lượt nguyên liệu bắt và gói thưởng hiện có. Hạ quái không tạo cá thể. Mã cá thể do máy chủ tạo, độc lập với tên loài; hai T-Rex vẫn có hai mã và số thứ tự khác nhau. Cùng một kết quả được gửi lại trả bản ghi đã nhận, không tạo con mới, quay lại nguyên liệu hoặc trừ thêm thuốc.

## Xem bộ sưu tập

- Danh sách hiện **T-Rex #001, #002…**, mã rút gọn và thời điểm bắt; con vừa nhận xếp trước. Chọn từng con để xem mã đầy đủ và thông tin riêng.
- Loài thử **T-Rex**, biến thể **Thường** (`Normal`), nguyên tố **Không** (`None`), kích thước **100%** (`SizeScale=1`). Chưa bốc biến thể, nguyên tố hoặc kích thước ngẫu nhiên.
- Thời điểm bắt lấy từ máy chủ và hiển thị **UTC+7**. Số thứ tự tăng theo lần ghi cá thể thành công trong hồ sơ, không thay bằng thứ tự đang chọn.
- Khung 3D dùng bản xem trước tĩnh của con mẫu, có thể giữ chuột trái rồi kéo để xoay góc nhìn. Bản này chỉ trình bày hình dáng, không có AI, sát thương, vùng đánh hoặc thao tác thả quái.
- Khi chưa bắt được con nào, màn hình hướng dẫn bắt sống; tổng số hiện **0 / 100**. Danh sách lấy từ snapshot có phiên bản cùng dữ liệu Vật phẩm và bỏ qua bản cũ.

**Giới hạn thử 100 cá thể.** Khi đầy, vẫn nhận lượt săn thường và tiêu diệt mục tiêu được. Máy chủ kiểm tra chỗ trống khi bắt đầu và hoàn tất thao tác cho uống, trước khi trừ thuốc hoặc khóa kết quả bắt. Không tự xóa con cũ, không biến hạ quái thành cá thể sở hữu.

Tab **CHẾ TẠO** trong Inventory tiếp tục là khung **Chưa triển khai** theo yêu cầu người dùng. Bàn chế/nâng thử P1-E tại base vẫn giữ như trước; giai đoạn này không thêm công thức hoặc giao dịch chế tạo mới.

## Dữ liệu và giao dịch

Hồ sơ bộ nhớ chuyển từ `DataVersion=1` sang **2**. Bản cũ hợp lệ giữ nguyên xu, nguyên liệu, vật tư, cấp búa, lượt đang chạy và dấu giao dịch; chỉ thêm `OwnedSpecimens={}` và `SpecimenSerial=0`, không cấp lại 80 xu đầu. Hồ sơ sai định dạng bị từ chối, không âm thầm tạo kho rỗng thay tiến trình cũ.

`OwnedSpecimens[Id]` lưu `Id`, `Serial`, `SpeciesId`, `Name`, `Variant`, `Element`, `SizeScale`, `CapturedAt`, `SourceRunId`, `SourceMonsterId`. Máy chủ tạo metadata cho đúng lượt/quái; bản sao gửi cho giao diện không tham chiếu trực tiếp kho gốc. Không có thao tác client tự nhập mã để nhận cá thể.

Ghi một cá thể, tăng số thứ tự, ba kết quả nguyên liệu, gói xương/xu, vật tư còn lại và dấu hoàn tất cùng nằm trong một cập nhật hồ sơ không nhường luồng. Thiếu chỗ/metadata sai/nguồn trùng hoặc vượt trần phần thưởng thì không ghi một phần. Mã nguồn trong cá thể vẫn chặn cấp lại sau khi danh sách giao dịch gần đây được dọn.

Nguồn chính: `src/hunting/HuntEconomyRules.luau`, `HuntEconomyService.luau`, `HuntQuestService.luau`, `HuntCaptureController.luau`, `SpecimenPreviewModel.luau`, `HuntQuest.client.luau` và `src/dark-jungle/EquipmentInventory.luau`. Bản xem trước tạo khi chạy tại `ReplicatedStorage.SpecimenVisuals`, không lưu thêm hình học vào map trong Edit.

## Kiểm chứng và giới hạn

- Luật kinh tế/kho cá thể: **2.134 kiểm tra / 31 nhóm đạt**, gồm hai cá thể khác mã, replay sau đóng lượt, 100 lần bắt, kho đầy không mất vật tư nhưng vẫn hạ được, chuyển hồ sơ v1, metadata sai và bản sao dữ liệu không sửa kho gốc. Bộ 767 kiểm tra kinh tế cũ được giữ.
- Controller bẫy/bắt: **195 kiểm tra / 27 tình huống đạt**. Trường hợp nước Terrain thật được bỏ qua vì không tìm thấy mẫu nền hồ phù hợp; chưa coi mọi bờ hồ đã được kiểm chứng.
- Preview native đạt **4.858 kiểm tra** trên **255 Part/21 MeshPart**, giữ hình học/trạng thái con mẫu gốc. Giữ metadata nguồn nhập `RBX_` hợp lệ được Roblox bảo vệ, loại bỏ AI/vùng đánh và trạng thái gameplay khỏi bản xem trước.
- Đã bắt sống thực trong Play: bắt đầu **80 xu**, mua bẫy thô/thuốc, nhặt quặng và chế bẫy tại bàn P1-E; các đòn búa hợp lệ gây tổng **1.080 sát thương**, để quái còn **120 HP**. Giữ B/G hoàn tất → `Harvest/Captured`, đúng **1 cá thể**, **100 xu, 1 xương, 3 răng, 1 vảy**. Không đặt HP quái để nhận kết quả.
- Chờ tự nhiên hết **120 giây** về sảnh vẫn đúng một cá thể, GUID `275d20fb-baee-4a26-9bd2-d58f3480ba73`; chết/hồi sinh vẫn cùng mã. Lượt kiểm tra có hỗ trợ đặt vị trí nhân vật và tạm tăng HP người lên 1.000 để lặp tình huống, đã trả về 100; không phải nghiệm thu cân bằng chiến đấu.
- Xoay xem trước hoạt động, thả chuột khôi phục camera `Custom`; chuyển sang Chế tạo vẫn hiện **Chưa triển khai** và dọn mô hình xem trước. Phiên Play mới có **0 cá thể/80 xu**, xác nhận giới hạn bộ nhớ và chưa lưu tài khoản.
- Sau sửa căn khung, giao diện cuối được thử bằng **snapshot chỉ để xem sau khi khởi động lại**, không cấp cá thể vào hồ sơ máy chủ. Đầu/đuôi và cả tám góc hộp bao nằm trong khung ở góc ban đầu và sau kéo chuột; sau xoay tỷ lệ ngang/dọc tối đa **0,678/0,862** so với nửa khung. Đã nạp **29 tài nguyên, 0 lỗi**. Không coi dữ liệu xem mẫu này là lần bắt thực thứ hai.

Backup trước thay đổi: `backups/Hub_v24_before_specimen_collection_20261019.rbxl`; sáu source cũ được giữ tại `ServerStorage.SpecimenCollectionBackup_20261019`. Bằng chứng Play: `assets/hunting/specimen-collection-play.json`. Source cuối đã lưu native Studio vào bản v2.4, kích thước file từ **4.214.535 → 4.220.334 byte**, để ở Edit. Inspector `tools/inspect-specimen-collection-saved.luau` chỉ đọc bản lưu và ghi `assets/hunting/specimen-collection-saved.json`.

Bản lưu cuối đạt **139.120 kiểm tra đọc/đối chiếu**, **118 script** biên dịch, **23 source chuẩn** khớp, **105 source cũ không liên quan** giữ nguyên và **6 backup** khớp baseline. Đúng sáu source sản xuất được sửa và một module mới. Toàn bộ **43.775 Part/845 khớp** giữ nguyên, trong Workspace **35.064 Part/723 khớp**; map vẫn **4.000 × 4.500**, **2.400 cây, 16 đường, 9 khu**, rig **255 Part/21 MeshPart/7 Motor6D/247 weld/1 anchor**. Không lưu runtime preview, loot, GUI hoặc dữ liệu thử vào Edit; không xuất lại Place/Terrain bằng Lune.

Chưa có DataStore, ống trưng bày, chọn con vào base, bán/thả/xóa, trao đổi, biến thể/hệ ngẫu nhiên hoặc nuôi lớn. Chưa nghiệm thu nhiều client, điện thoại hoặc hiệu năng danh sách 100 con bằng thao tác người dùng. Đây là bước kho cá thể của P1-F; phần trưng bày và lưu tài khoản còn lại sẽ triển khai riêng.
