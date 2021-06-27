/*BÀI TẬP ÔN TẬP SQL*/
/*Bài quản lý sản phẩm*/
use orderdetail;
/*6. In ra các số hóa đơn, trị giá hóa đơn bán ra trong ngày 19/6/2006 và ngày 20/6/2006.*/
select o.id,o.time,o.total from demo2006.order o
where o.time = '2006-6-19' or o.time = '2006-6-20';
/*7. In ra các số hóa đơn, trị giá hóa đơn trong tháng 6/2007, sắp xếp theo ngày (tăng dần) và trị giá của hóa đơn (giảm dần).*/
use demo2006;
select o.id,o.time, sum(price * orderdetail.quantity) as total	
from demo2006.order o ,product, orderdetail
where o.id = orderdetail.orderId and orderdetail.productId = product.id and  year(o.time) = 2006 and month(o.time) = 6
group by o.id;

/*8. In ra danh sách các khách hàng (MAKH, HOTEN) đã mua hàng trong ngày 19/07/2006.*/
select customer.id , customer.name from customer,demo2006.order 
where customer.id = demo2006.order.customerId and demo2006.order.time = '2006-07-19';
/*10. In ra danh sách các sản phẩm (MASP,TENSP) được khách hàng có tên "Nguyen Van A" mua trong tháng 10/2006.*/
select product.id , product.name 
from ((product join orderdetail on product.id = orderdetail.productId )
join demo2006.order on demo2006.order.id =  orderdetail.orderId and ((month(time) = 10) and (year(time) = 2006))
join customer on demo2006.order.customerId = customer.id and customer.name like "Nguyen Van A");
/*11. Tìm các số hóa đơn đã mua sản phẩm "Máy giặt" hoặc "Tủ lạnh".*/
select demo2006.order.id , product.name 
from product join orderdetail on product.id = orderdetail.productId  
join demo2006.order on demo2006.order.id = orderdetail.orderId
where product.name like "Máy giặt" or product.name like "Tủ lạnh";
/*12. Tìm các số hóa đơn đã mua sản phẩm "Máy giặt" hoặc "Tủ lạnh", mỗi sản phẩm mua với số lượng từ 10 đến 20.*/
select demo2006.order.id , product.name 
from product join orderdetail on product.id = orderdetail.productId  
join demo2006.order on demo2006.order.id = orderdetail.orderId
where product.name in ("Máy giặt","Tủ lạnh") and (orderdetail.quantity between 10 and 20);
/*13. Tìm các số hóa đơn mua cùng lúc 2 sản phẩm "Máy giặt" và "Tủ lạnh", mỗi sản phẩm mua với số lượng từ 10 đến 20.*/
create view MayGiat as
select o.id, p.name, o.time
from demo2006.order o 
join orderdetail od on o.id=od.orderid
join product p on od.productid=p.id
where p.name like 'Máy giặt'  and od.quantity between 10 and 20;

create view TuLanh as
select o.id, p.name, o.time
from demo2006.order o 
join orderdetail od on o.id=od.orderid
join product p on od.productid=p.id
where p.name like 'Tủ lạnh'  and od.quantity between 10 and 20;

select maygiat.id,maygiat.time,maygiat.name  from  maygiat join tulanh on maygiat.id = tulanh.id; 

/*15. In ra danh sách các sản phẩm (MASP,TENSP) không bán được.*/
select product.Id,product.name 
from product 
where product.id not in (select productId from orderdetail);
/*16. In ra danh sách các sản phẩm (MASP,TENSP) không bán được trong năm 2006.*/
select product.Id,product.name 
from product 
where product.id not in (select productId from orderdetail,demo2006.order
where orderdetail.productId = product.id and year(time) = 2006);

/*17. In ra danh sách các sản phẩm (MASP,TENSP) có giá >300 sản xuất bán được trong năm 2006.*/
select product.id,product.name,product.price from ((product join orderdetail on product.id = orderdetail.productId and product.price >300)
 join demo2006.order on demo2006.order.id = orderdetail.orderId and  year(time) = 2006);
/*18. Tìm số hóa đơn đã mua tất cả các sản phẩm có giá >200.*/
select orderId
from product,orderdetail
where product.id = orderdetail.productId
group by orderdetail.orderId
having min(product.price) > 200;

