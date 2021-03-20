//
//  MascroView.swift
//  Midi Control
//
//  Created by Morgan Jones on 18/03/2021.
//

import Foundation
import Cocoa

@IBDesignable
class MacroView : NSView {
    
    static let WIDTH : CGFloat = 470
    static let HEIGHT : CGFloat = 50
    
    @IBOutlet var contentView: NSView!
    
    init() {
        super.init(frame: NSRect(x: 0, y: 0, width: MacroView.WIDTH, height: MacroView.HEIGHT))
        
        Bundle.main.loadNibNamed("MacroView", owner: self, topLevelObjects: nil)
        let contentFrame = NSMakeRect(0, 0, 500, 350)
        self.contentView.frame = contentFrame
        self.addSubview(self.contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
}

