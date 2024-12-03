#!/bin/bash

 
#color codes

RED="\033[0;31m"
YELLOW="\033[0;33m"
PURPLE="\033[0;35m"
ORANGE="\033[0;33m"
GREEN="\033[0;32m"
NC="\033[0m"


LOG_FILE="/var/log/system.log"
ALERTS_LOG="alerts.log"
MAX_ALERTS_LOG_SIZE=10240


usage() {
echo "Usage: $0 [logfile_path]"
echo "Example: $0 /var/log/syslog"
exit 1
}

if [ $# -gt 0 ]; then
  LOG_FILE="$1"
fi

if [ ! -f "$LOG_FILE" ]; then
echo "Log file $LOG_FILE does not exit."
usage
fi

log_with_color() {
local log_line="$1"

if echo "$log_line" | grep -qi "ERROR"; then
  echo -e "${RED}[ERROR] $log_line${NC}"
  echo "[ERROR] $log_line" >> "$ALERTS_LOG"
elif echo "$log_line" | grep -qi "WARNING"; then
  echo -e "${YELLOW}[WARNING] $log_line${NC}"
elif echo "$log_line" | grep -qi "INFO"; then
  echo -e "${GREEN}[INFO] $log_line${NC}"
else
echo "$log_line"
 fi

rotate_alerts_log
}

monitor_log() {
local filter="$1"
echo "Monitoring $LOG_FILE with filter: $filter"


tail -f "$LOG_FILE" | while read -r line; do
  case "$filter" in
     ERROR) [[ "$line" =~ ERROR ]] && log_with_color "$line" ;;
     WARNING) [[ "$line" =~ WARNING|ERROR ]] && log_with_color "$line" ;;
     INFO) [[ "$line" =~ INFO|WARNING|ERROR ]] && log_with_color "$line" ;;
     *) log_with_color "$line" ;;
 esac
done
}

generate_report() {
echo "Report for $LOG_FILE"
local error_count=$(grep -ci "ERROR" "$LOG_FILE")
local warning_count=$(grep -ci "WARNING" "$LOG_FILE")
local info_count=$(grep -ci "INFO" "$LOG_FILE")


echo -e "${RED}ERROR: $error_count${NC}"
echo -e "${YELLOW}WARNING: $warning_count${NC}"
echo -e "${GREEN}INFO: $info_count${NC}"
}

rotate_alerts_log() {
if [ -f "$ALERTS_LOG" ] && [ $(stat -c%s "$ALERTS_LOG") -ge $MAX_ALERTS_LOG_SIZE ]; then
   mv "$ALERTS_LOG" "${ALERTS_LOG}.old"
  echo "Rotated $ALERTS_LOG to ${ALERTS_LOG}.old"
  echo "New $ALERTS_LOG created." > "$ALERTS_LOG"
   
  fi
}    
   
main_menu() {  
while true; do
  echo -e "\n=========================================="
  echo -e "${PURPLE}       Log Monitoring Menu            ${NC}"
  echo -e "=========================================="
  echo "1) Monitor Logs"
  echo "2) Generate Report"
  echo "3) View Alerts Log"
  echo "4) Exit"
  

  echo -e "===========================================\n"

read -rp " Choose an option: " choice

case "$choice" in
  1) 
     echo "Choose severity to monitor:"
     echo "1) ERROR"
     echo "2) WARNING"
     echo "3) INFO"
     echo "4) ALL"
     read -rp "Enter Choice: " severity_choice
     case "$severity_choice" in

        1) monitor_log "ERROR" ;;
        2) monitor_log "WARNING" ;;
        3) monitor_log "INFO" ;;
        4) monitor_log "ALL" ;;
        *) echo -e "${RED}Invalid option.${NC}" ;;
      esac
      ;;
    
  2) generate_report ;;
  3) cat "$ALERTS_LOG" ;;
  4) echo "Exiting."; exit 0 ;;
  *) echo -e "${RED}Invalid option.${NC}" ;;

    esac
      done
}

main_menu    


 
