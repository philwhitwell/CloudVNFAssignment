
| Environment | Role     | Interval       | Transfer    | Bitrate        | Jitter   | Lost/Total Datagrams |
| ----------- | -------- | -------------- | ----------- | -------------- | -------- | -------------------- |
| AKS         | Sender   | 0.00–60.00 sec | 71.5 MBytes | 10.0 Mbits/sec | 0.000 ms | 0/55638 (0%)         |
| AKS         | Receiver | 0.00–60.00 sec | 71.5 MBytes | 10.0 Mbits/sec | 0.130 ms | 0/55638 (0%)         |
| K3s         | Sender   | 0.00–60.00 sec | 71.5 MBytes | 10.0 Mbits/sec | 0.000 ms | 0/55638 (0%)         |
| K3s         | Receiver | 0.00–60.31 sec | 66.7 MBytes | 9.27 Mbits/sec | 1.253 ms | 0/55527 (0%)         |
| AKS         | Sender   | 0.00–60.00 sec | 358 MBytes  | 50.0 Mbits/sec | 0.000 ms | 0/278186 (0%)        |
| AKS         | Receiver | 0.00–60.00 sec | 358 MBytes  | 50.0 Mbits/sec | 0.145 ms | 0/278186 (0%)        |
| K3s         | Sender   | 0.00–60.00 sec | 358 MBytes  | 50.0 Mbits/sec | 0.000 ms | 0/278186 (0%)        |
| K3s         | Receiver | 0.00–60.15 sec | 235 MBytes  | 32.7 Mbits/sec | 0.342 ms | 0/278186 (0%)        |
| AKS         | Sender   | 0.00–60.00 sec | 715 MBytes  | 100 Mbits/sec  | 0.000 ms | 0/556364 (0%)        |
| AKS         | Receiver | 0.00–60.01 sec | 713 MBytes  | 99.6 Mbits/sec | 0.274 ms | 0/556364 (0%)        |
| K3s         | Sender   | 0.00–60.00 sec | 715 MBytes  | 100 Mbits/sec  | 0.000 ms | 0/556374 (0%)        |
| K3s         | Receiver | 0.00–60.21 sec | 251 MBytes  | 35.0 Mbits/sec | 0.100 ms | 0/556328 (0%)        |
| AKS         | Sender   | 0.00–60.01 sec | 1.40 GBytes | 200 Mbits/sec  | 0.000 ms | 0/1112728 (0%)       |
| AKS         | Receiver | 0.00–60.04 sec | 1.38 GBytes | 197 Mbits/sec  | 0.023 ms | 0/1112724 (0%)       |
| K3s         | Sender   | 0.00–60.00 sec | 1.40 GBytes | 200 Mbits/sec  | 0.000 ms | 0/1112745 (0%)       |
| K3s         | Receiver | 0.00–61.95 sec | 66.9 MBytes | 9.06 Mbits/sec | 0.119 ms | 0/1099430 (0%)       |


| Target Rate | AKS Throughput (Receiver) | K3s Throughput (Receiver) | AKS Jitter | K3s Jitter | Observation                                     |
| ----------- | ------------------------- | ------------------------- | ---------- | ---------- | ----------------------------------------------- |
| 10 Mbps     | 10.0 Mbps                 | 9.27 Mbps                 | 0.130 ms   | 1.253 ms   | Both environments perform similarly at low load |
| 50 Mbps     | 50.0 Mbps                 | 32.7 Mbps                 | 0.145 ms   | 0.342 ms   | K3s begins to saturate                          |
| 100 Mbps    | 99.6 Mbps                 | 35.0 Mbps                 | 0.274 ms   | 0.100 ms   | AKS scales linearly, K3s limited                |
| 200 Mbps    | 197 Mbps                  | 9.06 Mbps                 | 0.023 ms   | 0.119 ms   | K3s heavily constrained under high load         |
