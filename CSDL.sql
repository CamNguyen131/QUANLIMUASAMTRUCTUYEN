-- =========================================================
-- DATABASE QUẢN LÝ MUA SẮM TRỰC TUYẾN
-- FULL 14 BẢNG + RÀNG BUỘC + MỖI BẢNG 5 DÒNG DỮ LIỆU
-- SQL SERVER
-- =========================================================

-- =========================================================
-- TẠO DATABASE NẾU CHƯA CÓ
-- =========================================================

IF DB_ID('QuanLyMuaSamTrucTuyen') IS NULL
BEGIN
    CREATE DATABASE QuanLyMuaSamTrucTuyen;
END
GO

USE QuanLyMuaSamTrucTuyen;
GO

-- =========================================================
-- XÓA VIEW / PROCEDURE / TRIGGER
-- =========================================================

IF OBJECT_ID('View_DanhSachSanPham','V') IS NOT NULL
DROP VIEW View_DanhSachSanPham;
GO

IF OBJECT_ID('sp_ThemSanPham','P') IS NOT NULL
DROP PROCEDURE sp_ThemSanPham;
GO

IF OBJECT_ID('trg_CapNhatSoLuongTon','TR') IS NOT NULL
DROP TRIGGER trg_CapNhatSoLuongTon;
GO

-- =========================================================
-- XÓA TABLE
-- =========================================================

DROP TABLE IF EXISTS HinhAnhNoiDung;
DROP TABLE IF EXISTS NoiDung;
DROP TABLE IF EXISTS ThongBao;
DROP TABLE IF EXISTS Voucher;
DROP TABLE IF EXISTS DanhGia;
DROP TABLE IF EXISTS ThanhToan;
DROP TABLE IF EXISTS ChiTietDonHang;
DROP TABLE IF EXISTS DonHang;
DROP TABLE IF EXISTS ChiTietGioHang;
DROP TABLE IF EXISTS GioHang;
DROP TABLE IF EXISTS HinhAnhSanPham;
DROP TABLE IF EXISTS SanPham;
DROP TABLE IF EXISTS DanhMuc;
DROP TABLE IF EXISTS NguoiDung;
GO

-- =========================================================
-- 1. NGƯỜI DÙNG
-- =========================================================

CREATE TABLE NguoiDung(
    maNguoiDung INT IDENTITY(1,1) PRIMARY KEY,
    hoTen NVARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    soDienThoai VARCHAR(15) UNIQUE,
    matKhau VARCHAR(255) NOT NULL,
    vaiTro VARCHAR(20) CHECK(vaiTro IN('Admin','NhanVien','KhachHang')),
    trangThai VARCHAR(20) DEFAULT 'HoatDong',
    diaChi NVARCHAR(255),
    gioiTinh BIT,
    ngaySinh DATE,
    ngayTao DATETIME DEFAULT GETDATE()
);
GO

-- =========================================================
-- 2. DANH MỤC
-- =========================================================

CREATE TABLE DanhMuc(
    maDanhMuc INT IDENTITY(1,1) PRIMARY KEY,
    tenDanhMuc NVARCHAR(100) NOT NULL,
    moTa NVARCHAR(255),
    trangThai VARCHAR(20)
);
GO

-- =========================================================
-- 3. SẢN PHẨM
-- =========================================================

CREATE TABLE SanPham(
    maSanPham INT IDENTITY(1,1) PRIMARY KEY,
    maDanhMuc INT NOT NULL,
    SKU VARCHAR(50) UNIQUE,
    tenSanPham NVARCHAR(200) NOT NULL,
    moTa NVARCHAR(MAX),
    giaGoc DECIMAL(18,2),
    giaKhuyenMai DECIMAL(18,2),
    soLuongTon INT CHECK(soLuongTon >= 0),
    thuongHieu NVARCHAR(100),
    trangThai VARCHAR(20),

    CONSTRAINT FK_SanPham_DanhMuc
    FOREIGN KEY(maDanhMuc)
    REFERENCES DanhMuc(maDanhMuc)
);
GO

-- =========================================================
-- 4. HÌNH ẢNH SẢN PHẨM
-- =========================================================

CREATE TABLE HinhAnhSanPham(
    maHinhAnh INT IDENTITY(1,1) PRIMARY KEY,
    maSanPham INT,
    duongDan VARCHAR(255),
    thuTu INT,

    CONSTRAINT FK_HinhAnhSanPham
    FOREIGN KEY(maSanPham)
    REFERENCES SanPham(maSanPham)
);
GO

-- =========================================================
-- 5. GIỎ HÀNG
-- =========================================================

