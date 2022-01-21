## Cloud Data Engineer interview preparation resources

The interview process is quite different for Cloud Data Engineering roles at big technology companies for candidates who have several years of experience.

The usual Algorithm and Data Structure is not the only components covered. Other areas of the interview process include:

- Linux Troubleshooting
- System design
- Database design
- Project and program management
- Web Technologies
- Object oriented design
- Distributed systems

Here are some resources to get started on these topics.

### 🤖 Algorithms:
Basic algorithms like Binary Search, BFS, DFS and some common data structures like Set, Priority Que, Que, Stack etc. should suffice. Solving some 50 easy to medium problems should be good (unless you have been hands off for a few years).

- [Codingbat (very introductory)](https://codingbat.com/python)
- [Interviewbit practice site](https://www.interviewbit.com/practice/)
- [https://www.youtube.com/results?search_query=google+interview](https://www.youtube.com/results?search_query=google+interview)

### 🖥️ Linux Troubleshooting:
Knowing common troubleshooting commands is very important. These 2 resources I found to be very good to learn about some common troubleshooting commands and how to think about Linux troubleshooting. 

- [USE - Utilization Saturation Error methodology](http://www.brendangregg.com/USEmethod/use-linux.html)  
- [Linux performance analysis in 60 seconds](https://medium.com/netflix-techblog/linux-performance-analysis-in-60-000-milliseconds-accc10403c55)  
  
##### 📗 Linux Book:
This book is the bible. It's quite daunting to read it. So have it if you need to look up something quickly. If you have read it completely kudos to you!

[Linux System Administration Handbook](https://www.amazon.com/UNIX-Linux-System-Administration-Handbook/dp/0134277554/ref=sr_1_3?crid=3LOYUS1HYECFS&keywords=linux+administration&qid=1562519418&s=gateway&sprefix=linux+a%2Caps%2C159&sr=8-3)  

##### 📗 SRE best practices:
SRE best practices is really good preparation for Cloud Infrastructure engineers. This is the gold standard now a days.

[https://landing.google.com/sre/books/](https://landing.google.com/sre/books/)  

### ☁️ System design:
Generally the interview process doesn't go too much deep into system design. So I would not spend a lot of time on this topic. Just knowing the terms and what they mean and few concerete examples of each service layer (e.g. Spanner, CloudSQL, Pub/Sub etc. or equivalent services in AWS or Azure) would be good to know. The interview won't be about designing a web-crawler or gmail. Those are for senior software engineer roles.

- [The System design primer - Github](https://github.com/donnemartin/system-design-primer#index-of-system-design-topics)
- [Scalability, Availability and Stability patterns](https://www.slideshare.net/jboner/scalability-availability-stability-patterns/)
- [System design interview links](https://github.com/checkcheckzz/system-design-interview)

##### 📘 Good Books
These are great books if you have more than a year to prepare. They are gold standard for distributed systems. Not really useful if you have a few months to prepare. But I highly recommend you read them sometime. They are definitely worth the effort.

- [Big Data: Principles and best practices of scalable realtime data systems](http://www.amazon.com/Big-Data-Principles-practices-scalable/dp/1617290343)
- [Real-Time Analytics: Techniques to Analyze and Visualize Streaming Data](http://www.amazon.com/Real-Time-Analytics-Techniques-Visualize-Streaming/dp/1118837916)
- [Building Microservices: Designing Fine-Grained Systems](http://www.amazon.com/Building-Microservices-Sam-Newman/dp/1491950358)
- [Designing Data-Intensive Applications: The Big Ideas Behind Reliable, Scalable, and Maintainable Systems](https://www.amazon.com/Designing-Data-Intensive-Applications-Reliable-Maintainable/dp/1449373321)

### 🕸️ Web Technologies:
This is an important topic. So make sure you brush up on this. These 3 links have a very good primer and from there you could dive deeper into each sections if they are not clear.

- [How the web works 1: A Primer](https://www.freecodecamp.org/news/how-the-web-works-a-primer-for-newcomers-to-web-development-or-anyone-really-b4584e63585c/#.7l3tokoh1)
- [How the Web works 2: Client server and structure of a web application.](https://medium.com/free-code-camp/how-the-web-works-part-ii-client-server-model-the-structure-of-a-web-application-735b4b6d76e3#.e6tmj8112)
- [How the web works 3: HTTP and REST](https://www.freecodecamp.org/news/how-the-web-works-part-iii-http-rest-e61bc50fa0a/#.vbrmrnihn)

### 🥤 Object oriented design
This is a very broad topic. It's hard to cover it in a blog post. The easiest way to brush up is using a book. But mostly this topic should be just a brush up.

[Grokking the object oriented design interview](https://github.com/tssovi/grokking-the-object-oriented-design-interview)

### 📫 Database designs
Database design is probably the easy one to prepare. Every experienced candidate already has a good handle on this. So you could skip this section altogether if you feel you have a good handle on this.

- [Awesome database design links](https://github.com/sujeet-agrahari/awesome-database-design)
- [System design database design topics](https://github.com/donnemartin/donnemartin.github.io/blob/master/content/system-design-database.md)

[Learn Database design and SQL](https://gist.github.com/rosswd/88bc2a5c6f666e39d2a5ea89dffaa6ca)

##### 📖 Learn Database Design
-   [Relational Model](https://en.wikipedia.org/wiki/Relational_model)
-   [A quick start on database design](http://www.ntu.edu.sg/home/ehchua/programming/sql/Relational_Database_Design.html)
-   [Normalization](http://www.troubleshooters.com/littstip/ltnorm.html)
-   [An Introduction to Database Normalization](http://mikehillyer.com/articles/an-introduction-to-database-normalization/)
-   [3 Normal Forms Database Tutorial](http://phlonx.com/resources/nf3/)
-   [Description of Database Normalization Basics](https://support.microsoft.com/en-us/help/283878/description-of-the-database-normalization-basics)
-   [Database Normalization and Techniques](http://www.barrywise.com/2008/01/database-normalization-and-design-techniques/)
-   [Creating a Quick MySQL Database](http://www.anchor.com.au/hosting/support/CreatingAQuickMySQLRelationalDatabase)
-   [Relational Database Design](https://en.wikibooks.org/wiki/Relational_Database_Design)

##### 🧰 Tools
-   [SQLfiddle](http://www.sqlfiddle.com/) - Online Database Environment
-   [DBfiddle](https://www.db-fiddle.com/) - Another Online Database service
-   [mycli](https://www.mycli.net/) - Command line interface for MySQL, MariaDB, Percona
-   [poorsql](http://poorsql.com/) - SQL Formatter

### 🧅 Misc Topics
These topics are deep dive into each individual components of the web technology stack. I would strongly recommend having a good understanding on a few of these especially Load balancers, CDN, DNS etc.

- [Load balancers](https://github.com/donnemartin/donnemartin.github.io/blob/master/content/system-design-load-balancer.md)
- [Application layer design](https://github.com/donnemartin/donnemartin.github.io/blob/master/content/system-design-application-layer.md)
- [Asynchronous process design](https://github.com/donnemartin/donnemartin.github.io/blob/master/content/system-design-async.md)
- [Back pressure](http://mechanical-sympathy.blogspot.com/2012/05/apply-back-pressure-when-overloaded.html)
- [exponential backoff](https://en.wikipedia.org/wiki/Exponential_backoff)
- [Little's law](https://en.wikipedia.org/wiki/Little%27s_law)
- [What is the difference between a message queue and a task queue?](https://www.quora.com/What-is-the-difference-between-a-message-queue-and-a-task-queue-Why-would-a-task-queue-require-a-message-broker-like-RabbitMQ-Redis-Celery-or-IronMQ-to-function)
- [System design patterns Latency vs Througput, Performance vs Scalability, Availability vs Consistency](https://github.com/donnemartin/donnemartin.github.io/blob/master/content/system-design-basics.md)
- [DNS - Domain Name System](https://github.com/donnemartin/donnemartin.github.io/blob/master/content/system-design-dns.md "system-design-dns.md")
- [Communication TCP/IP](https://github.com/donnemartin/donnemartin.github.io/blob/master/content/system-design-comm.md "system-design-comm.md")
- [CDN - Content Delivery Network](https://github.com/donnemartin/donnemartin.github.io/blob/master/content/system-design-cdn.md "system-design-cdn.md")
- [Cache design](https://github.com/donnemartin/donnemartin.github.io/blob/master/content/system-design-cache.md "system-design-cache.md")
- [Reverse Proxy](https://github.com/donnemartin/donnemartin.github.io/blob/master/content/system-design-reverse-proxy.md "system-design-reverse-proxy.md")
- [System design Appendix](https://github.com/donnemartin/donnemartin.github.io/blob/master/content/system_design_appendix.md)

### 🔦 Leadership lessons
Most of the leadership questions are quite self explanatory for a senior and experienced candidate. But I included some foundational readings to brush up.

- [NASA 100 lessors learned for Project managers](https://llis.nasa.gov/lesson/1956)
- [The unwritten laws of Engineering](http://tlmerrill.pbworks.com/w/file/fetch/85018306/Unwritten%20Laws%20Engineering.pdf)
- [10 Career related books for Software engineering Individual Contributors/Managers club](https://www.instapaper.com/read/1476173341)
- [Staff Engineers (Stories and Book with the same name)](https://staffeng.com/)
	- Guides
		- [Work on what matters](https://staffeng.com/guides/work-on-what-matters)
		- [Staying aligned with authority](https://staffeng.com/guides/staying-aligned-with-authority/)
		- [Promotion packets](https://staffeng.com/guides/promo-packets/)
		- [Manage technical quality](https://staffeng.com/guides/manage-technical-quality/)
		- [Engineering strategy](https://staffeng.com/guides/engineering-strategy)
		- [Present to executives](https://staffeng.com/guides/present-to-executives)
		- [What do Staff engineers actually do?](https://staffeng.com/guides/what-do-staff-engineers-actually-do)
		- [Looking for more? Read all guides…_](https://staffeng.com/guides)
- [Setting and prioritizing goals as a staff engineer](https://www.intercom.com/blog/setting-prioritizing-goals-as-a-principal-engineer/)
	- [the replay](https://leaddev.com/leaddev-live/so-youre-staff-now-what)
- [Top recommended books for Engineering managers](https://www.managersclub.com/top-recommended-books-for-engineering-managers/)

### 📰 Distributed systems papers:
These are optional readings to understand how the distributed systems evolved over time. Not required for interview but for own development and understanding.

- [A distributed system reading list - (papers to read) ](https://dancres.github.io/Pages/)
	- Thought provokers
		- [On Designing and Deploying Internet Scale Services](https://mvdirona.com/jrh/talksAndPapers/JamesRH_Lisa.pdf) - James Hamilton
		- [Why Distributed Computing?](https://www.artima.com/weblogs/viewpost.jsp?thread=4247) - Jim Waldo
		- [A Note on Distributed Computing](https://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.41.7628) - Waldo, Wollrath et al
	- Latency
		- [Latency - the new web performance bottleneck](https://www.igvita.com/2012/07/19/latency-the-new-web-performance-bottleneck/) - not at all new (see [Patterson](http://dl.acm.org/citation.cfm?id=1022596)), but noteworthy
	- Google
		- [Google File System](https://research.google/pubs/pub51/)
		- [MapReduce](https://research.google/pubs/pub62/)
		- [BigTable](https://research.google/pubs/pub27898/)
		- [Spanner](https://research.google/pubs/pub39966/) - Google's scalable, multi-version, globally-distributed, and synchronously-replicated database.
	- Consistency models
		- [CAP Twelve Years Later: How the "Rules" Have Changed](https://www.infoq.com/articles/cap-twelve-years-later-how-the-rules-have-changed) - Eric Brewer expands on the original tradeoff description
	- Theory
		- [Rules of thumb in Data engineering](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/ms_tr_99_100_rules_of_thumb_in_data_engineering.pdf)
		- [Distributed computing economics](https://arxiv.org/ftp/cs/papers/0403/0403019.pdf)
	- Infrastructure
		- [Principles of Robust Timing over the Internet](https://queue.acm.org/detail.cfm?id=1773943) - Managing clocks is essential for even basics such as debugging
	- Storage
		- [Consistent Hashing and Random Trees](https://www.akamai.com/us/en/multimedia/documents/technical-publication/consistent-hashing-and-random-trees-distributed-caching-protocols-for-relieving-hot-spots-on-the-world-wide-web-technical-publication.pdf)
	- Paxos census
		- [The Part-Time Parliament](https://lamport.azurewebsites.net/pubs/lamport-paxos.pdf) - Leslie Lamport
		-   [Paxos Made Simple](https://lamport.azurewebsites.net/pubs/paxos-simple.pdf) - Leslie Lamport
