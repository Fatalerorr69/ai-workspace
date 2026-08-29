`version: '3.8'`

`services:`  
  `# Centrální správa kontejnerů`  
  `portainer:`  
    `image: portainer/portainer-ce:latest`  
    `container_name: genesis-portainer`  
    `restart: always`  
    `ports:`  
      `- "9000:9000"`  
    `volumes:`  
      `- /var/run/docker.sock:/var/run/docker.sock`  
      `- portainer_data:/data`

  `# Webové rozhraní pro interakci s modely Ollama`  
  `open-webui:`  
    `image: ghcr.io/open-webui/open-webui:main`  
    `container_name: genesis-webui`  
    `restart: always`  
    `ports:`  
      `- "3000:8080"`  
    `extra_hosts:`  
      `- "host.docker.internal:host-gateway"`  
    `volumes:`  
      `- open-webui:/app/backend/data`  
      `- ${HOME}/genesis/vault:/app/backend/data/docs:ro # RAG propojení s Vaultem`

`volumes:`  
  `portainer_data:`  
  `open-webui:`  
