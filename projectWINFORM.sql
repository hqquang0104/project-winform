CREATE DATABASE projectWINFORM
GO

USE projectWINFORM
GO

CREATE TABLE tblNhanSu(

	idNhanSu int identity(1,1) primary key not null,
	hoTen nvarchar(100) not null,
	soDienThoai nvarchar(50),
	ngaySinh datetime,
	idCapBac int,
	tenDangNhap nvarchar(100) unique,
	matKhau nvarchar(100)
)
GO


CREATE TABLE tblCapBac(
	idCapBac int primary key not null,
	capBac nvarchar(50)
)

GO

CREATE TABLE tblPhong(

	idPhong int primary key not null,
	giaPhongTheoNgay float,
	giaPhongTheoGio float,
	kieuPhong int,
	trangThai int
)
GO


CREATE TABLE tblChiTietDichVu(
	
	
	idDichVu int identity(1,1) primary key not null,
	idPhong int,
	maDichVu int,
	soLuong int
	
)
GO

CREATE TABLE tblDichVu(
	maDichVu int primary key not null,
	tenDichVu nvarchar(100),
	giaDichVu float,
	

)
GO
/*
ALTER TABLE tblDichVu ADD maDichVu int
ALTER TABLE tblThuePhong DROP COLUMN soLuong
ALTER TABLE tblChiTietThuePhong ALTER COLUMN soDienThoai nvarchar(50)
*/

Create TABLE tblChiTietThuePhong(

	id int identity(1,1) primary key not null,
	idPhong int,
	idDichVu int,
	gioVao datetime,
	gioRa datetime,
	chungMinhThu nvarchar(100),
	hoTen nvarchar(200),
	soDienThoai nvarchar(50),
	tienCoc float,
	trangThai int default 2
)
GO

select * from tblChiTietThuePhong




CREATE TABLE tblThuePhong(

	idThuePhong int identity(1,1) primary key not null,
	idChiTietThuePhong int,
	tongTien float,
	idNhanSu int
)
GO


--------------------------------------------------------------------------------------------------
ALTER TABLE tblChiTietThuePhong ADD FOREIGN KEY(idPhong) references tblPhong(idPhong)
ALTER TABLE tblChiTietThuePhong ADD FOREIGN KEY(idDichVu) references tblChiTietDichVu(idDichVu)
ALTER TABLE tblChiTietDichVu ADD FOREIGN KEY(maDichVu) references tblDichVu(maDichVu)
ALTER TABLE tblThuePhong ADD FOREIGN KEY(idChiTietThuePhong) references tblChiTietThuePhong(id)
ALTER TABLE tblThuePhong ADD FOREIGN KEY(idNhanSu) references tblnhanSu(idNhanSu)
ALTER TABLE tblNhanSu ADD FOREIGN KEY(idCapBac) references tblCapBac(idCapBac)




--------------------------------------------------------------------------------------------------
select * from tblPhong
INSERT INTO tblDichVu values(1,N'Nước lọc',20000)

INSERT INTO tblCapBac values(1,N'Giám Đốc')
INSERT INTO tblCapBac values(2,N'Nhân Viên')
INSERT INTO tblCapBac values(3,N'Khách hàng')

INSERT INTO tblNhanSu values(N'Nguyễn Huy Quang',0363989236,'4-1-1999',1,'admin','123')
INSERT INTO tblNhanSu values(N'Lê Hùng Tin',0988108703,'7-30-1997',2,'tin','123')
INSERT INTO tblNhanSu values(N'Lê Tú',0988752022,'4-15-1990',3,'tu','123')
/*
-- 1 ng thuê từ ngày 4-5 đến 7-5 
-- lấy những phòng trông từ ngày 4-7 
DECLARE @TimeIn datetime;
DECLARE @TimeOut datetime;
SET @TimeIn = '5-4-2019 00:00:00';
SET @TimeOut = '5-7-2019 00:00:00';

SELECT * FROM tblPhong p WHERE p.idPhong NOT IN
(SELECT dt.idPhong
FROM tblChiTietThuePhong dt
where 
(dt.gioVao BETWEEN @TimeIn AND @TimeOut) OR -- Khách trước có ngày đến trong khoảng khách đang đặt
(dt.gioRa BETWEEN @TimeIn AND @TimeOut)) -- Khách đặt trước nhưng ngày trả trong khoảng khách đang đặt
-- Kết quả ko có 102 và 103
*/
CREATE PROC tblPhong_Valid
	@TimeIn datetime,
	@TimeOut datetime
AS
BEGIN
	SELECT * FROM tblPhong p WHERE p.idPhong NOT IN
	(SELECT dt.idPhong
	FROM tblChiTietThuePhong dt
	where 
	(dt.gioVao BETWEEN @TimeIn AND @TimeOut) OR -- Khách trước có ngày đến trong khoảng khách đang đặt
	(dt.gioRa BETWEEN @TimeIn AND @TimeOut)) -- Khách đặt trước nhưng ngày trả trong khoảng khách đang đặt
	-- Kết quả ko có 102 và 103
END
GO

/*
--truy vấn 
select * from tblPhong p inner join tblChiTietThuePhong ctp
on p.idPhong = ctp.idPhong
update tblPhong
set trangThai = 1
where idPhong = 101
*/
--thủ tục checkexist
create proc CheckExist
@idPhong int
as
select * from tblPhong p inner join tblChiTietThuePhong ctp
on p.idPhong = ctp.idPhong
where p.idPhong = @idPhong
go
--thủ tục update trạng thái phòng 
create proc UpdateTT
@idPhong int
as
update tblPhong
set trangThai = 1
where idPhong = @idPhong
go



CREATE PROC Bill_Report
@idPhong int
AS
BEGIN
select 
		tp.idChiTietThuePhong as N'mã Chi Tiết',
		ct.idPhong as N'Mã phòng',
		ct.hoTen as N'Tên khách hàng',
		ct.chungMinhThu as N'Chứng minh thư',
		ct.gioVao as N'Giờ vào',
		ct.gioRa as N'Giờ ra',
		ct.tienCoc as N'Tiền cọc',
		ns.hoTen as N'Thu ngân',
		tp.tongTien as N'Tổng tiền',
		dv.maDichVu,
		dv.tenDichVu,
		dv.giaDichVu,
		ctdv.soLuong
		from tblThuePhong tp
		INNER JOIN tblNhanSu ns on tp.idNhanSu = ns.idNhanSu
		INNER JOIN tblChiTietThuePhong ct on tp.idChiTietThuePhong = ct.id
		INNER JOIN tblChiTietDichVu ctdv on ct.idPhong = ctdv.idPhong
		INNER JOIN tblDichVu dv on ctdv.maDichVu = dv.maDichVu
		WHERE ct.idPhong =@idPhong
END
GO


CREATE PROC deletDV
@idPhong int
AS
delete  from tblChiTietDichVu
where idPhong = @idPhong
GO