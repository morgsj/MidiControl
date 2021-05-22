//
//  ViewController.swift
//  Midi Control
//
//  Created by Morgan Jones on 11/03/2021.
//

import Cocoa
import CoreMIDI

class ViewController: NSViewController {
    
    /* Reference to managed context object */
    let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    /* List of preset views */
    public var presetViews : [PresetCompactView] = []
    
    /* The current preset view that is selected to be displayed in the preset editor */
    private var selectedPresetView : PresetCompactView?
    
    /* The preset editor view */
    private var presetEditor : PresetEditorView?
    
    /* The device manager pop up */
    private var deviceManager : DeviceManager?

    @IBOutlet weak var presetViewerScrollView: NSScrollView!
    @IBOutlet weak var presetEditorContainer: NSView!
    @IBOutlet weak var manageDeviceButton: NSButton!
    @IBOutlet weak var addPresetButton: NSButton!
    @IBOutlet weak var removePresetButton: NSButton!
    @IBOutlet weak var movePresetUpButton: NSButton!
    @IBOutlet weak var movePresetDownButton: NSButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        presetEditor = PresetEditorView(self)
        presetEditorContainer.addSubview(presetEditor!)
        
        fetchPresets()
        updatePresetViews()
        
        Connection.populateConnections(context: context)
        
        manageDeviceButton.action = #selector(openDeviceWindow)
    }
    
    
    private func newPreset() {
        // Create the new preset
        let newPreset = Preset(context: self.context)
        newPreset.name = "New Preset"
        newPreset.isEnabled = false
        newPreset.connection = nil
        newPreset.macros = []
        
        // Save the new preset
        do {
            try self.context.save()
            print("\nSaved preset\n")
        }
        catch {print("\n\(error)\n")}
        
        addPresetView(newPreset)
    }
    
    private func addPresetView(_ preset: Preset) {
        let newView = PresetCompactView(preset, delegate: self)
        presetViews.append(newView)
    }
    
    public func fetchPresets() {
        // Fetch data from core data
        do {
            let presets : [Preset] = try context.fetch(Preset.fetchRequest())
            
            presetViews = []
            for preset in presets {
                addPresetView(preset)
            }
        } catch {
            
        }
    }
    
    public func updatePresetViews() {
        for i in 0..<presetViews.count {
            presetViews[i].frame = NSMakeRect(0, CGFloat(i)*PresetCompactView.HEIGHT, PresetCompactView.WIDTH, PresetCompactView.HEIGHT)
            presetViews[i].refresh()
            presetViewerScrollView.addSubview(presetViews[i])
        }
        
        if presetViews.count > 0 {
            if selectedPresetView == nil || !presetViews.contains(selectedPresetView!) {
                presetSelected(presetViews[0])
            }
        }
        
        do {
            try context.save()
            print("Saved data")
        } catch {fatalError("Couldn't save")}

    }
    
    @objc func openDeviceWindow() {
        deviceManager = DeviceManager(self)
    }
    
    @IBAction func addPresetButtonClicked(_ sender: Any) {
        newPreset()
        updatePresetViews()
    }
    
    @IBAction func removePresetButtonClicked(_ sender: Any) {
        if let pv = selectedPresetView {
            presetViews.removeAll {$0 == pv}
            pv.removeFromSuperview()
            context.delete(pv.preset)
            updatePresetViews()
        }
    }
    
    //MARK: Functionality to move preset compact views around
    
    @IBAction func movePresetUpButtonPressed(_ sender: Any) {
        if let selectedPresetView = selectedPresetView {
            let index : Int = presetViews.firstIndex(of: selectedPresetView) ?? -1
            if index > 0 && index < presetViews.count {
                presetViews[index] = presetViews[index-1]
                presetViews[index-1] = selectedPresetView
                updatePresetViews()
            }
        }
    }
    
    @IBAction func movePresetDownButtonPressed(_ sender: Any) {
        if let selectedPresetView = selectedPresetView {
            let index : Int = presetViews.firstIndex(of: selectedPresetView) ?? -1
            if index < presetViews.count - 1 && index >= 0 {
                presetViews[index] = presetViews[index+1]
                presetViews[index+1] = selectedPresetView
                updatePresetViews()
            }
        }
    }
}

extension ViewController : PresetViewDelegate {
    func presetSelected(_ pv: PresetCompactView) {
        for presetView in presetViews {
            if pv.isEqual(to: presetView) {continue;}
            else {presetView.deselect()}
        }
        pv.select()
        
        print("\nPreset View Selected\n")
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
