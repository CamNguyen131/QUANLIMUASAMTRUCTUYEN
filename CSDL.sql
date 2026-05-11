USE master;
GO

/* =========================================================
   KIỂM TRA DATABASE TỒN TẠI
========================================================= */
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'QuanLyMuaSamTrucTuyen')
BEGIN
    ALTER DATABASE QuanLyMuaSamTrucTuyen
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE QuanLyMuaSamTrucTuyen;
END
GO

/* =========================================================
   TẠO DATABASE
========================================================= */
CREATE DATABASE QuanLyMuaSamTrucTuyen;
GO

USE QuanLyMuaSamTrucTuyen;
GO

/* =========================================================
   BẢNG NGƯỜI DÙNG
========================================================= */
CREATE TABLE NguoiDung
(
    maNguoiDung INT IDENTITY(1,1) PRIMARY KEY,
    hoTen NVARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    soDienThoai VARCHAR(15) UNIQUE,
    matKhau VARCHAR(255) NOT NULL,
    vaiTro NVARCHAR(30) DEFAULT N'KhachHang',
    trangThai NVARCHAR(30) DEFAULT N'HoatDong',
    diaChi NVARCHAR(255),
    gioiTinh NVARCHAR(10),
    ngaySinh DATE,
    ngayTao DATETIME DEFAULT GETDATE(),

    CONSTRAINT CK_NguoiDung_GioiTinh
    CHECK (gioiTinh IN (N'Nam', N'Nu'))
);
GO

/* =========================================================
   BẢNG DANH MỤC
========================================================= */
CREATE TABLE DanhMuc
(
    maDanhMuc INT IDENTITY(1,1) PRIMARY KEY,
    tenDanhMuc NVARCHAR(100) NOT NULL,
    moTa NVARCHAR(255),
    trangThai NVARCHAR(20) DEFAULT N'HienThi'
);
GO

/* =========================================================
   BẢNG SẢN PHẨM
========================================================= */
CREATE TABLE SanPham
(
    maSanPham INT IDENTITY(1,1) PRIMARY KEY,
    maDanhMuc INT NOT NULL,
    tenSanPham NVARCHAR(200) NOT NULL,
    giaBan DECIMAL(18,2) NOT NULL,
    soLuongTon INT DEFAULT 0,
    thuongHieu NVARCHAR(100),
    moTa NVARCHAR(MAX),
    hinhAnh VARCHAR(255),
    trangThai NVARCHAR(30) DEFAULT N'ConHang',

    CONSTRAINT FK_SanPham_DanhMuc
    FOREIGN KEY(maDanhMuc)
    REFERENCES DanhMuc(maDanhMuc),

    CONSTRAINT CK_SanPham_GiaBan
    CHECK (giaBan > 0),

    CONSTRAINT CK_SanPham_SoLuong
    CHECK (soLuongTon >= 0)
);
GO

/* =========================================================
   BẢNG HÌNH ẢNH SẢN PHẨM
========================================================= */
CREATE TABLE HinhAnhSanPham
(
    maHinhAnh INT IDENTITY(1,1) PRIMARY KEY,
    maSanPham INT NOT NULL,
    duongDan VARCHAR(255),
    thuTu INT,

    CONSTRAINT FK_HinhAnhSanPham_SanPham
    FOREIGN KEY(maSanPham)
    REFERENCES SanPham(maSanPham)
);
GO

/* =========================================================
   BẢNG GIỎ HÀNG
========================================================= */
CREATE TABLE GioHang
(
    maGioHang INT IDENTITY(1,1) PRIMARY KEY,
    maKhachHang INT NOT NULL,
    ngayTao DATETIME DEFAULT GETDATE(),
    trangThai NVARCHAR(30) DEFAULT N'ChuaThanhToan',

    CONSTRAINT FK_GioHang_NguoiDung
    FOREIGN KEY(maKhachHang)
    REFERENCES NguoiDung(maNguoiDung)
);
GO

