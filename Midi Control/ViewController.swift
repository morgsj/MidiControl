//
//  ViewController.swift
//  Midi Control
//
//  Created by Morgan Jones on 11/03/2021.
//

import Cocoa

class ViewController: NSViewController, PresetViewDelegate {
    
    
    private var presets : [PresetView] = []
    
    private var selectedPreset : PresetView?

    @IBOutlet weak var presetViewerScrollView: NSScrollView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPreset(Preset(name: "ye"))
        addPreset(Preset(name: "we"))
        
        updatePresets()
        
    }
    
    private func addPreset(_ preset: Preset) {
        let newView = PresetView(preset, delegate: self)
        presets.append(newView)
    }
    
    private func updatePresets() {
        
        for i in 0..<presets.count {
            presets[i].frame = NSMakeRect(0, CGFloat(i)*PresetView.HEIGHT, PresetView.WIDTH, PresetView.HEIGHT)
            presetViewerScrollView.addSubview(presets[i])
        }

    }

    func presetSelected(_ pv: PresetView) {
        for presetView in presets {
            if pv.isEqual(to: presetView) {continue;}
            else {presetView.deselect()}
        }
        selectedPreset = pv
    }
    
    func presetDeselected(_ pv: PresetView) {}
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

