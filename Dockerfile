# 1. Imagen base ligera de Python
FROM python:3.9-slim

# 2. Directorio de trabajo dentro del contenedor
WORKDIR /app

# 3. Copiamos los archivos necesarios
# (Primero copiamos requirements si tuvieramos)
COPY main.py .

# 4. Instalamos dependencias
RUN pip install fastapi uvicorn

# 5. Comando para arrancar la app
# --host 0.0.0.0 es OBLIGATORIO en contenedores para que sea accesible desde fuera
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]