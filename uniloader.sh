#
# Uniloader startup script for non-RHEL systems
#
# Please edit the following options in order to use the correct paths.
# $Id: uniloader,v 0.1 2019/02/21 18:54:20 lenz Exp $
# By Celso Annes
# contato@celsoannes.com.br
#

### BEGIN INIT INFO
# Provides:             uniloader
# Required-Start:       asterisk
# Required-Stop:        asterisk
# Should-Start:         asterisk
# Should-Stop:          asterisk
# Default-Start:        2 3 4 5
# Default-Stop:         0 1 6
# Short-Description:    uniloader
# Description:          QueueMetrics Queue Log Loader
### END INIT INFO

uniloader=/bin/uniloader
partition=P001
queuelog=/var/log/asterisk/queue_log
logfile=/var/log/asterisk/uniloader.log
host=192.168.0.161
port=3306
login=queuemetrics
pass=javadude


start() {
        echo -n $"Starting $prog: "
        nohup nice $uniloader -s $queuelog upload --uri "mysql:tcp($host:$port)/queuemetrics?allowOldPasswords=1" --login $login --pass $pass --token $partition >> $logfile &
        RETVAL=$?
        echo
        [ $RETVAL = 0 ] && touch /var/lock/uniloader && echo $! > /var/run/uniloader.pid
        return $RETVAL
}
stop() {
                echo -n $"Stopping $prog: "
                PID=`cat /var/run/uniloader.pid`
                kill -9 $PID
                RETVAL=$?
                echo
                [ $RETVAL = 0 ] && rm -f /var/lock/uniloader /var/run/uniloader.pid
}

case "$1" in
        start)
                echo -n "Starting QueueMetrics QLoaderd server: "
                                start
                ;;
        stop)
                echo -n "Stopping QueueMetrics QLoaderd server: "
                stop
                ;;
        restart)
                stop
                sleep 2
                start
                ;;

        *)
                echo "Usage: /etc/init.d/uniloader {start|stop|restart}"
                exit 1
esac

exit 0
