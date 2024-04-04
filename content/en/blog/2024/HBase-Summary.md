---
title:       "HBase全面解析：架构、应用场景及优化策略一网打尽"
description: "这篇文章全面解析了HBase的架构、应用场景和优化策略，包括表设计、数据访问模式和文件合并等关键技术。无论是想深入了解HBase的初学者，还是希望优化数据库性能的专业人士，都能从中获得宝贵的经验和实用的技巧"
date:        2024-03-22
author:   "Devean"
tags:       ["系统设计","HBase"]
categories:  ["Tech"]
thumbnail: "/img/blog/arch.png"

keywords: ["HBase","HBase特点","HBase应用场景","HBase架构","HBase开发经验总结","RowKey设计","HBase表结构设计","HBase优化策略","HBase热点问题","HBase合并"]

draft: true
---


## What is HBase？

HBase is a distributed, column-oriented, open-source database that is part of the Apache Hadoop project and runs on top of the HDFS file system. HBase is an open-source implementation of Google's [Bigtable paper](https://static.googleusercontent.com/media/research.google.com/en//archive/bigtable-osdi06.pdf) and is a highly reliable, high-performance, column-oriented, scalable distributed storage system that is suitable for large-scale unstructured data storage.

## What HBase is Feature?

**Scalability:** HBase can scale out across hundreds or thousands of servers to store and process large-scale data sets. It uses Hadoop's distributed file system (HDFS) as the underlying storage engine and achieves high availability and fault tolerance through horizontal partitioning and data replication.


**High performance:** HBase provides fast read and write access, supports high concurrency, and low-latency data access. It optimizes data access performance by storing data in memory and supporting data partitioning and indexing.

**Column-oriented storage:**  HBase uses a column-oriented storage model, which means it can effectively handle sparse data and a large number of columns. This storage model makes HBase particularly suitable for analytical workloads such as data warehousing, log analysis, and real-time analytics.


+ Row VS Column Database feature compare


|   | Row Database                                           |   Columns Database                                           |
|--------|--------------------------------------------------------|--------------------------------------------------------------------|
| 数据存储单位 | 行                                                      | 列族                                                                 |
| 适用场景   | OLTP（事务处理）、关联查询                                        | OLAP（在线分析处理）、大规模数据存储和查询                                            |
| 读取性能   | 读取整个记录较快                                               | 读取特定列或列族较快                                                         |
| 写入性能   | 单行写入较快                                                 | 大规模写入较快                                                            |
| 索引结构   | B-tree 或 B+tree                                        | LSM 树 或类似结构                                                        |
| 查询灵活性  | 适用于复杂查询和事务                                             | 适用于聚合操作和宽表查询                                                       |
| ACID 特性 | 具有较好的 ACID 特性                                          | 通常具有较弱的 ACID 特性                                                    |
| 存储空间占用 | 相对较高                                                   | 相对较低                                                               |
| 数据压缩率  | 相对较低                                                   | 相对较高                                                               |
| 数据模型   | 关系型模型                                                  | 键值对模型（或称宽表模型）                                                      |
| 产品     | MySQL, PostgreSQL, Oracle Database, SQL Server, SQLite | Apache HBase, Apache Cassandra, Google Bigtable, ScyllaDB, Vertica |

** Scalability: ** HBase provides flexible schema design, allowing column families to be added or removed dynamically without downtime, achieving data schema flexibility and flexibility.

**Supporrt for Big Data Ecosystem:** HBase is tightly integrated with the Apache Hadoop ecosystem and can seamlessly integrate with other big data processing frameworks such as Hadoop MapReduce, Apache Hive, Apache Spark, etc., to analyze, mine, and process large-scale data.

![img.png](/img/blog/big-data-feature.png)

## What are the application scenarios for H Base?

1. **Large-scale data random real-time read/write:** If you need to store and process massive data and need to quickly perform real-time queries and retrieval, then HBase is a good choice. Because it uses distributed storage and column-oriented storage mode, it can achieve high-performance random read and write, supporting real-time data queries and analysis.

2. **High-concurrency data access:** HBase provides high-concurrency read/write access capabilities and can handle a large number of read/write requests simultaneously. Therefore, if your application scenario requires high-concurrency data access, such as social networking applications, real-time log analysis, etc., then HBase is a good storage solution.

3. **Applications that require horizontal scaling:** HBase can scale out across hundreds or thousands of servers and can handle PB-level data. Therefore, if your application scenario requires processing large-scale data and needs to scale out horizontally as data grows, then HBase is a suitable storage solution.

4. **Real-time data processing and analysis:** HBase can be used in conjunction with real-time data processing frameworks (such as Apache Storm, Apache Flink) to store real-time generated data and support fast data queries and analysis. Therefore, if your application scenario requires real-time data processing and analysis, then HBase is a suitable choice.


