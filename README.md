# MiniCloud: Docker Stack Launcher

A simple, self-contained system to deploy and manage your favorite services using **Docker** and **Portainer**.  

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

🏋🏿‍♂️ You need more? 🔱 Fork me and submit a pull request!

- **Reusable Templates**  
  Docker Compose templates are preprocessed before deployment, replacing paths and environment variables automatically.  

---

## ⚡ Quick Start

1. **Clone this repository**

```bash
git clone <your-repo-url>
cd <your-repo>
```

2. **Run the deploy script**
```bash
./deploy.sh
```
