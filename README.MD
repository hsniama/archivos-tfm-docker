# 📦 Archivos del TFM - Evaluación de Prácticas de Seguridad en Docker

Este repositorio contiene los archivos generados durante el desarrollo del Trabajo de Fin de Máster (TFM) titulado:

**"Evaluación de prácticas de seguridad en Docker y su impacto en la protección de entornos de contenedores"**

En él se incluyen imágenes Docker hardenizadas, resultados de escaneos previos y posteriores, y una guía para probar las imágenes.

---

## 📁 Estructura del repositorio

### `/EscaneoInicial/`
Contiene los resultados de los escaneos de vulnerabilidades realizados **antes de aplicar el hardening**, tanto para:

- `devops-microservice`: imagen de proyecto personal.
- `nginx`: imagen oficial.
- `Docker Host`: entorno docker 

Incluye salidas de herramientas como:

- `Trivy`
- `Docker Scout`
- `Docker CIS benchmark`

---

### `/EscaneoPosterior/`
Contiene los resultados de escaneo **después de aplicar las prácticas de seguridad**, donde se evidencia una reducción de vulnerabilidades en las imágenes:

- `devops-microservice` hardenizado
- `nginx` hardenizado
- `Docker Host`: hardenizado

---

### `/ImagenesHardenizadas/`
Contiene las imágenes Docker exportadas en formato `.tar` listas para ser compartidas y probadas en otros entornos sin necesidad de reconstrucción.

- `nginx-hardened.tar`: Imagen de NGINX reforzada según el [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)

---

## 🚀 ¿Cómo usar las imágenes hardenizadas?

### 1. Descargar la imagen `.tar` y ubicala en tu equipo  si no descargalas directamente desde Docker Hub:
```bash
https://hub.docker.com/repositories/hsniama98
```

### 2. Cargar la imagen en Docker:

#### En Windows:
```bash
docker load -i C:\Users\TuUsuario\Descargas\nginx-hardened.tar
```

#### En Linux:
```bash
docker load -i /home/TuUsuario/Descargas/nginx-hardened.tar
```
#### Ejecutar el contenedor:
```bash
docker run -d --name nginx-secure -p 8080:8080 nginx-hardened
```
#### Verificar su funcionamiento:
```bash
curl http://localhost:8080/
```