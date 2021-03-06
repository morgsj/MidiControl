/**
 PresetEditor.swift
 Midi Control

 Created by Morgan Jones on 14/03/2021.
*/

import Foundation
import Cocoa

@IBDesignable
class PresetEditorView : NSView {
    
    /* Ensures the coordinate system has the origin at top right */
    override var isFlipped: Bool { return true }
    
    /* The dimensions of the custom view */
    static let WIDTH : CGFloat = 500
    static let HEIGHT : CGFloat = 350
    
    /* The view in which we build the editor */
    @IBOutlet var contentView: NSView!
    
    /* The combo box that allows the user to choose which valid connection the preset is associated with */
    @IBOutlet weak var connectionField: NSComboBox!
    
    /* The field allowing changing of the preset name */
    @IBOutlet weak var presetNameField: NSTextField!
    
    /* Toggle switch allowing the preset to be enabled or disabled */
    @IBOutlet weak var enabledSwitch: NSSwitch!
    
    /* The button that sets the preset name to be the value typed in presetNameField */
    @IBOutlet weak var setNameButton: NSButton!
    
    /* The area where macros are displayed */
    @IBOutlet weak var macroTableView: NSTableView!
    
    /* Button to add macros */
    @IBOutlet weak var addMacroButton: NSButton!
    
    /* Buttons to move macros */
    @IBOutlet weak var moveMacroUpButton: NSButton!
    @IBOutlet weak var moveMacroDownButton: NSButton!
    
    /* The view controller that this is a subview of */
    let parent : ViewController
    
    static var macroEditor : MacroEditor?
    
    private var dragDropType = NSPasteboard.PasteboardType(rawValue: "private.table-row")

    
    /* The preset we are editing */
    var preset : Preset? {
        get {
            return p
        }
        set {
            p = newValue
            
            if let preset = p { /* Check that the preset passed in is valid */
                
                presetNameField.layer?.borderColor = CGColor.init(gray: 0, alpha: 0)
                
                /* Set name */
                presetNameField.stringValue = preset.name
                
                /* Set combo box value */
                if let conn = preset.connection {
                    let index: Int? = Connection.connectionWhitelist().firstIndex(where: {$0 == conn})
                    if index != nil {
                        connectionField.stringValue = conn.name!
                    } else {
                        preset.connection = nil
                        try! parent.context.save()
                        connectionField.stringValue = ""
                        connectionField.deselectItem(at: connectionField.indexOfSelectedItem)
                    }
                } else {connectionField.stringValue = ""}
                
                /* Set enabled value */
                enabledSwitch.state = preset.isEnabled ? .on : .off
                
                /* Display all the preset's macros */
                macroTableView.reloadData()
            }
        }
    }; private var p : Preset?
    
    init(_ parent : ViewController) {
        self.parent = parent
        super.init(frame: NSMakeRect(0, 0, PresetEditorView.WIDTH, PresetEditorView.HEIGHT))
        
        Bundle.main.loadNibNamed("PresetEditorView", owner: self, topLevelObjects: nil)
        let contentFrame = NSMakeRect(0, 0, PresetEditorView.WIDTH, PresetEditorView.HEIGHT)
        self.contentView.frame = contentFrame
        self.addSubview(self.contentView)
           
        presetNameField.delegate = self
        connectionField.delegate = self
        
        macroTableView.delegate = self
        macroTableView.dataSource = self
        macroTableView.target = self
        macroTableView.action = #selector(tableViewClicked)
        
        macroTableView.registerForDraggedTypes([dragDropType])
        macroTableView.doubleAction = #selector(doubleClicked)
        
        refreshConnections()
        
        connectionField.delegate = self
        connectionField.dataSource = self
        
        /* TODO: Refactor into @IBActions to reduce volume of code */
        setNameButton.action     = #selector(setNameClicked)
        enabledSwitch.action     = #selector(toggleEnabledSwitch)
        addMacroButton.action    = #selector(addMacroButtonClicked)
        
        
    }; required init?(coder aDecoder: NSCoder) {fatalError()}
    
    @objc func addMacroButtonClicked(sender: NSButton) {
        if let preset = preset {
            let newMacro = Macro(context: parent.context)
            newMacro.name = "New Macro"
            newMacro.id = UUID()
            newMacro.enabled = true
            
            preset.addToMacros(newMacro)
            
            saveTableData()
        }
    }
    
    func saveTableData() {
        macroTableView.reloadData()
        
        do {try parent.context.save()}
        catch {fatalError("Couldn't save: \(error)")}
    }
    
    //TODO: FIX THIS
    @IBAction func moveMacroUp(_ sender: Any) {
        if let preset = preset {
            
            let row = macroTableView.selectedRow
            if row == 0 || row == -1 {return}
            
            macroTableView.moveRow(at: row, to: row - 1)
            
            var macros = preset.macros.array
            
            let temp = macros[row]
            macros[row] = macros[row - 1]
            macros[row - 1] = temp
            
            preset.macros = NSOrderedSet(array: macros)
            
            do {try parent.context.save()}
            catch {fatalError("Couldn't save: \(error)")}
        }
    }
    
