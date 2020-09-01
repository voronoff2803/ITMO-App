//
//  RentsTableViewController.swift
//  ITMO
//
//  Created by Алексей Воронов on 27.02.2020.
//  Copyright © 2020 Alexey Voronov. All rights reserved.
//

import UIKit

class RentsTableViewController: UITableViewController {
    
    let api = ApiWorker.shared
    var result: [String: Any] = [:]
    var infoLabel: UILabel?

    func setupColors() {
        self.view.backgroundColor = Config.Colors.background
        self.tableView.backgroundColor = Config.Colors.background
        self.tableView.separatorColor = Config.Colors.separator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupColors()
        self.refreshControl?.addTarget(self, action: #selector(loadData), for: UIControl.Event.valueChanged)
        
        infoLabel = UILabel()
        infoLabel?.textColor = Config.Colors.textFirst
        infoLabel?.frame = CGRect(origin: .zero, size: CGSize(width: 0, height: 140))
        infoLabel?.numberOfLines = 0
        infoLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        self.tableView.tableHeaderView = infoLabel
    }
    
    func setInfoLabel() {
        print(result)
        guard let limit = result["limit"] as? Int else { return }
        guard let balance = result["left"] as? Int else { return }
        guard let fine = result["fine"] as? Int else { return }
        infoLabel?.text = "Лимит: \(limit)\nОсталось времени: \(balance) \nШтраф: \(fine)"
        infoLabel?.padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return getRents().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rent = getRents()[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.backgroundColor = Config.Colors.background
        cell.textLabel?.text = (rent["date"] as? String ?? "") + " | " + (rent["time"] as? String ?? "")
        cell.textLabel?.textColor = Config.Colors.textFirst
        cell.detailTextLabel?.text = rent["status"] as? String ?? ""
        cell.detailTextLabel?.textColor = Config.Colors.textSecond
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        deleteRent(row: indexPath.row)
        cell?.setSelected(false, animated: true)
    }
    
    func deleteRent(row: Int) {
        
        let rent = getRents()[row]
        
        if let id = rent["delete_id"] as? String {
            let alert = UIAlertController(title: "Отмена записи", message: "Точно хотите отменить запись?", preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { (action) in
                self.loadIndicator(show: true, true)
                self.api.deleteRent(deleteId: id, onSuccess: { (result) in
                    DispatchQueue.main.async {
                        self.loadIndicator(show: false)
                        self.loadData()
                        self.dismiss(animated: true, completion: nil)
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        self.loadIndicator(show: false)
                        self.dismiss(animated: true) {
                            self.alert(title: "Ошибка", message: "Ошибка отмены записи")
                        }
                    }
                }
            }
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        } else {
            self.alert(title: "Ошибка отмены записи", message: "Заявка уже выполнена")
        }
    }
    
    @objc func loadData() {
        self.loadIndicator(show: true, true)
        api.showRents(onSuccess: { (result) in
            DispatchQueue.main.async {
                self.loadIndicator(show: false)
                self.refreshControl?.endRefreshing()
                if let dict = result as? [String : Any] {
                    self.result = dict
                    self.tableView.reloadData()
                    self.setInfoLabel()
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
    
    func getRents() -> [[String: Any]] {
        return result["rents"] as? [[String: Any]] ?? []
    }
}
