# Lưu tiến trình tài khoản HunDino — 20/10/2026

<!-- TIEN_DO_20261027_BEGIN -->
> **Trạng thái đối chiếu 27/10/2026, 09:48 UTC+7:** local chính `HunDino_MerchantWeapons_20261026.rbxl` **4.495.025 byte**, SHA256 `8626bc714aa7a0da39493ba1bbcc676a142038b2f8a2c06e602fe01d522229bf`; inspector **129.779 kiểm / 164 source**, đạt. Cloud có bằng chứng mới nhất **v14**, nguồn **4.481.440 byte**; sửa bố cục ống mới chỉ local, **chưa Publish**.
>
> V14 sửa bộ đọc biên nhận HelloHunDino; Player xác nhận ProfileReady/Saved/DataStore, 210 xu và độ nhạy 75%, rồi rejoin thấy trang bị. Chưa nghiệm thu mọi giao dịch/cá thể/ống qua server mới.
>
> [Báo cáo tiến độ toàn dự án và hôm nay](BAO_CAO_TIEN_DO_2026-10-27.md). Ghi chú này cập nhật trạng thái; số liệu/hash của từng mốc cũ bên dưới giữ nguyên theo phạm vi lúc kiểm.
<!-- TIEN_DO_20261027_END -->

Hệ thống này bổ sung lưu tiến trình cho bản **HunDino_DarkJungle_v2_4.rbxl**: lựa chọn vũ khí/giáp của Người và Pet, vật phẩm đã mua/chế tạo, nguyên liệu, xu, cấp búa, cá thể bắt sống, cài đặt và một số thống kê. Khi vào lại, server tải hồ sơ trước khi khởi tạo trang bị. Lưu tài khoản là một hệ thống riêng với thao tác **Ctrl+S lưu file Roblox Place**: file `.rbxl` chứa map và mã nguồn; tiến trình từng tài khoản nằm trong kho dữ liệu của game đã xuất bản.

**Mức kiểm chứng hiện có:** các bộ kiểm tra dữ liệu thuần đã đạt; luồng tích hợp đã thử trong Studio bằng **TestMemory được bật rõ ràng riêng trong Play**. Chưa kiểm chứng thoát rồi vào lại qua DataStore Roblox thật. Việc lưu native và đối chiếu bản `.rbxl` cuối là bước kiểm tra riêng, chưa lấy kết quả của mốc UI trước để chứng nhận bản persistence này.

## 1. Người chơi dùng như thế nào

1. Vào game và đợi màn **ĐANG TẢI HỒ SƠ** biến mất. Server chỉ cho dùng các chức năng gameplay sau khi hồ sơ sẵn sàng; lỗi tải không mở một kho mới thay cho dữ liệu cũ.
2. Đổi vũ khí, mặc/tháo từng món giáp của Người hoặc Pet như trước. Lựa chọn mới được đánh dấu chờ lưu; cài đặt trong biểu tượng Cài đặt cũng đi qua server và cùng hồ sơ tài khoản.
3. Mua bẫy/thuốc tại quầy, chế bẫy/nâng búa ở bàn base, nhặt nguyên liệu hoặc hoàn thành săn. Các thay đổi kinh tế được ghi qua lớp lưu trước khi thông báo thành công và công bố số mới.
4. Xem dòng trạng thái lưu nhỏ phía trên giữa màn hình. Có thể bấm **LƯU**; server giới hạn thao tác thủ công cách nhau ít nhất 5 giây. Nút này không thay thế điều kiện mua/chế/nâng và không tạo phần thưởng.
5. Khi rời game, server cố gắng đóng lượt săn, trả vật tư chưa dùng và lưu lần cuối. Đợt tự lưu vẫn hoạt động trong khi chơi để giảm phụ thuộc vào riêng thao tác thoát.

Màn hình hiện **“THỬ: chỉ giữ trong phiên · không lưu tài khoản”** nghĩa là đang dùng TestMemory. Lưu rồi tải lại trong cùng phiên thử có thể giữ dữ liệu, nhưng Stop Play/máy chủ kết thúc sẽ mất bộ nhớ thử đó. Không dùng kết quả này để kết luận tài khoản đã được lưu lên Roblox.

## 2. Những gì được lưu