/* =========================================================
   BẢNG CHI TIẾT GIỎ HÀNG
========================================================= */
CREATE TABLE ChiTietGioHang
(
    maChiTietGioHang INT IDENTITY(1,1) PRIMARY KEY,
    maGioHang INT NOT NULL,
    maSanPham INT NOT NULL,
    soLuong INT NOT NULL,
    giaBan DECIMAL(18,2) NOT NULL,

    thanhTien AS (soLuong * giaBan) PERSISTED,

    CONSTRAINT FK_CTGH_GioHang
    FOREIGN KEY(maGioHang)
    REFERENCES GioHang(maGioHang),

    CONSTRAINT FK_CTGH_SanPham
    FOREIGN KEY(maSanPham)
    REFERENCES SanPham(maSanPham),

    CONSTRAINT CK_CTGH_SoLuong
    CHECK (soLuong > 0)
);
GO

/* =========================================================
   BẢNG ĐƠN HÀNG
========================================================= */
CREATE TABLE DonHang
(
    maDonHang INT IDENTITY(1,1) PRIMARY KEY,
    maKhachHang INT NOT NULL,
    tongTien DECIMAL(18,2),
    phiVanChuyen DECIMAL(18,2),
    giamGia DECIMAL(18,2),
    tongThanhToan DECIMAL(18,2),
    trangThai NVARCHAR(30),
    phuongThucThanhToan NVARCHAR(50),
    diaChiGiao NVARCHAR(255),
    ngayDat DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_DonHang_NguoiDung
    FOREIGN KEY(maKhachHang)
    REFERENCES NguoiDung(maNguoiDung)
);
GO

/* =========================================================
   BẢNG CHI TIẾT ĐƠN HÀNG
========================================================= */
CREATE TABLE ChiTietDonHang
(
    maChiTiet INT IDENTITY(1,1) PRIMARY KEY,
    maDonHang INT NOT NULL,
    maSanPham INT NOT NULL,
    soLuong INT NOT NULL,
    giaBan DECIMAL(18,2),

    thanhTien AS (soLuong * giaBan) PERSISTED,

    CONSTRAINT FK_CTDH_DonHang
    FOREIGN KEY(maDonHang)
    REFERENCES DonHang(maDonHang),

    CONSTRAINT FK_CTDH_SanPham
    FOREIGN KEY(maSanPham)
    REFERENCES SanPham(maSanPham)
);
GO

/* =========================================================
   BẢNG THANH TOÁN
========================================================= */
CREATE TABLE ThanhToan
(
    maThanhToan INT IDENTITY(1,1) PRIMARY KEY,
    maDonHang INT NOT NULL,
    ngayThanhToan DATETIME,
    soTien DECIMAL(18,2),
    phuongThuc NVARCHAR(50),
    trangThai NVARCHAR(30),

    CONSTRAINT FK_ThanhToan_DonHang
    FOREIGN KEY(maDonHang)
    REFERENCES DonHang(maDonHang)
);
GO

/* =========================================================
   BẢNG ĐÁNH GIÁ
========================================================= */
CREATE TABLE DanhGia
(
    maDanhGia INT IDENTITY(1,1) PRIMARY KEY,
    maSanPham INT NOT NULL,
    maKhachHang INT NOT NULL,
    soSao INT,
    noiDung NVARCHAR(1000),
    ngayDanhGia DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_DanhGia_SanPham
    FOREIGN KEY(maSanPham)
    REFERENCES SanPham(maSanPham),

    CONSTRAINT FK_DanhGia_NguoiDung
    FOREIGN KEY(maKhachHang)
    REFERENCES NguoiDung(maNguoiDung),

    CONSTRAINT CK_DanhGia_SoSao
    CHECK (soSao BETWEEN 1 AND 5)
);
GO

