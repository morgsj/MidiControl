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
    static var PresetEditor : PresetEditorView?
    
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
        
        ViewController.PresetEditor = PresetEditorView(self)
        presetEditorContainer.addSubview(ViewController.PresetEditor!)

//        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Connection")
//        let predicate = NSPredicate(format: "forgotten == 0")
//        request.predicate = predicate
//
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
//
//        do {
//            print("\nabout to delete")
//            try context.execute(deleteRequest)
//            print("deleted all connections")
//        } catch {fatalError("Couldn't delete")}

        

        Connection.refreshConnections(context: context, shouldFetch: true)
        
        fetchPresets()
        
        for preset in Preset.presets {print("\nPreset connection: \(preset.connection)\n")}
        
        presetViews = []
        for preset in Preset.presets {
            addPresetView(preset)
        }
        updatePresetViews()

        manageDeviceButton.action = #selector(openDeviceWindow)
        
        //MARK: Background connection checker thread
        Thread {
            while (true) {
                DispatchQueue.main.async {
                    Connection.refreshConnections(context: self.context, shouldFetch: false)
                    self.deviceManager?.deviceTable?.reloadData()
                }
                
                for pv in self.presetViews {
                    if let connection = pv.preset.connection {
                        if !Connection.connectionWhitelist().contains(connection) {
                             
                            DispatchQueue.main.async {
                                pv.preset.connection = nil
                                pv.statusLabel.stringValue = "Disconnected"
                                pv.presetConnection.stringValue = "No Connection"
                            }
                            
                        } else {
                            
                            DispatchQueue.main.async {
                                pv.statusLabel.stringValue = connection.connected ? "Connected" : "Disconnected"
                            }
                            
                        }
                        DispatchQueue.main.async {try! self.context.save()}
                    }
                }
                
                sleep(1)
            }
        }.start()
        
    }
    
    private func newPreset() {
        // Create the new preset
        let newPreset = Preset(context: self.context)
        newPreset.name = "New Preset"
        newPreset.isEnabled = false
        newPreset.connection = nil
        newPreset.macros = []
        
        // Save the new preset
        try! self.context.save()
        
        addPresetView(newPreset)
    }
    
    private func addPresetView(_ preset: Preset) {
        let newView = PresetCompactView(preset, delegate: self)
        presetViews.append(newView)
    }
    
    // Fetch data from core data
    public func fetchPresets() {
        Preset.presets = try! context.fetch(Preset.fetchRequest())
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
        
        try! context.save()
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
        ViewController.PresetEditor!.preset = pv.preset
        
        removePresetButton.isEnabled = true
    }
    
    func presetDeselected(_ pv: PresetCompactView) {
        pv.deselect()
        removePresetButton.isEnabled = false
    }
    
    func alteredPreset(_ pv: PresetCompactView) {
        ViewController.PresetEditor?.preset = pv.preset
    }
}
