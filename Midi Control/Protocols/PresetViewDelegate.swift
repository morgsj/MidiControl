//
//  PresetViewDelegate.swift
//  Midi Control
//
//  Created by Morgan Jones on 12/03/2021.
//

import Foundation

protocol PresetViewDelegate {
    func presetSelected(_ pv: PresetView)
    func presetDeselected(_ pv: PresetView)
}
