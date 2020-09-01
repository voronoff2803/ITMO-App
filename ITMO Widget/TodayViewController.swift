//
//  TodayViewController.swift
//  ITMO Widget
//
//  Created by Alexey Voronov on 17/08/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit
import NotificationCenter
import RealmSwift

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDataSource {
    var weekEven = 1
    var dayOfWeek = 0
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if cdeSchedule?.subjects.count ?? 0 > 0 {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if getSchedule(even: weekEven, day: dayOfWeek).count == 0 {
            return 1
        }
        return getSchedule(even: weekEven, day: dayOfWeek).count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if getSchedule(even: weekEven, day: dayOfWeek).count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RelaxTableViewCell", for: indexPath) as! RelaxTableViewCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableViewCell", for: indexPath) as! ScheduleTableViewCell
        let subject = getSchedule(even: weekEven, day: dayOfWeek)[indexPath.row]
        cell.setup(subject: subject)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Config.weekdays[dayOfWeek]
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
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
    
    func getSchedule(even: Int, day: Int) -> [ScheduleSubject] {
        if cdeSchedule != nil {
            return Array(cdeSchedule!.subjects).filter {$0.data_day == day && ($0.data_week == even || $0.data_week == 0)}
        } else {
            return []
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        dayOfWeek = Helper.normalWeekDay(Calendar.current.component(.weekday, from: Date()))
        
        if Calendar.current.component(.hour, from: Date()) > 20 {
            if dayOfWeek > 5 {
                dayOfWeek = 0
            } else {
                dayOfWeek += 1
            }
        }
        
        if Helper.weekEven() > 0 {
            weekEven = 2
        } else {
            weekEven = 1
        }
        
        tableView.dataSource = self
        
        self.tableView.register(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: "ScheduleTableViewCell")
        self.tableView.register(UINib(nibName: "RelaxTableViewCell", bundle: nil), forCellReuseIdentifier: "RelaxTableViewCell")
        tableView.isUserInteractionEnabled = false
        
        
        tableView.reloadData()
        //self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            self.preferredContentSize = CGSize(width: self.tableView.contentSize.width, height: self.tableView.contentSize.height)
        }
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        
        if activeDisplayMode == NCWidgetDisplayMode.compact {
            //compact
            self.preferredContentSize = CGSize(width: maxSize.width, height: 100)
        } else {
            //extended
            self.preferredContentSize = CGSize(width: maxSize.width, height: tableView.contentSize.height)
        }
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