| Nhóm | Trường và hành vi hiện có |
| --- | --- |
| Vũ khí Người | `Loadout.WeaponId`: Búa tạ, Kiếm/khiên, Katana, Thương cán dài, Song dao, Cung hoặc Rìu đại hai lưỡi theo ID hợp lệ của game |
| Vũ khí Pet | `Loadout.PetWeaponId`, độc lập với vũ khí của chủ |
| Giáp Người | `Loadout.PlayerArmor`: năm vị trí `Head`, `Chest`, `Arms`, `Waist`, `Legs`; từng ô giữ bộ đã chọn hoặc `None` khi tháo |
| Giáp Pet | `Loadout.PetArmor`: năm vị trí giống Người, độc lập với Người; giữ cả việc tháo từng ô |
| Xu | `Economy.Coins`; 80 xu chỉ là tiền khởi đầu của hồ sơ mới hợp lệ |
| Nguyên liệu | `Economy.Materials`: `Skin`, `Tooth`, `Scale`, `Bone`, `Iron` |
| Vật tư trong kho | `Economy.StoredConsumables`: `RawTrap`, `IronTrap`, `SleepPotion` |
| Chế tạo | Kết quả và phần nguyên liệu/vật tư đã tiêu của giao dịch chế bẫy được ghi cùng nhau |
| Nâng cấp đã triển khai | `Economy.HammerLevel`: búa Người cấp 1 hoặc 2; cấp 2 tăng 15% sát thương búa của Người |
| Cá thể đã bắt | `Economy.OwnedSpecimens`, `SpecimenSerial`; mỗi cá thể giữ GUID, số thứ tự, loài, tên, biến thể, nguyên tố, kích thước, thời điểm và mã nguồn lượt/quái |
| Dấu giao dịch | `Revision`, `StarterGranted`, `RunSerial`, `OperationSerial`, `OperationReceipts`, `OperationOrder`, `ClosedRuns`, cùng toàn bộ `ActiveRun` nếu còn |
| Cài đặt | `Preferences.ShowComboGuide`, `ShowDamage`, `ShowComboFX`, `AimSensitivity`; độ nhạy hiện nhận 100%, 75% hoặc 50% |
| Hồi máu Pet | `Pet.HealReadyAt`: hạn hồi chiêu được lưu bằng thời gian Unix; chuyển đổi khi nối với đồng hồ gameplay |
| Thống kê | `Statistics.HuntsCompleted`, `HuntsFailed`, `Captures`; tăng theo giao dịch `Finish` hợp lệ, cùng lần ghi kinh tế tương ứng |
| Phiên bản và thời gian | `DataVersion=1` của hồ sơ tài khoản; `CreatedAt`, `UpdatedAt` dùng Unix giây |

Các bộ giáp hiện có là `Training`, `Leather`, `Metal`, `Bone` và lựa chọn tháo `None`. Giáp tiếp tục là ngoại hình thử, chưa có chỉ số phòng thủ, chế giáp hoặc cấp nâng giáp. Bảy vũ khí và bốn bộ giáp hiện vẫn là danh mục cho chọn của bản thử; lưu loadout chưa tạo ra hệ thống kiếm/mua từng món trang bị riêng.

Chỉ búa Người hiện có cấp nâng thực tế. Lưu tài khoản không tự bổ sung nâng cấp các vũ khí khác, tăng cấp Pet hoặc công thức mới. Tab Chế tạo trong Inventory tiếp tục là khung chờ; giao dịch hiện có vẫn ở bàn base. Những hệ thống mở sau cần thêm trường và migration tương ứng, không chỉ thêm chữ lên giao diện.

Giới hạn kho cá thể hiện là **100**. Metadata thử của cá thể T-Rex tiếp tục là `Normal`/`None`/`SizeScale=1`; lưu dữ liệu không tự tạo biến thể hoặc nguyên tố ngẫu nhiên. Chưa có ống trưng bày, chọn cá thể vào base, thả/xóa/trao đổi hoặc nuôi lớn.

## 3. Những gì chỉ thuộc phiên chơi

| Dữ liệu phiên | Khi vào lại hoặc bắt đầu phiên mới |
| --- | --- |
| BaseId và chủ các base | Gán lại trong tối đa 12 base trống của server; không lưu số base như quyền sở hữu vĩnh viễn |
| Khu đang đứng, vị trí, camera | Bắt đầu tại sảnh; không đưa trở lại tọa độ cũ cạnh khủng long |
| Máu Người, thể lực, rút/cất, đỡ, chạy, combo, tụ lực, lướt | Khởi tạo trạng thái gameplay mới; không nối tiếp động tác đang chạy |
| Máu/AI/vị trí khủng long, xác và vật rơi chưa nhặt | Không khôi phục trận cũ từ tài khoản |
| Thời gian 40 phút và 120 giây thu hoạch | Không tiếp tục lượt đang dở ở máy chủ mới; xử lý vật tư theo mục 6 |
| Bẫy đã đặt, thao tác đặt bẫy/cho uống/mổ đang giữ | Không dựng lại đối tượng hoặc hoàn tất hành động chưa xong |
| Máu Pet, choáng, tìm đường, animation, mục tiêu và nhịp đánh | Vẫn là trạng thái trong phiên; hạn hồi chiêu hồi chủ được lưu riêng |
| Sát thương tập và các con số chiến đấu thời gian thực | Không biến thành thống kê tài khoản nếu chưa có trường tương ứng |
| Quyền bay admin và trạng thái bay | Không lấy từ hồ sơ người chơi để tự cấp quyền |

