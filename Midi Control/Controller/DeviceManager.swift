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
    
    init() {
        super.init(window: nil)
        
        Bundle.main.loadNibNamed("DeviceManager", owner: self, topLevelObjects: nil)

        refreshDevices()
        refreshButton.action = #selector(refreshDevices)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func refreshDevices() {
        // refresh devices
        
        
    }
    

}

extension DeviceManager : NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return Connection.connections.count ?? 0
    }
}
