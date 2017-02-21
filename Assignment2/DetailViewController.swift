//
//  DetailViewController.swift
//  Assignment2
//
//  Created by Willian Campos on 2017-01-31.
//  Copyright © 2017 Camponale. All rights reserved.
//

import UIKit

protocol DetailViewControllerDelegate {
    
    func taskChanged(task: Task);
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
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        task.name = nameTextField.text!
        task.description = descriptionTextView.text!
        delegate.taskChanged(task: task)
        navigationController!.popViewController(animated: true)
    }
}
