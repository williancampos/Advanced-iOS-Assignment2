//
//  ViewController.swift
//  Assignment2
//
//  Created by Willian Campos (300879280) on 2017-01-31.
//  Copyright © 2017 Camponale. All rights reserved.
//
//  This is the controller for the main screen. 
//  It is responsible for database persistence handling as well.
//  Done / undone handling is implemented using swipe left on table row.

import UIKit



class ListTaskViewController: UITableViewController, DetailViewControllerDelegate {
    
    var data: Array<Task> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Connect to database
        var database:OpaquePointer? = nil
        var result = sqlite3_open(dataFilePath(), &database)
        if result != SQLITE_OK {
            sqlite3_close(database)
            print("Failed to open database")
            return
        }
        
        //Create tasks table in case it does not exist
        let createSQL = "CREATE TABLE IF NOT EXISTS TASKS " +
        "(ROW INTEGER PRIMARY KEY, NAME TEXT, DESCRIPTION TEXT, DONE INTEGER);"
        var errMsg:UnsafeMutablePointer<Int8>? = nil
        result = sqlite3_exec(database, createSQL, nil, nil, &errMsg)
        if (result != SQLITE_OK) {
            sqlite3_close(database)
            print("Failed to create table")
            return
        }
        
        //Populate task table with database tasks
        let query = "SELECT ROW, NAME, DESCRIPTION, DONE FROM TASKS ORDER BY ROW"
        var statement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, query, -1, &statement, nil) == SQLITE_OK {
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
    
    //Invoked when app "lose focus"
    func applicationWillResignActive(notification:NSNotification) {
        var database:OpaquePointer? = nil
        let result = sqlite3_open(dataFilePath(), &database)
        if result != SQLITE_OK {
            sqlite3_close(database)
            print("Failed to open database")
            return
        }
        
        
        //Clear database task data
        let delete = "delete from TASKS;"
        var deleteStatement:OpaquePointer? = nil
        if sqlite3_prepare_v2(database, delete, -1, &deleteStatement, nil) == SQLITE_OK {
        }
        if sqlite3_step(deleteStatement) != SQLITE_DONE {
            print("Error delete data")
            NSLog("Database Error Message : %s", sqlite3_errmsg(database))
            return
        }
        sqlite3_finalize(deleteStatement)
        
        
        //Persist all the tasks in current state
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
        
        //Close connection with database
        sqlite3_close(database)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    // Populate task data into table cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        let task = data[indexPath.row]
        cell.nameLabel.text = task.name
        cell.nameLabel.isEnabled = !task.done
        return cell
    }
    
    
    // This method is responsible for adding an action for mark task as done/undone once detected a swipe left gesture on row.
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
    
    
    //Invoked before changing to any other screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Set delegate and task before opening detail screen
        let destination = segue.destination as! DetailViewController
        destination.task = data[tableView.indexPathForSelectedRow!.row]
        destination.delegate = self
    }
    
    //Action on new task button pressed: create new task with default name and without description
    @IBAction func addTaskPressed(_ sender: UIBarButtonItem) {
        let task = Task(data.count, "New task", false, "")
        data.append(task)
        tableView.reloadData()
    }
    
    //Refresh table row for task changed
    func taskChanged(task: Task) {
        tableView.reloadRows(at: [tableView.indexPathForSelectedRow!], with: UITableViewRowAnimation.fade)
    }
    
    
    //Remove from table deleted task
    func taskDeleted(task: Task) {
        let index = data.index(of: task)
        data.remove(at: index!)
        tableView.reloadData()
    }
    
}

