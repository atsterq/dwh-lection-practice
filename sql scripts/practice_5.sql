-- схема
create schema if not exists payments_and_loans;


-- таблица
create table payments_and_loans.payments (
    payment_id serial4,
    loan_id	int4,
	payment_date date,
    amount numeric,
	created_at timestamp,
	updated_at timestamp
) distributed randomly;


-- копирование через dblink
select * from pg_extension where extname = 'dblink';

create extension dblink;

insert into payments_and_loans.payments
select *
from dblink(
    'dbname=t1_dwh_potok3_datasandbox 
     host=host
     port=port 
     user=user 
     password=password',
    'SELECT payment_id,
    	loan_id,
		payment_date,
	    amount,
		created_at,
		updated_at
     FROM payments_and_loans.payments'
) as remote_table (
    payment_id int4,
    loan_id	int4,
	payment_date date,
    amount numeric,
	created_at timestamp,
	updated_at timestamp
);


-- payments_compressed_columnar тип сжатия RLE, уровень сжатия 4 и колоночный тип хранения
create table payments_and_loans.payments_compressed_columnar 
with (
    appendonly = true,
    orientation = 'column',
    compresstype = 'rle_type',
    compresslevel = 4
) as
select * from payments_and_loans.payments
distributed randomly;


-- payments_compressed_row тип сжатия ZTSD, уровень сжатия 7 и строчный тип хранения
create table payments_and_loans.payments_compressed_row
with (
    appendonly = true,
    orientation = 'row',
    compresslevel = 7,
    compresstype = 'zstd'
) as
select * from payments_and_loans.payments
distributed randomly;


-- сравнение
-- payments
explain analyze
select 
    loan_id,
    sum(amount) as total_amount,
    avg(amount) as avg_amount,
    max(payment_date) as last_payment,
    (select count(*) 
     from payments_and_loans.payments 
     where loan_id = p.loan_id and amount < 500) as small_payments_count
from 
    payments_and_loans.payments p
where 
    payment_date >= '2023-01-01'
    and amount > 1000
group by 
    loan_id
having 
    sum(amount) > 10000
order by 
    total_amount desc
limit 50;



-- payments_compressed_row
explain analyze
select 
    loan_id,
    sum(amount) as total_amount,
    avg(amount) as avg_amount,
    max(payment_date) as last_payment,
    (select count(*) 
     from payments_and_loans.payments_compressed_row 
     where loan_id = p.loan_id and amount < 500) as small_payments_count
from 
    payments_and_loans.payments_compressed_row p
where 
    payment_date >= '2023-01-01'
    and amount > 1000
group by 
    loan_id
having 
    sum(amount) > 10000
order by 
    total_amount desc
limit 50;


-- payments_compressed_columnar
explain analyze
select 
    loan_id,
    sum(amount) as total_amount,
    avg(amount) as avg_amount,
    max(payment_date) as last_payment,
    (select count(*) 
     from payments_and_loans.payments_compressed_columnar 
     where loan_id = p.loan_id and amount < 500) as small_payments_count
from 
    payments_and_loans.payments_compressed_columnar p
where 
    payment_date >= '2023-01-01'
    and amount > 1000
group by 
    loan_id
having 
    sum(amount) > 10000
order by 
    total_amount desc
limit 50;