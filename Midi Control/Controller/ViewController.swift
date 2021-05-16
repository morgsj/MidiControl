//
//  ViewController.swift
//  Midi Control
//
//  Created by Morgan Jones on 11/03/2021.
//

import Cocoa
import AudioKit
import CoreMIDI

class ViewController: NSViewController {
    
    public var presets : [PresetCompactView] = []
    
    private var selectedPresetView : PresetCompactView?
    
    private var presetEditor : PresetEditorView?
    
    private var deviceManager : DeviceManager?

    @IBOutlet weak var presetViewerScrollView: NSScrollView!
    @IBOutlet weak var presetEditorContainer: NSView!
    @IBOutlet weak var manageDeviceButton: NSButton!
    
    @IBOutlet weak var addPresetButton: NSButton!
    @IBOutlet weak var removePresetButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presetEditor = PresetEditorView(self)
        presetEditorContainer.addSubview(presetEditor!)
        
//        addPreset(Preset(name: "preset 1", connection: Connection.connections[0]))
//        addPreset(Preset(name: "preset 2", connection: Connection.connections[1]))
        
        updatePresets()
        
        manageDeviceButton.action = #selector(openDeviceWindow)
    }
    
    private func addPreset(_ preset: Preset) {
        let newView = PresetCompactView(preset, delegate: self)
        presets.append(newView)
    }
    
    public func updatePresets() {
        
        for i in 0..<presets.count {
            presets[i].frame = NSMakeRect(0, CGFloat(i)*PresetCompactView.HEIGHT, PresetCompactView.WIDTH, PresetCompactView.HEIGHT)
            presets[i].refresh()
            presetViewerScrollView.addSubview(presets[i])
        }
        
        if (presets.count > 0) {
            presetSelected(presets[0])
        }

    }
    
    @objc func openDeviceWindow() {
        deviceManager = DeviceManager(self)
    }
    
    @IBAction func addPresetButtonClicked(_ sender: Any) {
        presets.append(PresetCompactView(Preset(name: "New Preset"), delegate: self))
        updatePresets()
    }
    
    @IBAction func removePresetButtonClicked(_ sender: Any) {
        
    }
}

extension ViewController : PresetViewDelegate {
    func presetSelected(_ pv: PresetCompactView) {
        for presetView in presets {
            if pv.isEqual(to: presetView) {continue;}
            else {presetView.deselect()}
        }
        pv.select()
        selectedPresetView = pv
        presetEditor!.preset = pv.preset
        
        removePresetButton.isEnabled = true
    }
    
    func presetDeselected(_ pv: PresetCompactView) {
        pv.deselect()
        removePresetButton.isEnabled = false
    }
    
    func alteredPreset(_ pv: PresetCompactView) {
        presetEditor?.preset = pv.preset
    }
}
