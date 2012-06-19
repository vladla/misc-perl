## server-log-parser

### Log format

The script assumes the use of the "combined" log format. This is the default format for nginx. For the curious, here's what the configuration looks like:

```
log_format combined '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent"';
```

nginx uses this format by default, so you don't have to configure anything to use this script.

If you're using Apache, there are instructions for using the combined format here (search for "Combined Log Format"): https://httpd.apache.org/docs/current/logs.html

The configuration looks like this:

```
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"" combined
CustomLog log/access_log combined
```



### Generate the report

The parser lets the shell handle the I/O so you'll run it with something like this:

```bash
$ perl logParser.pl < access.log > report.txt
```

### Options

#### Referrer blacklist

A list of domains to ignore when counting referrers. These domains won't appear in your referrers list. 

You can use this to ignore referrals coming from pages within your own site. On robert.io I would do so with this configuration:

```perl
my %refBlacklist = (
    "robert.io" => 1,
    "www.robert.io" => 1,
);
```

### To-do

* Show search keywords 
* Display information about spiders - Data would have to be parsed (probably from an external file) to associate user-agents with known spiders. The script could just skip the spider stats if the file doesn't exist.
* Show stats for last 30 days
