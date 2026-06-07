USE NexusEsportsEWC;
GO

-- ========================================================================
-- VISTA 1: Estrategia de Portafolio (Amplitud vs. Profundidad)
-- OBJETIVO: Responder si es mejor diversificar en muchos juegos o especializarse en 3 o 4.
-- ENRIQUECIMIENTO: Incorpora los datos raspados de Wikipedia (Club_Divisions).
-- ========================================================================
CREATE OR ALTER VIEW dbo.vw_Strategy_Broad_vs_Deep AS
WITH ScrapedMetrics AS (
    -- Contamos en cuántas divisiones participa realmente el club según Wikipedia
    SELECT 
        Organization_Name,
        COUNT(Game_Title) AS Total_Games_Wikipedia
    FROM dbo.Club_Divisions
    GROUP BY Organization_Name
)
SELECT 
    c.Organization_Name,
    c.Region,
    c.Founded_Year,
    c.Social_Media_Followers_M AS Club_Social_Followers_M,
    cs.Rank_Position,
    cs.Total_Points,
    cs.Prize_Money_USD AS Total_Prize_Money_Club_USD,
    cs.Tournament_Wins,
    cs.Top_8_Finishes,
    COALESCE(s.Total_Games_Wikipedia, 0) AS Total_Games_Wikipedia,
    
    -- MÉTRICAS DE EFICIENCIA ENRIQUECIDAS
    CAST(cs.Total_Points / NULLIF(CAST(s.Total_Games_Wikipedia AS DECIMAL(10,2)), 0) AS DECIMAL(10,2)) AS Points_Per_Game_Ratio,
    CAST(cs.Prize_Money_USD / NULLIF(CAST(s.Total_Games_Wikipedia AS DECIMAL(10,2)), 0) AS DECIMAL(10,2)) AS ROI_USD_Per_Game_Ratio,
    
    -- CLUSTERIZACIÓN LÓGICA DE LA ESTRATEGIA CORPORATIVA
    CASE 
        WHEN s.Total_Games_Wikipedia >= 8 AND cs.Total_Points >= 1500 THEN 'Élite Omnipresente (Alta Amplitud + Alto Éxito)'
        WHEN s.Total_Games_Wikipedia >= 8 AND cs.Total_Points < 1500  THEN 'Postulante Expansivo (Alta Amplitud + Bajo Éxito)'
        WHEN s.Total_Games_Wikipedia < 8  AND cs.Total_Points >= 1500 THEN 'Especialista Quirúrgico (Enfoque/Profundidad + Alto Éxito)'
        ELSE 'Participante de Nicho (Bajo Enfoque + Bajo Éxito)'
    END AS Corporate_Strategy_Cluster
FROM dbo.Clubs c
INNER JOIN dbo.Club_Standings cs ON c.Organization_Name = cs.Organization_Name
LEFT JOIN ScrapedMetrics s ON c.Organization_Name = s.Organization_Name;
GO

