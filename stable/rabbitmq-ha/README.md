# RabbitMQ 高可用

[RabbitMQ](https://www.rabbitmq.com) 是一个开源消息代理软件，它实现了高级消息队列协议（AMQP）。

## 依赖

- Kubernetes 1.5+ with Beta APIs enabled
- 提供PV provisioner可以支持的卷插件

## 应用的部署和使用

安装名为“my-release”的charts:

```bash
$ helm install --name my-release stable/rabbitmq-ha
```

### 常用配置参数

| 参数                        | 描述                                                                                                                  | 默认值                                                   |
| -------------------------------- | -----------------------------------------------------                                                                        | --------------------------------------------------------- |
| `rabbitmqUsername`                          | RabbitMQ application 用户名                                                                                                                  | `guest`                                                   |
| `rabbitmqPassword`                          | RabbitMQ application 密码                                                                                                                  | `随机24位字符串`                                                   |
| `managementUsername`                          | 管理用户名                                                                                                                  | `management`                                                   |
| `managementPassword`                          | 管理用户密码                                                                                                                  | `随机24位字符串`                                                   |
| `rabbitmqVhost`                          | 默认vhost                                                                                                                  | `"/"`                                                   |
| `rabbitmqErlangCookie`                          | Erlang cookie	                                                                                                                  | `随机32个为字符串`                                                   |
| `rabbitmqClusterPartitionHandling`                          | 自动分区处理策略                                                                                                                  | `autoheal`                                                   |
| `openAllAmqpService.enabled`                          | 为每个amqp单独映射一个服务                                                                                                                  | `false`                                                   |
| `prometheus.exporter.enabled`                          | 配置Prometheus Exporter                                                                                                                | `false`                                                   |
| `service.type`                          | Service type                                                                                                                  | `ClusterIP`                                                   |

**更多配置参数请参阅[values.yaml](values.yaml)**

## 升级charts

要升级charts，您需要确保使用相同的`rabbitmqErlangCookie`值。如果您没有在安装charts时定义，则可以使用以下命令进行升级:

```
$ export ERLANGCOOKIE=$(kubectl get secrets -n <NAMESPACE> <HELM_RELEASE_NAME>-rabbitmq-ha -o jsonpath="{.data.rabbitmq-erlang-cookie}" | base64 --decode)
$ helm upgrade \
    --set rabbitmqErlangCookie=$ERLANGCOOKIE \
    <HELM_RELEASE_NAME> stable/rabbitmq-ha
```

## 卸载charts
卸载(或删除)`my-release` deployment:

```bash
$ helm delete my-release
```   
该命令将删除与charts关联的所有Kubernetes组件并删除该release。

## Prometheus监控

通过将`prometheus.enabled`设置为`true`，可以启用Prometheus。有关更多详细信息和配置选项，请参阅[values.yaml](values.yaml)