Hồi sinh trong cùng lượt săn vẫn giữ luật nhiệm vụ hiện có. Quy tắc “vào lại ở sảnh, đóng lượt cũ” áp dụng cho phục hồi hồ sơ qua phiên, không thay luồng hồi sinh tại trại khi server và lượt săn vẫn đang hoạt động.

## 4. Định dạng và nguồn dữ liệu chuẩn

Kho dữ liệu dùng khóa **`player_<UserId>`** trong scope **`accounts`**:

| Môi trường | Store hiện được cấu hình |
| --- | --- |
| Game chạy trên Roblox | `HunDinoProfiles_v1` |
| Studio dùng DataStore thật | `HunDinoProfiles_Studio_v1` |
| Studio QA bộ nhớ được bật rõ ràng | `TestMemory`, không ghi vào hai store trên |

Hồ sơ tài khoản có ba lớp phiên bản khác nhau, không dùng thay nhau:

```text
Envelope.FormatVersion = 1       -- định dạng lưu và khóa phiên
Envelope.Revision               -- số lần ghi ở repository
Envelope.Data.DataVersion = 1   -- định dạng tài khoản
Envelope.Data.Economy.DataVersion = 2
```

`Economy` vẫn dùng bộ luật kinh tế v2 để kiểm tra dữ liệu, migration v1 và giao dịch. Nhãn `ServerMemory` bên trong cấu trúc luật kinh tế cũ là chi tiết tương thích của schema đó; trạng thái lưu thực tế do `ProfileStorageMode` và adapter cung cấp. Không đọc riêng nhãn cũ này rồi kết luận toàn bộ tài khoản vẫn chỉ ở bộ nhớ. Snapshot gửi Inventory được gắn mode hiện hành.

`ProfileService` giữ một hồ sơ chuẩn mỗi Player. `HuntEconomyService:Profile()` lấy đúng bảng `Data.Economy` của hồ sơ đó thay vì tạo một kho độc lập khi đã nối persistence. Giao diện chỉ nhận bản trình bày và gửi ý định; không được gửi số xu, cấp nâng, vật phẩm hoặc cả bảng hồ sơ để server tin dùng.

Không lưu bản `Economy.snapshot()` làm tài khoản: snapshot cố ý bỏ một phần sổ giao dịch. Lớp lưu giữ **toàn bộ dữ liệu kinh tế chuẩn**, gồm dấu nhận và `ActiveRun.Claims`, để lần tải sau biết nguồn nào đã nhận rồi.

Các khóa số của `OperationReceipts` được encode thành khóa chuỗi thập phân trước khi lưu và decode/kiểm tra khi đọc. Cách này giữ được sổ đã dọn còn khóa số thưa; khóa trùng, giả dạng hoặc dữ liệu không hợp lệ bị từ chối.

## 5. Luồng tải và lưu

### Khi vào game

Server lấy khóa tài khoản qua `UpdateAsync`, kiểm tra envelope, phiên bản và schema. Chỉ khi bản ghi thật sự chưa tồn tại mới dùng hồ sơ mặc định; tải lỗi, dữ liệu hỏng hoặc phiên bản mới hơn mã hiện tại không được coi là “người chơi mới”.

Nếu còn lượt săn bị ngắt, server phục hồi vật tư theo mục 6 và phải lưu thành công bản phục hồi trước khi mở gameplay. Sau đó áp dụng vũ khí, mười ô giáp, cài đặt và hạn hồi chiêu Pet; mới tạo nhân vật/trang bị và công bố `ProfileReady=true`.

Mặc định mới là Búa cho Người/Pet, giáp Thợ săn cho Người, giáp Kim loại cho Pet, ba lựa chọn hiển thị bật, độ nhạy 100%, 80 xu và kho nguyên liệu/vật tư/cá thể rỗng. Đây là khởi tạo lần đầu, không phải lệnh reset mỗi lần đăng nhập.

### Mua, chế, nâng, nhặt và nhận thưởng

Server kiểm tra vị trí, trạng thái và request như luật cũ, rồi tạo bản ứng viên của hồ sơ. Giao dịch sửa bản ứng viên: trừ chi phí, cộng vật phẩm/thưởng, ghi dấu giao dịch và thống kê trong cùng dữ liệu. Lớp lưu ghi bản đó trước khi đưa kết quả vào kho chuẩn và báo thành công.

Ví dụ chế bẫy có ba thay đổi **-1 bẫy thô, -1 sắt, +1 bẫy sắt** trong cùng bản ghi. Nâng búa có **-2 xương, -2 sắt, cấp búa = 2**. Bắt sống ghi cá thể, vật tư còn lại, nguyên liệu, xu/xương, dấu nhận và số đếm cùng một giao dịch. Không lưu riêng từng vế rồi báo hoàn thành giữa chừng.

Nếu ghi lỗi, bản ứng viên giữ ở trạng thái chờ. Kho đã công bố không được tăng/giảm sớm; giao dịch mới bị chặn trong khi chưa giải quyết bản chờ. Thử lại dùng cùng dữ liệu và mã commit, tránh trừ tiền lần hai hoặc quay lại phần thưởng. Nếu Roblox đã ghi nhưng phản hồi bị mất, sổ commit cho phép nhận biết lần ghi đó khi retry.

