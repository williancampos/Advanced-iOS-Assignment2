//
//  ViewController.swift
//  Assignment2
//
//  Created by Willian Campos on 2017-01-31.
//  Copyright © 2017 Camponale. All rights reserved.
//

import UIKit



class ListTaskViewController: UITableViewController, DetailViewControllerDelegate {
    
    var data: Array<Task> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var database:OpaquePointer? = nil
        var result = sqlite3_open(dataFilePath(), &database)
        if result != SQLITE_OK {
            sqlite3_close(database)
            print("Failed to open database")
            return
        }
        let createSQL = "CREATE TABLE IF NOT EXISTS TASKS " +
        "(ROW INTEGER PRIMARY KEY, NAME TEXT, DESCRIPTION TEXT, DONE INTEGER);"
        var errMsg:UnsafeMutablePointer<Int8>? = nil
        result = sqlite3_exec(database, createSQL, nil, nil, &errMsg)
        if (result != SQLITE_OK) {
            sqlite3_close(database)
            print("Failed to create table")
            return
        }
        
        let query = "SELECT ROW, NAME, DESCRIPTION, DONE FROM TASKS ORDER BY ROW"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
            print("Select run successfully")
            while sqlite3_step(statement) == SQLITE_ROW {
                let row = Int(sqlite3_column_int(statement, 0))
                let name = String.init(cString: sqlite3_column_text(statement, 1)!)
                let description = String.init(cString: sqlite3_column_text(statement, 2)!)
                let doneInt: Int = Int(sqlite3_column_int(statement, 3))
                let done = Bool.init(NSNumber.init(integerLiteral: doneInt))
                data.append(Task(row, name, done, description))
            }
            sqlite3_finalize(statement)
        }
        sqlite3_close(database)
        
        let app = UIApplication.shared
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillResignActive(notification:)), name: Notification.Name.UIApplicationWillResignActive, object: app)
        
        
    }
    
    func dataFilePath() -> String {
        let urls = FileManager.default.urls(for:
            .documentDirectory, in: .userDomainMask)
        var url:String?
        url = urls.first?.appendingPathComponent("data.plist").path
        return url!
    }
    
    func applicationWillResignActive(notification:NSNotification) {
        var database:OpaquePointer? = nil
        let result = sqlite3_open(dataFilePath(), &database)
        if result != SQLITE_OK {
            sqlite3_close(database)
            print("Failed to open database")
            return
        }
        for i in 0..<data.count  {
            let task = data[i]
            let update = "INSERT OR REPLACE INTO TASKS (ROW, NAME, DESCRIPTION, DONE) " +
            "VALUES (?, ?, ?, ?);"
            var statement:OpaquePointer? = nil
            if sqlite3_prepare_v2(database, update, -1, &statement, nil) == SQLITE_OK {
                let name = task.name
                let description = task.description
                let doneInt = task.done ? 1 : 0
                sqlite3_bind_int(statement, 1, Int32(i))
                sqlite3_bind_text(statement, 2, (name as NSString).utf8String, -1, nil)
                sqlite3_bind_text(statement, 3, (description as NSString).utf8String, -1, nil)
                sqlite3_bind_int(statement, 4, Int32(doneInt))
            }
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error updating table")
                NSLog("Database Error Message : %s", sqlite3_errmsg(database))
                sqlite3_close(database)
                return
            }
            
            sqlite3_finalize(statement)
        }
        sqlite3_close(database)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        let task = data[indexPath.row]
        cell.nameLabel.text = task.name
        cell.nameLabel.isEnabled = !task.done
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let task = data[indexPath.row]
        let actionStr = task.done ? "Undone" : "Done"
        let switchStatus = UITableViewRowAction(style: .destructive, title: actionStr) { action, index in
            task.done = !task.done
            tableView.reloadData()
        }
        
        switchStatus.backgroundColor = UIColor.lightGray
        
        return [switchStatus]
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! DetailViewController
        destination.task = data[tableView.indexPathForSelectedRow!.row]
        destination.delegate = self
    }
    
    @IBAction func addTaskPressed(_ sender: UIBarButtonItem) {
        let task = Task(data.count, "New task", false, "")
        data.append(task)
        tableView.reloadData()
    }
    
    func taskChanged(task: Task) {
        let index = data.index(of: task)
        tableView.reloadRows(at: [tableView.indexPathForSelectedRow!], with: UITableViewRowAnimation.fade)
    }
    
}

