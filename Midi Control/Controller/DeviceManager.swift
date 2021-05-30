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
    
    
    @IBAction func refreshDevices(_ sender: NSButton?) {
        Connection.refreshConnections(context: parent.context, shouldFetch: true)
        deviceTable.reloadData()
    }

    @IBAction func forgetDevice(_ sender: Any) {
        let row = deviceTable.selectedRow
        if (row != -1) {
            
            let conn = Connection.connectionWhitelist()[row]
            conn.forgotten = true
            
            Connection.refreshConnections(context: parent.context, shouldFetch: false)
            deviceTable.removeRows(at: IndexSet(integer: row), withAnimation: NSTableView.AnimationOptions())
            
        }
        
    }
}

extension DeviceManager : NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return Connection.connectionWhitelist().count
    }
}

extension DeviceManager : NSTableViewDelegate {
    fileprivate enum CellIdentifiers {
        static let DeviceCell = "Device"
        static let ConnectedCell = "Connected"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String?
        var cellIdentifier: String = ""
        
        let item = Connection.connectionWhitelist()[row]
        
        if tableColumn == deviceTable.tableColumns[0] {
            text = item.name
            cellIdentifier = CellIdentifiers.DeviceCell
        } else if tableColumn == deviceTable.tableColumns[1] {
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
                    checkbox = NSButton(checkboxWithTitle: "", target: self, action: nil)
                    cell.addSubview(checkbox!)
                }
                
                checkbox!.tag = row
                checkbox!.state = item.connected ? .on : .off
                checkbox!.isEnabled = false
                
                
            }
            
            return cell
        }
        return nil
      
    }
    
}
