
### CPU
sum(rate(container_cpu_usage_seconds_total{namespace="pw-open5gs",pod=~"open5gs-upf.*"}[1m])) * 100
Units: 1-100%

### Memory
sum(container_memory_usage_bytes{namespace="pw-open5gs",pod=~"open5gs-upf.*"}) / 1024 / 1024
Units: MB

### Network RX
sum(rate(container_network_receive_bytes_total{namespace="pw-open5gs",pod=~"open5gs-upf.*"}[30s])) * 8 / 1000000
Units: MBps

### Network TX
sum(rate(container_network_transmit_bytes_total{namespace="pw-open5gs",pod=~"open5gs-upf.*"}[30s])) * 8 / 1000000
Units: MBps


