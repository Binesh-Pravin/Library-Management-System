-- Project 2 Library Management System
-- Creating tables

create table branch(branch_id varchar(10) primary key,
					manager_id varchar(10),
					branch_address varchar(55),
					contact_no varchar(20)
   					);
create table employee(emp_id varchar(20) primary key,
					  emp_name varchar(50),
					  position varchar(20),
					  salary int,
					  branch_id varchar(10),
					  foreign key (branch_id) references branch(branch_id)
					  );
					  
create table members(member_id varchar(20) primary key,
					 member_name varchar(50),
					 member_address varchar(50),
					 reg_date date
					 );
					 
create table books(isbn	varchar(50) primary key,
				   book_title varchar(50),
				   category varchar(20),
				   rental_price float,
				   status varchar(5),
				   author varchar(20),
				   publisher varchar(25)
				  );
alter table books
alter column category type varchar(100);

alter table books
alter column book_title type varchar(100);

alter table books
alter column author type varchar(100);

create table issue_status(issued_id varchar(20) primary key,
						  issued_member_id varchar(20),
						  issued_book_name varchar(200),
						  issued_date date,
						  issued_book_isbn varchar(20),
						  issued_emp_id varchar(20),
						  foreign key (issued_member_id) references members(member_id),
						  foreign key (issued_book_isbn) references books(isbn),
						  foreign key (issued_emp_id) references employee(emp_id)
						  );

create table return_status(return_id varchar(20),
						   issued_id varchar(20),
						   return_book_name varchar(50),
						   return_date date,
						   return_book_isbn varchar(10),
						   foreign key (return_book_isbn) references books(isbn)
						   );