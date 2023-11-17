---
title: '翻译 | 什么是套利'
subtitle: "What Is Arbitrage"
description: ""
date: 2023-11-14T22:59:31+08:00
tags:
    - Quantitative Finance
categories:  [ "Finance" ]
---

> 本文简单科普了什么是套利、有哪些套利方法、套利失效的原因

## 什么是套利

套利是指在无风险回报率之外获得确定的利润。 用量化金融的语言来说，我们 可以说套利机会是今天价值为零但未来价值为正的投资组合 的概率，并且未来为负值的概率为零。


市场上不存在套利机会的假设是经典金融理论的基础。这个想法是俗话说“天下没有免费的午餐”。

现在我们可以看到，我们可以想到几种套利方式。以下是最重要的几种套利的列表和说明。
+ 静态套利是一种无需重新平衡正向持仓的套利。
+ 动态套利是一种需要在未来进行交易的价差套利策略，通常取决于市场状况。
+ 统计套利并非套利，而只是根据过去的统计数据预测，可能获得超过无风险收益的利润（甚至可能根据承担的风险进行适当调整）。
+ 模型无关套利是一种不依赖于任何金融工具数学模型而发挥作用的套利。例如，可利用的对看跌期权平价的违反或对债券与掉期之间关系的违反
+ 依赖于模型的套利需要一个模型。例如，由于不正确的波动率估计，期权定价错误。为了从套利中获利，你需要delta对冲，这需要一个模型。


这有几个套利失效的原因
+ 报价错误或不可交易
+ 期权价格和股票价格没有同步报价
+ 存在您未计算在内的竞价价差
+ 你的模型是错误的，或者存在你没有考虑到的风险因素

## What Is Arbitrage 

Arbitrage is making a sure profit in excess of the risk-free rate of return. In the language of quantitative finance we 
can say that an arbitrage opportunity is a portfolio of zero value today which is of positive value in the future with positive
probability,and of negative value in the future with zero probability.
 

The assumption that there are no arbitrage opportunities in the market is fundamental to classical finance theory.This idea is
popularly known as 'there's no such thing as a free lunch.


Now we can see that there are several types of arbitrage that we can think of. Here is a list and description of the most important.

+ A static arbitrage is an arbitrage that does not require re-balancing of positives
+ A dynamic arbitrage is an arbitrage that requires trading instruments in the future,generally contingent on market states
+ A statistical arbitrage is not an arbitrage that but simply a likely profit in excess of the risk-free return (perhaps even suitably adjusted for risk taken) as predicted by past statistics
+ Model-independent arbitrage is an arbitrage which dose not depend on any mathematical model of financial instruments to work. For example, an exploitable violation of put-call parity or a violation of the relationship between bonds and swaps 
+ Model-dependent arbitrage dose require a model. For example, options mis-priced because of incorrect volatility estimate. To profit from the arbitrage you need to delta hedge, and that requires a model.

Here are several reasons for arbitrage fails

+ Quoted prices are wrong  or not tradeable
+ Option and stock prices were not quoted synchronously
+ There is a bid-off spread you have not accounted for
+ Your model is wrong, or there is  a risk factor you have not  accounted for


-------

[1] Wilmott，M 2009 Frequently Asked Questions In Quantitative Finance, second edition. John Wiley & Sons,Ltd.


> 欢迎扫码关注公众号，订阅更多文章!

![欢迎扫](/img/public-plantform-qr.png)