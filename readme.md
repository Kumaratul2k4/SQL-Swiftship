# SQL SwiftShip Logistics

SwiftShip Logistics is a SQL-based data analytics project designed to track and analyze the performance of various shipping partners. The project involves creating a relational database, inserting sample shipping data, and running complex analytical queries to evaluate logistics efficiency.

## 📌 Project Overview

The primary goal of this project is to manage shipment data and evaluate the performance of delivery partners (e.g., BlueDart, DTDC, Delhivery, Ekart). It achieves this by calculating delivery success rates, identifying delayed shipments, and finding high-volume delivery zones.

## 🗄️ Database Schema

The database `swiftship_database` consists of three core tables:

1. **`Partner`**: Stores details about the shipping partners.
   - `p_id`: Primary Key
   - `partner_name`: Name of the logistics partner
2. **`Shipment`**: Tracks individual shipment records.
   - `s_id`: Primary Key
   - `trk_no`: Unique Tracking Number
   - `p_id`: Foreign Key linking to `Partner`
   - `Ordered_Date` & `Promised_date`: Expected timelines
   - `Destination_city`: Delivery location
   - `Status`: Current state ('In Transit', 'Delivered', 'Returned', 'Lost')
3. **`DeliveryLogs`**: Logs the actual delivery dates for completed shipments.
   - `log_id`: Primary Key
   - `s_id`: Foreign Key linking to `Shipment`
   - `actual_delivery_date`: Date the shipment reached the customer

## 📊 Analytical Reports

The SQL script automatically generates several analytical tables/reports using advanced SQL features like `JOIN`s, aggregations, conditional statements (`CASE`), and window functions (`DENSE_RANK()`).

* **Report 1: Delayed Shipments (`DelayedShipments`)**
  Identifies all shipments delivered past their promised date and calculates the exact number of days they were late.
* **Report 2: Partner Performance (`PartnerPerformance`)**
  Calculates the success rate (Delivered vs. Total Shipments) for each partner and ranks them accordingly.
* **Report 3: Zone Filter (`ZoneFilter`)**
  Finds the destination city with the highest volume of orders placed in the last 30 days.
* **Report 4: Partner Scorecard (`Partnercorecard`)**
  Evaluates partners based on their delay rate. Partners are ranked to highlight the most reliable logistics provider (Rank 1).

## 🚀 How to Run

1. Make sure you have a MySQL environment installed and running (e.g., MySQL Workbench, XAMPP, or CLI).
2. Open the `SQL-SwiftShip/swiftship_logistics.sql` file.
3. Execute the entire script. It will automatically:
   - Drop and recreate the `swiftship_database`.
   - Create the necessary tables.
   - Insert the mock data.
   - Generate and display the analytical reports.

## 📁 Repository Structure

```text
SQL-SwiftShip_Project/
│
├── SQL-SwiftShip/
│   └── swiftship_logistics.sql    # Main SQL script containing schema, data, and queries
│
└── readme.md                      # Project documentation
```
