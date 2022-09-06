//
//  RecursiveLoading.swift
//   
//
//  Created by Vlad Soroka on 05.01.2021.
//  Copyright © 2021  . All rights reserved.
//

import RxSwift

public func recursivelyLoad<DataType, T>(_ loadedSoFar: [DataType],
                               nextPageTrigger: Observable<T>,
                               dataProvider: @escaping ([DataType]) -> Single<[DataType]>) -> Observable<[DataType]> {

    return dataProvider(loadedSoFar)
        .asObservable()
        .flatMap { newBatch -> Observable<[DataType]> in
            
            if newBatch.isEmpty { 
                return loadedSoFar.isEmpty ? .just([]) : .empty()
            }
            
            let running = loadedSoFar + newBatch
            
            return Observable.concat([
                .just(running),
                Observable.never().take(until: nextPageTrigger),
                .deferred {
                    recursivelyLoad(running,
                                    nextPageTrigger: nextPageTrigger,
                                    dataProvider: dataProvider)
                }
            ])
        }
        
}

public extension PrimitiveSequence{
  func retry(maxAttempts: Int, delay: RxTimeInterval) -> PrimitiveSequence<Trait, Element> {
    return self.retry { errors in
      return errors.enumerated().flatMap{ (index, error) -> Observable<Int64> in
        if index < maxAttempts {
            return Observable<Int64>.timer( delay, scheduler: MainScheduler.instance)
        } else {
          return Observable.error(error)
        }
      }
    }
  }
}
