## Crontab Hacks

**cron** is the daemon that executes scheduled commands
**crontab** is the program used to modify crontab
**crontab** is a per user file that contains instructions for cron

### Crontab Overview

Every user on a system may have their own crontab file. The location of the root and user crontab files are system dependant but they are generally below `/var/spool/cron`.

There is a system-wide `/etc/crontab` file, the `/etc/cron.d` directory may contain crontab fragments which are also read and actioned by cron. 

root can always use the crontab command; regular users may or may not be granted access. When you edit the crontab file with the command `crontab -e` and save it, cron checks it for basic validity but does not guarantee your crontab file is correctly formed. There is a file called `cron.deny` which will specify which users cannot use cron. The `cron.deny` file location is system dependent and can be deleted which will allow all users to use cron.

If the computer is not powered on or crond daemon is not running, and the date/time for a command to run has passed, cron will not catchup and run past queries.

### Operation

View the contents of crontab with `crontab -l`

Edit the crontab file with `crontab -e`

*note:* it is not recommended to run crontab as sudo

A crontab command is represented by a single line. You cannot use `\` to extend a command over multiple lines. The hash (`#`) sign represents a comment which means anything on that line is ignored by cron. Leading whitespace and blank lines are ignored.

Be *very* careful when using the percent (`%`) sign in your command. Unless they are escaped `\%` they are converted into newlines and everything after the first non-escaped `%` is passed to your command on stdin.


* User Crontabs
```
# Example of job definition:
 # .---------------- minute (0 - 59)
 # |  .------------- hour (0 - 23)
 # |  |  .---------- day of month (1 - 31)
 # |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
 # |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7)
 # |  |  |  |  |
 # *  *  *  *  *   command to be executed
```

* System wide

```
 # Example of job definition:
 # .---------------- minute (0 - 59)
 # |  .------------- hour (0 - 23)
 # |  |  .---------- day of month (1 - 31)
 # |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
 # |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7)
 # |  |  |  |  |
 # *  *  *  *  * user-name  command to be executed
```

Notice that the latter requires a user-name. The command will be run as the named user.

The first 5 fields of the line represent the time(s) when the command should be run. You can use numbers or where applicable day/month names in the time specification.

* The fields are separated by spaces or tabs.
* A comma (`,`) is used to specify a list e.g 1,4,6,8 which means run at 1,4,6,8.
* Ranges are specified with a dash (`-`) and may be combined with lists e.g. 1-3,9-12 which means between 1 and 3 then between 9 and 12.
* The `/` character can be used to introduce a step e.g. 2/5 which means starting at 2 then every 5 (2,7,12,17,22...). They do not wrap past the end.
* An asterisk (`*`) in a field signifies the entire range for that field (e.g. 0-59 for the minute field).
* Ranges and steps can be combined e.g. `*/2` signifies starting at the minimum for the relevant field then every 2 e.g. 0 for minutes( 0,2...58), 1 for months (1,3 ... 11) etc.

### Debugging

#### Check that cron is running
1. check to see if cron is running with `ps -ef | grep cron | grep -v grep`
2. If not, restart it with `/sbin/service cron start` or `/sbin/service crond start`

#### Formatting
1. Make sure the last line is terminated by going to it and pressing enter to start a new line.

#### Logging 

You can redirect stdout and stderr to a file. The exact syntax for capturing output may vary depending on what shell cron is using. Here are two examples which save all output to a file at `/tmp/mycommand.log`:

 ```
1 2 * * * /path/to/your/command &>/tmp/mycommand.log
1 2 * * * /path/to/your/command >/tmp/mycommand.log 2>&1
```
