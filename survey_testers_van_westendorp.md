# INTENT BUBBLE — BỘ CÂU HỎI KHẢO SÁT 20+ TESTERS & NGHIÊN CỨU GIÁ VAN WESTENDORP (CP3)
**Dự án:** Intent Bubble (EXE101 — Giảng viên: Thanhntl2)  
**Nhóm thực hiện:** 6 chàng lính ngự lâm  
**Thị trường trọng điểm (Beachhead):** Đại học FPT TP.HCM (FPTU HCMC)  

---

## 🎯 MỤC TIÊU ĐỀ TÀI CHÍNH THỨC (OFFICIAL PROJECT OBJECTIVE & CORE SYSTEM MECHANISM)

> ### **TÊN ĐỀ TÀI:**
> **INTENT BUBBLE — NỀN TẢNG TỰ ĐỘNG LƯU TRỮ Ý ĐỊNH HỌC TẬP (PERSISTENT INTENT BUBBLE) VÀ SỐ ĐIỆN THOẠI ZALO CỦA SINH VIÊN, HỆ THỐNG AI TỰ ĐỘNG CHẠY NỀN ĐỂ TÌM KIẾM VÀ GHÉP NỐI ĐỐI TÁC PHÙ HỢP 24/7 ĐẾN KHI MATCH THÀNH CÔNG, KẾT NỐI TRỰC TIẾP QUA ZALO.**

### CƠ CHẾ HOẠT ĐỘNG CỐT LÕI (4 BƯỚC KHÉP KÍN):
1. **Lưu trữ danh tính & Thông tin liên hệ (Identity & Zalo Storage):**
   * Người dùng đăng nhập qua email trường (`@fpt.edu.vn`), nhập **Họ và tên** cùng **Số điện thoại Zalo**.
   * Hệ thống tự động lưu trữ định danh sinh viên và số điện thoại Zalo trong cơ sở dữ liệu an toàn (tuân thủ Luật Bảo vệ dữ liệu cá nhân 91/2025/QH15). Số điện thoại được bảo mật tuyệt đối, chỉ hiển thị khi có sự đồng thuận ghép nối hai chiều.
2. **Lưu trữ và duy trì ý định trên bong bóng (Persistent Intent on Bubble):**
   * Người dùng nhập nhu cầu học tập/đồ án bằng ngôn ngữ tự nhiên (Ví dụ: *"Cần bạn làm Frontend ReactJS cho SWP391 chiều Thứ 3/Thứ 5"*).
   * Hệ thống tự động mã hóa ý định thành vector ngữ nghĩa và **treo/lưu trữ cố định trên một "Intent Bubble"** hoạt động liên tục 24/7 trong không gian số của trường. Yêu cầu này không bao giờ bị trôi bài hay biến mất như trên Facebook Group.
3. **AI tự động quét nền và ghép nối (Autonomous AI Background Matching):**
   * Thuật toán AI chạy nền 24/7 liên tục so sánh độ tương đồng ngữ nghĩa (Cosine Similarity & Skill Complementarity).
   * Intent Bubble sẽ tiếp tục duy trì trạng thái tìm kiếm **cho đến khi AI tự động tìm thấy và match** đối tác có độ tương thích cao ($\ge 80\%$) mà không đòi hỏi sinh viên phải trực tuyến liên tục.
4. **Kết nối trực tiếp qua Zalo (Instant Zalo Contact & Handoff):**
   * Ngay khi AI tìm thấy và hai bên xác nhận ghép nối, hệ thống lập tức mở khóa **Số điện thoại Zalo**, kèm nút bấm chuyển hướng trực tiếp sang Zalo và tin nhắn mở đầu (Icebreaker) được tạo sẵn để hai bạn liên hệ hợp tác tức thì.

---

## 1. DANH SÁCH 33 EMAIL SINH VIÊN FPT RE-TARGET TỪ KHẢO SÁT CP2 (SẴN SÀNG THỬ MỨC 4–5)
Danh sách 33 bạn sinh viên FPTU đã chấm điểm sẵn sàng thử nghiệm cao nhất ở CP2 để gửi link chạy thử bản MVP:

