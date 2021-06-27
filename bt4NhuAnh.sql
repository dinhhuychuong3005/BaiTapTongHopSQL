use bt4;
/*Tạo view KET QUA chứa kết quả thi của từng học sinh bao gồm các thông tin: SoBD, HoTen, Phai, Tuoi, Toan, Van, AnhVan, TongDiem, XepLoai, DTDuThi*/
delimiter //
create function tinhtong(toan int, van int, anhvan int, diemUT int) returns int
    deterministic
begin
    declare sum int;
    set sum = toan + van + anhvan + diemUT;
    return sum;
end //
delimiter ;
delimiter //
create function xeploai(toan int, van int, anhvan int,diemUT int)
    returns varchar(50)
    deterministic
begin
    declare ketqua varchar(50);
    if ((tinhtong(toan, van, anhvan, diemUT) >= 24) and
       toan >= 7 and van >= 7 and anhvan >= 7)
    then set ketqua = 'Gioi';
    elseif ((tinhtong(toan, van, anhvan,diemUT) >= 21) and toan >= 6 and van >= 6 and anhvan >= 6)
    then set ketqua = 'Kha';
    elseif ((tinhtong(toan, van, anhvan,diemUT) >= 15) and toan >= 4 and van >= 4 and anhvan >= 4)
    then set ketqua = 'Trungbinh';
    else set ketqua = 'Truot';
    end if;
    return ketqua;
end
//
delimiter ;

create view ketqua as
    select
    v.soBD,concat(v.ho,v.ten) as hoten,v.phai,
   TIMESTAMPDIFF(YEAR, v.NTNS, CURDATE()) AS age,
    v.toan,v.van,v.anhvan, tinhtong(v.toan,v.van,v.anhvan,c.diemUT)  as tongdiem,
    xeploai(v.toan,v.van,v.anhvan,c.diemUT) as xeploai,c.DTDuthi from danhsach v
    join chitietdt c on c.DTDuThi = v.DTDuThi;
    
    /*Tạo view GIOI TOAN – VAN – ANH VAN bao gồm các học sinh có ít nhất 1 môn 10 vàcó TongDiem>=25 bao gồm các thông tin: SoBD, HoTen, Toan, Van, AnhVan, TongDiem,DienGiaiDT*/
    
    create view GIOI_TOAN–VAN–ANHVAN as
    select ds.soBD, concat(ds.ho,ds.ten), ds.toan, ds.van, ds.anhvan, tinhtong(ds.toan, ds.van, ds.anhvan,c.diemUT) as tongdiem, c.diengiaiDT
    from danhsach ds join chitietdt c on ds.dtDuthi = c.dtDuthi
    where (ds.toan >= 10 or ds.van >=10 or ds.anhvan >= 10) and tinhtong(ds.toan, ds.van, ds.anhvan,c.diemUT) >= 25;
    
    /*Tạo view DANH SACH DAU (ĐẬU) gồm các học sinh có XepLoai là Giỏi, Khá hoặcTrung   Bình   với   các   field:   SoBD,   HoTen,   Phai,   Tuoi,   Toan,   Van,   AnhVan,   TongDiem,XepLoai, DTDuThi*/
    
    create view DANHSACHDAU as
    select k.soBD, k.hoten, k.phai, k.age, k.toan, k.van, k.anhvan, k.tongdiem, k.xeploai, k.DTduthi
    from ketqua k
    where k.xeploai not in ("Truot");
    
    /* Tạo view HOC SINH DAT THU KHOA KY THI bao gồm các học sinh “ĐẬU” cóTongDiem   lớn   nhất   với   các   field:   SoBD,   HoTen,   Phai,   Tuoi,   Toan,   Van,   AnhVan,TongDiem, DienGiaiDT*/
    
    create view thukhoa as
    select *
    from danhsachdau
    where tongdiem = (select max(tongdiem) from danhsachdau);
    
    /*Tạo thủ tục có đầu vào là số báo danh, đầu ra là các điểm thi, điểm ưu tiên và tổng điểm*/
    
    delimiter //
    create procedure searchBySBD (in sbd int)
    begin
		select kq.toan,kq.van,kq.anhvan, c.diemUT, kq.tongdiem
        from ketqua kq join chitietdt c 
        on kq.dtDuThi = c.dtDuThi
        where kq.soBD = sbd ;
        end //
        delimiter ;
        call searchBySBD(6);