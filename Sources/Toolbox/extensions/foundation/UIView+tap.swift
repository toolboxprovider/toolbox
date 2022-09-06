//
//  File.swift
//  
//
//  Created by Vladislav Soroka on 19.11.2023.
//

import UIKit

public extension UIView {
    
    func registerTap(command: @escaping () -> Command?) {
        addGestureRecognizer(CommandTap(command: Command {
            command()?.perform()
        }))
    }
    
}

class CommandObject: NSObject {
    let command: Command
    
    init(command: Command) {
        self.command = command
    }
    
    @objc func perform() {
        command.perform()
    }
}

class CommandTap: UITapGestureRecognizer {
    
    let commandObject: CommandObject
    
    init(command: Command) {
        self.commandObject = .init(command: command)
        
        super.init(target: commandObject, action: #selector(CommandObject.perform as (CommandObject) -> () -> ()))
        
        cancelsTouchesInView = false
    }
    
}
