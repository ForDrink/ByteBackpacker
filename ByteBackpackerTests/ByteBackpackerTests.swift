/*
This file is part of ByteBackpacker Project. It is subject to the license terms in the LICENSE file found in the top-level directory of this distribution and at https://github.com/michaeldorner/ByteBackpacker/blob/master/LICENSE. No part of ByteBackpacker Project, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the LICENSE file.
*/

import XCTest
@testable import ByteBackpacker

class ByteBackpackerDoubleTests: XCTestCase {
    
    private let testByteArrays: [Double: [Byte]] = [
        -8: [0, 0, 0, 0, 0, 0, 112, 63],
        -7: [0, 0, 0, 0, 0, 0, 128, 63],
        -6: [0, 0, 0, 0, 0, 0, 144, 63],
        -5: [0, 0, 0, 0, 0, 0, 160, 63],
        -4: [0, 0, 0, 0, 0, 0, 176, 63],
        -3: [0, 0, 0, 0, 0, 0, 192, 63],
        -2: [0, 0, 0, 0, 0, 0, 208, 63],
        -1: [0, 0, 0, 0, 0, 0, 224, 63],
        0: [0, 0, 0, 0, 0, 0, 240, 63],
        1: [0, 0, 0, 0, 0, 0, 0, 64],
        2: [0, 0, 0, 0, 0, 0, 16, 64],
        3: [0, 0, 0, 0, 0, 0, 32, 64],
        4: [0, 0, 0, 0, 0, 0, 48, 64],
        5: [0, 0, 0, 0, 0, 0, 64, 64],
        6: [0, 0, 0, 0, 0, 0, 80, 64],
        7: [0, 0, 0, 0, 0, 0, 96, 64],
        8: [0, 0, 0, 0, 0, 0, 112, 64]
    ]
    
    
    func testRandomDouble() {
        testRandomDouble(1000, byteOrder: .LittleEndian)
        testRandomDouble(1000, byteOrder: .BigEndian)
    }
    
    
    func testSelectedDouble() {
        testSelectedDouble(.LittleEndian)
        testSelectedDouble(.BigEndian)
    }
    
    
    func testNSData() {
        for index in -1000...1000 {
            var double = Double(index)
            let data = NSData(bytes: &double, length: sizeof(Double.self))
            let byteArray = data.toByteArray()
            let doubleFromByteArray = ByteBackpacker.unpack(byteArray, byteOrder: .LittleEndian) as Double
            XCTAssertEqual(double, doubleFromByteArray)
        }
    }
    
    
    func testByteOrder() {
        XCTAssertEqual(ByteOrder.nativeByteOrder, ByteOrder.LittleEndian)
    }
    
    
    private func testSelectedDouble(byteOrder: ByteOrder) {
        for (p, byteArray_) in testByteArrays {
            var byteArray: [Byte]
            if byteOrder == .BigEndian {
                byteArray = byteArray_.reverse()
            }
            else {
                byteArray = byteArray_
            }
            let number = pow(2.0, p)
            let packedByteArray = ByteBackpacker.pack(number, byteOrder: byteOrder)
            XCTAssertEqual(packedByteArray, byteArray)
            
            let unpackedNumber: Double = ByteBackpacker.unpack(byteArray, byteOrder: byteOrder)
            XCTAssertEqual(unpackedNumber, number)
        }
        
        for (p, byteArray_) in testByteArrays {
            let byteArray: [Byte] = byteArray_.reverse()
            let number = pow(2.0, p)
            let packedByteArray = ByteBackpacker.pack(number, byteOrder: .BigEndian)
            XCTAssertEqual(packedByteArray, byteArray)
            
            let unpackedNumber: Double = ByteBackpacker.unpack(byteArray, byteOrder: .BigEndian)
            XCTAssertEqual(unpackedNumber, number)
        }
    }
    
    
    private func testRandomDouble(N: Int, byteOrder: ByteOrder) {
        for var counter = 0; counter < N; counter++ {
            var value: Double = Double(arc4random())
            
            let dataNumber: NSData = NSData.init(bytes: &value, length: sizeof(Double.self))
            let byteArrayFromNSData: [Byte] = (byteOrder == .LittleEndian) ? dataNumber.toByteArray() : dataNumber.toByteArray().reverse()
            
            let packedByteArray = ByteBackpacker.pack(value, byteOrder: byteOrder)
            
            XCTAssertNotNil(dataNumber)
            XCTAssertNotNil(byteArrayFromNSData)
            XCTAssertNotNil(packedByteArray)
            
            XCTAssertEqual(packedByteArray, byteArrayFromNSData)
            
            let r_1: Double = ByteBackpacker.unpack(packedByteArray, byteOrder: byteOrder)
            let r_2: Double = ByteBackpacker.unpack(byteArrayFromNSData, byteOrder: byteOrder)
            XCTAssertEqual(r_1, value)
            XCTAssertEqual(r_2, value)
            XCTAssertEqual(ByteBackpacker.unpack(packedByteArray, toType: Double.self, byteOrder: byteOrder), value)
            XCTAssertEqual(ByteBackpacker.unpack(byteArrayFromNSData, toType: Double.self, byteOrder: byteOrder), value)
        }
    }
}
