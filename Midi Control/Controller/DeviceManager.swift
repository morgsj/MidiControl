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
        
        refreshDevices()
        print(Connection.connections.count)
        refreshButton.action = #selector(refreshDevices)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func refreshDevices() {
        Connection.populateConnections()
        deviceTable.reloadData()
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
                let checkbox = NSButton(checkboxWithTitle: "", target: self, action: #selector(visibilityChange))
                checkbox.tag = row
                if (cellIdentifier == CellIdentifiers.VisibleCell) {
                    checkbox.state = item.visible ? .on : .off
                    checkbox.isEnabled = true
                } else {
                    checkbox.state = item.connected ? .on : .off
                    checkbox.isEnabled = false
                }
                cell.addSubview(checkbox)
            }
            
            return cell
        }
        return nil
      
    }
    
    @objc func visibilityChange(sender: NSButton) {
        Connection.connections[sender.tag].visible = (sender.state == .on)
        
        parent.updatePresets()
    }
    
}
