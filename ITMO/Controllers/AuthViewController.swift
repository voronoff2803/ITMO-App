//
//  AuthViewController.swift
//  ITMO
//
//  Created by Alexey Voronov on 21/07/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import UIKit
import Eureka
import Firebase
import UserNotifications

class AuthViewController: FormViewController {
    
    let dataManager = DataFlowManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupColors()
        
        let logoView = UIImageView(image: #imageLiteral(resourceName: "iconWithShadow"))
        logoView.contentMode = .scaleAspectFit
        logoView.frame = CGRect(origin: .zero, size: CGSize(width: 0, height: 140))
        
        self.tableView.tableHeaderView = logoView
        
        form +++ Section("Информация ЦДО")
            <<< TextRow(){ row in
                row.title = "Логин"
            }
            <<<  PasswordRow(){ row in
                row.title = "Пароль"
            }
            +++ Section()
            <<< ButtonRow() { row in
                row.title = "Войти"
                }.onCellSelection {_,_  in
                    self.login()
            }
            +++ Section()
            <<< SwitchRow() { row in
                row.title = "Уведомления о баллах"
                }.onChange() { row in
                    if row.value == true {
                        self.accessNotofications() { accepted in
                            row.value = accepted
                            row.cell.switchControl.setOn(accepted, animated: true)
                        }
                    } else {
                        UIApplication.shared.unregisterForRemoteNotifications()
                    }
            }
            <<< LabelRow() { row in
                row.title = "Для рассылки уведомлений информация об аккаунте будет храниться на сервере приложения"
                row.cell.textLabel?.numberOfLines = 0
                row.cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
                row.cell.textLabel?.textAlignment = .center
            }
    }
    
    func setupColors() {
        self.view.backgroundColor = Config.Colors.background
        self.tableView.backgroundColor = Config.Colors.background
        self.tableView.separatorColor = Config.Colors.separator
    }
    
    func login() {
        let loginRow = form.allRows[0] as! TextRow
        dataManager.login = loginRow.value ?? ""
        let passRow = form.allRows[1] as! PasswordRow
        dataManager.password = passRow.value ?? ""
        let switchRow = form.allRows[3] as! SwitchRow
        
        self.loadIndicator(show: true)
        dataManager.updateCdeJournal {
            if let group = self.dataManager.cdeJournal?.years.last?.group {
                if group != "" {
                    self.dataManager.group = group
                    self.dataManager.save()
                    self.dataManager.updateSchedule {
                        
                        if switchRow.value ?? false {
                            let tokenRef = Database.database().reference(withPath: "tokens")
                            tokenRef.updateChildValues([self.dataManager.login : [self.dataManager.password, self.dataManager.notificationToken]])
                        }
                        self.dismiss(animated: true, completion: nil)
                    }  
                } else {
                    self.loadIndicator(show: false)
                    self.alert(title: "Ошибка", message: "Не удалось найти группу")
                }
            } else {
                self.loadIndicator(show: false)
                self.alert(title: "Ошибка", message: "Проверьте данные")
            }
        }
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
