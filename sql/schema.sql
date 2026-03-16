-- ======================================================================
-- DỰ ÁN: HỆ THỐNG QUẢN LÝ THƯ VIỆN (LIBRARY MANAGEMENT SYSTEM)
-- MÔ TẢ: Script khởi tạo cấu trúc CSDL (DDL) dựa trên sơ đồ ERD.
-- ======================================================================

CREATE DATABASE IF NOT EXISTS LibraryManagement;
USE LibraryManagement;

-- 1. BẢNG DANH MỤC THÔNG TIN CHUNG
CREATE TABLE NHAXUATBAN (
    MaNXB INT AUTO_INCREMENT PRIMARY KEY,
    TenNXB VARCHAR(150) NOT NULL,
    DiaChi VARCHAR(255),
    SDT VARCHAR(20)
);

CREATE TABLE TACGIA (
    MaTacGia INT AUTO_INCREMENT PRIMARY KEY,
    TenTacGia VARCHAR(120) NOT NULL,
    ButDanh VARCHAR(100)
);

CREATE TABLE THELOAI (
    MaTheLoai INT AUTO_INCREMENT PRIMARY KEY,
    TenTheLoai VARCHAR(100) NOT NULL UNIQUE
);

-- 2. BẢNG NGƯỜI DÙNG CỐT LÕI
CREATE TABLE DOCGIA (
    MaDocGia INT AUTO_INCREMENT PRIMARY KEY,
    HoTen VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    SDT VARCHAR(20),
    LoaiThe VARCHAR(50),
    NgayHetHanThe DATE,
    TenDangNhap VARCHAR(50) UNIQUE NOT NULL,
    MatKhau VARCHAR(255) NOT NULL
);

CREATE TABLE THUTHU (
    MaThuThu INT AUTO_INCREMENT PRIMARY KEY,
    HoTen VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    CaLamViec VARCHAR(50)
);

-- 3. BẢNG QUẢN LÝ TÀI NGUYÊN (Tách biệt Thông tin & Bản sao vật lý)
CREATE TABLE DAUSACH (
    ISBN VARCHAR(20) PRIMARY KEY,
    TenSach VARCHAR(200) NOT NULL,
    NamXuatBan INT,
    MaNXB INT,
    FOREIGN KEY (MaNXB) REFERENCES NHAXUATBAN(MaNXB)
);

-- Bảng trung gian (Quan hệ n-n)
CREATE TABLE DAUSACH_TACGIA (
    ISBN VARCHAR(20),
    MaTacGia INT,
    PRIMARY KEY (ISBN, MaTacGia),
    FOREIGN KEY (ISBN) REFERENCES DAUSACH(ISBN) ON DELETE CASCADE,
    FOREIGN KEY (MaTacGia) REFERENCES TACGIA(MaTacGia) ON DELETE CASCADE
);

CREATE TABLE DAUSACH_THELOAI (
    ISBN VARCHAR(20),
    MaTheLoai INT,
    PRIMARY KEY (ISBN, MaTheLoai),
    FOREIGN KEY (ISBN) REFERENCES DAUSACH(ISBN) ON DELETE CASCADE,
    FOREIGN KEY (MaTheLoai) REFERENCES THELOAI(MaTheLoai) ON DELETE CASCADE
);

-- Cuốn sách vật lý
CREATE TABLE CUONSACH (
    MaCaBiet VARCHAR(50) PRIMARY KEY, -- Mã vạch dán trên sách
    ISBN VARCHAR(20),
    ViTriKe VARCHAR(50),
    TinhTrang VARCHAR(50) DEFAULT 'Mới', -- Mới, Cũ, Rách bìa...
    TrangThai VARCHAR(50) DEFAULT 'Có sẵn', -- Có sẵn, Đang mượn, Đã mất
    FOREIGN KEY (ISBN) REFERENCES DAUSACH(ISBN)
);

-- 4. BẢNG NGHIỆP VỤ GIAO DỊCH (Lưu thông sách)
CREATE TABLE PHIEUDATCHO (
    MaDatCho INT AUTO_INCREMENT PRIMARY KEY,
    MaDocGia INT,
    ISBN VARCHAR(20),
    NgayDat DATETIME DEFAULT CURRENT_TIMESTAMP,
    HanGiu DATETIME,
    TrangThai VARCHAR(50) DEFAULT 'Đang chờ', -- Đang chờ, Đã nhận, Hủy
    FOREIGN KEY (MaDocGia) REFERENCES DOCGIA(MaDocGia),
    FOREIGN KEY (ISBN) REFERENCES DAUSACH(ISBN)
);

CREATE TABLE PHIEUMUON (
    MaPhieuMuon INT AUTO_INCREMENT PRIMARY KEY,
    MaDocGia INT,
    MaThuThu INT,
    NgayMuon DATETIME DEFAULT CURRENT_TIMESTAMP,
    HanTra DATETIME NOT NULL,
    TrangThai VARCHAR(50) DEFAULT 'Đang mượn', -- Đang mượn, Đã trả xong, Quá hạn
    FOREIGN KEY (MaDocGia) REFERENCES DOCGIA(MaDocGia),
    FOREIGN KEY (MaThuThu) REFERENCES THUTHU(MaThuThu)
);

CREATE TABLE CT_PHIEUMUON (
    MaPhieuMuon INT,
    MaCaBiet VARCHAR(50),
    NgayTraThucTe DATETIME NULL,
    TinhTrangLucTra VARCHAR(100),
    GhiChu VARCHAR(255),
    PRIMARY KEY (MaPhieuMuon, MaCaBiet),
    FOREIGN KEY (MaPhieuMuon) REFERENCES PHIEUMUON(MaPhieuMuon),
    FOREIGN KEY (MaCaBiet) REFERENCES CUONSACH(MaCaBiet)
);

CREATE TABLE PHIEUPHAT (
    MaPhieuPhat INT AUTO_INCREMENT PRIMARY KEY,
    MaPhieuMuon INT,
    MaCaBiet VARCHAR(50),
    LoaiPhat VARCHAR(100), -- Quá hạn, Làm rách, Mất sách
    SoTien DECIMAL(10, 2) NOT NULL,
    TrangThai VARCHAR(50) DEFAULT 'Chưa thanh toán', -- Chưa thanh toán, Đã thanh toán
    FOREIGN KEY (MaPhieuMuon, MaCaBiet) REFERENCES CT_PHIEUMUON(MaPhieuMuon, MaCaBiet)
);
