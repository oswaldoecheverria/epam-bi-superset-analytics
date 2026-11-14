# Bitácora de Trabajo - Superset EPAM

> **Ubicación:** `F:\proyectos\superset-epam`  
> **Inicio de sesión:** 13 de noviembre de 2026, 18:48 ECT  
> **Objetivo:** Registro continuo y resiliente de actividades, comandos, configuraciones y avances ante imprevistos (cortes de luz, reinicios, apagones).

---

## 📌 Estado Actual del Proyecto
- **Directorio de trabajo:** `F:\proyectos\superset-epam`
- **Archivos iniciales detectados:**
  - `Query maestro final - global.docx`
  - Carpeta `imagenes/`
- **Estado:** Inicialización de entorno y preparación de bitácora.

---

## 📝 Registro Cronológico de Actividades

### [2026-11-13 18:48 ECT] — Inicialización y Setup
- Reconocimiento del directorio `F:\proyectos\superset-epam`.
- Creación de este archivo de bitácora (`BITACORA.md`) como punto de recuperación ante fallos de energía o reinicio del equipo.

### [2026-11-13 20:15 ECT] — Análisis Forense de Datos, Imágenes y CV
- **Lectura del Currículum (`cv-oswaldo-echeverria.html`):**
  - Rol: *Analista de Business Intelligence & Datos* (Feb 2024 – Jun 2024) en EPAM.
  - Hito: Diseño de solución con Apache Superset, detección de anomalías críticas de cartera y presentación ejecutiva a la directiva institucional.
- **Análisis de Capturas del Dashboard (`imagenes/01.png` a `07.png`):**
  - `01.png` & `02.png`: Pestaña *Indicadores de Deudas y Pagos* (8.33k contratos facturables, 40.7k deudas por $1.76M, $428k recaudados, 35.36% pagos anticipados, 80.36% cobro de facturas, morosidad 19.64%, días promedio de mora 70 vs días de pago 43.4).
  - `03.png`: Pestaña *KPIs de Tendencias Temporales* (MoM con sparklines).
  - `04.png` & `05.png`: Pestaña *KPIs Análisis mensuales* (Líneas y barras de evolución 2023-12 a 2024-06, cruce crítico donde la morosidad supera el recaudo en abr-2024).
  - `06.png` & `07.png`: Pestaña *KPIs Análisis por Tipo de consumo* (Residencial, Comercial, Industrial). Insight clave: el sector Industrial representa <1% en volumen transaccional pero acumula el 35% del monto de deuda total con un ciclo de pago de 74 días.
- **Recuperación del Query Maestro (`Query maestro final - global.docx`):**
  - Extracción y formateo limpio en `sql/kpis_recaudacion_maestro.sql` con 23 métricas estadísticas (agregaciones, desviación estándar, percentiles, ratios).
- **Protección de Datos Privados / LOPDP:**
  - Los datos reales se protegen y ofuscan. El repositorio público en GitHub se estructurará como un caso de estudio de ingeniería de datos y BI de alto nivel (arquitectura, queries reproducibles con mock schema, dashboards, storytelling e impacto).

### [2026-11-13 20:25 ECT] — Creación del Entorno Completo y Vista Previa HTML
- **Organización de Recursos Visuales:**
  - Imágenes normalizadas y copiadas con nombres descriptivos a `assets/images/` (`01-kpis-deudas-pagos.png` a `07-analisis-industrial-vs-comercial.png`).
- **Scripts Técnicos y Reproducibilidad:**
  - `sql/kpis_recaudacion_maestro.sql`: Query maestro limpio con 23 KPIs y agregaciones estadísticas.
  - `sql/schema_mock.sql`: DDL de base de datos (`portalepam_mock`) con datos sintéticos respetando la LOPDP para reproducibilidad en GitHub.
- **Documentación Técnica:**
  - `docs/FICHA_TECNICA.md`: Metodología y diccionario de los 23 KPIs.
  - `README.md`: Storytelling corporativo formal (modelo STAR: Situación, Tarea, Acción, Resultados), diagramas Mermaid, arquitectura, capturas incrustadas, hallazgos de negocio (el fenómeno del sector industrial) y agradecimientos institucionales.
### [2026-11-13 20:34 ECT] — Correcciones de Roles, Arquitectura y Tono de Negocio
- **Corrección de Roles (100% Desarrollo Técnico por Oswaldo Echeverría):**
  - Clarificación contundente de la autoría: Oswaldo Echeverría como *Lead Data Engineer, BI Analyst & Desarrollador Principal* (responsable de la arquitectura técnica, extracción de datos de producción `portalepam`, modelado analítico, query maestro SQL, configuración/despliegue de Apache Superset y diseño de todos los tableros).
  - Wellington Alcívar asignado formalmente como *Documentación Técnica & Co-investigador* (redacción documental académica y compilación del marco referencial).
- **Ajuste de Precisión en Impacto Institucional (Cero Suposiciones):**
  - Se eliminaron todas las aseveraciones de que EPAM "tomó acción inmediata sobre los datos".
  - Se reenfocó en el **valor analítico entregado y demostrado**: diagnóstico cuantitativo, detección de patrones invisibles (concentración de deuda en sector industrial), identificación de discrepancias entre abonos y facturas, y reducción del tiempo de reportería a menos de 2 segundos.
- **Optimización del Diagrama de Arquitectura:**
  - Rediseño del flujo de horizontal comprimido (`LR`) a vertical jerárquico estructurado (`TD`).
  - Configuración explícita en `preview.html` (`mermaid.initialize` con tema oscuro base, `htmlLabels: true` y padding proporcional) para evitar texto cortado o distorsionado tanto en local como en GitHub.

### [2026-11-13 20:40 ECT] — Preparación de Repositorio Público y Licencia
- **Definición de Nombre Canónico:** `epam-bi-superset-analytics`.
- **Licencia Creada:** `LICENSE` bajo estándar **MIT (Copyright 2024 Oswaldo Echeverría)**, garantizando atribución obligatoria de autoría y exención de responsabilidad.
- **Configuración Git:** Creación de `.gitignore` para exclusión de archivos temporales de sistema.

---

## 📋 Tareas Pendientes / Próximos Pasos
- [x] Extraer e interpretar query maestro y capturas de Superset.
- [x] Generar DDL sintético reproducible (LOPDP Compliant).
- [x] Redactar `README.md` profesional para GitHub con storytelling de alto impacto.
- [x] Crear visor `preview.html` y validar correcciones de roles y diagrama.
- [x] Crear archivo de licencia `LICENSE` (MIT) y `.gitignore`.
- [ ] Inicialización de Git en local (`git init`, `git add`, `git commit`).
- [ ] Creación y vinculación del repositorio en GitHub (`git remote add origin ...`, `git push -u origin main`).
