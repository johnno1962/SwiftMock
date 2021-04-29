//
//  HotSwiftUI.swift
//  HotSwiftUI
//
//  Created by John Holdsworth on 29/04/2021.
//  Copyright © 2017 John Holdsworth. All rights reserved.
//
//  $Id: //depot/SwiftMock/Sources/SwiftMock/SwiftMock.swift#3 $
//

import Foundation
import EasyPointer
import DLKit

struct SwiftMock {
    static func pose(_ poser: Any.Type, as posee: Any.Type,
                     image: ImageSymbols = DLKit.mainImage) {
        let poserPrefix = _typeName(poser)+"."
        let poseePrefix = _typeName(posee)+"."
        var symbols = [SymbolName]()
        var posers = [UnsafeMutableRawPointer]()
        var replaced = [String: UnsafeMutableRawPointer]()

        for (name, _, entry) in image
            where entry.pointee.n_sect != 0 {
            if let oldSwift = name.demangled,
                oldSwift.hasPrefix(poseePrefix) {
                let newSwift = oldSwift.replacingOccurrences(of:
                    poseePrefix, with: poserPrefix)
                if let replacement = image
                    .mangle(swift: newSwift)?.value,
                   !newSwift.hasSuffix("deinit") {
//                    print(oldSwift, newSwift, replacement)
                    symbols.append(name)
                    posers.append(replacement)
                    replaced[String(cString: name)] = replacement
                }
            }
        }

        image[symbols] = posers

        guard let poseeClass = posee as? AnyClass else { return }

        // patch vtable...
        let swiftMeta: UnsafeMutablePointer<TargetClassMetadata> = autoBitCast(poseeClass)
        let endMeta = UnsafeMutablePointer<Int8>(cast: swiftMeta) -
            Int(swiftMeta.pointee.ClassAddressPoint) +
            Int(swiftMeta.pointee.ClassSize)
        let vtableStart = UnsafeMutablePointer<UnsafeRawPointer?>(cast:
            &swiftMeta.pointee.IVarDestroyer)
        let vtableEnd = UnsafeMutablePointer<UnsafeRawPointer?>(cast: endMeta)

        for slotIndex in 0..<(vtableEnd - vtableStart) {
            if let existing = vtableStart[slotIndex],
               let symname = image[UnsafeMutableRawPointer(mutating: existing)],
                let replacement = replaced[String(cString: symname.name)] {
                vtableStart[slotIndex] = UnsafeRawPointer(replacement)
            }
        }
    }

    /**
     Layout of a class instance. Needs to be kept in sync with ~swift/include/swift/Runtime/Metadata.h
     */
    public struct TargetClassMetadata {

        let MetaClass: uintptr_t = 0, SuperClass: uintptr_t = 0
        let CacheData1: uintptr_t = 0, CacheData2: uintptr_t = 0

        public let Data: uintptr_t = 0

        /// Swift-specific class flags.
        public let Flags: UInt32 = 0

        /// The address point of instances of this type.
        public let InstanceAddressPoint: UInt32 = 0

        /// The required size of instances of this type.
        /// 'InstanceAddressPoint' bytes go before the address point;
        /// 'InstanceSize - InstanceAddressPoint' bytes go after it.
        public let InstanceSize: UInt32 = 0

        /// The alignment mask of the address point of instances of this type.
        public let InstanceAlignMask: UInt16 = 0

        /// Reserved for runtime use.
        public let Reserved: UInt16 = 0

        /// The total size of the class object, including prefix and suffix
        /// extents.
        public let ClassSize: UInt32 = 0

        /// The offset of the address point within the class object.
        public let ClassAddressPoint: UInt32 = 0

        /// An out-of-line Swift-specific description of the type, or null
        /// if this is an artificial subclass.  We currently provide no
        /// supported mechanism for making a non-artificial subclass
        /// dynamically.
        public let Description: uintptr_t = 0

        /// A function for destroying instance variables, used to clean up
        /// after an early return from a constructor.
        public var IVarDestroyer: UnsafeRawPointer? = nil

        // After this come the class members, laid out as follows:
        //   - class members for the superclass (recursively)
        //   - metadata reference for the parent, if applicable
        //   - generic parameters for this class
        //   - class variables (if we choose to support these)
        //   - "tabulated" virtual methods

    }
}
