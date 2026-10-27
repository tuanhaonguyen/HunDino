# Khủng long đầu tiên — mẫu ngoại hình 15/10/2026

**Đồng bộ tài liệu: 20/10/2026 — đối chiếu bản v2.4 đã lưu ngày 19/10/2026.**

`Dinosaur01_TRex_Visual.rbxl` là file mẫu ngoại hình riêng. Con mẫu đã tích hợp vào [v2.4](HunDino_DarkJungle_v2_4.rbxl): rig **255 Part/21 MeshPart/7 Motor6D/247 weld/1 anchor**, tuần tra/nghỉ 60 giây trên H2, có combat và bắt sống. Xem [combat](DINOSAUR_COMBAT.md), [nhiệm vụ/bắt](HUNT_QUEST.md) và [kho cá thể](SPECIMEN_COLLECTION.md). Các phím F/G/R/C hoặc E thử cắn và những câu chưa AI/sát thương bên dưới thuộc phiên xem model riêng; không dùng làm điều khiển bản chung.

## Hồ sơ ngoại hình và rig riêng — 15/10/2026

## Cập nhật theo ảnh tham khảo

### Đầu gọn hơn, thử cắn và đi bộ — bản hiện hành

Đã lưu `Dinosaur01_TRex_Visual.rbxl` ngày **15/10/2026**, dung lượng **925.165 byte**. Bản trước chuyển động: `backups/Dinosaur01_before_walk_20261015.rbxl`; bản trước chỉnh đầu: `backups/Dinosaur01_before_head_cleanup_20261015.rbxl`. Chỉ còn **một model chính** trong Workspace; các mẫu cũ giữ ở ServerStorage.

- Bỏ mảng đen phủ rộng trên trán; thay bằng dải mào hẹp có 188 lá lông vuốt về sau. Làm mượt lưới đầu/hàm, bỏ các tam giác đóng miệng cũ; thêm mắt hổ phách nhỏ và lỗ mũi. Thay răng rời bằng hai mesh gồm 21 răng trên và 19 răng dưới, đặt gốc theo bề mặt thật; chỉnh tư thế khép giảm 8° để răng dưới nằm trong miệng.
- **Cách thử mới: bấm Play, dùng nút trên màn hình hoặc F để cắn, G để đi/dừng, R về chỗ cũ, C đổi giữa góc quan sát và camera nhân vật.** Các nút thử chạy trong Studio. Phím E cũ đã được thay bằng F và bảng nút, tránh phụ thuộc vị trí người chơi so với đầu cao của model.
- Bật lại JawRuntime trên model đã chỉnh đầu. Khi cắn, cổ hơi cúi cùng nhịp khép hàm. Đã kiểm tra cả phím F và bấm chuột, kể cả khi đang đi.
- Rig đi bộ gồm hai khớp hông, hai vai, cổ và đuôi, cộng khớp hàm trước đó. Chân bước luân phiên, nhấc chân trong pha bước, thân nhún nhẹ; tay và đuôi đung đưa. Đi vòng chậm ở tốc độ 6 studs/giây để xem thử. Đây là bước đi cơ bản cho mesh mỗi chân còn liền khối, chưa phải hệ chuyển động có khớp gối/cổ chân hoặc AI tìm đường.
- Vảy, mắt, lông và răng được nối vào bộ phận tương ứng để đi theo rig. Bản cuối có **255 BasePart, 21 MeshPart, tám SurfaceAppearance, bảy Motor6D, 247 WeldConstraint**; chỉ thân gốc Anchored. 255 phần đã được kiểm tra nối chung, không có bộ phận rơi rời.
- Kiểm tra Play: model đi hơn 20,87 studs trong lượt thử, hai chân đạt biên độ gần 11° và bước trái/phải đối pha ở cả 24 mẫu. Chân thấp nhất khoảng -0,046 stud, nhấc cao nhất 0,81 stud; sau dừng không trôi; R phục hồi vị trí với sai số 0. Khớp hàm khi vừa đi vừa cắn sai số dưới 0,00001 stud.

Nguồn mới: `src/dinosaur/MotionController.luau`, `MotionRuntime.server.luau`, `PreviewBridge.server.luau`, `PreviewControls.client.luau`; công cụ rig: `tools/rig-dinosaur-walk.luau`. AI sau này có thể gọi `model.WalkRequest:Fire(true/false)`, `model.BiteRequest:Fire()` và `model.ResetMotionRequest:Fire()` trên server. Chưa thêm sát thương.

Nguồn chỉnh đầu: `tools/clean-dinosaur-head.py`, `assets/dinosaur01/head-cleanup-source.json`, `TRex_Head_Cleanup.glb`, `TRex_Head_LowerTeeth.glb`. Ảnh Play: `assets/dinosaur01/preview-walk-controls.png`. Thông số cuối: `assets/dinosaur01/final-model-manifest.json`; `tools/inspect-dinosaur-preview.luau` đọc kiểm tra cấu trúc đã lưu trong file.

### Khớp hàm và chuyển động cắn — bản đã lưu

