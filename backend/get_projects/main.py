import json
import urllib.request
import os

# Configuration
GITHUB_USERNAME = os.environ.get('GITHUB_USERNAME', 'yisak-mesifin') # Default or Env Var

def handler(event, context):
    print("Fetching projects for:", GITHUB_USERNAME)
    
    headers = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
    }

    try:
        url = f"https://api.github.com/users/{GITHUB_USERNAME}/repos?sort=updated&per_page=6"
        
        # Create request with User-Agent (Required by GitHub API)
        req = urllib.request.Request(url, headers={'User-Agent': 'AWS-Lambda-Portfolio'})
        
        with urllib.request.urlopen(req) as response:
            if response.status != 200:
                raise Exception(f"GitHub API returned {response.status}")
            
            data = json.loads(response.read().decode())
            
            # Filter and Format Data for Frontend
            projects = []
            for repo in data:
                # Skip forked repos if you want original work only
                if not repo['fork']:
                    projects.append({
                        "id": repo['id'],
                        "name": repo['name'],
                        "description": repo['description'] or "No description provided.",
                        "html_url": repo['html_url'],
                        "language": repo['language'],
                        "stars": repo['stargazers_count']
                    })

        return {
            "statusCode": 200,
            "headers": headers,
            "body": json.dumps(projects)
        }

    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            "statusCode": 500,
            "headers": headers,
            "body": json.dumps({"error": "Failed to fetch projects"})
        }