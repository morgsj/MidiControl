//
//  ViewController.swift
//  Midi Control
//
//  Created by Morgan Jones on 11/03/2021.
//

import Cocoa

class ViewController: NSViewController, PresetViewDelegate {
    
    
    private var presets : [PresetListView] = []
    
    private var selectedPresetView : PresetListView?
    private var presetEditor : PresetEditorView?
    
    private var deviceManager : DeviceManager?

    @IBOutlet weak var presetViewerScrollView: NSScrollView!
    @IBOutlet weak var presetEditorContainer: NSView!
    @IBOutlet weak var manageDeviceButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presetEditor = PresetEditorView()
        presetEditorContainer.addSubview(presetEditor!)
        
        addPreset(Preset(name: "preset 1", connection: Connection.connections[0]))
        addPreset(Preset(name: "preset 2", connection: Connection.connections[1]))
        
        updatePresets()
        
        
        manageDeviceButton.action = #selector(openDeviceWindow)
    }
    
    private func addPreset(_ preset: Preset) {
        let newView = PresetListView(preset, delegate: self)
        presets.append(newView)
    }
    
    private func updatePresets() {
        
        for i in 0..<presets.count {
            presets[i].frame = NSMakeRect(0, CGFloat(i)*PresetListView.HEIGHT, PresetListView.WIDTH, PresetListView.HEIGHT)
            presetViewerScrollView.addSubview(presets[i])
        }
        
        if (presets.count > 0) {
            presets[0].select()
            selectedPresetView = presets[0]
            presetEditor!.preset = presets[0].preset
        }

    }

    func presetSelected(_ pv: PresetListView) {
        for presetView in presets {
            if pv.isEqual(to: presetView) {continue;}
            else {presetView.deselect()}
        }
        selectedPresetView = pv
        presetEditor!.preset = pv.preset
    }
    
    func presetDeselected(_ pv: PresetListView) {}
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @objc func openDeviceWindow() {
        print("open")
        deviceManager = DeviceManager()
        
    }
}

