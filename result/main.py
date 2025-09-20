import requests
import os
from collections import defaultdict

METRICS_EXPORTER_URL = os.getenv("METRICS_EXPORTER_URL")

def parse_metrics(text):
    buckets = defaultdict(list)
    sums = {}
    counts = {}

    for line in text.splitlines():
        if line.startswith("#") or not line.strip():
            continue

        if line.startswith("client_http_request_latency_seconds_bucket"):
            # example: client_http_request_latency_seconds_bucket{path="/about",le="0.21"} 10
            parts = line.split()
            value = float(parts[1])
            labels = parts[0].split("{")[1].split("}")[0]
            label_dict = dict(item.split("=") for item in labels.split(","))
            path = label_dict["path"].strip('"')
            le = label_dict["le"].strip('"')
            buckets[path].append((float(le) if le != "+Inf" else float("inf"), value))

        elif line.startswith("client_http_request_latency_seconds_sum"):
            parts = line.split()
            value = float(parts[1])
            labels = parts[0].split("{")[1].split("}")[0]
            label_dict = dict(item.split("=") for item in labels.split(","))
            path = label_dict["path"].strip('"')
            sums[path] = value

        elif line.startswith("client_http_request_latency_seconds_count"):
            parts = line.split()
            value = float(parts[1])
            labels = parts[0].split("{")[1].split("}")[0]
            label_dict = dict(item.split("=") for item in labels.split(","))
            path = label_dict["path"].strip('"')
            counts[path] = int(value)

    return buckets, sums, counts


def calculate_quantile(buckets, count, quantile):
    """Approximate quantile from Prometheus histogram buckets."""
    if count == 0:
        return None

    target = count * quantile
    for upper, value in sorted(buckets):
        if value >= target:
            return upper
    return None


def main():
    resp = requests.get(METRICS_EXPORTER_URL)
    resp.raise_for_status()

    buckets, sums, counts = parse_metrics(resp.text)

    for path in counts:
        avg = sums[path] / counts[path] if counts[path] > 0 else 0
        p50 = calculate_quantile(buckets[path], counts[path], 0.50)        
        p90 = calculate_quantile(buckets[path], counts[path], 0.90)
        p95 = calculate_quantile(buckets[path], counts[path], 0.95)
        p99 = calculate_quantile(buckets[path], counts[path], 0.99)

        print(f"Path: {path}")
        print(f"  Average latency: {avg:.3f}s")
        print(f"  p50: {p50:.3f}s")
        print(f"  p90: {p90:.3f}s")
        print(f"  p95: {p95:.3f}s")
        print(f"  p99: {p99:.3f}s")
        print("")


if __name__ == "__main__":
    main()
