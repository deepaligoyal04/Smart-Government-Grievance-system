USE GrievanceDB;

INSERT INTO Departments (department_name, service_level_days) VALUES
('Electricity', 5),
('Water Supply', 4),
('Sanitation', 3),
('Road Maintenance', 10),
('Public Health', 7);

INSERT INTO Complaint_Categories (category_name, description) VALUES
('Power Outage', 'Unexpected interruption in electricity supply'),
('Water Leakage', 'Leakage in public water pipelines'),
('Garbage Collection', 'Missed or irregular waste collection'),
('Road Damage', 'Potholes or damaged public roads'),
('Street Lighting', 'Non-functional street lights'),
('Drainage', 'Blocked or overflowing drains'),
('Public Facility', 'Issue related to public facilities');

INSERT INTO Citizens (citizen_name, email, phone, city, registration_date) VALUES
('Aarav Sharma','aarav.sharma@example.com','9000000001','Delhi','2026-01-03'),
('Diya Verma','diya.verma@example.com','9000000002','Noida','2026-01-05'),
('Kabir Singh','kabir.singh@example.com','9000000003','Delhi','2026-01-07'),
('Anaya Gupta','anaya.gupta@example.com','9000000004','Ghaziabad','2026-01-09'),
('Vivaan Mehta','vivaan.mehta@example.com','9000000005','Delhi','2026-01-12'),
('Ishita Rao','ishita.rao@example.com','9000000006','Noida','2026-01-14'),
('Advik Jain','advik.jain@example.com','9000000007','Faridabad','2026-01-16'),
('Sara Khan','sara.khan@example.com','9000000008','Delhi','2026-01-18'),
('Reyansh Das','reyansh.das@example.com','9000000009','Ghaziabad','2026-01-20'),
('Myra Kapoor','myra.kapoor@example.com','9000000010','Noida','2026-01-22'),
('Arjun Malhotra','arjun.m@example.com','9000000011','Delhi','2026-01-24'),
('Aadhya Nair','aadhya.nair@example.com','9000000012','Faridabad','2026-01-26'),
('Krish Patel','krish.patel@example.com','9000000013','Delhi','2026-01-28'),
('Saanvi Bose','saanvi.bose@example.com','9000000014','Noida','2026-02-01'),
('Rudra Iyer','rudra.iyer@example.com','9000000015','Ghaziabad','2026-02-03');

INSERT INTO Officers (officer_name, department_id, email) VALUES
('Ankit Kumar',1,'ankit.kumar@example.gov.in'),
('Rohit Mehta',1,'rohit.mehta@example.gov.in'),
('Nisha Saini',2,'nisha.saini@example.gov.in'),
('Manoj Yadav',2,'manoj.yadav@example.gov.in'),
('Pooja Das',3,'pooja.das@example.gov.in'),
('Suresh Rawat',3,'suresh.rawat@example.gov.in'),
('Vikas Sharma',4,'vikas.sharma@example.gov.in'),
('Neelam Joshi',4,'neelam.joshi@example.gov.in'),
('Farah Ali',5,'farah.ali@example.gov.in'),
('Karan Gill',5,'karan.gill@example.gov.in');

INSERT INTO Complaints
(citizen_id, department_id, category_id, officer_id, complaint_title,
 complaint_description, priority, status, complaint_date, resolution_date)
