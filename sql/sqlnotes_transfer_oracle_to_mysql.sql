--#################################################################################################################################################
--USEFUL QUERY ON STK TABLES
select 
tkr, 
s.seq, --sma1.seq, sma2.seq, 
--to_char(tkr_date, 'yyyy-mm-dd') ||chr(9)|| open ||chr(9)|| high ||chr(9)|| low ||chr(9)||close ||chr(9)||vol ||chr(9)|| chr(9)
to_char(tkr_date, 'yyyy-mm-dd') tkr_date, 
open, high, low, close, vol,
sma1.sma_val sma1, 
sma2.sma_val sma2
from 
    stk s, 
   (select * from ind_sma where sma_range=10) sma1,
   (select * from ind_sma where sma_range=40) sma2
where s.stk_id=sma1.stk_id and s.stk_id=sma2.stk_id 
order by tkr_date;

--extract data CSV files for charting.
select to_char(tkr_date, 'yyyy-mm-dd') tkr_date, open, high, low, close, vol/1000 vol
from stk where tkr='MSFT' 
--and to_char(tkr_date, 'yyyy') > 2015
ORDER BY SEQ

--#################################################################################################################################################
--AHMAD APIS


testing_stk_trading.get_pending_action(
    p_in_event_id =>p_in_event_id,
    p_in_exch  =>p_in_exch,
    p_in_tkr   =>p_in_tkr,
    p_in_price =>p_in_price,
    p_out_event_id =>p_out_event_id,
    p_out_exch =>p_out_exch,
    p_out_tkr  =>p_out_tkr,
    p_out_trade_type =>p_out_trade_type,
    p_out_share =>p_out_share,
    p_out_price =>p_out_price,
    p_out_action =>p_out_action
);


declare
p_in_event_id number;
p_in_exch  varchar2(30);
p_in_tkr   varchar2(30);
p_in_price number;
p_out_event_id number;
p_out_exch varchar2(30);
p_out_tkr  varchar2(30);
p_out_trade_type varchar2(30);
p_out_share number;
p_out_price number;
p_out_action varchar2(30);
begin
dbms_output.put_line('aa1');
testing_stk_trading.get_pending_action(
    p_in_event_id =>p_in_event_id,
    p_in_exch  =>p_in_exch,
    p_in_tkr   =>p_in_tkr,
    p_in_price =>p_in_price,
    p_out_event_id =>p_out_event_id,
    p_out_exch =>p_out_exch,
    p_out_tkr  =>p_out_tkr,
    p_out_trade_type =>p_out_trade_type,
    p_out_share =>p_out_share,
    p_out_price =>p_out_price,
    p_out_action =>p_out_action
);
dbms_output.put_line(p_out_exch ||'*'|| p_out_trade_type || '*' ||p_out_share ||'*' || p_out_price ||'*' || p_out_action);
dbms_output.put_line('aa2');
exception when others then 
    dbms_output.put_line(sqlerrm);
end;
/



--#################################################################################################################################################
--MYSQL CREATE TABLES

create database stkdb;

/*
drop table andrew_table;
create table andrew_table(x int, y varchar(100));
insert into andrew_table values (10, 'MYSQL : andrew_table in STKDB schema');
select * from andrew_table;
*/

select * from stk;
select * from stk_event;

----------------------------------------------

show tables;

CREATE TABLE STK
(
  STK_ID    INT,
  EXCH      VARCHAR(10),
  TKR       VARCHAR(10),
  PER       VARCHAR(3),
  TKR_DATE  VARCHAR(10),
  OPEN      float,
  HIGH      float,
  LOW       float,
  CLOSE     float,
  VOL       float,
  SEQ       INT
);

CREATE TABLE STK_EVENT
(
  EVENT_ID    int,
  STK_ID      int,
  EVENT_TYPE  VARCHAR(30),
  INVALID     VARCHAR(3)
);


CREATE TABLE STK_TRADE
(
  STK_TRADE_ID        INT,
  EVENT_ID            INT,
  EXCH                VARCHAR(30),
  TKR                 VARCHAR(30),
  PER                 VARCHAR(3),
  TRADE_TYPE          VARCHAR(20),
  TRADE_STATUS        VARCHAR(20),
  SHARES              INT,
  BOT_PRICE           INT,
  BOT_DATE            DATE,
  BOT_AMT             INT,
  SOLD_PRICE          INT,
  SOLD_DATE           DATE,
  SOLD_AMT            INT,
  TARGET_EXIT_TYPE    VARCHAR(30),
  TARGET_EXIT_PARAM   INT,
  STOP_EXIT_TYPE      VARCHAR(30),
  STOP_EXIT_PARAM     INT,
  GAIN_LOSS_AMT       INT,
  GAIN_LOSS_PERCENT   INT,
  NOTES               VARCHAR(300),
  CREATE_DATE         VARCHAR(10),
  LOSS_THRESHOLD_AMT  INT,
  GAIN_THRESHOLD_AMT  INT,
  CREATE_DATE_PRICE   INT,
  BOT_PENDING_DATE    DATE,
  FIRST_DATE_CHECK    DATE,
  LAST_DATE_CHECK     DATE,
  STK_ID              INT
);

