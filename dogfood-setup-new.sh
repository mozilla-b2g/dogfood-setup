#!/bin/bash
# download and run the newest dogfood-setup.sh
curl -SsL https://raw.github.com/mozilla-b2g/dogfood-setup/master/dogfood-setup.sh | sh -s $1
