//
//  PresetViewDelegate.swift
//  Midi Control
//
//  Created by Morgan Jones on 12/03/2021.
//

protocol PresetViewDelegate {    
    func presetSelected(_ pv: PresetCompactView)
    func presetDeselected(_ pv: PresetCompactView)
    func alteredPreset(_ pv: PresetCompactView)
}
