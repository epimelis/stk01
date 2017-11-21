package main

import (
	"encoding/json"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"database/sql"
	_ "github.com/go-sql-driver/mysql"
	"strconv"
)


type Stk_Serie struct {
//	Id int
//	Seq int
	TkrDate string
	Open float32
	High float32
	Low float32
	Close float32
	//Vol float32
	SMA_50 float32
	SMA_200 float32
}
type Stk_Event struct {
	Stk_id int
	Tkr string
	Seq int
	Tkr_date string
	Event_id int
	Event_type string
	Sma1_dir string
	Sma2_dir string
}
var db *sql.DB

func handler(w http.ResponseWriter, r *http.Request) {
	t, err := template.ParseFiles("templates/page.html")
	if err != nil {
		panic(err)
	}
	t.Execute(w, nil)
}


func handlerJsonStk(res http.ResponseWriter, req *http.Request) {

	res.Header().Set("Access-Control-Allow-Origin", "*")
	stk_series := getStks()
	// decode chart data to JSON
	data_json, err := json.Marshal(stk_series)

	if err != nil {
		http.Error(res, err.Error(), 500)
		return
	}

	//res.Header().Set("Content-Type", "application/json; charset=utf-8")
	res.Header().Set("Content-Type", "application/json")
	res.Write(data_json)

	fmt.Println("ss0 : db series")
	fmt.Println(stk_series)
	fmt.Println("ss1 : data_json")
	fmt.Println(data_json)
	fmt.Println("ss2 : string(data_json)")
	fmt.Println(string(data_json))
	fmt.Println("ss3")

}

func handlerJsonEvents(res http.ResponseWriter, req *http.Request) {

	res.Header().Set("Access-Control-Allow-Origin", "*")
	stk_events := getEvents()
	data_json, err := json.Marshal(stk_events)
	if err != nil {
		http.Error(res, err.Error(), 500)
		return
	}

	//res.Header().Set("Content-Type", "application/json; charset=utf-8")
	res.Header().Set("Content-Type", "application/json")
	res.Write(data_json)


	fmt.Println("ss0 : db series")
	fmt.Println(stk_events)
	fmt.Println("ss1 : data_json")
	fmt.Println(data_json)
	fmt.Println("ss2 : string(data_json)")
	fmt.Println(string(data_json))
	fmt.Println("ss3")


}


// init db and page template
func init() {
	//pageTemplate = template.Must(template.ParseFiles("templates/index.html"))
	var err error
	db, err = sql.Open("mysql", "ayong:ayong@/anychart_db")
	if err != nil {
		panic(err)
	}
}


// get stk events  from database
func getEvents() []Stk_Event{

	res, err := db.Query("select stk_id, tkr, seq, tkr_date, event_id, event_type, sma1_dir, sma2_dir from ay_events order by seq")

	if err != nil {
		panic(err)
	}
	defer res.Close()
	var (
		//id, seq, VOL int
		stk_id, seq, event_id int
		tkr, tkr_date, event_type, sma1_dir, sma2_dir string
		stk_events    []Stk_Event
	)
	for res.Next() {
		fmt.Println("aa1")
		err = res.Scan(&stk_id, &tkr, &seq, &tkr_date, &event_id, &event_type, &sma1_dir, &sma2_dir)

		if err != nil {
			panic(err)
		}
		fmt.Println(stk_id)
		fmt.Println("aa2 : " + strconv.Itoa(stk_id) + tkr)
		stk_events = append(stk_events, Stk_Event{stk_id, tkr, seq, tkr_date, event_id, event_type, sma1_dir, sma2_dir})

	}
	return stk_events
}

// get stk data from database
func getStks() []Stk_Serie {
	num0 :=304;
	num_range :=40
	num1 :=num0-num_range;
	num2 :=num0+num_range;
	res, err := db.Query("SELECT tkr_date, open, high, low, close, round(sma_50,2) sma_50, round(sma_200,2) sma_200 FROM stk1 where tkr='MSFT' and seq between ? and ? order by SEQ", num1, num2)
	if err != nil {
		panic(err)
	}
	defer res.Close()
	var (
		//id, seq, VOL int
		tkrDate string
		open, high, low, close, sma_50, sma_200 float32
		stk_series    []Stk_Serie
	)
	for res.Next() {
		err = res.Scan(&tkrDate, &open, &high, &low, &close, &sma_50, &sma_200)
		if err != nil {
			panic(err)
		}
		stk_series = append(stk_series, Stk_Serie{tkrDate, open, high, low, close, sma_50, sma_200})
	}
	return stk_series
}



func main() {
	port := os.Getenv("WEB_SERVER_PORT")
	if port == "" {
		port = ":8000"
	}

	fmt.Printf("Listening on port %s!\n", port)
	http.HandleFunc("/", handler)
	http.HandleFunc("/get-json-stk", handlerJsonStk)
	http.HandleFunc("/get-json-events", handlerJsonEvents)

	fs := http.FileServer(http.Dir("charts"))
	http.Handle("/charts/", http.StripPrefix("/charts/", fs))

	err := http.ListenAndServe(port, nil)
	if err != nil {
		log.Fatal("ListenAndServe: ", err)
	}
}
