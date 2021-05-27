//
//  MacroEditor.swift
//  Midi Control
//
//  Created by Morgan Jones on 23/05/2021.
//

import Cocoa

class MacroEditor: NSWindowController {
    
    var macro: Macro
    var macroTriggers: [[UMidiMessage]] = [[], []]
    
    var parent : PresetEditorView

    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var enabledCheckbox: NSButton!
    
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var noteTriggerTableView: NSTableView!
    @IBOutlet weak var controlTriggerTableView: NSTableView!
    
    @IBOutlet weak var responseKey: NSTextField!
    @IBOutlet weak var shiftCheckbox: NSButton!
    @IBOutlet weak var fnCheckbox: NSButton!
    @IBOutlet weak var ctrlCheckbox: NSButton!
    @IBOutlet weak var optionCheckbox: NSButton!
    @IBOutlet weak var cmdCheckbox: NSButton!
    
    @IBOutlet weak var saveAndExitButton: NSButton!
    
    @IBOutlet weak var addTriggerButton: NSButton!
    @IBOutlet weak var removeTriggerButton: NSButton!
    
    init(macro: Macro, parent: PresetEditorView) {
        self.macro = macro
        self.parent = parent
        super.init(window: nil)
        Bundle.main.loadNibNamed("MacroEditor", owner: self, topLevelObjects: nil)
        
        noteTriggerTableView.delegate = self
        noteTriggerTableView.dataSource = self
        controlTriggerTableView.delegate = self
        controlTriggerTableView.dataSource = self
        
        // Separate macro triggers into separate lists for the two menus
        for trigger in macro.triggers {
            guard let trigger = trigger as? UMidiMessage else {
                fatalError("Couldn't cast to UMidiMessage")
            }
            
            if trigger.messageType <= 1 {
                macroTriggers[0].append(trigger)
            } else { // trigger.messageType == 2
                macroTriggers[1].append(trigger)
            }
        }
        
        // Set name and enabled fields
        nameField.stringValue = macro.name
        enabledCheckbox.state = macro.enabled ? .on : .off
        
        noteTriggerTableView.reloadData()
        controlTriggerTableView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()

    }
    
    @objc func ignoreVelocityChange(_ sender: NSButton) {}
    @objc func ignoreChannelChange(_ sender: NSButton) {}
    
    @IBAction func addTriggerButtonClicked(_ sender: Any) {
        if let label = tabView.selectedTabViewItem?.label {
            if label == "Note Triggers" {
                let newTrigger = UMidiMessage(context: parent.parent.context)
                // TODO: parent.parent is messy
                newTrigger.ignoresVelocity = true; newTrigger.ignoresChannel = true;
                macroTriggers[0].append(newTrigger)
                noteTriggerTableView.reloadData()
                
                var mutableTriggers = macro.triggers.array
                mutableTriggers.append(newTrigger)
                macro.triggers = NSOrderedSet(array: mutableTriggers)
                try! parent.parent.context.save()
                print("saved")
                
            } else if label == "Control Triggers" {
                let newTrigger = UMidiMessage(context: parent.parent.context)
                newTrigger.ignoresChannel = true;
                macroTriggers[1].append(newTrigger)
                controlTriggerTableView.reloadData()
                
                var mutableTriggers = macro.triggers.array
                mutableTriggers.append(newTrigger)
                macro.triggers = NSOrderedSet(array: mutableTriggers)
                try! parent.parent.context.save()
                print("saved")
                
            }
        }
        
    }
}

// MARK: TableViewDelegate methods
extension MacroEditor: NSTableViewDelegate, NSTableViewDataSource {
    
    fileprivate enum CellIdentifiers {
        static let TypeCell = "TypeCellID"
        static let NoteCell = "NoteCellID"
        static let VelocityCell = "VelocityCellID"
        static let ChannelCell = "ChannelCellID"
        static let IgnoreVelocityCell = "IgnoreVelocityCellID"
        static let IgnoreChannelCell = "IgnoreChannelCellID"
        
        static let ControllerCell = "ControllerCellID"
        static let ValueCell = "ValueCellID"
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == noteTriggerTableView {
            return macroTriggers[0].count
        } else if tableView == controlTriggerTableView {
            return macroTriggers[1].count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let noteTriggerTable: Bool = tableView == noteTriggerTableView
        
        let trigger = macroTriggers[noteTriggerTable ? 0 : 1][row]
        
        var text: String?
        var cellIdentifier: String = ""
        
        if tableColumn == tableView.tableColumns[0] {
            if noteTriggerTable {
                text = String(trigger.messageType)
                cellIdentifier = CellIdentifiers.TypeCell
            } else {
                text = String(trigger.noteID)
                cellIdentifier = CellIdentifiers.ControllerCell
            }
        } else if tableColumn == tableView.tableColumns[1] {
            if noteTriggerTable {
                text = String(trigger.noteID)
                cellIdentifier = CellIdentifiers.NoteCell
            } else {
                text = String(trigger.value)
                cellIdentifier = CellIdentifiers.ValueCell
            }
        } else if tableColumn == tableView.tableColumns[2] {
            if noteTriggerTable {
                text = String(trigger.value)
                cellIdentifier = CellIdentifiers.VelocityCell
            } else {
                text = String(trigger.channel)
                cellIdentifier = CellIdentifiers.ChannelCell
            }
        } else if tableColumn == tableView.tableColumns[3] {
            if noteTriggerTable {
                text = String(trigger.channel)
                cellIdentifier = CellIdentifiers.ChannelCell
            } else {
                
                cellIdentifier = CellIdentifiers.IgnoreChannelCell
            }
        } else if tableColumn == tableView.tableColumns[4] {
            if noteTriggerTable {
                
                cellIdentifier = CellIdentifiers.IgnoreVelocityCell
            } else {return nil}
        } else if tableColumn == tableView.tableColumns[5] {
            if noteTriggerTable {
                
                cellIdentifier = CellIdentifiers.IgnoreChannelCell
            } else {return nil}
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as? NSTableCellView {
            
            if let text = text {
                cell.textField?.isEditable = false
                cell.textField?.stringValue = text
            } else {
                var checkbox: NSButton!
                if cellIdentifier == CellIdentifiers.IgnoreVelocityCell {
                    checkbox = NSButton(checkboxWithTitle: "", target: self, action: #selector(ignoreVelocityChange))
                    checkbox.state = trigger.ignoresVelocity ? .on : .off
                    checkbox.isEnabled = true
                    checkbox.tag = row
                } else { // cellIdentifier == CellIdentifiers.IgnoreChannelCell
                    checkbox = NSButton(checkboxWithTitle: "", target: self, action: #selector(ignoreChannelChange))
                    checkbox.state = trigger.ignoresChannel ? .on : .off
                    checkbox.isEnabled = true
                    checkbox.tag = row
                }
                
                cell.addSubview(checkbox)
            }
            
            return cell
        } else {return nil}
        
    }
    
    
    
}