/*19. Tìm số hóa đơn trong năm 2006 đã mua tất cả các sản phẩm có giá <300.*/
select orderId
from product,orderdetail,demo2006.order
where product.id = orderdetail.productId and year(time) = 2006
group by orderdetail.orderId
having max(product.price) < 300;
/*21. Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006.*/
select count(product.id) as sanphamkhacnhau
from product
where product.id in (select orderdetail.productId from orderdetail, `order`
where orderdetail.orderId = `order`.id and year(time) = 2006); 
/*22. Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu?*/
create view total as
select o.id , sum(product.price * orderdetail.quantity) as total, o.time 
from demo2006.order o join orderdetail on o.id = orderdetail.orderId
join product on orderdetail.productId = product.id
group by o.id;
select max(total.total) as caonhat,min(total.total) as thapnhat
from total;
/*23. Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu?*/
select avg(total.total) as giatritb2006
from total
where year(time) = 2006;
/*24. Tính doanh thu bán hàng trong năm 2006.*/
select sum(total.total) as tongdoanhthu
from total
where year(time) = 2006;
/*25. Tìm số hóa đơn có trị giá cao nhất trong năm 2006.*/
select o.id , max(total.total) as caonhat
from demo2006.order o, total 
where year(total.time) = 2006;
/*26. Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006.*/
select c.name, o.id as mahoadon ,max(total.total) as caonhat
from customer c , demo2006.order o ,total
where o.id = total.id and c.id = o.customerId and year(total.time) = 2006 ;
/*27. In ra danh sách 3 khách hàng (MAKH, HOTEN) mua nhiều hàng nhất (tính theo số lượng).*/
select c.id,c.name, sum(od.quantity) as soluonglonnhat
from customer c join demo2006.order o on c.id = o.customerId
join orderdetail od on od.orderId = o.id
group by c.id
order by soluonglonnhat desc
limit 3;
/*28. In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao nhất.*/
create view top3p as
select price
from product
group by price order by price desc limit 3;
select * from top3p;
use demo2006;
select *
from product
where price in
(select * from top3p);
set @top3 =  (SELECT price
FROM product
GROUP BY price
ORDER BY price DESC
LIMIT 3,1);
set @top1 =  (SELECT price
FROM product
GROUP BY price
ORDER BY price DESC
LIMIT 1);
select * from product where price <= @top1 and price >= @top3;
/*29. In ra danh sách các sản phẩm (MASP, TENSP) có tên bắt đầu bằng chữ M, có giá bằng 1 trong 3 mức giá cao nhất (của tất cả các sản phẩm).*/
select * from product where price <= @top1 and price >= @top3
and product.name like 'M%';
/*32. Tính tổng số sản phẩm giá <300.*/

select count(product.price) as sosanpham
from product
where product.price < 300;

/*33. Tính tổng số sản phẩm theo từng giá.*/

select p.price , count(p.price) as sosanpham
from product p
group by p.price;
/*34. Tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm bắt đầu bằng chữ M.*/

select max(p.price) as caonhat , min(p.price) as thapnhat, avg(p.price)
from product p
where p.name like 'M%';

/*35. Tính doanh thu bán hàng mỗi ngày.*/

select sum(total.total) as doanhthumoingay , total.time
from total
group by total.time;

/*36. Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006.*/

select p.name,p.id, sum(od.quantity) as tongsoluong
from product p join orderdetail od on p.id = od.productId
join demo2006.order o on o.id = od.orderId 
where month(o.time) = 10 and year(o.time) = 2006
group by od.productId;

/*37. Tính doanh thu bán hàng của từng tháng trong năm 2006.*/

select sum(total.total) as doanhthuthang , month(total.time) as month
from total
where year(total.time) = 2006
group by month(total.time);
/*38. Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau.*/
select o.id 
from `order` o , orderdetail od
where o.id = od.orderId
group by o.id
having count(od.productId) >= 4;
/*39. Tìm hóa đơn có mua 3 sản phẩm có giá <300 (3 sản phẩm khác nhau).*/
create view spduoi300 as
select o.id, p.name, p.price
from demo2006.order o join demo2006.orderdetail od join demo2006.product p on od.productId = p.id and o.id = od.orderId
where p.price<300;
select spduoi300.id, count(spduoi300.id) as sosanphamduoi300
from spduoi300
group by spduoi300.id
having sosanphamduoi300>=3;

/*40. Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất.*/
create view solanmua as
select c.id, c.name, count(od.orderId) as soluong
from demo2006.customer c join demo2006.order o join demo2006.orderdetail od on c.id = o.customerId and o.id = od.orderId
group by c.id;
select solanmua.id, solanmua.name, solanmua.soluong
from solanmua
where solanmua.soluong = (select max(solanmua.soluong) from solanmua);
/*41. Tháng mấy trong năm 2006, doanh số bán hàng cao nhất?*/

select month(total.time)  from total where total = (select max(total) from total where year(total.time) = 2006);

/*42. Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006.*/
create view Soluongnam2006 as
select Sum(od.quantity) as totalsanpham,p.id,p.name
from product p join orderdetail od on p.id = od.productId
join `order` o on o.id = od.orderId where YEAR(time)=2006 group by od.productId;
select Soluongnam2006.id,Soluongnam2006.name,Min(Soluongnam2006.totalsanpham) as soluongnhonhat from Soluongnam2006;
/*45. Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều nhất.*/

create view doanhso as
select c.name, sum(p.price*od.quantity) as tong, count(od.orderId) as solanmua
from demo2006.customer c join demo2006.order o  join demo2006.orderdetail od join demo2006.product p on o.id = od.orderId and p.id = od.productId and o.customerId = c.id
group by o.customerId
order by tong desc
limit 10;
select *
from doanhso
where doanhso.solanmua = (select max(doanhso.solanmua) from doanhso);