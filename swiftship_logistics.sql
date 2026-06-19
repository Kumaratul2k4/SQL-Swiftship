-- Section 1
drop database if exists swiftship_database;
create database swiftship_database;
use swiftship_database;
show databases;

-- Table 1 (Partner Table)
create table Partner (
 p_id      int  auto_increment primary key,
 partner_name    varchar(100)  not null
);

-- Table 2 (Shipment Table)
create table Shipment (
 s_id      int                                                 auto_increment primary key,
 trk_no  varchar(100)                                        not null unique,
 p_id       int                                                 not null,
 Ordered_Date      date                                                not null, 
 Promised_date    date                                                not null,
 Destination_city varchar(100)                                        not null,
 Status           ENUM('In Transit', 'Delivered','Returned','Lost')   not null default 'In Transit',
 foreign key (p_id) references Partner (p_id) 
);

-- Table 3 (DeliveryLogs Table)
create table DeliveryLogs (
 log_id             int                      auto_increment primary key,
 s_id        int                                         not null,
 actual_delivery_date date                                               null,
 foreign key (s_id) references Shipment (s_id) 
);


-- Section 2
insert into Partner (partner_name) values 
( 'BlueDart'),
( 'DTDC'),
( 'DELHIVERY'),
( 'Ekart');

insert into Shipment ( trk_no, p_id, Ordered_date, Promised_date, Destination_city, Status ) values
-- Partner 1 (BlueDart)
('B_001', 1, '2026-03-20', '2026-03-25', 'Delhi', 'Delivered'),
('B_02', 1, '2026-03-22', '2026-03-27', 'Mumbai', 'Delivered'),
('B_003', 1, '2026-03-25', '2026-03-30', 'Delhi', 'Returned'),

-- Partner 2 (DTDC)
('DT_004', 2, '2026-03-21', '2026-03-26', 'Bangalore', 'Delivered'),
('DT_005', 2, '2026-03-24', '2026-03-29', 'Delhi', 'Delivered'),
('DT_006', 2, '2026-03-28', '2026-04-02', 'Mumbai', 'Delivered'),

-- Partner 3 (DELHIVERY)
('D_007', 3, '2026-03-20', '2026-03-24', 'Chennai', 'Delivered'),
('D_008', 3, '2026-03-23', '2026-03-28', 'Delhi', 'Returned'),
('D_009', 3, '2026-03-26', '2026-03-31', 'Delhi', 'Delivered'),

-- Partner 4 (Ekart)
('E_010', 4, '2026-03-27', '2026-04-01', 'Mumbai', 'Delivered'),
('E_011', 4, '2026-03-29', '2026-04-03', 'Delhi', 'Delivered'),
('E_012', 4, '2026-03-30', '2026-04-04', 'Bangalore', 'In Transit');

insert into DeliveryLogs (s_id, actual_delivery_date) values
-- BlueDart
(1, '2026-03-26'),  -- Late
(2, '2026-03-29'),  -- Late
(3, NULL),          -- Returned

-- DTDC
(4, '2026-03-25'),  -- On time
(5, '2026-03-30'),  -- Late
(6, '2026-04-01'),  -- On time

-- SpeedyLogistics
(7, '2026-03-23'),  -- On time
(8, NULL),          -- Returned
(9, '2026-04-02'),  -- Late

-- Ekart
(10, '2026-04-01'), -- On time
(11, '2026-04-05'), -- Late
(12, NULL);         -- In Transit

-- View Table
-- select * from Partner;
-- select * from Shipment;
-- select * from DeliveryLogs;

-- Section 3 Analytical Queries
-- Report 1 (DELAYED SHIPMENTS)

create table DelayedShipments as 
select
s.s_id as "Shipment ID",
s.trk_no as "Tracking No",
s. p_id as "Partner ID",
p.partner_name as "Partner name",
s.Ordered_date as "Ordered On",
s.Promised_date as "Promised By",
dl.actual_delivery_date as "Actual Delivered",
s.Destination_city as "Destination City",
Datediff(dl.actual_delivery_date , s.Promised_date) as "Days Late"
from Shipment as s
join Partner as p on s.p_id = p. p_id
join DeliveryLogs as dl on s.s_id = dl.s_id
where dl.actual_delivery_date is not null and dl.actual_delivery_date > s.Promised_date
order by `Days Late` DESC;
select * from DelayedShipments;

-- Report 2 (Partner Performance Table)
create table PartnerPerformance as
select
p.p_id as "Partner Id",
p.partner_name as "Partner Name",
count(s.s_id) as "Total Shipment",
sum(case When s.status = 'Delivered'  THEN 1 ELSE 0 END) as "Delivered",
sum(Case When s.status = 'Returned'   THEN 1 ELSE 0 END) as "Returned",
concat(
round(
sum(case When s.status = 'Delivered'  THEN 1 ELSE 0 END) * 100 / count(s.s_id)
),'%'
)                                                                                 as "Rate_of_Success",

dense_rank() over (
order by
concat(
round(
sum(case When s.status = 'Delivered'  THEN 1 ELSE 0 END) * 100 / count(s.s_id)
),'%' 
)
) as "Rank"
from Partner p 
join Shipment s on s.p_id = p.p_id
group by p.p_id
order by "Rank";
select * from PartnerPerformance;

-- Report 3 (Zone Filter)
create table ZoneFilter as
select 
count(s.s_id) as "Order (Last 30 Days)",
s.Destination_city as "Destination City"
from Shipment s
where s.Ordered_Date >= curdate()-interval 30 day
group by s.Destination_city
order by count(s.s_id) desc limit 1;

select * from ZoneFilter;

-- Report 4 (Partner ScoreCard)
create table Partnerscorecard as
select 
p.p_id as "Partner Id",
p.partner_name as "Partner Name",
count(s.s_id) as "Total Shipment",
SUM(CASE
        WHEN dl.actual_delivery_date IS NOT NULL
         AND dl.actual_delivery_date > s.Promised_date THEN 1
        ELSE 0
    END) 
                                                                       as "Delayed",
concat(
round(
SUM(CASE
        WHEN dl.actual_delivery_date IS NOT NULL
         AND dl.actual_delivery_date > s.Promised_date THEN 1
        ELSE 0
    END)    * 100 /            count(s.s_id)                                                                                                        
) , '%' 
) as "DelayRate", 
dense_rank() over(
order by
SUM(CASE
        WHEN dl.actual_delivery_date IS NOT NULL
         AND dl.actual_delivery_date > s.Promised_date THEN 1
        ELSE 0
    END)    * 100 /            count(s.s_id)                                                                                              
) as "Rank"
from Partner p
join Shipment s on p.p_id = s.p_id
join DeliveryLogs dl on dl.s_id = s.s_id
group by p.p_id;

select * from Partnerscorecard
where `Rank` = 1;

















