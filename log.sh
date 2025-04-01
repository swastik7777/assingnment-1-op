SYSLOG="/var/log/syslog"
AUTHLOG="/var/log/auth.log"
ALERT_LOG="/var/log/alerts.log"
CPU_THRESHOLD=80
DISK_THRESHOLD=90
FAILED_ATTEMPT_THRESHOLD=5

EMAIL="swastik.gomase.sae.comp@gmail.com"

#Function to send email alert
send_email_alert() {
     echo "$1" | mail -s "Log Monitor Alert" $EMAIL
     }

     # Monitor CPU usage
 cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    if [[ $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) ]]; then
         alert_message="ALERT: CPU usage is above ${CPU_THRESHOLD}%! Current usage: ${cpu_usage}%."
             echo "$(date): $alert_message" >> $ALERT_LOG
                 send_email_alert "$alert_message"
                 fi

                 # Monitor Disk usage
                 disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
                 if [[ $disk_usage > $DISK_THRESHOLD ]]
		 then
                     alert_message="ALERT: Disk usage is above ${DISK_THRESHOLD}%! Current usage: ${disk_usage}%."
                         echo "$(date): $alert_message" >> $ALERT_LOG
                             send_email_alert "$alert_message"
                             fi

                             # Monitor for failed login attempts
                             failed_logins=$(grep "Failed password" $AUTHLOG | wc -l)
                             if [[ failed_logins > FAILED_ATTEMPT_THRESHOLD ]]; then
                                 alert_message="ALERT: More than $FAILED_ATTEMPT_THRESHOLD failed login attempts! Total attempts: $failed_logins."
                                     echo "$(date): $alert_message" >> $ALERT_LOG
                                         send_email_alert "$alert_message"
                                         fi

                                         # Extract the latest 10 critical log messages from /var/log/syslog
                                         critical_logs=$(tail -n 100 $SYSLOG | grep -i "critical" | head -n 10)
                                         if [ -n "$critical_logs" ]; then
                                             alert_message="ALERT: Latest 10 critical log messages:\n$critical_logs"
                                                 echo "$(date): $alert_message" >> $ALERT_LOG#                   
                                                 send_email_alert "$alet_message"             
					 fi
