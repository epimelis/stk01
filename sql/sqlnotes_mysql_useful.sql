create database stkdb;
drop table andrew_table;
create table andrew_table(x int, y varchar(100));

insert into andrew_table values (10, 'MYSQL : andrew_table in STKDB schema');
select * from andrew_table;

select * from stk;
select * from stk_event;

select s.stk_id, s.tkr, s.seq, s.tkr_date, e.event_id, e.event_type from stk s, stk_event e where s.stk_id=e.stk_id order by seq;

select stk_id, tkr, seq, tkr_date, open, high, low, close, vol/1000 from stk where tkr='MSFT' and seq between 10 and 20 order by seq;

select s.stk_id, s.tkr, s.seq, s.tkr_date, e.event_id, e.event_type from stk s, stk_event e where s.stk_id=e.stk_id order by seq;