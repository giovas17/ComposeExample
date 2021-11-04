#!/bin/bash

function config_emulator_settings() {
  adb shell "settings put global window_animation_scale 0.0"
  adb shell "settings put global transition_animation_scale 0.0"
  adb shell "settings put global animator_duration_scale 0.0"
  adb shell "settings put secure show_ime_with_hard_keyboard 0"
  adb shell "am broadcast -a com.android.intent.action.SET_LOCALE --es com.android.intent.extra.LOCALE EN"
}

function wait_emulator_to_be_ready() {
  adb devices | grep emulator | cut -f1 | while read line; do adb -s $line emu kill; done
  emulator -avd "test" -verbose -no-boot-anim -no-snapshot-save -no-window -accel off -gpu off -skin 1440x2880 -noaudio &
  boot_completed=false
  adb wait-for-device shell <<ENDSCRIPT
      echo -n "Waiting for device to boot "
      echo "" > /data/local/tmp/zero
      getprop dev.bootcomplete > /data/local/tmp/bootcomplete
      while cmp /data/local/tmp/zero /data/local/tmp/bootcomplete; do
      {
          echo -n "."
          sleep 1
          getprop dev.bootcomplete > /data/local/tmp/bootcomplete
      }; done
      echo "Booted."
      exit
  ENDSCRIPT

  echo "Waiting 30 secs for us to be really booted"
  sleep 30

  echo "Unlocking screen"
  adb shell "input keyevent 82"
}

function start_emulator_if_possible() {
  wait_emulator_to_be_ready
  sleep 1
  config_emulator_settings
}

start_emulator_if_possible