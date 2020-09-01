//
//  AddDeadlineViewController.swift
//  ITMO
//
//  Created by Alexey Voronov on 01/08/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit
import Eureka
import Firebase

class AddDeadlineViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupColors()
        
        form +++ Section("Название")
            <<< TextRow(){ row in
                row.placeholder = "Что нужно сделать?"
                row.cell.backgroundColor = Config.Colors.backgroundSecond
                row.placeholderColor = Config.Colors.textFirst
            }
                .cellUpdate { cell, row in
                    cell.titleLabel?.textColor = Config.Colors.textFirst
                    cell.textField.textColor = Config.Colors.textFirst
            }
            +++ Section("Описание")
            <<< TextAreaRow(){ row in
                row.placeholder = "Подробности (не обязательно)"
                row.cell.backgroundColor = Config.Colors.backgroundSecond
                row.cell.textView.backgroundColor = Config.Colors.backgroundSecond
                row.cell.textView.tintColor = Config.Colors.textFirst
                }
                .cellUpdate { cell, row in
                    cell.textLabel?.textColor = Config.Colors.textFirst
                    cell.textView.textColor = Config.Colors.textFirst
            }
            +++ Section()
            <<< TextRow(){ row in
                row.cell.backgroundColor = Config.Colors.backgroundSecond
                row.placeholderColor = Config.Colors.textFirst
                row.placeholder = "Предмет или категория"
            }
                .cellUpdate { cell, row in
                    cell.titleLabel?.textColor = Config.Colors.textFirst
                    cell.textField.textColor = Config.Colors.textFirst
            }
            +++ Section()
            <<< DateRow(){ row in
                row.cell.backgroundColor = Config.Colors.backgroundSecond
                row.cell.tintColor = Config.Colors.textFirst
                row.value = Date()
                row.title = "Дата дедлайна"
            }
                .cellUpdate { cell, row in
                    cell.textLabel?.textColor = Config.Colors.textFirst
            }
            +++ Section("Кому виден?")
            <<< PickerInputRow<String>(){ row in
                row.cell.backgroundColor = Config.Colors.backgroundSecond
                row.cell.tintColor = Config.Colors.textFirst
                row.value = "Только мне"
                row.options = ["Всем студентам", "Одногруппникам", "Только мне"]
            }
                .cellUpdate { cell, row in
                    cell.textLabel?.textColor = Config.Colors.textFirst
            }
            +++ Section()
            <<< ButtonRow() { row in
                row.cell.backgroundColor = Config.Colors.backgroundSecond
                row.cell.tintColor = Config.Colors.backgroundSecond
                row.title = "Добавить"
                }.onCellSelection {_,_ in
                    self.addDeadline()
            }
                .cellUpdate { cell, row in
                    cell.textLabel?.textColor = Config.Colors.textFirst
        }
    }
    
    func setupColors() {
        self.view.backgroundColor = Config.Colors.background
        self.tableView.backgroundColor = Config.Colors.background
        self.tableView.separatorColor = Config.Colors.separator
    }
    
    func addDeadline() {
        let nameRow = form.allRows[0] as! TextRow
        let descriptionRow = form.allRows[1] as! TextAreaRow
        let categoryRow = form.allRows[2] as! TextRow
        let dateRow = form.allRows[3] as! DateRow
        let visibleRow = form.allRows[4] as! PickerInputRow<String>
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let name = nameRow.value ?? ""
        let description = descriptionRow.value ?? ""
        let category = categoryRow.value ?? ""
        let date = dateFormatter.string(from: dateRow.value!)
        let visible = visibleRow.value ?? ""
        
        
        let ref = Database.database().reference()
        
        if visible == "Только мне" {
            if (DataFlowManager.shared.login != "") {
                if (name != "" && category != "") {
                    let key = ref.child(DataFlowManager.shared.login).childByAutoId().key!
                    
                    let dictionaryTodo = [ "name": name,
                                           "description": description,
                                           "category": category,
                                           "date": date,
                                           "visible": "Личное",
                                           "hidden": 0,
                                           "active": 1,
                                           "id": key,
                                           "user": DataFlowManager.shared.login] as [String : Any]
                    let childUpdates = ["/\(DataFlowManager.shared.login)/\(key)": dictionaryTodo]
                    print("/\(DataFlowManager.shared.login)/\(key)")
                    
                    ref.updateChildValues(childUpdates, withCompletionBlock: { (error, ref) -> Void in
                        self.loadIndicator(show: false)
                        self.navigationController?.popViewController(animated: true)
                    })
                } else {
                    alert(title: "Ошибка", message: "Заполните все поля")
                }
            } else {
                alert(title: "Ошибка", message: "Войдите в свой аккаунт")
            }
        }
        
        if visible == "Одногруппникам" {
            if (DataFlowManager.shared.login != "" && DataFlowManager.shared.group != "") {
                if (name != "" && category != "") {
                    let key = ref.child(DataFlowManager.shared.group).childByAutoId().key!
                    
                    let dictionaryTodo = [ "name": name,
                                           "description": description,
                                           "category": category,
                                           "date": date,
                                           "visible": DataFlowManager.shared.group,
                                           "id": key,
                                           "user": DataFlowManager.shared.login] as [String : Any]
                    let childUpdates = ["/\(DataFlowManager.shared.group)/\(key)": dictionaryTodo]
                    print("/\(DataFlowManager.shared.group)/\(key)")
                    
                    ref.updateChildValues(childUpdates, withCompletionBlock: { (error, ref) -> Void in
                        self.navigationController?.popViewController(animated: true)
                    })
                } else {
                    alert(title: "Ошибка", message: "Заполните все поля")
                }
            } else {
                alert(title: "Ошибка", message: "Войдите в свой аккаунт")
            }
        }
        
        if visible == "Всем студентам" {
            if (DataFlowManager.shared.login != "" && DataFlowManager.shared.group != "") {
                if (name != "" && category != "") {
                    let key = ref.child("all").childByAutoId().key!
                    
                    let dictionaryTodo = [ "name": name,
                                           "description": description,
                                           "category": category,
                                           "date": date,
                                           "visible": "Все студенты",
                                           "id": key,
                                           "user": DataFlowManager.shared.login] as [String : Any]
                    let childUpdates = ["/all/\(key)": dictionaryTodo]
                    print("/all/\(key)")
                    
                    ref.updateChildValues(childUpdates, withCompletionBlock: { (error, ref) -> Void in
                        self.navigationController?.popViewController(animated: true)
                    })
                } else {
                    alert(title: "Ошибка", message: "Заполните все поля")
                }
            } else {
                alert(title: "Ошибка", message: "Войдите в свой аккаунт")
            }
        }
    }
}
