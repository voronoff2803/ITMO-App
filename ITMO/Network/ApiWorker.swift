//
//  ApiWorker.swift
//  ITMO
//
//  Created by Alexey Voronov on 12/05/2019.
//  Copyright © 2019 Alexey Voronov. All rights reserved.
//

import Foundation
import Firebase

class ApiWorker {
    static var shared = ApiWorker()
    private init() {}
    
    private let baseURL = "https://mountain.ifmo.ru/api.ifmo.ru/public/v1/"
    private let scheduleEndpoint = "schedule_lesson_group/"
    private let personScheduleEndpoint = "schedule_lesson_person/"
    private let personEndpoint = "schedule_person?lastname="
    
    var cdeURL = ""
    private let cdeLoginURL = "https://de.ifmo.ru/servlet/"
    private let cdeMarksURL = "https://de.ifmo.ru/api/private/eregister"
    
    private let manager = DataFlowManager.shared
    
    var cdeDate = ""
    var cdeStart = ""
    var cdeEnd = ""
    
    
    func showRents(onSuccess: @escaping(NSDictionary?) -> Void, onFailure: @escaping(String) -> Void) {
        let url = cdeURL + "/itmo_app/cde/show_rents?login=\(manager.login.encodeUrl)&password=\(manager.password.encodeUrl)"
        ServerApiRequest(url: url, onSuccess: { (result) in
            onSuccess(result)
        }) { (error) in
            onFailure(error)
        }
    }
    
    func showDates(onSuccess: @escaping(NSDictionary?) -> Void, onFailure: @escaping(String) -> Void) {
        let url = cdeURL + "/itmo_app/cde/new_rent/show_dates?login=\(manager.login.encodeUrl)&password=\(manager.password.encodeUrl)"
        ServerApiRequest(url: url, onSuccess: { (result) in
            onSuccess(result)
        }) { (error) in
            onFailure(error)
        }
    }
    
    func showStart(onSuccess: @escaping(NSDictionary?) -> Void, onFailure: @escaping(String) -> Void) {
        let url = cdeURL + "/itmo_app/cde/new_rent/show_begin_times?login=\(manager.login.encodeUrl)&password=\(manager.password.encodeUrl)&date=\(cdeDate)"
        ServerApiRequest(url: url, onSuccess: { (result) in
            onSuccess(result)
        }) { (error) in
            onFailure(error)
        }
    }
    
    func showEnd(onSuccess: @escaping(NSDictionary?) -> Void, onFailure: @escaping(String) -> Void) {
        let url = cdeURL + "/itmo_app/cde/new_rent/show_end_times?login=\(manager.login.encodeUrl)&password=\(manager.password.encodeUrl)&date=\(cdeDate)&begin_time=\(cdeStart)"
        ServerApiRequest(url: url, onSuccess: { (result) in
            onSuccess(result)
        }) { (error) in
            onFailure(error)
        }
    }
    
    func confirm(onSuccess: @escaping(NSDictionary?) -> Void, onFailure: @escaping(String) -> Void) {
        let url = cdeURL + "/itmo_app/cde/new_rent/confirm?login=\(manager.login.encodeUrl)&password=\(manager.password.encodeUrl)&date=\(cdeDate)&begin_time=\(cdeStart)&end_time=\(cdeEnd)"
        ServerApiRequest(url: url, onSuccess: { (result) in
            onSuccess(result)
        }) { (error) in
            onFailure(error)
        }
    }
    
    func deleteRent(deleteId: String, onSuccess: @escaping(NSDictionary?) -> Void, onFailure: @escaping(String) -> Void) {
        let url = cdeURL + "/itmo_app/cde/delete_rent?login=\(manager.login.encodeUrl)&password=\(manager.password.encodeUrl)&delete_id=\(deleteId)"
        ServerApiRequest(url: url, onSuccess: { (result) in
            onSuccess(result)
        }) { (error) in
            onFailure(error)
        }
    }
    
