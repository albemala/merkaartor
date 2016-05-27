#!/usr/bin/perl

use common::sense;

for my $file (@ARGV) {
    print "Processing $file...\n";
    # File looks like this:
    # merkaartor-0.18.2-105-g9071144-64bit.exe
    if ($file =~ m!merkaartor-([0-9.]*)-([0-9]+-[a-z0-9]{8})?-?([0-9]+bit).exe!) {
        my ($short, $version, $tag, $arch) = ($&, $1, $2, $3);
        print "Short name = '$short'\n";
        print "Version = '$version'\n";
        print "Tag = '$tag'\n";
        print "Arch = '$arch'\n";
        my $repo = "";
        my $vstring = "";
        if (length $tag) {
            $repo = "nightly";
            $vstring = "$version-$tag";
        } else {
            $repo = "release";
            $vstring = "$version";
        }
        my $cmd = "curl -T '$file' -ukrakonos:$ENV{BINTRAY_TOKEN} https://api.bintray.com/content/krakonos/$repo/Merkaartor/$vstring/$short";
        system($cmd) and die "Failed to upload file $file."; # And means or... if exit code wasn't 0
        if ($repo eq "nightly") {
            #Autopublish nightly builds
            system "curl -T '$file' -ukrakonos:$ENV{BINTRAY_TOKEN} https://api.bintray.com/content/krakonos/$repo/Merkaartor/$vstring/publish";
        }
        print "\n";
    } else {
        print "Filename '$file' does not match!\n";
    }
}