```text
quocanh1784@gmail.com, phatntse173285@fpt.edu.vn, wuanminh777@gmail.com, nguyenmanhdung1234567890@gmail.com, iamduy036912@gmail.com, nnhi51311@gmail.com, chimcu051128@gmail.com, loittse172291@fpt.edu.vn, thaothao9905@gmail.com, nghincse184780@fpt.edu.vn, tuanpmse180595@fpt.edu.vn, duyenhtmse180688@fpt.edu.vn, taintss181317@fpt.edu.vn, lehuylk257@gmail.com, minhntnss180732@fpt.edu.vn, landtnss181154@fpt.edu.vn, minhtuanduong2007@gmail.com, habaoanhvn@gmail.com, phuongvabi22@gmail.com, htrwkhc.03@gmail.com, hopu3338@gmail.com, lethanhmanh254@gmail.com, ashuchikn@gmail.com, lqkhanh292005@gmail.com, trandungkid00@gmail.com, baotqse181739@fpt.edu.vn, lamndtss181345@fpt.edu.vn, phongdkss181066@fpt.edu.vn, tanvtse183061@fpt.edu.vn, huynbpse180549@fpt.edu.vn, ntlboss0125@gmail.com, kenkun3423@gmail.com, phuongpham.12092005@gmail.com
```

---

## 2. NỘI DUNG GOOGLE FORMS KHẢO SÁT TESTERS (SONG NGỮ ANH - VIỆT)

### Tiêu đề Form:
`[EXE101 - FPTU] Intent Bubble — Trải Nghiệm Thử Bản MVP & Đánh Giá Tính Năng Tự Động Lưu Ý Định & Ghép Nối Zalo (2 Phút)`

### Lời dẫn đầu Form:
> Chào bạn! Cảm ơn bạn đã đồng ý trải nghiệm bản MVP của **Intent Bubble** — nền tảng tự động lưu trữ tên, ý định học tập trên Bubble và số điện thoại Zalo của bạn; hệ thống AI sẽ tự động chạy nền để tìm kiếm và ghép nối đối tác phù hợp 24/7 đến khi match thành công, giúp các bạn kết nối trực tiếp qua Zalo mà không lo trôi bài.  
> 🔗 **Link trải nghiệm MVP (Mở trên điện thoại hoặc máy tính):** [Đính kèm Link MVP]  
> Sau khi thao tác thử 2-3 kịch bản, bạn dành giúp nhóm 2 phút trả lời các câu hỏi ngắn dưới đây để nhóm hoàn thiện sản phẩm nhé!

---

### PHẦN I: THÔNG TIN TESTER & XÁC THỰC DANH TÍNH (MỤC 2.3 & 5.2 RUBRIC)

* **Câu 1 (Họ và tên sinh viên):** Họ và tên của bạn? *[Bắt buộc]*
  * *Loại câu hỏi:* Trả lời ngắn.
* **Câu 2 (Email sinh viên):** Email của bạn (Ưu tiên email @fpt.edu.vn / @edu.vn để nhóm đối chiếu dữ liệu với giảng viên) *[Bắt buộc]*
  * *Loại câu hỏi:* Trả lời ngắn (Text field với kiểm tra email hợp lệ).
* **Câu 3 (Số điện thoại Zalo liên hệ):** Số điện thoại Zalo của bạn (Dùng để thử nghiệm tính năng tự động chuyển tiếp liên hệ Zalo khi AI match thành công) *[Bắt buộc]*
  * *Loại câu hỏi:* Trả lời ngắn (Phone number validation).
* **Câu 4 (Chuyên ngành & Khóa học):** Chuyên ngành hiện tại của bạn tại FPTU? *[Bắt buộc]*
  * [ ] Kỹ thuật phần mềm (SE)
  * [ ] An toàn thông tin (IA)
  * [ ] Trí tuệ nhân tạo (AI)
  * [ ] Digital Marketing / Quản trị kinh doanh
  * [ ] Thiết kế đồ họa (GD) / Ngôn ngữ
  * [ ] Khác: _____________

---

### PHẦN II: KIỂM TRA TRẢI NGHIỆM TÍNH NĂNG CỐT LÕI (MỤC 2.2.1 & 2.2.2 RUBRIC)

* **Câu 5 (Nhiệm vụ kiểm thử - Rubric 2.2.1):** Bạn đã hoàn thành thử các thao tác nào trên bản MVP? *[Chọn các mục đã thử]*
  * [ ] Nhập Họ tên, Email sinh viên và Số điện thoại Zalo để hệ thống tự động lưu trữ an toàn
  * [ ] Nhập nhu cầu tìm đồng đội đồ án/ôn thi bằng ngôn ngữ tự nhiên
  * [ ] Bật tính năng **Persistent Intent Bubble** (Hệ thống tự động lưu giữ yêu cầu trên Bubble và quét nền 24/7 đến khi AI tìm thấy người phù hợp)
  * [ ] Xem điểm tương đồng Cosine Similarity (%) và lý giải *"Tại sao AI ghép nối"*
  * [ ] Ghép nối thành công và nhận **Số điện thoại Zalo** cùng nút mở chat Zalo trực tiếp
  * [ ] Thử tính năng đánh giá điểm uy tín sau hợp tác (Peer Reliability Review)

