# Hướng dẫn Git cho HunDino

<!-- TIEN_DO_20261027_BEGIN -->
> **Trạng thái đối chiếu 27/10/2026, 09:48 UTC+7:** local chính `HunDino_MerchantWeapons_20261026.rbxl` **4.495.025 byte**, SHA256 `8626bc714aa7a0da39493ba1bbcc676a142038b2f8a2c06e602fe01d522229bf`; inspector **129.779 kiểm / 164 source**, đạt. Cloud có bằng chứng mới nhất **v14**, nguồn **4.481.440 byte**; sửa bố cục ống mới chỉ local, **chưa Publish**.
>
> Commit quan sát 677f3da trên developer, workspace sạch trước đợt sửa tài liệu. Đợt cập nhật tiến độ không commit/push/merge, không kiểm lại cấu hình GitHub; tiếp tục dùng quy trình được mô tả bên dưới.
>
> [Báo cáo tiến độ toàn dự án và hôm nay](HunDino/BAO_CAO_TIEN_DO_2026-10-27.md). Ghi chú này cập nhật trạng thái; số liệu/hash của từng mốc cũ bên dưới giữ nguyên theo phạm vi lúc kiểm.
<!-- TIEN_DO_20261027_END -->

Cấu hình ngày 27/10/2026 cho https://github.com/tunz2146/HunDino.

## Luồng làm việc

**Sửa code → commit → kiểm tra tại máy → push lên `developer` → báo cáo Actions → PR → bạn duyệt → merge vào `main`.**

- `developer`: nơi nhận code đang phát triển.
- `main`: bản đã được bạn xem xét; chỉ nhận thay đổi qua Pull Request (PR).
- GitHub yêu cầu cả `Validate` và `Owner approval` đạt trước khi merge. Áp dụng cả admin, chặn force push và xóa nhánh.
- `main-approval` chỉ có người duyệt là tài khoản **tunz2146**, tắt quyền bỏ qua của admin. Cho phép tài khoản này duyệt workflow do chính mình khởi tạo để dùng được với repo một người.
- Không tự merge PR. Đẩy Git hoặc merge Git **không tự Publish game lên Roblox**.

## Thư mục đúng

Repo Git trên máy hiện tại là:

```text
C:\Users\khanh\OneDrive\Documents\ChatGPT\game roblox
├── .git
├── .github                  # Workflow chạy trên GitHub
├── .githooks                # Chặn push sai nhánh và chạy kiểm tra
├── scripts                  # Setup, kiểm tra, push
├── HUONG_DAN_GIT.md
└── HunDino                  # Code, assets, file Roblox Studio
```

Repo trống từng nằm tại `HunDino/.git` đã được lưu nguyên vào `.git/archived-nested/` của repo cha. Không xóa source hoặc lịch sử repo chính. Khi mở riêng `HunDino` trong VS Code, thiết lập đã cho phép nhận repo ở thư mục cha.

## Lấy code lần đầu về máy khác

Cần Git và Python **3.10 trở lên** trong PATH. Cài Git từ https://git-scm.com/downloads và Python từ https://www.python.org/downloads/ nếu máy chưa có. VS Code và Roblox Studio phục vụ sửa code/thử game.

Mở PowerShell ở thư mục muốn đặt dự án:

```powershell
git clone --branch developer https://github.com/tunz2146/HunDino.git HunDino-repo
cd HunDino-repo
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\setup.ps1
```

Mở **cả thư mục `HunDino-repo`** trong VS Code. Bạn có thể mở riêng thư mục con `HunDino` vì đã có task tương ứng, nhưng các ví dụ lệnh dưới đây chạy từ gốc repo.

`setup.ps1` tải Lune **0.10.5** và Rojo **7.7.0** vào `.tools/`, kiểm tra SHA256 theo `scripts/tool-lock.json`, cài Git hook cục bộ, chọn nhánh `developer`, đặt pull chỉ fast-forward và đích push mặc định là `developer`. Không đổi execution policy toàn máy. Bản máy hiện tại có thể dùng Python đi kèm runtime của ứng dụng; máy khác dùng Python đã cài.

Nếu Git chưa biết tên/email của bạn, đặt tại repo, dùng đúng thông tin của tài khoản GitHub:

```powershell
git config user.name "Tên của bạn"
git config user.email "Email GitHub của bạn"
```

