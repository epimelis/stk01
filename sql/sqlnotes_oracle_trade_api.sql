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
