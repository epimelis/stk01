select s.stk_id, s.tkr, s.seq, s.close, s.tkr_date, e.event_id, e.event_type from stk s, stk_event e where s.stk_id=e.stk_id order by seq;