//
//  DeviceManager.swift
//  Midi Control
//
//  Created by Morgan Jones on 20/03/2021.
//

import Foundation
import Cocoa

@IBDesignable
class DeviceManager : NSWindowController {

    @IBOutlet weak var refreshButton: NSButton!
    @IBOutlet weak var deviceTable: NSTableView!
    
    let parent : ViewController
    
    init(_ parent: ViewController) {
        self.parent = parent
        super.init(window: nil)
        Bundle.main.loadNibNamed("DeviceManager", owner: self, topLevelObjects: nil)
        
        deviceTable.delegate = self
        deviceTable.dataSource = self
        
        refreshDevices(nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TODO: still doesn't quite work?
    @IBAction func refreshDevices(_ sender: NSButton?) {
        Connection.populateConnections(context: parent.context)
        deviceTable.reloadData()
    }

    @IBAction func forgetDevice(_ sender: Any) {
        let row = deviceTable.selectedRow
        if (row != -1) {
            
            let conn = Connection.connections[row]
            conn.forgotten = true
            Connection.connections[row] = conn
            
            do {try parent.context.save(); print("saved")} catch {fatalError("Couldn't save")}
            
            Connection.populateConnections(context: parent.context)
            deviceTable.removeRows(at: IndexSet(integer: row), withAnimation: NSTableView.AnimationOptions())
            
        }
        
    }
}

extension DeviceManager : NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return Connection.connections.count
    }
}

extension DeviceManager : NSTableViewDelegate {
    fileprivate enum CellIdentifiers {
        static let DeviceCell = "Device"
        static let VisibleCell = "Visible"
        static let ConnectedCell = "Connected"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String?
        var cellIdentifier: String = ""
        
        let item = Connection.connections[row]
        
        if tableColumn == deviceTable.tableColumns[0] {
            text = item.name
            cellIdentifier = CellIdentifiers.DeviceCell
        } else if tableColumn == deviceTable.tableColumns[1] {
            cellIdentifier = CellIdentifiers.VisibleCell
        } else if tableColumn == deviceTable.tableColumns[2] {
            cellIdentifier = CellIdentifiers.ConnectedCell
        }
        
        let id = NSUserInterfaceItemIdentifier(rawValue: cellIdentifier)
        
        if let cell = deviceTable.makeView(withIdentifier: id, owner: nil) as? NSTableCellView {
            if let text = text {
                cell.textField?.stringValue = text
            } else {
                var checkbox: NSButton? = cell.subviews.first as? NSButton
                //let checkbox = NSButton(checkboxWithTitle: "", target: self, action: #selector(visibilityChange))
                if checkbox == nil {
                    checkbox = NSButton(checkboxWithTitle: "", target: self, action: #selector(visibilityChange))
                    cell.addSubview(checkbox!)
                }
                
                checkbox!.tag = row
                if (cellIdentifier == CellIdentifiers.VisibleCell) {
                    checkbox!.state = item.visible ? .on : .off
                    checkbox!.isEnabled = true
                } else {
                    checkbox!.state = item.connected ? .on : .off
                    checkbox!.isEnabled = false
                }
                
            }
            
            return cell
        }
        return nil
      
    }
    
    @objc func visibilityChange(sender: NSButton) {
        Connection.connections[sender.tag].visible = (sender.state == .on)
        
        parent.updatePresetViews()
    }
    
}
