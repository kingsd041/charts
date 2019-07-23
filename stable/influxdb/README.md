# InfluxDB Helm Chart

InfluxDB 是一个时间序列数据库，用于处理海量写入与负载查询。InfluxDB旨在用作涉及大量时间戳数据的任何用例的后端存储, 包括DevOps监控，应用程序指标，物联网传感器数据和实时分析。

## 关键特性

以下是InfluxDB目前支持的一些功能，使其成为处理时间序列数据的绝佳选择。
- 专为时间序列数据编写的自定义高性能数据存储。
- 完全使用GO编写。编译成单个二进制文件，没有外部依赖项。
- 简单，高性能的写入和查询HTTP API。
- 插件支持其他数据提取协议，如Graphite，collectd和OpenTSDB。
- 专为类似SQL的查询语言量身定制，可轻松查询聚合数据。支持min, max, sum, count, mean, median 等一系列函数，方便统计
- 标签允许对系列进行索引以实现快速有效的查询。
- 保留策略有效地自动使过时数据过期。
- 连续查询自动计算聚合数据，以提高频繁查询的效率。

## InfluxDB-Relay架构设计
InfluxDB Relay项目向InfluxDB添加了一个基本的高可用性层。通过正确的体系结构和灾难恢复过程，可以实现高可用性的设置。
该体系结构相当简单，由一个负载均衡器、两个或多个InfluxDB Relay进程和两个或多个InfluxDB进程组成。负载均衡器将UDP流量和HTTP POST请求的路径/write指向两个InfluxDB，同时将GET请求的路径/query指向两个InfluxDB服务器。

```
        ┌─────────────────┐                 
        │writes & queries │                 
        └─────────────────┘                 
                 │                          
                 ▼                          
         ┌───────────────┐                  
         │               │                  
┌────────│   LB (Nginx)  │─────────┐        
│        │               │         │        
│        └──────┬─┬──────┘         │        
│               │ │                │        
│               │ │                │        
│        ┌──────┘ └────────┐       │        
│        │ ┌─────────────┐ │       │┌──────┐
│        │ │/write or UDP│ │       ││/query│
│        ▼ └─────────────┘ ▼       │└──────┘
│  ┌──────────┐      ┌──────────┐  │        
│  │ InfluxDB │      │ InfluxDB │  │        
│  │ Relay    │      │ Relay    │  │        
│  └──┬────┬──┘      └────┬──┬──┘  │        
│     │    |              |  │     │        
│     |  ┌─┼──────────────┘  |     │        
│     │  │ └──────────────┐  │     │        
│     ▼  ▼                ▼  ▼     │        
│  ┌──────────┐      ┌──────────┐  │        
│  │          │      │          │  │        
└─▶│ InfluxDB │      │ InfluxDB │◀─┘        
   │          │      │          │           
   └──────────┘      └──────────┘           
 
```   

Relay将侦听HTTP或UDP写入，并通过适当的HTTP写入或UDP端点将数据写入到每个InfluxDB服务器。如果写是通过HTTP发送的，那么当一个InfluxDB服务器返回成功时，relay将立即返回一个成功响应。如果任何InfluxDB服务器返回一个4xx响应，该响应将立即返回给客户机。如果所有服务器都返回5xx，则会将5xx返回给客户机。如果一些(但不是所有)服务器返回一个5xx，该5xx将不会返回给客户机。我们应该监视每个实例的日志，以发现5xx个错误。
通过此设置，可以在一个relay或一个InfluxDB出现故障时，仍然可以进行写入和提供查询操作。但是，恢复过程可能需要操作员干预。

## Endpoint介绍

#### /admin endpoint
数据操作依赖于/write endpoint，而其他一些功能（如数据库或用户管理）则基于/query endpoint。由于InfluxDB Relay不向客户端发回响应主体，因此我们无法转发此端点提供的所有功能。不过，我们可以通过/admin路由公开它。
现在可以查询/admin endpoint。它的用法与标准/query InfluxDB enpoint相同：
```
curl -X POST "http://127.0.0.1:9096/admin" --data-urlencode 'q=CREATE DATABASE some_database'
```

#### /health endpoint
此endpoint提供了一种快速检查所有后端状态的方法。它将返回一个JSON对象，详细说明后端的状态，如下所示：
```JSON
{
	"status": "healthy",
	"healthy": {
		"http-backend-0": "OK. Time taken 1.665655ms",
		"http-backend-1": "OK. Time taken 1.540956ms"
	}
}
```

## InfluxDB操作示例

#### 创建数据库
```
curl -X POST "http://NGINX_IP:NGINX_PORT/admin" --data-urlencode 'q=CREATE DATABASE some_database'
```

#### 写入数据
```
curl -i -XPOST 'http://NGINX_IP:NGINX_PORT/write?db=some_database' --data-binary 'cpu_load_short,host=server01,region=us-west value=0.65 '
```

#### 查询数据
```
curl -G 'http://NGINX_IP:NGINX_PORT/query?pretty=true' --data-urlencode "db=some_database" --data-urlencode "q=SELECT * FROM cpu_load_short ORDER BY time DESC LIMIT 3"
```
