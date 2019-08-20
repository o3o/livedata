import std.experimental.logger;
import vibe.data.json;
import vibe.http.fileserver;
import vibe.http.router;
import vibe.web.web;

shared static this() {
   import std.functional : toDelegate;
   import std.process : environment;
   import std.conv : to;
   import std.format : format;
   import livedata.chart;


   auto router = new URLRouter;
   auto indexM = new ChartModel();
   router.registerWebInterface(new ChartController(indexM));
   router.get("*", serveStaticFiles("./public/",));

   auto settings = new HTTPServerSettings;
   settings.port = 8080;
   settings.bindAddresses = ["::1", "127.0.0.1"];
   trace("start listen");
   try {
      auto l = listenHTTP(settings, router);
   } catch (Exception e) {
      errorf("app listenHTTP error: %s", e.msg);
      throw e;
   }
}