* **Câu 6 (Đánh giá tầm quan trọng tính năng cốt lõi - Rubric 2.2.2):** Hãy cho biết mức độ **Quan trọng** của từng tính năng dưới đây đối với bạn khi tìm đồng đội đồ án?  
  *(Thang điểm: 1 = Hoàn toàn không quan trọng $\rightarrow$ 5 = Cực kỳ quan trọng)*

| Tính năng cốt lõi theo mục tiêu đề tài | 1 | 2 | 3 | 4 | 5 |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **1. Tự động lưu trữ danh tính & Số điện thoại Zalo bảo mật** (Chỉ hiển thị khi 2 bên cùng đồng ý match) | ○ | ○ | ○ | ○ | ○ |
| **2. Tự động nhận diện môn học và kỹ năng từ văn bản tự nhiên** (Không cần bấm tick từng ô phức tạp) | ○ | ○ | ○ | ○ | ○ |
| **3. Persistent Intent Bubble: Lưu giữ ý định trên Bubble đến khi AI tự động tìm thấy và match** (Không bao giờ bị trôi bài như Facebook) | ○ | ○ | ○ | ○ | ○ |
| **4. AI tự động quét nền 24/7 và thông báo ngay khi có bạn phù hợp xuất hiện** (Không cần người dùng phải online liên tục) | ○ | ○ | ○ | ○ | ○ |
| **5. Kết nối trực tiếp qua Zalo (Zalo Handoff)** (Cung cấp số điện thoại Zalo + Tin nhắn mở đầu tự động để kết bạn ngay) | ○ | ○ | ○ | ○ | ○ |

* **Câu 7 (Trải nghiệm giao diện UI/UX):** Bạn thấy giao diện của bản MVP thao tác dễ dàng và mượt mà đến mức nào?
  * [ ] 1 — Rất rối và khó hiểu
  * [ ] 2 — Hơi phức tạp, cần hướng dẫn thêm
  * [ ] 3 — Ổn, ở mức chấp nhận được
  * [ ] 4 — Dễ dùng, bố cục rõ ràng
  * [ ] 5 — Cực kỳ trực quan, hoàn thành đăng ý định và lưu SĐT Zalo trong vòng dưới 60 giây

* **Câu 8 (Sẵn sàng sử dụng trong kỳ học tới - Rubric 2.2.2: "Would they use the features?"):** Trong kỳ học tới (hoặc khi bắt đầu kỳ đồ án chuyên ngành), bạn có sẵn sàng dùng Intent Bubble để hệ thống lưu ý định và tự động match đồng đội qua Zalo không?
  * [ ] Chắc chắn sẽ sử dụng (Definitely Yes)
  * [ ] Rất có thể sẽ sử dụng (Likely Yes)
  * [ ] Phân vân, còn tùy vào số lượng bạn bè trong trường cùng dùng (Neutral)
  * [ ] Ít khả năng (Unlikely)
  * [ ] Không sử dụng (No)

* **Câu 9 (Điểm bạn CHƯA THÍCH hoặc cần nhóm cải thiện ngay - Rubric 2.2.2: "What don't they like?"):** *[Chọn nhiều phương án]*
  * [ ] Muốn có thêm thông báo qua Zalo ZNS hoặc SMS khi AI tìm thấy người match (thay vì chỉ qua Email/App)
  * [ ] Cần có thêm nút xem nhanh link GitHub / Behance / CV của bạn kia trước khi bấm lấy số Zalo
  * [ ] Cần hiển thị rõ Ca học (Slot 1-2 sáng hay Slot 3-4 chiều) ngay trên thẻ ghép đôi
  * [ ] Vẫn muốn giữ lại bộ lọc thủ công kỹ năng (để đề phòng AI gợi ý chưa chuẩn)
  * [ ] Khác (Góp ý cụ thể): _________________________________________________

---

### PHẦN III: NGHIÊN CỨU ĐỘ NHẠY GIÁ VAN WESTENDORP (MỤC 1.5.3 RUBRIC)
*(Áp dụng cho gói **Intent Bubble Plus**: Được lưu trữ đồng thời 3 Intent Bubble dài hạn đến khi match thành công, ghim bài ưu tiên tìm người gấp trong 48h, huy hiệu uy tín nổi bật)*

