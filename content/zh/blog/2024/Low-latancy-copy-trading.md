---
title:       "低延迟高并发跟单服务解决方案"
description: "P99 50毫秒低延迟跟单交易服务设计方案核心要点思路"
date:        2024-05-21
author:      "Devean"
image:       ""
math: true
categories:  ["Tech" ]
thumbnail: "/img/blog/QPTrade1.webp"
tags:        ["系统设计"]
keywords: ["低延迟跟单交易","高并发交易系统", "异步处理", "Disruptor", "容错处理", "中间件异常"]
draft: true
---

## 需求背景
   根据用户KOL交易下单开/平仓信号,自动为跟单散户完成自动下单开仓、平仓的操作。实现低延迟、高并发下单。且不对现有交易系统进行过多的改造。在下文中带单员统称Trader,跟单员统称Copier。
## 需求分析

### 功能需求

#### **核心业务背景**
交易系统，每个交易用户可根据自己的实际情况对自己的仓位,按以下几个维度进行设置后进行下单,最终导致风控保证金、持仓多少会产生不同的影响。
   1. 保证金模式：全仓保证金、逐仓保证金。
   2. 仓位模式：多空模式、买卖模式。
   3. 账户模式：单币种保证金账户、跨币种保证金账户、组合保证金模式。
   4. 主子账户模式：主账户带单/主账户跟单、子账户带单/子账户跟单。主账户带单/子账户跟单、子账户带单/主账户跟单。
#### **核心业务难点**
   在以上维度的业务模式下,如何保证带单员、跟单员仓位风险隔离、收益率一致性、除此之外在现有交易场景上不过多的增加带单员、跟单员的操作复杂度、降低用户操作体验。
+ 问题
    1. 如何保证带单员、跟单员仓位风险隔离。即带单员爆仓后跟单员已跟开仓位如何处理。
    2. 如何处理带单员、跟单员收益率一致性。即带单员收益率高、跟单员收益率低如何处理。，比如仓位模式不一致、杠杠倍数不一致、保证金模式不一致等。
    3. 如何在现有交易场景上不过多的增加带单员、跟单员的操作复杂度。即带单员、跟单员操作简单、易上手。不去开子账户进行主子账户资金划转，分散资金。
    4. 如何处理同一跟单员对统一合约标的跟随多个带单员，其中单个带单员、仓位模式、保证金模式不一致的情况。其中一个带单员平仓时，如何平掉对应带开的仓位，计算对应该带单员应得的分润。
#### **核心功能**
  1. 带单员申请：历史交易胜率高、收益率高的用户可发起申请带单员操作成为带单员(Trader),并设置交易账户配置、带单币种、分润比例成为带单员。
  2. 跟单关系建立：跟单员(Copier)可在带单员排行榜选择带单员进行跟单操作,并设置跟单账户配置与交易员账户不互斥、跟单币种、跟单模式(按比例/固定金额)进行跟单。
  3. 带单开/平仓：带单员在交易账户下带单币种进行开仓,跟单系统消费来自交易系统的下单事件,匹配跟单系统中的跟单员进行下单操作。
  4. 分润结算：平仓后根据带单员的分润比例进行结算,并将分润金额转入结算系统账户、最终按天、周等结算给带单员。
### 非功能性需求
   1. 低延迟：P99 50毫秒内完所有跟单下单操作。即带单员下单后，触发跟单下单延迟越低，跟单员开仓价格与带单员一致性越高、开仓成功率越高。
   2. 高并发：即带单员触发跟单后，满员跟单500人，跟单员资金充足的情况下，触发500人同时下单操作。如果后续系统能力充足，可进一步提升该限制操作。
   3. 高可用：保证系统24小时不间断运行，系统故障后，可快速恢复,系统升级最小化停机时间。
## 整体架构

### 核心技术解决方案
1. 带单信号过滤

| 序号 | 方案                                                          | 优点                        | 缺点                                    |  备注  |
|----|-------------------------------------------------------------|---------------------------|---------------------------------------| --------- |
| 1  | 在交易系统中过滤信号: 即在带单审核通过、变更带单合约标的、退出带单操作时要同步，带单员状态标志位及对应的带单合约标的 | 带单系统压力小，同步带单系统不容易出现信号堆积。  | 1.交易系统新增资源消耗压力 2.交易系统新增带单状态同步，过滤发送逻辑  |  |
| 2  | 在跟单系统中过滤: 即跟单系统消费到交易信号后过滤出带单信号向下流转处理。                       | 交易系统改造小、不新增资源消耗压力，对现有交易系统 | 1.带单系统要同步海量的交易信号，并在带单系统信号同步入口逻辑过滤带单信号 |

2. 低延迟同步

| 序号 | 方案                      | 优点                        | 缺点                                    |  备注  |
|----|-------------------------|---------------------------|---------------------------------------| --------- |
| 1  | 基于binlog、cannel、kafka 同步 |  |  |  |
| 2  | websocket               |  |  |  |

//todo
### 业务难点

### 技术难点

## 业务难点

