//
//  ForgottenDevicesManager.swift
//  Midi Control
//
//  Created by Morgan Jones on 24/05/2021.
//

import Cocoa

class ForgottenDevicesManager: NSWindowController {

    let context: NSManagedObjectContext
    
    var forgottenDevices: [Connection] = []
    
    @IBOutlet weak var tableView: NSTableView!
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init(window: nil)
        Bundle.main.loadNibNamed("ForgottenDevicesManager", owner: self, topLevelObjects: nil)

        // TODO: This should be in the static Connection functionality
        let request: NSFetchRequest<Connection> = Connection.fetchRequest()
        let predicate = NSPredicate(format: "forgotten == 1")
        request.predicate = predicate
        do {
            forgottenDevices = try context.fetch(request)
        } catch {
            fatalError("Couldn't fetch forgotten devices: \(error)")
        }
        
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    @IBAction func restoreDevice(_ sender: Any) {
        let row = tableView.selectedRow
        if row != -1 {
            forgottenDevices[row].forgotten = false
            
            do {try context.save()} catch {fatalError("Couldn't save context: \(error)")}
        
            tableView.removeRows(at: IndexSet(integer: row), withAnimation: NSTableView.AnimationOptions())
            forgottenDevices.remove(at: row)
        }
    }
    
}

extension ForgottenDevicesManager: NSTableViewDelegate, NSTableViewDataSource {
    fileprivate enum CellIdentifiers {
        static let NameCell = "Name"
        static let IDCell = "ID"
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return forgottenDevices.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String!
        var cellIdentifier: String = ""
        
        let item = forgottenDevices[row]
        
        if tableColumn == tableView.tableColumns[0] {
            text = item.name
            cellIdentifier = CellIdentifiers.NameCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = String(item.id)
            cellIdentifier = CellIdentifiers.IDCell
        }
        
        let id = NSUserInterfaceItemIdentifier(rawValue: cellIdentifier)
        
        if let cell = tableView.makeView(withIdentifier: id, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
      
    }
}
