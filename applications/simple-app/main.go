package main

import (
	"log"
	"math/rand"
	"net/http"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

// Define a histogram metric for request latencies on this server.
var requestLatency = prometheus.NewHistogramVec(
	prometheus.HistogramOpts{
		Name:    "http_server_requests_seconds",
		Help:    "A histogram of latencies for HTTP requests in seconds.",
		Buckets: prometheus.LinearBuckets(0.01, 0.05, 20),
	},
	[]string{"path"},
)

// init registers the metrics with the Prometheus registry.
func init() {
	prometheus.MustRegister(requestLatency)
}

// simulateWork simulates a task that takes a random amount of time.
func simulateWork(path string) {
	start := time.Now()

	// Simulate work by sleeping for a random duration between 1ms and 500ms.
	sleepTime := time.Duration(rand.Intn(500)+1) * time.Millisecond
	time.Sleep(sleepTime)

	// Observe the duration in the histogram.
	duration := time.Since(start).Seconds()
	requestLatency.WithLabelValues(path).Observe(duration)

	log.Printf("Server: Request to %s took %.3fs", path, duration)
}

// homeHandler handles requests to the root path.
func homeHandler(w http.ResponseWriter, r *http.Request) {
	simulateWork("/home")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Hello from the server!"))
}

// aboutHandler handles requests to the about path.
func aboutHandler(w http.ResponseWriter, r *http.Request) {
	simulateWork("/about")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("This is a demo page."))
}

func main() {
	rand.Seed(time.Now().UnixNano())

	// Start metrics server on port 8081 in a goroutine
	go func() {
			metricsMux := http.NewServeMux()
			metricsMux.Handle("/metrics", promhttp.Handler())
			log.Println("Starting Prometheus metrics server on :8081...")
			log.Fatal(http.ListenAndServe(":8081", metricsMux))
	}()

	// Start main application server on port 8080
	appMux := http.NewServeMux()
	appMux.HandleFunc("/home", homeHandler)
	appMux.HandleFunc("/about", aboutHandler)

	log.Println("Starting application server on :8080...")
	log.Fatal(http.ListenAndServe(":8080", appMux))
}