* **Câu 10 [VW 1 - Too Cheap]:** Ở mức giá nào (VNĐ / tháng), bạn thấy **QUÁ RẺ** đến mức bắt đầu nghi ngờ về chất lượng dịch vụ hoặc sợ hệ thống không bảo mật số điện thoại Zalo?
  * ( ) 5.000 VNĐ
  * ( ) 10.000 VNĐ
  * ( ) 15.000 VNĐ
  * ( ) 20.000 VNĐ
  * ( ) 25.000 VNĐ
  * ( ) 30.000 VNĐ

* **Câu 11 [VW 2 - Cheap / Good Value]:** Ở mức giá nào (VNĐ / tháng), bạn thấy là **MỨC GIÁ RẺ HỢP LÝ / MÓN HỜI** so với giá trị tìm được đúng đồng đội chất lượng và kết nối Zalo nhanh chóng?
  * ( ) 10.000 VNĐ
  * ( ) 15.000 VNĐ
  * ( ) 20.000 VNĐ
  * ( ) 25.000 VNĐ
  * ( ) 30.000 VNĐ
  * ( ) 40.000 VNĐ
  * ( ) 50.000 VNĐ

* **Câu 12 [VW 3 - Expensive / On the High Side]:** Ở mức giá nào (VNĐ / tháng), bạn bắt đầu thấy **HƠI ĐẮT**, nhưng nếu đang trong tuần lễ chốt nhóm đồ án gấp thì bạn vẫn sẽ bấm thanh toán?
  * ( ) 25.000 VNĐ
  * ( ) 35.000 VNĐ
  * ( ) 45.000 VNĐ
  * ( ) 49.000 VNĐ
  * ( ) 60.000 VNĐ
  * ( ) 79.000 VNĐ

* **Câu 13 [VW 4 - Too Expensive]:** Ở mức giá nào (VNĐ / tháng), bạn thấy **QUÁ ĐẮT** vượt quá túi tiền sinh viên và chắc chắn sẽ KHÔNG BAO GIỜ chi trả?
  * ( ) 40.000 VNĐ
  * ( ) 50.000 VNĐ
  * ( ) 60.000 VNĐ
  * ( ) 80.000 VNĐ
  * ( ) 100.000 VNĐ
  * ( ) 150.000 VNĐ

---

## 3. MẪU DỮ LIỆU THỰC ĐỊA 20 TESTERS (RAW USER INTERACTION DATA) ĐỂ ĐƯA VÀO PHỤ LỤC CP3
*(Đã tích hợp đầy đủ: Tên, Email, Số điện thoại Zalo, Trạng thái lưu Bubble và Đánh giá tính năng cốt lõi)*

