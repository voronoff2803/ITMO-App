//
//  DataFlowManager.swift
//  ITMO
//
//  Created by Alexey Voronov on 15/07/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import Foundation
import RealmSwift

class DataFlowManager {
    static var shared = DataFlowManager()
    
    var studYear: String = ""
    var login: String = ""
    var password: String = ""
    var group: String = ""
    var semestr: String = ""
    var notificationToken = ""
    
    var realm: Realm {
        let fileURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.itmo")!
            .appendingPathComponent("default.realm")
        let config = Realm.Configuration(fileURL: fileURL)
        let realm = try! Realm(configuration: config)
        return realm
    }
    
    var cdeSchedule: Schedule? {
        get {
            return realm.objects(Schedule.self).first
        }
    }
    var cdeJournal: CdeJournal? {
        get {
            return realm.objects(CdeJournal.self).first
        }
    }
    
    private init() {
        self.studYear = UserDefaults.standard.string(forKey: "studYear") ?? ""
        self.login = UserDefaults.standard.string(forKey: "login") ?? ""
        self.password = UserDefaults.standard.string(forKey: "password") ?? ""
        self.group = UserDefaults.standard.string(forKey: "group") ?? ""
        self.semestr = UserDefaults.standard.string(forKey: "semestr") ?? ""
    }
    
    func save() {
        UserDefaults.standard.set(self.studYear, forKey: "studYear")
        UserDefaults.standard.set(self.login, forKey: "login")
        UserDefaults.standard.set(self.password, forKey: "password")
        UserDefaults.standard.set(self.group, forKey: "group")
        UserDefaults.standard.set(self.semestr, forKey: "semestr")
    }
    
    // Получение расписания и запись в БД
    func updateSchedule(onSuccess: @escaping () -> Void) {
        ApiWorker.shared.getSchedule(group: self.group, onSuccess: { (dict) in
            let schedule = Schedule()
            schedule.current_week = dict["current_week"] as? Int ?? 0
            schedule.label = dict["label"] as? String ?? ""
            schedule.today_data_day = dict["today_data_day"] as? Int ?? 0
            schedule.current_week = dict["current_week"] as? Int ?? 0
            if let jsonSubjects = dict["schedule"] as? [[String : Any]] {
                for jsonSubject in jsonSubjects {
                    let subject = ScheduleSubject()
                    subject.pid = String(jsonSubject["pid"] as? Int ?? 0)
                    subject.data_day = jsonSubject["data_day"] as? Int ?? 0
                    subject.data_week = jsonSubject["data_week"] as? Int ?? 0
                    subject.end_time = jsonSubject["end_time"] as? String ?? ""
                    subject.person = jsonSubject["person"] as? String ?? ""
                    subject.place = jsonSubject["place"] as? String ?? ""
                    subject.room = jsonSubject["room"] as? String ?? ""
                    subject.start_time = jsonSubject["start_time"] as? String ?? ""
                    subject.status = jsonSubject["status"] as? String ?? ""
                    subject.title = jsonSubject["title"] as? String ?? ""
                    schedule.subjects.append(subject)
                }
            }
            DispatchQueue.main.async {
                if let realmSchedule = self.realm.objects(Schedule.self).first {
                    try! self.realm.write {
                        realmSchedule.current_week = schedule.current_week
                        realmSchedule.label = schedule.label
                        realmSchedule.today_data_day = schedule.today_data_day
                        realmSchedule.subjects.removeAll()
                        for i in schedule.subjects {
                            realmSchedule.subjects.append(i)
                        }
                    }
                } else {
                    try! self.realm.write {
                        self.realm.add(schedule)
                    }
                }
                onSuccess()
            }
        }) { (error) in
            DispatchQueue.main.async {
                onSuccess()
            }
        }
    }
    
