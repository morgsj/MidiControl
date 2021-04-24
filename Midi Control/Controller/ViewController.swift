//
//  ViewController.swift
//  Midi Control
//
//  Created by Morgan Jones on 11/03/2021.
//

import Cocoa

class ViewController: NSViewController {
    
    public var presets : [PresetView] = []
    
    private var selectedPresetView : PresetView?
    
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
        
        addPreset(Preset(name: "preset 1", connection: Connection.connections[0]))
        addPreset(Preset(name: "preset 2", connection: Connection.connections[1]))
        
        updatePresets()
        
        manageDeviceButton.action = #selector(openDeviceWindow)
    }
    
    private func addPreset(_ preset: Preset) {
        let newView = PresetView(preset, delegate: self)
        presets.append(newView)
    }
    
    public func updatePresets() {
        
        for i in 0..<presets.count {
            presets[i].frame = NSMakeRect(0, CGFloat(i)*PresetView.HEIGHT, PresetView.WIDTH, PresetView.HEIGHT)
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
        presets.append(PresetView(Preset(name: "New Preset"), delegate: self))
        updatePresets()
    }
    
    @IBAction func removePresetButtonClicked(_ sender: Any) {
        
    }
}

extension ViewController : PresetViewDelegate {
    func presetSelected(_ pv: PresetView) {
        for presetView in presets {
            if pv.isEqual(to: presetView) {continue;}
            else {presetView.deselect()}
        }
        pv.select()
        selectedPresetView = pv
        presetEditor!.preset = pv.preset
        
        removePresetButton.isEnabled = true
    }
    
    func presetDeselected(_ pv: PresetView) {
        pv.deselect()
        removePresetButton.isEnabled = false
    }
    
    func alteredPreset(_ pv: PresetView) {
        presetEditor?.preset = pv.preset
    }
}
