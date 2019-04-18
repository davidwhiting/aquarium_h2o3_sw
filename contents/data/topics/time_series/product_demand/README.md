# Product Demand

### Goal

The dataset contains the order demand for different products per manufacturing warehouse.  There are 4 different warehouse locations.  The goal is to forecast the demand for each product a month in advanced.  This would allow the manufacturing company enough time to ship the product to the specified warehouse in anticipation of the demand.

The goal is described in more detail here: <https://www.kaggle.com/felixzhao/productdemandforecasting/home>


### Data Cleaning

The raw data consists of the total demand by product, warehouse, and date.  Since our goal is to forecast the demand by product and warehouse one month in advanced, we aggregated the data by month.  We also cleaned the `Order_Demand` column by converting numbers with parentheses to negatives (ex: `(10)` -> `-10`).

**Steps**

1. Extract month from date
2. Convert `Order_Demand` to numeric
3. Calculate the total `Order_Demand` and number of orders per product, warehouse, and month.
4. Months where no orders took place had a Total Demand and Number of Orders equal to 0.

### References

* Original Dataset: <https://www.kaggle.com/felixzhao/productdemandforecasting>