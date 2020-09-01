//
//  Config.swift
//  ITMO X
//
//  Created by Alexey Voronov on 12/05/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import Foundation
import UIKit

struct Config {
    static let weekdays = [
        "Понедельник",
        "Вторник",
        "Среда",
        "Четверг",
        "Пятница",
        "Суббота",
        "Воскресенье"
    ]
    
    static let months = [
        "",
        "Января",
        "Февраля",
        "Марта",
        "Апреля",
        "Мая",
        "Июня",
        "Июля",
        "Августа",
        "Сентября",
        "Октября",
        "Ноября",
        "Декабря"
    ]
    
    // Цветовая схема обычный режим
    struct Colors {
        static var background = #colorLiteral(red: 0.9473534226, green: 0.941721499, blue: 0.9516823888, alpha: 1)
        static var backgroundSecond = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        static var backgroundThird = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        static var textFirst = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        static var textSecond = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6)
        static var blue = #colorLiteral(red: 0.2374433279, green: 0.5704764724, blue: 0.9959508777, alpha: 1)
        static var green = #colorLiteral(red: 0.3492472069, green: 0.6454830266, blue: 0.1348775036, alpha: 1)
        static var red = #colorLiteral(red: 1, green: 0.3355553344, blue: 0.2866917798, alpha: 1)
        static var separator = #colorLiteral(red: 0.8903496861, green: 0.88905406, blue: 0.9107625484, alpha: 1)
    }
    
    // Цветовая схема темный режим
    static func changeToBlack() {
        Colors.background = #colorLiteral(red: 0.1411764706, green: 0.1490196078, blue: 0.1529411765, alpha: 1)
        Colors.backgroundSecond = #colorLiteral(red: 0.2284164131, green: 0.2514702678, blue: 0.2666666667, alpha: 1)
        Colors.backgroundThird = #colorLiteral(red: 0.1867569387, green: 0.2098347843, blue: 0.231372549, alpha: 1)
        Colors.textFirst = #colorLiteral(red: 0.9473534226, green: 0.941721499, blue: 0.9516823888, alpha: 1)
        Colors.textSecond = #colorLiteral(red: 0.9961728454, green: 0.9902502894, blue: 1, alpha: 0.3977418664)
        Colors.blue = #colorLiteral(red: 0, green: 0.4618991017, blue: 1, alpha: 1)
        Colors.green = #colorLiteral(red: 0.5401662588, green: 0.857365191, blue: 0.1591555476, alpha: 1)
        Colors.red = #colorLiteral(red: 1, green: 0.3355553344, blue: 0.2866917798, alpha: 1)
        Colors.separator = #colorLiteral(red: 0.1867569387, green: 0.2098347843, blue: 0.231372549, alpha: 1)
    }
    
    static var weekConf: Int {
        get {
            UserDefaults.standard.integer(forKey: "weekConf")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "weekConf")
        }
    }
}

