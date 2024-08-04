#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   lib.sh of /CoreOS/varnish/Library/varnish
#   Description: Library for Varnish testing
#   Author: Ondrej Ptak <optak@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2016 Red Hat, Inc.
#
#   This program is free software: you can redistribute it and/or
#   modify it under the terms of the GNU General Public License as
#   published by the Free Software Foundation, either version 2 of
#   the License, or (at your option) any later version.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE.  See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program. If not, see http://www.gnu.org/licenses/.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   library-prefix = varnish
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

true <<'=cut'
=pod

=head1 NAME

varnish/varnish - Library for Varnish testing

=head1 DESCRIPTION

Collection of utilities which make Varnish testing easier.

=head2 USAGE

To use this library in a test, add the following line to its C<Makefile>:

	@echo "RhtsRequires:    library(varnish/varnish)" >> $(METADATA)

In C<runtest.sh>, import the library as follows:

	rlImport varnish/varnish

Be sure to import the library B<before> checking installed packages with
C<rlAssertRpm>.

The rest is quite straightforward:

	rlLog "Configuration file: ${varnishCONF}"

	rlRun "varnishStart" 0 "Starting Varnish proxy"
	rlRun "varnishRestart" 0 "Restarting Varnish proxy"
	rlRun "varnishStop" 0 "Stopping Varnish proxy"

=cut

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Variables
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

true <<'=cut'
=pod

=head1 VARIABLES

Below is the list of global variables.

=over

=item varnishMAIN

Name of main package.

=back

=cut

export varnishPACKAGE=${varnishPACKAGE:-"varnish"}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Functions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

true <<'=cut'
=pod

=head1 FUNCTIONS

=head2 varnishStart

Starts varnish service and waits for the configured port(s) to start listening.

=cut

varnishStart() {
    rlServiceStart $varnishMAIN
}

true <<'=cut'
=pod

=head2 varnishStop

Stop C<varnish> service and performs a cleanup. This includes deleting the PID
file, lock file and shared memory segments.

=cut

varnishStop() {
    rlServiceStop $varnishMAIN
}

true <<'=cut'
=pod

=head2 varnishRestart

Restart C<varnish> service; equivalent to C<varnishStop> + C<varnishStart>.

=cut

varnishRestart() {
    varnishStop
    varnishStart
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Execution
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

true <<'=cut'
=pod

=head1 EXECUTION

This library supports direct execution. When run as a task, phases
provided in the PHASE environment variable will be executed.
Supported phases are:

=over

=item Test

Run the self test suite.

=back

=cut

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Verification
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   When the library is first loaded, detect the varnish package which is being
#   tested from the PACKAGES variable. If this detection fails for some reason,
#   exit with 1.

varnishLibraryLoaded() {
    ret=0
    # setup path variables if running in collection
    if echo $COLLECTIONS|grep "varnish";then
        varnishCOLLECTION_NAME=`echo $COLLECTIONS|grep -Eo '(rh-)?\bvarnish[0-9]*\b'|tail -1`
        if [ "$varnishCOLLECTION_NAME" == "" ];then
            rlFail "Failed to detect varnish collection name"
            rlLog "COLLECTIONS=$COLLECTIONS"
            return 1
        fi
        varnishCOLLECTION=1
        varnishMAIN=${varnishCOLLECTION_NAME}-varnish
        varnishROOTPREFIX=/var/opt/rh/$varnishCOLLECTION_NAME
        varnishCONFDIR=/etc/opt/rh/$varnishCOLLECTION_NAME/varnish
        varnishLOGDIR=/var/opt/rh/$varnishCOLLECTION_NAME/log/varnish
    else
        varnishCOLLECTION=0
        varnishMAIN=varnish
        varnishCONFDIR=/etc/varnish
        varnishLOGDIR=/var/log/varnish
    fi

    # print variables
    rlLogInfo "COLLECTIONS=$COLLECTIONS"
    rlLogInfo "varnishCOLLECTION=$varnishCOLLECTION"
    rlLogInfo "varnishCOLLECTION_NAME=$varnishCOLLECTION_NAME"
    rlLogInfo "varnishMAIN=$varnishMAIN"
    rlLogInfo "varnishROOTPREFIX=/var/opt/rh/$varnishCOLLECTION_NAME"
    rlLogInfo "varnishCONFDIR=$varnishCONFDIR"
    rlLogInfo "varnishLOGDIR=$varnishLOGDIR"

    rlAssertRpm $varnishMAIN || ret=1
    return $ret

}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Authors
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

true <<'=cut'
=pod

=head1 AUTHORS

=over

=item *

Ondrej Ptak <optak@redhat.com>

=back

=cut