## What is the architecture of H Base?


![img.png](/img/blog/arch.png)

### HBase architecture consists of the following components:

1. **Client:** is the user interface of HBase, used to interact with the HBase cluster. Clients can access the HBase cluster through HBase's Java API or interfaces such as Thrift, REST, etc., to read and write data.

2. **zookeeper:** ZooKeeper is the coordination service of HBase, used to coordinate the status and metadata information of the HBase cluster. HBase uses ZooKeeper to perform operations such as master node election, RegionServer registration, and status monitoring.

3. **HMaster:** HMaster is the master node of HBase, responsible for managing the metadata information of the HBase cluster, including table creation, deletion, splitting, merging, etc. HMaster also monitors the status of RegionServer and is responsible for load balancing and failover of RegionServer.

4. **RegionServer:** RegionServer is the working node of HBase, responsible for storing and processing data. Each RegionServer can manage multiple Regions, each Region corresponds to a partition of an HBase table. RegionServer is responsible for handling client read/write requests and storing and retrieving data.

5. **HLog:** HLog is the Write-Ahead Log (WAL) file of HBase, used to record data change operations. HLog is used to ensure data consistency and durability to prevent data loss.

6. **HRegion:** HRegion is the data storage unit of HBase, corresponding to a partition of an HBase table. Each HRegion contains multiple Stores, each Store corresponds to a column family. HRegion is responsible for storing and managing data and handling client read/write requests.

7. **Store:** Store is the data storage unit of HBase, corresponding to a column family of an HBase table. Each Store contains multiple StoreFiles, each StoreFile corresponds to an HFile. Store is responsible for storing and managing data and handling client read/write requests. 

8. **MemStore:** MemStore is the memory storage unit of HBase, used to cache data change operations. MemStore is used to cache data change operations to improve data write performance. When the data volume of MemStore reaches a certain threshold, the data is flushed to StoreFile on disk.

9. **HFile:** HFile is the data file of HBase, used to store data. HFile is a data file based on HDFS, used to store data of HBase tables. HFile uses block compression and block indexing technologies to improve data storage efficiency and read performance.

![img_1.png](/img/blog/Ffile-structure.png)

10. **HDFS:** HDFS is the underlying storage engine of HBase, used to store data of HBase tables. HBase uses HDFS to store HFile and HLog files to achieve data persistence and high reliability.
11. **DataNode:** DataNode is the data node of HDFS, used to store data of HBase tables. HBase uses DataNode to store HFile and HLog files to achieve data persistence and high reliability.



## HBase application development experience summary

### RowKey Design

#### RowKey Design Principles

**Length principle:** The length of the RowKey should be kept short, generally controlled between 10-100 bytes, to improve data storage efficiency and read performance. The actual storage structure is as shown in the figure below. In addition, it should be as fixed-length as possible, and do not use variable-length auto-increment numbers, which may cause write skew on a single machine and lead to write hotspots.


![hbase data structure](/img/blog/data-structure.png)

**The only principle:**
Must be unique in design to ensure the uniqueness of the RowKey. Since data storage in HBase is in the form of Key-Value, if the same RowKey data is inserted into the same table in HBase, the original data will be overwritten by the new data when storing a single version of the data, and the new data will be appended to the original data when storing multiple versions.

**Sort principle:**

The RowKey of HBase is sorted in ASCII order, that is, in lexicographic order, which means that the value of the RowKey with a smaller ASCII code will be placed in front. Therefore, when designing the RowKey, we should make full use of this point and put the data that needs to be queried together frequently together to improve query efficiency.

**Hash principle:**

The RowKey should be evenly distributed on each HBase node to avoid data skew, because the data is stored on which RegionServer based on the dictionary order and table partition. If the RowKey design is unreasonable, it may cause data skew, that is, the data is concentrated on a certain RegionServer. If there are too many RowKeys with the same prefix, it may cause data skew and affect the performance of HBase.

#### RowKey Hotspot Issues

1. **顺序递增的RowKey**：
- 当RowKey是顺序递增的时候，例如时间戳作为RowKey的一部分，如果写入速率过高，那么所有的写操作都会集中在最后的Region中，导致该Region成为热点写。同时，如果读取操作也集中在最新的数据上，那么这些读操作也会集中在同一个Region，导致热点读。

2. **随机分布的RowKey**：
- 当RowKey的分布不均匀，例如采用随机生成的UUID作为RowKey，有些Region可能会负责大量的数据，而其他Region可能几乎没有数据。这样的话，负责大量数据的Region容易成为热点写，同时也可能成为热点读，因为访问这些数据的请求集中在一个Region上。

3. **某些特定的业务场景**：
- 某些特定的业务场景可能会导致热点读和热点写，例如流行度较高的用户或热门的数据。如果大量的读写操作集中在某些特定的RowKey上，那么就会导致相关Region成为热点。