Lần đầu push có thể cần đăng nhập GitHub qua Git Credential Manager. Không đưa token hoặc mật khẩu vào source.

## Lấy code mới trước khi làm

Lưu file trong VS Code, rồi:

```powershell
git status
git switch developer
git pull --ff-only origin developer
```

Nếu còn thay đổi chưa commit thì commit hoặc cất chúng trước khi pull. Nếu Git báo hai nhánh phân kỳ, dừng để xem lịch sử và giải quyết xung đột; không dùng force push để chữa lỗi.

Sau khi một PR đã merge vào `main`, cập nhật nhánh làm việc để lần sau không bị thiếu merge commit:

```powershell
git switch developer
git fetch origin
git merge origin/main
```

Nếu không có thay đổi mới, đây thường là fast-forward. Nếu có xung đột, sửa file được báo, kiểm tra rồi commit bản merge trên `developer`.

## Sửa code và push

1. Sửa code, lưu tất cả file. Code trong bộ nhớ chưa Save của VS Code/Studio sẽ không được Git lấy.
2. Xem file nào sắp đưa lên:

```powershell
git status
git diff
```

3. Commit và push bằng lệnh gộp:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\push-developer.ps1 -Message "Sửa cung và cập nhật giao diện"
```

Lệnh này stage **toàn bộ thay đổi không bị ignore trong repo**, tạo commit nếu cần, rồi push `developer`. Git hook sẽ kiểm tra trước khi truyền code. Nếu kiểm tra thất bại, commit vẫn nằm an toàn tại máy và push bị chặn. Sửa lỗi, chạy lại với mô tả mới.

Bạn cũng có thể dùng từng lệnh:

```powershell
git switch developer
git add -A
git commit -m "Mô tả thay đổi"
git push -u origin developer
```

`git add -A` lấy các thay đổi trong toàn repo, kể cả khi terminal đang ở thư mục con `HunDino`. Nếu dùng `git add .` ở thư mục con, tài liệu ở thư mục cha có thể chưa được commit và hook sẽ chặn push do working tree còn thay đổi. Cảnh báo LF/CRLF là thông báo chuẩn hóa ký tự xuống dòng, không phải lỗi push.

Hook vẫn chạy khi push từ terminal hoặc nút **Push/Sync** của VS Code. Nếu muốn kiểm tra trước khi commit:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check.ps1
```

Trong VS Code: **Terminal → Run Task** → `HunDino: setup`, `HunDino: check` hoặc `HunDino: push developer`. Task push sẽ hỏi mô tả commit.

## Xem báo cáo mỗi lần push

- **Tại máy**: `.reports/push-<UTC>-<mã riêng>/report.md`, kèm `report.json`, metadata push và log từng bài kiểm tra. Mỗi lần chạy tạo thư mục mới; lần kiểm tra riêng có tiền tố `check-`.
- **Trên GitHub**: mở https://github.com/tunz2146/HunDino/actions → `Developer gate` → lần chạy tương ứng. Xem phần Summary và tải artifact `report-push-<run_id>-<attempt>`; PR có artifact riêng.
- Artifact giữ **90 ngày**. Tải về nếu muốn lưu lâu hơn. Summary/log vẫn phụ thuộc thời gian lưu của GitHub.
- `.reports/` và `.tools/` không commit lên repo. Không tự tạo commit báo cáo để tránh workflow tự kích hoạt lặp.
- Một lần push không có commit mới sẽ báo `Everything up-to-date`; GitHub không tạo run mới. Nếu push bị mất mạng trước khi tới hook/Actions thì không có báo cáo phía GitHub.

Báo cáo có mã commit, nhánh, thời điểm UTC, phạm vi thay đổi, kết quả từng kiểm tra và giới hạn kiểm chứng. Với PR, mã commit được kiểm tra là merge thử do GitHub tạo, bao gồm cả `developer` và `main` hiện tại.

## Khi nào đưa lên main

