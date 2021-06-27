use qlvt;
/*Tạo view gồm các trường SoXe, MaLoTrinh, SoLuongVT, NgayDi, NgayDen, ThoiGianVT, CuocPhi, Thuong*/

create view testview as
select c.soxe, lt.malotrinh, c.soluongVT, c.ngaydi, c.ngayden, caculatorDate(c.ngayden,c.ngaydi) as thoigianVT,
CuocPhi(c.soluongVT,lt.dongia,tt.trongtaiQD) as cuocphi , lt.thoigianQD
from trongtai tt join chitietvantai c on tt.matrongtai = c.matrongtai
join lotrinh lt on lt.malotrinh = c.malotrinh;



create view abc as 
select t.soxe, t.malotrinh, t.soluongVT, t.ngaydi, t.ngayden, t.thoigianVT, t.cuocphi,bonus(t.thoigianVT, t.thoigianQD, t.cuocphi) as bonus
from testview t;
/* funtion tính ngày*/
delimiter //
create function caculatorDate(ngayden datetime, ngaydi datetime ) 
returns int 
DETERMINISTIC
begin
	declare kq int;
    if datediff(ngayden,ngaydi)=0 
    then set kq=1;
	else 
    set kq=datediff(ngayden,ngaydi);
    end if;
    return kq;
end;    
// delimiter ;

delimiter //
create function CuocPhi(soluongVT int,dongia int,trongtaiQD int)
returns int
DETERMINISTIC
begin 
     declare kq int;
    if soluongVT > trongtaiQD 
    then set kq = soluongVT * dongia * 1.05;
    else set kq = soluongVT * dongia;
    end if;
    return kq;
    end;
    // delimiter ;
    
   delimiter //
   create function bonus(ThoiGianVT int,ThoiGianQD int,CuocPhi int)
   returns int
   deterministic
   begin
		declare bn int;
        if thoigianVT > thoigianQD 
        then set bn = 0.05 * cuocphi;
        else set bn = 0;
        end if;
        return bn;
        end;
        // delimiter ;
        
        /*Tạo view để lập bảng cước phí gồm các trường SoXe, TenLoTrinh, SoLuongVT, NgayDi, NgayDen, CuocPhi.*/
        
        create view CuocPhi as
        select tv.soxe, lt.tenlotrinh, tv.soluongVT, tv.ngaydi,tv.ngayden, tv.cuocphi
        from testview tv join lotrinh lt on tv.malotrinh = lt.malotrinh; 
   
   /*Tạo view danh sách các xe có có SoLuongVT vượt trọng tải qui định, gồm các trường SoXe, TenLoTrinh, SoLuongVT, TronTaiQD, NgayDi, NgayDen.*/
   
   create view SoluongVTQD as
   select c.soxe , lt.tenlotrinh, c.soluongVT, tt.trongtaiQD, c.ngaydi,c.ngayden
   from trongtai tt join chitietvantai c on tt.matrongtai = c.matrongtai
   join lotrinh lt on lt.malotrinh = c.malotrinh
   where c.soluongVT > tt.trongtaiQD;
   
   /*Thiết lập thủ tục có đầu vào là số xe, đầu ra là thông tin về lộ trình*/
   
   delimiter //
   create procedure tt (in soxe VARCHAR(50))
   begin
		select l.tenlotrinh from lotrinh l
        join chitietvantai c on c.malotrinh = l.malotrinh
        where c.soxe like soxe;
	end //
    delimiter ;
    call tt('30F-111.11');
    
    /*Thêm trường Thành tiền vào bảng chi tiết vận tải và tạo trigger điền dữ liệu cho trường*/ 
    
    alter table chitietvantai add ThanhTien int;
use qlvt;
delimiter //
create trigger cau7a before update on chitietvantai for each row
begin
	declare cuocphi1 int;
	set cuocphi1 = (select cuocphi from testview where New.MaLoTrinh = testview.MaLoTrinh);
	set New.ThanhTien = cuocphi1;
end //
delimiter ;
update chitietvantai set thanhtien = 3 where 1 = 1;

/*Tạo thủ tục có đầu vào là mã lộ trình, năm vận tải, đầu ra là số tiền theo mã lộ trình đó*/
 use qlvt;
 delimiter //
 create procedure cau8 (in malotrinh VARCHAR(50), in ngaydi datetime)
 begin
	select c.malotrinh, year(c.ngaydi),c.thanhtien from chitietvantai c
    where c.malotrinh = malotrinh and year(ngaydi) = year(c.ngaydi)
    ;
end //
delimiter ;
call cau8('MLT01', '2019-03-10');

/*Tạo thủ tục có đầu vào là số xe, năm vận tải, đầu ra là số tiền theo mã lộ trình đó*/

delimiter //
create procedure cau9_3 (in bsx VARCHAR(50), in namVT int)
begin
	select soxe, year(ngaydi) as namvantai, sum(thanhtien) as sotien 
    from chitietvantai
    where soxe = bsx and year(ngaydi) = namVT
    group by soxe;
end //
delimiter ;
call cau9_3('30F-111.14',2020);

