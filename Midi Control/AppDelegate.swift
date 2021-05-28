//
//  AppDelegate.swift
//  Midi Control
//
//  Created by Morgan Jones on 11/03/2021.
//

import Cocoa

import AudioKit 
import CoreMIDI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
   
    static let midi = MIDI()
    static var midiListener: MIDIReceiver? = nil
    
    static let midiMessageSemaphore = DispatchSemaphore(value: 1)
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        let unusedMenu = NSMenu(title: "Unused")
        NSApplication.shared.helpMenu = unusedMenu
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        AppDelegate.midi.openInput()
        
        AppDelegate.midiListener = MIDIReceiver(context: self.persistentContainer.viewContext)
        AppDelegate.midi.addListener(AppDelegate.midiListener!)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        AppDelegate.midi.closeInput()
    }

    @IBAction func githubButtonPressed(_ sender: Any) {
        let url = URL(string: "https://www.github.com/morgsj/MidiControl")!
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func coffeeButtonPressed(_ sender: Any) {
        let url = URL(string: "https://www.buymeacoffee.com/morganj")!
        NSWorkspace.shared.open(url)
    }
    
    
    // MARK: Core Data
    lazy var persistentContainer: NSPersistentContainer = {
            let container = NSPersistentContainer(name: "DataModel")
            container.loadPersistentStores { description, error in
                if let error = error {
                    fatalError("Unable to load persistent stores: \(error)")
                }
            }
            return container
        }()
    
    
    var forgottenDevicesManager: ForgottenDevicesManager?
    @IBAction func loadForgottenDevices(_ sender: Any) {
        forgottenDevicesManager = ForgottenDevicesManager(context: persistentContainer.viewContext)
    }
    
}

