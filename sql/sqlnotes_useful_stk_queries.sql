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



