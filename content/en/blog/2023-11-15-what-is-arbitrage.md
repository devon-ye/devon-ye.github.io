---
title: 'What Is Arbitrage'
keywords: [Arbitrage,Quantitative Finance]
description: "A brief generalization of what arbitrage is, what arbitrage methods are available, and why arbitrage fails."
author:      "Devean"
date: 2023-11-15T22:59:31+08:00
tags:        ["Quantitative Finance"]
categories:  [ "Finance" ]
thumbnail: "/img/202308/2023080506.jpg"
---

> This paper briefly introduces what is arbitrage, what are the arbitrage methods and the reasons why arbitrage fails.


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


> Welcome to scan the code to pay attention to the public number, subscribe to more articles!

![欢迎扫](/img/public-plantform-qr.png)