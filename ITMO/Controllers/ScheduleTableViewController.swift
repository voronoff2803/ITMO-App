//
//  ScheduleTableViewController.swift
//  ITMO
//
//  Created by Alexey Voronov on 17/07/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit
import BetterSegmentedControl
import ViewAnimator


class ScheduleTableViewController: UITableViewController {
    
    let dataManager = DataFlowManager.shared
    var weekEven = 1
    
    var isEvenEquals: Bool {
        get {
            return Helper.weekEven() == weekEven - 1
        }
    }
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentedChanged() {
        if self.segmentedControl?.selectedSegmentIndex == 0 {
            weekEven = 1
        } else {
            weekEven = 2
        }
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        self.setupColors()
        
        self.segmentedControl?.selectedSegmentIndex = Helper.weekEven()
        if Helper.weekEven() == 0 {
            segmentedControl?.setTitle(" • Четная", forSegmentAt: 0)
            segmentedControl?.setTitle("Нечетная", forSegmentAt: 1)
        } else {
            segmentedControl?.setTitle("Четная", forSegmentAt: 0)
            segmentedControl?.setTitle(" • Нечетная", forSegmentAt: 1)
        }
        self.segmentedChanged()
        if (dataManager.group == "") {
            self.performSegue(withIdentifier: "auth", sender: self)
        } else {
            dataManager.updateSchedule {
                self.tableView.reloadData()
                self.showCurrentGroup()
                self.scrollToDate()
            }
        }
        self.setup()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        self.showCurrentGroup()
        self.segmentedChanged()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (dataManager.group == "") {
            self.performSegue(withIdentifier: "auth", sender: self)
        }
        refresh()
        
    }
    
    func setupColors() {
        self.view.backgroundColor = Config.Colors.background
        self.tableView.backgroundColor = Config.Colors.background
    }
    
    func scrollToDate() {
        DispatchQueue.main.async {
            if self.tableView.contentOffset.y < -20 {
                var row = 0
                let section = Helper.normalWeekDay(Calendar.current.component(.weekday, from: Date()))
                if self.dataManager.getSchedule(even: self.weekEven, day: section).count != 0 {
                    row = self.dataManager.getSchedule(even: self.weekEven, day: section).count - 1
                }
                if section < 6 {
                    let indexPath = IndexPath(row: row, section: section)
                    print("Scroll to: \(indexPath)")
                    if self.tableView.numberOfRows(inSection: section) < 50 && self.tableView.numberOfRows(inSection: section) >= 0 {
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }
        }
    }
    
    func showCurrentGroup() {
        let group = dataManager.cdeSchedule?.label
        let more = UIBarButtonItem(title: group, style: .plain, target: self, action: #selector(goToSettings))
        self.navigationItem.leftBarButtonItem = more
    }
    
    func setup() {
        let search = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(toSearchController))
        self.navigationItem.rightBarButtonItem = search
        
        let more = UIBarButtonItem(title: dataManager.group, style: .plain, target: self, action: #selector(goToSettings))
        self.navigationItem.leftBarButtonItem = more
        
        self.refreshControl = UIRefreshControl()
        
        if let refreshControl = self.refreshControl{
            refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
            self.tableView.addSubview(refreshControl)
        }
        
        self.tableView.register(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: "ScheduleTableViewCell")
        self.tableView.register(UINib(nibName: "RelaxTableViewCell", bundle: nil), forCellReuseIdentifier: "RelaxTableViewCell")
    }
    
    @objc func toSearchController() {
        print("toSearchController")
        self.performSegue(withIdentifier: "search", sender: self)
    }
    
    @objc func refresh() {
        dataManager.updateSchedule {
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            self.showCurrentGroup()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if dataManager.cdeSchedule?.subjects.count ?? 0 > 0 {
            return 6
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataManager.getSchedule(even: weekEven, day: section).count == 0 {
            return 1
        }
        return dataManager.getSchedule(even: weekEven, day: section).count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataManager.getSchedule(even: weekEven, day: indexPath.section).count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RelaxTableViewCell", for: indexPath) as! RelaxTableViewCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableViewCell", for: indexPath) as! ScheduleTableViewCell
        let subject = dataManager.getSchedule(even: weekEven, day: indexPath.section)[indexPath.row]
        cell.setup(subject: subject)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UILabel()
        headerView.backgroundColor = Config.Colors.background
        headerView.textColor = Config.Colors.textFirst
        headerView.font = UIFont.systemFont(ofSize: 21, weight: .bold)
        if Helper.normalWeekDay(Calendar.current.component(.weekday, from: Date())) == section, isEvenEquals {
            headerView.text = "• " + textForHeader(section: section)
        } else {
            headerView.text = textForHeader(section: section)
        }
        headerView.padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "person", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let personScheduleVC = segue.destination as? PersonScheduleViewController {
            let subject = dataManager.getSchedule(even: weekEven, day: tableView.indexPathForSelectedRow!.section)[tableView.indexPathForSelectedRow!.row]
            personScheduleVC.pid = subject.pid
            personScheduleVC.person = subject.person
        }
    }
    
    @objc func goToSettings() {
        self.tabBarController?.selectedIndex = 4
    }
}
