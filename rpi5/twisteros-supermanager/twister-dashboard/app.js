// app.js - Twister Dashboard backend (Express)
// Umístění: ~/twisteros_supermanager/twister-dashboard/app.js

const express = require('express');
const fs = require('fs');
const path = require('path');
const multer = require('multer');
const { exec, spawn } = require('child_process');
const fetch = require('node-fetch');

const app = express();
const PORT = 8080;

const ROOT = path.resolve(__dirname, '..');
const DASH_DATA = path.join(__dirname, 'data');
const PLUGIN_DIR = path.join(ROOT, 'plugins');
const LOG_FILE = path.join(ROOT, 'logs', 'plugin.log');
const STATUS_FILE = path.join(__dirname, 'data', 'plugin_status.json');

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(__dirname)); // servíruje index.html, style.css, ai.js ...

// ---------- helpery ----------
function safeJsonRead(filePath, defaultObj = {}) {
  try { return JSON.parse(fs.readFileSync(filePath, 'utf8') || '{}'); }
  catch (e) { return defaultObj; }
}
function safeWriteJson(filePath, obj) {
  fs.writeFileSync(filePath, JSON.stringify(obj, null, 2));
}

// ---------- STATUS a LOG ----------
app.get('/status', (req, res) => {
  const s = safeJsonRead(STATUS_FILE, {});
  res.json(s);
});

app.get('/log', (req, res) => {
  if (fs.existsSync(LOG_FILE)) res.type('text/plain').send(fs.readFileSync(LOG_FILE, 'utf8'));
  else res.send('');
});

// ---------- METRICS ----------
app.get('/metrics', async (req, res) => {
  // CPU load (%), memory usage (free/total), uptime, temp (pokud dostupné)
  const os = require('os');
  const totalMem = os.totalmem();
  const freeMem = os.freemem();
  const usedMem = totalMem - freeMem;
  const memPercent = Math.round((usedMem / totalMem) * 100);

  // CPU load jako 1-min load přepočtený na % dle jader
  const cpus = os.cpus().length;
  const load = os.loadavg()[0]; // 1 min
  const cpuPercent = Math.round((load / cpus) * 100);

  // uptime
  const uptime = os.uptime();

  // teplota - pokus o vcgencmd (RPi), fallback null
  let temp = null;
  try {
    const out = require('child_process').execSync('vcgencmd measure_temp').toString().trim();
    const m = out.match(/temp=([\d\.]+)/);
    if (m) temp = parseFloat(m[1]);
  } catch (e) {
    temp = null;
  }

  res.json({
    cpuPercent,
    memPercent,
    uptime,
    temp
  });
});

// ---------- PLUGIN management ----------
function pluginPath(name) {
  // přijímáme název souboru (např. plugin-conky.sh)
  return path.join(PLUGIN_DIR, name);
}

function writeLog(line) {
  const l = `[${new Date().toISOString()}] ${line}\n`;
  fs.appendFileSync(LOG_FILE, l);
}

// start / stop / restart pluginy (start -> spustí plugin s parametrem start, atd.)
app.post('/plugin/:action', (req, res) => {
  const action = req.params.action; // start/stop/restart
  const plugin = req.body.plugin;
  if (!plugin) return res.status(400).json({ error: 'plugin required' });

  const p = pluginPath(plugin);
  if (!fs.existsSync(p)) return res.status(404).json({ error: 'plugin not found' });

  // spouštíme v shellu - pluginy by měly podporovat start|stop|status|cli
  exec(`bash "${p}" ${action}`, { env: process.env }, (err, stdout, stderr) => {
    if (err) {
      writeLog(`PLUGIN ${plugin} ${action} ERR: ${err.message}`);
      return res.status(500).json({ ok: false, error: err.message, stdout, stderr });
    }
    writeLog(`PLUGIN ${plugin} ${action} OK`);
    // aktualizuj status JSON (zjednodušení: pokud start -> running, stop->inactive)
    const status = safeJsonRead(STATUS_FILE, {});
    if (action === 'start') status[plugin] = 'running';
    else if (action === 'stop') status[plugin] = 'inactive';
    else if (action === 'restart') status[plugin] = 'running';
    safeWriteJson(STATUS_FILE, status);
    res.json({ ok: true, stdout, stderr });
  });
});

// ---------- UPLOAD PLUGIN ----------
const upload = multer({ dest: path.join(__dirname, 'tmp_upload') });
app.post('/plugin/upload', upload.single('file'), (req, res) => {
  if (!req.file) return res.status(400).send('file missing');
  const orig = req.file.originalname;
  const tmp = req.file.path;
  const dest = path.join(PLUGIN_DIR, orig);
  fs.renameSync(tmp, dest);
  fs.chmodSync(dest, 0o755);
  writeLog(`PLUGIN UPLOAD: ${orig}`);
  // přidej do status JSON jako inactive
  const status = safeJsonRead(STATUS_FILE, {});
  status[orig] = 'inactive';
  safeWriteJson(STATUS_FILE, status);
  res.json({ ok: true, file: orig });
});

// ---------- AI proxy endpoint ----------
app.post('/api/ai', async (req, res) => {
  try {
    const prompt = req.body.prompt || '';
    // Prefer local AI server
    const LOCAL = 'http://127.0.0.1:7070/api';
    const OPENAI_KEY = process.env.OPENAI_API_KEY || null;

    // zkus lokální
    try {
      const r = await fetch(LOCAL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ prompt })
      });
      if (r.ok) {
        const j = await r.json();
        return res.json({ response: j.response || j.result || JSON.stringify(j) });
      }
    } catch (e) {
      // nepodařilo se s lokálním, pokračujeme k OpenAI pokud klíč existuje
    }

    if (OPENAI_KEY) {
      // jednoduchý proxy volání na OpenAI ChatCompletion (GPT-4o/gpt-4)
      const openaiResp = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${OPENAI_KEY}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          model: 'gpt-4o-mini', // můžeš upravit
          messages: [{ role: 'user', content: prompt }],
          max_tokens: 800
        })
      });
      const j = await openaiResp.json();
      const text = j.choices && j.choices[0] && (j.choices[0].message?.content || j.choices[0].text) ? (j.choices[0].message?.content || j.choices[0].text) : JSON.stringify(j);
      return res.json({ response: text });
    }

    // fallback
    res.json({ response: 'Žádný lokální AI server nenalezen a OPENAI_API_KEY není nastaven.' });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: String(e) });
  }
});

// ---------- START SERVER ----------
app.listen(PORT, () => {
  console.log(`🌐 Twister Dashboard backend běží na http://localhost:${PORT}`);
});
