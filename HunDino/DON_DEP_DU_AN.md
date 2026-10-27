# File đang dùng và kế hoạch dọn HunDino

**Đồng bộ tài liệu: 20/10/2026 — đối chiếu bản v2.4 đã lưu ngày 19/10/2026.**

Kiểm kê trạng thái ngày 20/10: **bản làm việc là v2.4 trong Documents**, kế thừa các đợt đến kho cá thể ngày 19/10. File `HunDino_DarkJungle_v2_4.rbxl` hiện **4.220.334 byte (~4,02 MiB)**. Giữ toàn bộ `src/`, `studio-pet-integration/`, `assets/`, `tools/`, `.git/` ở thư mục gốc dự án và mọi `backups/`; giữ cả v2.3 và file săn/model riêng làm mốc nguồn.

Tài liệu hiện hành gồm **27 file Markdown**: hai bản thiết kế tổng giống nhau, thiết kế map săn ở thư mục cha, README và 23 tài liệu chuyên đề/báo cáo trong HunDino. Danh mục đầy đủ ở [README](README.md). Đợt này không xóa/di chuyển file hoặc xác nhận lại cặp Desktop/Documents trùng nhau. Các số dung lượng và SHA256 so trùng phía dưới là kiểm kê **08/10**, chỉ có giá trị cho mốc đó; không dùng làm căn cứ xóa bản hiện hành.

Kiểm kê 08/10/2026. Chưa xóa file nào. Dung lượng dưới đây là tổng kích thước file logic, không đo dung lượng OneDrive thực chiếm trên ổ.

## Giữ để làm tiếp — danh sách lịch sử 08/10

- `HunDino_DarkJungle_v2_3.rbxl` trên Desktop: file mở trong Studio. Documents có bản đồng bộ để kiểm tra.
- `src/`, `assets/`, `tools/`, `.git/`: mã nguồn, icon gốc, kiểm tra và lịch sử. Giữ `tools/lune/lune.exe`; có thể bỏ gói nén tải về `tools/lune.zip`.
- `THIET_KE_GAME.md`, `README.md`, `TRAINING_SANCTUARY.md`, `COMBOS_V2_3.md`, các manifest/kết quả kiểm tra.
- Ít nhất một bản sao lưu v2.3 trước lần sửa gần nhất. Các bản `.rbxl` chỉ khoảng 0,4 MiB, nên giữ.
- `HunDino_original.rbxl`: map nguồn cho bộ dựng cũ, dung lượng nhỏ.

## File phụ ở mốc v2.3 — kiểm kê lịch sử 08/10

Các file sau có thể đưa sang kho lưu trữ hoặc xóa nếu không cần quay lại mốc cũ. Nên giữ một bản của mỗi mốc muốn khôi phục; không cần giữ cả bản Desktop và Documents giống nhau.

| File (có ở cả Desktop và Documents) | Một bản, MiB | Vai trò |
|---|---:|---|
| `HunDino_DarkJungle_v1.rbxlx` | 16.68 | Mốc đảo cũ |
| `HunDino_DarkJungle_v2_1.rbxlx` | 51.68 | Mốc trước bãi tập; bộ merge cũ dùng nếu dựng lại |
| `HunDino_DarkJungle_v2_2.rbxlx` | 53.74 | Mốc XML trước v2.3 |
| `HunDino_DarkJungle_v2.rbxlx` | 16.68 | Mốc đảo cũ |
| `HunDino_L0.rbxlx` | 12.54 | Mốc sảnh ban đầu |
| `HunDino_original.rbxlx` | 12.40 | Map nguồn dạng XML; giữ nếu cần khôi phục bản nguồn này |
| `TrainingSanctuary.rbxmx` | 0.98 | Kết quả dựng trung gian; có thể tạo lại bằng build-training-sanctuary.luau |
| `tools\lune.zip` | 4.94 | Gói cài đã giải nén; không cần cho kiểm tra |

Bốn bản sao lưu XML lớn trong mỗi `backups/`:

