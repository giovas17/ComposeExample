#!/bin/bash

function config_emulator_settings() {
  adb shell "settings put global window_animation_scale 0.0"
  adb shell "settings put global transition_animation_scale 0.0"
  adb shell "settings put global animator_duration_scale 0.0"
  adb shell "settings put secure show_ime_with_hard_keyboard 0"
  adb shell "am broadcast -a com.android.intent.action.SET_LOCALE --es com.android.intent.extra.LOCALE EN"
}

function wait_emulator_to_be_ready() {
  adb root
  adb devices | grep emulator | cut -f1 | while read line; do adb -s $line emu kill; done
  adb shell avbctl disable-verification
  adb disable-verity
  adb emu sensor set acceleration 5:5:5
  emulator -avd "test" -verbose -no-boot-anim -no-snapshot -no-window -accel off -gpu host -skin 1440x2880 -noaudio -memory 2048 -debug-all &
  boot_completed=false
  while [ "$boot_completed" == false ]; do
    status=$(adb wait-for-device shell getprop sys.boot_completed | tr -d '\r')
    echo "Boot Status: $status"

    if [ "$status" == "1" ]; then
      boot_completed=true
      echo "Emulator successfully started!"
    else
      sleep 1
    fi
  done
}

function start_emulator_if_possible() {
  wait_emulator_to_be_ready
  sleep 1
  config_emulator_settings
}

start_emulator_if_possible