/* =========================================================
   BẢNG VOUCHER
========================================================= */
CREATE TABLE Voucher
(
    maVoucher INT IDENTITY(1,1) PRIMARY KEY,
    codeVoucher VARCHAR(50) UNIQUE,
    giaTriGiam DECIMAL(18,2),
    ngayBatDau DATE,
    ngayKetThuc DATE,
    soLuong INT,

    CONSTRAINT CK_Voucher_SoLuong
    CHECK (soLuong >= 0)
);
GO

/* =========================================================
   BẢNG THÔNG BÁO
========================================================= */
CREATE TABLE ThongBao
(
    maThongBao INT IDENTITY(1,1) PRIMARY KEY,
    maNguoiNhan INT,
    tieuDe NVARCHAR(255),
    noiDung NVARCHAR(MAX),
    ngayGui DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_ThongBao_NguoiDung
    FOREIGN KEY(maNguoiNhan)
    REFERENCES NguoiDung(maNguoiDung)
);
GO

/* =========================================================
   BẢNG NỘI DUNG
========================================================= */
CREATE TABLE NoiDung
(
    maNoiDung INT IDENTITY(1,1) PRIMARY KEY,
    tieuDe NVARCHAR(255),
    noiDung NVARCHAR(MAX),
    nguoiTao NVARCHAR(100),
    ngayTao DATETIME DEFAULT GETDATE()
);
GO

/* =========================================================
   BẢNG HÌNH ẢNH NỘI DUNG
========================================================= */
CREATE TABLE HinhAnhNoiDung
(
    maHinhAnh INT IDENTITY(1,1) PRIMARY KEY,
    maNoiDung INT,
    duongDan VARCHAR(255),

    CONSTRAINT FK_HinhAnhNoiDung_NoiDung
    FOREIGN KEY(maNoiDung)
    REFERENCES NoiDung(maNoiDung)
);
GO

/* =========================================================
   INSERT NGƯỜI DÙNG
========================================================= */
INSERT INTO NguoiDung
(hoTen,email,soDienThoai,matKhau,vaiTro,diaChi,gioiTinh)
VALUES
(N'Nguyễn Văn A','a@gmail.com','0901111111','123456',N'Admin',N'Đà Nẵng',N'Nam'),
(N'Trần Thị B','b@gmail.com','0902222222','123456',N'KhachHang',N'Hà Nội',N'Nu'),
(N'Lê Văn C','c@gmail.com','0903333333','123456',N'KhachHang',N'Huế',N'Nam'),
(N'Phạm Thị D','d@gmail.com','0904444444','123456',N'NhanVien',N'HCM',N'Nu'),
(N'Hoàng Văn E','e@gmail.com','0905555555','123456',N'KhachHang',N'Quảng Nam',N'Nam');
GO

/* =========================================================
   INSERT DANH MỤC
========================================================= */
INSERT INTO DanhMuc(tenDanhMuc,moTa)
VALUES
(N'Laptop',N'Laptop gaming'),
(N'Điện thoại',N'Smartphone'),
(N'Màn hình',N'Màn hình máy tính'),
(N'Phụ kiện',N'Chuột bàn phím'),
(N'PC Gaming',N'Máy tính gaming');
GO

/* =========================================================
   INSERT SẢN PHẨM
========================================================= */
INSERT INTO SanPham
(maDanhMuc,tenSanPham,giaBan,soLuongTon,thuongHieu,moTa,hinhAnh)
VALUES
(1,N'ASUS ROG Strix',32000000,10,N'ASUS',N'Laptop gaming mạnh','asus.jpg'),
(1,N'Acer Nitro 5',22000000,15,N'Acer',N'Laptop gaming','acer.jpg'),
(2,N'iPhone 15',28000000,8,N'Apple',N'Điện thoại cao cấp','iphone.jpg'),
(3,N'Màn hình LG 27 inch',5000000,12,N'LG',N'Màn hình đẹp','lg.jpg'),
(4,N'Chuột Logitech G102',350000,50,N'Logitech',N'Chuột gaming','g102.jpg');
GO

