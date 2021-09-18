create database movie_tickets;

use movie_tickets;

-- Screen (screen_no PK)
create table screen(screen_no varchar(20) primary key);

insert into screen values('screen1');
insert into screen values('screen2');
insert into screen values('screen3');
insert into screen values('screen4');

select * from screen;
desc screen;

-- Movies (mid PK,mname,mlanguage,mrelease, isreleased)
create table movies(mid int,mname varchar(50),mlanguage varchar(20),mrelease date,isReleased varchar(20), primary key(mid));
alter table movies modify mid int auto_increment;
desc movies;

insert into movies(mname,mlanguage,mrelease,isreleased) values('SPIDERMAN NO WAY HOME','ENGLISH','2021-09-30','NOT RELEASED');
insert into movies(mname,mlanguage,mrelease,isreleased) values('WANDA VISION','ENGLISH','2021-04-12','RELEASED');
insert into movies(mname,mlanguage,mrelease,isreleased) values('FOREST GUMP','ENGLISH','2020-05-03','RELEASED');
insert into movies(mname,mlanguage,mrelease,isreleased) values('INTERSTELLAR','ENGLISH','2002-12-19','RELEASED');
insert into movies(mname,mlanguage,mrelease,isreleased) values('AVATAR 2','ENGLISH','2024-9-23','NOT RELEASED');
insert into movies(mname,mlanguage,mrelease,isreleased) values('SAW 5','ENGLISH','2012-1-15','RELEASED');
insert into movies(mname,mlanguage,mrelease,isreleased) values('TENET','ENGLISH','2020-09-12','RELEASED');
insert into movies(mname,mlanguage,mrelease,isreleased) values('HILLS HAVE EYES','ENGLISH','2014-5-31','RELEASED');
insert into movies(mname,mlanguage,mrelease,isreleased) values('PRISON BREAK MOVIE','ENGLISH','2006-2-2','RELEASED');

select * from customer;

use movie_tickets;

-- customer (cid,cname,cwallet)
create table customer(cid int auto_increment,cname varchar(30),cregisteredDate date,cwallet float(10,2),primary key(cid));
insert into customer(cname,cregisteredDate,cwallet) values('thinesh','2019-8-19',1400);
insert into customer(cname,cregisteredDate,cwallet) values('stephen','2017-2-20',2000);
insert into customer(cname,cregisteredDate,cwallet) values('lokesh','2012-12-4',1000);
insert into customer(cname,cregisteredDate,cwallet) values('divya','2021-4-23',2500);
insert into customer(cname,cregisteredDate,cwallet) values('raksha','2018-5-2',900);
select * from customer;

-- bookings (bookingID PK,cid PK,tid PK,mname,screen PK)
create table booking(bookingid int auto_increment,cid int,cname varchar(30), tid int, mname varchar(50), screen_no varchar(10),tickets int,cost float(10,2),
primary key(bookingid),
foreign key(cid) references customer(cid) on delete cascade,
foreign key(tid) references on_theatres(tid) on delete cascade,
foreign key(screen_no) references screen(screen_no) on delete cascade);
select * from booking;
show tables;
drop table booking;//

-- on_Theatres (tid PK,mid FK, screen FK, mprice,availableTickets)
create table on_theatres(tid int auto_increment,mid int,screen varchar(10),mprice float(10,2),availableTickets int,
primary key(tid), foreign key(mid) references movies(mid) on delete cascade);
alter table on_theatres add column movieName varchar(40) after mid;
select * from on_theatres;
insert into on_theatres(mid,screen,mprice,availabletickets) values(7,'screen2',170,60);
insert into on_theatres(mid,screen,mprice,availabletickets) values(2,'screen1',90,40);

delimiter //
-- Trigger to set movie name in On_theatres
create trigger setMovieName
before insert on on_theatres for each row
begin
declare movie_name varchar(40);
select mname into movie_name from movies where mid=new.mid;
set new.movieName=movie_name;
end;//

-- Book the Movie ticket and perform operations on Customer (wallet price deducted)
create trigger bookmyshow
before insert on booking for each row
begin
declare movieid int;
declare movie_Name varchar(20);
declare screenno varchar(20);
declare movieprice float(10,2);
declare customername varchar(30);
declare availtickets int;
declare customerwallet float(10,2);
declare totalprice float(10,2);
select  mid into movieid from on_theatres where tid=new.tid;
select cname into customername from customer where cid=new.cid;
select moviename into movie_name from on_theatres where tid=new.tid;
select screen into screenno from on_theatres where tid=new.tid;
select mprice into movieprice from on_theatres where tid=new.tid;
select availabletickets into availtickets from on_theatres where tid=new.tid;
select cwallet into customerwallet from customer where cid=new.cid;
set totalprice=(movieprice*new.tickets);
if availtickets<new.tickets then signal sqlstate '45000' set message_text= 'No more tickets available';
elseif totalprice>customerwallet then signal sqlstate '45000' set message_text='You have no balance to book this movie';
else
set new.mname=movie_name;
set new.cname=customername;
set new.screen_no=screenno;
set new.cost=(movieprice*new.tickets);
update on_theatres set availableTickets=availableTickets-new.tickets where tid=new.tid;
update customer set cwallet=cwallet-(totalprice) where cid=new.cid;
end if;
end;//

drop trigger bookmyshow;//
-- set new.screen_no=(select screen from on_theatres where tid=new.tid); 

insert into booking(cid,tid,tickets) values(1,7,8);//
insert into booking(cid,tid,tickets) values(2,7,5);//
insert into booking(cid,tid) values(2,3);//

-- Customer wallet Fetcher
create procedure WalletAmount(in customerid int)
begin
declare customername varchar(20);
declare customerwallet float(10,2);
select cname into customername from customer where cid=customerid;
select cwallet into customerwallet from customer where cid=customerid;
select concat('Hello ',upper(customername),' your wallet balance is ',customerwallet,' Rs') as CUSTOMER_DETAIL;
end;//
drop procedure walletamount//
call walletamount(1);//


-- Cancel ticket with applied charges
create trigger cancelTicket
after delete on booking for each row
begin
-- Cancelling charges
update customer set cwallet=cwallet+(old.cost*10/100) where cid=old.cid;
update on_theatres set availableTickets=availabletickets+old.tickets where tid=old.tid;
end;//



-- Shows done
create table done_shows(doneid int primary key auto_increment,bid int,
cid int, tid int,moviename varchar(50),tickets int,cost float(10,2));//
drop table done_shows//

-- Flaw in show_completed trigger is... it is triggering another trigger(cancel ticket trigger) and paying back the money to customers and 
-- also updating seats in the on_theatre table.
create trigger show_completed
before insert on done_shows for each row
begin
declare thid int;
declare movienaming varchar(50);
declare ticket int;
declare costs float(10,2);
select tid into thid from booking where bookingid=new.bid;
set new.tid=thid;
select mname into movienaming from booking where bookingid=new.bid;
set new.moviename=movienaming;
select tickets into ticket from booking where bookingid=new.bid;
set new.tickets=ticket;
select cost into costs from booking where bookingid=new.bid;
set new.cost=costs;
delete from booking where bookingid=new.bid;
end;//

select * from on_theatres//

insert into booking(cid,tid,tickets) values(1,7,8);//
select * from booking;//
desc screen//
insert into on_theatres(mid,screen,mprice,availabletickets) values(8,'screen4',120,90);//
insert into on_theatres(mid,screen,mprice,availabletickets) values(4,'screen3',150,30);//