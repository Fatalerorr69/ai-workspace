async function api(path, method="GET"){
  const API = "http://127.0.0.1:5001";
  const KEY = "REPLACE_WITH_SECURE_KEY";
  let res = await fetch(API + path, {headers:{'X-API-KEY':KEY}});
  return res.json();
}

async function detectMHS(){
  alert("Detekován: " + (await api("/display/status")).detected);
}

async function setupMHS(){
  alert(JSON.stringify(await api("/display/setup", "POST"), null, 2));
}

async function testMHS(){
  alert(JSON.stringify(await api("/display/test"), null, 2));
}

document.getElementById("btnMHSDetect").onclick = detectMHS;
document.getElementById("btnMHSSetup").onclick = setupMHS;
document.getElementById("btnMHSTest").onclick = testMHS;
