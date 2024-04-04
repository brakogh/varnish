#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/varnish/Library/varnish
#   Description: Library for varnish testing
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

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGES=${PACKAGES:-"varnish"}
PHASE=${PHASE:-"Test"}

rlJournalStart
    rlPhaseStartSetup
        rlRun "rlImport varnish/varnish"
    rlPhaseEnd

    if [[ ${PHASE} =~ "Test" ]]; then
        rlPhaseStartTest "Test service start and stop"
            rlRun "echo Quack\! > /var/www/html/duck" 0 "Creating test file"
            rlRun "rlServiceStart httpd" 0 "Starting HTTP server"
	    CONF=$varnishCONFDIR/default.vcl
	    rlRun "rlFileBackup $CONF"
	    rlRun "sed -i 's/8080/80/' $CONF" 0 "Changing port of backed server"
            rlRun "varnishStart" 0 "Starting Varnish server"
	    sleep 5

            rlRun -s "curl -4 -v -x $(hostname):6081 $(hostname)/duck" 0 \
                "Downloading file via Varnish proxy"
            rlAssertGrep 'Quack!' ${rlRun_LOG}

            rlRun "varnishStop" 0 "Stopping Varnish server"
	    rlRun "rlFileRestore $CONF"
            rlRun "rlServiceStop httpd" 0 "Stopping HTTP server"
            rlRun "rm /var/www/html/duck" 0 "Deleting test file"
        rlPhaseEnd
    fi

rlJournalPrintText
rlJournalEnd