/* =========================================================
   INSERT HÌNH ẢNH SẢN PHẨM
========================================================= */
INSERT INTO HinhAnhSanPham(maSanPham,duongDan,thuTu)
VALUES
(1,'asus1.jpg',1),
(2,'acer1.jpg',1),
(3,'iphone1.jpg',1),
(4,'lg1.jpg',1),
(5,'g102.jpg',1);
GO

/* =========================================================
   INSERT GIỎ HÀNG
========================================================= */
INSERT INTO GioHang(maKhachHang,trangThai)
VALUES
(2,N'ChuaThanhToan'),
(3,N'ChuaThanhToan'),
(4,N'DaThanhToan'),
(5,N'ChuaThanhToan'),
(2,N'DaDatHang');
GO

/* =========================================================
   INSERT CHI TIẾT GIỎ HÀNG
========================================================= */
INSERT INTO ChiTietGioHang(maGioHang,maSanPham,soLuong,giaBan)
VALUES
(1,1,1,32000000),
(1,5,2,350000),
(2,3,1,28000000),
(3,4,1,5000000),
(4,2,1,22000000);
GO

/* =========================================================
   INSERT ĐƠN HÀNG
========================================================= */
INSERT INTO DonHang
(maKhachHang,tongTien,phiVanChuyen,giamGia,tongThanhToan,trangThai,phuongThucThanhToan,diaChiGiao)
VALUES
(2,32700000,30000,0,32730000,N'DangGiao',N'Momo',N'Hà Nội'),
(3,28000000,30000,500000,27530000,N'DaGiao',N'COD',N'Huế'),
(4,5000000,30000,0,5030000,N'ChoXacNhan',N'VNPay',N'HCM'),
(5,22000000,30000,1000000,21030000,N'DangGiao',N'Momo',N'Quảng Nam'),
(2,350000,30000,0,380000,N'DaGiao',N'TienMat',N'Đà Nẵng');
GO

/* =========================================================
   INSERT CHI TIẾT ĐƠN HÀNG
========================================================= */
INSERT INTO ChiTietDonHang(maDonHang,maSanPham,soLuong,giaBan)
VALUES
(1,1,1,32000000),
(2,3,1,28000000),
(3,4,1,5000000),
(4,2,1,22000000),
(5,5,1,350000);
GO

/* =========================================================
   INSERT THANH TOÁN
========================================================= */
INSERT INTO ThanhToan(maDonHang,ngayThanhToan,soTien,phuongThuc,trangThai)
VALUES
(1,GETDATE(),32730000,N'Momo',N'ThanhCong'),
(2,GETDATE(),27530000,N'COD',N'ThanhCong'),
(3,GETDATE(),5030000,N'VNPay',N'ChoThanhToan'),
(4,GETDATE(),21030000,N'Momo',N'ThanhCong'),
(5,GETDATE(),380000,N'TienMat',N'ThanhCong');
GO

/* =========================================================
   INSERT ĐÁNH GIÁ
========================================================= */
INSERT INTO DanhGia(maSanPham,maKhachHang,soSao,noiDung)
VALUES
(1,2,5,N'Laptop rất mạnh'),
(2,3,4,N'Dùng khá tốt'),
(3,4,5,N'Điện thoại đẹp'),
(4,5,4,N'Màn hình sắc nét'),
(5,2,5,N'Chuột bấm rất êm');
GO

/* =========================================================
   INSERT VOUCHER
========================================================= */
INSERT INTO Voucher(codeVoucher,giaTriGiam,ngayBatDau,ngayKetThuc,soLuong)
VALUES
('SALE10',10,'2026-01-01','2026-12-31',100),
('GIAM50K',50000,'2026-01-01','2026-12-31',200),
('VIP100K',100000,'2026-01-01','2026-12-31',50),
('FREESHIP',30000,'2026-01-01','2026-12-31',500),
('NEWUSER',150000,'2026-01-01','2026-12-31',100);
GO

