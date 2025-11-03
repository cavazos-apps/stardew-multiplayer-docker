# Kubernetes Deployment Guide

## Steam Version with Runtime Authentication

The Steam version now supports runtime authentication, allowing you to build the Docker image without Steam credentials and provide them at container startup instead.

### Key Changes

- **No credentials needed during build**: The Docker image can be built without STEAM_USER, STEAM_PASS, or STEAM_GUARD
- **Runtime game download**: Game files are downloaded when the container first starts
- **Persistent storage**: Game data must be stored on a persistent volume mounted to `/data/Stardew/game`

### Kubernetes Manifest Example

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: stardew-game-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi  # Stardew Valley game files require ~1.5GB

---
apiVersion: v1
kind: Secret
metadata:
  name: steam-credentials
type: Opaque
stringData:
  STEAM_USER: "your_steam_username"
  STEAM_PASS: "your_steam_password"
  # STEAM_GUARD is optional if Steam Guard is disabled on the account
  # STEAM_GUARD: "ABC123"

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stardew-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: stardew
  template:
    metadata:
      labels:
        app: stardew
    spec:
      containers:
      - name: stardew
        image: your-registry/stardew-multiplayer-steam:latest
        env:
        - name: STEAM_USER
          valueFrom:
            secretKeyRef:
              name: steam-credentials
              key: STEAM_USER
        - name: STEAM_PASS
          valueFrom:
            secretKeyRef:
              name: steam-credentials
              key: STEAM_PASS
        - name: STEAM_GUARD
          valueFrom:
            secretKeyRef:
              name: steam-credentials
              key: STEAM_GUARD
              optional: true
        - name: SRCDS_APPID
          value: "413150"
        # Add other environment variables for mods configuration here
        - name: VNC_PASSWORD
          value: "insecure"
        - name: ENABLE_ALWAYSONSERVER_MOD
          value: "true"
        - name: ENABLE_AUTOLOADGAME_MOD
          value: "true"
        ports:
        - containerPort: 5900
          name: vnc
        - containerPort: 5800
          name: novnc
        - containerPort: 24642
          protocol: UDP
          name: game
        volumeMounts:
        - name: game-data
          mountPath: /data/Stardew/game
        - name: save-data
          mountPath: /config/xdg/config/StardewValley/Saves
      volumes:
      - name: game-data
        persistentVolumeClaim:
          claimName: stardew-game-pvc
      - name: save-data
        persistentVolumeClaim:
          claimName: stardew-saves-pvc  # Create separately

---
apiVersion: v1
kind: Service
metadata:
  name: stardew-service
spec:
  type: LoadBalancer
  selector:
    app: stardew
  ports:
  - name: vnc
    port: 5900
    targetPort: 5900
  - name: novnc
    port: 5800
    targetPort: 5800
  - name: game
    port: 24642
    targetPort: 24642
    protocol: UDP
```

### First Start Behavior

On the first container start:
1. The container detects that game files are missing
2. It authenticates with Steam using provided credentials
3. It downloads Stardew Valley game files to the persistent volume
4. It installs SMAPI mod loader
5. It copies configured mods to the game directory
6. The game starts normally

### Subsequent Starts

On subsequent starts, the container:
1. Detects that game files already exist in the persistent volume
2. Skips the download process
3. Starts the game immediately

### Important Notes

- **Persistent Volume Required**: You must mount a persistent volume to `/data/Stardew/game` or the game will re-download on every restart
- **Steam Guard**: If your Steam account has Steam Guard enabled, you need to disable it or provide the STEAM_GUARD environment variable with a current code
- **Storage Size**: Ensure your persistent volume has at least 2GB of storage for game files
- **First Start Time**: The first start will take several minutes to download the game (1.5GB+)
