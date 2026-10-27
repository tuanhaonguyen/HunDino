# Khai thác sắt — trạng thái 27/10/2026

<!-- TIEN_DO_20261027_BEGIN -->
> **Trạng thái đối chiếu 27/10/2026, 09:48 UTC+7:** local chính `HunDino_MerchantWeapons_20261026.rbxl` **4.495.025 byte**, SHA256 `8626bc714aa7a0da39493ba1bbcc676a142038b2f8a2c06e602fe01d522229bf`; inspector **129.779 kiểm / 164 source**, đạt. Cloud có bằng chứng mới nhất **v14**, nguồn **4.481.440 byte**; sửa bố cục ống mới chỉ local, **chưa Publish**.
>
> 30 model quặng đã được xác nhận khi nạp lại cloud; 402 kiểm logic đạt. Inspector 386 kiểm/Ok=false là mốc lịch sử chưa đối soát riêng, không phải inspector mới nhất của bản local.
>
> [Báo cáo tiến độ toàn dự án và hôm nay](BAO_CAO_TIEN_DO_2026-10-27.md). Ghi chú này cập nhật trạng thái; số liệu/hash của từng mốc cũ bên dưới giữ nguyên theo phạm vi lúc kiểm.
<!-- TIEN_DO_20261027_END -->

## Triển khai và luật cấu hình

Đã có 30 điểm quặng cố định trong Thung Lũng Sương Xám; mã nằm ở `src/hunting` gồm IronMiningConfig, IronMiningService, IronMining.client, IronOreVisual, MiningPickaxeVisual và BuildIronMiningNodes. Cấu hình hiện có: thao tác 2,2 giây, hồi quặng 300 giây, tầm 9 studs, tối đa 3 hit. Đây là thông số mã, không tự thay cho Play thực toàn bộ 30 điểm.

## Bằng chứng và giới hạn

| Mốc | Kết quả | Phạm vi |
| --- | --- | --- |
| Inspector thêm quặng 26/10 | `Ok: false`, 386 kiểm trước dừng; hash 73bb353d…43ae9e, 4.480.005 byte | Phát hiện Instance ngoài phạm vi cho phép; giữ làm tồn đọng đối soát, chưa kết luận hỏng map. |
| Publish v12 ngày 27/10 | Mở lại cloud xác nhận 30 model quặng, 163 source, TestMemory tắt | Xác nhận nội dung được upload, chưa chứng minh mọi thao tác khai thác. |
| Sửa tương thích hồ sơ v14 | 402 kiểm logic khai quặng đạt trong bộ hồi quy | Không thay cho input thật và cloud qua phiên mới. |
| Local sửa đường base 27/10 | Inspector 129.779 kiểm / 164 source đạt, hash 8626bc71…2229bf | Đối chiếu với baseline sửa ống; không tự đóng lỗi inspector thêm quặng trước đó. |

Nguồn: [inspector lịch sử](assets/iron-mining/iron-mining-saved.json), [manifest](assets/iron-mining/iron-mining-install.json), [xác nhận phát hành](assets/release/publish-20261027.json), [kiểm logic](assets/profile-compat/verification.json), [kiểm bản local](assets/base-clearance/saved-inspection.json).

## Việc còn lại

Đối soát các Instance chênh trên đúng baseline thêm quặng và ghi kết luận có chứng cứ. Thử khai thác bằng input, hủy/ra xa/rút vũ khí, hồi quặng, nhận nguyên liệu/chống lặp và lưu qua phiên cloud. Chưa có bằng chứng nghiệm thu Play riêng toàn vòng khai quặng trong nguồn đã đối chiếu. Trạng thái toàn dự án xem [báo cáo hôm nay](BAO_CAO_TIEN_DO_2026-10-27.md).
