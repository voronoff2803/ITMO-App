//
//  DeadlineTableViewController.swift
//  ITMO
//
//  Created by Alexey Voronov on 01/08/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class DeadlineTableViewController: UITableViewController {
    
    var deadlines: [Deadline] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupColors()

        self.tableView.register(UINib(nibName: "DeadlineTableViewCell", bundle: nil), forCellReuseIdentifier: "DeadlineTableViewCell")
        self.tableView.allowsSelection = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadData()
        self.copyDeadlines()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if deadlines.filter({($0.active == true && $0.hidden == false)}).count == 0 && deadlines.filter({($0.active == false && $0.hidden == false)}).count == 0 {
            return 0
        } else {
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return deadlines.filter({($0.active == true && $0.hidden == false)}).count
        } else {
            return deadlines.filter({($0.active == false && $0.hidden == false)}).count
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeadlineTableViewCell", for: indexPath) as! DeadlineTableViewCell

        if indexPath.section == 0 {
            cell.setup(deadline: deadlines.filter({($0.active == true && $0.hidden == false)})[indexPath.row])
        } else {
            cell.setup(deadline: deadlines.filter({($0.active == false && $0.hidden == false)})[indexPath.row])
        }
        
        return cell
    }
    
    func setupColors() {
        self.view.backgroundColor = Config.Colors.background
        self.tableView.backgroundColor = Config.Colors.background
        self.tableView.separatorColor = Config.Colors.separator
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UILabel()
        headerView.backgroundColor = Config.Colors.background
        headerView.textColor = Config.Colors.textFirst
        headerView.font = UIFont.systemFont(ofSize: 21, weight: .bold)
        if section == 0 {
            headerView.text = "Активные"
        } else {
            headerView.text = "Завершенные"
        }
        headerView.padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return headerView
    }
    
    @IBAction func addAction() {
        self.performSegue(withIdentifier: "add", sender: nil)
    }
    
    func loadData() {
        let ref = Database.database().reference(withPath: DataFlowManager.shared.login)
        ref.observe(.value, with: { snapshot in
            if let todoDict = snapshot.value as? [String:AnyObject] {
                self.deadlines = []
                for (_,todoElement) in todoDict {
                    let deadline = Deadline()
                    deadline.title = todoElement["name"] as? String ?? ""
                    deadline.subject = todoElement["category"] as? String ?? ""
                    deadline.description = todoElement["description"] as? String ?? ""
                    deadline.date = todoElement["date"] as? String ?? ""
                    deadline.visible = todoElement["visible"] as? String ?? ""
                    deadline.id = todoElement["id"] as? String ?? ""
                    deadline.active = todoElement["active"] as? Bool ?? true
                    deadline.hidden = todoElement["hidden"] as? Bool ?? false
                    deadline.user = todoElement["user"] as? String ?? ""
                    
                    self.deadlines.append(deadline)
                }
            }
            self.tableView.reloadData()
            
            for deadline in self.deadlines.filter({$0.active == true && $0.hidden == false}) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy.HH.mm"
                guard let date = dateFormatter.date(from: deadline.date + ".09.00") else { return }
                
                self.scheduleNotification(at: date, title: deadline.title, body: deadline.description, id: deadline.id)
            }
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let deadline = deadlines.filter({($0.active == true && $0.hidden == false)})[indexPath.row]
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [deadline.id])
            Database.database().reference(withPath: "\(DataFlowManager.shared.login)/\(deadline.id)").updateChildValues(["active": 0])
        } else {
            let deadline = deadlines.filter({($0.active == false && $0.hidden == false)})[indexPath.row]
            
            Database.database().reference(withPath: "\(DataFlowManager.shared.login)/\(deadline.id)").updateChildValues(["active": 1])
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            if indexPath.section == 0 {
                let deadline = deadlines.filter({($0.active == true && $0.hidden == false)})[indexPath.row]
                Database.database().reference(withPath: "\(DataFlowManager.shared.login)/\(deadline.id)").updateChildValues(["hidden": 1])
            } else {
                let deadline = deadlines.filter({($0.active == false && $0.hidden == false)})[indexPath.row]
                Database.database().reference(withPath: "\(DataFlowManager.shared.login)/\(deadline.id)").updateChildValues(["hidden": 1])
            }
        }
    }
    
    func copyDeadlines() {
        if (DataFlowManager.shared.group != "" && DataFlowManager.shared.login != "") {
            let allRef = Database.database().reference(withPath: "/all")
            let groupRef = Database.database().reference(withPath: "/\(DataFlowManager.shared.group)")
            let ref = Database.database().reference(withPath: DataFlowManager.shared.login)
            
            allRef.observe(.value) { (snapshot) in
                if let todoDict = snapshot.value as? [String:AnyObject] {
                    for (key, value) in todoDict {
                        ref.child(key).observe(.value) { (snapshot) in
                            if !snapshot.exists() {
                                if let dictValue = value as? [String:AnyObject] {
                                    ref.child(key).updateChildValues(dictValue)
                                }
                            }
                        }
                    }
                }
            }
            
            groupRef.observe(.value) { (snapshot) in
                if let todoDict = snapshot.value as? [String:AnyObject] {
                    for (key, value) in todoDict {
                        ref.child(key).observe(.value) { (snapshot) in
                            if !snapshot.exists() {
                                if let dictValue = value as? [String:AnyObject] {
                                    ref.child(key).updateChildValues(dictValue)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func scheduleNotification(at date: Date, title: String, body: String, id: String) {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        
        print(newComponents)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }
}