CREATE TABLE GioHang(
    maGioHang INT IDENTITY(1,1) PRIMARY KEY,
    maKhachHang INT,
    ngayTao DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_GioHang
    FOREIGN KEY(maKhachHang)
    REFERENCES NguoiDung(maNguoiDung)
);
GO

-- =========================================================
-- 6. CHI TIẾT GIỎ HÀNG
-- =========================================================

CREATE TABLE ChiTietGioHang(
    maChiTietGioHang INT IDENTITY(1,1) PRIMARY KEY,
    maGioHang INT,
    maSanPham INT,
    soLuong INT CHECK(soLuong > 0),
    giaBan DECIMAL(18,2),

    CONSTRAINT FK_CTGH_GioHang
    FOREIGN KEY(maGioHang)
    REFERENCES GioHang(maGioHang),

    CONSTRAINT FK_CTGH_SanPham
    FOREIGN KEY(maSanPham)
    REFERENCES SanPham(maSanPham)
);
GO

-- =========================================================
-- 7. ĐƠN HÀNG
-- =========================================================

CREATE TABLE DonHang(
    maDonHang INT IDENTITY(1,1) PRIMARY KEY,
    maKhachHang INT,
    tongTien DECIMAL(18,2),
    phiVanChuyen DECIMAL(18,2),
    giamGia DECIMAL(18,2),
    tongThanhToan DECIMAL(18,2),
    trangThai VARCHAR(30),
    phuongThucThanhToan VARCHAR(50),
    diaChiGiao NVARCHAR(255),
    ngayDat DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_DonHang
    FOREIGN KEY(maKhachHang)
    REFERENCES NguoiDung(maNguoiDung)
);
GO

-- =========================================================
-- 8. CHI TIẾT ĐƠN HÀNG
-- =========================================================

CREATE TABLE ChiTietDonHang(
    maChiTiet INT IDENTITY(1,1) PRIMARY KEY,
    maDonHang INT,
    maSanPham INT,
    soLuong INT CHECK(soLuong > 0),
    giaBan DECIMAL(18,2),
    thanhTien DECIMAL(18,2),

    CONSTRAINT FK_CTDH_DonHang
    FOREIGN KEY(maDonHang)
    REFERENCES DonHang(maDonHang),

    CONSTRAINT FK_CTDH_SanPham
    FOREIGN KEY(maSanPham)
    REFERENCES SanPham(maSanPham)
);
GO

-- =========================================================
-- 9. THANH TOÁN
-- =========================================================

CREATE TABLE ThanhToan(
    maThanhToan INT IDENTITY(1,1) PRIMARY KEY,
    maDonHang INT,
    ngayThanhToan DATETIME,
    soTien DECIMAL(18,2),
    phuongThuc VARCHAR(50),
    trangThai VARCHAR(30),

    CONSTRAINT FK_ThanhToan
    FOREIGN KEY(maDonHang)
    REFERENCES DonHang(maDonHang)
);
GO

-- =========================================================
-- 10. ĐÁNH GIÁ
-- =========================================================

CREATE TABLE DanhGia(
    maDanhGia INT IDENTITY(1,1) PRIMARY KEY,
    maSanPham INT,
    maKhachHang INT,
    maDonHang INT,
    soSao INT CHECK(soSao BETWEEN 1 AND 5),
    noiDung NVARCHAR(1000),

    CONSTRAINT FK_DanhGia_SP
    FOREIGN KEY(maSanPham)
    REFERENCES SanPham(maSanPham),

    CONSTRAINT FK_DanhGia_ND
    FOREIGN KEY(maKhachHang)
    REFERENCES NguoiDung(maNguoiDung),

    CONSTRAINT FK_DanhGia_DH
    FOREIGN KEY(maDonHang)
    REFERENCES DonHang(maDonHang)
);
GO

-- =========================================================
-- 11. VOUCHER
-- =========================================================

CREATE TABLE Voucher(
    maVoucher INT IDENTITY(1,1) PRIMARY KEY,
    maNguoiDung INT,
    codeVoucher VARCHAR(50) UNIQUE,
    giaTriGiam DECIMAL(18,2),
    ngayBatDau DATE,
    ngayKetThuc DATE,

    CONSTRAINT FK_Voucher
    FOREIGN KEY(maNguoiDung)
    REFERENCES NguoiDung(maNguoiDung)
);
GO

-- =========================================================
-- 12. THÔNG BÁO
-- =========================================================

CREATE TABLE ThongBao(
    maThongBao INT IDENTITY(1,1) PRIMARY KEY,
    maNguoiNhan INT,
    tieuDe NVARCHAR(255),
    noiDung NVARCHAR(MAX),

    CONSTRAINT FK_ThongBao
    FOREIGN KEY(maNguoiNhan)
    REFERENCES NguoiDung(maNguoiDung)
);
GO

