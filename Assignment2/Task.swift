//
//  Task.swift
//  Assignment2
//
//  Created by Willian Campos (300879280) on 2017-01-31.
//  Copyright © 2017 Camponale. All rights reserved.
//
//  This is the model class for tasks. It represents one task and its properties.

class Task: Equatable {
    
    var row: Int
    var name: String
    var done: Bool
    var description: String
    
    init(_ row: Int, _ name: String, _ done: Bool, _ description: String) {
        self.row = row
        self.name = name
        self.done = done
        self.description = description
    }
    
    static func == (lhs: Task, rhs: Task) -> Bool {
        return
            lhs.row == rhs.row &&
            lhs.name == rhs.name &&
                lhs.done == rhs.done &&
                lhs.description == rhs.description
    }
}
