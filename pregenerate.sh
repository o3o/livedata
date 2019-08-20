# Script richiamato da DUB per generare i file di supporto
# semantic ui 

mkdir -p public
mkdir -p public/js
mkdir -p public/css


# highchart
HC=./node_modules/highcharts
cp -up $HC/highcharts.js ./public/js
cp -up $HC/highcharts.js.map ./public/js
cp -up $HC/modules/solid-gauge.js ./public/js
cp -up $HC/modules/exporting.js ./public/js
cp -up $HC/modules/exporting.js.map ./public/js

# jQuery
JQ=./node_modules/jquery
cp -up $JQ/dist/jquery.min.js ./public/js

# javascript
mkdir -p public/js
uglifyjs -b -o public/js/livedata.js js/livedata.js
uglifyjs -b -o public/js/chart.js js/chart.js

# css
#mkdir -p public/css
#cp css/*.* public/css

## img
#mkdir -p public/img
#cp img/*.png public/img
#cp img/favicon.ico public/
