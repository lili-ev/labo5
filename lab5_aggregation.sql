
USE bibliotheque;

SELECT COUNT(*) AS total_abonnes
FROM abonne;

SELECT AVG(nb) AS moyenne_emprunts
FROM (
  SELECT COUNT(*) AS nb
  FROM emprunt
  GROUP BY abonne_id
) AS sous;


SELECT abonne_id, COUNT(*) AS nbre
FROM emprunt
GROUP BY abonne_id;

SELECT auteur_id, COUNT(*) AS total_ouvrages
FROM ouvrage
GROUP BY auteur_id;

SELECT abonne_id, COUNT(*) AS nbre
FROM emprunt
GROUP BY abonne_id
HAVING COUNT(*) >= 3;

SELECT auteur_id, COUNT(*) AS total_ouvrages
FROM ouvrage
GROUP BY auteur_id
HAVING total_ouvrages > 5;

SELECT a.nom, COUNT(e.id) AS emprunts
FROM abonne a
LEFT JOIN emprunt e ON e.abonne_id = a.id
GROUP BY a.id, a.nom;

SELECT au.nom, COUNT(e.id) AS total_emprunts
FROM auteur au
JOIN ouvrage o ON o.auteur_id = au.id
LEFT JOIN emprunt e ON e.ouvrage_id = o.id
GROUP BY au.id, au.nom;


SELECT 
  ROUND(
    COUNT(CASE WHEN e.id IS NOT NULL THEN 1 END) * 100 
    / COUNT(DISTINCT o.id), 2
  ) AS pct_empruntes
FROM ouvrage o
LEFT JOIN emprunt e ON e.ouvrage_id = o.id;

SELECT a.nom, COUNT(*) AS nbre_emprunts
FROM abonne a
JOIN emprunt e ON e.abonne_id = a.id
GROUP BY a.id, a.nom
ORDER BY nbre_emprunts DESC
LIMIT 3;

WITH stats AS (
  SELECT o.auteur_id, COUNT(e.id) AS emprunts, COUNT(DISTINCT o.id) AS ouvrages
  FROM ouvrage o
  LEFT JOIN emprunt e ON e.ouvrage_id = o.id
  GROUP BY o.auteur_id
)
SELECT s.auteur_id, s.emprunts / s.ouvrages * 1.0 AS moyenne
FROM stats s
WHERE s.emprunts / s.ouvrages * 1.0 > 0;

EXPLAIN
SELECT abonne_id, COUNT(*) AS nbre
FROM emprunt
GROUP BY abonne_id;


SELECT DAYOFWEEK(date_debut) AS jour, COUNT(*) AS nbre_emprunts
FROM emprunt
GROUP BY jour;

SELECT MONTH(date_debut) AS mois, COUNT(*) AS total_emprunts
FROM emprunt
WHERE YEAR(date_debut) = 2025
GROUP BY mois;

SELECT COUNT(*) AS nb_ouvrages_non_empruntes
FROM ouvrage o
LEFT JOIN emprunt e ON e.ouvrage_id = o.id
WHERE e.id IS NULL;
