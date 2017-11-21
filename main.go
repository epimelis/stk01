package main

import (
	"database/sql"
	"fmt"
	"html/template"
	"log"
	"net/http"

	_ "github.com/go-sql-driver/mysql"
	//_ "github.com/mattn/go-oci8"
	"encoding/json"
	"strconv"
)

type StkEvent struct {
	Stk_id     int
	Tkr        string
	Seq        int
	Close      float32
	Tkr_date   string
	Event_id   int
	Event_type string
}
type StkRow struct {
	Stk_id   int
	Tkr      string
	Seq      int
	Tkr_date string
	Open     float32
	High     float32
	Low      float32
	Close    float32
	Volume   float32
}

type StkTrade struct {
	Stk_Trade_Id       int
	Stk_Id             int
	Event_Id           int
	Exch               string
	Tkr                string
	Per                string
	Trade_Type         string
	Trade_Status       string
	Shares             float32
	Bot_Price          float32
	Bot_Date           string
	Bot_Amt            float32
	Sold_Price         float32
	Sold_Date          string
	Sold_Amt           float32
	Target_Exit_Type   string
	Target_Exit_Param  float32
	Stop_Exit_Type     string
	Stop_Exit_Param    float32
	Gain_Loss_Amt      float32
	Gain_Loss_Percent  float32
	Notes              string
	Create_Date        string
	Loss_Threshold_Amt float32
	Gain_Threshold_Amt float32
	Create_Date_Price  float32
	Bot_Pending_Date   string
	First_Date_Check   string
	Last_Date_Check    string
	Monitor_Start_Date string
	Trade_Action       string
	Event_Date         string
}

var db *sql.DB
var pageTemplate *template.Template

func init() {
	var err error
	db, err = sql.Open("mysql", "ayong:ayong@/stkdb")
	//db, err =sql.Open("oci8", "stkappdev/stkappdev@localhost:1521/xe")
	if err != nil {
		panic(err)
	}
}

func GetStkEvents() (stkEvents []StkEvent, err error) {
	rows, err := db.Query("select s.stk_id, s.tkr, s.seq, s.close, s.tkr_date, e.event_id, e.event_type from stk s, stk_event e where s.stk_id=e.stk_id order by seq")
	defer rows.Close()
	var (
		stk_id, seq, event_id     int
		close                     float32
		tkr, tkr_date, event_type string
		stk_events                []StkEvent
	)
	for rows.Next() {
		err = rows.Scan(&stk_id, &tkr, &seq, &close, &tkr_date, &event_id, &event_type)
		stk_events = append(stk_events, StkEvent{stk_id, tkr, seq, close, tkr_date, event_id, event_type})
	}
	return stk_events, err

}

func GetStkTrade(stk_id int) (stkTrade StkTrade, err error) {
	sql_str := "select STK_TRADE_ID,t.STK_ID, EVENT_ID,t.EXCH,t.TKR,t.PER,TRADE_TYPE,TRADE_STATUS,SHARES,BOT_PRICE,BOT_DATE,BOT_AMT,SOLD_PRICE,SOLD_DATE,SOLD_AMT,TARGET_EXIT_TYPE,TARGET_EXIT_PARAM,STOP_EXIT_TYPE,STOP_EXIT_PARAM,GAIN_LOSS_AMT,GAIN_LOSS_PERCENT,NOTES,CREATE_DATE,LOSS_THRESHOLD_AMT,GAIN_THRESHOLD_AMT,CREATE_DATE_PRICE,BOT_PENDING_DATE,FIRST_DATE_CHECK,LAST_DATE_CHECK,MONITOR_START_DATE,TRADE_ACTION, s.tkr_date from stk s, stk_trade t where s.stk_id=t.stk_id and t.stk_id=?"
	rows, err := db.Query(sql_str, stk_id)
	defer rows.Close()

	for rows.Next() {
		err = rows.Scan(
			&stkTrade.Stk_Trade_Id,
			&stkTrade.Stk_Id,
			&stkTrade.Event_Id,
			&stkTrade.Exch,
			&stkTrade.Tkr,
			&stkTrade.Per,
			&stkTrade.Trade_Type,
			&stkTrade.Trade_Status,
			&stkTrade.Shares,
			&stkTrade.Bot_Price,
			&stkTrade.Bot_Date,
			&stkTrade.Bot_Amt,
			&stkTrade.Sold_Price,
			&stkTrade.Sold_Date,
			&stkTrade.Sold_Amt,
			&stkTrade.Target_Exit_Type,
			&stkTrade.Target_Exit_Param,
			&stkTrade.Stop_Exit_Type,
			&stkTrade.Stop_Exit_Param,
			&stkTrade.Gain_Loss_Amt,
			&stkTrade.Gain_Loss_Percent,
			&stkTrade.Notes,
			&stkTrade.Create_Date,
			&stkTrade.Loss_Threshold_Amt,
			&stkTrade.Gain_Threshold_Amt,
			&stkTrade.Create_Date_Price,
			&stkTrade.Bot_Pending_Date,
			&stkTrade.First_Date_Check,
			&stkTrade.Last_Date_Check,
			&stkTrade.Monitor_Start_Date,
			&stkTrade.Trade_Action,
			&stkTrade.Event_Date)
	}
	return stkTrade, err

}

