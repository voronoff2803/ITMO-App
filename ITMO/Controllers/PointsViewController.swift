//
//  PointsViewController.swift
//  ITMO
//
//  Created by Alexey Voronov on 19/07/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit

class PointsViewController: UITableViewController {

    let dataManager = DataFlowManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupColors()
        dataManager.updateCdeJournal {
            self.loadLastPeriod()
            self.tableView.reloadData()
        }
        self.setup()
        self.loadLastPeriod()
        self.tableView.reloadData()
        self.updateButtons()
    }
    
    func setupColors() {
        self.view.backgroundColor = Config.Colors.background
        self.tableView.backgroundColor = Config.Colors.background
    }
    
    func updateButtons() {
        let leftBtn = UIBarButtonItem(title: dataManager.semestr + " сем", style: .plain, target: self, action: #selector(chooseSemestr))
        self.navigationItem.leftBarButtonItem = leftBtn
        
        let rightBtn = UIBarButtonItem(title: dataManager.studYear, style: .plain, target: self, action: #selector(chooseYear))
        self.navigationItem.rightBarButtonItem = rightBtn
    }
    
    func loadLastPeriod() {
        if dataManager.studYear == "" {
            dataManager.studYear = dataManager.getScheduleYears().last ?? ""
        }
        loadLastSemestr()
    }
    
    func loadLastSemestr() {
        dataManager.semestr = dataManager.cdeJournal?.years.first(where: {$0.studyyear == dataManager.studYear})?.subjects.last?.semester ?? ""
    }
    
    func setup() {
        self.refreshControl = UIRefreshControl()
        
        if let refreshControl = self.refreshControl{
            refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
            self.tableView.addSubview(refreshControl)
        }
        
        self.tableView.register(UINib(nibName: "CdeSubjectTableViewCell", bundle: nil), forCellReuseIdentifier: "CdeSubjectTableViewCell")
        self.tableView.allowsSelection = true
    }
    
    @objc func refresh() {
        dataManager.updateCdeJournal {
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            self.updateButtons()
        }
    }
    
    @objc @IBAction func chooseYear() {
        let myActionSheet = UIAlertController(title: "Выберите учебный год", message: "", preferredStyle: .actionSheet)
        
        myActionSheet.view.tintColor = Config.Colors.textFirst
        
        let years = dataManager.getScheduleYears()
        for i in years {
            myActionSheet.addAction(UIAlertAction(title: i, style: .default, handler: { action in
                self.changeStudYear(action: action)
            }))
        }
        myActionSheet.addAction(UIAlertAction(title: "Отмена", style: .default, handler: nil))
        self.present(myActionSheet, animated: true, completion: nil)
    }
    
    @objc @IBAction func chooseSemestr() {
        let myActionSheet = UIAlertController(title: "Выберите семестр", message: "", preferredStyle: .actionSheet)
        
        myActionSheet.view.tintColor = Config.Colors.textFirst
        
        var sem = Set<String>()
        if let year = dataManager.cdeJournal?.years.first(where: {$0.studyyear == dataManager.studYear}) {
            year.subjects.forEach{sem.insert($0.semester)}
            for i in Array(sem).sorted() {
                myActionSheet.addAction(UIAlertAction(title: i, style: .default, handler: { action in
                    self.changeStudSem(action: action)
                }))
            }
        }
        myActionSheet.addAction(UIAlertAction(title: "Отмена", style: .default, handler: nil))
        self.present(myActionSheet, animated: true, completion: nil)
    }
    
    func changeStudSem(action: UIAlertAction) {
        dataManager.semestr = action.title ?? ""
        dataManager.save()
        self.tableView.reloadData()
        self.updateButtons()
    }
    
    func changeStudYear(action: UIAlertAction) {
        dataManager.studYear = action.title ?? ""
        dataManager.save()
        self.loadLastSemestr()
        self.tableView.reloadData()
        self.updateButtons()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CdeSubjectTableViewCell", for: indexPath) as! CdeSubjectTableViewCell
        
        cell.setup(cdeSubject: dataManager.getCdeSubjects(studyyear: dataManager.studYear, semestr: dataManager.semestr)[indexPath.row])
        return cell
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.getCdeSubjects(studyyear: dataManager.studYear, semestr: dataManager.semestr).count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let subj = dataManager.getCdeSubjects(studyyear: dataManager.studYear, semestr: dataManager.semestr)[indexPath.row]
        let detailVC = DetailPointsTableViewController()
        detailVC.title = subj.name
        let navController = UINavigationController(rootViewController: detailVC)
        detailVC.cdePoints = Array(dataManager.getCdeSubjects(studyyear: dataManager.studYear, semestr: dataManager.semestr)[indexPath.row].points)
        DispatchQueue.main.async {
            self.present(navController, animated: true, completion: nil)
        }
    }
}
