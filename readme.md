# PersonaBot

## Project Overview

This project consists of a mobile application for iOS, developed in Swift, paired with a Python-based backend leveraging Retrieval-Augmented Generation (RAG) using OpenAI's ChatGPT, facilitated by LlamaIndex. The primary goal of this application is to empower users to create and customize bots with unique parameters and distinct knowledge bases, tailored to their specific needs.

---

## Features

### iOS Application
- **User-Friendly Interface:** Intuitive UI for creating and managing bots.
- **Customization Options:** Adjust bot parameters such as tone, personality, and response style.
- **Knowledge Base Management:** Upload and manage knowledge bases to tailor each bot’s expertise.
- **Cloud Synchronization:** Securely store and retrieve bot configurations and knowledge bases from the backend.
- **Real-Time Interaction:** Test and interact with the bots directly within the app.

> Actually, Config.swift backend url is actually online so you can just launch the application.

### Python Backend
- **RAG with OpenAI ChatGPT:** Combines powerful natural language understanding with efficient knowledge retrieval using LlamaIndex.
- **Dynamic Bot Generation:** Create bots dynamically based on user-defined parameters.
- **Knowledge Base Integration:** Supports various formats (e.g., text, PDFs, and more) for knowledge base ingestion.
- **Scalability:** Designed to handle multiple users and bots concurrently.
- **API Integration:** Exposes endpoints for creating, managing, and querying bots.

---

## Tech Stack

### Frontend (iOS Application)
- Language: Swift

### Backend
- Language: Python
- Frameworks: Flask
- ML Model: OpenAI ChatGPT (integrated for RAG via LlamaIndex)
- Storage: Supabase
- Deployment: Docker, Coolify

---

## Installation

### Prerequisites
- macOS with Xcode installed (for iOS app)
- Python 3.9+ (for backend)
- Docker (optional, for containerized deployment of backend)

### Frontend (iOS App)
1. Clone the repository.
2. Open the `.xcodeproj` file in Xcode.
3. Update the `API_BASE_URL` in the app’s configuration to point to your backend.
4. Build and run the application on an iOS device or simulator.

### Backend

1. Install the dependencies:
```bash
pip install -r requirements.txt
```

2. Configure Qdrant and Supabase as per their respective documentation.

3. Run the application:
```bash
gunicorn --bind 0.0.0.0:5001 main:app
```
