async function api(path, method='GET', body=null){
  const API_BASE = "http://127.0.0.1:5001";
  const API_KEY = "REPLACE_WITH_STRONG_KEY";
  const opts = { method, headers: { 'X-API-KEY': API_KEY } };
  if(body){ opts.headers['Content-Type']='application/json'; opts.body=JSON.stringify(body); }
  const res = await fetch(API_BASE + path, opts);
  return res.json();
}

async function mountNAS(){
  const r = await api('/run', 'POST', { script: 'mount_nas' });
  console.log(r);
  alert(JSON.stringify(r, null, 2));
}

document.getElementById('btnMountNAS').onclick = mountNAS;