    func ServerApiRequest(url: String, onSuccess: @escaping(NSDictionary?) -> Void, onFailure: @escaping(String) -> Void) {
        apiRequest(url: url, onSuccess: { (result) in
            if let error = result?["reason"] as? String {
                onFailure(error)
            } else if let dictResult = result?["result"] as? NSDictionary  {
                onSuccess(dictResult)
            } else {
                onSuccess(result)
            }
        }) { (error) in
            onFailure(error.localizedDescription)
        }
    }
    
    private func apiRequest(url: String, onSuccess: @escaping(NSDictionary?) -> Void, onFailure: @escaping(Error) -> Void) {
        let urlString : String = url
        print(urlString)
        if let url = URL(string: urlString) {
            let request: NSMutableURLRequest = NSMutableURLRequest(url: url)
            request.httpMethod = "GET"
            let session = URLSession.shared
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error -> Void in
                if(error != nil){
                    onFailure(error!)
                } else{
                    do {
                        if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                            onSuccess(jsonResult)
                        }
                    } catch let parseError as NSError {
                        print(parseError)
                        onSuccess(nil)
                    }
                }
            })
            task.resume()
        } else {
            onFailure(NSError())
        }
    }
    
    func getJournal(login: String, pass: String, onSuccess: @escaping(NSDictionary) -> Void, onFailure: @escaping(Error) -> Void) {
        let urlString : String = self.cdeLoginURL + "?LOGIN=\(login.encodeUrl)&PASSWD=\(pass.encodeUrl)&Rule=Logon"
        // Every time when request cde marks, logining is necessary
        self.apiRequest(url: urlString, onSuccess: { _ in
            self.apiRequest(url: self.cdeMarksURL, onSuccess: { (dict) in
                if dict != nil {
                    onSuccess(dict!)
                } else {
                    onFailure(NSError())
                }
            }, onFailure: {(error) in
                onFailure(error)
            })
        }) { (error) in
            onFailure(error)
        }
    }
    
    func getSchedule(group: String, onSuccess: @escaping(NSDictionary) -> Void, onFailure: @escaping(Error) -> Void) {
        let urlString : String = self.baseURL + self.scheduleEndpoint + group.encodeUrl
        self.apiRequest(url: urlString, onSuccess: { (dict) in
            if dict != nil {
                onSuccess(dict!)
            } else {
                onFailure(NSError(domain: NSCocoaErrorDomain, code: 22, userInfo: [NSLocalizedDescriptionKey :  NSLocalizedString("Ошибка", value: "Проверьте номер группы", comment: "")]))
            }
        }) { (error) in
            onFailure(error)
        }
    }
    
    func getSchedule(pid: String, onSuccess: @escaping(NSDictionary) -> Void, onFailure: @escaping(Error) -> Void) {
        let urlString : String = self.baseURL + self.personScheduleEndpoint + pid
        self.apiRequest(url: urlString, onSuccess: { (dict) in
            if dict != nil {
                onSuccess(dict!)
            } else {
                onFailure(NSError(domain: NSCocoaErrorDomain, code: 22, userInfo: [NSLocalizedDescriptionKey :  NSLocalizedString("Ошибка", value: "Не могу получить данные", comment: "")]))
            }
        }) { (error) in
            onFailure(error)
        }
    }
    
    func getPersons(lastname: String, onSuccess: @escaping(NSDictionary) -> Void, onFailure: @escaping(Error) -> Void) {
        let urlString : String = self.baseURL + self.personEndpoint + lastname.encodeUrl
        self.apiRequest(url: urlString, onSuccess: { (dict) in
            if dict != nil {
                onSuccess(dict!)
            } else {
                onFailure(NSError(domain: NSCocoaErrorDomain, code: 22, userInfo: [NSLocalizedDescriptionKey :  NSLocalizedString("Ошибка", value: "Не могу получить данные", comment: "")]))
            }
        }) { (error) in
            onFailure(error)
        }
    }
}
