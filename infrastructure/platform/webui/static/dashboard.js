async function loadStats() {
    const response = await fetch("/api/stats");
    const data = await response.json();

    document.getElementById("cpu").innerText = "CPU: " + data.cpu + "%";
    document.getElementById("ram").innerText = "RAM: " + data.ram + "%";
    document.getElementById("disk").innerText = "Disk: " + data.disk + "%";
    document.getElementById("uptime").innerText = "Uptime: " + data.uptime;
}

setInterval(loadStats, 3000);
window.onload = loadStats;