VALUES
(1,1,1,1,'Frequent power cuts','Repeated power interruptions in the locality','High','Pending','2026-02-01 09:15:00',NULL),
(2,2,2,3,'Pipeline leakage','Water leaking near the main road','Critical','Resolved','2026-02-02 10:00:00','2026-02-03 14:00:00'),
(3,3,3,5,'Garbage not collected','Waste collection missed for two days','Medium','In Progress','2026-02-03 08:30:00',NULL),
(4,4,4,7,'Large pothole','Pothole causing traffic disruption','High','Pending','2026-02-04 11:20:00',NULL),
(5,1,5,2,'Street light failure','Street lights not working in the lane','Low','Resolved','2026-02-05 19:00:00','2026-02-08 12:00:00'),
(6,2,6,4,'Blocked drainage','Drain overflowing after rainfall','Critical','In Progress','2026-02-06 07:45:00',NULL),
(7,5,7,9,'Public clinic maintenance','Waiting area requires maintenance','Low','Pending','2026-02-07 12:10:00',NULL),
(8,1,1,1,'Voltage fluctuation','Voltage fluctuating during evening hours','High','Resolved','2026-02-08 18:10:00','2026-02-10 16:30:00'),
(9,3,3,6,'Missed waste pickup','Garbage collection vehicle did not arrive','Medium','Pending','2026-02-09 08:00:00',NULL),
(10,4,4,8,'Damaged footpath','Footpath tiles are broken','Low','Resolved','2026-02-10 09:00:00','2026-02-15 11:00:00'),
(11,2,2,3,'Low water pressure','Water pressure is low in the morning','Medium','In Progress','2026-02-11 06:30:00',NULL),
(12,5,7,10,'Clinic sanitation','Sanitation issue at local clinic','High','Resolved','2026-02-12 13:00:00','2026-02-14 15:00:00'),
(13,1,5,2,'Street light damaged','Street light pole is not functioning','Medium','Pending','2026-02-13 20:00:00',NULL),
(14,3,3,5,'Overflowing community bin','Community bin is overflowing','High','Resolved','2026-02-14 08:15:00','2026-02-15 09:00:00'),
(15,4,4,7,'Road surface damage','Road surface damaged after construction','Critical','In Progress','2026-02-15 10:30:00',NULL),
(1,2,6,4,'Drain blockage','Drain blockage near residential area','High','Pending','2026-02-16 07:00:00',NULL),
(2,1,1,1,'Power interruption','Unexpected power interruption','Medium','Resolved','2026-02-17 17:00:00','2026-02-19 10:00:00'),
(3,5,7,9,'Public facility issue','Broken water tap at public facility','Low','Rejected','2026-02-18 14:00:00',NULL),
(4,3,3,6,'Irregular waste collection','Waste not collected on scheduled day','Medium','In Progress','2026-02-19 08:20:00',NULL),
(5,4,4,8,'Road repair request','Road needs resurfacing','High','Pending','2026-02-20 09:40:00',NULL),
(6,1,5,2,'Dark street','Street light not operational','High','Resolved','2026-02-21 19:10:00','2026-02-22 21:00:00'),
(7,2,2,3,'Water leakage near school','Leakage reported near school entrance','Critical','Pending','2026-02-22 11:00:00',NULL),
(8,5,7,10,'Health centre cleanliness','Cleanliness issue in health centre','Medium','In Progress','2026-02-23 12:00:00',NULL),
(9,3,3,5,'Garbage pile','Garbage pile near market','High','Resolved','2026-02-24 07:30:00','2026-02-25 08:00:00'),
(10,4,4,7,'Pothole complaint','Pothole near bus stop','Critical','Pending','2026-02-25 16:00:00',NULL),
(11,1,1,1,'Power outage','Power outage during working hours','High','In Progress','2026-02-26 13:00:00',NULL),
(12,2,6,4,'Drain overflow','Drain overflow after rain','Medium','Resolved','2026-02-27 08:00:00','2026-03-01 09:00:00'),
(13,3,3,6,'Waste pickup delay','Collection delayed repeatedly','Low','Pending','2026-03-01 08:00:00',NULL),
(14,4,4,8,'Damaged road divider','Road divider needs repair','Medium','Resolved','2026-03-02 10:00:00','2026-03-05 14:00:00'),
(15,5,7,9,'Clinic facility request','Public clinic facility needs attention','Medium','Pending','2026-03-03 12:00:00',NULL);

INSERT INTO Feedback (complaint_id, rating, comments) VALUES
(2,5,'Issue resolved quickly'),
(5,4,'Satisfied with the resolution'),
(8,4,'Service was helpful'),
(10,3,'Resolution took some time'),
(12,5,'Good response'),
(14,4,'Clean-up completed'),
(17,4,'Power restored'),
(21,5,'Street light repaired'),
(24,4,'Waste removed'),
(27,3,'Drain cleared');
