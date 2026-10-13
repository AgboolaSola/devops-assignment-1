# Assignment 1 - Linux Diagnostic Toolkit

Three bash scripts for checking system info, disk usage and network.

## Setup

```
git clone https://github.com/AgboolaSola/devops-assignment-1.git
cd devops-assignment-1
chmod +x *.sh
```

## Scripts

### system-info.sh
Shows hostname, user, date, OS, kernel, uptime, CPU, memory and current directory.

```
./system-info.sh
```

### disk-check.sh
Checks disk usage against a threshold (1-100). The path is optional, default is /.

```
./disk-check.sh 80
./disk-check.sh 80 /home
```

Exit codes: 0 = below threshold, 1 = reached or above threshold, 2 = invalid input

### network-check.sh
Checks a host. It resolves the IP, pings it, shows the network interfaces, and checks a port if you give one (1-65535).

```
./network-check.sh google.com
./network-check.sh google.com 443
```

Exit codes: 0 = all checks passed, 1 = a check failed, 2 = invalid input

## Logs

Each script writes to its own log file in logs/ with a timestamp. The log files are in .gitignore so they don't get pushed.

## Testing

```
./grade.sh
```

I also tested invalid inputs manually, like `./disk-check.sh abc`, `./disk-check.sh 101` and `./network-check.sh localhost 65536`. They all return exit code 2.

## Assumptions

- Runs on Linux with bash (I used Ubuntu on WSL2)
- Needs internet to check outside hosts like google.com
- Some servers block ping, so a failed ping doesn't always mean the host is down
- disk-check checks the whole disk the path is on, not just that folder