Đã lưu `Dinosaur01_TRex_Visual.rbxl` lúc **17:04 ngày 15/10/2026**, dung lượng **745.766 byte**. Bản sao trước lượt này: `backups/Dinosaur01_before_jaw_rig_20261015.rbxl`; bản model trước khi rig còn trong `ServerStorage.DinosaurVisualBackups.TRex_BeforeJawRig_20261015`.

- Gắn `head.head_geom.JawMotor` (Motor6D) tại khớp hàm thật. Hàm dưới và 15 răng dưới bỏ Anchored, nối răng bằng WeldConstraint; đầu và thân vẫn cố định. Tư thế khép được chỉnh thêm 12 độ so với bản trước.
- Chuyển động: mở xuống tối đa 30° trong 0,32 giây, giữ 0,12 giây rồi khép nhanh trong 0,14 giây. Chặn cắn chồng, có cooldown và có thể hủy để trở về tư thế khép.
- **Thử trong Studio: Play → nhấn E** gần khủng long. Nút "Thử cắn" chỉ là xem chuyển động. Tắt bằng attribute `BitePreviewEnabled=false`.
- Nguồn điều khiển: `src/dinosaur/JawController.luau` và `JawRuntime.server.luau`, đã được chèn cùng model. AI sau này gọi `model.BiteRequest:Fire()` trên server; hoặc lấy controller bằng `require(model.JawController).new(model)` rồi gọi `:Bite()` / `:SetOpenAngle(degrees)` / `:Cancel()`.
- Kiểm tra trong Play trên server và client: phím E đi qua đủ `Opening → Holding → Closing → Idle`; hàm mở đủ 30°, trở về đúng vị trí; sai số khớp <0,00001 stud và sai số răng <0,00001 stud. Đã thử chặn cắn chồng, cooldown, giới hạn góc và hủy giữa chừng.
- Sửa lỗi ba lớp nền lông CSG có MeshContent rỗng khi chạy Play: dựng lại thành mesh cố định, nhập từ `assets/dinosaur01/TRex_Undercoat_Persistent.glb`. Đã kiểm tra phía client không còn các khối đen thay cho hình học.
- Model hiện có 283 BasePart, 13 MeshPart, tám SurfaceAppearance, một Motor6D, 15 WeldConstraint, một ModuleScript và một Script. Chỉ 16 phần của hàm dưới được bỏ Anchored. Chưa thêm di chuyển, sát thương hoặc AI tấn công.

Ảnh kiểm tra hàm mở trong Play: `assets/dinosaur01/preview-jaw-open.png`. Công cụ dựng lại lớp nền lông: `tools/export-dinosaur-undercoat.py`; công cụ gắn rig từ bản model chưa có motor: `tools/rig-dinosaur-jaw.luau`.

### Ảnh toàn thân — bản đã lưu

File hiện hành của model riêng trong Studio đã được người dùng đổi tên thành **Dinosaur01_TRex_Visual.rbxl**, nằm cùng thư mục tài liệu này. Đã lưu bằng Studio và xác nhận file trên đĩa cập nhật lúc **16:45 ngày 15/10/2026**, dung lượng 714.258 byte. Không ghi thay đổi vào map DarkJungle. Bản file trước lượt sửa được giữ tại `backups/Dinosaur01_before_fullbody_20261015.rbxl`.

- Giữ ảnh toàn thân mới tại `assets/dinosaur01/reference-fullbody.png` làm tham khảo chính. Kết quả vẫn là bản thử, chưa tái tạo đầy đủ sculpt và chi tiết da của ảnh.
- Đã chỉnh lưới thật bằng Blender: thân đầy hơn, cổ thấp hơn; tách hàm dưới và khép bớt 10 độ. Giữ UV, hàn các đỉnh trùng và làm mượt normals, nhập trở lại Studio bằng GLB.
- Hàm dưới tại `Workspace.Dinosaur01_TRex_Visual.head.LowerJaw` có pivot ở khớp hàm, hai Attachment JawHinge và răng dưới đi cùng. Đã thử xoay 5 độ rồi trả về tư thế ban đầu, sai số phục hồi dưới 0,001 stud. Đây là chuẩn bị cấu trúc model, chưa có animation hoặc logic cắn.
- Thay 462 gai rời bằng **914 lá lông** trong hai MeshPart, kèm ba lớp nền đen bám sát đầu/lưng/đuôi bằng CSG để lớp phủ liền hơn. Bổ sung lại **234 vảy sẫm** ở vai, đùi và cẳng chân, lấy vị trí trên tam giác thật của mesh.
- Model chính gồm **283 BasePart, 13 MeshPart, tám SurfaceAppearance**, không có script; tất cả đứng yên và không va chạm. Bản cũ và các bản thử được giữ trong `ServerStorage.DinosaurVisualBackups`.

Nguồn chỉnh lưới: `assets/dinosaur01/head-source.json`, `body-source.json`, `tail-surface.json`; công cụ Blender: `tools/refine-dinosaur-reference.py`; file nhập cuối: `assets/dinosaur01/TRex_Reference_FinalSmooth.glb`; thông số và asset ID: `assets/dinosaur01/final-model-manifest.json`.

