#!/bin/bash

#================================================================#
# Copyright (c) 2010-2011 Zipline Games, Inc.
# All Rights Reserved.
# http://getmoai.com
#================================================================#

#----------------------------------------------------------------#
# path to Android SDK folder (on Windows, you MUST use forward 
# slashes as directory separators, e.g. C:/android-sdk)
#----------------------------------------------------------------#

	android_sdk_root="/Users/johnvandewater/Development/adt-bundle-mac-x86_64-20130729/sdk"

#----------------------------------------------------------------#
# space-delimited list of source lua directories to add to the 
# application bundle and corresponding destination directories in 
# the assets directory of the bundle
#----------------------------------------------------------------#

	src_dirs=( "/Users/johnvandewater/Development/GDD" )
	dest_dirs=(	"lua" )

#----------------------------------------------------------------#
# debug & release settings
# you must define key store data in order to build for release
#----------------------------------------------------------------#

	debug=true
	key_store=pygo-release-key.keystore
	key_alias=pygo
	key_store_password=A1LY5TowC6se6uP
	key_alias_password=0a1Zn2H6s8m7wqA