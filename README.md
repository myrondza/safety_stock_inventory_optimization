# Empirical Safety Stock Estimation for Inventory Optimization.

Managing a supply chain involves making decisions under imperfect or unknown information. Uncertainty in the supply chain can arise from various sources, including demand uncertainty, supply uncertainty, and production uncertainty. Addressing these challenges requires finding the right balance between service level, stock holding, and safety stock.

Demand uncertainty refers to the risk of customers not buying products as forecasted. This can be due to factors such as changing consumer preferences, unexpected events, and economic conditions. When demand is uncertain, companies need to hold safety stock to buffer against unexpected fluctuations.
Demand uncertainty can be further categorized into smooth vs. volatile demand. Smooth demand occurs when the forecasted volume is close to the actual demand, requiring a smaller safety stock to maintain the same service level. In contrast, volatile demand occurs when the forecasted volume is often far from the actual demand, requiring a larger safety stock to maintain the same service level.

Supply uncertainty refers to the risk of suppliers not delivering goods on time. This can be due to factors such as geopolitical events, last-minute orders, transportation delays, weather conditions, vehicle breakdowns, driver shortages, and trade barriers. When suppliers are unreliable, companies need to hold more safety stock to ensure that they can meet customer demand in case of unexpected delays.
Supplier reliability is another factor that affects safety stock. When suppliers are reliable and deliver goods on time, companies can hold smaller safety stock. In contrast, when suppliers are unreliable and frequently deliver goods late, companies need to hold larger safety stock to ensure that they can meet customer demand in case of unexpected delays.

Production uncertainty refers to the risk of not having enough production capacity to meet demand. This can be due to factors such as raw material shortages, production defects, maintenance, strikes, energy costs, labor shortages, and machine breakdowns. When production is unreliable, companies need to hold more safety stock to ensure that they can meet customer demand in case of unexpected shortages.
Lead times also affect safety stock. When lead times are shorter, companies can hold smaller safety stock. In contrast, when lead times are longer, companies need to hold larger safety stock to ensure that they can meet customer demand in case of unexpected delays.
In summary, managing uncertainty in the supply chain requires finding the right balance between service level, stock holding, and safety stock. This involves analyzing historic forecast errors and the volatility of demand, assessing supplier and production reliability, and considering lead times. By doing so, companies can optimize their inventory management and ensure that they have enough inventory on hand to meet customer demand while minimizing the risk of stockouts.


### Assuming the Deamand / Forecast Error Distribution is a Normal Distribution then Safety Stock is calculated as follows :

1) Average - Max Method :

`Safety Stock  =  (lead_time_max * demand_max)-(lead_time_avg * demand_avg)`

  
2) Heizer and Render Method :
 
`Safety Stock  = z_score * demand_sd * sqrt(lead_time_avg)`

3) Greasley's Method :

`Safety Stock  = z_score * demand_avg * lead_time_sd`
  
4) King's Method :

`Safety Stock  = z_score * (sqrt(lead_time_avg*(demand_sd)**2 + ((demand_avg)**2 * (lead_time_sd**2))))`
  
5) Alternative Method :

`Safety Stock  = (z_score * demand_sd * sqrt(lead_time_avg))+ (z_score * demand_avg * lead_time_sd)`


Here, z_score is computed as follows : (As the normal distribution is symmetric in nature we need to tweak the formula to account for both the tails.)
`z_score <- qnorm(service_level + ((1 - service_level) / 2))`

z_score is the number of standard deviations required to achieve the desired service level.

qnorm or ppf : ** Probability Point Function**`(or Inverse Cumulative Distribution Function) 

The graph on the left denotes that for a given x value the respective cdf(x) value is input to the ppf function, and ppf returns once again the original x value.

This formula calculates the stock level needed to maintain a certain service level. It multiplies the Z-score of the service level by the standard deviation of demand.

SKU Last and SKU Specific are two factors that increase demand uncertainty, and therefore require a higher safety stock. Additionally, increasing the target service level will also require a larger safety stock to cover against outlier events. When calculating the appropriate safety stock size, it's important to consider historic forecast errors and the volatility of demand. This can be done by analyzing the forecast error distribution and using the KDE method to create a smooth curve, which is then converted into percentiles to determine the corresponding safety stock.

### Assuming the Demand / Forecast Error Distribution is not Normally Distributed then Safety Stock is calculated as follows : (Real World Cases)

### Non-parametric method

When demand /forecast errors are not normally distributed, using the standard deviation to calculate safety stock may not be appropriate. In such cases, we can use a `non-parametric method`, such as kernel density estimation (KDE), to estimate the probability density function of the forecast errors and then use this distribution to calculate safety stock.

1) KDE Method :
KDE is a method that estimates the probability density function of a random variable based on a set of observations. It works by placing a `Kernel`, which is a probability density function, at each observation and then summing the kernels to obtain an estimate of the underlying density function.

### Parametric method

### Assuming the Forecast Error Distribution is not Normally Distributed then Safety Stock is calculated as follows : (Real World Cases)

1) GARCH Method :
The GARCH (Generalized Autoregressive Conditional Heteroskedasticity) model is a popular time-series model used for estimating volatility and forecasting future values of a time series. It can also be used to estimate the standard deviation of forecast errors for safety stock calculation.

## Reorder Point

`ROP = Average Demand + Safety Stock`

ROP stands for Reorder Point, and it is the inventory level at which an order needs to be placed to avoid a stockout. The Safety Stock is added to the average demand to determine the ROP. The Safety Stock acts as a buffer against demand and supply uncertainties, ensuring that there is enough inventory to meet customer demand in case of unexpected fluctuations. A higher Safety Stock will result in a higher ROP, which means that orders will need to be placed more frequently to maintain inventory levels.

## Min Max Levels

If your stock drops below this point then you need to reorder more so you’re not at risk of stocking out.

`Min Level = ROP`

Max Level is the order up to amount. Order enough stock so that you’ll have enough net stock

`Max Level = Forecast Demand in Review Period + Min Level`
