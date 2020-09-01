//
//  Models.swift
//  ITMO
//
//  Created by Alexey Voronov on 15/07/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import Foundation
import RealmSwift

// Модель расписания
class Schedule: Object {
    @objc dynamic var label = ""
    @objc dynamic var today_data_day = 0
    @objc dynamic var current_week = 0
    var subjects = List<ScheduleSubject>()
}

// Модель занятия
class ScheduleSubject: Object {
    @objc dynamic var pid = ""
    @objc dynamic var data_day = 0
    @objc dynamic var status = ""
    @objc dynamic var data_week = 0
    @objc dynamic var room = ""
    @objc dynamic var place = ""
    @objc dynamic var title = ""
    @objc dynamic var person = ""
    @objc dynamic var start_time = ""
    @objc dynamic var end_time = ""
    @objc dynamic var gr = ""
}

class CdeJournal: Object {
    var years = List<CdeYear>()
}

class CdeYear: Object {
    @objc dynamic var group = ""
    @objc dynamic var studyyear = ""
    let subjects = List<CdeSubject>()
}

class CdeSubject: Object {
    @objc dynamic var name = ""
    @objc dynamic var semester = ""
    let marks = List<CdeMark>()
    let points = List<CdePoint>()
}

class CdeMark: Object {
    @objc dynamic var mark = ""
    @objc dynamic var markdate = ""
    @objc dynamic var worktype = ""
}

class CdePoint: Object {
    @objc dynamic var variable = ""
    @objc dynamic var max = ""
    @objc dynamic var limit = ""
    @objc dynamic var value = ""
}

class Person {
    var pid: String = ""
    var person: String = ""
}

class Deadline {
    var subject: String = ""
    var title: String = ""
    var description: String = ""
    var date: String = ""
    var visible: String = ""
    var id: String = ""
    var user: String = ""
    var active: Bool = true
    var hidden: Bool = false
}