-- ========================================================================
-- VISTA 2: El Dilema del Scouting (Veteranos Élite vs. Promesas Mediáticas)
-- OBJETIVO: Determinar qué asegura mayor retorno: medallas o seguidores.
-- ========================================================================
CREATE OR ALTER VIEW dbo.vw_Scouting_Talent_ROI AS
WITH PlayerMedals AS (
    -- Agrupamos las medallas obtenidas por cada jugador
    SELECT 
        Player_Name,
        COUNT(CASE WHEN Medal_Type = 'Gold' THEN 1 END) AS Gold_Medals,
        COUNT(CASE WHEN Medal_Type = 'Silver' THEN 1 END) AS Silver_Medals,
        COUNT(CASE WHEN Medal_Type = 'Bronze' THEN 1 END) AS Bronze_Medals,
        COUNT(Medal_ID) AS Total_Medals
    FROM dbo.Medalists
    GROUP BY Player_Name
)
SELECT 
    p.Player_Name,
    p.Organization_Name AS Current_Club,
    p.Game_Title,
    p.Country,
    p.Age,
    p.Experience_Years,
    p.Prize_Earned_USD AS Player_Prize_Earned_USD,
    p.Social_Media_Followers_K AS Player_Followers_K,
    COALESCE(m.Gold_Medals, 0) AS Gold_Medals,
    COALESCE(m.Silver_Medals, 0) AS Silver_Medals,
    COALESCE(m.Bronze_Medals, 0) AS Bronze_Medals,
    COALESCE(m.Total_Medals, 0) AS Total_Medals,
    
    -- CLASIFICACIÓN DEL PERFIL DE TALENTO PARA NEGOCIACIÓN
    CASE 
        WHEN p.Experience_Years >= 5 AND COALESCE(m.Total_Medals, 0) >= 1 THEN 'Veterano Consolidado (Alto Éxito + Experiencia)'
        WHEN p.Experience_Years < 3  AND p.Social_Media_Followers_K >= 100 THEN 'Imán de Marcas (Joven Promesa + Alto Alcance)'
        WHEN p.Experience_Years >= 3  AND p.Social_Media_Followers_K >= 100 AND COALESCE(m.Total_Medals, 0) >= 1 THEN 'Superestrella Balanceada (Rendimiento + Audiencia)'
        ELSE 'Atleta de Soporte / Perfil Bajo'
    END AS Talent_Strategic_Segment
FROM dbo.Players p
LEFT JOIN PlayerMedals m ON p.Player_Name = m.Player_Name;
GO

-- ========================================================================
-- VISTA 3: Predictor de Rentabilidad y Atractivo de Torneos
-- OBJETIVO: Analizar características de torneos y probabilidad de éxito.
-- ENRIQUECIMIENTO: Mide la saturación del torneo usando los datos de Wikipedia.
-- ========================================================================
CREATE OR ALTER VIEW dbo.vw_Tournament_Profitability_Predictor AS
WITH ClubsPerTournament AS (
    -- Medimos cuántas organizaciones del ecosistema compiten en cada juego (Saturación de mercado)
    SELECT 
        Game_Title,
        COUNT(Organization_Name) AS Total_Clubs_Competing
    FROM dbo.Club_Divisions
    GROUP BY Game_Title
),
MedalsPerTournament AS (
    -- Medimos la cantidad de medallas de élite entregadas por disciplina
    SELECT 
        Game_Title,
        COUNT(Medal_ID) AS Elite_Medals_Distributed
    FROM dbo.Medalists
    GROUP BY Game_Title
)
SELECT 
    t.Game_Title,
    t.Event_Name,
    t.Game_Type,
    t.Platform,
    t.Prize_Pool_USD,
    t.Num_Participants,
    COALESCE(c.Total_Clubs_Competing, 0) AS Scraped_Clubs_In_Game,
    COALESCE(m.Elite_Medals_Distributed, 0) AS Elite_Medals_Distributed,
    
    -- INDICADORES FINANCIEROS DERIVADOS
    CAST(t.Prize_Pool_USD / NULLIF(t.Num_Participants, 0) AS DECIMAL(18,2)) AS Avg_Prize_Per_Participant_USD,
    
    -- ÍNDICE DE COMPETITIVIDAD (A mayor cantidad de clubes de Wikipedia compitiendo, más saturado el juego)
    CASE 
        WHEN t.Prize_Pool_USD >= 5000000 AND COALESCE(c.Total_Clubs_Competing, 0) >= 15 THEN 'Océano Rojo (Bolsa Gigante + Alta Saturación)'
        WHEN t.Prize_Pool_USD >= 3000000 AND COALESCE(c.Total_Clubs_Competing, 0) < 10  THEN 'Océano Azul (Bolsa Alta + Baja Competencia)'
        WHEN t.Prize_Pool_USD < 1000000  THEN 'Torneo de Acceso / Nicho Económico'
        ELSE 'Competencia Estándar de Mercado'
    END AS Tournament_Market_Attractiveness
FROM dbo.Tournaments t
LEFT JOIN ClubsPerTournament c ON t.Game_Title = c.Game_Title
LEFT JOIN MedalsPerTournament m ON t.Game_Title = m.Game_Title;
GO