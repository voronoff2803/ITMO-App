//
//  SearchViewController.swift
//  ITMO
//
//  Created by Alexey Voronov on 20/07/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    let dataManager = DataFlowManager.shared
    var persons: [Person] = []

    lazy var searchBar = UISearchBar(frame: CGRect.zero)
    @IBOutlet weak var searchTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        setupColors()
    }
    
    func setup() {
        self.searchTableView.register(UINib(nibName: "PersonTableViewCell", bundle: nil), forCellReuseIdentifier: "PersonTableViewCell")
        self.searchTableView.dataSource = self
        self.searchTableView.delegate = self
        self.searchBar.placeholder = "Поиск по фамилии"
        self.searchBar.delegate = self
        if let textfield = self.searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = Config.Colors.backgroundThird
        }
        navigationItem.titleView = self.searchBar
    }
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.loadIndicator(show: true)
        self.searchBar.endEditing(true)
        dataManager.getPersons(lastname: searchBar.text ?? "", onSuccess: { persons in
            self.persons = persons
            self.loadIndicator(show: false)
            self.searchTableView.reloadData()
        }) { (error) in
            self.loadIndicator(show: false)
            print(error)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return persons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonTableViewCell") as! PersonTableViewCell
        cell.setup(person: persons[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "person", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let personScheduleVC = segue.destination as! PersonScheduleViewController
        let person = self.persons[searchTableView.indexPathForSelectedRow!.row]
        personScheduleVC.pid = person.pid
        personScheduleVC.person = person.person
    }
    
    func setupColors() {
        self.view.backgroundColor = Config.Colors.background
        self.searchTableView.backgroundColor = Config.Colors.background
        self.searchTableView.separatorColor = Config.Colors.separator
    }
}
