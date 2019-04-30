import Foundation
import Kitura
import LoggerAPI
import Configuration
import CloudEnvironment
import KituraContracts
import Health


public let projectPath = ConfigurationManager.BasePath.project.path
public let health = Health()

public class App {
    static let formatter = DateFormatter()
    
    let router = Router()
    let cloudEnv = CloudEnv()

    public init() throws {
        App.formatter.dateFormat = "H:m:ss.SSSS"
        
        // Run the metrics initializer
        initializeMetrics(router: router)
        
        Log.info("PATH = \(projectPath)")
    }

    func postInit() throws {
        // Endpoints
        initializeHealthRoutes(app: self)
        initializeTestRoutes(app: self)
        
        self.router.all("/", middleware: StaticFileServer(path: projectPath + "/static/app"))

    }

    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: cloudEnv.port, with: router)
        Kitura.run()
    }
}

func timeDifference(_ t1: DispatchTime) -> (DispatchTime, Double) {
    let t2 = DispatchTime.now()
    
    let d = Double(t2.uptimeNanoseconds - t1.uptimeNanoseconds) / 1_000_000_000
    
    return (t2, d)
}
