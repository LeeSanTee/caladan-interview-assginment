# Table of Contents

- [Table of Contents](#table-of-contents)
- [Caladan Work Sample Assignment](#caladan-work-sample-assignment)
  - [I. Technology choices and rationale.](#i-technology-choices-and-rationale)
    - [Infrastructure as Code:](#infrastructure-as-code)
    - [Application Stack:](#application-stack)
    - [Cloud Platform:](#cloud-platform)
  - [II. How to provision and deploy the project.](#ii-how-to-provision-and-deploy-the-project)
    - [Assumptions](#assumptions)
    - [Walkthrough](#walkthrough)
  - [III. Access Metrics](#iii-access-metrics)
    - [UI](#ui)
    - [Caluate average latency, median latency, 90th, 95th, 99th percentile latency](#caluate-average-latency-median-latency-90th-95th-99th-percentile-latency)
  - [IV. Assumptions, Limitations, and Tradeoffs](#iv-assumptions-limitations-and-tradeoffs)
    - [Assumptions](#assumptions-1)
    - [Limitations](#limitations)
    - [Tradeoffs](#tradeoffs)
      - [Histogram Type Selection: Classic vs Native Histograms](#histogram-type-selection-classic-vs-native-histograms)
      - [Other Design Tradeoffs](#other-design-tradeoffs)
    - [Production Considerations](#production-considerations)
  - [V. Code Structure](#v-code-structure)

# Caladan Work Sample Assignment
- Use infrastructure-as-code (e.g. Terraform, Pulumi, CloudFormation) to provision
two servers in the cloud (AWS preferred, but any provider is fine).

- Deploy a simple app (on one server) that:
  - Periodically measures network latency to the second server, using any method you find appropriate
  - Exposes the latency measurement via an HTTP endpoint (e.g. /metrics or /latency).
  - The app can be written in any language or framework you choose.

- Automation
  - Automate the installation and configuration of the app using scripts or tools of your choice (e.g. Ansible, shell scripts, Docker, cloud-init).

- Documentation
  - Technology choices and rationale. (I)
  - How to provision and deploy the project. (II)
  - How to access and interpret the latency metrics  (III)
  - Any assumptions, limitations, or tradeoffs you made (IV)
  
## I. Technology choices and rationale.

### Infrastructure as Code:
Terraform - Infrastructure provisioning and resource management
Packer - Immutable infrastructure with pre-baked AMIs containing applications
Ansible - Configuration management and application deployment

### Application Stack:
Go - High-performance applications for metrics collection and latency measurement
Nginx - Web server and reverse proxy for routing traffic
Prometheus metrics format - Standard observability format for metrics exposition

### Cloud Platform:
AWS EC2, VPC networking
Immutable Infrastructure: Packer + Terraform approach ensures consistent, reproducible deployments
Separation of Concerns: Distinct roles for infrastructure (Terraform), configuration (Ansible), and image building (Packer)
Performance: Go applications provide low-latency, efficient network measurements
Observability: Prometheus metrics format enables integration with monitoring ecosystems
Security: Private subnet deployment with VPN access reduces attack surface

## II. How to provision and deploy the project. 
### Assumptions
If you would like to follow along, these are the existing resources:

1. AWS VPC (in my case I use VPC name)
2. Public Subnet Masks (subnet that allow you to access EC2's public_dns. However, in my case I deploy those intances into private subnets because I have VPN server to access them by private_dns)
3. Golang, Python3, Terraform installed

### Walkthrough

Build the image with Packer:

```
$ cd packer
$ packer validate packer-metrics-exporter.json
$ packer build packer-metrics-exporter.json

amazon-ebs: output will be in this color.
...
==> amazon-ebs: Stopping the source instance...
==> amazon-ebs: Stopping instance
==> amazon-ebs: Waiting for the instance to stop...
==> amazon-ebs: Creating AMI packer-simple-app-1758343781 from instance i-0e6224778c6716e32
==> amazon-ebs: Attaching run tags to AMI...
==> amazon-ebs: AMI: ami-024808e069b9788c8
==> amazon-ebs: Waiting for AMI to become ready...
==> amazon-ebs: Skipping Enable AMI deprecation...
==> amazon-ebs: Skipping Enable AMI deregistration protection...
==> amazon-ebs: Adding tags to AMI (ami-024808e069b9788c8)...
==> amazon-ebs: Tagging snapshot: snap-07ce42cd346aad281
==> amazon-ebs: Creating AMI tags
==> amazon-ebs: Adding tag: "Timestamp": "packer-1758343781"
==> amazon-ebs: Adding tag: "BaseAmi": "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250821"
==> amazon-ebs: Adding tag: "Datestamp": "2025-09-20T04:49:41Z"
==> amazon-ebs: Adding tag: "UUID": "68ce3681-ae1f-c1cf-074b-db80e2150b33"
==> amazon-ebs: Adding tag: "Name": "packer-simple-app-1758343781"
==> amazon-ebs: Creating snapshot tags
==> amazon-ebs: Terminating the source AWS instance...
==> amazon-ebs: Cleaning up any extra volumes...
==> amazon-ebs: No volumes to clean up, skipping
==> amazon-ebs: Deleting temporary security group...
==> amazon-ebs: Deleting temporary keypair...
Build 'amazon-ebs' finished after 17 minutes 50 seconds.

==> Wait completed after 17 minutes 50 seconds

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs: AMIs were created:
ap-southeast-1: ami-024808e069b9788c8

$ cd ..
```

We should now see our AMI in our AWS EC2 Console:

![image](https://github.com/leesantee/caladan-interview-assginment/images/amis.png?raw=true)

Now since our AMIs are baked with our software and website files, we will use Terraform to provision 2 EC2 instances from those AMIs:

```bash
config "enable_eip = True" to create public Elasic IPs

$ terraform -chdir=./terraform init
$ terraform -chdir=./terraform plan
$ terraform -chdir=./terraform apply

...

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

ami_id_metrics_exporter = "ami-047c5e78c45ef21e8"
ami_id_simple_app = "ami-024808e069b9788c8"
instance_id_metrics_exporter = "i-0bc8d78a3a20d6aae"
instance_id_simple_app = "i-09c70036ea3a2f356"
private_dns_metrics_exporter = "ip-172-17-27-148.ap-southeast-1.compute.internal"
private_dns_simple_app = "ip-172-17-21-68.ap-southeast-1.compute.internal"
public_dns_metrics_exporter = "null"
public_dns_simple_app = "null"
public_ip_metrics_exporter = "null"
public_ip_simple_app = "null"
subnet_id_metrics_exporter = "subnet-004556289e21558c1"
subnet_id_simple_app = "subnet-034798433cb55fafe"
```

## III. Access Metrics
### UI
On our AWS EC2 console we will see our EC2 instance in a running state:

![image](https://github.com/leesantee/caladan-interview-assginment/images/ec2.png?raw=true)

And when we access our Public IPs, we should see our website:
In my case, I access `metrics_exporter` with private dns `ip-172-17-27-148.ap-southeast-1.compute.internal` for http_client_requests_latency

![image](https://github.com/leesantee/caladan-interview-assginment/images/web.png?raw=true)
Click button `View Metrics` to access Prometheus exposition format metrics.

![image](https://github.com/leesantee/caladan-interview-assginment/images/metrics_exporter.png?raw=true)

and I access `simple_app`  with private dns `http://ip-172-17-21-68.ap-southeast-1.compute.internal:8081/metrics` for http_server_requests_latency
![image](https://github.com/leesantee/caladan-interview-assginment/images/simple_app.png?raw=true)

### Caluate average latency, median latency, 90th, 95th, 99th percentile latency

```bash
export METRICS_EXPORTER_URL="http://ip-172-17-27-148.ap-southeast-1.compute.internal/metrics"
cd result
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python3 main.py

...

Path: /about
  Average latency: 0.260s
  p50: 0.310s
  p90: 0.410s
  p95: 0.459s
  p99: infs

Path: /home
  Average latency: 0.250s
  p50: 0.260s
  p90: 0.460s
  p95: infs
  p99: infs
```

## IV. Assumptions, Limitations, and Tradeoffs

### Assumptions
- **Network Environment**: Assumes stable VPC networking with consistent routing between private subnets
- **AWS Resources**: Pre-existing VPC, subnets, and VPN access for private instance management
- **Application Endpoints**: Simple-app exposes `/home` and `/about` endpoints for latency measurement
- **Measurement Method**: HTTP GET requests provide sufficient accuracy for application-level latency monitoring
- **Histogram Implementation**: Uses Prometheus classic histograms with predefined buckets for latency distribution

### Limitations
- **Measurement Scope**: Only measures HTTP application latency, not network layer (ICMP) latency
- **Single Point Measurement**: Latency measured from one instance only, not bidirectional
- **Sample Size**: Limited historical data - metrics reset on service restart
- **Network Hops**: Cannot distinguish between network vs application processing latency
- **Percentile Accuracy**: High percentiles (p99) may show as "inf" with insufficient data points
- **Classic Histogram Limitations**: 
  - Fixed bucket boundaries may miss outliers or create accuracy issues
  - Memory overhead increases with number of buckets
  - Cannot calculate exact percentiles, only approximations based on bucket ranges
  - Requires pre-knowledge of expected latency distribution for optimal bucket selection

### Tradeoffs

#### Histogram Type Selection: Classic vs Native Histograms

**Classic Histograms (Current Implementation)**
- ✅ **Pros**: Widely supported, mature ecosystem, predictable memory usage
- ❌ **Cons**: Fixed buckets, approximate percentiles, potential accuracy loss
- **Use Case**: Suitable for well-understood latency patterns with predictable ranges

```go
// Current implementation using classic histogram
prometheus.NewHistogramVec(
    prometheus.HistogramOpts{
        Buckets: prometheus.LinearBuckets(0.01, 0.05, 10), // Fixed buckets
    },
)
```

**Native Histograms (Alternative)**
- ✅ **Pros**: Exact percentile calculation, adaptive resolution, efficient storage
- ❌ **Cons**: Newer feature, less tooling support, higher computational overhead
- **Use Case**: Better for unknown or highly variable latency distributions

```go
// Alternative native histogram implementation
prometheus.NewHistogramVec(
    prometheus.HistogramOpts{
        NativeHistogramBucketFactor: 1.1, // Adaptive buckets
        NativeHistogramMaxBucketNumber: 100,
    },
)
```

#### Other Design Tradeoffs
- **HTTP vs ICMP**: Chose HTTP requests over ping for real-world application latency simulation
- **Prometheus Format**: Standard metrics format vs custom output for broader ecosystem compatibility  
- **Immutable Infrastructure**: Longer deployment time vs consistency and reproducibility
- **Private Subnets**: Enhanced security vs direct internet accessibility for testing
- **Polling Frequency**: 10-second intervals balance data granularity with resource consumption

### Production Considerations

**Immediate Improvements**:
- Implement native histograms for more accurate percentile calculations
- Add bidirectional latency measurement
- Increase bucket resolution or switch to adaptive buckets

**Long-term Enhancements**:
- Network layer monitoring (ping/traceroute)
- Persistent metrics storage (Prometheus/Grafana)
- Alert thresholds for latency degradation
- Multiple measurement points across availability zones
- Custom histogram bucket optimization based on observed latency patterns

**Histogram Bucket Optimization**:
```go
// Optimized buckets for typical network latency
Buckets: []float64{0.001, 0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0}
```
  
## V. Code Structure

The following shows packer, ansible, terraform, golang app source code and latency calcalation script.

```bash
.
├── LICENSE
├── Makefile
├── README.md
├── ansible
│   ├── playbook.yml
│   └── roles
│       ├── metrics-exporter
│       │   ├── files
│       │   │   └── main
│       │   ├── handlers
│       │   │   └── main.yaml
│       │   ├── tasks
│       │   │   └── main.yaml
│       │   └── templates
│       │       └── golang-app.service.j2
│       ├── simple-app
│       │   ├── files
│       │   │   └── main
│       │   ├── handlers
│       │   │   └── main.yaml
│       │   ├── tasks
│       │   │   └── main.yaml
│       │   └── templates
│       │       └── golang-app.service.j2
│       └── web
│           ├── defaults
│           │   └── main.yml
│           ├── files
│           │   ├── www
│           │   │   ├── icons
│           │   │   │   └── favicon.ico
│           │   │   ├── index.html
│           │   │   └── styles
│           │   │       ├── font-awesome.css
│           │   │       └── main.css
│           │   └── www.conf
│           ├── handlers
│           │   └── main.yml
│           ├── meta
│           │   └── main.yml
│           ├── tasks
│           │   └── main.yml
│           ├── templates
│           │   └── nginx.conf.j2
│           └── vars
│               └── main.yml
├── applications
│   ├── metrics-exporter
│   │   ├── build.sh
│   │   ├── go.mod
│   │   ├── go.sum
│   │   └── main.go
│   └── simple-app
│       ├── build.sh
│       ├── go.mod
│       ├── go.sum
│       └── main.go
├── dependencies
│   └── requirements.txt
├── images
│   ├── amis.png
│   └── metrics_exporter.png
├── packer
│   ├── packer-metrics-exporter.json
│   └── packer-simple-app.json
├── result
│   ├── main.py
│   └── requirements.txt
└── terraform
    ├── main.tf
    ├── modules
    │   └── compute
    │       ├── locals.tf
    │       ├── main.tf
    │       ├── networking.tf
    │       ├── outputs.tf
    │       └── variables.tf
    ├── outputs.tf
    ├── providers.tf
    └── variables.tf
```