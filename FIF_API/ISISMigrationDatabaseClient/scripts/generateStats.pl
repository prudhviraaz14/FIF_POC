#!/usr/bin/perl -w
#
# Perl script that creates FIF request statistics for the ISIS migration
#
# Usage:
#   generateStatistics.pl <fif-reply-directory> <output-file>
#
# @author Olivier Goethals, AMS Management Systens
# @date 2003-12-18
#

# The default name of the output file
my $outputfile = "isis-stats.txt";

# Read the arguments
my $dir = $ARGV[0];

if (@ARGV == 2) {
    $outputfile = $ARGV[1];
}

# Bail out if there are not enough arguments
if (!$dir) {
    print "Creates FIF request statistics for the ISIS migration. \n";
    print "Usage: generateStats.pl <fif-reply-directory> <output-file>\n";
    exit(0);
}

# Open the directory
opendir(DIR, $dir) || die "Cannot open directory $dir: $!";

# Create the output file
open(OUTPUT, ">$outputfile") || die("Error Writing to Output File: $outputfile $!");

print "Creating report...\n";

# Loop through the directory
my $filecount = 0;
my %command_durations = ();
my %command_successes = ();
my $total_duration = 0;
my $total_successes = 0;
while (defined($file = readdir(DIR))) {
    if ($file =~ /\.xml/) {
        $filecount++;

        # Open the XML file
        open(INPUT, "$dir/$file") || die "Cannot open $file: $!";

        my @input = <INPUT>;
        my $processing_duration = 0;
        my $command = "";
        my $command_duration = 0;
        my $transactionID = "";
        my $status = "";

        foreach $line (@input) {
            # Populate the processing duration if the status is commit
            if ($line =~ m@.processing_duration.(...CDATA.)+(.*)(]].)+./processing_duration.@) {
                $processing_duration = $2;
            }
            # Populate the command
            if ($line =~ m@<(CcmFif.*Cmd)>@) {
                $command = $1;
                $command_duration = 0;
            }
            # Populate the duration
            if ($line =~ m@.command_duration.(...CDATA.)+(.*)(]].)+./command_duration.@) {
                $command_duration = $2;
                $command_durations{$command} += $command_duration;
                $command_successes{$command} += 1;
            }
            # Populate the transaction ID
            if ($line =~ m@.transaction_id.(...CDATA.)+(.*)(]].)+./transaction_id.@) {
                $transactionID = $2;
            }
            # Populate the status
            if ($line =~ m@.transaction_state.(...CDATA.)+(.*)(]].)+./transaction_state.@) {
                $status = $2;
                if ($status eq "ROLLED_BACK") {
                    $processing_duration = 0;
                    last;
                } else {
                    $total_duration += $processing_duration;
                    $total_successes += 1;
                }
            }
        }
    }
}

print OUTPUT "===================\n";
print OUTPUT " Overal statistics\n";
print OUTPUT "===================\n\n";
print OUTPUT "Total commands:                $filecount\n";
print OUTPUT "Successes:                     $total_successes\n";
print OUTPUT "Failures:                      ".($filecount - $total_successes)."\n\n";
print OUTPUT "Total duration of successes:   ".($total_duration)." seconds (".($total_duration/60)." minutes)\n";
print OUTPUT "Average duration of successes: ".($total_duration/$total_successes)." seconds\n";


my %averages = ();
foreach $k (sort keys %command_durations) {
    my $average = $command_durations{$k} / $command_successes{$k};
    $averages{$k} = $average;
}

format OUTPUT =
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @######## @######## @#####.##
$one, $two, $three, $four
.

print OUTPUT "\n\n\n";

print OUTPUT "====================\n";
print OUTPUT " Command statistics\n";
print OUTPUT "====================\n\n";

print OUTPUT "Command name                          Total    Success  Average\n";
print OUTPUT "------------------------------------- -------- -------- ---------\n";

foreach $j (sort { $averages{$b} <=> $averages{$a} } keys %averages) {
    $one = $j;
    $two = ($command_durations{$j}/1000);
    $three = $command_successes{$j};
    $four = ($averages{$j}/1000);
    write(OUTPUT);
}

close(OUTPUT);
closedir(DIR);

print "Processed $filecount files.  Wrote output to: $outputfile\n";