### Trang bị, cài đặt và tự lưu

Lựa chọn được server duyệt cập nhật gameplay trước, đánh dấu hồ sơ đã thay đổi và **gom lưu sau 2 giây tính từ thay đổi cuối**. Khi vẫn còn thay đổi liên tục, lịch lưu dự phòng mỗi **30 giây** tiếp tục ghi hồ sơ. Lưu thủ công có giới hạn **5 giây** giữa các yêu cầu; có thêm lần lưu khi rời/chốt server.

Vì trang bị/cài đặt có khoảng gom, dừng máy chủ đột ngột trước lần ghi có thể khiến lựa chọn mới nhất chưa lên kho bền vững. Dòng trạng thái cho biết còn chờ hay đã ghi; không hiển thị thành “đã lưu” chỉ vì người chơi vừa bấm nút.

### Hồi chiêu Pet

Thời gian hồi chủ được chụp từ trạng thái server và lưu dưới dạng hạn Unix. Khi tải lại, phần thời gian đã qua được tính tiếp thay vì đặt lại một lượt hồi sẵn sàng. Máu/choáng Pet là cơ chế khác; lưu hạn hồi chủ không làm cho việc cho Pet choáng tạo thêm lượt hồi.

### Khi rời và khi server đóng

Luồng rời gọi đóng nhiệm vụ/trả vật tư trước, sau đó lưu và nhả khóa tài khoản, cuối cùng dọn trạng thái nhân vật/Pet/base. `BindToClose` chạy lưu các hồ sơ song song và chờ trong khoảng thời gian giới hạn của triển khai; từng lần release cũng đợi một thao tác lưu đang chạy.

Đây là cơ hội lưu cuối có giới hạn, không phải bảo đảm ghi được khi mạng hoặc dịch vụ ngừng hoạt động kéo dài. Bản chưa ghi được giữ để thử lại khi tiến trình còn sống; kill ứng dụng/crash làm mất phần chỉ còn trong RAM. Do đó giao dịch kinh tế dùng lưu trước thành công và trạng thái lỗi phải hiện rõ.

## 6. Lượt săn bị ngắt và trả vật tư

Đồ mang đi săn là phần **được chuyển từ kho vào `ActiveRun`**, không phải một bản sao thêm. Lượt giữ số đầu và số còn của bẫy sắt/thuốc, mã lượt/quái, trạng thái và các dấu đã nhận.

| Trạng thái ghi lại | Cách phục hồi |
| --- | --- |
| `Preparing`, chưa vào săn xong | Đóng dưới dạng vào thất bại và trả vật tư được dành ban đầu |
| `Hunting` bị ngắt | Đóng lượt cũ; trả đúng bẫy/thuốc còn lại đã ghi, không cấp gói thắng |
| Đã `Defeated` hoặc `Captured` nhưng chưa đóng | Giữ thưởng/cá thể đã ghi, trả vật tư còn lại; không phát lại kết quả |
| Lượt đã đóng | Không trả thêm; sổ dấu nhận tiếp tục ngăn replay |

Sau phục hồi người chơi ở sảnh và nhận lượt mới. Không dựng lại máu, AI, xác quái, bẫy hay thời gian thu hoạch cũ. Quặng/vảy chưa nhặt và lượt mổ chưa hoàn tất không tự biến thành vật phẩm.

Thao tác đóng/phục hồi dùng cùng luật giao dịch, giữ dấu `CloseRun` và lưu bản đã sửa trước khi cho chơi. Gọi phục hồi lần hai không hoàn thêm một bộ vật tư. Nếu phục hồi vượt trần kho hoặc dữ liệu sai, hệ thống chặn tải và giữ dữ liệu để điều tra thay vì âm thầm bỏ reservation.

Thống kê thắng/bắt tăng khi Finish được ghi hợp lệ. Lượt Hunting bị bỏ dở tăng thất bại khi CloseRun hoặc Recover được ghi lần đầu; gọi phục hồi/lặp receipt không cộng thêm. Đây là bộ đếm cơ bản, chưa phải hệ thành tích đầy đủ.

## 7. Khóa phiên, retry và chống ghi đè

Một tài khoản có một token sở hữu phiên, kèm hạn khóa **120 giây**. Lưu định kỳ gia hạn khóa; chỉ thao tác acquire/tải được tiếp nhận một khóa đã hết hạn. Server khác có khóa còn hiệu lực sẽ nhận trạng thái xung đột thay vì lấy hồ sơ rồi ghi đè.

Các lần ghi kiểm tra token, hạn khóa và revision. Mất khóa hoặc lệch revision đưa hồ sơ vào trạng thái cần tải lại/xử lý xung đột; không ghi một bản mặc định lên thay. Release cũng có mã commit để việc gọi lại không ghi trùng sau khi khóa đã nhả.

