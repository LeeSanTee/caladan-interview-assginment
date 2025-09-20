package main

import (
	"log"
	"net/http"
	"time"
	"os"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

// Define a histogram metric for client-side request latencies.
var clientRequestLatency = prometheus.NewHistogramVec(
	prometheus.HistogramOpts{
		Name:    "client_http_request_latency_seconds",
		Help:    "A histogram of latencies for client HTTP requests to other services in seconds.",
		Buckets: prometheus.LinearBuckets(0.01, 0.05, 10),
	},
	[]string{"path"},
)

// init registers the metrics with the Prometheus registry.
func init() {
	prometheus.MustRegister(clientRequestLatency)
}

// main starts both the client and the Prometheus metrics server.
func main() {
	// Start a goroutine to continuously make requests to the server.
	go func() {
		for {
			measureRequestLatency("/about")
			time.Sleep(1 * time.Second) // Wait 1 second between requests
			measureRequestLatency("/home")
			time.Sleep(1 * time.Second)
		}
	}()

	// Expose the client's metrics on port 8081.
	http.Handle("/metrics", promhttp.Handler())
	log.Println("Starting Prometheus client on :8081...")
	log.Fatal(http.ListenAndServe(":8081", nil))
}

// measureRequestLatency sends a request to a specified path on the server and records the latency.
func measureRequestLatency(path string) {
	start := time.Now()

	// Get SIMPLE_APP_URL from environment, default to localhost:8080 if not set
	simpleAppURL := os.Getenv("SIMPLE_APP_URL")
	if simpleAppURL == "" {
			simpleAppURL = "http://localhost:8080"
	}
	
	url := simpleAppURL + path // e.g http://example.com

	resp, err := http.Get(url)
	if err != nil {
		log.Printf("Client: Error making request to %s: %v", url, err)
		return
	}
	defer resp.Body.Close()

	duration := time.Since(start).Seconds()
	clientRequestLatency.WithLabelValues(path).Observe(duration)

	log.Printf("Client: Request to %s took %.3fs, status: %d", url, duration, resp.StatusCode)
}