-- =========================================================
-- 13. NỘI DUNG
-- =========================================================

CREATE TABLE NoiDung(
    maNoiDung INT IDENTITY(1,1) PRIMARY KEY,
    tieuDe NVARCHAR(255),
    loaiNoiDung VARCHAR(50),
    noiDung NVARCHAR(MAX),
    nguoiTao NVARCHAR(100)
);
GO

-- =========================================================
-- 14. HÌNH ẢNH NỘI DUNG
-- =========================================================

CREATE TABLE HinhAnhNoiDung(
    maHinhAnh INT IDENTITY(1,1) PRIMARY KEY,
    maNoiDung INT,
    duongDan VARCHAR(255),

    CONSTRAINT FK_HinhAnhNoiDung
    FOREIGN KEY(maNoiDung)
    REFERENCES NoiDung(maNoiDung)
);
GO

-- =========================================================
-- INSERT NGƯỜI DÙNG (5 DÒNG)
-- =========================================================

INSERT INTO NguoiDung VALUES
(N'Admin', 'admin@gmail.com', '0901111111', '123', 'Admin', 'HoatDong', N'Đà Nẵng', 1, '2000-01-01', GETDATE()),
(N'Lan', 'lan@gmail.com', '0901111112', '123', 'KhachHang', 'HoatDong', N'Hà Nội', 0, '2001-02-02', GETDATE()),
(N'Hoàng', 'hoang@gmail.com', '0901111113', '123', 'KhachHang', 'HoatDong', N'HCM', 1, '2002-03-03', GETDATE()),
(N'Mai', 'mai@gmail.com', '0901111114', '123', 'NhanVien', 'HoatDong', N'Huế', 0, '2003-04-04', GETDATE()),
(N'An', 'an@gmail.com', '0901111115', '123', 'KhachHang', 'HoatDong', N'Quảng Nam', 1, '2004-05-05', GETDATE());
GO

-- =========================================================
-- INSERT DANH MỤC
-- =========================================================

INSERT INTO DanhMuc VALUES
(N'Laptop', N'Laptop gaming', 'HienThi'),
(N'Điện thoại', N'Smartphone', 'HienThi'),
(N'Phụ kiện', N'Gaming gear', 'HienThi'),
(N'Màn hình', N'Monitor', 'HienThi'),
(N'PC', N'Máy tính bàn', 'HienThi');
GO

-- =========================================================
-- INSERT SẢN PHẨM
-- =========================================================

INSERT INTO SanPham VALUES
(1,'LAP001',N'ASUS ROG',N'Gaming',35000000,33000000,10,N'ASUS','ConHang'),
(1,'LAP002',N'Acer Nitro',N'Gaming',25000000,22000000,5,N'Acer','ConHang'),
(2,'DT001',N'iPhone 15',N'Apple',34000000,33000000,8,N'Apple','ConHang'),
(2,'DT002',N'Samsung S24',N'Samsung',32000000,30000000,6,N'Samsung','ConHang'),
(3,'PK001',N'Logitech G102',N'Chuột gaming',500000,350000,50,N'Logitech','ConHang');
GO

-- =========================================================
-- INSERT HÌNH ẢNH SẢN PHẨM
-- =========================================================

INSERT INTO HinhAnhSanPham VALUES
(1,'asus.jpg',1),
(2,'acer.jpg',1),
(3,'iphone.jpg',1),
(4,'samsung.jpg',1),
(5,'logitech.jpg',1);
GO

-- =========================================================
-- INSERT GIỎ HÀNG
-- =========================================================

INSERT INTO GioHang(maKhachHang) VALUES
(1),(2),(3),(4),(5);
GO

-- =========================================================
-- INSERT CHI TIẾT GIỎ HÀNG
-- =========================================================

INSERT INTO ChiTietGioHang VALUES
(1,1,1,33000000),
(2,2,1,22000000),
(3,3,1,33000000),
(4,4,1,30000000),
(5,5,2,350000);
GO

-- =========================================================
-- INSERT ĐƠN HÀNG
-- =========================================================

INSERT INTO DonHang VALUES
(1,33000000,30000,0,33030000,'DangGiao','COD',N'Đà Nẵng',GETDATE()),
(2,22000000,30000,0,22030000,'DaGiao','Momo',N'Hà Nội',GETDATE()),
(3,33000000,30000,0,33030000,'ChoXacNhan','VNPay',N'HCM',GETDATE()),
(4,30000000,30000,0,30030000,'DangGiao','COD',N'Huế',GETDATE()),
(5,700000,30000,0,730000,'Mới','COD',N'Quảng Nam',GETDATE());
GO

