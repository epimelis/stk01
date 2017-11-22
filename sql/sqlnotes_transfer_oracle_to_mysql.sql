--#################################################################################################################################################
--MYSQL CREATE TABLES - run in Mysql

create database stkdb;

show tables;


----------------------------------------------

--Generate create table/column statements in Oracle for Mysql
SELECT column_name || '     '
|| decode(data_type, 'NUMBER', 'FLOAT',
                     'DATE', 'VARCHAR(',
                     'VARCHAR2', 'VARCHAR('
        )
|| decode(data_type,
                    'DATE', data_length || ')',
                    'VARCHAR2', data_length || ')'
         )
|| ','
gen_mysql_columns
FROM ALL_TAB_COLUMNS
WHERE TABLE_NAME='STK_TRADE'
ORDER BY COLUMN_ID;

------------------------------------------------
--Create tables in mysql

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


create table stk_trade(
STK_TRADE_ID     INT,
EVENT_ID     INT,
EXCH     VARCHAR(100),
TKR     VARCHAR(100),
PER     VARCHAR(100),
TRADE_TYPE     VARCHAR(100),
TRADE_STATUS     VARCHAR(100),
SHARES     FLOAT,
BOT_PRICE     FLOAT,
BOT_DATE     VARCHAR(100),
BOT_AMT     FLOAT,
SOLD_PRICE     FLOAT,
SOLD_DATE     VARCHAR(100),
SOLD_AMT     FLOAT,
TARGET_EXIT_TYPE     VARCHAR(100),
TARGET_EXIT_PARAM     FLOAT,
STOP_EXIT_TYPE     VARCHAR(100),
STOP_EXIT_PARAM     FLOAT,
GAIN_LOSS_AMT     FLOAT,
GAIN_LOSS_PERCENT     FLOAT,
NOTES     VARCHAR(100),
CREATE_DATE     VARCHAR(100),
LOSS_THRESHOLD_AMT     FLOAT,
GAIN_THRESHOLD_AMT     FLOAT,
CREATE_DATE_PRICE     FLOAT,
BOT_PENDING_DATE     VARCHAR(100),
FIRST_DATE_CHECK     VARCHAR(100),
LAST_DATE_CHECK     VARCHAR(100),
STK_ID     INT,
MONITOR_START_DATE     VARCHAR(100),
TRADE_ACTION     VARCHAR(100)
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
--GENERATE INSERT STATEMENTS FOR MYSQL - run in Oracle

CREATE TABLE MYSQL_INSERT (table_name varchar2(30), seq number, insert_str varchar2(4000)); 

--------------PLSQL-------------------


select INSERT_STR from mysql_insert
WHERE 1=1
AND table_name='STK_EVENT'
ORDER BY SEQ;

-----------------------------------------------------------------------------------

declare
--------------need to handle stk, stk_event and stk_trade------------------------
/*
cursor c0 is
    select stk_id from stk
    where TKR='MSFT'
    order by stk_id;
v_tab_name varchar2(100) :='STK';
*/
--------------------------------------
/*
cursor c0 is
    select stk_id from stk_event e
    where exists (select 1 from stk s where s.stk_id=e.stk_id and tkr='MSFT')
    order by stk_id;
v_tab_name varchar2(100) :='STK_EVENT';
*/
--------------------------------------
cursor c0 is
    select stk_id from stk_trade e
    where exists (select 1 from stk s where s.stk_id=e.stk_id and tkr='MSFT')
    order by stk_id;
v_tab_name varchar2(100) :='STK_TRADE';
cursor c1(c_tab_name varchar2) is
    select * from user_tab_columns where table_name=c_tab_name order by column_id;
v_column_name varchar2(100);
v_insert_str varchar2(8000);
v_sql varchar2(4000);
v_value varchar2(500);
v_cnt number;
v_seq number;
begin
delete from mysql_insert where table_name=v_tab_name;
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





