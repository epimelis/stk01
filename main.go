package main

import (
	"database/sql"
	"fmt"
	"html/template"
	"log"
	"net/http"

	"encoding/json"
	"strconv"

	_ "github.com/go-sql-driver/mysql"
)

type StkEvent struct {
	Stk_id     int
	Tkr        string
	Seq        int
	Tkr_date   string
	Event_id   int
	Event_type string
	Sma1_dir   string
	Sma2_dir   string
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
	Sma50    float32
	Sma200   float32
}

var db *sql.DB
var pageTemplate *template.Template
var zz int = 60

func init() {
	var err error
	db, err = sql.Open("mysql", "ayong:ayong@/anychart_db")
	//db, err =sql.Open("oci8", "stkappdev/stkappdev@localhost:1521/xe")
	if err != nil {
		panic(err)
	}
}

func GetStkEvents() (stkEvents []StkEvent, err error) {
	rows, err := db.Query("select stk_id, tkr, seq, tkr_date, event_id, event_type, sma1_dir, sma2_dir from ay_events order by seq")
	defer rows.Close()
	var (
		stk_id, seq, event_id                         int
		tkr, tkr_date, event_type, sma1_dir, sma2_dir string
		stk_events                                    []StkEvent
	)
	for rows.Next() {
		err = rows.Scan(&stk_id, &tkr, &seq, &tkr_date, &event_id, &event_type, &sma1_dir, &sma2_dir)
		stk_events = append(stk_events, StkEvent{stk_id, tkr, seq, tkr_date, event_id, event_type, sma1_dir, sma2_dir})
	}
	return stk_events, err

}
func GetChartData(tkr string, seq1 int, seq2 int) (stkRows []StkRow, err error) {
	rows, err := db.Query("select stk_id, tkr, seq, tkr_date, open, high, low, close, vol, sma50, sma200 from stk2 where tkr=? and seq between ? and ? order by seq", tkr, seq1, seq2)
	//rows, err :=db.Query("select stk_id, tkr, seq, tkr_date, open, high, low, close, vol, sma50, sma200 from stk2 where tkr=:1 and seq between :2 and :3 order by seq", tkr, seq1, seq2)
	defer rows.Close()
	var (
		stk_id, seq                                int
		open, high, low, close, vol, sma50, sma200 float32
		ticker, tkr_date                           string
	)
	for rows.Next() {
		err = rows.Scan(&stk_id, &ticker, &seq, &tkr_date, &open, &high, &low, &close, &vol, &sma50, &sma200)
		stkRows = append(stkRows, StkRow{stk_id, tkr, seq, tkr_date, open, high, low, close, vol, sma50, sma200})
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
	seq, err := strconv.Atoi(seqStr)
	seq1 := seq - zz
	seq2 := seq + zz
	fmt.Println(tkr)
	fmt.Println(seq)
	stkRows, err := GetChartData(tkr, seq1, seq2)

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
	tkr := vals.Get("tkr")
	seqStr := vals.Get("seq")
	drangeStr := vals.Get("drange")
	seq, _ := strconv.Atoi(seqStr)
	drange, _ := strconv.Atoi(drangeStr)
	//seq1 := seq-drange
	//seq2 := seq+drange
	fmt.Println(tkr)
	fmt.Println(seq)
	fmt.Println(drange)
	stkRows, err := GetChartData(tkr, seq-drange, seq+drange)

	if err != nil {
		fmt.Println("Error: Cannot stock charting data!")
		fmt.Println(err)
	} else {
		pageTemplate = template.Must(template.ParseFiles("templates/stk_chart.html"))

		//run this when it is not a template
		//pageTemplate.Execute(w, stkEvents)

		//when it is a template
		pageTemplate.ExecuteTemplate(w, "tpl_chart", stkRows)
	}
	fmt.Println("end show chart !!")
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
