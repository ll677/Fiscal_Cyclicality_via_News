## Directions on how to run code for "Planning Ahead: Measuring Fiscal Cyclicality Through News"

### Requirements

Code run using Stata 15/IC. Packages ivreg2, ranktest, xtivreg2, and estout are necessary and installed automatically by the code.

### Data acquisition

#### IMF WEO forecasts: 
1. Go to the database page for any IMF WEO release (e.g. [here](https://www.imf.org/en/Publications/WEO/weo-database/2020/April))
2. Click on "Historical WEO Forecasts Database" in the related links box; the current link is [this](https://www.imf.org/external/pubs/ft/weo/data/WEOhistorical.xlsx)
3. Move to the working directory and make sure the file is saved as `WEOhistorical.xlsx`

#### IMF DOTS
1. Go to the [IMF DOTS database page](https://data.imf.org/?sk=9D6028D4-F14A-464C-A2F2-59B2CD424B85) and click on the bulk download button (currently in top right with an icon of an arrow pointing down into an upward-opening bracket)
2. Download the entire dataset with the format set to .csv and layout set to panel; this requires making a free account
3. Move to working directory and save data file as `EXIM.csv`

#### World Bank WDI
1. Access the World Bank WDI Databank [here](https://databank.worldbank.org/source/world-development-indicators#)
2. Selecting "World Development Indicators" as the database, make a query with a selection of all countries and aggregates, all available years, and the following variables:
- Net lending (+) / net borrowing (-) (% of GDP)
- Expense (% of GDP)
- Net investment in nonfinancial assets (% of GDP) 
- GDP growth (annual %)
- Interest payments (% of expense)
- Net barter terms of trade index (2000 = 100)
- Exports of goods and services (% of GDP)
3. Under the layout tab, set Time and Country to Row and Series to Column
4. Download the data from the query in .csv format and save in working directory as `WB_WDI_vars.csv`

### Running code

Open and run master.do after resetting the global rootdir variable to the working directory.
