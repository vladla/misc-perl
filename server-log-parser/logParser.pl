#!/usr/bin/perl
use strict;
use warnings;

#   Copyright (C) 2012 Robert Picard
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#   You can contact me at mail@robert.io


#
# Configuration
#

# A list of domains to ignore when counting referrers. These domains won't appear in your referrers list.


# The example provided would ignore referrals coming from pages
# within your own site. Make sure to replace "yourdomain.com" with 
# your domain and remove the "#" to un-comment the line.

my %refBlacklist = (
#    "yourdomain.com" => 1,
#    "www.yourdomain.com" => 1,
);


#
# Variable initialization
#

# Total number of records parsed
my $totalRequests = 0;

# Total number of unique IP addresses
my $uniqueAddrs = 0;

# Total bytes sent minus request headers
my $totalBodyBytes = 0;

# Average body bytes sent for each request
my $avgBodyBytes = 0;

# Track the requests sent by various spiders
# my %spiderRequests = ();

# Where on the web are the visitors coming from?
my %refSites = ();

# Unique IP addresses
my %ipAddrs = ();

# Which files are being requested?
my %filesRequested = ();

# Files encountering 404 errors
my %files404 = ();


#
# Data
#

# For the timestamp
my %months = (
    0 => 'January',
    1 => 'February',
    2 => 'March',
    3 => 'April',
    4 => 'May',
    5 => 'June',
    6 => 'July',
    7 => 'August',
    8 => 'September',
    9 => 'October',
    10 => 'November',
    11 => 'December');


# A hash of known spider user-agents
# my %spiders = ();

#
# Let the parsing begin!
#

## Use the shell for I/O and read each line of the log
while (my $line = <STDIN>) {
    
    # Use a regex to parse the log format. This assumes use of the
    # combined log format. This is the default for nginx
    # Assign values to the same variable names used in "log_format"
    # http://nginx.org/en/docs/http/ngx_http_log_module.html#log_format
    
    my ($remote_addr,
        $remote_user,,
        $time_local,
        $request,
        $status,
        $body_bytes_sent,
        $http_referer,
        $http_user_agent) = ($line =~ /^(\d+\.\d+\.\d+\.\d+)\s-\s(.*?)\s\[(.*?)\]\s\"(.*?)\"\s(\d+?)\s(\d+?)\s\"(.*?)\"\s\"(.*?)\"/);

    # Strip everything but the file path from the request string
    my @requestParts = split(" ", $request) if $request;
    $request = $requestParts[1] if $requestParts[1];

    # Increment the request counter
    $totalRequests++;
    
    # Increment or create the counter for requests from this IP address
    $ipAddrs{$remote_addr}++ if $remote_addr;

    # Increment or create the counter for referrals from this referrer
    # if it's not on the blacklist
    $http_referer =~ /^.*\:\/\/(.*?)\//;
    my $refDomain = $1;
    if ($http_referer ne '-' && $http_referer && !exists $refBlacklist{$refDomain}) {
        $refSites{$http_referer}++;
    }

    # Update total body bytes sent
    $totalBodyBytes += $body_bytes_sent;

    next unless $request;
    
    # Increment or create the counter for requests for this file
    $filesRequested{$request}++ if $status == '200';
    
    # Update 404 log
    $files404{$request}++ if $status == '404';

}

#
# Calculations
#

$avgBodyBytes = $totalBodyBytes / $totalRequests;

$uniqueAddrs = keys %ipAddrs;

#
# Generate the report
#

my $report = "";

## Add some meta information

# Small header
$report .= "Log parser report\n";

# Include the current time in the report
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);

$mon = $months{$mon};;
$year += 1900;

$report .= "\nGenerated: $mon $mday, $year at $hour hours, $min minutes, and $sec seconds.\n";

$report .= "\n---\n";

$report .= "\nStats:\n";

$report .= "\nTotal requests: $totalRequests\n";

$report .= "\nUnique IP addresses: $uniqueAddrs\n";

$report .= "\nTotal body bytes sent: $totalBodyBytes\n";

$report .= "\nAverage body bytes sent: $avgBodyBytes\n";

# Files Requested

$report .= "\n\nRequests (status 200):\n";

$report .= "\n#\t\t\tFile\n\n";

foreach my $thisFile (sort {$filesRequested{$b} <=> $filesRequested{$a}} keys %filesRequested) {
    my $thisCount = $filesRequested{$thisFile};
    
    $report .= "$thisCount\t\t\t$thisFile\n";
}

# 404 Errors

$report .= "\n\nRequests (status 404):\n";

$report .= "\n#\t\t\tFile\n\n";

foreach my $thisFile (sort {$files404{$b} <=> $files404{$a}} keys %files404) {
    my $thisCount = $files404{$thisFile};

    $report .= "$thisCount\t\t\t$thisFile\n";
}

## Referrers

$report .= "\n\nReferrers:\n";

$report .= "\n#\t\t\tReferrer\n\n";

foreach my $thisRef (sort {$refSites{$b} <=> $refSites{$a}} keys %refSites) {
    my $thisCount = $refSites{$thisRef};

    $report .= "$thisCount\t\t\t$thisRef\n";
}

print $report;