1. Push xong, đợi `Validate` đạt và đọc báo cáo. Thử gameplay liên quan trong Roblox Studio.
2. Mở https://github.com/tunz2146/HunDino/compare/main...developer để tạo PR, hoặc mở PR đang có cho cùng hai nhánh. Chọn **base: main**, **compare: developer**.
3. Đăng nhập đúng **tunz2146**. Trong trang PR/Actions, mở workflow **Main approval** đang chờ, bấm **Review deployments**, chọn **main-approval**, rồi **Approve and deploy**. Đây là tên nút của GitHub; workflow này chỉ ghi nhận duyệt commit, không Publish Roblox.
4. Quay lại PR, kiểm tra hai check `Validate` và `Owner approval` đều đạt, đọc diff rồi bấm **Merge pull request → Confirm merge** khi bạn quyết định đưa bản đó vào `main`.
5. Nếu push thêm code vào `developer`, kiểm tra và duyệt lại commit mới. Quy tắc yêu cầu nhánh cập nhật với `main` hiện tại.

Không dùng `git push origin main`. Hook sẽ từ chối; GitHub cũng yêu cầu PR và các check. Với repo một người, bước xác nhận dùng environment approval vì tác giả PR không thể tự tạo review Approve cho PR của mình.

## Phạm vi kiểm tra và lỗi đã biết

Bộ kiểm tra mặc định gồm:

- Biên dịch Luau trong source, integration và asset code; kiểm tra cú pháp Python.
- Build cả `default.project.json` và `bio-tubes.project.json` bằng Rojo.
- 25 bài kiểm tra Luau có thể chạy ngoài Studio, gồm chiến đấu, Pet, kinh tế, nhiệm vụ, lưu hồ sơ, chống cấp thưởng lặp và chế tạo/nâng cấp.
- Bộ test server lưu cục bộ bằng Python, dùng dữ liệu giả.
- Chặn file từ 100 MiB, các file bí mật phổ biến và một số mẫu credential. Đây là kiểm tra mẫu, không phải cam kết phát hiện mọi loại bí mật.
- Với PR vào `main`, chỉ chấp nhận nhánh `developer` từ chính repo này.

Ba bài kiểm tra lịch sử hiện **thất bại**, không thuộc gate mặc định. Chúng được ghi trong mọi báo cáo, không được sửa để che kết quả:

| Bài kiểm tra | Nguyên nhân quan sát được |
|---|---|
| `test-training-sanctuary.luau` | Snapshot v2.3 yêu cầu mọi part anchored; part Scute của khủng long không thỏa |
| `test-ui-modernization.luau` | So số remote call hiện tại với bản sao UI trước 20/10; Inventory đã thay đổi |
| `test-weapons-pro.luau` | So sánh hình học giữa hai snapshot lịch sử đang khác nhau |

Để tái hiện các lỗi này, chạy lệnh sau; dự kiến kết quả FAIL:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check.ps1 -Legacy
```

Các test cần engine, ánh sáng, địa hình, va chạm, gameplay hoặc snapshot riêng phải chạy trong Roblox Studio với đúng baseline. CI không chứng minh game hoàn toàn không lỗi, cũng không xác nhận code trong file `.rbxl` luôn trùng source rời. Bạn cần xem phần này trước khi duyệt.

## Khi bị chặn hoặc cần phục hồi

- **Sai nhánh**: `git switch developer`, kiểm tra `git status`, rồi push lại.
- **Còn file chưa commit**: Save file, xem `git status`, commit phần cần đẩy. Hook yêu cầu working tree sạch để kiểm tra đúng commit được gửi.
- **FAIL**: mở đường dẫn báo cáo được in ở terminal hoặc artifact Actions, xem log bài bị lỗi; sửa rồi tạo commit mới.
- **Rejected/non-fast-forward**: `git fetch origin`, xem lịch sử; cập nhật `developer` và giải quyết xung đột. Không force push.
- **Main out of date**: merge `origin/main` vào `developer`, push lại và đợi kiểm tra/duyệt mới.
- **Chưa thấy repo trong VS Code**: mở thư mục gốc repo hoặc reload cửa sổ VS Code sau setup.
- **Muốn hủy thay đổi đã commit**: dùng `git revert <commit>` trên `developer`, push và qua PR như bình thường. Không dùng reset để ghi đè lịch sử chung.

Hook chỉ bảo vệ các máy đã chạy setup và có thể bị bỏ qua bởi người chủ động thay cấu hình. Bảo vệ trên GitHub mới là lớp cưỡng chế phía server. Chủ repo vẫn có quyền chỉnh các quy tắc trong Settings; hãy giữ các check và environment review khi sửa workflow.

## Tham khảo

- [GitHub: protected branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [GitHub: required reviewers cho environment](https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments)
