select count(*) from payments_and_loans.payments as p ;

begin;

insert into payments_and_loans.payments (payment_id, loan_id, payment_date, amount, created_at, updated_at) 
values 
	(230001, 111, '2024-11-11', 111, now(), now()),
	(230002, 222, '2024-11-11', 222, now(), now());

update payments_and_loans.payments 
set amount = 600.00, updated_at = now() 
where payment_id = 230001;

savepoint save1;

insert into payments_and_loans.payments (payment_id, loan_id, payment_date, amount, created_at, updated_at) 
values 
	(230003, 333, '2024-11-11', 333, 123, now());

rollback to savepoint save1;

insert into payments_and_loans.payments (payment_id, loan_id, payment_date, amount, created_at, updated_at) 
values 
	(230003, 333, '2024-11-11', 333, now(), now());

commit;