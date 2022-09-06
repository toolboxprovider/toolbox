//
//  ViewController+ErrorMessage.swift
//   
//
//  Created  on 2/26/16.
//  Copyright © 2016   All rights reserved.
//

import UIKit
import RxSwift

public typealias MessageCallback = () -> Void

public extension UIViewController {
    
    func showMessage(title: String,
                     text: String,
                     style: UIAlertController.Style = .alert,
                     buttonText: String = "Ok",
                     callback: MessageCallback? = nil) {
        let alertController = UIAlertController(title: title, message: text, preferredStyle: style)
        
        alertController.addAction(UIAlertAction(title: buttonText, style: .default) { _ in
            callback?()
        })
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showDialog(title: String,
                    text: String,
                    style: UIAlertController.Style = .alert,
                    negativeText: String = "No",
                    negativeStyle: UIAlertAction.Style = .cancel,
                    negativeCallback: MessageCallback? = nil,
                    positiveText: String = "Yes",
                    positiveCallback: MessageCallback? = nil) {
        let alertController = UIAlertController(title: title, message: text, preferredStyle: style)
        
        alertController.addAction(UIAlertAction(title: negativeText, style: negativeStyle) { _ in
            negativeCallback?()
        })
        
        alertController.addAction(UIAlertAction(title: positiveText, style: .default) { _ in
            positiveCallback?()
        })
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showDialog(title: String,
                    text: String,
                    style: UIAlertController.Style = .alert,
                    actions: [UIAlertAction]) {
        let alertController = UIAlertController(title: title,
                                                message: text,
                                                preferredStyle: style)
        
        actions.forEach { alertController.addAction($0) }
        
        alertController.popoverPresentationController?.sourceView = view
        
        present(alertController, animated: true, completion: nil)
    }
 
    func showTextQuestionDialog(title: String,
                                text: String,
                                style: UIAlertController.Style = .alert,
                                callback: @escaping (String) -> Void) {
        let alertController = UIAlertController(title: title,
                                                message: text,
                                                preferredStyle: style)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            
        })
        
        alertController.addTextField(configurationHandler: { (_) in
            
        })
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default) { _ in
            callback( alertController.textFields?.first?.text ?? "" )
        })
        
        alertController.popoverPresentationController?.sourceView = view
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func showTextQuestion(with title: String,
                          question: String,
                          actionName: String,
                          placeholder: String? = nil,
                          callback: ( (String) -> () )? = nil)
    {
        let alertController = UIAlertController(title: title,
                                                message: question,
                                                preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = placeholder
        }
        
        alertController.addAction(UIAlertAction(title: actionName, style: .default) { _ in
            let text = alertController.textFields!.first!.text ?? ""
            callback?(text)
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            
        })
        
        alertController.popoverPresentationController?.sourceView = self.view
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func showSimpleQuestionMessage(withTitle title:String,
                                   _ question: String,
                                   negativeText: String = "No",
                                   positiveText: String = "Yes",
                                   positiveCallback: MessageCallback? = nil,
                                   negativeCallback: MessageCallback? = nil)
    {
        let alertController = UIAlertController(title: title, message: question, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: negativeText, style: .cancel) { _ in
            if let callback = negativeCallback {
                callback()
            }
        })
        
        alertController.addAction(UIAlertAction(title: positiveText, style: .default) { _ in
            if let callback = positiveCallback {
                callback()
            }
        })
        
        self.present(alertController, animated: true, completion: nil)

    }
    
    func showOptions(with title: String?,
                        options: [String],
                        style: UIAlertController.Style = .alert,
                        optionStyle: UIAlertAction.Style = .default,
                        positiveCallback: ( (Int) -> () )? = nil,
                        negativeCallback: MessageCallback? = nil)
    {
        let vc = UIViewController.options(with: title, options: options, style: style, optionStyle: optionStyle, positiveCallback: positiveCallback, negativeCallback: negativeCallback)
        
        vc.popoverPresentationController?.sourceView = self.view
        
        self.present(vc, animated: true, completion: nil)
        
    }
    
}

public extension UIViewController {
    
    static func options(with title: String?,
                        options: [String],
                        style: UIAlertController.Style = .alert,
                        optionStyle: UIAlertAction.Style = .default,
                        positiveCallback: ( (Int) -> () )? = nil,
                        negativeCallback: MessageCallback? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title,
                                                message: nil,
                                                preferredStyle: style)
        
        options.enumerated().forEach { (offset: Int, element: String) in
            
            alertController.addAction(UIAlertAction(title: element, style: optionStyle) { _ in
                positiveCallback?(offset)
            })
            
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            negativeCallback?()
        })
        
        return alertController
        
    }
    
}

extension UIViewController {
    
    fileprivate func onLoadedView<T>(observable: Observable<T>) -> Observable<T> {
        
        if self.isViewLoaded {
            return observable.subscribe(on: MainScheduler.instance)
        }
        else {
            return rx.sentMessage(#selector(UIViewController.viewDidLoad))
                .flatMapLatest { _ in observable }
                .subscribe(on: MainScheduler.instance)
        }

    }
    
    public func presentMessage(title: String, description: String, callback: MessageCallback? = nil) {
        let _ = onLoadedView(observable: Observable.just(0))
            .subscribe(onNext: { [unowned self] _ in
                self.showMessage(title: title,
                                 text: description, callback: callback)
            })
        
    }
    
    public func presentMessage(title: String, description: String) -> Observable<Void> {
        let x: Observable<Void> = Observable.create({ [unowned self] (subscriber) -> Disposable in
            
             self.showMessage(title: title, text: description, callback: {
                subscriber.onNext(())
                subscriber.onCompleted()
             })
            
            return Disposables.create()
        })
        
        return onLoadedView(observable: x)
        
    }
    
    public func presentConfirmQuestion(title: String, description: String,
                                negativeText: String = "No",
                                positiveText: String = "Yes") -> Observable<Bool> {
        
        let x: Observable<Bool> = Observable.create({ [unowned self] (subscriber) -> Disposable in
            
            self.showSimpleQuestionMessage(withTitle: title,
                                           description,
                                           negativeText: negativeText,
                                           positiveText: positiveText, positiveCallback: {
                subscriber.onNext(true)
                subscriber.onCompleted()
                
            },
                                           negativeCallback: {
                                            subscriber.onNext(false)
                                            subscriber.onCompleted()
                                            
            })
            
            return Disposables.create()
        })
        
        return onLoadedView(observable: x)
    }
    
    public func present(error: Error, callback: Command = .nop) {
        
        if case .canceled? = error as? AppError {
            return
        }
        
        if case .generic(let description)? = error as? AppError {
            return presentMessage(title: "Error", description: description, callback: callback.perform)
        }
        
        if let (title, message) = appConfig.customError(error) {
            return showMessage(title: title, text: message, callback: callback.perform)
        }
        
        presentMessage(title: "Error", description: error.localizedDescription, callback: callback.perform)
    }
    
}
