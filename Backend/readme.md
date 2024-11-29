## Installation

1. Install the dependencies:
```bash
pip install -r requirements.txt
```

2. Configure Qdrant and Supabase as per their respective documentation.

3. Run the application:
```bash
gunicorn --bind 0.0.0.0:5001 main:app
```

> Note : the SUPABASE_KEY should be the Supabase Service Key