func GetChartData(tkr string, in_seq int, drange int) (stkRows []StkRow, err error) {
	seq1 := in_seq - drange
	seq2 := in_seq + drange
	rows, err := db.Query("select stk_id, tkr, seq, tkr_date, open, high, low, close, vol/1000 from stk where tkr=? and seq between ? and ? order by seq", tkr, seq1, seq2)
	defer rows.Close()
	var (
		stk_id, seq                 int
		open, high, low, close, vol float32
		ticker, tkr_date            string
	)
	for rows.Next() {
		err = rows.Scan(&stk_id, &ticker, &seq, &tkr_date, &open, &high, &low, &close, &vol)
		stkRows = append(stkRows, StkRow{stk_id, tkr, seq, tkr_date, open, high, low, close, vol})
	}
	return stkRows, err

}

func handleIndex(w http.ResponseWriter, r *http.Request) {
	tpl, err := template.ParseFiles("templates/index.html")
	if err != nil {
		panic(err)
	}
	tpl.Execute(w, nil)

}

func handlerJsonStk(w http.ResponseWriter, r *http.Request) {

	fmt.Println("inside handlerJsonStk!!")

	w.Header().Set("Access-Control-Allow-Origin", "*")

	vals := r.URL.Query()
	tkr := vals.Get("tkr")
	seqStr := vals.Get("seq")
	dRangeStr := vals.Get("drange")
	seq, err := strconv.Atoi(seqStr)
	drange, err := strconv.Atoi(dRangeStr)
	fmt.Println(tkr)
	fmt.Println("seq=", seq)
	stkRows, err := GetChartData(tkr, seq, drange)

	// decode chart data to JSON
	data_json, err := json.Marshal(stkRows)

	if err != nil {
		//http.Error(res, err.Error(), 500)
		fmt.Println("Error in handlerJsonStk")
		fmt.Println(err)
		return
	}

	//res.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.Header().Set("Content-Type", "application/json")
	w.Write(data_json)

	/*
		fmt.Println("ss0 : db series")
		fmt.Println(stkRows)
		fmt.Println("ss1 : data_json")
		fmt.Println(data_json)
		fmt.Println("ss2 : string(data_json)")
		fmt.Println(string(data_json))
		fmt.Println("ss3")
	*/

}

func handleListStkEvents(w http.ResponseWriter, r *http.Request) {
	fmt.Println("inside handleListStkEvents !!")

	stkEvents, err := GetStkEvents()

	if err != nil {
		//error_message(w, r, "Cannot get stock events")
		fmt.Println("Error: Cannot get stock events!!")
	} else {
		pageTemplate = template.Must(template.ParseFiles("templates/stk_events.html"))

		//run this when it is not a template
		//pageTemplate.Execute(w, stkEvents)

		//when it is a template
		pageTemplate.ExecuteTemplate(w, "tpl_events", stkEvents)
	}
	fmt.Println("end handleListStkEvents !!")

}
func handleChart(w http.ResponseWriter, r *http.Request) {
	fmt.Println("inside chart!!")
	vals := r.URL.Query()
	stk_id, err := strconv.Atoi(vals.Get("stk_id"))

	fmt.Println("inside func handleChart")
	/*
		pageTemplate = template.Must(template.ParseFiles("templates/stk_chart.html"))
		pageTemplate.ExecuteTemplate(w, "tpl_chart", nil)
	*/

	stkTrade, err := GetStkTrade(stk_id)
	if err != nil {
		fmt.Println("Error: Cannot get stk trade data!")
		fmt.Println(err)
	} else {
		pageTemplate = template.Must(template.ParseFiles("templates/stk_chart.html"))

		//run this when it is not a template
		//pageTemplate.Execute(w, stkEvents)
		//when it is a template, run this
		pageTemplate.ExecuteTemplate(w, "tpl_chart", stkTrade)
	}

	/*
		stkRows, err := GetChartData(tkr, seq, drange)
		if err != nil {
			fmt.Println("Error: Cannot stock charting data!")
			fmt.Println(err)
		} else {
			pageTemplate = template.Must(template.ParseFiles("templates/stk_chart.html"))

			//run this when it is not a template
			//pageTemplate.Execute(w, stkEvents)
			//when it is a template, run this
			pageTemplate.ExecuteTemplate(w, "tpl_chart", stkRows)
		}
	*/
}

func main() {

	port := ":80"

	//serve static files
	fs := http.FileServer(http.Dir("charts"))
	http.Handle("/charts/", http.StripPrefix("/charts/", fs))

	http.HandleFunc("/", handleIndex)

	http.HandleFunc("/list-stk-events", handleListStkEvents)
	http.HandleFunc("/chart", handleChart)
	http.HandleFunc("/get-json-stk", handlerJsonStk)

	fmt.Printf("Listening on port %s\n", port)
	err := http.ListenAndServe(port, nil)
	if err != nil {
		log.Fatal("ErrorListenAndServe", err)
	}
}
