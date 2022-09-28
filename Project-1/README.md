# COP5615-DOSP Project 1

Team Members:
* Raghav Gupta
* Anurag Swarnim Yadav 


Project Overview

Our architecture consists of a master, server, and client. The master and client are involved in mining bitcoins, and the server, acts as a listner to all the workers to print the output.

Master: Our master file has a variable (Noworkers) that can be varied to decide how many workers we would like to employ for the client. The file spawns one worker for itself and multiple workers as the "client".


Server: Our server acts as a listner to all the workers. Once the worker finds a bitcoin with the leading zeros. The server receives the random raw string and the hashed string with the leading zeros from the worker and prints them on the terminal/screen. 


Client: The client employs a specified number of workers to mine bitcoins. The workers keep mining until they find a single bitcoin.


Steps to mine bitcoin:

* First compile all the files using following command:
    * erlc -- master.erl client.erl time.erl server.erl 

    Then 

    * In the terminal, run the erl shell by typing -> erl
    * > master:master_start({"Number of leading zeroes you are expecting or in our case the value of K"}). \\This is to start the mining without any time stats.
    OR
    * > time:time_test().     (The default value of leading zeros is 4) \\This will also return back the ratio of runtime/wall_clock.




Stats on 3.5 GHz Quad-Core Intel Core i5:

* Random

| Number of Workers | Bytes | Number of leading zeros | Ratio |
| ----------------- | ----- | ----------------------- | ----- |
| 5000              | 9     | Four                    | 2.849 |

* Keeping bytes same and varying number of workers 

| Number of Workers | Bytes  | Number of leading zeros |  Ratio   |
| ----------------- | -----  | ----------------------- | -------- |
| 100               | 10     | Four                    | 2.367478 |
| 200               | 10     | Four                    | 2.567263 |
| 300               | 10     | Four                    | 2.671107 |
| 400               | 10     | Four                    | 2.509436 |
| 500               | 10     | Four                    | 2.651392 |


* Keeping number of workers same and varying bytes 

| Number of Workers | Bytes  | Number of leading zeros | Ratio    |
| ----------------- | ------ |-------------------------|--------- |
| 100               | 20     | Four                    | 3.108701 |
| 100               | 30     | Four                    | 2.967347 |
| 100               | 40     | Four                    | 3.225127 |
| 100               | 50     | Four                    | 2.963174 |
| 100               | 60     | Four                    | 3.239055 |



* Large numbers of workers and large bytes size  

| Number of Workers  | Bytes    | Number of leading zeros | Ratio    |
| ------------------ | -------- | ----------------------- | -------- |
| 1000               | 500      | Four                    | 3.399491 |
| 2000               | 1000     | Four                    | 3.493995 |
| 3000               | 1500     | Four                    | 3.582912 |
| 4000               | 2000     | Four                    | 3.519020 |
<!--| 5000               | 2500     | Four                    | 3.2 | -->



In the README file, you have to include the following material:

* Size of the work unit that you determined results in the best performance for your implementation and an explanation of how you determined it. The size of the work unit refers to the number of sub-problems that a worker gets in a single request from the boss.
    * Answer: The workers are getting 5 sub-problems in single request. The 5-sub problems are:
      -> 1.) generating a random string.
      -> 2.) concatinating it with the UFID.
      -> 3.) Generating the hash string.
      -> 4.) Comparing the substring with the number of zeroes.
      -> 5.) sending the message to the server if the string is found.
      
* The result of running your program for input 4
    * Answer: Stats are mentioned above

* The running time for the above is reported by time for the above and report the time. The ratio of CPU time to REAL TIME tells you how many cores were effectively used in the computation.  If you are close to 1 you have almost no parallelism (points will be subtracted).
    * Answer: Most 3 and above.

* The coin with the most 0s you managed to find.
    * k = 7

    | Raw String                                | Hashed string                                                    |
    | ----------------------------------------- | ---------------------------------------------------------------- |
    | gupta.raghav;Wcrx5VDGx3NyyA==             | 0000000fe66950f2c252bdf8f6c878e6098c97cdc382acd2661bdb1e2040a465 |
    
    
    * k = 8

    | Raw String                                | Hashed string           |
    | ----------------------------------------- | ---------------------------------------------------------------- |
    | gupta.raghav;iCPb5VAh21cglw==             | 0000000042f1917ac20eafd3d7f22be6456ff71ffebf7eb9ded3bf0259bc1a92 |

* The largest number of working machines you were able to run your code with.
