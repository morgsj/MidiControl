//
//  MascroView.swift
//  Midi Control
//
//  Created by Morgan Jones on 18/03/2021.
//

import Foundation
import Cocoa

class MacroView : NSView {
    
    static let WIDTH : CGFloat = 470
    static let MIN_HEIGHT : CGFloat = 50
    
    override var isFlipped: Bool {
        get {
            return true
        }
    }

    @IBOutlet var contentView: NSView!
    @IBOutlet weak var box: NSBox!
    @IBOutlet weak var expandButton: NSButton!
    
    public var macro: Macro
    public var delegate : MacroEditorDelegate
    
    init(delegate: PresetEditorView, macro: Macro = Macro()) {
        self.macro = macro
        self.delegate = delegate
        
        super.init(frame: NSRect(x: 0, y: 0, width: MacroView.WIDTH, height: MacroView.MIN_HEIGHT))
        
        Bundle.main.loadNibNamed("MacroView", owner: self, topLevelObjects: nil)
        let contentFrame = NSMakeRect(0, 0, frame.size.width, frame.size.height)
        self.contentView.frame = contentFrame
        self.addSubview(self.contentView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func mouseUp(with event: NSEvent) {
        delegate.selectedMacro == self ? delegate.macroDeselected(self) : delegate.macroSelected(self)
    }
    
    public func select() {
        box.fillColor = .systemBlue
    }
    
    public func deselect() {
        box.fillColor = .clear
    }
    
    @IBAction func expandButtonClicked(_ sender: Any) {
        if expandButton.state == .on {
            contentView.setFrameSize(NSSize(width: MacroView.WIDTH, height: 400))
            box.setFrameSize(NSSize(width: MacroView.WIDTH, height: 400))
        } else {
            contentView.setFrameSize(NSSize(width: MacroView.WIDTH, height:  MacroView.MIN_HEIGHT))
            box.setFrameSize(NSSize(width: MacroView.WIDTH, height:  MacroView.MIN_HEIGHT))
        }
    }
    
    
    
}
