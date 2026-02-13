//
//  File.swift
//  
//
//  Created  on 09.09.2022.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

var appConfig: App.StaticConfig!

public enum App {

    public struct StaticConfig {
        public typealias CustomErrorPresentation = (Error) -> (title: String, message: String)?
        public typealias AuthRequestHeaders = (inout [String: String]) async -> Void
        public typealias CustomErrorMapper = (Error, Data) -> Error?
        
        public init(loaderImage: UIImage = UIImage(named: "spring_indicator")!,
                    loaderBackgroundAlpha: CGFloat = 0.5,
                    initialsStyle: InitialsStyle? = nil,
                    customError: @escaping CustomErrorPresentation = { _ in nil },
                    debugShakeCommands: [NamedCommand] = [],
                    reduxActionDispatched: CommandWith<String> = .nop,
                    network: Network?) {
            self.loaderImage = loaderImage
            self.loaderBackgroundAlpha = loaderBackgroundAlpha
            self.initialsStyle = initialsStyle ?? .init(font: .systemFont(ofSize: 14), color: .black)
            self.customError = customError
            self.debugShakeCommands = debugShakeCommands
            self.reduxActionDispatched = reduxActionDispatched
            self.network = network
        }
        
        let loaderImage: UIImage
        let loaderBackgroundAlpha: CGFloat
        let initialsStyle: InitialsStyle
        let customError: CustomErrorPresentation
        let debugShakeCommands: [NamedCommand]
        
        ///can be used for crashlytics logging
        let reduxActionDispatched: CommandWith<String>
        
        let network: Network?
        
        public struct InitialsStyle {
            public init(font: UIFont, color: UIColor) {
                self.font = font
                self.color = color
            }

            let font: UIFont
            let color: UIColor
        }
        
        public struct Network {
            public init(
                baseNetworkURL: URLConvertible,
                networkEncoder: JSONEncoder = .init(),
                networkDecoder: JSONDecoder = .init(),
                session: Alamofire.Session = AF,
                cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
                authRequestHeaders: AuthRequestHeaders? = nil,
                customErrorMapper: CustomErrorMapper? = nil) {
                    self.baseNetworkURL = baseNetworkURL
                    self.networkEncoder = networkEncoder
                    self.networkDecoder = networkDecoder
                    self.session = session
                    self.cachePolicy = cachePolicy
                    self.customErrorMapper = customErrorMapper
                    self.authRequestHeaders = authRequestHeaders
                }
            
            let baseNetworkURL: URLConvertible
            let networkEncoder: JSONEncoder
            let networkDecoder: JSONDecoder
            let cachePolicy: URLRequest.CachePolicy
            let customErrorMapper: CustomErrorMapper?
            let authRequestHeaders: AuthRequestHeaders?
            let session: Alamofire.Session
        }
        
    }
    
    public class Store<T: AppStateT> {
        
        public init(appStateSettingsKey: String,
                    customSaveTrigger: (Observable<T>) -> Observable<Void> = { m in
            if RunScheme.debug {
                ///debugger termination might not trigger any of AppState saving notifications.
                return m.asObservable().map { _ in }
            } else {
                return .never()
            }
        }) {
            #if os(tvOS)
            diskStore = DiskSetting(key: appStateSettingsKey,
                                    initialValue: .default)
            #else
            diskStore = Setting(key: appStateSettingsKey,
                                initialValue: .default)
            #endif
            memmoryStore = .init(value: diskStore.value)
            
            let df = DateFormatter()
            df.dateFormat = "HH:mm:ss dd-MM ZZZZ"
            df.timeZone = .current
            initialStateDescription = "\(df.string(from: Date()))\n\(diskStore.value)"
            
            let _ =
            Observable.merge([
                NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification),
                NotificationCenter.default.rx.notification(UIApplication.willTerminateNotification),
                NotificationCenter.default.rx.notification(UIApplication.didReceiveMemoryWarningNotification),
                customSaveTrigger(memmoryStore.asObservable())
                    .map { _ in .init(name: UIApplication.willTerminateNotification) }
            ])
                .subscribe(onNext: { (_) in
                    self.diskStore.value = self.memmoryStore.value
                })
            
        }
        
#if os(tvOS) ///tvOS is very limitted with storing data in UserDefaults
        var diskStore: DiskSetting<T>
#else
        var diskStore: Setting<T>
#endif
        let memmoryStore: BehaviorRelay<T>
        
        let initialStateDescription: String
        var actions: [(String, Date, String?)] = []

        private let queue = DispatchQueue(label: "AppState mutation queue")
        
        public func dispatch<A: ReduxAction>
        (action: A, actor: CustomStringConvertible? = nil) where A.T == T {
            
            queue.async { [unowned self] in
                
                var dscr = "\(action)"
                if let x = actor?.description {
                    dscr.append(" by \(x) actor")
                }
                appConfig.reduxActionDispatched(with: dscr)
                actions.append((dscr, Date(), actor?.description))
                
                var newState = memmoryStore.value
                action.apply(to: &newState)
                
                memmoryStore.accept(newState)
                
            }
            
        }
        
        public func testableDispatch<A: ReduxAction>
        (action: A, actor: CustomStringConvertible? = nil) where A.T == T {
            
            queue.sync { [unowned self] in
                
                var dscr = "\(action)"
                if let x = actor?.description {
                    dscr.append(" by \(x) actor")
                }
                appConfig.reduxActionDispatched(with: dscr)
                actions.append((dscr, Date(), actor?.description))
                
                var newState = memmoryStore.value
                action.apply(to: &newState)
                
                memmoryStore.accept(newState)
                
            }
            
        }
        
        public func dispatchCommand<A: ReduxAction>
        (action: A, actor: CustomStringConvertible? = nil) -> Command where A.T == T  {
            return Command {
                self.dispatch(action: action, actor: actor)
            }
        }
        
        public func dispatchCommand<A: ReduxAction>
        (actor: CustomStringConvertible? = nil) -> CommandWith<A> where A.T == T  {
            return CommandWith { action in
                self.dispatch(action: action, actor: actor)
            }
        }

    }
    
    
}

extension App.Store {
    
    public var slice: T {
        return memmoryStore.value
    }

    public var changes: Driver<T> {
        return memmoryStore.asDriver()
    }
    
    public func logStateMutations() -> String {
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "HH:mm:ss dd-MM"
        var str = "InitialState: \(initialStateDescription)\n\n"
        queue.sync {
            
            for (index, (action, date, actor)) in actions.enumerated() {

                let dateStr = dateFormatterGet.string(from: date)

                str.append("\nMutation #\(index+1) at \(dateStr)\nAction: \(action)\n")
                if let x = actor {
                    str.append("By \(x)\n")
                }

            }

        }
        
        return str
    }
}

public extension App {
    static func setup<T: AppStateT>(
        _ s: App.StaticConfig,
        _ d: App.Store<T>)
    -> App.Store<T> {
        appConfig = s
        
#if os(iOS)
        UIApplication.shared.applicationSupportsShakeToEdit = s.debugShakeCommands.count > 0
#endif
        if RunScheme.debug && s.network != nil {
            NetworkLoggerBridge.enableNetworkingLogging()
        }
        
        return d
    }
}
