function sendAI() {
    let p = document.getElementById("prompt").value;

    fetch("/api/ai", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ prompt: p })
    })
    .then(res => res.text())
    .then(data => {
        document.getElementById("output").innerText = data;
    });
}