    @IBAction func moveMacroDown(_ sender: Any) {
        if let preset = preset {
            
            let row = macroTableView.selectedRow
            if row == preset.macros.count - 1 || row == -1 {return}
            
            macroTableView.moveRow(at: row, to: row + 1)
            
            var macros = preset.macros.array
            
            let temp = macros[row]
            macros[row] = macros[row + 1]
            macros[row + 1] = temp
            
            preset.macros = NSOrderedSet(array: macros)
            
            do {try parent.context.save()}
            catch {fatalError("Couldn't save: \(error)")}
        }
    }
    
    @objc func setNameClicked() {
        preset?.name = presetNameField.stringValue
        parent.updatePresetViews()
    }
    
    
    func refreshConnections() {
        connectionField.reloadData()
    }
    
    override func mouseDown(with event: NSEvent) {
        enabledSwitch.becomeFirstResponder()
    }
    
    @objc func toggleEnabledSwitch() {
        if let preset = preset {
            preset.isEnabled = (enabledSwitch.state == .on)
            for presetView in parent.presetViews {
                if presetView.preset == preset {
                    presetView.enabledCheckbox.state = preset.isEnabled ? .on : .off
                }
            }
        }
    }
    
    @objc func doubleClicked(_ sender: NSTableView) {
       
        
        let selectedRow = macroTableView.selectedRow
        
        if selectedRow != -1 && preset != nil {
            if PresetEditorView.macroEditor != nil {
                PresetEditorView.macroEditor!.close()
            }
            
            PresetEditorView.macroEditor = MacroEditor(macro: preset!.macros[selectedRow] as! Macro, parent: self)
            PresetEditorView.macroEditor?.showWindow(self)
            
        }
    }
    
}

// MARK: TextFieldDelegate methods
extension PresetEditorView: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        setNameClicked()
    }
    
    func controlTextDidBeginEditing(_ obj: Notification) {
        presetNameField.layer?.backgroundColor = CGColor(gray: 0, alpha: 1)
    }
    
}

// MARK: TableViewDelegate methods
extension PresetEditorView : NSTableViewDelegate, NSTableViewDataSource {
    
    fileprivate enum CellIdentifiers {
        static let NameCell = "NameCellID"
        static let EnabledCell = "EnabledCellID"
        static let BinCell = "BinCellID"
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if let preset = preset {
            return preset.macros.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let preset = preset else {return nil}
            
        guard let macro = preset.macros[row] as? Macro else {return nil}
        
        var text : String?
        var image: NSImage?
        var cellIdentifier: String = ""
        
        if tableColumn == tableView.tableColumns[0] {
            text = macro.name
            cellIdentifier = CellIdentifiers.NameCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = macro.enabled ? "Yes" : "No"
            cellIdentifier = CellIdentifiers.EnabledCell
        } else {
            image = NSImage(systemSymbolName: "xmark.bin", accessibilityDescription: nil)
            cellIdentifier = CellIdentifiers.BinCell
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: nil) as? NSTableCellView {
            
            if let text = text {
                cell.textField?.isEditable = true
                cell.textField?.stringValue = text
                cell.textField?.tag = row
                cell.textField?.action = #selector(textFieldFinishedEditing)
            }
            
            if let image = image {
                cell.imageView?.image = image
                cell.imageView?.tag = row
            }
            
            return cell
        } else {return nil}
    }
    
    @objc func binMacro(_ sender: NSImageView) {
        print("ok baby")
    }

    @objc func textFieldFinishedEditing(_ sender: NSTextField) {
        if let macro = preset?.macros[sender.tag] as? Macro {
            macro.name = sender.stringValue
            preset?.replaceMacros(at: sender.tag, with: macro)
            saveTableData()
        }
    }
    
    func tableView(tableView: NSTableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath)
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        for i in 0..<macroTableView.numberOfRows {
            if macroTableView.isRowSelected(i) {
                moveMacroUpButton.isEnabled = true
                moveMacroDownButton.isEnabled = true
                return
            }
        }
        moveMacroUpButton.isEnabled = false
        moveMacroDownButton.isEnabled = false
    }
    
    @objc func tableViewClicked() {
        if macroTableView.clickedColumn == 2 {
            parent.context.delete(preset?.macros[macroTableView.clickedRow] as! Macro)
            preset?.removeFromMacros(at: macroTableView.clickedRow)
            saveTableData()
        }
    }
    
    
}

// MARK: ComboBoxDelegate methods
extension PresetEditorView : NSComboBoxDelegate, NSComboBoxDataSource {
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return Connection.connectionWhitelist().count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        if index < 0 || index >= numberOfItems(in: comboBox) {return nil}
        return Connection.connectionWhitelist()[index].name as AnyObject
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        let index = connectionField.indexOfSelectedItem
        let connection = Connection.connectionWhitelist()[index]
        if let preset = preset {
            
            preset.connection = connection
            try! parent.context.save()
            
            for presetView in parent.presetViews {
                if presetView.preset == preset {
                    presetView.presetConnection.stringValue = connection.name!
                    presetView.statusLabel.stringValue = connection.connected ? "Connected" : "Disconnected"
                }
            }
            
        }
    }
}
    