Các trạng thái chưa lưu ở những mốc bên dưới là lịch sử; mốc hiện tại ở trên đã được lưu vào file riêng.

### Lượt tăng độ chân thực

Trong phiên **HunDino.rbxl**, đã cập nhật trực tiếp `Workspace.Dinosaur01_TRex_Visual`:

- Tạo lại texture đỏ nâu trầm; thêm SurfaceAppearance cho cả bảy MeshPart với normal/roughness/metalness từ vật liệu `TRexSkinRealism01`.
- Thân trên nghiêng về trước 12 độ, đầu dày hơn, tay giảm 24%; giữ phần chân và vị trí đứng của bản cũ.
- Bổ sung 36 răng hình nón bằng solid geometry riêng, đã kiểm tra và bỏ các răng nằm quá xa về phía khớp hàm.
- Thay lông gai cũ bằng 462 sợi hình nón mảnh; bổ sung 120 vảy nổi thấp ở vai/đùi.
- Đã kiểm tra cận cảnh và toàn thân. Tổng 625 BasePart, tất cả Anchored, không va chạm; bảy SurfaceAppearance; không có script hoặc di chuyển/tấn công.
- Bản trước nằm tại `ServerStorage.DinosaurVisualBackups.TRex_BeforeRealism_20261015` và `TRex_Previous_VisualBeforeRealism`.

Texture generation tag: `RBXAI-TexturedMesh-TextureGen-2d0c7caf-e687-4dfd-8f26-7e0d4d022a90`. Normal map: `79853329843822`; roughness: `80590620486943`; metalness: `94833075128867`. Mẫu răng solid được giữ tại `ServerStorage.DinosaurVisualBackups.TRex_ToothPrototype`.

Đây vẫn là bản thử cải thiện từ mesh tạo tự động, chưa đạt mức sculpt của mẫu Blender. Chưa xác nhận lưu phiên Studio vào file .rbxl trên đĩa; các sửa tỷ lệ, răng, vảy và lông cần được lưu cùng place.

### Mốc trước lượt tăng độ chân thực

Đích hiện hành là phiên Studio **HunDino.rbxl**, không phải DarkJungle. Model tại `Workspace.Dinosaur01_TRex_Visual` đã thay bằng bản thử đỏ nâu theo ảnh người dùng. Mesh nguồn mới: **104678914367015**, generation **c98835f2-e823-4300-8d58-6ef48eeed956**. Giữ độ cao khoảng 41 studs theo kích thước người dùng đã chỉnh; đặt cạnh Spawn.

Đã kéo dài đuôi, tăng độ dày đầu và thêm 361 lông gai đen dọc lưng. Model gồm 7 MeshPart cùng lông gai; tất cả đứng yên, không có script. Bản xanh và lượt thử đỏ trước được giữ tại `ServerStorage.DinosaurVisualBackups`.

Đã xem các góc trong Studio. Kết quả là bản thử gần màu và một số đặc điểm của ảnh, **chưa đạt độ chân thực, giải phẫu và chi tiết da của mẫu Blender**. Chưa rig, di chuyển hoặc tấn công. Chưa xác nhận lưu phiên HunDino.rbxl ra đĩa; asset nguồn không bao gồm các sửa đuôi/đầu/lông gai thực hiện trong Studio.

## Mốc mẫu xanh ban đầu

Yêu cầu: hoàn thiện model 3D trước, di chuyển làm sau, tấn công làm cuối cùng.

Đã tạo mẫu T-Rex trong Studio HunDino_DarkJungle_v2_3.rbxl, tại Workspace.Dinosaur01_TRex_Visual. T-Rex là lựa chọn mẫu để xem, chưa phải loài hoặc ngoại hình cuối do người dùng chốt.

- Asset model: 94835262681501 (đã được công cụ tạo mesh lưu lên Roblox).
- Generation ID: 23519cd3-3cbf-487d-bf01-4931c18a770b.
- Bảy MeshPart: thân, đầu, hai chân, hai tay, đuôi; có texture xanh, bụng sáng, sọc lưng, mắt và răng.
- Kích thước thực khoảng 9 × 11.66 × 13.42 studs. Tọa độ tâm khoảng (513.54, 225.83, -27.93), chân ở Y=220: khu xem tạm trên cao, chưa đặt vào khu săn.
- Tất cả bộ phận Anchored=true, CanCollide=false. Không có script trong model, chưa rig hoặc có animation/AI.
- Đã kiểm tra ảnh góc ba phần tư trong Studio và xác nhận đủ bảy MeshPart.

Model đang có trong phiên Edit của Studio; chưa xác nhận lưu thay đổi vào file .rbxl. Cần lưu Studio để giữ vị trí và tên model trong place. Asset ID ở trên giữ bản mesh đã tạo để chèn lại nếu cần.

Bước tiếp theo: chỉnh ngoại hình theo góp ý, sau đó mới rig/di chuyển, cuối cùng mới xây dựng tấn công.
