//
//  PresetView.swift
//  Midi Control
//
//  Created by Morgan Jones on 11/03/2021.
//

import Foundation
import Cocoa

@IBDesignable
class PresetCompactView : NSView {
    
    static let WIDTH : CGFloat = 200
    static let HEIGHT : CGFloat = 50
    
    @IBOutlet var contentView: NSView!
    
    @IBOutlet weak var enabledCheckbox: NSButton!
    @IBOutlet weak var presetName: NSTextField!
    @IBOutlet weak var presetConnection: NSTextField!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var backgroundBox: NSBox!

    public var preset : Preset
    private let delegate : PresetViewDelegate?
    private var isSelected : Bool = false
    
    init(_ preset: Preset, delegate: PresetViewDelegate) {
        self.preset = preset
        self.delegate = delegate
        
        super.init(frame: NSMakeRect(0, 0, PresetCompactView.WIDTH, PresetCompactView.HEIGHT))
        
        Bundle.main.loadNibNamed("PresetCompactView", owner: self, topLevelObjects: nil)
        let contentFrame = NSMakeRect(0, 0, frame.size.width, frame.size.height)
        self.contentView.frame = contentFrame
        self.addSubview(self.contentView)
        
        enabledCheckbox.state = preset.isEnabled ? .on : .off
        enabledCheckbox.target = self
        enabledCheckbox.action = #selector(boxChecked)
        
        if let connection = preset.connection {
            presetConnection.stringValue = connection.name
            statusLabel.stringValue = connection.connected ? "Connected" : "Disconnected"
        } else {
            presetConnection.stringValue = "No Connection"
            statusLabel.stringValue = "Disconnected"
        }
        
        refresh()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    @objc func boxChecked() {
        preset.isEnabled = (enabledCheckbox.state == .on)
        if isSelected {
            delegate?.alteredPreset(self)
        }
    }
    
    // MARK: mouse events
    override func mouseUp(with event: NSEvent) {
        print("mouseUP")
        if (!isSelected) {
            select()
            delegate!.presetSelected(self)
        } else {
            deselect()
            delegate!.presetDeselected(self)
        }
    }
    
    public func select() {
        backgroundBox.fillColor = .lightGray
        isSelected = true
    }
    
    public func deselect() {
        backgroundBox.fillColor = .controlBackgroundColor
        isSelected = false
    }
    
    func refresh() {
        presetName.stringValue = preset.name
        if let name = preset.connection?.name {presetConnection.stringValue = name}
        enabledCheckbox.state = preset.isEnabled ? .on : .off
    }
}
