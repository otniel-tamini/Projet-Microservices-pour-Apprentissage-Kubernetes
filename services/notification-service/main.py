from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from datetime import datetime
from typing import List, Optional
import os

app = FastAPI(title="Notification Service", version="1.0.0")

# Configuration CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Modèles de données
class NotificationCreate(BaseModel):
    userId: int
    message: str
    type: str = "general"

class Notification(BaseModel):
    id: int
    userId: int
    message: str
    type: str
    status: str = "unread"
    createdAt: datetime
    readAt: Optional[datetime] = None

# Données simulées
notifications = [
    Notification(
        id=1,
        userId=1,
        message="Bienvenue sur notre plateforme !",
        type="welcome",
        status="unread",
        createdAt=datetime.now(),
    ),
    Notification(
        id=2,
        userId=1,
        message="Votre commande #1 a été confirmée.",
        type="order_confirmed",
        status="read",
        createdAt=datetime.now(),
        readAt=datetime.now(),
    ),
    Notification(
        id=3,
        userId=2,
        message="Votre commande #2 a été expédiée.",
        type="order_shipped",
        status="unread",
        createdAt=datetime.now(),
    ),
]

@app.get("/health")
async def health():
    return {
        "status": "OK",
        "service": "notification-service",
        "timestamp": datetime.now()
    }

@app.get("/notifications", response_model=List[Notification])
async def get_notifications(userId: Optional[int] = None, status: Optional[str] = None):
    filtered_notifications = notifications.copy()
    
    if userId:
        filtered_notifications = [n for n in filtered_notifications if n.userId == userId]
    
    if status:
        filtered_notifications = [n for n in filtered_notifications if n.status == status]
    
    # Trier par date de création (plus récent en premier)
    filtered_notifications.sort(key=lambda x: x.createdAt, reverse=True)
    return filtered_notifications

@app.get("/notifications/{notification_id}", response_model=Notification)
async def get_notification(notification_id: int):
    notification = next((n for n in notifications if n.id == notification_id), None)
    if not notification:
        raise HTTPException(status_code=404, detail="Notification non trouvée")
    return notification

@app.post("/notifications", response_model=Notification)
async def create_notification(notification_data: NotificationCreate):
    new_notification = Notification(
        id=len(notifications) + 1,
        userId=notification_data.userId,
        message=notification_data.message,
        type=notification_data.type,
        status="unread",
        createdAt=datetime.now()
    )
    
    notifications.append(new_notification)
    print(f"📧 Nouvelle notification pour l'utilisateur {notification_data.userId}: {notification_data.message}")
    return new_notification

@app.patch("/notifications/{notification_id}/read")
async def mark_as_read(notification_id: int):
    notification = next((n for n in notifications if n.id == notification_id), None)
    if not notification:
        raise HTTPException(status_code=404, detail="Notification non trouvée")
    
    notification.status = "read"
    notification.readAt = datetime.now()
    return notification

@app.patch("/notifications/user/{user_id}/read-all")
async def mark_all_as_read(user_id: int):
    user_notifications = [n for n in notifications if n.userId == user_id and n.status == "unread"]
    
    for notification in user_notifications:
        notification.status = "read"
        notification.readAt = datetime.now()
    
    return {"message": f"{len(user_notifications)} notifications marquées comme lues"}

@app.delete("/notifications/{notification_id}")
async def delete_notification(notification_id: int):
    global notifications
    notification = next((n for n in notifications if n.id == notification_id), None)
    if not notification:
        raise HTTPException(status_code=404, detail="Notification non trouvée")
    
    notifications = [n for n in notifications if n.id != notification_id]
    return {"message": "Notification supprimée"}

@app.get("/notifications/user/{user_id}/stats")
async def get_user_notification_stats(user_id: int):
    user_notifications = [n for n in notifications if n.userId == user_id]
    
    total = len(user_notifications)
    unread = len([n for n in user_notifications if n.status == "unread"])
    read = total - unread
    
    types_count = {}
    for notification in user_notifications:
        types_count[notification.type] = types_count.get(notification.type, 0) + 1
    
    return {
        "userId": user_id,
        "total": total,
        "unread": unread,
        "read": read,
        "byType": types_count
    }

# Endpoint pour envoyer des notifications en masse
@app.post("/notifications/broadcast")
async def broadcast_notification(message: str, notification_type: str = "announcement"):
    # Récupérer tous les userId uniques
    user_ids = list(set([n.userId for n in notifications]))
    
    created_notifications = []
    for user_id in user_ids:
        new_notification = Notification(
            id=len(notifications) + len(created_notifications) + 1,
            userId=user_id,
            message=message,
            type=notification_type,
            status="unread",
            createdAt=datetime.now()
        )
        created_notifications.append(new_notification)
    
    notifications.extend(created_notifications)
    return {"message": f"Notification diffusée à {len(created_notifications)} utilisateurs"}

if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 3004))
    print(f"🚀 Notification Service démarré sur le port {port}")
    print(f"📊 Health check: http://localhost:{port}/health")
    print(f"📖 API docs: http://localhost:{port}/docs")
    uvicorn.run(app, host="0.0.0.0", port=port)
