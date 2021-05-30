//
//  Midi_Control_Tests.swift
//  Midi Control Tests
//
//  Created by Morgan Jones on 29/05/2021.
//

import XCTest
import Midi_Control

class Midi_Control_Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func newConnectionIsNotNil() throws {
        let connection: Connection? = Connection()
        assert(connection != nil)
    }

}
