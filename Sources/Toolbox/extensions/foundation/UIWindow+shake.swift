//
//  File.swift
//  
//
//  Created  on 09.09.2022.
//

import UIKit

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            
            if RunScheme.appstore && appConfig.debugShakeCommands.count > 0 {
                return;
            }
            
            var actions: [UIAlertAction] = appConfig.debugShakeCommands.map { x in
                return .init(title: x.name,
                             style: .default)  { _ in x.perform() }
            }
            
            actions.append(.init(title: "Cancel", style: .cancel, handler: nil))
            
            self.rootViewController?.showDialog(title: "Debug Actions",
                                                text: "Pick one",
                                                style: .alert,
                                                actions: actions)
                        
        }
    }
}
