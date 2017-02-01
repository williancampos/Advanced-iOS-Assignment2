//
//  ViewController.swift
//  Assignment2
//
//  Created by Willian Campos on 2017-01-31.
//  Copyright © 2017 Camponale. All rights reserved.
//

import UIKit

class ListTaskViewController: UITableViewController {
    
    let data = [
        Task("Create UI", true, "Create UI for Assignment 2"),
        Task("Implement model", true, "Create classes for model"),
        Task("Add persistence", false, "Decide the storage strategy and implement it"),
        Task("Implement business logic", false, "Implement all the business logic"),
        Task("Test", false, "Testing. Lots of testing"),]
    
    
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
    }
}

