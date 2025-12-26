import json
import urllib.request
import os

# Configuration
# Defaults to your username, but can be overridden by env var
GITHUB_USERNAME = os.environ.get('GITHUB_USERNAME', 'yisak-mesifin')

def handler(event, context):
    print(f"Fetching projects for: {GITHUB_USERNAME}")
    
    # API Gateway (HTTP API) handles CORS based on Terraform config.
    # We only need to specify the content type here.
    headers = {
        "Content-Type": "application/json"
    }

    try:
        # Fetch 6 most recently updated repositories
        url = f"https://api.github.com/users/{GITHUB_USERNAME}/repos?sort=updated&per_page=6"
        
        # GitHub API requires a User-Agent header
        req = urllib.request.Request(url, headers={'User-Agent': 'AWS-Lambda-Portfolio'})
        
        with urllib.request.urlopen(req) as response:
            if response.status != 200:
                raise Exception(f"GitHub API returned {response.status}")
            
            data = json.loads(response.read().decode())
            
            projects = []
            for repo in data:
                # Skip forked repos to show only your original work
                # Remove this 'if' statement if you want to show forks too
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
        print(f"Error fetching projects: {str(e)}")
        return {
            "statusCode": 500,
            "headers": headers,
            "body": json.dumps({"error": "Failed to fetch projects from GitHub"})
        }