-- =========================================================
-- INSERT CHI TIẾT ĐƠN HÀNG
-- =========================================================

INSERT INTO ChiTietDonHang VALUES
(1,1,1,33000000,33000000),
(2,2,1,22000000,22000000),
(3,3,1,33000000,33000000),
(4,4,1,30000000,30000000),
(5,5,2,350000,700000);
GO

-- =========================================================
-- INSERT THANH TOÁN
-- =========================================================

INSERT INTO ThanhToan VALUES
(1,GETDATE(),33030000,'COD','ThanhCong'),
(2,GETDATE(),22030000,'Momo','ThanhCong'),
(3,GETDATE(),33030000,'VNPay','ChoXuLy'),
(4,GETDATE(),30030000,'COD','ThanhCong'),
(5,GETDATE(),730000,'COD','ChoXuLy');
GO

-- =========================================================
-- INSERT ĐÁNH GIÁ
-- =========================================================

INSERT INTO DanhGia VALUES
(1,1,1,5,N'Rất tốt'),
(2,2,2,4,N'Ổn'),
(3,3,3,5,N'Đẹp'),
(4,4,4,4,N'Mượt'),
(5,5,5,5,N'Giá rẻ');
GO

-- =========================================================
-- INSERT VOUCHER
-- =========================================================

INSERT INTO Voucher VALUES
(1,'SALE10',10,'2026-01-01','2026-12-31'),
(2,'SALE20',20,'2026-01-01','2026-12-31'),
(3,'SALE30',30,'2026-01-01','2026-12-31'),
(4,'SALE40',40,'2026-01-01','2026-12-31'),
(5,'SALE50',50,'2026-01-01','2026-12-31');
GO

-- =========================================================
-- INSERT THÔNG BÁO
-- =========================================================

INSERT INTO ThongBao VALUES
(1,N'TB1',N'Nội dung 1'),
(2,N'TB2',N'Nội dung 2'),
(3,N'TB3',N'Nội dung 3'),
(4,N'TB4',N'Nội dung 4'),
(5,N'TB5',N'Nội dung 5');
GO

-- =========================================================
-- INSERT NỘI DUNG
-- =========================================================

INSERT INTO NoiDung VALUES
(N'Bài viết 1','Blog',N'Nội dung 1',N'Admin'),
(N'Bài viết 2','Blog',N'Nội dung 2',N'Admin'),
(N'Bài viết 3','TinTuc',N'Nội dung 3',N'Admin'),
(N'Bài viết 4','Blog',N'Nội dung 4',N'Admin'),
(N'Bài viết 5','TinTuc',N'Nội dung 5',N'Admin');
GO

-- =========================================================
-- INSERT HÌNH ẢNH NỘI DUNG
-- =========================================================

INSERT INTO HinhAnhNoiDung VALUES
(1,'blog1.jpg'),
(2,'blog2.jpg'),
(3,'blog3.jpg'),
(4,'blog4.jpg'),
(5,'blog5.jpg');
GO

-- =========================================================
-- VIEW
-- =========================================================

CREATE VIEW View_DanhSachSanPham
AS
SELECT 
    sp.maSanPham,
    sp.tenSanPham,
    dm.tenDanhMuc,
    sp.giaKhuyenMai
FROM SanPham sp
INNER JOIN DanhMuc dm
ON sp.maDanhMuc = dm.maDanhMuc;
GO

-- =========================================================
-- PROCEDURE
-- =========================================================

CREATE PROCEDURE sp_ThemSanPham
(
    @maDanhMuc INT,
    @SKU VARCHAR(50),
    @tenSanPham NVARCHAR(200),
    @gia DECIMAL(18,2)
)
AS
BEGIN

    INSERT INTO SanPham(
        maDanhMuc,
        SKU,
        tenSanPham,
        giaKhuyenMai
    )
    VALUES(
        @maDanhMuc,
        @SKU,
        @tenSanPham,
        @gia
    );

END;
GO

-- =========================================================
-- TRIGGER
-- =========================================================

CREATE TRIGGER trg_CapNhatSoLuongTon
ON ChiTietDonHang
AFTER INSERT
AS
BEGIN

    UPDATE SanPham
    SET soLuongTon = soLuongTon - inserted.soLuong
    FROM SanPham
    INNER JOIN inserted
    ON SanPham.maSanPham = inserted.maSanPham;

END;
GO

PRINT N'TẠO DATABASE THÀNH CÔNG';
GO