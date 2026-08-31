async function api(path, method='GET', body=null){
  const API_BASE = "http://127.0.0.1:5001";
  const API_KEY = "REPLACE_WITH_STRONG_KEY";
  const opts = { method, headers: { 'X-API-KEY': API_KEY } };
  if(body){ opts.headers['Content-Type']='application/json'; opts.body=JSON.stringify(body); }
  const res = await fetch(API_BASE + path, opts);
  return res.json();
}

async function syncROMs(){ alert(JSON.stringify(await api('/run','POST',{script:'sync_roms'}),null,2)); }
async function syncBIOS(){ alert(JSON.stringify(await api('/run','POST',{script:'sync_bios'}),null,2)); }
async function importROMs(){ alert(JSON.stringify(await api('/run','POST',{script:'import_roms'}),null,2)); }

document.getElementById('btnSyncROMs').onclick = syncROMs;
document.getElementById('btnSyncBIOS').onclick = syncBIOS;
document.getElementById('btnImportROMs').onclick = importROMs;
