module livedata.chart;

import std.experimental.logger;
import vibe.data.json : Json, parseJsonString;
import vibe.http.websockets : WebSocket;
import vibe.web.web;
import std.datetime.stopwatch : StopWatch, AutoStart;

enum BLK = 50_000;
final class ChartController {
   private ChartModel chartModel;
   private StopWatch timerAdd;
   private StopWatch timerSet;

   this(ChartModel chartModel) {
      assert(chartModel !is null);
      this.chartModel = chartModel;
      timerAdd.start;
      timerSet.start;
   }

   @path("chart") void getChart() {
      render!("chart.dt");
   }
   @path("chart2") void getChart2() {
      render!("chart2.dt");
   }

   /**
    * Gestore del websocket
    *
    * Dal websocket si riceve un messaggio json cosi fatto (graffe e virgolette omesse)
    * --------------------
    * action: rqs|close
    * --------------------
    *
    * In caso di $(I rqs), il metodo pompa nel socket un array di punti di tutte le serie.
    * Un punto e' una coppia x-y $(I p: [x,y]), una serie e' un array di punti $(I s: [p0, p1 ..]): nel socket e' inviato un array di serie $(I [s0, s1..])
    *
    * Il risultato finale e' qualcosa del tipo:
    *
    * --------------------
    * [
    *   [ [x0, a0],  [x1, a1],  [x2, a2] ...], //serie 0
    *   [ [x0, b0],  [x1, b1],  [x2, b2] ...], //serie 1
    *   ...
    * ]
    * --------------------
    *
    * Params:
    *  socket = Socket collegato
    *  _id = Id del grafico: e' l'id della tabella chart (1, 2 etc)
    */
   @path("chart_ws") void getPullDataIntoSocket(scope WebSocket socket) {
      trace("Chart - connect", );
      timerSet.reset;

      while (true) {
         try {
            if (!socket.connected) {
               break;
            }
            string message = socket.receiveText();
            Json j = parseJsonString(message);

            if (j["action"].get!string == "rqs") {
               int last = j["last"].get!int;
               int len = j["len"].get!int;
               if (last <= BLK) {
                  tracef("setData %sms last %s",  timerSet.peek.total!"msecs", last);
                  timerSet.reset;
                  string data = chartModel.getData(last, len);
                  socket.send(data);
               }
            } else if (message == "close") {
               trace("Chart FD - close");
               break;
            }
         } catch (Exception e) {
            errorf("Chart FD - %s", e.msg);
         }
      }
      trace("Chart FD - disconnect");
   }
   @path("chart_ws2") void getPullDataIntoSocket2(scope WebSocket socket) {
      trace("Chart2 - connect", );

      while (true) {
         try {
            if (!socket.connected) {
               break;
            }
            string message = socket.receiveText();
            Json j = parseJsonString(message);

            if (j["action"].get!string == "rqs") {
               tracef("setData %s", timerSet.peek.total!"msecs");
               timerSet.reset;
               string data = chartModel.getData(0, BLK);
               socket.send(data);
            } else if (message == "close") {
               trace("Chart FD - close");
               break;
            }
         } catch (Exception e) {
            errorf("Chart FD - %s", e.msg);
         }
      }
      trace("Chart FD - disconnect");
   }
}

class ChartModel {
   private string getData(int last, int len) {
      import std.random;
      auto rnd = Random(unpredictableSeed);

      Json table = Json.emptyArray;
      enum SERIES = 5;
      foreach (s; 0 .. SERIES) {
         Json jrow = Json.emptyArray;
         foreach (i; 0 .. len) {
            Json  jA = Json.emptyArray;
            jA ~= last + i;
            jA ~= uniform(0, 100, rnd);
            jrow.appendArrayElement(jA);
         }
         table.appendArrayElement(jrow);
      }
      return table.toString();
   }
}
