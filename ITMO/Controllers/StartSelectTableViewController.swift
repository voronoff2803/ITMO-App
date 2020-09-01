//
//  RentsTableViewController.swift
//  ITMO
//
//  Created by Алексей Воронов on 27.02.2020.
//  Copyright © 2020 Alexey Voronov. All rights reserved.
//

import UIKit

class StartSelectTableViewController: UITableViewController {
    
    let api = ApiWorker.shared
    var times: [[Any]] = []

    func setupColors() {
        self.view.backgroundColor = Config.Colors.background
        self.tableView.backgroundColor = Config.Colors.background
        self.tableView.separatorColor = Config.Colors.separator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupColors()
        loadData()
        self.refreshControl?.addTarget(self, action: #selector(loadData), for: UIControl.Event.valueChanged)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return times.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.backgroundColor = Config.Colors.background
        cell.textLabel?.text = times[indexPath.row][0] as? String ?? ""
        cell.textLabel?.textColor = Config.Colors.textFirst
        cell.detailTextLabel?.text = "Свободных мест: " + String(times[indexPath.row][1] as? Int ?? 0)
        cell.detailTextLabel?.textColor = Config.Colors.textSecond
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: true)
        
        api.cdeStart = cell?.textLabel?.text ?? ""
        performSegue(withIdentifier: "next", sender: nil)
    }
    
    @objc func loadData() {
        self.loadIndicator(show: true)
        api.showStart(onSuccess: { (result) in
            DispatchQueue.main.async {
                self.loadIndicator(show: false)
                self.refreshControl?.endRefreshing()
                print(result)
                if let times = result?["result"] as? [[Any]] {
                    self.times = times
                    print(times)
                    self.tableView.reloadData()
                }
            }
        }) { (error) in
            DispatchQueue.main.async {
                self.loadIndicator(show: false)
                self.refreshControl?.endRefreshing()
            }
            self.alert(title: "Ошибка", message: error)
        }
    }
}
