//
//  MacroEditorDelegate.swift
//  Midi Control
//
//  Created by Morgan Jones on 24/03/2021.
//

protocol MacroEditorDelegate {
    
    var selectedMacro : MacroView? { get }
    
    func macroSelected(_ mv: MacroView)
    func macroDeselected(_ mv: MacroView)
    func alteredMacro(_ mv: MacroView)
}
