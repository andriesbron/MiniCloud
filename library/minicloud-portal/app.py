from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
import httpx
import os


app = FastAPI()

# Configuration - set these as environment variables
PORTAINER_URL = os.getenv("PORTAINER_URL", "http://localhost:9000")
PORTAINER_API_TOKEN = os.getenv("PORTAINER_API_TOKEN", "")
PORTAINER_ENDPOINT_ID = os.getenv("PORTAINER_ENDPOINT_ID", "1")
# dns-sd -G v4 localhost
# Icon mapping for known stacks (using emoji as fallback)
STACK_ICONS = {
    "filebrowser": "📁",
    "gitea": "🐙",
    "jupyter": "📓",
    "mealie": "🥗",
    "nextcloud": "☁️",
    "redis": "🧰",
    "sagemath": "📐"
}

# Stack descriptions
STACK_DESCRIPTIONS = {
    "filebrowser": "Web-based file manager",
    "gitea": "Self-hosted Git service",
    "jupyter": "Interactive data science notebooks",
    "mealie": "Personal recipe manager",
    "nextcloud": "Private cloud storage & collaboration",
    "redis": "High-performance key-value store",
    "sagemath": "Open-source mathematics system"
}

async def get_portainer_stacks():
    """Fetch stacks from Portainer API"""
    if not PORTAINER_API_TOKEN:
        # Return mock data if no API token is configured
        return [
            {"Name": "filebrowser", "Id": 1, "EndpointId": 1},
            {"Name": "gitea", "Id": 2, "EndpointId": 1},
            {"Name": "jupyter", "Id": 3, "EndpointId": 1},
            {"Name": "mealie", "Id": 4, "EndpointId": 1},
            {"Name": "nextcloud", "Id": 5, "EndpointId": 1},
            {"Name": "redis", "Id": 6, "EndpointId": 1},
            {"Name": "sagemath", "Id": 7, "EndpointId": 1}
        ]
    
    try:
        print(f"Fetching from Portainer: {PORTAINER_URL}")
        async with httpx.AsyncClient() as client:
            headers = {"X-API-Key": PORTAINER_API_TOKEN}
            response = await client.get(
                f"{PORTAINER_URL}/api/stacks",
                headers=headers,
                timeout=10.0
            )
            response.raise_for_status()
            return response.json()
    except Exception as e:
        print(f"Error fetching from Portainer: {e}")
        return []

def get_stack_url(stack_name: str) -> str:
    """Generate URL for stack (customize based on your setup)"""
    # This is a placeholder - adjust based on your actual service URLs
    port_mapping = {
        "filebrowser": "8080",
        "gitea": "3000",
        "jupyter": "8888",
        "mealie": "9925",
        "nextcloud": "8081",
        "redis": "6379",  # Redis doesn't have a web UI
        "sagemath": "8888"
    }
    
    port = port_mapping.get(stack_name.lower(), "80")
    # Adjust this to your actual domain/IP
    return f"http://localhost:{port}"

@app.get("/", response_class=HTMLResponse)
async def home(request: Request):
    stacks = await get_portainer_stacks()
    
    # Build app cards
    app_cards = []
    for stack in stacks:
        name = stack.get("Name", "Unknown")
        icon = STACK_ICONS.get(name.lower(), "📦")
        description = STACK_DESCRIPTIONS.get(name.lower(), "Application")
        url = get_stack_url(name)
        
        app_cards.append(f"""
            <a href="{url}" class="app-card" target="_blank">
                <div class="app-icon">{icon}</div>
                <div class="app-name">{name}</div>
                <div class="app-description">{description}</div>
            </a>
        """)
    
    html_content = f"""
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>App Portal</title>
        <style>
            * {{
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }}
            
            body {{
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                padding: 40px 20px;
                color: #333;
            }}
            
            .container {{
                max-width: 1200px;
                margin: 0 auto;
            }}
            
            h1 {{
                color: white;
                text-align: center;
                margin-bottom: 50px;
                font-size: 2.5rem;
                text-shadow: 0 2px 4px rgba(0,0,0,0.2);
            }}
            
            .app-grid {{
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
                gap: 30px;
                padding: 20px;
            }}
            
            .app-card {{
                background: rgba(255, 255, 255, 0.95);
                border-radius: 20px;
                padding: 25px 20px;
                text-decoration: none;
                color: inherit;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                transition: all 0.3s ease;
                box-shadow: 0 4px 6px rgba(0,0,0,0.1);
                cursor: pointer;
                min-height: 180px;
            }}
            
            .app-card:hover {{
                transform: translateY(-5px);
                box-shadow: 0 8px 15px rgba(0,0,0,0.2);
                background: white;
            }}
            
            .app-icon {{
                font-size: 4rem;
                margin-bottom: 15px;
                line-height: 1;
            }}
            
            .app-name {{
                font-weight: 600;
                font-size: 1.1rem;
                margin-bottom: 8px;
                text-align: center;
                color: #333;
            }}
            
            .app-description {{
                font-size: 0.85rem;
                color: #666;
                text-align: center;
                line-height: 1.3;
            }}
            
            .refresh-btn {{
                position: fixed;
                bottom: 30px;
                right: 30px;
                background: white;
                border: none;
                border-radius: 50%;
                width: 60px;
                height: 60px;
                font-size: 1.5rem;
                cursor: pointer;
                box-shadow: 0 4px 12px rgba(0,0,0,0.2);
                transition: all 0.3s ease;
            }}
            
            .refresh-btn:hover {{
                transform: rotate(180deg);
                box-shadow: 0 6px 16px rgba(0,0,0,0.3);
            }}
            
            @media (max-width: 768px) {{
                .app-grid {{
                    grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
                    gap: 20px;
                }}
                
                h1 {{
                    font-size: 2rem;
                }}
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 MiniCloud Applications</h1>
            <div class="app-grid">
                {''.join(app_cards)}
            </div>
        </div>
        
        <button class="refresh-btn" onclick="location.reload()" title="Refresh">
            🔄
        </button>
    </body>
    </html>
    """
    
    return HTMLResponse(content=html_content)

@app.get("/api/stacks")
async def api_stacks():
    """API endpoint to get stacks as JSON"""
    stacks = await get_portainer_stacks()
    return {"stacks": stacks}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8600)