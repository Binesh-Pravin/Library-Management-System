/*
Task 1: 
Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

-- issued_status == members == books == return_status
-- filter books which is return
-- overdue > 30

SELECT 
    m.member_id,
    m.member_name,
    b.book_title,
    i.issued_date,
    current_date - (i.issued_date + 30 ) AS days_overdue 
FROM 
	members AS m
JOIN 
	issue_status AS i 
ON 
	m.member_id = i.issued_member_id
JOIN 
	books AS b 
ON 
	b.isbn = i.issued_book_isbn
LEFT JOIN 
	return_status AS r 
ON 
	r.issued_id = i.issued_id
WHERE 
	r.return_id IS NULL
	and 
	(current_date - (i.issued_date + 30 )) >0;

/*    
Task 2: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/
-- checking for the book-status
select 
	* 
from 
	books
where 
	isbn = '978-0-375-41398-8';

-- checking for the book_issue_status
select 
	* 
from 
	public.issue_status
where 
	issued_book_isbn = '978-0-375-41398-8' ;

-- checking whether the book is returned or not
select 
	* 
from 
	return_status
where 
	issued_id = 'IS134';


create or replace procedure add_book_status(p_return_id varchar(20),p_issued_id varchar(20),
											p_book_quality varchar(15))
language plpgsql
as $$
declare 
	v_isbn varchar(50);
	v_book_name varchar(80);

Begin
	-- insert the records into return table
	insert into
		return_status(return_id,issued_id,return_date,book_quality)
	values
		(p_return_id,p_issued_id,current_date,p_book_quality);
		
	-- get the isbn of the returned book
	select
		issued_book_isbn,
		issued_book_name
	into
		v_isbn,
		v_book_name
	from 
		issue_status
	where
		issued_id = p_issued_id;

	-- update the book status
	update
		books
	set
		status = 'yes'
	where
		isbn = v_isbn; 
		
	raise notice 'Thank you for returning the book:%',v_book_name;

END;
$$;

call add_book_status('RS120','IS134','Good');

-- Testing
select 
	*
from
	books
where 
	isbn = '978-0-375-41398-8';

/*
Task 3: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/
select * from public.branch;
select * from public.issue_status;
select * from public.return_status;
select * from public.employee;
select * from public.books;

create table performance_report
as
select
	b.branch_id,
	b.manager_id,
	count(i.issued_id) as book_issued,
	count(r.return_id) as books_returned,
	sum(bo.rental_price) as total_revenue
from
	branch as b
join
	employee as e on e.branch_id = b.branch_id
join
	issue_status as i on i.issued_emp_id = e.emp_id
left join
	return_status as r on r.issued_id = i.issued_id
join
	books as bo on bo.isbn = i.issued_book_isbn
group by
	b.branch_id
order by
	1,2
;

select * from performance_report;

-- Task 4: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
select * from public.members;
select * from public.return_status;
select * from public.issue_status;

select 
	m.member_id,
	m.member_name
from 
	members as m
join
	issue_status as i on i.issued_member_id = m.member_id
left join
	return_status as r on r.issued_id = i.issued_id
where
	r.return_date between(current_date-interval '2 months')and current_date;

-- Task 5: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

select * from public.employee;
select * from public.issue_status;

select
	e.emp_id,
	e.emp_name,
	e.branch_id,
	count(i.issued_emp_id) as no_books_processed
from 
	employee as e
join
	issue_status as i on i.issued_emp_id = e.emp_id
group by
	1,2
order by 	
	4 desc;

/*
Task 6: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table.
Display the member name, book title, and the number of times they've issued damaged books.
*/

select * from public.books;
select * from public.issue_status;
select * from public.return_status;
select * from public.members;

select
	m.member_name,
	b.book_title,
	count(book_quality) as count
from 
	members as m
join
	issue_status as i on i.issued_member_id = m.member_id
join
	books as b on b.isbn = i.issued_book_isbn
join
	return_status as r on r.issued_id = i.issued_id
where
	r.book_quality = 'Damaged'
group by
	1,2
having
	count(book_quality) > 2;

/*
Task 7: Stored Procedure Objective: 

Create a stored procedure to manage the status of books in a library system. 

Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 

The procedure should function as follows: 

The stored procedure should take the book_id as an input parameter. 

The procedure should first check if the book is available (status = 'yes'). 

If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 

If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/
select * from public.books;
select * from public.issue_status;

create or replace procedure book_avail(p_issued_id varchar(20),p_issued_member_id varchar(20),
										p_issued_book_isbn varchar(20),p_issued_emp_id varchar(20))
language plpgsql
as
$$
Declare
	v_book_title varchar(100);
	v_status varchar(10);
Begin
	select 
		status,
		book_title
		into
		v_status,
		v_book_title
	from
		books
	where isbn = p_issued_book_isbn;

	If v_status = 'yes' then
		insert into issue_status (issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
		values (p_issued_id,p_issued_member_id,current_date,p_issued_book_isbn,p_issued_emp_id );

		update books
		set status = 'no'
		where isbn = p_issued_book_isbn;
		
		update issue_status
		set issued_book_name = v_book_title;

		Raise Notice 'Thank you for choosing this book:%',p_issued_book_isbn ;
	else
		Raise Notice 'Thanks for request.The enquired book is not availble now';
		
	End if;

END;
$$;
-- Calling the function
call book_avail('IS156','C107','978-0-14-044930-3','E108');
call book_avail('IS158','C107','978-0-141-44171-6','E108');

-- Checking the availability after issued
select * from public.books
where isbn = '978-0-14-044930-3';

-- checking the record inserted or not
select * from public.issue_status
where issued_id = 'IS156' ;

/*Task 8: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table 
		that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines
*/

select * from public.books;
select * from public.issue_status;
select * from public.members;
select * from public.return_status;


Create Table fine_table 
As
SELECT 
    m.member_id,
    m.member_name,
    COUNT(r.return_id) AS no_of_overdue_books,
    SUM(GREATEST(0, EXTRACT(DAY FROM (r.return_date - (i.issued_date + INTERVAL '30 days')))) * 0.5) AS fine_amount
FROM 
    members AS m
JOIN
    issue_status AS i ON i.issued_member_id = m.member_id
JOIN
    return_status AS r ON r.issued_id = i.issued_id
JOIN
    books AS b ON b.isbn = i.issued_book_isbn
where
	return_date-(issued_date+30) > 0
	
GROUP BY 
    m.member_id,
    m.member_name
ORDER BY
    m.member_id;
	
select * from fine_table;