- `backups\HunDino_DarkJungle_v2_before_v2_1_5f198ba295ce.rbxlx`: 50.55 MiB.
- `backups\HunDino_L0_before_DarkJungle_20261005.rbxlx`: 16.38 MiB.
- `backups\v2_1_before_training_a7b69ed72390.rbxlx`: 50.59 MiB.
- `backups\v2_2_before_bow_camera_studio_saved.rbxlx`: 53.73 MiB.

Chúng chiếm **171.25 MiB mỗi thư mục**. Không cần cho v2.3 đang chạy; chỉ phục vụ quay lại lịch sử.

## Bản trùng đã đối chiếu SHA256 ngày 08/10 — chưa kiểm tra lại

- `HunDino_DarkJungle_v1.rbxlx`: 2 bản giống hệt, có thể giữ một bản nếu cần lịch sử (16.68 MiB/bản).
- `HunDino_DarkJungle_v2_1.rbxlx`: 2 bản giống hệt, có thể giữ một bản nếu cần lịch sử (51.68 MiB/bản).
- `HunDino_DarkJungle_v2_2.rbxlx`: 2 bản giống hệt, có thể giữ một bản nếu cần lịch sử (53.74 MiB/bản).
- `HunDino_DarkJungle_v2.rbxlx`: 2 bản giống hệt, có thể giữ một bản nếu cần lịch sử (16.68 MiB/bản).
- `HunDino_L0.rbxlx`: 2 bản giống hệt, có thể giữ một bản nếu cần lịch sử (12.54 MiB/bản).
- `HunDino_original.rbxlx`: 2 bản giống hệt, có thể giữ một bản nếu cần lịch sử (12.40 MiB/bản).
- `TrainingSanctuary.rbxmx`: 2 bản giống hệt, có thể giữ một bản nếu cần lịch sử (0.98 MiB/bản).
- `backups\HunDino_DarkJungle_v2_before_v2_1_5f198ba295ce.rbxlx`: 2 bản giống hệt, có thể giữ một bản nếu cần lịch sử (50.55 MiB/bản).
- `backups\HunDino_L0_before_DarkJungle_20261005.rbxlx`: 2 bản giống hệt, có thể giữ một bản nếu cần lịch sử (16.38 MiB/bản).
- `backups\v2_1_before_training_a7b69ed72390.rbxlx`: 2 bản giống hệt, có thể giữ một bản nếu cần lịch sử (50.59 MiB/bản).
- `backups\v2_2_before_bow_camera_studio_saved.rbxlx`: 2 bản giống hệt, có thể giữ một bản nếu cần lịch sử (53.73 MiB/bản).
- `tools\lune.zip`: 2 bản giống hệt, có thể giữ một bản nếu cần lịch sử (4.94 MiB/bản).

## Đề xuất dọn ở mốc 08/10 — chưa thực hiện

1. Xóa hai `tools/lune.zip` sẽ giảm khoảng 9,88 MiB; giữ `tools/lune/lune.exe`.
2. Gom các mốc XML cũ vào một kho lưu trữ, bỏ bản sao trùng ở thư mục còn lại sau khi kiểm tra. Không cần xóa `.git`.
3. Khi đã thử v2.3 và xác nhận đủ nội dung, chỉ giữ các mốc lịch sử thật sự muốn phục hồi. Các trình dựng cũ cần file nguồn riêng như nêu trong bảng; chúng không phải quy trình cập nhật v2.3.
4. File `.lock` là khóa phiên Studio; không đụng vào khi map còn mở. Chỉ cân nhắc khóa cũ khi Studio đã đóng.

Hiện không có nhiều file v2.3 mới phát sinh: tiếp tục cùng tên bản `.rbxl` và cập nhật thiết kế theo từng đợt. Việc map XML lớn hơn binary không có nghĩa game chạy nặng hơn tương ứng; hiệu năng còn phụ thuộc đối tượng, vật lý và hiệu ứng trong map.
