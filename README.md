# NSE data

This repository contains daily price data from [The CSCS site](http://www.cscsnigeriaplc.com/web/guest/dailypricelist). All duplicate dates have been removed. Dates are in WAT.

The Ruby and R scripts used to download and update the data are in the `script` directory.

## Data
The stock prices (open, close) are in the [price](https://github.com/ogennadi/nse-data/tree/master/price) directory. Bonuses (e.g. 1 for 3) are in the [bonus](https://github.com/ogennadi/nse-data/tree/master/bonus) directory. Dividends (Close date and amount) are in the [dividend](https://github.com/ogennadi/nse-data/tree/master/dividend) directory. 