Mỗi đợt gọi repository thử tối đa **4 lần** khi lỗi dịch vụ, với khoảng chờ tăng dần **0,5 → 1 → 2 giây** giữa các lần trong cấu hình hiện hành. Sau một đợt lưu vẫn lỗi, service đặt lịch thử lại sau **10 giây**; nút lưu có thể yêu cầu thử sớm khi không có thao tác khác đang ghi. Xung đột/dữ liệu không hợp lệ không được retry như thể chỉ là mạng chậm.

Sổ kinh tế tiếp tục giữ 64 thao tác gần đây và 8 lượt đã đóng; số thứ tự tăng dần từ chối mã quá cũ. Sổ commit của repository giữ 32 lần gần nhất và `LastCommit`. Các lớp này phục vụ những dạng retry khác nhau, không thay cho kiểm tra quyền máy chủ, khoảng cách hoặc điều kiện săn.

## 8. Trạng thái trên màn hình

| Trạng thái | Ý nghĩa/cách xử lý |
| --- | --- |
| `Loading` | Đang tải; chưa có quyền dùng hồ sơ |
| `Loaded` | Đã tải và áp dụng hồ sơ; không đồng nghĩa người chơi vừa thực hiện một lần lưu thủ công |
| `Dirty` | Có trang bị/cài đặt vừa đổi, chờ tự lưu |
| `Saving` | Đang gửi bản ghi; tránh lặp giao dịch đang chờ |
| `Saved` | Lần ghi đã được repository xác nhận; HUD hiện giờ UTC+7 |
| `Error` | Tải/lưu không thành công; xem thông báo, thử tải hoặc lưu lại đúng trạng thái |
| `Unavailable` | Chưa đủ điều kiện dùng kho, ví dụ Place cục bộ chưa xuất bản |
| `Conflict` | Hồ sơ đang được phiên khác dùng hoặc server hiện tại mất quyền ghi; chờ rồi tải lại |
| `Closing` | Đang chốt/lưu trước khi nhả phiên |

Khi `ProfileReady=false`, màn phủ chỉ cho thấy trạng thái và nút **THỬ TẢI LẠI** trong trường hợp lỗi. Lớp server cũng kiểm tra readiness; màn phủ không phải cơ chế bảo mật duy nhất. Nếu hồ sơ đã tải nhưng ghi tạm lỗi, không tự xóa các món đã có; giao dịch mới cần lưu bị khóa cho tới khi xử lý bản chờ.

`TestMemory` luôn được ghi rõ trên HUD và phần Cài đặt/Cửa hàng, không hiện tuyên bố lưu tài khoản. Nút lưu HUD được ẩn trong mode này. Đây là lựa chọn QA chủ động, không phải fallback tự bật khi DataStore lỗi.

## 9. Bản thử riêng tư, mở game và thử lưu cloud

**Đã tạo thành công HunDino trên Roblox và Studio đã tải lại qua Team Create**, hỗ trợ PC. PlaceId **`103261391098991`**, UniverseId/GameId **`10772096106`**, CreatorId **`11605296816`** (tài khoản User). Mục tiêu quyền truy cập là **riêng tư**; đang đối chiếu trạng thái thực tế trên Dashboard, chưa ghi nhận mở công khai. Thành công khi tạo game chưa chứng minh DataStore hoặc thoát/vào lại đã đạt.

