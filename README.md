# Description

This project demonstrates performance problems, when using the SwiftKueryMySQL library with multiple simultaneous requests. These problems only show when running on Linux. Mac seems mostly unaffected.

# Setup
In order to work, the application needs to be able to connect to any MySQL database, but no tables are needed. The requests simulates a 300 ms query using SELECT SLEEP(0.3). Query time can be tuned by changing the queryDelay variable in TestRoutes.swift:

```swift
let queryDelay = 0.3
```

The username, password, hostname, schema and port number can be changed in the TestRoutes.swift file.

```swift
let host = "REPLACE_WITH_HOST_NAME"
let user = "REPLACE_WITH_USERNAME"
let pass = "REPLACE_WITH_PASSWORD"
let schema = "REPLACE_WITH_DATABASE_NAME"
let port = 3306
```

# Compiling and Running on Linux

The following command will build and launch the **k-bug** application.

```sh
bash build-linux.sh
```

Note that the executable is saved to `.build-linux/debug/k-bug`.

# Compiling and Running on Mac

The problem only seems to manifest when running on Linux. However, should you still want to run on Mac, you may generate an xcode project with all the right settings. Type the following command:

```sh
bash create-xcode-project.sh
```

You may then open the xcode project, build and run.

# Using k-bug

Once you have the k-bug application running on a Linux box, use Chrome to open it http://localhost:8080

The main page will let you indicate how many simultaneous requests you want to make and what kind.

- **Use Semaphores:** Access the database using the library with semaphores to wait for each completion closure to finish.
- **Do not use Semaphores:** Access the database using the library with nested completion closures.
- **Mixed:** Half of the request will use semaphores and the other half will not.

# Column Description

| Column Name | Description |
| ----------- | ----------- |
| Request #   | Number of request |
| Semaphores | Indicates if the request used semaphores or not |
| Processing Duration | How much time was actually used to process the request, does not count query time (300 ms). |
| Query Duration | Time to execute the query |
| Total Duration | Processing Duration + Query Duration |
| Start Time | Indicates when the request started processing |
| End Time | Indicates when the request finished processing |

# What to Look For

The problem is much more evident when using the semaphore requests. Although it also occurs (in a much less obvious way), using the non-semaphore requests.

For example, the semaphore requests may take 4 seconds to finish. That is a lot!

While using the non-semaphore requests some take 20ms while others took 300ms. It may not seem much (specially compared to the semaphore version), but those that took 300 ms means they took 15 times the normal time! This does not happen when running on Mac (for the most part).

> It is worth noting that sometimes the request does not even begin processing on time. It seems other requests may be blocking them.
> This can be seen by looking at the start times. Ideally they should be all almost the same, but sometimes they differ by seconds.
> By using Chrome network debug pane this requests may show as if they took 4 seconds, but when looking at the processing time it may be 1 second. This means the request was on hold and started 3 seconds later. Is SwiftKuery blocking the Kitura thread!?

# Workaround

There is a change that makes all the problems dissappear. Chaning all the calls to `DispatchQueue.global().async` by `Dispatch.global().sync` makes it all go away. There are six of this calls: 5 in **MySQLConnection.swift** and the other in **MySQLResultFetcher.swift**

I know, I know, this is not how the library is suppose to work... nevertheless, it **does** work.




