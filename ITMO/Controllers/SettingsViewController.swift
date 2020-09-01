//
//  SettingsViewController.swift
//  ITMO
//
//  Created by Alexey Voronov on 19/07/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit
import Eureka
import UserNotifications
import FirebaseDatabase

class SettingsViewController: FormViewController {
    
    let dataManager = DataFlowManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupColors()

        form +++ Section("Информация ЦДО")
            <<< TextRow(){ row in
                row.title = "Логин"
                row.value = dataManager.login
                row.cell.backgroundColor = Config.Colors.backgroundSecond
            }
            .cellUpdate { cell, row in
                cell.titleLabel?.textColor = Config.Colors.textFirst
                cell.textField.textColor = Config.Colors.textFirst
            }
            .cellUpdate { cell, row in
                cell.titleLabel?.textColor = Config.Colors.textFirst
                cell.textField.textColor = Config.Colors.textFirst
            }
            <<<  PasswordRow(){ row in
                row.title = "Пароль"
                row.value = dataManager.password
                row.cell.backgroundColor = Config.Colors.backgroundSecond
                row.cell.titleLabel?.textColor = Config.Colors.textFirst
            }
            .cellUpdate { cell, row in
                cell.titleLabel?.textColor = Config.Colors.textFirst
                cell.textField.textColor = Config.Colors.textFirst
            }
            +++ Section()
            <<< ButtonRow() { row in
                row.title = "Выйти"
                row.cell.backgroundColor = Config.Colors.backgroundSecond
                row.cell.tintColor = Config.Colors.textFirst
                }.onCellSelection {_,_  in
                    self.logout()
            }
            +++ Section("Информация ИТМО")
            <<< TextRow(){ row in
                row.title = "Группа (латинские буквы)"
                row.value = dataManager.group
                row.cell.backgroundColor = Config.Colors.backgroundSecond
                row.cell.titleLabel?.textColor = Config.Colors.textFirst
            }
            .cellUpdate { cell, row in
                cell.titleLabel?.textColor = Config.Colors.textFirst
                cell.textField.textColor = Config.Colors.textFirst
            }
            +++ Section()
            <<< ButtonRow() { row in
                row.title = "Сохранить"
                row.cell.backgroundColor = Config.Colors.backgroundSecond
                row.cell.tintColor = Config.Colors.textFirst
                }.onCellSelection {_,_  in
                    self.save()
            }
            +++ Section()
            <<< SwitchRow() { row in
                row.title = "Уведомления о баллах"
                row.cell.backgroundColor = Config.Colors.backgroundSecond
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    DispatchQueue.main.async {
                        row.cell.switchControl.setOn(UIApplication.shared.isRegisteredForRemoteNotifications, animated: false)
                        print(UIApplication.shared.isRegisteredForRemoteNotifications)
                    }
                }
                }.onChange() { row in
                    if row.value == true {
                        self.accessNotofications() { accepted in
                            row.value = accepted
                            row.cell.switchControl.setOn(accepted, animated: true)
                        }
                    } else {
                        DispatchQueue.main.async {
                            UIApplication.shared.unregisterForRemoteNotifications()
                        }
                    }
                }.cellUpdate { cell, row in
                    cell.textLabel?.textColor = Config.Colors.textFirst
                }
            <<< LabelRow() { row in
                row.title = "Для рассылки уведомлений информация об аккаунте будет храниться на сервере приложения"
                row.cell.backgroundColor = Config.Colors.backgroundSecond
                row.cell.textLabel?.numberOfLines = 0
                row.cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
                //row.cell.textLabel?.textAlignment = .center
                }.cellUpdate { cell, row in
                    cell.textLabel?.textColor = Config.Colors.textFirst
                }
    }
    
    func logout() {
        self.dataManager.studYear = ""
        self.dataManager.login = ""
        self.dataManager.password = ""
        self.dataManager.group = ""
        self.dataManager.semestr = ""
        self.dataManager.save()
        tabBarController?.selectedIndex = 0
    }
    
    func save() {
        let loginRow = form.allRows[0] as! TextRow
        dataManager.login = loginRow.value ?? ""
        let passRow = form.allRows[1] as! PasswordRow
        dataManager.password = passRow.value ?? ""
        let groupRow = form.allRows[2] as! TextRow
        dataManager.group = groupRow.value ?? ""
        dataManager.save()
    }
    
    func setupColors() {
        self.view.backgroundColor = Config.Colors.background
        self.tableView.backgroundColor = Config.Colors.background
        self.tableView.separatorColor = Config.Colors.separator
    }
    
    func accessNotofications(compelition: @escaping (Bool) -> ()) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {(accepted, error) in
            if !accepted { print("Notification access denied.") } else {
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    guard settings.authorizationStatus == .authorized else { return }
                    DispatchQueue.main.async { UIApplication.shared.registerForRemoteNotifications() }
                }
            }
            DispatchQueue.main.async {
                compelition(accepted)
            }
        }
    }
}
