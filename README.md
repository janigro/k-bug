# k-bug

This project demonstrates performance problems, when using the SwiftKueryMySQL library for multiple simultaneous requests.y

In order to work, the application needs to be able to connect to any MySQL database. No tables are needed. The requests simulate a query using SELECT SLEEP(0.3). Which is just a query that takes 300 ms to complete.

Once you have the k-bug application running on a Linux box, you may access its main page, which has a button to make several concurrent requests.

There are two types of requests:

1. Use Semaphores: This type of request access the database using the library with semaphores.
2. Do not use Semaphores: This type of requests uses completion closures.

```
https://localhost:8080
```

