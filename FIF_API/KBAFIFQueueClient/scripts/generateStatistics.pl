#!/usr/bin/perl -w
#
# Perl script that creates FIF request statistics
#
# Usage:
#   generateStatistics.pl <kba-response-directory> <output-file>
#
# @author Olivier Goethals, AMS Management Systens
# @date 2003-07-23
#

# The default name of the output file
my $outputfile = "stats.csv";

# Read the arguments
my $dir = $ARGV[0];

if (@ARGV == 2) {
    $outputfile = $ARGV[1];
}

# Bail out if there are not enough arguments
if (!$dir) {
    print "Creates FIF request statistics. \n";
    print "Usage: generateStatistics.pl <kba-response-directory> <output-file>\n";
    exit(0);
}

# Open the directory
opendir(DIR, $dir) || die "Cannot open directory $dir: $!";

# Create the output file
open(OUTPUT, ">$outputfile") || die("Error Writing to Output File: $outputfile $!");
print OUTPUT "Action,Transaction ID,Status,Error\n";

print "Processing directory...\n";

# Loop through the directory
my $filecount = 0;
while (defined($file = readdir(DIR))) {
    if ($file =~ /\.xml/) {
        $filecount++;

        # Open the XML file
        open(INPUT, "$dir/$file") || die "Cannot open $file: $!";

        my @input = <INPUT>;
        my $action = "";
        my $transactionID = "";
        my $status = "";
        my $error = "";

        foreach $line (@input) {
            # Populate the action
            if ($line =~ m@.action-name.(...CDATA.)+(.*)(]].)+./action-name.@) {
                $action = $2;
            }
            # Populate the transaction ID
            if ($line =~ m@.transaction-id.(...CDATA.)+(.*)(]].)+./transaction-id.@) {
                $transactionID = $2;
            }
            # Populate the status
            if ($line =~ m@.transaction-result.(...CDATA.)+(.*)(]].)+./transaction-result.@) {
                $status = $2;
            }
            # Populate the status
            if ($line =~ m@.message.(...CDATA.)+(.*)(]].)+./message.@) {
                $error = $2;
                $error =~ s/,/./;
                last;
            }
        }

        print OUTPUT "$action,$transactionID,$status,$error\n";
    }
}
close(OUTPUT);
closedir(DIR);

print "Processed $filecount files.  Wrote output to: $outputfile\n";
