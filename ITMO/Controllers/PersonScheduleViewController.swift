//
//  PersonScheduleViewController.swift
//  ITMO
//
//  Created by Alexey Voronov on 20/07/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit

class PersonScheduleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var pid: String = ""
    var person: String = ""
    var subjects: [ScheduleSubject] = []
    
    var isEvenEquals: Bool {
        get {
            return Helper.weekEven() == weekEven - 1
        }
    }
    
    let dataManager = DataFlowManager.shared
    
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var personLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var segmentedControl: UISegmentedControl?
    
    var weekEven = 1
    
    @IBAction func segmentedChanged() {
        if self.segmentedControl?.selectedSegmentIndex == 0 {
            weekEven = 1
        } else {
            weekEven = 2
        }
        self.scheduleTableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupColors()
        self.setup()
        self.loadIndicator(show: true)
        self.segmentedControl?.selectedSegmentIndex = Helper.weekEven()
        if Helper.weekEven() == 0 {
            segmentedControl?.setTitle("• Четная", forSegmentAt: 0)
            segmentedControl?.setTitle("Нечетная", forSegmentAt: 1)
        } else {
            segmentedControl?.setTitle("Четная", forSegmentAt: 0)
            segmentedControl?.setTitle("• Нечетная", forSegmentAt: 1)
        }
        self.segmentedChanged()
        dataManager.getPersonSchedule(pid: self.pid, onSuccess: { newSubjects in
            self.subjects = newSubjects
            self.scheduleTableView.reloadData()
            self.loadIndicator(show: false)
            self.segmentedControl?.selectedSegmentIndex = Helper.weekEven()
            if Helper.weekEven() == 0 {
                self.segmentedControl?.setTitle("• Четная", forSegmentAt: 0)
                self.segmentedControl?.setTitle("Нечетная", forSegmentAt: 1)
            } else {
                self.segmentedControl?.setTitle("Четная", forSegmentAt: 0)
                self.segmentedControl?.setTitle("• Нечетная", forSegmentAt: 1)
            }
            self.segmentedChanged()
            self.scrollToDate()
        }) { error in
            print(error)
            self.loadIndicator(show: false)
        }
    }
    
    func setupColors() {
        self.view.backgroundColor = Config.Colors.background
        scheduleTableView.backgroundColor = Config.Colors.background
        photoImageView.backgroundColor = Config.Colors.backgroundSecond
    }
    
    func setup() {
        self.scheduleTableView.register(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: "ScheduleTableViewCell")
        self.scheduleTableView.register(UINib(nibName: "RelaxTableViewCell", bundle: nil), forCellReuseIdentifier: "RelaxTableViewCell")
        self.scheduleTableView.allowsSelection = false
        self.scheduleTableView.dataSource = self
        self.scheduleTableView.delegate = self
        self.personLabel.text = self.person
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.subjects.count > 0 {
            return 6
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.getSchedule(even: weekEven, day: section).count == 0 {
            return 1
        }
        return self.getSchedule(even: weekEven, day: section).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.getSchedule(even: weekEven, day: indexPath.section).count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RelaxTableViewCell", for: indexPath) as! RelaxTableViewCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableViewCell", for: indexPath) as! ScheduleTableViewCell
        let subject = self.getSchedule(even: weekEven, day: indexPath.section)[indexPath.row]
        cell.setup(subject: subject)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UILabel()
        headerView.backgroundColor = Config.Colors.background
        headerView.text = textForHeader(section: section)
        headerView.font = UIFont.systemFont(ofSize: 21, weight: .bold)
        headerView.padding = UIEdgeInsets(top: 16, left: 16, bottom: 4, right: 16)
        return headerView
    }
    
    func textForHeader(section: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMMM"
        
        let currentDay = Helper.normalWeekDay(Calendar.current.component(.weekday, from: Date()))
        var offset = 0
        if isEvenEquals {
            offset = 0
        } else {
            offset = 7
        }
        if currentDay == 6 {
            offset += 7
        }
        return Config.weekdays[section] + ", " + formatter.string(from: Date().addingTimeInterval(86400.0 * Double(section - currentDay + offset)))
    }
    
    func getSchedule(even: Int, day: Int) -> [ScheduleSubject] {
        return subjects.filter {$0.data_day == day && ($0.data_week == even || $0.data_week == 0)}
    }
    
    func scrollToDate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if self.scheduleTableView.contentOffset.y < -20 {
                var row = 0
                let section = Helper.normalWeekDay(Calendar.current.component(.weekday, from: Date()))
                if self.dataManager.getSchedule(even: self.weekEven, day: section).count != 0 {
                    row = self.dataManager.getSchedule(even: self.weekEven, day: section).count - 1
                }
                if section < 6 {
                    let indexPath = IndexPath(row: row, section: section)
                    print("Scroll to: \(indexPath)")
                    if self.scheduleTableView.numberOfRows(inSection: section) < 50 && self.scheduleTableView.numberOfRows(inSection: section) >= 0 {
                        self.scheduleTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
                    }
                }
            }
        }
    }
}
