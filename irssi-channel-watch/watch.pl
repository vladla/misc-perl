# This script shows libnotify desktop notifications for messages
# in watched channels.
#
# It is based on a script by Luke Macken: 
# http://lewk.org/blog/2006/05/19/irssi-notify
#
# Copyright (C) 2012 Robert Picard
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


use strict;
use warnings;
use Irssi;
use vars qw($VERSION %IRSSI);

$VERSION = '0.01';
%IRSSI = (
    authors => 'Robert Picard',
    contact => 'mail@robert.io',
    name => 'Channel Watcher',
    description => 'Shows desktop notifications for messages in tracked channels.',
    license => 'GNU GPL v3'
);

my %watched_channels = (
    '#duckduckgo' => undef,
    '#roberttestchannel' => undef,
);

sub notify {
    
    # Parameters passed by Irssi when the function is called
    my ($dest, $text, $stripped) = @_;

    # We only want to notify for watched channels
    # TODO: Move this list to settings
    return unless exists $watched_channels{"$dest->{target}"};
    
    # Strip any weird characters just in case they break our notification
    $stripped =~ s/[^a-zA-Z0-9 \.\,\!\?\@\:\>\<]//g;
    
    # Don't show alerts for our own messages
    # This will probably be made moot when I stop showing alerts when we
    # are viewing the channel.
    
    # Accounts for regular messages and /me messages
    $stripped =~ m/^\s*(?:<)?(.*?)(?:>)?\s+/;

    my $from_nick = $1 || '';
    $from_nick =~ s/^[\@\+]//;
    
    return if !$from_nick || $dest->{server}->{nick} eq $from_nick;

    # Send the notification command
    system("notify-send -t 5000 '$dest->{target}' ' \n$stripped'");
}

sub watch {
    # Usage /watch <command>

    # data - contains the parameters for /HELLO
    # server - the active server in window
    # witem - the active window item (eg. channel, query)
    
    my ($data, $server, $witem) = @_;

    # Friendly error messages

    unless ($server && $server->{connected}) {
        Irssi::print("Not connected to a server.");
        return;
    }
    
    unless ($data) {
        Irssi::print("No commands given.");
        return;
    }

    unless ($witem) {
        Irssi::print("No active channel or query in window.");
        return;
    }
    
    # Run the subcommand
    Irssi::command_runsub('watch', $data, $server, $witem);
}

sub watch_this {
    my ($data, $server, $witem) = @_;
    
}

# sub toggle {
# 
# }

# Signal for text printed on the screen
Irssi::signal_add('print text', 'notify');

# Bind to /watch commands
Irssi::command_bind('watch', 'watch');
Irssi::command_bind("watch this", 'watch_this');

# Don't show notifications for channels we are
# viewing. Toggle on switching to / from.
# Irssi::signal_add('window changed', 'toggle');
