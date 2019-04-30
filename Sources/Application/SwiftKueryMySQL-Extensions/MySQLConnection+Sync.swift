//
//  MySQLConnection+Sync.swift
//  Application
//
//  Created by Javier Nigro on 29/04/2019.
//

import Foundation
import SwiftKuery
import SwiftKueryMySQL

extension MySQLConnection {
    
    func executeSync(raw: String, parameters: [Any?] = [Any]()) -> QueryResult {
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: QueryResult?
        
        self.execute(raw, parameters: parameters) { r in
            result = r
            semaphore.signal()
        }
        
        semaphore.wait()
        
        return result!
    }
}
