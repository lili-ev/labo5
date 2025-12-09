

USE bibliotheque;

WITH emprunts_2025 AS (
    SELECT 
        abonne_id,
        ouvrage_id,
        YEAR(date_debut) AS annee,
        MONTH(date_debut) AS mois
    FROM emprunt
    WHERE YEAR(date_debut) = 2025
),

indicateurs_mensuels AS (
    SELECT 
        annee,
        mois,
        COUNT(*) AS total_emprunts,
        COUNT(DISTINCT abonne_id) AS abonnes_actifs,
        ROUND(COUNT(*) / COUNT(DISTINCT abonne_id), 2) AS moyenne_par_abonne
    FROM emprunts_2025
    GROUP BY annee, mois
),

ouvrages_mensuels AS (
    SELECT
        annee,
        mois,
        ouvrage_id,
        COUNT(*) AS nb_emprunts
    FROM emprunts_2025
    GROUP BY annee, mois, ouvrage_id
),

top_3_ouvrages AS (
    SELECT
        om.annee,
        om.mois,
        o.titre,
        om.nb_emprunts,
        ROW_NUMBER() OVER (PARTITION BY om.annee, om.mois ORDER BY om.nb_emprunts DESC) AS rang
    FROM ouvrages_mensuels om
    JOIN ouvrage o ON o.id = om.ouvrage_id
)

, top_3_par_mois AS (
    SELECT annee, mois, GROUP_CONCAT(titre ORDER BY rang) AS top_3_titres
    FROM top_3_ouvrages
    WHERE rang <= 3
    GROUP BY annee, mois
),

pct_ouvrages AS (
    SELECT 
        e.annee,
        e.mois,
        COUNT(DISTINCT e.ouvrage_id) AS ouvrages_empruntes,
        (SELECT COUNT(*) FROM ouvrage) AS total_ouvrages,
        ROUND(COUNT(DISTINCT e.ouvrage_id) * 100 / (SELECT COUNT(*) FROM ouvrage), 2) AS pct_empruntes
    FROM emprunts_2025 e
    GROUP BY e.annee, e.mois
)

SELECT 
    i.annee,
    i.mois,
    COALESCE(i.total_emprunts, 0) AS total_emprunts,
    COALESCE(i.abonnes_actifs, 0) AS abonnes_actifs,
    COALESCE(i.moyenne_par_abonne, 0) AS moyenne_par_abonne,
    COALESCE(p.pct_empruntes, 0) AS pct_empruntes,
    COALESCE(t.top_3_titres, '') AS top_3_ouvrages
FROM indicateurs_mensuels i
LEFT JOIN pct_ouvrages p ON i.annee = p.annee AND i.mois = p.mois
LEFT JOIN top_3_par_mois t ON i.annee = t.annee AND i.mois = t.mois
ORDER BY i.annee, i.mois;