CREATE TABLE IND_BOLL_BANDS
(
  STK_ID       INT,
  IND_RANGE    INT,
  MIDDLE_BAND  INT,
  UPPER_BAND   INT,
  LOWER_BAND   INT
);



--#################################################################################################################################################
--GENERATE INSERT STATEMENTS FOR MYSQL

CREATE TABLE MYSQL_INSERT (table_name varchar2(30), seq number, insert_str varchar2(4000)); 

select * from stk where stk_id in (104, 1059) order by stk_id;
select count(*), count(exch), count(tkr), count(per), count(tkr_date), count(open), count(high), count(low), count(close), count(vol), count(seq) from stk;


--------------PLSQL-------------------


select INSERT_STR from mysql_insert
WHERE 1=1
AND table_name='STK';



declare
/*
cursor c0 is
    select stk_id from stk
    where TKR='MSFT'
    order by stk_id;
*/
cursor c0 is
    select stk_id from stk_event e
    where exists (select 1 from stk s where s.stk_id=e.stk_id and tkr='MSFT')
    order by stk_id;
cursor c1(c_tab_name varchar2) is
    select * from user_tab_columns where table_name=c_tab_name order by column_id;
v_tab_name varchar2(1000);
v_column_name varchar2(100);
v_insert_str varchar2(8000);
v_sql varchar2(4000);
v_value varchar2(500);
v_cnt number;
v_seq number;
begin
/*
delete from mysql_insert where table_name='STK';
v_tab_name :='STK';
*/
delete from mysql_insert where table_name='STK_EVENT';
v_tab_name :='STK_EVENT';
v_seq :=0;
--==========================================================================================================
--List out column names in insert statement
for r0 in c0 loop
    v_seq :=v_seq +1;
    v_insert_str :='insert into ' || v_tab_name || ' (';
    v_cnt :=0;
    for r1 in c1(v_tab_name) loop
        ---------------------------------------------
        --add comma to separate data vlues
        if v_cnt>0 then
            v_insert_str := v_insert_str || ',';
        end if;
        v_insert_str :=v_insert_str || r1.column_name;
        v_cnt := v_cnt +1;
    end loop;
    v_insert_str :=v_insert_str || ')';
    --==========================================================================================================
    v_insert_str :=v_insert_str || ' values (';
    v_cnt :=0;
    for r1 in c1(v_tab_name) loop
        ---------------------------------------------
        --add comma to separate data vlues
        if v_cnt>0 then
            v_insert_str := v_insert_str || ',';
        end if;
        ---------------------------------------------
        --prepare sql query to get the single data value from that 1 column name
        if r1.data_type='DATE' then
            v_column_name := 'to_char(' || r1.column_name || ',' ||'''yyyy-mm-dd'')';
        else
            v_column_name :=r1.column_name;
        end if;
        v_sql :='select ' || v_column_name || ' from ' || v_tab_name || ' where  stk_id=' || r0.stk_id;
        --dbms_output.put_line(v_sql);
        ---------------------------------------------
        --get the data value and format accordingly for insert statement
        execute immediate v_sql into v_value;
        if r1.data_type='VARCHAR2' then
            v_value := '''' || v_value || '''';
        /*
        -- for Oracle date inserts
        elsif r1.data_type='DATE' then -- only for inserts into Oracle DB
            v_value := 'to_date(''' || v_value || ''')';
         */
        -- for MySQL date inserts
        elsif r1.data_type='DATE' then -- only for inserts into Oracle DB
            v_value := '''' || v_value || '''';
        else
            null; -- do nothing
        end if;
        --dbms_output.put_line(v_value);
        v_insert_str :=v_insert_str || v_value;
        v_cnt := v_cnt +1;
    end loop;
    v_insert_str :=v_insert_str || ');';
    --dbms_output.put_line(v_insert_str);
    insert into mysql_insert(table_name, seq, insert_str) values(v_tab_name, v_seq, v_insert_str);
end loop;
commit;
exception when others then
    dbms_output.put_line(sqlerrm);
end;




