//
//  Bool+Extension\].swift
//  DynamicLinkFramework
//
//  Created by NGUYEN HAU on 25/2/25.
//

import Foundation

public extension Bool {
    
    func wireFormatFromBool() -> NSNumber? {
        return self ? NSNumber(value: true) : nil
    }
    
}
