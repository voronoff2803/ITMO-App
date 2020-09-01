//
//  Helper.swift
//  ITMO X
//
//  Created by Alexey Voronov on 13/05/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import Foundation
import UIKit

class Helper {
    static func normalWeekDay(_ weekDay: Int) -> Int {
        if weekDay < 2 {
            return 6
        } else {
            return weekDay - 2
        }
    }
    
    static func weekEven() -> Int {
        
        
        
        let date = Date()
        let calendar = Calendar(identifier: .gregorian)

        let week = calendar.component(.weekOfYear, from: date)
        
        print("\(Config.weekConf) - week even")
        
        
        if week % 2 == Config.weekConf {
            return 0
        } else {
            return 1
        }
    }
}
