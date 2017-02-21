//
//  DetailViewController.swift
//  Assignment2
//
//  Created by Willian Campos (300879280) on 2017-01-31.
//  Copyright © 2017 Camponale. All rights reserved.
//
//  This is the controller for the edit screen.
//  It is responsible for managing changes in the task and notifying its delegate of them.
//

import UIKit

protocol DetailViewControllerDelegate {
    
    func taskChanged(task: Task);
    func taskDeleted(task: Task)
}

class DetailViewController: UIViewController {
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    var delegate: DetailViewControllerDelegate!
    var task: Task!
    
    override func viewDidLoad() {
        nameTextField.text = task.name
        descriptionTextView.text = task.description
    }
    
    //Action to do when save is pressed: update task with screen values and go back do main screen
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        task.name = nameTextField.text!
        task.description = descriptionTextView.text!
        delegate.taskChanged(task: task)
        navigationController!.popViewController(animated: true)
    }
    
    @IBAction func deletePressed(_ sender: UIBarButtonItem) {
        delegate.taskDeleted(task: task)
        navigationController!.popViewController(animated: true)
    }
}
