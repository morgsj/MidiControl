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
    
    var awaitingMidiInput: Bool = false
    var rowAwaitingMidiMessage: Int = -1
    
    var newMidiInput: MIDIReceiver.MIDIMessageTuple? {
        get {return midiIn}
        set {
            midiIn = newValue
            if newValue != nil && rowAwaitingMidiMessage >= 0 {
                let label = tabView.selectedTabViewItem?.label
                
                if label == TabLabel.NoteTrigger && (newValue!.type == UMidiMessage.MessageType.NoteOnMessage || newValue!.type == UMidiMessage.MessageType.NoteOffMessage) {
                    
                    macroTriggers[0][rowAwaitingMidiMessage].messageType = newValue!.type
                    macroTriggers[0][rowAwaitingMidiMessage].noteID = newValue!.data1
                    macroTriggers[0][rowAwaitingMidiMessage].value = newValue!.data2
                    macroTriggers[0][rowAwaitingMidiMessage].channel = newValue!.channel
                    
                    try! parent.parent.context.save()
                    noteTriggerTableView.reloadData()
                    
                    rowAwaitingMidiMessage = -1
                    awaitingMidiInput = false
                } else if label == TabLabel.ControlTrigger && newValue!.type == UMidiMessage.MessageType.ControlMessage {
                    
                    macroTriggers[1][rowAwaitingMidiMessage].messageType = newValue!.type
                    macroTriggers[1][rowAwaitingMidiMessage].noteID = newValue!.data1
                    macroTriggers[1][rowAwaitingMidiMessage].value = newValue!.data2
                    macroTriggers[1][rowAwaitingMidiMessage].channel = newValue!.channel
                    
                    try! parent.parent.context.save()
                    controlTriggerTableView.reloadData()
                                        
                    rowAwaitingMidiMessage = -1
                    awaitingMidiInput = false
                }
            }
        }
    }; var midiIn: MIDIReceiver.MIDIMessageTuple?
    
    var parent : PresetEditorView

    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var enabledCheckbox: NSButton!
    
    @IBOutlet weak var tabView: NSTabView!
    fileprivate enum TabLabel {
        static let NoteTrigger = "Note Triggers"
        static let ControlTrigger = "Control Triggers"
    }
    
    
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
        
        noteTriggerTableView.doubleAction = #selector(doubleClicked)
        controlTriggerTableView.doubleAction = #selector(doubleClicked)
        
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
    
    @objc func doubleClicked(_ tableView: NSTableView) {
        
        rowAwaitingMidiMessage = tableView.selectedRow
        
        let rowView: NSTableRowView = tableView.rowView(atRow: rowAwaitingMidiMessage, makeIfNecessary: false)!
        
        rowView.backgroundColor = NSColor(red: 153, green: 0, blue: 51, alpha: 1)
        tableView.deselectAll(nil)
        
        awaitingMidiInput = true
        
    }
    
    @IBAction func addTriggerButtonClicked(_ sender: Any) {
        if let label = tabView.selectedTabViewItem?.label {
            if label == TabLabel.NoteTrigger {
                let newTrigger = UMidiMessage(context: parent.parent.context)
                // TODO: parent.parent is messy
                newTrigger.ignoresVelocity = true; newTrigger.ignoresChannel = true;
                macroTriggers[0].append(newTrigger)
                noteTriggerTableView.reloadData()
                
                var mutableTriggers = macro.triggers.array
                mutableTriggers.append(newTrigger)
                macro.triggers = NSOrderedSet(array: mutableTriggers)
                try! parent.parent.context.save()
                
            } else if label == TabLabel.ControlTrigger {
                let newTrigger = UMidiMessage(context: parent.parent.context)
                newTrigger.ignoresChannel = true;
                macroTriggers[1].append(newTrigger)
                controlTriggerTableView.reloadData()
                
                var mutableTriggers = macro.triggers.array
                mutableTriggers.append(newTrigger)
                macro.triggers = NSOrderedSet(array: mutableTriggers)
                try! parent.parent.context.save()
                
            }
        }
        
    }
    
    @IBAction func removeTriggerButtonClicked(_ sender: Any) {
        let noteTriggerTable: Bool = tabView.selectedTabViewItem?.label == TabLabel.NoteTrigger
        let row: Int!
        
        if noteTriggerTable {
            row = noteTriggerTableView.selectedRow
            noteTriggerTableView.removeRows(at: IndexSet(integer:row), withAnimation: NSTableView.AnimationOptions())
            removeTriggerButton.isEnabled = false
            
            let trigger = macroTriggers[0][row]
            macroTriggers[0].remove(at: row)
            parent.parent.context.delete(trigger)
            
            var triggerArray = macro.triggers.array
            triggerArray.removeAll(where: {$0 as! UMidiMessage == trigger})
            macro.triggers = NSOrderedSet(array: triggerArray)
            
            try! parent.parent.context.save()
            print("saved")
        } else {
            row = controlTriggerTableView.selectedRow
            noteTriggerTableView.removeRows(at: IndexSet(integer:row), withAnimation: NSTableView.AnimationOptions())
            removeTriggerButton.isEnabled = false
            
            let trigger = macroTriggers[1][row]
            macroTriggers[1].remove(at: row)
            parent.parent.context.delete(trigger)
            
            var triggerArray = macro.triggers.array
            triggerArray.removeAll(where: {$0 as! UMidiMessage == trigger})
            macro.triggers = NSOrderedSet(array: triggerArray)
            
            try! parent.parent.context.save()
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
                text = String(trigger.messageType == UMidiMessage.MessageType.NoteOnMessage ? "Note On" : "Note Off")
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
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        removeTriggerButton.isEnabled = true
    }
    
}
