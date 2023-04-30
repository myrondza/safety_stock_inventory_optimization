
############################## PREPROCESSING TIMESERIES ############################

library(TSstudio)
library(forecast)
library(data.table)
library(xts)
library(tseries)


############################## GET DAILY DEMAND TIMESERIES ############################

df_daily <- read.csv("Demand.csv")
df_daily$date<-as.Date(df_daily$date, format="%Y-%m-%d")

df_daily<- xts(df_daily$Demand,order.by = df_daily$date,frequency = 1)
df_weekly <- period.apply(df_daily, INDEX = endpoints(df_daily, on = "weeks"), FUN = mean)
df_monthly<- period.apply(df_daily, INDEX = endpoints(df_daily, on = "months"), FUN = mean)


ts_seasonal(df_monthly, type = "box")

ts_seasonal(df_daily, type = "normal")
ts_seasonal(df_weekly, type = "normal")
ts_seasonal(df_monthly, type = "normal")


ts_surface(df_daily)
ts_surface(df_weekly)
ts_surface(df_monthly)

ts_heatmap(df_weekly)
ts_heatmap(df_monthly)

train_idx <- nrow(df_daily) *0.8

train_df <- df_daily[1:train_idx,]
test_df <- df_daily[-c(1:train_idx),]

train_df <- as.data.table(train_df)
test_df <- as.data.table(test_df)


############################## GET LEADTIME STATS IN DAYS ############################

start_date <- Sys.Date()
lead_time_dates <- seq.Date(from = start_date + 1, to = start_date + 10, by = "day")
lead_time_values <- c(10, 15, 20, 7, 5, 8, 9, 7, 6, 8)
lead_time_df <- data.frame(date = lead_time_dates, value = lead_time_values)


lead_time_min <- min(lead_time_df$value)
lead_time_max <- max(lead_time_df$value)
lead_time_sd <- sd(lead_time_df$value)
lead_time_avg <- mean(lead_time_df$value)

lead_time_summary <- data.frame(lead_time_min,lead_time_max,lead_time_sd,lead_time_avg)

############################## GET DEMAND STATS (PER DAY) ############################

demand_min <- min(train_df$V1)
demand_max <- max(train_df$V1)
demand_sd <- sd(train_df$V1)
demand_avg <- mean(train_df$V1)


demand_summary <- data.frame(demand_min,demand_max,demand_sd,demand_avg)


############################## GET SAFETY STOCK (NORMAL DISTRIBUTION ASSUMPTION) ############################

service_level= 0.95

# For Method 2,3,4 & 5 We assume the demand has a normal distribution 
# And for obtaining a 95% service level we can calculate safety stock as follows


calculate_z_score <- function(service_level) {
  # Calculate the z-score using the inverse cumulative distribution function (CDF) of the standard normal distribution
  z_score <- qnorm(service_level + ((1 - service_level) / 2))
  
  return(z_score)
}

calculate_safety_stock <- function(method,z_score,demand_summary,lead_time_summary) {
  
  ############################### Average - Max Method ###############################
  if (method == 1) 
  {ss <- ((lead_time_summary$lead_time_max * demand_summary$demand_max)-(lead_time_summary$lead_time_avg * demand_summary$demand_avg))
  return(ss)}
  
  ############################### Heizer and Render Method ###############################
  else if (method == 2) 
  {ss <- (z_score * demand_summary$demand_sd * sqrt(lead_time_summary$lead_time_avg))
  return(ss)}
  
  ############################### Greasley's Method ###############################
  else if (method == 3) 
  {ss <- (z_score * demand_summary$demand_avg * lead_time_summary$lead_time_sd)
  return(ss)}
  
  ############################### King's Method ###############################
  else if (method == 4) 
  {ss <- (z_score * (sqrt(lead_time_summary$lead_time_avg*(demand_summary$demand_sd)**2 +
                            ((demand_summary$demand_avg)**2 * (lead_time_summary$lead_time_sd**2)))))
  return(ss)}
  
  ############################### Alternative Method ###############################
  else if (method == 5) 
  {ss <- (z_score * demand_summary$demand_sd * sqrt(lead_time_summary$lead_time_avg))+
    (z_score * demand_summary$demand_avg * lead_time_summary$lead_time_sd)
  return(ss)}
  
  ############################### Default Method ###############################
  else
  {ss <- z_score * demand_summary$demand_avg * lead_time_summary$lead_time_sd
  return(ss)} 
}

z_score = calculate_z_score(service_level)

safetystock_summary_op <- data.frame()

for (i in 1:5){
  
  safety_stock = calculate_safety_stock(i,z_score,demand_summary,lead_time_summary)
  rop = safety_stock + (demand_summary$demand_avg * lead_time_summary$lead_time_avg)
  
  min_level = safety_stock + (demand_summary$demand_avg * lead_time_summary$lead_time_avg)
  max_level = rop + demand_summary$demand_max
  
  safetystock_summary <- data.frame(lead_time_summary,demand_summary,z_score,safety_stock,rop,min_level,max_level)
  
  safetystock_summary$method = i
  safetystock_summary_op <- rbind(safetystock_summary_op,safetystock_summary)
}


safetystock_summary_op



############################## GET SAFETY STOCK (NON-NORMAL DISTRIBUTION ASSUMPTION - NON PARAMETRIC) ############################

library(dplyr)
library(ggplot2) 
library(KernSmooth) 


############################### KDE Method ###############################

ggplot(train_df, aes(x = V1)) + 
  geom_histogram(binwidth = 10, fill = "steelblue", color = "blue") + 
  labs(x = "Demand", y = "Frequency", title = "Histogram of Demand")

density_est <- density(train_df$V1)

kde_est <- bkde(train_df$V1 ,kernel = "epanech",gridsize = 512)


ggplot(data.frame(x = density_est$x, y = density_est$y, z = kde_est$y), aes(x = x)) + 
  geom_line(aes(y = y), color = "steelblue") +
  geom_line(aes(y = z), color = "red") +
  labs(x = "Demand", y = "Density", title = "PDF and KDE of Demand")

qt<-quantile(kde_est$x,0.95)

safety_stock <- qt

rop = safety_stock + (demand_summary$demand_avg * lead_time_summary$lead_time_avg)

min_level = safety_stock + (demand_summary$demand_avg * lead_time_summary$lead_time_avg)
max_level = rop + demand_summary$demand_max

safetystock_summary_kde <- data.frame(lead_time_summary,demand_summary,z_score,safety_stock,rop,min_level,max_level)

############################## GET SAFETY STOCK (NON-NORMAL DISTRIBUTION ASSUMPTION - PARAMETRIC) ############################


############################### GARCH Method (WIP) ###############################

library(rugarch)

fit <- auto.arima(train_df$V1)
order <- arimaorder(fit)

spec <- ugarchspec(variance.model = list(model = "sGARCH", 
                   garchOrder = c(1, 1)),
                   mean.model = list(c(order[1],order[3])))

fit <- ugarchfit(spec, data = train_df$V1, solver.control = list(trace = 0))
forecast <- ugarchforecast(fit, n.ahead = 1)

qt<-quantile(forecast,0.95)

safety_stock <- qt[1]

rop = safety_stock + (demand_summary$demand_avg * lead_time_summary$lead_time_avg)

min_level = safety_stock + (demand_summary$demand_avg * lead_time_summary$lead_time_avg)
max_level = rop + demand_summary$demand_max

safetystock_summary_garch <- data.frame(lead_time_summary,demand_summary,z_score,safety_stock,rop,min_level,max_level)
