/* jslint esversion: 6 */
/* jslint node: true */

/* global  WebSocket , Highcharts  */

/*
 * bit22 chart
 */

'use strict';

let MYAPP = {
   width: 800,
   height: 600,
   last: 0,
   len: 25000
};

function getBaseURL () {
   var href = window.location.href.substring(7); // strip "http://"
   var idx = href.indexOf('/');
   return 'ws://' + href.substring(0, idx);
}

Highcharts.setOptions({
   time: {
      // timezone: 'Europe/Rome',
      useUTC: false
   }
});

/**
 * Grafico forza-spostamento
 */
function renderChart () {
   MYAPP.chart  = Highcharts.chart('container', {
      chart: {
         zoomType: 'xy',
         resetZoomButton: {
            position: {x: -50, y: 50},
            relativeTo: 'chart'
         },

         //width: MYAPP.width,
         //height: MYAPP.height
      },
      title: {
         text: 'Live Data (CSV)'
      },

      subtitle: {
         text: 'Data input from a remote CSV file'
      },
      yAxis: [
         {
            title: {
               text: 'Force'
            },
            labels: {
               format: '{value}mN'
            },
            lineWidth: 2
         }
      ],
      series: [
         { name: 'S0', data: [] },
         { name: 'S1', data: [] },
         { name: 'S2', data: [] },
         { name: 'S3', data: [] },
         { name: 'S4', data: [] },
      ]
   });
}

function connectChartAdd () {
   let wsUri = getBaseURL() + '/chart_add_ws';
   console.log('uri: ' + wsUri);

   let sock = new WebSocket(wsUri);

   sock.onmessage = function (msg) {
      var msgJson = JSON.parse(msg.data);
      MYAPP.last += msgJson[0].length;
      addSeries(msgJson);
   };
   sock.onopen = function () {
      sock.send(JSON.stringify({action: 'rqs', last: MYAPP.last, len: 20000}));
      window.setInterval(function () {
         sock.send(JSON.stringify({action: 'rqs', last: MYAPP.last, len: 1000}));
      }, 500);
   };
   sock.onclose = function () {
      sock.send(JSON.stringify({action: 'close'}));
   };
}

function connectChartSet () {
   let wsUri = getBaseURL() + '/chart_set_ws';
   console.log('uri: ' + wsUri);

   let sock = new WebSocket(wsUri);

   sock.onmessage = function (msg) {
      var msgJson = JSON.parse(msg.data);
      MYAPP.last += msgJson[0].length;
      setSeries(msgJson);
   };

   sock.onopen = function () {
      window.setInterval(function () {
         sock.send(JSON.stringify({action: 'rqs', last: MYAPP.last, len: 50}));
      }, 500);
   };
   sock.onclose = function () {
      sock.send(JSON.stringify({action: 'close'}));
   };
}



/*
 * Imposta i punti di tutte le serie di un grafico.
 *
 * L'oggetto res e' un array cosi fatto
 * ---------------
 *  [ S0, S1, ...Sn-1]
 * ---------------
 * 
 * res[i] conincide con Si e
 * ciascun elemento Sk e' un array:
 *
 * ---------------
 *  [ [x0, y0], [x1,y1], [x2,y2]....]
 * ---------------
 *
 * Params:
 *  id = id del grafico
 *  res = array con i punti della serie. Ogni elemento rappresenta una serie
 */
function addSeries (res) {
   let c = MYAPP.chart;

   if (c && res !== null) {
      var seriesSize = Math.min(res.length, c.series.length);
      for (let i = 0; i < seriesSize; i++) {
         for (let j = 0; j < res[i].length; j++) {
            c.series[i].addPoint(res[i][j], false);
         }
      }
       c.redraw(false);
   } else {
      console.log('setSeries: series is null');
   }
}

function setSeries (res) {
   let c = MYAPP.chart;
  if (c && res !== null) {
    var seriesSize = Math.min(res.length, c.series.length);
    for (let i = 0; i < seriesSize; i++) {
      // setData(data [, redraw] [, animation] [, updatePoints])
      c.series[i].setData(res[i], false, false, true);
    }
    // c.hideLoading();
    c.redraw(false);
  } else {
    console.log('setSeries: series is null');
  }
}

