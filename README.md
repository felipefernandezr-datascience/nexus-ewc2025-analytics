# 🎮 Nexus Esports Management & Analytics: EWC 2025 Investment Model

> **Ecosistema analítico de Inteligencia de Negocios fundamentado en datos históricos de la Esports World Cup (EWC) 2025 para la optimización de portafolios, adquisición de talento y maximización del Retorno de Inversión (ROI).**

---

## 📌 Descripción del Proyecto

Este proyecto aborda la necesidad estratégica de **Nexus Esports Management & Analytics** de estructurar un modelo de inversión empírico dentro de la industria de los deportes electrónicos. Utilizando la data masiva generada por la Esports World Cup 2025 (27 torneos, +100 millones de dólares en premios), se desarrolló una arquitectura de *Business Intelligence* *end-to-end* que resuelve dilemas críticos del negocio:
* Identificación de la estructura ideal de un club competitivo (Diversificación vs. Especialización).
* Optimización del proceso de *scouting* (Rendimiento histórico vs. Impacto mediático).
* Detección de ecosistemas altamente rentables ("Océanos Azules").

---

## 🏗️ Arquitectura de la Solución

El flujo de los datos fue diseñado para garantizar escalabilidad, trazabilidad e integridad referencial, dividido en cuatro capas principales:

1. **Extracción (Data Sourcing):** * Ingesta de datos crudos estructurados desde la plataforma Kaggle (Resultados oficiales de la EWC 2025).
   * Enriquecimiento de la data mediante **Web Scraping** para capturar la huella operativa global y el nivel de diversificación de los clubes participantes.
2. **Procesamiento y Limpieza (ETL):**
   * Desarrollo de *pipelines* en Python (Jupyter Notebooks) para la depuración algorítmica, imputación de nulos y homologación de entidades (Clubes, Jugadores, Torneos).
3. **Almacenamiento y Modelado (Data Warehouse):**
   * Migración automatizada a un entorno relacional en **SQL Server**.
   * Creación de un modelo lógico y vistas analíticas (`.sql`) para perfilar el riesgo y segmentar el mercado.
4. **Visualización y Capa Semántica (Business Intelligence):**
   * Conexión DirectQuery/Import a **Power BI**.
   * Desarrollo de medidas dinámicas mediante expresiones DAX para calcular el rendimiento financiero en tiempo real a través de 3 tableros interactivos.

---

## 🧠 Metodología CRISP-DM

El proyecto se ejecutó bajo el rigor del marco de trabajo *Cross-Industry Standard Process for Data Mining* (CRISP-DM), estructurado en 5 fases:

* **1. Comprensión del Negocio:** Definición de los objetivos de ROI, estructuración de las preguntas de negocio y evaluación de la viabilidad financiera.
* **2. Comprensión de los Datos:** Análisis exploratorio inicial (EDA) para auditar la calidad de los registros de la EWC y mapear las variables clave.
* **3. Preparación de los Datos:** Ejecución del pipeline ETL, cruce de llaves primarias/foráneas y recolección de variables externas (Scraping).
* **4. Modelado:** Construcción de la arquitectura relacional en SQL y la capa matemática (DAX) en Power BI.
* **5. Evaluación:** Despliegue de los tableros de control para contrastar los hallazgos empíricos contra las interrogantes de inversión iniciales.

---

## 📁 Estructura del Repositorio

El proyecto sigue una arquitectura de carpetas estandarizada para ingeniería de datos:

```text
nexus-ewc2025-analytics/
├── .github/workflows/    # Pipelines de CI/CD (GitHub Actions para Linting)
├── dashboards/           # Archivos de visualización (.pbix)
├── notebooks/            # Scripts de Python: ETL, EDA y Web Scraping (.ipynb)
├── sql_querys/           # Scripts de DDL, DML y Vistas analíticas (.sql)
├── requirements.txt      # Dependencias del entorno Python
└── README.md             # Documentación del proyecto