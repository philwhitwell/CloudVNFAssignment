# This is a sample Python script.

# Press ⌃R to execute it or replace it with your code.
# Press Double ⇧ to search everywhere for classes, files, tool windows, actions, and settings.


# def print_hi(name):
#     # Use a breakpoint in the code line below to debug your script.
#     print(f'Hi, {name}')  # Press ⌘F8 to toggle the breakpoint.
#
#
# # Press the green button in the gutter to run the script.
# if __name__ == '__main__':
#     print_hi('PyCharm')
#
# # See PyCharm help at https://www.jetbrains.com/help/pycharm/

import matplotlib.pyplot as plt

# Data
offered_load = [10, 50, 100, 200]
aks_throughput = [10, 50, 99.6, 197]
k3s_throughput = [9.3, 32.7, 35, 9]

# Create plot
plt.figure(figsize=(8,5))

plt.plot(offered_load, aks_throughput, marker='o', label='AKS Throughput')
plt.plot(offered_load, k3s_throughput, marker='s', label='K3s Throughput')

# Labels and title
plt.xlabel("Offered Load (Mbps)")
plt.ylabel("Measured Throughput (Mbps)")
plt.title("UPF Throughput vs Offered Load (AKS vs K3s)")
plt.grid(True)

# Legend
plt.legend()

# Save figure (useful for report)
plt.savefig("upf_throughput_comparison.png", dpi=300)

# Show plot
plt.show()