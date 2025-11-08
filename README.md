# MiniCloud: Docker Stack Launcher

A simple, self-contained system to deploy and manage your favorite services using **Docker** and **Portainer**.

Developed for Mac Mini, but I guess it might work on other systems as well, because, it is just Docker...

With this setup, you maintain **full control** over your services, keep everything isolated, and can deploy or update stacks with **just one script**.  

---

## 🌟 Features

- **Self-control & Simplicity**  
  Launch and manage your services locally without relying on external orchestrators or cloud providers.  
  All stacks live on your own machine, giving you full visibility and control.  

- **Portainer Integration**  
  Deploys services in a way fully compatible with [Portainer](https://www.portainer.io/).  
  You can monitor, manage, and configure your stacks visually through the Portainer dashboard.  

- **Automatic Stack Deployment**  
  Currently supports deploying the following stacks:

  | Stack       | Status |
  |------------|--------|
  | filebrowser | ✅ Simple web-based file manager. |
  | gitea       | ✅ Self-hosted Git service. |
  | jupyter     | ✅ Interactive notebooks for data science. |
  | mealie      | ✅ Personal recipe manager. |
  | nextcloud   | ✅ Private cloud storage and collaboration. |
  | redis       | ✅ High-performance key-value store. |
  | sagemath    | ✅ Open-source mathematics software system. |

- **Reusable Templates**  
  Docker Compose templates are preprocessed before deployment, replacing paths and environment variables automatically.  

🏋🏿‍♂️ You need more? 🔱 Fork me and submit a pull request!
---

## ⚡ Quick Start

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
You stay in control — no external dependencies beyond Docker.
Easy to extend or customize — add new stack templates in library/stack-templates.
Compatible with Portainer, so you can visually manage networks, volumes, and containers.

## 📂 Structure
.
├── deploy.sh                # Launches all stacks
├── stacks/                  # Processed YAML files for deployment
└── library/stack-templates/ # Stack templates

## 💡 Tips
- Customize .tpl files for your environment paths or secrets.
- Use Portainer to monitor logs, resource usage, and update stacks seamlessly.

## 🚀 Next Steps
- Add new stack templates for additional services.
- Integrate automatic backups for Nextcloud, Mealie, and Gitea.
- Expand monitoring with Portainer alerts or Prometheus/Grafana.