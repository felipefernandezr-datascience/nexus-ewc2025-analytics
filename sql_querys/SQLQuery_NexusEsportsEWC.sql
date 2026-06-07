USE NexusEsportsEWC;
GO

/* ====================================================================================
   SCRIPT DE AUDITORÍA Y ANÁLISIS DE NEGOCIO (BI)
   Descripción: Este script contiene las consultas oficiales para validar la calidad 
                de los datos tras el proceso ETL y extraer insights estratégicos 
                del modelo relacional NexusEsportsEWC.
==================================================================================== */

/* ------------------------------------------------------------------------------------
   BLOQUE 1: ASEGURAMIENTO DE LA CALIDAD DE DATOS (DATA QUALITY & QA)
   Objetivo: Garantizar la integridad, volumetría y unicidad del modelo relacional.
------------------------------------------------------------------------------------ */

/* 1.1. Auditoría General de Volumetría (Conteo de Registros)
   Objetivo: Validar de un vistazo rápido que todas las tablas maestras y transaccionales 
             hayan sido pobladas exitosamente durante el pipeline ETL.
   Resultado Esperado: Un listado de las 6 tablas principales con un total de registros > 0.
*/
SELECT 'Club_Standings' AS 'Table', COUNT(*) AS 'Total' FROM Club_Standings
UNION
SELECT 'Clubs' AS 'Table', COUNT(*) AS 'Total' FROM Clubs
UNION
SELECT 'Medalists' AS 'Table', COUNT(*) AS 'Total' FROM Medalists
UNION
SELECT 'Players' AS 'Table', COUNT(*) AS 'Total' FROM Players
UNION
SELECT 'Tournaments' AS 'Table', COUNT(*) AS 'Total' FROM Tournaments
UNION
SELECT 'Club_Divisions' AS 'TABLE', COUNT(*) AS 'Total' FROM Club_Divisions;
GO

/* 1.2. Auditoría de Integridad Referencial (Detección de Huérfanos)
   Objetivo: Confirmar que el cruce y filtrado realizado en Python (pandas) fue exitoso. 
             Se verifica que ningún registro en la tabla intermedia apunte a un club o torneo inexistente.
   Resultado Esperado: 0 filas devueltas (Indicador de integridad referencial perfecta).
*/
SELECT 
    cd.Organization_Name, 
    cd.Game_Title
FROM 
    Club_Divisions cd
LEFT JOIN 
    Clubs c ON cd.Organization_Name = c.Organization_Name
LEFT JOIN 
    Tournaments t ON cd.Game_Title = t.Game_Title
WHERE 
    c.Organization_Name IS NULL OR t.Game_Title IS NULL;
GO

/* 1.3. Detección de Duplicados Lógicos (Violación de Llave Primaria)
   Objetivo: Asegurar que una misma organización no esté inscrita dos veces en el mismo videojuego.
   Resultado Esperado: 0 filas devueltas (Indicador de unicidad respetada).
*/
SELECT 
    Organization_Name, 
    Game_Title, 
    COUNT(*) AS Frecuencia
FROM 
    Club_Divisions
GROUP BY 
    Organization_Name, 
    Game_Title
HAVING 
    COUNT(*) > 1;
GO


/* ------------------------------------------------------------------------------------
   BLOQUE 2: INTELIGENCIA DE NEGOCIO (BUSINESS ANALYTICS)
   Objetivo: Extraer insights estratégicos y responder preguntas clave del negocio.
------------------------------------------------------------------------------------ */

/* 2.1. Nivel de Diversificación: Top Clubes con Mayor Participación
   Valor de Negocio: Permite a los inversionistas identificar cuáles son las organizaciones 
                     con mayor despliegue competitivo, poder financiero y compromiso 
                     dentro del ecosistema del mundial.
*/
SELECT TOP 10
    c.Organization_Name,
    c.Region,
    COUNT(cd.Game_Title) AS Total_Divisiones_Participantes
FROM 
    Clubs c
INNER JOIN 
    Club_Divisions cd ON c.Organization_Name = cd.Organization_Name
GROUP BY 
    c.Organization_Name,
    c.Region
ORDER BY 
    Total_Divisiones_Participantes DESC;
GO

/* 2.2. Termómetro del Ecosistema: Los Videojuegos más Populares
   Valor de Negocio: Ayuda a los organizadores y patrocinadores a entender qué títulos 
                     generan mayor tracción, atrayendo a la mayor cantidad de clubes. 
                     Útil para futuras asignaciones de "Prize Pools" (Premios).
*/
SELECT 
    t.Game_Title,
    t.Game_Type,
    COUNT(cd.Organization_Name) AS Clubes_Inscritos
FROM 
    Tournaments t
INNER JOIN 
    Club_Divisions cd ON t.Game_Title = cd.Game_Title
GROUP BY 
    t.Game_Title,
    t.Game_Type
ORDER BY 
    Clubes_Inscritos DESC;
GO

/* 2.3. Matriz de Penetración de Mercado por Región y Género
   Valor de Negocio: Cruza geografía y tipo de juego para revelar tendencias de mercado. 
                     Responde a dudas estratégicas como: "¿Las organizaciones asiáticas 
                     invierten más en juegos Mobile o en Shooters?". 
*/
SELECT 
    c.Region,
    t.Game_Type,
    COUNT(DISTINCT c.Organization_Name) AS Clubes_Unicos,
    COUNT(cd.Game_Title) AS Total_Inscripciones
FROM 
    Club_Divisions cd
INNER JOIN 
    Clubs c ON cd.Organization_Name = c.Organization_Name
INNER JOIN 
    Tournaments t ON cd.Game_Title = t.Game_Title
GROUP BY 
    c.Region,
    t.Game_Type
ORDER BY 
    Total_Inscripciones DESC;
GO