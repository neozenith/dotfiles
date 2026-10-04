#!/bin/zsh -f
# Measure interactive shell startup, first prompt expansion, and slow functions.
set -eu

root=${0:A:h:h:h}
output_dir="$root/tmp/shell-startup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$output_dir/zdot"

printf 'Seconds (shell includes prompt)\n'
printf '%-6s %10s %10s %10s\n' Run Shell Prompt Setup
for run in {1..5}; do
  /usr/bin/time -p /bin/zsh -ic '
    zmodload zsh/datetime
    start=$EPOCHREALTIME
    print -P -- "$PROMPT" >/dev/null
    print -r -- "PROMPT_SECONDS=$(( EPOCHREALTIME - start ))"
  ' >"$output_dir/run-$run.out" 2>"$output_dir/run-$run.err"
  shell_seconds=$(awk '$1 == "real" { print $2 }' "$output_dir/run-$run.err")
  prompt_seconds=$(sed -n 's/^PROMPT_SECONDS=//p' "$output_dir/run-$run.out")
  setup_seconds=$(awk -v shell="$shell_seconds" -v prompt="$prompt_seconds" 'BEGIN { printf "%.3f", shell - prompt }')
  printf '%-6s %10.3f %10.3f %10s\n' "$run" "$shell_seconds" "$prompt_seconds" "$setup_seconds"
done

# ZDOTDIR loads the profiler before the real .zshrc without editing home files.
cat >"$output_dir/zdot/.zshrc" <<'EOF'
zmodload zsh/zprof
source "$HOME/.zshrc"
EOF
ZDOTDIR="$output_dir/zdot" /bin/zsh -ic 'zprof' >"$output_dir/zprof.txt" 2>"$output_dir/zprof.err"
printf '\nSlow functions (milliseconds; inclusive times can overlap)\n'
sed -n '1,13p' "$output_dir/zprof.txt"

if [[ ${1:-} == --trace ]]; then
  PS4='+%D{%s.%6.} %N:%i> ' /bin/zsh -ixc ':' >"$output_dir/trace.out" 2>"$output_dir/trace.err"
  python3 - "$output_dir/trace.err" <<'PY'
import re
import sys

previous = None
gaps = []
with open(sys.argv[1], errors="replace") as trace:
    for line in trace:
        match = re.match(r"^\+(\d+\.\d+) (.*)", line)
        if not match:
            continue
        timestamp = float(match.group(1))
        if previous and timestamp >= previous[0]:
            gaps.append((timestamp - previous[0], previous[1]))
        previous = (timestamp, match.group(2).rstrip())
print("\nLargest trace gaps (seconds; tracing adds overhead)")
for duration, command in sorted(gaps, reverse=True)[:10]:
    print(f"{duration:.3f}  {command[:140]}")
PY
fi

printf '\nReports: %s\n' "$output_dir"
printf 'Review run-*.err and zprof.err for startup errors. Trace files can contain expanded secrets.\n'