/* =========================================================
   INSERT THÔNG BÁO
========================================================= */
INSERT INTO ThongBao(maNguoiNhan,tieuDe,noiDung)
VALUES
(1,N'Đơn hàng mới',N'Bạn có đơn hàng mới'),
(2,N'Khuyến mãi',N'Giảm giá cuối tuần'),
(3,N'Thanh toán thành công',N'Đã thanh toán'),
(4,N'Đơn hàng đang giao',N'Shipper đang giao'),
(5,N'Tài khoản',N'Cập nhật tài khoản');
GO

/* =========================================================
   INSERT NỘI DUNG
========================================================= */
INSERT INTO NoiDung(tieuDe,noiDung,nguoiTao)
VALUES
(N'Top laptop gaming',N'Nội dung laptop',N'Admin'),
(N'Top điện thoại',N'Nội dung điện thoại',N'Admin'),
(N'Khuyến mãi tháng 5',N'Nội dung sale',N'Admin'),
(N'Mẹo mua hàng',N'Hướng dẫn mua hàng',N'Admin'),
(N'Tin công nghệ',N'Tin mới nhất',N'Admin');
GO

/* =========================================================
   INSERT HÌNH ẢNH NỘI DUNG
========================================================= */
INSERT INTO HinhAnhNoiDung(maNoiDung,duongDan)
VALUES
(1,'blog1.jpg'),
(2,'blog2.jpg'),
(3,'blog3.jpg'),
(4,'blog4.jpg'),
(5,'blog5.jpg');
GO

/* =========================================================
   VIEW
========================================================= */
CREATE VIEW View_DanhSachSanPham
AS
SELECT
    sp.maSanPham,
    sp.tenSanPham,
    dm.tenDanhMuc,
    sp.giaBan,
    sp.soLuongTon
FROM SanPham sp
INNER JOIN DanhMuc dm
ON sp.maDanhMuc = dm.maDanhMuc;
GO

/* =========================================================
   PROCEDURE THÊM SẢN PHẨM
========================================================= */
CREATE PROC sp_ThemSanPham
(
    @maDanhMuc INT,
    @tenSanPham NVARCHAR(200),
    @giaBan DECIMAL(18,2),
    @soLuongTon INT
)
AS
BEGIN
    INSERT INTO SanPham
    (
        maDanhMuc,
        tenSanPham,
        giaBan,
        soLuongTon
    )
    VALUES
    (
        @maDanhMuc,
        @tenSanPham,
        @giaBan,
        @soLuongTon
    )
END;
GO

/* =========================================================
   TRIGGER GIẢM SỐ LƯỢNG TỒN
========================================================= */
CREATE TRIGGER trg_GiamSoLuongTon
ON ChiTietDonHang
AFTER INSERT
AS
BEGIN
    UPDATE SanPham
    SET soLuongTon = soLuongTon - inserted.soLuong
    FROM SanPham
    INNER JOIN inserted
    ON SanPham.maSanPham = inserted.maSanPham
END;
GO

/* =========================================================
   KIỂM TRA
========================================================= */
SELECT * FROM NguoiDung;
SELECT * FROM DanhMuc;
SELECT * FROM SanPham;
SELECT * FROM GioHang;
SELECT * FROM ChiTietGioHang;
SELECT * FROM DonHang;
SELECT * FROM ChiTietDonHang;
SELECT * FROM ThanhToan;
SELECT * FROM DanhGia;
SELECT * FROM Voucher;
SELECT * FROM ThongBao;
SELECT * FROM NoiDung;
SELECT * FROM HinhAnhNoiDung;
GO

PRINT N'TẠO DATABASE THÀNH CÔNG!';
GO