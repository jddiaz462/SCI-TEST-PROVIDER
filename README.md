
# SCI – Provider CRUD (Backend + Frontend)

Este repositorio contiene la solución a la prueba técnica solicitada.  
El objetivo del proyecto es demostrar habilidades en backend, uso de SQL Stored Procedures, consumo de API y un frontend básico en Angular.

---

## 📌 Descripción General

El proyecto está dividido en tres partes principales:

- **Backend:** API desarrollada en .NET CORE 10 que implementa un CRUD usando Stored Procedures en SQL Server.
- **Frontend:** Aplicación Angular que consume la API y permite gestionar proveedores.
- **Database:** Script SQL para crear la tabla de proveedores y los Stored Procedures.

---

## 📂 Estructura del Repositorio
/
├── backend/        -> .NET API
├── frontend/       -> Angular application
├── database/       -> SQL scripts (tables + stored procedures)
└── README.md

---

## 1) Prerrequisitos

### Backend
- .NET SDK 8 / 9 / 10
- SQL Server (LocalDB, Express, Developer o superior)
- SQL Server Management Studio (SSMS)

### Frontend
- Node.js (versión LTS recomendada)
- Angular CLI
  
---

## 2) Configuración de la Base de Datos (SQL Server)

### ⚠️ Importante
La base de datos es un **prerrequisito obligatorio**.  
Debe crearse  **antes de ejecutar el backend**.

### Pasos

1. Abrir **SQL Server Management Studio (SSMS)**.
2. Ejecutar el script ubicado en la siguiente ruta: /database/init.sql

Este script realiza las siguientes acciones:
- Crea la tabla `Providers`
- Crea todos los Stored Procedures necesarios para las operaciones CRUD
- Maneja validaciones y control de errores a nivel de base de datos

---

## 3) Configuración del Backend (.NET API)

### 3.1 Configurar la conexión a la base de datos

Una vez creada la base de datos, se debe configurar la cadena de conexión en el archivo: /backend/appsettings.json

Ejemplo:

```json
{
  "ConnectionStrings": {
    "DBConnection": "Server=localhost;Database=SCICustomers;Trusted_Connection=True;TrustServerCertificate=True;"
  }
}
```
Asegúrese de que:

El nombre de la base de datos sea correcto
El servidor SQL corresponda a su entorno local
El método de autenticación sea válido


 ## Flujo rápido para probar el proyecto
- Ejecutar el script database/init.sql
- Configurar la cadena de conexión en appsettings.json
- Ejecutar el backend .NET
- Configurar la URL del API en environment.ts
- Ejecutar el frontend Angular
- Probar las operaciones CRUD desde la interfaz de usuario
