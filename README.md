[![Build Status](https://travis-ci.org/morgsj/MidiControl.svg?branch=main)](https://travis-ci.org/morgsj/MidiControl)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/morgsj/MidiControl/issues)
[![contributions welcome](https://img.shields.io/badge/version-WIP-red.svg?style=flat)](https://github.com/morgsj/MidiControl/issues)
# Midi Control (work in progress)

Midi Control is a MacOS application that enables the triggering of keyboard shortcuts through input from MIDI devices.

## Installation


## Getting Started

Once the program has been installed, use this manual to set up MIDI devices, then program desired macros.

## Devices

Any MIDI device that has been connected to the computer the program has been installed on can be used with this program. Click on the `Manage Devices` button in the main window to open up the Device Manager.

The Device Manager displays all devices: both ones that are currently connected to the computer, and ones that have previously been connected. The program regularly checks whether devices are connected or not, but if you believe a device should have appeared, clicking `Refresh` will manually perform the check for device connections.

Any additional MIDI entites will also show up in this menu. If these are present, or if MIDI devices will no longer be of use, pressing the `Forget Devices` button will remove these devices from the menu, and prohibit them from being the connection from any preset (see below).

In case that a MIDI device has been forgotten unintentionally, you can restore it by finding the Forgotten Devices Manager in `Help -> Forgotten Devices` in the menu bar. Select the device and click `Restore`.

## Presets

A preset represents a batch of MIDI-activated macros, which can be turned on and off all together. Presets could hold a set of similar commands, or shortcuts for a certain application etc.



## Macros