    func updateCdeJournal(onSuccess: @escaping () -> Void) {
        ApiWorker.shared.getJournal(login: self.login, pass: self.password, onSuccess: { (dict) in
            let journal = CdeJournal()
            if let jsonYears = dict["years"] as? [[String : Any]] {
                for jsonYear in jsonYears {
                    let year = CdeYear()
                    year.group = jsonYear["group"] as? String ?? ""
                    year.studyyear = jsonYear["studyyear"] as? String ?? ""
                    if let jsonSubjects = jsonYear["subjects"] as? [[String: Any]] {
                        for jsonSubject in jsonSubjects {
                            let subject = CdeSubject()
                            subject.name = jsonSubject["name"] as? String ?? ""
                            subject.semester = jsonSubject["semester"] as? String ?? ""
                            if let jsonMarks = jsonSubject["marks"] as? [[String: Any]] {
                                for jsonMark in jsonMarks {
                                    let mark = CdeMark()
                                    mark.mark = jsonMark["mark"] as? String ?? ""
                                    mark.markdate = jsonMark["markdate"] as? String ?? ""
                                    mark.worktype = jsonMark["worktype"] as? String ?? ""
                                    subject.marks.append(mark)
                                }
                            }
                            if let jsonPoints = jsonSubject["points"] as? [[String: Any]] {
                                for jsonPoint in jsonPoints {
                                    let point = CdePoint()
                                    point.limit = jsonPoint["limit"] as? String ?? ""
                                    point.max = jsonPoint["max"] as? String ?? ""
                                    point.value = jsonPoint["value"] as? String ?? ""
                                    point.variable = jsonPoint["variable"] as? String ?? ""
                                    subject.points.append(point)
                                }
                            }
                            year.subjects.append(subject)
                        }
                    }
                    journal.years.append(year)
                }
            }
            DispatchQueue.main.async {
                if let realmJournal = self.realm.objects(CdeJournal.self).first {
                    try! self.realm.write {
                        realmJournal.years.removeAll()
                        for i in journal.years {
                            realmJournal.years.append(i)
                        }
                    }
                } else {
                    try! self.realm.write {
                        self.realm.add(journal)
                    }
                }
                onSuccess()
            }
        }) { (error) in
            DispatchQueue.main.async {
                onSuccess()
            }
        }
    }
    
    func getPersons(lastname: String, onSuccess: @escaping([Person]) -> Void, onFailure: @escaping(Error) -> Void) {
        ApiWorker.shared.getPersons(lastname: lastname, onSuccess: { (dict) in
            if let personsJson = dict["list"] as? [[String: Any]] {
                var persons: [Person] = []
                for personJson in personsJson {
                    let person = Person()
                    person.person = personJson["person"] as? String ?? ""
                    person.pid = String(personJson["pid"] as? Int ?? 0)
                    persons.append(person)
                }
                DispatchQueue.main.async {
                    onSuccess(persons)
                }
            } else {
                onFailure(NSError(domain: "getPersons", code: 22, userInfo: nil))
            }
        }) { (error) in
            onFailure(error)
        }
    }
    
    func getPersonSchedule(pid: String, onSuccess: @escaping([ScheduleSubject]) -> Void, onFailure: @escaping(Error) -> Void) {
        ApiWorker.shared.getSchedule(pid: pid, onSuccess: { (dict) in
            var subjects: [ScheduleSubject] = []
            if let jsonSubjects = dict["schedule"] as? [[String : Any]] {
                for jsonSubject in jsonSubjects {
                    let subject = ScheduleSubject()
                    subject.pid = String(jsonSubject["pid"] as? Int ?? 0)
                    subject.data_day = jsonSubject["data_day"] as? Int ?? 0
                    subject.data_week = jsonSubject["data_week"] as? Int ?? 0
                    subject.end_time = jsonSubject["end_time"] as? String ?? ""
                    subject.gr = jsonSubject["gr"] as? String ?? ""
                    subject.person = jsonSubject["person"] as? String ?? ""
                    subject.place = jsonSubject["place"] as? String ?? ""
                    subject.room = jsonSubject["room"] as? String ?? ""
                    subject.start_time = jsonSubject["start_time"] as? String ?? ""
                    subject.status = jsonSubject["status"] as? String ?? ""
                    subject.title = jsonSubject["title"] as? String ?? ""
                    subjects.append(subject)
                }
                DispatchQueue.main.async {
                    onSuccess(subjects)
                }
            } else {
                onFailure(NSError(domain: "getPersonSchedule", code: 22, userInfo: nil))
            }
        }) { error in
            onFailure(error)
        }
    }
    
    func getSchedule(even: Int, day: Int) -> [ScheduleSubject] {
        if cdeSchedule != nil {
            return Array(cdeSchedule!.subjects).filter {$0.data_day == day && ($0.data_week == even || $0.data_week == 0)}
        } else {
            return []
        }
    }
    
    func getScheduleYears() -> [String] {
        if cdeJournal != nil {
            return cdeJournal?.years.map{$0.studyyear} ?? []
        } else {
            return []
        }
    }
    
    func getCdeSubjects(studyyear: String, semestr: String) -> [CdeSubject] {
        let year = DataFlowManager.shared.cdeJournal?.years.first(where: {$0.studyyear == studyyear})
        if let subjects = year?.subjects.filter({$0.semester == semestr}) {
            return Array(subjects).sorted(by: { first, second in
                let firstPoint = Float(first.points.first?.value.replacingOccurrences(of: ",", with: ".") ?? "") ?? 0.0
                let secondPoint = Float(second.points.first?.value.replacingOccurrences(of: ",", with: ".") ?? "") ?? 0.0
                let result = firstPoint > secondPoint
                return result
            })
        } else {
            return []
        }
    }
}

