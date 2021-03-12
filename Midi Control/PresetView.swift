//
//  PresetView.swift
//  Midi Control
//
//  Created by Morgan Jones on 11/03/2021.
//

import Foundation
import Cocoa

@IBDesignable
class PresetView : NSView {
    
    static let WIDTH : CGFloat = 200
    static let HEIGHT : CGFloat = 50
    
    @IBOutlet var contentView: NSView!
    
    @IBOutlet weak var enabledCheckbox: NSButton!
    @IBOutlet weak var presetName: NSTextField!
    @IBOutlet weak var presetConnection: NSTextField!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var backgroundBox: NSBox!

    private var preset : Preset?
    private let delegate : PresetViewDelegate?
    private var isSelected : Bool = false
    
    init(_ preset: Preset, delegate: PresetViewDelegate) {
        self.preset = preset
        self.delegate = delegate
        
        super.init(frame: NSMakeRect(0, 0, PresetView.WIDTH, PresetView.HEIGHT))
        
        Bundle.main.loadNibNamed("PresetView", owner: self, topLevelObjects: nil)
        let contentFrame = NSMakeRect(0, 0, frame.size.width, frame.size.height)
        self.contentView.frame = contentFrame
        self.addSubview(self.contentView)
        
        presetName.stringValue = preset.name
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func mouseUp(with event: NSEvent) {
        if (!isSelected) {
            backgroundBox.fillColor = .highlightColor
            delegate!.presetSelected(self)
        } else {
            deselect()
            delegate!.presetDeselected(self)
        }
        isSelected = !isSelected
    }
    
    public func deselect() {
        backgroundBox.fillColor = .controlBackgroundColor
    }
    
}
