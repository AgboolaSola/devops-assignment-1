# Assignment 1 — Linux Diagnostic Toolkit

A small set of Bash scripts for basic Linux diagnostics: a system information report, a disk usage check and a network check. Each script validates its input, prints a clear result, logs what it did, and returns meaningful exit codes so it can be used by other scripts or a CI pipeline.

## Project structure

```
.
├── README.md
├── system-info.sh      # system information report
├── disk-check.sh       # disk usage compared with a threshold
├── network-check.sh    # host, connectivity, interface and port checks
├── grade.sh            # instructor-supplied grader
├── .gitignore          # keeps log files out of Git
└── logs/
    └── .gitkeep        # keeps the empty logs folder in Git
```

## Requirements

- Linux with Bash 4 or newer (developed and tested on Ubuntu 26.04 under WSL2)
- Standard tools: `df`, `awk`, `free`, `uptime`, `getent`, `ping`, `ip` (iproute2), `timeout`
- Internet access and working DNS when checking external hosts such as `google.com`

## Setup

```bash
git clone https://github.com/AgboolaSola/devops-assignment-1.git
cd devops-assignment-1
chmod +x *.sh
```

The scripts can be run from any directory. Logs always go to the project's own `logs/` folder.

## Usage

### system-info.sh

Shows the hostname, current user, date and time, operating system, kernel version, uptime, CPU model and core count, memory usage and current working directory. Every value is read from the system when the script runs.

```bash
./system-info.sh
```

| Exit code | Meaning |
|---|---|
| 0 | Report printed successfully |

### disk-check.sh

Checks how full the filesystem holding a path is and compares it with a threshold.

```bash
./disk-check.sh <threshold> [path]
```

- `threshold` (required): a whole number from 1 to 100
- `path` (optional): any existing file or folder. Defaults to `/`

```bash
./disk-check.sh 80            # checks /
./disk-check.sh 80 /home      # checks the filesystem that /home is on
```

Example output:

```
Disk usage for /mnt/c: 62% (threshold: 80%)
OK: disk usage 62% is below the threshold 80%
```

| Exit code | Meaning |
|---|---|
| 0 | Usage is below the threshold |
| 1 | Usage has reached or gone over the threshold |
| 2 | Invalid input: missing, non-numeric or out-of-range threshold, or a path that does not exist |

### network-check.sh

```bash
./network-check.sh <hostname-or-ip> [port]
```

The script runs these steps in order:

1. **Validates input.** The host may only contain letters, numbers, dots, colons and hyphens. If a port is given, it must be a whole number from 1 to 65535.
2. **Resolves the host** and shows its address, using `getent ahosts`.
3. **Checks basic connectivity** with a single ping and a 2-second timeout.
4. **Shows network interface information** with `ip -brief address`.
5. **Checks TCP connectivity** to the port, if one was given, with a 3-second timeout.

```bash
./network-check.sh google.com
./network-check.sh google.com 443
./network-check.sh 8.8.8.8 53
```

Example output:

```
Resolved google.com to 142.250.180.14
Connectivity: google.com is reachable
Network interfaces:
lo               UNKNOWN        127.0.0.1/8 ::1/128
eth0             UP             172.17.10.100/20
Port 443 on google.com is open
```

| Exit code | Meaning |
|---|---|
| 0 | All checks passed |
| 1 | A check failed: the host could not be resolved, did not reply to ping, or the port was closed or unreachable |
| 2 | Invalid input: missing or badly formatted host, or an invalid port |

A failed ping does not stop the script. The remaining checks still run, and the final exit code reports the failure.

## Logging

Each script writes to its own log file in `logs/`:

| Script | Log file |
|---|---|
| `system-info.sh` | `logs/system-info.log` |
| `disk-check.sh` | `logs/disk-check.log` |
| `network-check.sh` | `logs/network-check.log` |

Every entry has a timestamp and a description of what happened, including invalid input and the final result:

```
2026-10-12 15:42:45 - Started disk-check.sh (threshold=60, path=/mnt/c)
2026-10-12 15:42:45 - Warning: /mnt/c usage 62% reached threshold 60%
```

Log files are created on the first run and are not committed to Git. Only `logs/.gitkeep` is tracked.

## Testing

### Automated

```bash
chmod +x grade.sh *.sh
./grade.sh
```

### Manual tests

Input validation (the same result on any machine):

| Command | Expected exit code |
|---|---|
| `./disk-check.sh` | 2 |
| `./disk-check.sh abc` | 2 |
| `./disk-check.sh 0` | 2 |
| `./disk-check.sh 101` | 2 |
| `./disk-check.sh 80 /does-not-exist` | 2 |
| `./disk-check.sh 100 /` | 0 |
| `./network-check.sh` | 2 |
| `./network-check.sh "bad host"` | 2 |
| `./network-check.sh localhost abc` | 2 |
| `./network-check.sh localhost 0` | 2 |
| `./network-check.sh localhost 65536` | 2 |

Runtime checks (results depend on the machine and network):

| Command | Expected exit code |
|---|---|
| `./network-check.sh localhost` | 0 |
| `./network-check.sh google.com 443` | 0 (needs internet) |
| `./network-check.sh thisdoesnotexist.invalid` | 1 (cannot be resolved) |
| `./network-check.sh 10.255.255.1` | 1 (no ping reply) |
| `./network-check.sh localhost 9` | 1 (nothing listening on port 9) |

To test an open port locally, start a temporary web server with Docker:

```bash
docker run -d -p 8080:80 --name port-test nginx:alpine
./network-check.sh localhost 8080     # expected: port open, exit code 0
docker rm -f port-test
```

## Git workflow

- `main` holds finished work.
- `disk-check.sh` and `network-check.sh` were each built on their own feature branch (`feature/disk-check`, `feature/network-check`).
- Each branch was merged into `main` with `git merge --no-ff`, so every merge stays visible in the history.

```bash
git log --oneline --graph --all
```

## Assumptions and limitations

- The scripts target Linux and Bash. They were not tested on macOS, where tools such as `ping` and `ip` behave differently.
- `disk-check.sh` measures the whole filesystem that the path lives on, not the size of the folder itself. `du -sh <path>` shows a folder's size.
- The threshold must be a whole number, such as `80`, not `80.5`.
- `network-check.sh` uses `getent ahosts`. It returns an IP address unchanged instead of attempting a reverse lookup, and it orders results by what the system can actually reach, which is usually IPv4 first.
- Some servers ignore ping on purpose. A failed ping does not always mean a host is down, which is why the port check still runs afterwards.
- Checking external hosts requires internet access and working DNS.
- Host validation only checks for allowed characters. Whether the name really exists is decided by the resolve step.
- Log files grow over time and are not rotated.