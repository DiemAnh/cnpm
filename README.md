# Template mẫu project nhập môn công nghệ phần mềm

## Công nghệ đang sử dụng
- Backend:
    - Java 17
    - Maven 3.9.11 (các bạn có thể tải bản mới nhất)
- Frontend:
    - Nodejs 16
    - npm 8
- Database:
    - MySQL (chạy trên docker)

## Cách cài đặt hệ thống
**Lưu ý:** Đây là cài đặt cho hệ thống hiện tại. Nếu các bạn sử dụng công nghệ khác, phiên bản khác hoặc ngôn ngữ khác, thì cách cài đặt có thể khác đi nhiều.
1. Cài đặt **docker** và **docker compose**. Sau đó mở terminal hoặc cmd trong thư mục "mysql", tạo thư mục "data" trong thư mục "mysql", chạy câu lệnh:
<pre> docker compose up -d </pre>

Kiểm tra bằng lệnh "docker ps" xem mysql container đã chạy thành công hay chưa. Sau đó truy cập vào database để thêm database "shop". Có thể sử dụng "MySQL Workbench" (với username: root, password: 1) hoặc truy cập bằng câu lệnh:
<pre>
docker exec -it mysql bash
mysql -u root -p 1
create database bluemoon_db;
</pre>
2. Cài đặt java 17 và maven. Các link tham khảo: https://www.youtube.com/watch?v=mg9jJr2_2Oo và https://www.youtube.com/watch?v=YTvlb6eny_0

Trước khi chạy backend, các bạn cần điền các thông tin sau và file "Backend\src\main\resources\application.properties" để hỗ trợ việc xác thực tài khoản bằng otp:

<pre>
spring.mail.username = email
spring.mail.password = password  
</pre>

"email" và "password" chính là tài khoản mail mà các bạn muốn dùng cho hệ thống của mình. Email này sẽ phục vụ việc gửi mail otp đến các mail của tài khoản người dùng. Lưu ý với gmail thì phải dùng "app password" thay vì "password", các bạn vào link sau để lấy "app password": https://myaccount.google.com/u/3/apppasswords

Sau đó chạy các câu lệnh sau để khởi chạy backend:

<pre>
mvn clean install
mvn spring-boot:run
</pre>

Hoặc các bạn có thể không cần cài đặt mvn, khi đó sử dụng file mvnw đang có sẵn:

<pre>
./mvnw clean install
./mvnw spring-boot:run
</pre>

Sau khi khởi chạy backend, với sự hỗ trợ của Spring Data JPA  và Hibernate, backend sẽ tự khởi tạo các bảng trong cơ sở dữ liệu.

3. Cài đặt nodejs và npm. Nên sử dụng nvm-windows để dễ kiểm soát môi trường, ví dụ hướng dẫn cài đặt nvm-windows: https://www.youtube.com/watch?v=E6k6R4PnLV0

Cài đặt nodejs 18:

<pre>
nvm install 18
nvm use 18
</pre>

Kiểm tra cài đặt:

<pre>
node -v   
npm -v    
</pre>

Sau đó khởi chạy frontend:

<pre>
npm install
npm start
</pre>

Sau đó truy cập http://localhost:3000 . Các bạn có thể bắt đầu trải nghiệm trang web từ bây giờ.

## Liên hệ
Cảm ơn các bạn đã đọc 😄🌞😊🙏. 

Project mẫu còn nhiều hạn chế, mong các bạn cố gắng cải thiện để có được dự án tốt nhất, đạt được điểm cao. 

Nếu gặp vấn đề khi khởi chạy hệ thống, các bạn liên hệ qua email: tung.nguyenson@hust.edu.vn hoặc tungns@soict.hust.edu.vn


## Lời cảm ơn
Xin được gửi lời cảm ơn trân trọng nhất tới các bạn sinh viên xuất sắc sau đây đã góp phần giúp cải thiện phần bài tập môn học rất nhiều:

Nguyễn Bá Nhật Hoàng 20230030

Nguyễn Tấn Dũng 20230021

Sái Văn Hiếu 20230027

Trần Quốc Thái 20230065


