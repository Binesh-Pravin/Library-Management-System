select * from public.books;
select * from public.branch;
select * from public.employee;
select * from public.issue_status;
select * from public.members;
select * from public.return_status;

-- CRUD Operations

-- CREATE a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
insert into books (isbn,book_title,category,rental_price,status,author,publisher)
values('978-1-60129-456-2','To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

-- RETRIEVE All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issue_status
WHERE issued_emp_id = 'E101';

-- UPDATE an Existing Member's Address

UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
SELECT * FROM members;

-- DELETE a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issue_status table.

SELECT * FROM issue_status
WHERE issued_id = 'IS121';

DELETE FROM issue_status
WHERE issued_id = 'IS121';

-- CTAS
-- Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
create table
	summary
as
select
	i.issued_book_isbn,
	b.book_title,
	count(b.book_title) as count
from
	books as b
join
	issue_status as i
on
	i.issued_book_isbn = b.isbn
group by
	1,2
order by 
	3 desc;

select * from summary;

-- Data Analysis & Findings

-- Task 1: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

select 
	issued_emp_id,
	count(*) as issued_books
from 
	issue_status
group by
	1
having
	count(*)>1;

-- Task 2: Retrieve All Books in a Specific Category:
select
	* 
from 
	books
where 
	category = 'Literary Fiction';

-- Task 3: Find Total Rental Income by Category:
select
	category,
	sum(rental_price) as total_rental_price
from 
	books
group by
	1
order by 
	2 desc;

-- Task 4: List Members Who Registered in the Last 180 Days:
select
	* 
from 
	members
where
	reg_date 
	between
		(current_date - interval '180 Days') 
	    and 
		current_date;

-- Task 5: List Employees with Their Branch Manager's Name and their branch details:
select 
	a.emp_id,
	a.emp_name,
	c.emp_name as manager_name,
	b.branch_address,
	b.contact_no 
from 
	employee as a
join 
	branch as b
on 
	a.branch_id = b.branch_id
join 	
	employee as c
on 
	c.emp_id = b.manager_id
where 
	a.emp_id != b.manager_id;

-- Task 6: Create a Table of Books with Rental Price Above a Certain Threshold 7USD:
create table book_rental7
as
select
	*
from
	books
where
	rental_price > 7;
	
select 
	*
from
	book_rental7;
	
-- Task 7: Retrieve the List of Books Not Yet Returned

select 
	i.issued_id,
	i.issued_book_name
from 
	issue_status as i
left join 
	return_status as r
on 
	i.issued_id = r.issued_id
where 
	r.return_id is null;