#!/bin/bash

#
# Copyright (C) 2015 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Help script to restart adb with specific adb keys.

# usage:
# source setAdbKeys.sh adb_keys_directory

if [ "$#" -ne 1 ] || ! [ -d "$1" ]; then
  echo "Usage: source $0 ADB_KEYS_DIRECTORY"
else
  export ADB_VENDOR_KEYS=
  for key in "$1"/*adb_key
  do
    if [ "$ADB_VENDOR_KEYS" == "" ]; then
      ADB_VENDOR_KEYS="$key"
    else
      ADB_VENDOR_KEYS=$ADB_VENDOR_KEYS:"$key"
    fi
  done
  export ADB_VENDOR_KEYS
fi
