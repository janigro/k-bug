//
//  TestRoutes.swift
//  Application
//
//  Created by Javier Nigro on 27/04/2019.
//

import Foundation
import Kitura
import LoggerAPI
import SwiftKueryMySQL
import SwiftKuery

let host = "REPLACE_WITH_HOST_NAME"
let user = "REPLACE_WITH_USERNAME"
let pass = "REPLACE_WITH_PASSWORD"
let schema = "REPLACE_WITH_DATABASE_NAME"
let port = 3306
let queryDelay = 0.3

extension String: Error {}

func initializeTestRoutes(app: App) {
    
    app.router.get("/without_semaphores/:n") { request, response, next in
        // Start counting time
        let start = Date()
        let t = DispatchTime.now()

        let n: String = request.parameters["n"] ?? ""

        // Get MySQLConnection with connection details from global variables at the top of the file
        let connection = MySQLConnection(host: host, user: user, password: pass, database: schema, port: port, reconnect: true)
        
        // Connect to database
        connection.connect() { result in
            if let error = result.asError {
                response.status(.forbidden).send("")
                next()
                Log.info("W_SEM connect() ERROR \(error)")
                return
            }
            
            // Run query that will take as much time as defined in global variable queryDelay
            // No tables are needed for the query to work, only a connectable database.
            connection.execute("SELECT SLEEP(?)", parameters: [queryDelay], onCompletion: { result in
                if let error = result.asError {
                    response.status(.forbidden).send("")
                    next()
                    Log.info("W_SEM execute() ERROR \(error)")
                    return
                }
                
                // Fetch all results
                let _ = result.asRows { rows, error in
                    
                    guard rows != nil else {
                        let error = error ?? ""
                        response.status(.forbidden).send("")
                        next()
                        Log.info("W_SEM asRows() ERROR \(error)")
                        return
                    }
                    
                    // Calculate execution time
                    let (_, td) = timeDifference(t)
                    let end = Date()

                    // Return execution time to the server
                    let json = """
                    { "n": \(n),
                    "query_time": "\(queryDelay)",
                    "exec_time": "\(td - queryDelay)",
                    "total_time": "\(td)",
                    "begin": "\(App.formatter.string(from: start))",
                    "end": "\(App.formatter.string(from: end))",
                    "semaphores": "No"
                    }
                    """
                    
                    response.send(json)
                    next()
                    
                    Log.info("Request \(request.originalURL) took \(td) seconds to execute")

                }
                
                
            })
        }
    }
    
    app.router.get("/with_semaphores/:n") { request, response, next in
        // Start counting time
        let start = Date()
        let t = DispatchTime.now()

        let n: String = request.parameters["n"] ?? ""
        

        // Get MySQLConnection with connection details from global variables at the top of the file
        let connection = MySQLConnection(host: host, user: user, password: pass, database: schema, port: port, reconnect: true)

        // Connect to database
        let connectResult = connection.connectSync()
        
        guard connection.isConnected else {
            response.status(.forbidden).send("")
            next()
            
            let error = connectResult.asError ?? ""
            Log.info("W_SEM asRows() connectSync() \(error)")
            return
        }
        
        // Run query that will take as much time as defined in global variable queryDelay
        // No tables are needed for the query to work, only a connectable database.
        let result = connection.executeSync(raw: "SELECT SLEEP(?)", parameters: [queryDelay])
        
        if let error = result.asError {
            response.status(.forbidden).send("")
            next()
            Log.info("W_SEM asRows() executeSync() \(error)")
            return
        }
        
        // Fetch all results
        let (rows, error) = result.asRowsSync()
        
        guard rows != nil else {
            response.status(.forbidden).send("")
            next()
            
            let error = error ?? ""
            Log.info("W_SEM asRows() asRowsSync() \(error)")
            return
        }
        
        // Calculate execution time
        let (_, td) = timeDifference(t)
        let end = Date()
        
        // Return execution time to the server
        let json = """
        { "n": \(n),
        "query_time": "\(queryDelay)",
        "exec_time": "\(td - queryDelay)",
        "total_time": "\(td)",
        "begin": "\(App.formatter.string(from: start))",
        "end": "\(App.formatter.string(from: end))",
        "semaphores": "Yes"
        }
        """

        response.send(json)
        next()
        
        // Log time spent executing the request
        Log.info("Request \(request.originalURL) took \(td) seconds to execute")
    }
}

