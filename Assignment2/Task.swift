//
//  Task.swift
//  Assignment2
//
//  Created by Willian Campos on 2017-01-31.
//  Copyright © 2017 Camponale. All rights reserved.
//

class Task {
    
    var name: String
    var done: Bool
    var description: String
    
    init(_ name: String, _ done: Bool, _ description: String) {
        self.name = name
        self.done = done
        self.description = description
    }
}
