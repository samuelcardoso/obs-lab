const express = require("express");
const bodyParser = require("body-parser");
const prom = require("prom-client");

const app = express();
app.use(bodyParser.json());

// --- métricas Prometheus (registrar antes das rotas) ---
const register = new prom.Registry();
prom.collectDefaultMetrics({ register });

const httpRequests = new prom.Counter({
  name: "http_requests_total",
  help: "Total de requisições",
  labelNames: ["route","method","code"]
});
register.registerMetric(httpRequests);

app.use((req,res,next)=>{
  res.on("finish", ()=>{
    httpRequests.inc({ route: req.path, method: req.method, code: res.statusCode });
  });
  next();
});
// --------------------------------------------------------

// health/readiness
app.get("/healthz", (_,res)=>res.send("ok"));
app.get("/readyz",  (_,res)=>res.send("ready"));

// endpoint funcional
app.post("/reply", (req,res)=>{
  const messages = req.body?.messages || [];
  const lastUser = [...messages].reverse().find(m=>m.role==='user');
  const reply = lastUser
    ? `Você disse: "${lastUser.content}". (resposta simulada)`
    : "Oi! Como posso ajudar?";
  res.json({ reply });
});

// endpoint de métricas
app.get("/metrics", async (_,res)=>{
  res.set("Content-Type", register.contentType);
  res.end(await register.metrics());
});

const port = process.env.PORT || 3000;
app.listen(port, ()=> console.log(`chat-reply (obs) on ${port}`));