- [Mở HunDino trên Roblox](https://www.roblox.com/games/103261391098991/HunDino).
- [Quản lý đúng HunDino trong Creator Dashboard](https://create.roblox.com/dashboard/creations/experiences/10772096106/overview).

### 9.1. Mở đúng bản riêng tư

Đăng nhập đúng tài khoản chủ dự án, mở trang chơi HunDino ở trên và bấm **Play** trên PC. Trong [Creator Dashboard](https://create.roblox.com/dashboard/creations), chọn đúng **HunDino / UniverseId 10772096106**. Muốn sửa, mở chính game đó trong Studio; cập nhật bản đang dùng thay vì tạo một game mới mỗi lần.

Game mới mặc định chỉ dành cho người tạo và người có quyền phù hợp. Bật Team Create phục vụ cộng tác chỉnh sửa, không tự mở game cho công chúng; tiếp tục giữ quyền truy cập riêng tư trong lúc thử. [Quyền truy cập sau xuất bản của Roblox](https://create.roblox.com/docs/production/publishing/publish-games-and-places).

Nếu mở một bản `.rbxl` chưa gắn game/place và thấy `GameId=0` hoặc `PlaceId=0`, lớp lưu vẫn chặn tiến trình. Hãy đối chiếu bản đang mở với đúng game đã xuất bản; không tắt kiểm tra readiness để vào một kho giả. Bản `.rbxl` và bản trên Roblox là hai vị trí lưu mã/map cần được cập nhật có chủ đích.

### 9.2. Thử lưu tài khoản bằng client Roblox

1. Vào bản HunDino riêng tư bằng **ứng dụng Roblox**, đợi màn tải biến mất; mode phải là `DataStore`, không có dòng TestMemory.
2. Ghi lại loadout và số xu/vật phẩm ban đầu. Đổi Người sang Cung, Pet sang Katana, thay một số ô giáp khác nhau, tắt Số sát thương và đặt độ nhạy 50%.
3. Đợi trạng thái **Saved/Đã lưu**; có thể bấm LƯU và đợi phản hồi. Mua một vật tư tại đúng quầy để kiểm cả số xu lẫn số món. Không lấy thay đổi UI hoặc thông báo vừa bấm nút làm bằng chứng đã ghi.
4. Thoát hẳn game rồi vào lại đúng trang HunDino bằng cùng tài khoản. So lại từng lựa chọn, xu và vật tư, kiểm không cấp lại 80 xu hoặc trừ mua lần hai.
5. Lặp lại bằng một server mới để tách kết quả khỏi dữ liệu còn trong bộ nhớ server cũ. Sau đó thử chế/nâng hợp lệ, cá thể thật và lượt săn bị ngắt theo checklist mục 10.

Game riêng tư vẫn có thể dùng luồng DataStore trong server Roblox của nó; không cần mở Public để kiểm lưu. **Kết quả các bước này hiện còn chờ nghiệm thu**, không được thay bằng phép save/release/load TestMemory đã làm.

### 9.3. Thử thêm trong Studio

Khi muốn kiểm store cloud riêng của Studio, chủ dự án mở **File → Experience Settings → Security → Enable Studio Access to API Services → Save** trong game thử đã xuất bản. Chỉ bật cho bản thử thuộc quyền quản lý; không tự thay quyền/API trên game live. Đây là quyền Studio truy cập dữ liệu, không phải công tắc mở công khai game. [Hướng dẫn DataStore và quyền Studio của Roblox](https://create.roblox.com/docs/cloud-services/data-stores).

`ProfileConfig.StudioMemoryTest` mặc định **false**; thuộc tính `AccountData.StudioMemoryTest` chỉ dùng bật QA tạm trong Play. Bản native để phát triển/xuất bản phải giữ flag thử tắt. Studio cloud dùng `HunDinoProfiles_Studio_v1`; client Roblox dùng `HunDinoProfiles_v1`. Hai store tách nhau, nên dữ liệu test Studio không tự xuất hiện trong client Roblox.

### 9.4. Khi chủ dự án muốn mở công khai sau này

Chưa thực hiện bước này. Khi đã sẵn sàng, mở đúng HunDino trong Creator Dashboard → **Publish settings → Manage Audience → Manage access**. Chọn tab **Public**, tắt giới hạn Friends nếu muốn cho mọi người trong đối tượng hợp lệ truy cập, rồi **Save Changes**. Hoàn tất điều kiện phát hành và bảng nội dung Roblox yêu cầu, theo nội dung thật của game. [Luồng phát hành và chọn đối tượng hiện hành](https://create.roblox.com/docs/production/publishing/publish-games-and-places).

Điều kiện tài khoản, nội dung và độ tuổi do Roblox kiểm tra tại thời điểm phát hành; nếu chưa đủ điều kiện, giữ riêng tư và hoàn thành đúng yêu cầu hiển thị. Không đánh dấu game đã Public khi chỉ mới publish Place hoặc bật Team Create. Mốc hiện tại tiếp tục giới hạn PC; thêm điện thoại/nền tảng khác cần nghiệm thu điều khiển và bố cục tương ứng.

## 10. Kiểm chứng đã thực hiện và phần còn chờ

### Dữ liệu thuần

| Bộ kiểm tra | Kết quả đã ghi nhận | Nội dung chính |
| --- | --- | --- |
| `tools/test-profile-store.luau` | **160 kiểm tra đạt** | acquire/release, khóa hết hạn, cạnh tranh revision, retry, phản hồi ghi bị mất, commit lặp và chặn ghi trước tải |
| `tools/test-profile-schema.luau` | **597 kiểm tra đạt** | loadout, cài đặt, timestamp, schema/migration, khóa receipt số, dữ liệu sai và phục hồi reservation |
| `tools/test-profile-roundtrip.luau` | **547 kiểm tra đạt** | encode/decode JSON, nhiều giao dịch, kinh tế/cá thể/dấu nhận qua tải lại, recovery và lỗi tải không cấp lại tiền đầu |

Các bộ này dùng backend thử có điều khiển. Chúng chứng minh logic trong tình huống được kiểm tra, không phải kết quả mạng Roblox thật.

### Tích hợp trong Studio — TestMemory rõ ràng

Trong Play đã đổi **Người dùng Cung, Pet dùng Katana**, lựa chọn giáp **Xương/Da**, độ nhạy **50%** và tắt **Số sát thương**. Sau save → release → load trong cùng backend bộ nhớ, các lựa chọn vẫn khớp.

Mua một bẫy thô và một thuốc ngủ ghi số xu từ **80 → 60**, giữ vật phẩm và dấu giao dịch khi reload. Thử chèn **4 lỗi ghi liên tiếp** vào giao dịch đang chờ: kho chưa công bố vẫn **70 xu/0 thuốc ngủ**, không báo đã mua sớm; retry sau đó thành **60 xu/1 thuốc ngủ**, tổng đúng **2 receipt** cho hai lần mua, không trừ thêm.

Hồi máu Pet thực trong bãi tập đưa chủ từ 30 lên 100 HP; hạn hồi chiêu lưu và tải lại vẫn là cùng một mốc Unix, không trở về sẵn sàng. Harness dịch vụ trong Studio đạt thêm 65 kiểm tra/10 nhóm về tải, giao dịch, lỗi, recovery, thay trang bị trong lúc ghi, release và khóa cũ.

Các kết quả trên chỉ là QA TestMemory trong cùng phiên Play. Không có tuyên bố giữ dữ liệu qua Stop Play hoặc thoát/vào client Roblox thật. Bản native cuối đạt 70.035 kiểm tra: 29 binding khớp, 125 script biên dịch, 61.203 đối tượng gốc/5.334.383 thuộc tính đối chiếu không có khác biệt ngoài source cho phép. Giữ 43.775 Part/845 khớp và Terrain gốc. Báo cáo assets/hunting/persistence-saved.json; SHA256: 6e64e2be559d42d13a5b2ffa6baa5248bae31db16c477c8341a95a9703dcb99e. Mốc UI cũ không thay phép kiểm này.

### Checklist nghiệm thu cloud còn chờ

- [ ] Game thử đã xuất bản; source đúng bản persistence, QA bộ nhớ tắt.
- [ ] Studio dùng `HunDinoProfiles_Studio_v1`, client Roblox dùng `HunDinoProfiles_v1`; không đổi hai store sang cùng kho để tiện thử.
- [ ] Chọn vũ khí/giáp Người và Pet khác nhau, đổi cài đặt, đợi Saved, thoát rồi vào lại bằng phiên/server mới vẫn khớp.
- [ ] Mua/chế/nâng búa bằng giao dịch hợp lệ, vào lại giữ xu, chi phí, vật tư, cấp và sát thương búa tương ứng.
- [ ] Bắt thật một cá thể, vào lại giữ đúng GUID/số thứ tự/metadata và số thưởng; replay không tạo con thứ hai.
- [ ] Thoát giữa lượt có vật tư còn lại, vào lại sảnh; chỉ hoàn đúng phần chưa dùng một lần, không tái tạo quái hoặc gói thắng.
- [ ] Gọi Pet hồi, lưu/thoát/vào nhanh; phần hồi chiêu còn lại không được làm mới thành sẵn sàng.
- [ ] Hai phiên cùng tài khoản được xử lý khóa/xung đột; bản cũ không ghi đè bản mới.
- [ ] Thử lỗi/quota/mạng: không mở kho mặc định, không báo thành công sớm, có thông báo và có thể xử lý lại bản chờ.
- [ ] Đóng server có nhiều người: kiểm tra kết quả lưu từng tài khoản và dọn khóa, không chỉ nhìn một dòng Saved trên một client.

## 11. Xử lý lỗi và phục hồi có kiểm soát

| Hiện tượng | Kiểm tra tiếp |
| --- | --- |
| Mở file local và kẹt ở tải | Xem `GameId`/`PlaceId`; dùng game thử đã xuất bản để thử cloud, hoặc QA TestMemory tạm nếu chỉ kiểm logic |
| `Error` khi tải | Xem `ProfileErrorCode` và Output server; xác định quyền API/dịch vụ hay schema, rồi dùng Thử tải lại; không xóa record để “sửa nhanh” |
| Hồ sơ đang ở phiên khác | Thoát phiên cũ nếu còn hoạt động, chờ khóa nhả/hết hạn rồi tải lại; không bỏ kiểm tra khóa |
| Lưu lỗi sau một giao dịch | Giữ bản chờ; thử lưu lại khi hệ thống cho phép. Không gửi thêm lệnh mua/cấp bù vì lần trước có thể đã được ghi nhưng mất phản hồi |
| Vào lại thấy 80 xu/khác dữ liệu thử | Đối chiếu đúng UserId, game và store/mode. TestMemory và hai store cloud không dùng chung dữ liệu |
| Chọn giáp rồi crash ngay | Kiểm tra lần cuối đã Saved chưa; lựa chọn có khoảng gom lưu 2 giây và lịch dự phòng 30 giây |
| Dữ liệu bị từ chối do phiên bản/sai định dạng | Giữ record và bản export để điều tra; sửa migration/validator theo định dạng thực, không tự tạo hồ sơ rỗng thay |

Không có nút reset tài khoản hoặc đường remote tự cấp đồ trong giao diện người chơi. Các probe thử chỉ được tạo ở Studio khi TestMemory bật rõ ràng; không phải tính năng sản phẩm live.

Trước khi thay schema/migration hoặc khôi phục một tài khoản, cần giữ bản export của record hiện tại, UserId, game/store/scope, revision và thời điểm. Bản backup map trước đợt này là `backups/Hub_v24_before_persistence_20261020.rbxl`; nó giúp phục hồi mã/map, **không chứa bản sao tài khoản cloud**.

Nếu cần khôi phục tài khoản từ một bản dữ liệu cũ đã lưu/export, quy trình là chặn phiên đang ghi của tài khoản đó, kiểm tra và chuyển phiên bản bản sao bằng schema hiện hành, giữ nguyên sổ receipt và các mã nguồn, đối chiếu vật tư/cá thể/nâng cấp, rồi mới ghi lại có kiểm soát. Không sửa riêng số xu hoặc cấp đồ bù mà bỏ qua dấu giao dịch. Hệ thống chưa có công cụ admin trong game để thực hiện quy trình này; việc khôi phục cần thao tác quản trị riêng và kiểm tra lại trước khi mở tài khoản.

Những phiên trước khi có lớp lưu chỉ tồn tại trong bộ nhớ server không thể truy xuất lại sau khi server đó đã kết thúc nếu không có bản export hoặc bằng chứng dữ liệu riêng. Lưu mới không tự biết người chơi đã từng chế/nâng gì trong các phiên mất dữ liệu cũ.

## 12. Mã nguồn và API

| File | Vai trò/API chính |
| --- | --- |
| `src/data/ProfileConfig.luau` | Tên store/scope, 2 giây gom, 30 giây dự phòng, 120 giây khóa, 10 giây retry và flag QA mặc định tắt |
| `src/data/ProfileSchema.luau` | `new(EconomyRules)` tạo schema; `Default(nowUnix)`, `Validate/Decode(data)`, `Encode(data)`, `Recover(data)`; kiểm tra/chuẩn hóa dữ liệu thuần |
| `src/data/ProfileStore.luau` | `new(options)`, `Load(key, defaultData)`, `Save(key, data, release)`, `Renew(key)`; acquire, UpdateAsync, revision, retry, encode và receipt commit |
| `src/data/ProfileService.luau` | `Load(player)`, `Data(player)`, `Ready/CanPlay/CanMutate(player)`, `Touch(player)`, `CommitEconomy(player, mutate)`, `Save(player, release)`, `Release(player)`, `Shutdown(beforeRelease)` |
| `src/data/ProfileStatus.client.luau` | HUD lưu, nút lưu thủ công, màn chờ/lỗi và thử tải lại; không tự ghi kho hoặc giả lập gameplay |
| `src/dark-jungle/HubUI.luau` | Cài đặt đọc attribute đã xác nhận, gửi preference cho server và hiện mode/trạng thái lưu |
| `src/hunting/HuntEconomyService.luau` | Adapter nối mọi giao dịch hiện có vào `CommitEconomy`, dùng cùng bảng kinh tế của tài khoản |
| `src/hunting/HuntQuestService.luau`, `HuntCaptureController.luau` | Kiểm tra readiness, đồng bộ vật tư và thứ tự ghi/đóng lượt săn theo luật hiện có |
| `studio-pet-integration/Training.server.luau` | Tải trước khi tạo gameplay, nối loadout/Pet, dọn PlayerRemoving và BindToClose |

`Data(player)` là truy cập server tới dữ liệu chuẩn, không phải API để UI sửa bảng. Thay đổi kinh tế đi qua `CommitEconomy`; thay đổi trang bị/cài đặt đã kiểm tra dùng attribute được server sở hữu và `Touch`. Mở thêm dữ liệu lâu dài phải cập nhật schema, encode/decode, validation, migration và bộ kiểm roundtrip cùng nhau.

Remote mới **`HunDinoProfileAction`** chỉ nhận:

```text
Save
RetryLoad
Preference(key, value)
```

`Preference` chỉ chấp nhận ba boolean và ba mức độ nhạy đã nêu; server rate limit và kiểm tra tài khoản có thể sửa. Client không được chọn UserId, tên store, mã khóa, số dư, cấp hoặc payload hồ sơ. Attribute công bố gồm `ProfileReady`, `ProfileSaveState`, `ProfileStatusText`, `ProfileSavedAt`, `ProfileStorageMode`, `ProfileErrorCode`.

Chạy bộ kiểm từ thư mục HunDino:

```powershell
.\tools\lune\lune.exe run tools/test-profile-store.luau
.\tools\lune\lune.exe run tools/test-profile-schema.luau
.\tools\lune\lune.exe run tools/test-profile-roundtrip.luau
.\tools\lune\lune.exe run tools/inspect-persistence-saved.luau
```

Ba lệnh đầu kiểm dữ liệu/backend thử. Lệnh cuối chỉ đọc Place đã lưu và báo cáo source/cấu hình/bảo toàn cảnh; không ghi lại Place hoặc giải mã/dựng lại Terrain. Lưu bản `.rbxl` bằng native Roblox Studio và kiểm dữ liệu tài khoản là hai bước nghiệm thu riêng.
