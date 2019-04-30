//
//  QueryResult+Sync.swift
//  Application
//
//  Created by Javier Nigro on 29/04/2019.
//

import Foundation
import SwiftKuery
import SwiftKueryMySQL

extension QueryResult {
    func asRowsSync() -> ([[String: Any?]]?, Error?) {
        let semaphore = DispatchSemaphore(value: 0)
        
        var rows: [[String: Any?]]?
        var error: Error?
        
        self.asRows { r, e in
            rows = r
            error = e
            semaphore.signal()
        }
        
        semaphore.wait()
        
        return (rows, error)
    }
}
