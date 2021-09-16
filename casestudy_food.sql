create table food(fid int auto_increment,fname varchar(20),fprice float(10,2),fcategory varchar(20),fquantity int,primary key(fid));
desc food;

create table customer(cid int auto_increment,cname varchar(20),cmobile bigint,cemail varchar(50),caddress varchar(200),cregistertime datetime,
primary key(cid));
desc customer;

create table cart(cartid int auto_increment,fid int,cid int,quantity int,PricePerProduct float(10,2),primary key(cartid),
foreign key(fid) references food(fid), foreign key(cid) references customer(cid));
desc cart;
drop table cart;

create table orders(oid int auto_increment,cartid int,cid int,orderdate datetime,totalamount float(10,2), primary key(oid),
foreign key(cid) references customer(cid));
desc orders;
drop table orders;

select * from food;

insert into food(fname,fprice,fcategory,fquantity) values('chapatti',25,'veg',150); 
insert into food(fname,fprice,fcategory,fquantity) values('idli',13,'veg',78); 
insert into food(fname,fprice,fcategory,fquantity) values('dosa',60,'veg',25); 
insert into food(fname,fprice,fcategory,fquantity) values('chicken_biriyani',150,'nonveg',20); 
insert into food(fname,fprice,fcategory,fquantity) values('palak_paneer',130,'veg',10); 
insert into food(fname,fprice,fcategory,fquantity) values('icecream',45,'veg',45); 
insert into food(fname,fprice,fcategory,fquantity) values('fish_curry',190,'nonveg',15); 
insert into food(fname,fprice,fcategory,fquantity) values('pizza',99,'nonveg',10); 
insert into food(fname,fprice,fcategory,fquantity) values('burger',78,'veg',15); 
insert into food(fname,fprice,fcategory,fquantity) values('chicken_lollipop',130,'nonveg',75); 

desc customer;
select * from customer;
select * from food;
desc orders;




insert into customer(cname,cmobile,cemail,caddress,cregistertime) values('rajan',9998887776,'rajan@gmail.com','Grant Road',now());
insert into customer(cname,cmobile,cemail,caddress,cregistertime) values('agnel',9595671297,'agnel@gmail.com','Ram Nagar','2020-12-18 19:54:32');
insert into customer(cname,cmobile,cemail,caddress,cregistertime) values('thinesh',9969253589,'thinesh@gmail.com','Mangatram','2019-07-09 13:02:52');
insert into customer(cname,cmobile,cemail,caddress,cregistertime) values('stephen',9987382723,'ste@gmail.com','Tembi paga','2021-03-12 07:39:16');
insert into customer(cname,cmobile,cemail,caddress,cregistertime) values('lokesh',9545719356,'lokesh@gmail.com','bhandup west','2021-01-28 15:59:07');

insert into cart(fid,cid,quantity) values(2,5,6);//
delimiter //
alter table cart change priceperproduct TotalPricePerProduct float(10,2);//
desc cart;//
desc orders;//
select * from food;//
select * from cart;//
truncate cart;//

-- Quantity update and Price Trigger for cart
create trigger quantityprice
before insert on cart for each row
begin
declare totalquantity int;
declare cprice float(10,2);
select fquantity into totalquantity from food where fid=new.fid;
update food set fquantity=totalquantity-new.quantity where fid=new.fid;
select fprice into cprice from food where fid=new.fid;
set new.totalpriceperproduct=new.quantity*cprice;
end;//

-- Update cart quantity and price
create trigger updatecart
before update on cart for each row
begin
declare foodprice int;
select fprice into foodprice from food where fid=new.fid;
set new.totalpriceperproduct=foodprice*new.quantity;
if old.quantity>new.quantity then
update food set fquantity=fquantity+(old.quantity-new.quantity) where fid=new.fid;
else
update food set fquantity=fquantity-(new.quantity-old.quantity) where fid=new.fid;
end if;
end;//

-- Deleting food from cart and updating quantity in food
create trigger deleteFoodFromCart
before delete on cart for each row
begin
update food set fquantity=fquantity+old.quantity where fid=old.fid;
end;//

insert into orders(fid,cid) values(10,1);//
select * from orders;//
drop table orders//
truncate orders;//

-- Place orders
create trigger insertorders
before insert on orders for each row
begin
set new.totalamount=(select totalpriceperproduct from cart where cartid=new.cartid);
delete from cart where cartid=new.cartid;
end;//

drop trigger insertorders//

drop table orders//

insert into orders(cartid,cid,orderdate) values(5,2,now())//
select * from orders//
select * from cart//
select * from food//
insert into cart(fid,cid,quantity) values(1,2,5)//

create function bill(customerid int)
returns varchar(50) deterministic
begin
declare your_bill float(10,2);
declare customername varchar(20);
select sum(totalamount) into your_bill from orders group by cid having cid=customerid;
select cname into customername from customer where cid=customerid;
return concat('Hello ',customername,' your total bill is ',your_bill);
end;//


select bill(2);//

select * from customer//



