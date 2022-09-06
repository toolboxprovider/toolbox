//
//  AVPlayer+rx.swift
//
//  Created  on 9/10/17.
//  Copyright © 2017 All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

import AVFoundation

public extension Reactive where Base == AVPlayer {
    
    var timeObserver: Observable<CMTime> {
        
        return Observable.create { (subscriber) -> Disposable in
            
            let observer = self.base.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1,
                                                                                     timescale: 30),
                                                             queue: DispatchQueue.main) { (x) in
                subscriber.onNext(x)
            }
            
            return Disposables.create {
                self.base.removeTimeObserver(observer)
            }
            
        }
        
    }

    var playRate: Observable<Float> {
        return base.rx.observe(Float.self, "rate")
                    .startWith(base.rate)
                    .notNil()
    }
    
    var status: Observable<AVPlayer.Status> {
        
        return base.rx.observeWeakly(AVPlayer.Status.self, "status")
            .startWith(base.status)
            .notNil()
    }
    
    var reasonForWaitingToPlay: Observable<AVPlayer.WaitingReason?> {
        
        return base.rx.observe(AVPlayer.WaitingReason.self, "reasonForWaitingToPlay")
            .startWith(base.reasonForWaitingToPlay)
        
    }
    
    var timeControlStatus: Observable<AVPlayer.TimeControlStatus?> {
        
        return base.rx.observe(AVPlayer.TimeControlStatus.self, "timeControlStatus")
            .startWith(base.timeControlStatus)
        
    }
    
    var error: Observable<Error?> {
        return base.rx.observeWeakly(NSError.self, "error")
            .map { $0 as Error? }
    }
}

public extension AVPlayer {
    var rx: Reactive<AVPlayer> {
        return Reactive(self)
    }
}
