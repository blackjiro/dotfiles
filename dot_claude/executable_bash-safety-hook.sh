#!/bin/bash

read -r INPUT

COMMAND=$(echo "$INPUT" | jq -r '.params.command // empty' 2>/dev/null)

if [ -z "$COMMAND" ]; then
  exit 0
fi

DANGEROUS_PATTERNS=(
  "rm -rf /"
  "rm -rf /*"
  "rm -r /"
  "rm -r /*"
  "sudo rm -rf /"
  "sudo rm -rf /*"
  "rm -rf ~"
  "rm -rf ~/*"
  "rm -rf /home"
  "rm -rf /home/*"
  "rm -rf /etc"
  "rm -rf /etc/*"
  "rm -rf /var"
  "rm -rf /var/*"
  "rm -rf /usr"
  "rm -rf /usr/*"
  "rm -rf /opt"
  "rm -rf /opt/*"
  "rm -rf /System"
  "rm -rf /Library"
  "rm -rf /Applications"
  "> /dev/sda"
  "dd if=/dev/zero of=/dev/"
  "dd if=/dev/random of=/dev/"
  "mkfs."
  "fdisk /dev/"
  "shutdown"
  "reboot"
  "halt"
  "poweroff"
  "init 0"
  "init 6"
  ": (){ :|:& };:"
  "chmod -R 777 /"
  "chmod -R 000 /"
  "chown -R"
  "passwd root"
  "sudo passwd"
  "nc -l"
  "netcat -l"
  "cryptominer"
  "xmrig"
  "monero"
)

for PATTERN in "${DANGEROUS_PATTERNS[@]}"; do
  if [[ "$COMMAND" == *"$PATTERN"* ]]; then
    echo "{\"error\": \"Blocked dangerous command: $PATTERN\"}"
    exit 2
  fi
done

if [[ "$COMMAND" =~ ^rm[[:space:]]+-[[:alnum:]]*[rRfF] ]] && [[ "$COMMAND" =~ (^|[[:space:]])/($|[[:space:]]) ]]; then
  echo "{\"error\": \"Blocked: rm with -rf/-r/-f flags on root path\"}"
  exit 2
fi

if [[ "$COMMAND" =~ curl.*\|[[:space:]]*(bash|sh) ]] || [[ "$COMMAND" =~ wget.*\|[[:space:]]*(bash|sh) ]]; then
  echo "{\"error\": \"Blocked: piping web content to shell\"}"
  exit 2
fi

if [[ "$COMMAND" =~ \>\&[[:space:]]*/dev/tcp/ ]] || [[ "$COMMAND" =~ /dev/tcp/.*\>\& ]]; then
  echo "{\"error\": \"Blocked: reverse shell attempt\"}"
  exit 2
fi

exit 0
