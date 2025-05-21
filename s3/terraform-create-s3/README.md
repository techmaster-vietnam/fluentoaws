# Cấu hình Website Tĩnh trên AWS S3 sử dụng Terraform

Dự án này thiết lập một AWS S3 bucket được cấu hình để lưu trữ website tĩnh với quyền truy cập công khai. Sử dụng Terraform để quản lý cơ sở hạ tầng dưới dạng code.

## Yêu cầu

- [Terraform](https://www.terraform.io/downloads.html) (phiên bản >= 1.0.0)
- [AWS CLI](https://aws.amazon.com/cli/)
- Tài khoản AWS với quyền truy cập phù hợp
- AWS Access Key và Secret Key

## Cấu trúc Dự án

```
.
├── main.tf           # File cấu hình Terraform chính
├── variables.tf      # Định nghĩa các biến
├── outputs.tf        # Định nghĩa các output
├── index.html        # Trang chủ mẫu
└── error.html        # Trang lỗi 404 tùy chỉnh
```

## Cấu hình

1. Cấu hình AWS credentials bằng một trong các cách sau:

   a. Sử dụng AWS CLI:
   ```bash
   aws configure
   ```
   Nhập các thông tin:
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region (ví dụ: ap-southeast-1)
   - Default output format (json)

   b. Hoặc tạo/sửa file `~/.aws/credentials` thủ công:
   ```ini
   [default]
   aws_access_key_id = YOUR_ACCESS_KEY
   aws_secret_access_key = YOUR_SECRET_KEY
   ```

2. Cập nhật các biến trong `variables.tf` nếu cần:
   - `aws_region`: Khu vực AWS bạn muốn sử dụng
   - `bucket_name`: Tên bucket S3 mong muốn (phải là duy nhất trên toàn cầu)
   - `index_document`: Tên file index (mặc định: index.html)
   - `error_document`: Tên file lỗi (mặc định: error.html)

## Triển khai

1. Khởi tạo Terraform:
   ```bash
   terraform init
   ```

2. Xem trước các thay đổi:
   ```bash
   terraform plan
   ```

3. Áp dụng cấu hình:
   ```bash
   terraform apply
   ```

4. Sau khi triển khai thành công, upload các file tĩnh:
   ```bash
   aws s3 cp index.html s3://<tên-bucket-của-bạn>/
   aws s3 cp error.html s3://<tên-bucket-của-bạn>/
   ```

## Tính năng

- Cho phép truy cập công khai đến tất cả các đối tượng trong bucket
- Cấu hình lưu trữ website tĩnh
- Trang lỗi tùy chỉnh (404)
- Cấu hình CORS cho các yêu cầu cross-origin
- Chính sách bucket phù hợp cho truy cập công khai

## Vấn đề Bảo mật

- Bucket được cấu hình cho phép truy cập công khai
- Chỉ cho phép các phương thức GET và HEAD
- CORS được cấu hình để cho phép truy cập từ mọi nguồn
- Nên xem xét thêm các biện pháp bảo mật bổ sung cho môi trường production

## Output

Sau khi triển khai thành công, Terraform sẽ hiển thị:
- `bucket_name`: Tên của S3 bucket
- `bucket_website_endpoint`: URL endpoint của website
- `bucket_arn`: ARN của S3 bucket

## Truy cập Website

Sau khi triển khai, bạn có thể truy cập website bằng URL endpoint được cung cấp trong output của Terraform. URL sẽ có định dạng:
```
http://<tên-bucket>.s3-website-<khu-vực>.amazonaws.com
```

## Dọn dẹp

Để xóa tất cả tài nguyên đã tạo:
```bash
terraform destroy
```

## Xử lý Sự cố

1. **Lỗi Truy cập Bị Từ chối**
   - Kiểm tra xem AWS credentials đã được cấu hình đúng chưa
   - Kiểm tra xem bucket policy đã được áp dụng đúng chưa
   - Đảm bảo các cài đặt block public access đã bị vô hiệu hóa

2. **Website Không Tải Được**
   - Kiểm tra xem các file đã được upload đúng bucket chưa
   - Kiểm tra xem index.html có ở thư mục gốc của bucket không
   - Đảm bảo bucket đã được cấu hình cho lưu trữ website tĩnh

3. **Vấn đề CORS**
   - Kiểm tra cấu hình CORS trong bucket
   - Kiểm tra xem domain yêu cầu có được phép trong quy tắc CORS không

## Đóng góp

Mọi đóng góp và yêu cầu cải tiến đều được hoan nghênh!

## Giấy phép

Dự án này được cấp phép theo MIT License - xem file LICENSE để biết thêm chi tiết. 