4. **批量写入或读取**：
- 如果应用程序进行大量的批量写入或读取操作，并且这些操作都集中在一小部分RowKey上，那么就可能导致热点写或热点读。这种情况下，一些Region会承担大量的负载，而其他Region可能闲置。


#### RowKey常见设计优化方法


**Reversing逆序：**

如果经初步设计出的RowKey在数据分布上不均匀，但RowKey尾部的数据却呈现出了良好的随机性，此时，可以考虑将RowKey的信息翻转，或者直接将尾部的bytes提前到RowKey的开头。 Reversing可以有效的使RowKey随机分布，但是牺牲了RowKey的有序性。将rowKey的部分逆序，可以有效的减少热点问题，但是牺牲了rowKey的有序性。

+ 缺点：利于Get操作，但不利于Scan操作，因为数据在原RowKey上的自然顺序已经被打乱。

**SaltingSalting（加盐):**

在原RowKey的前面添加固定长度的随机数，也就是给RowKey分配一个随机前缀使它和之间的RowKey的开头不同,随机数能保障数据在所有Regions间的负载均衡。

+ 缺点：因为添加的是随机数，基于原RowKey查询时无法知道随机数是什么，那样在查询的时候就需要去各个可能的Regions中查找，Salting对于读取是利空的。并且加盐这种方式增加了读写时的吞吐量。


**Hashing:**
基于RowKey的完整或部分数据进行Hash，而后将Hashing后的值完整替换或部分替换原RowKey的前缀部分。这里说的 hash 包含 MD5、sha1、sha256 或 sha512 等算法。
+ 缺点：与 Reversing 类似，Hashing 也不利于 Scan，因为打乱了原RowKey的自然顺序。

**Combining:**
将多个字段组合成一个RowKey，这样可以保证RowKey的唯一性，同时也可以保证RowKey的有序性。例如，可以将时间戳和设备ID组合成一个RowKey，这样可以保证同一设备的数据存储在一起，同时也可以保证数据按时间顺序存储。



### 表结构设计原则

1. **表设计：**
    + 表名设计：建议生产线创建表时不要单独使用表名，而应该使用命名空间加表名的形式。同一个业务的相关表放在同一个命名空间下，不同业务使用不同的命名空间。这样可以方便管理，也可以避免表名冲突及权限控制
    + 列族设计：单业务单表尽可能保持少的列族数量、因底层存储HFile文件数量与列族数量成正比，列族数量越多，每次读取多个列族内数据时，读取的HFile文件越多，直接影响性能。
    + 列设计：避免设计过多的列，尽量将相关的数据存储在同一列族下，以减少列的数量。
    + 表属性配置
        + MAX_FILESIZE: 表示HBase表中HFile文件的最大大小，默认为10G。如果HFile文件的大小超过了这个值，HBase会自动触发Split操作，将HFile文件切分成更小的文件。
        + MEMSTORE_FLUSHSIZE: 表示HBase表中MemStore的最大大小，默认为128M。当MemStore的大小超过这个值时，HBase会自动触发Flush操作，将MemStore中的数据刷写到HFile文件中。
        + DURABILITY: 表示HBase表中数据的持久化策略，默认为USE_DEFAULT。可以设置为SKIP_WAL，表示不将数据写入WAL文件，以提高写入性能。但是这样会降低数据的持久性和可靠性。
        + READONLY: 表示HBase表是否只读，默认为false。可以设置为true，表示HBase表只读，不允许写入操作。这样可以保护数据不被修改。

