-- ========================================================================
-- PROYECTO: Nexus Esports Management & Analytics (CRISP-DM)
-- MOTOR: SQL Server (T-SQL)
-- FASE 3: Modelado Inicial de Base de Datos
-- ========================================================================


CREATE DATABASE NexusEsportsEWC;
GO
USE NexusEsportsEWC;
GO

-- ========================================================================
-- 0. LIMPIEZA PREVIA (Drop en orden inverso a las dependencias)
-- ========================================================================
DROP TABLE IF EXISTS Medalists;
DROP TABLE IF EXISTS Players;
DROP TABLE IF EXISTS Club_Standings;
DROP TABLE IF EXISTS Clubs;
DROP TABLE IF EXISTS Tournaments;
GO

-- ========================================================================
-- 1. EJE DE COMPETICIÓN (Dimensión Central)
-- Archivo Origen: 01_EWC2025_Event_Tournament_Summary.csv
-- ========================================================================
CREATE TABLE Tournaments (
    Game_Title NVARCHAR(100) NOT NULL PRIMARY KEY, -- Llave Primaria
    Event_Name NVARCHAR(150),
    Start_Date DATE,
    End_Date DATE,
    Prize_Pool_USD DECIMAL(18,2),
    Num_Participants INT,
    Game_Type NVARCHAR(50),
    Platform NVARCHAR(50)
);
GO

-- ========================================================================
-- 2. EJE ORGANIZACIONAL (Influencia Corporativa)
-- Archivo Origen: 04_EWC2025_Club_Partner_Program.csv
-- ========================================================================
CREATE TABLE Clubs (
    Organization_Name NVARCHAR(100) NOT NULL PRIMARY KEY, -- Llave Primaria
    Region NVARCHAR(100),
    Founded_Year INT,
    CEO NVARCHAR(150),
    Social_Media_Followers_M DECIMAL(10,2) -- Seguidores en millones
);
GO

-- ========================================================================
-- 3. EJE ORGANIZACIONAL (Rendimiento Competitivo)
-- Archivo Origen: 03_EWC2025_Club_Championship_Standings.csv
-- ========================================================================
CREATE TABLE Club_Standings (
    Organization_Name NVARCHAR(100) NOT NULL PRIMARY KEY, 
    Rank_Position INT,
    Total_Points INT,
    Prize_Money_USD DECIMAL(18,2),
    Tournament_Wins INT,
    Top_8_Finishes INT,
    -- Llave foránea que conecta el rendimiento con el perfil corporativo
    CONSTRAINT FK_ClubStandings_Clubs FOREIGN KEY (Organization_Name) 
        REFERENCES Clubs(Organization_Name)
);
GO

-- ========================================================================
-- 4. EJE DEL TALENTO (Roster global de participantes)
-- Archivo Origen: 05_EWC2025_Player_Roster.csv
-- ========================================================================
CREATE TABLE Players (
    Player_Name NVARCHAR(100) NOT NULL PRIMARY KEY, -- Llave principal definida en el diseño
    Organization_Name NVARCHAR(100),
    Game_Title NVARCHAR(100),
    Country NVARCHAR(100),
    Age INT,
    Experience_Years INT,
    Prize_Earned_USD DECIMAL(18,2),
    Social_Media_Followers_K INT, -- Seguidores en miles
    
    -- Vinculación bidireccional (Organización y Competición)
    CONSTRAINT FK_Players_Clubs FOREIGN KEY (Organization_Name) 
        REFERENCES Clubs(Organization_Name),
    CONSTRAINT FK_Players_Tournaments FOREIGN KEY (Game_Title) 
        REFERENCES Tournaments(Game_Title)
);
GO

-- ========================================================================
-- 5. EJE DEL TALENTO (Atletas de élite / Histórico de Medallas)
-- Archivo Origen: 02_EWC2025_Medalists.csv
-- ========================================================================
CREATE TABLE Medalists (
    Medal_ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY, -- Llave subrogada autoincremental
    Player_Name NVARCHAR(100) NOT NULL,
    Game_Title NVARCHAR(100) NOT NULL,
    Medal_Type NVARCHAR(20), -- Gold, Silver, Bronze
    Player_Role NVARCHAR(50),
    
    -- Vinculación con los jugadores comunes para el filtrado de élite
    CONSTRAINT FK_Medalists_Players FOREIGN KEY (Player_Name) 
        REFERENCES Players(Player_Name),
    -- Vinculación para saber en qué torneo específico ganaron
    CONSTRAINT FK_Medalists_Tournaments FOREIGN KEY (Game_Title) 
        REFERENCES Tournaments(Game_Title)
);
GO

-- ========================================================================
-- 6. EJE ESTRATÉGICO DE DIVERSIFICACIÓN (Tabla Intermedia)
-- Origen: Datos enriquecidos mediante Web Scraping (Wikipedia)
-- Descripción: Resuelve la relación Muchos a Muchos entre Clubes y Torneos, 
--              permitiendo analizar la huella operativa global de la organización.
-- ========================================================================
CREATE TABLE Club_Divisions (
    Organization_Name NVARCHAR(100),
    Game_Title NVARCHAR(100),
    -- La combinación de ambas columnas será nuestra Llave Primaria Compuesta
    CONSTRAINT PK_Club_Divisions PRIMARY KEY (Organization_Name, Game_Title),
    
    -- Llave Foránea hacia la tabla de Clubs
    CONSTRAINT FK_ClubDivisions_Clubs FOREIGN KEY (Organization_Name) 
        REFERENCES Clubs(Organization_Name),
        
    -- Llave Foránea hacia la tabla de Torneos
    CONSTRAINT FK_ClubDivisions_Tournaments FOREIGN KEY (Game_Title) 
        REFERENCES Tournaments(Game_Title)
);
GO