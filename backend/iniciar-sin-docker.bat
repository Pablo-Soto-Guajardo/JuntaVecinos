@echo off
rem ==========================================================
rem  Inicia los 4 microservicios SIN Docker (solo Java 21 + MySQL)
rem  Requisitos:
rem   - MySQL encendido en localhost:3306, usuario root sin clave (XAMPP)
rem   - Los .jar ya compilados (carpetas target) -> build-all.bat
rem  Se abren 4 ventanas; para detener todo, cierralas.
rem ==========================================================
cd /d "%~dp0"

if defined JAVA_HOME (set "JAVA=%JAVA_HOME%\bin\java.exe") else (set "JAVA=java")

set "DB=jdbc:mysql://localhost:3306"

echo Iniciando ms-admin (9091)...
start "ms-admin" "%JAVA%" -jar ms-admin\target\ms-admin-0.0.1-SNAPSHOT.jar ^
  --spring.datasource.url=%DB%/bd_junta_admin?createDatabaseIfNotExist=true

echo Iniciando ms-reservas (9092)...
start "ms-reservas" "%JAVA%" -jar ms-reservas\target\ms-reservas-0.0.1-SNAPSHOT.jar ^
  --spring.datasource.url=%DB%/bd_junta_reservas?createDatabaseIfNotExist=true ^
  --api.base-url=http://localhost:9090

echo Iniciando ms-finanzas (9093)...
start "ms-finanzas" "%JAVA%" -jar ms-finanzas\target\ms-finanzas-0.0.1-SNAPSHOT.jar ^
  --spring.datasource.url=%DB%/bd_junta_finanzas?createDatabaseIfNotExist=true

echo Iniciando api-gateway (9090)...
start "api-gateway" "%JAVA%" -jar api-gateway\target\api-gateway-0.0.1-SNAPSHOT.jar ^
  --spring.cloud.gateway.routes[0].uri=http://localhost:9091 ^
  --spring.cloud.gateway.routes[1].uri=http://localhost:9091 ^
  --spring.cloud.gateway.routes[2].uri=http://localhost:9092 ^
  --spring.cloud.gateway.routes[3].uri=http://localhost:9093

echo.
echo Listo. Espera 1 minuto y abre http://localhost:9090/reservas/dependencias
