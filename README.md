# 🖥️ MiniCloud: Portainer Setup And Docker Stack Launcher

A simple, self-contained system to deploy and manage your favorite services using **Docker** and **Portainer**.

- Developed for Mac Mini
- **Attention** Not for production use, solemn for private local hosting in a safe network.

With this setup, you maintain **full control** over your services, keep everything isolated, and can deploy or update stacks with **just one script**.  



## 👷‍♂️ Todo
- [ ] Setup Caddy
- [ ] Setup Portal page



## 🌟 Features

- **Self-control & Simplicity**  
  Launch and manage your services locally without relying on external orchestrators or cloud providers.  
  All stacks live on your own machine, giving you full visibility and control.

- **Portainer Integration**  
  Deploys services in a way fully compatible with [Portainer](https://www.portainer.io/).  
  You can monitor, manage, and configure your stacks visually through the Portainer dashboard.

- **Persistent data to local disc**
  Volumes mounted to host, outside docker registry.

- **Automatic setup and deploy** 
  All stacks deploy automatically using `./deploy.sh` and attach to your existing Docker networks.  

- **Reusable Templates**  
  Docker Compose templates are preprocessed before deployment, replacing paths and environment variables automatically.  


## 🚀 Currently Deployed Stacks

| Emoji | Stack       | Description |
|-------|------------|-------------|
| 📁    | filebrowser | Web-based file manager |
| 🐙    | gitea       | Self-hosted Git service |
| 📓    | jupyter     | Interactive data science notebooks |
| 🥗    | mealie      | Personal recipe manager |
| ☁️    | nextcloud   | Private cloud storage & collaboration |
| 🧰    | redis       | High-performance key-value store |
| 📐    | sagemath    | Open-source mathematics system |



# ⚡ Quick Start

1. **Clone this repository**

```bash
git clone <your-repo-url>
cd <your-repo>
```

2. **Run the deploy script**
```bash
chmod +x deploy.sh
./deploy.sh
```
3. **Open Portainer**
Visit http://localhost:9000 (or your configured Portainer instance) to view and manage your stacks.

## 🔒 Why This Setup?
ou stay in control:
- No external dependencies beyond Docker.
- Easy to extend or customize
  - Add new stack templates in library/stack-templates.
- Compatible with Portainer, so you can visually manage networks, volumes, and containers.

## 📂 Structure
```
.
├── deploy.sh                   # Launches all stacks
├── stacks/                     # Processed YAML files for deployment
└── library/stack-templates/    # Stack templates
```

## 💡 Tips
- Customize .tpl files for your environment paths or secrets.
- Use Portainer to monitor logs, resource usage, and update stacks seamlessly.

## 🚀 Next Steps
- Add new stack templates for additional services
- Integrate automatic backups for Nextcloud, Mealie, and Gitea.
- Expand monitoring with Portainer alerts or Prometheus/Grafana.

## 🙋‍♂️ Pull Requests?
Sure!