2. **列族设计**：
- 列族名称设计：列族名称应具有可读性和描述性，除此之外，列族名称的长度应尽量短。
- 合理划分列族，将具有相似访问模式的列放在同一个列族中，以提高读取效率，因同一个列族内的数据存储在同一块HFile上，实际生产中一搬不超过3个。
- 避免设计过多的列族，以减少HBase中的列族数量，从而降低维护成本,及同一张表内列族越多，每次读取多个列族内数据时，读取的HFile文件越多，即直接影响性能。
- 列族配置
    - VERSIONS: 用于控制列族中数据的版本数，默认为1，即只保留最新的版本。如果需要保留多个版本，可以设置VERSIONS的值为2或更多。
    - BLOCKCACHE: 用于控制列族中数据的缓存策略，默认为true，即开启缓存。如果数据的**访问模式是随机读取，可以关闭缓存以节省内存。**
    - BLOOMFILTER: 布隆过滤器类型，可选项为NONE、ROW和ROWCOL，默认为ROW。ROW模式表示仅仅根据rowkey就可以判断待查找数据是否存在于HFile中，而ROWCOL模式只对指定列的随机读有优化作用，如果用户只根据rowkey定位所有数据，而没有具体指定列查找，ROWCOL模式就不会有任何效果。通常建议选择ROW模式。
    - TTL (Time To Live) ：数据失效时间。TTL是HBase非常重要的一个特性，可以让数据自动过期失效，不需要用户手动删除。根据实际业务情况配置数据保留时间，以节省存储空间。
    - COMPRESSION: 数据压缩算法，可选项为NONE、GZ、LZO、SNAPPY、BZIP2，默认为NONE。最重要的作用是减少数据存储成本，理论上SNAPPY算法的压缩率可以达到5∶1甚至更高，但是根据测试数据不同，压缩率可能并没有达到理论值，另一方面，压缩/解压缩需要消耗大量计算资源，对系统CPU资源需求较高。
    - DATA_BLOCK_ENCODING：数据编码算法，可选项NONE、PREFIX、DIFF、FASTDIFF和PREFIX_TREE。和压缩一样，编码最直接、最重要的作用也是减少数据存储成本；编码/解码一般也需要大量计算，需要消耗大量CPU资源。
    - BLOCKSIZE ：文件块大小。Block是HBase系统文件层面写入、读取的最小粒度，默认块大小为64K。对于不同的业务数据，块大小的合理设置对读写性能有很大的影响。通常来说，如果业务请求以get请求为主，可以考虑将块设置较小；如果以scan请求为主，可以将块调大；默认的64K块大小是在scan和get之间取得的一个平衡。

4. **列设计**：
- 避免设计过多的列，尽量将相关的数据存储在同一列族下，以减少列的数量。
- 列的命名应具有可读性和描述性，便于理解和维护。

### 数据访问模式

HBase支持两种主要的数据访问模式：随机访问和扫描访问。这两种模式各有适用的场景，可以根据具体需求选择合适的访问模式。

#### 随机访问模式

随机访问模式是指根据行键（Row Key）直接访问特定行数据的模式。在随机访问模式下，用户可以通过指定行键直接获取或修改相应的数据，而不需要扫描整个表。随机访问模式适用于需要快速定位和获取特定行数据的场景，通常用于查询、更新或删除单个数据记录的操作。RowKey设计时就不用考虑数据的存储连续性问题。

##### 特点：
- 快速：通过行键直接获取数据，读取速度非常快。
- 精准：能够准确定位到特定行数据，适用于精确查找和操作。

#### 扫描访问模式

- 扫描访问模式是指按照顺序或范围扫描表中的数据的模式。在扫描访问模式下，用户可以指定起始行键和结束行键，按照字典序顺序扫描表中的数据，或者指定特定的行范围进行扫描。扫描访问模式适用于需要按照顺序或范围获取大量数据的场景，通常用于数据分析、统计或批量处理等操作。
- 扫描访问模式需特别注意是否存在最新数据高频读写问题，如果存在，在设计RowKey 可设计散列前缀+Long.MAX_VALUE-时间戳，这样可以保证最新数据分散在不同的Region中，且最新数据在最后，不会影响其他数据的读写。

##### 特点：
- 适用于大量数据：能够高效处理大量数据的扫描和处理。
- 顺序访问：按照字典序顺序或指定范围顺序扫描数据，适用于顺序处理或统计。

根据业务场景选择合适的数据访问模式，可以提高数据访问效率和性能、比如读多写少的高频查询场景、还是读少写多的高频写入同步统计分析场景。，还是两者结合。

## 文件合并

HBase 中的存储管理机制通过监控和控制存储文件的数量和大小，以及定期执行合并和切分操作，来保证数据的存储和管理的高效性和稳定性。即小文件过多时触发合并，合并为大文件,来减少碎片文件数量,当大文件过大时触发Region切分，主要目的是为了保持数据的负载均衡和系统的性能，防止单机负载过高，导致性能下降。

![Compactio](/img/blog/Compactio.png)

### 小合并 Minor Compactio

小合并主要目的是合并多个较小的HFile文件，以减少存储文件数量，减少磁盘占用，并提高读取性能。

+ 触发时机：
    + 当HFile数量达到一定阈值时。
    + 当某个列族的HFile文件数量超过一定阈值时。
    + 定期触发，以维护存储文件的整洁性和性能。
+ 影响范围： 小合并只影响某个列族的HFile文件，不会影响其他列族的数据。

### 大合并  Major Compactio



一般情况下，Major Compaction持续时间会比较长，整个过程会消耗大量系统资源，对上层业务有比较大的影响。因此线上部分数据量较大的业务通常推荐关闭自动触发Major Compaction功能，改为在业务低峰期手动触发（或设置策略自动在低峰期触发）。

## Encapsulation of the HBase Client interface

https://github.com/devon-ye/org-middle-ware/tree/develop/mw-HBase