
# Read in data
df <- read.csv("./Historical Product Demand.csv", stringsAsFactors = F, header = T)

# Convert Date column to date type
df$Date <- as.Date(df$Date, "%Y/%m/%d")

# Extract month from Dtae
df$Month <- as.Date(paste0(substr(df$Date, 1, 7), "-01"), "%Y-%m-%d")

# Remove any records with invalid date
df <- df[!is.na(df$Month), ]


# Convert Order Demand to numeric
# Convert certain demands to negative: (10) -> -10
df$Order_Demand_New <- as.numeric(trimws(gsub("\\)", "", gsub("\\(", "", df$Order_Demand))))
df$Order_Demand_New <- ifelse(grepl("\\(", df$Order_Demand), df$Order_Demand_New*(-1), df$Order_Demand_New)

# Aggregate by Month
library('plyr')
agg_df <- ddply(df, c("Product_Code", "Warehouse", "Product_Category"), function(x) {
  # Get all months during the period when the product - warehouse is sold
  months <- data.frame('Month' = seq(min(x$Month), max(x$Month), by = "month"))
  
  # Calculate total order by month
  group_data <- ddply(x, "Month", function(y) 
    data.frame('Total_Demand' = sum(y$Order_Demand_New), 'Number_Orders' = nrow(y)))
  
  # Merge all possible months - we will replace values with 0 when they are NA
  # This ensures we don't skip any months
  group_data <- merge(group_data, months, all.x = T, all.y = T)
}, .progress = "text")

# Convert NA's to 0 - no demand occurred in that month
agg_df$Total_Demand <- ifelse(is.na(agg_df$Total_Demand), 0, agg_df$Total_Demand)
agg_df$Number_Orders <- ifelse(is.na(agg_df$Number_Orders), 0, agg_df$Number_Orders)

# Export file to csv
write.csv(agg_df, file = "./Monthly_Product_Demand.csv", row.names = F)