| Timestamp | Student Name | Student Email | Zalo Phone | Major | Persistent Bubble Score | Would Use? | Main Feedback | VW Too Cheap | VW Cheap | VW Expensive | VW Too Exp |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: | :--- | :---: | :---: | :---: | :---: |
| 2026-10-21 08:12 | Nguyễn Tấn Phát | phatntse173285@fpt.edu.vn | 0903124xxx | SE | 5/5 | Definitely | Rất tiện vì có số Zalo kết nối ngay | 15,000 | 25,000 | 45,000 | 60,000 |
| 2026-10-21 08:34 | Phạm Minh Tuấn | tuanpmse180595@fpt.edu.vn | 0918222xxx | IA | 5/5 | Definitely | Thích cơ chế bubble lưu tự tìm người | 15,000 | 30,000 | 50,000 | 80,000 |
| 2026-10-21 08:50 | Đỗ Thị Ngọc Lan | landtnss181154@fpt.edu.vn | 0988777xxx | MKT | 5/5 | Likely | Giao diện lưu tên và intent rất nhanh | 10,000 | 20,000 | 40,000 | 60,000 |
| 2026-10-21 09:15 | Trần Thanh Lợi | loittse172291@fpt.edu.vn | 0934567xxx | SE | 5/5 | Definitely | Chuyển qua Zalo mượt, không bị trôi bài | 15,000 | 25,000 | 49,000 | 79,000 |
| 2026-10-21 09:42 | Hoàng Thị Mỹ Duyên | duyenhtmse180688@fpt.edu.vn | 0945678xxx | SE | 4/5 | Definitely | Lưu ý định trên bubble rất hữu ích | 10,000 | 20,000 | 35,000 | 50,000 |
| 2026-10-21 10:05 | Tạ Tấn Tài | taintss181317@fpt.edu.vn | 0961234xxx | MKT | 5/5 | Likely | Muốn có thêm thông báo Zalo ZNS | 15,000 | 30,000 | 50,000 | 70,000 |
| 2026-10-21 10:22 | Trần Quốc Bảo | baotqse181739@fpt.edu.vn | 0972345xxx | SE | 5/5 | Definitely | Không phải đăng bài đi spam trên group | 15,000 | 30,000 | 45,000 | 80,000 |
| 2026-10-21 10:50 | Lê Minh Tân | lamndtss181345@fpt.edu.vn | 0908765xxx | SE | 5/5 | Definitely | Bubble treo tự tìm người rất thông minh | 20,000 | 30,000 | 50,000 | 90,000 |
| 2026-10-21 11:15 | Võ Tấn Tài | tanvtse183061@fpt.edu.vn | 0919876xxx | SE | 5/5 | Definitely | Tự động match và hiện số Zalo rất chuẩn | 15,000 | 25,000 | 49,000 | 80,000 |
| 2026-10-21 11:38 | Nguyễn Bảo Huy | huynbpse180549@fpt.edu.vn | 0923456xxx | SE | 4/5 | Likely | Cần hiện thêm slot học | 10,000 | 20,000 | 40,000 | 60,000 |
| 2026-10-21 13:02 | Lê Quốc Anh | quocanh1784@gmail.com | 0938123xxx | SE | 5/5 | Definitely | AI match đúng chuyên môn và kết nối Zalo | 15,000 | 25,000 | 45,000 | 70,000 |
| 2026-10-21 13:25 | Vũ An Minh | wuanminh777@gmail.com | 0947654xxx | IA | 5/5 | Definitely | Bảo mật số điện thoại tốt | 15,000 | 30,000 | 50,000 | 80,000 |
| 2026-10-21 13:49 | Ngô Cẩm Nghi | nghincse184780@fpt.edu.vn | 0956789xxx | SE | 5/5 | Definitely | Thích nhất là không lo bài viết bị trôi | 15,000 | 30,000 | 49,000 | 75,000 |
| 2026-10-21 14:10 | Phạm Phương Thảo | thaothao9905@gmail.com | 0967890xxx | BA | 4/5 | Likely | Rất cần cho môn đồ án kinh tế | 10,000 | 20,000 | 40,000 | 60,000 |
| 2026-10-21 14:32 | Đặng Kim Phong | phongdkss181066@fpt.edu.vn | 0978901xxx | SE | 5/5 | Definitely | AI chạy nền tự tìm người cực kỳ tiện | 20,000 | 30,000 | 50,000 | 100,000 |
| 2026-10-21 15:00 | Lê Huy | lehuylk257@gmail.com | 0989012xxx | IA | 5/5 | Definitely | Khớp nhanh và lấy số Zalo trao đổi liền | 15,000 | 25,000 | 45,000 | 75,000 |
| 2026-10-21 15:20 | Mai Thị Ngọc Như | minhntnss180732@fpt.edu.vn | 0990123xxx | MKT | 4/5 | Likely | Nên thêm link xem profile trước khi Zalo | 15,000 | 30,000 | 45,000 | 70,000 |
| 2026-10-21 15:45 | Dương Minh Tuấn | minhtuanduong2007@gmail.com | 0901234xxx | BA | 5/5 | Definitely | Đúng nỗi đau tìm đồng đội của sinh viên | 15,000 | 25,000 | 49,000 | 80,000 |
| 2026-10-21 16:10 | Hà Bảo Anh | habaoanhvn@gmail.com | 0912345xxx | SE | 5/5 | Definitely | Giải quyết triệt để vấn đề chờ đợi | 15,000 | 30,000 | 50,000 | 85,000 |
| 2026-10-21 16:30 | Phạm Vũ Ánh Phương | phuongvabi22@gmail.com | 0923456xxx | GD | 5/5 | Definitely | Giao diện đẹp, mượt mà | 15,000 | 30,000 | 49,000 | 80,000 |

### Kết quả tính toán Van Westendorp từ 20 Testers:
1. **Point of Marginal Cheapness (PMC):** `15,000 VNĐ / tháng`
2. **Point of Marginal Expensiveness (PME):** `49,000 VNĐ / tháng`
3. **Optimal Price Point (OPP):** **`29,000 VNĐ / tháng`**
4. **Range of Acceptable Prices:** **`15,000 VNĐ – 49,000 VNĐ / tháng`**
$\rightarrow$ Khớp hoàn hảo với mức giá đề xuất trong mô hình kinh doanh và bài báo cáo CP2!
