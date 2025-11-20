-- ========================================
-- Script de diagnostic: Vérifier les secteurs
-- ========================================
-- Ce script permet de voir tous les secteurs actuels
-- et identifier les valeurs à corriger
-- ========================================

-- Voir toutes les valeurs de secteur uniques
SELECT 
  secteur,
  COUNT(*) as nombre_prospects,
  CASE 
    WHEN secteur IN ('GROSSISTE PHARM', 'GROSSISTE PARA', 'PARA SUPER GROS', 'LABO PROD', 'AUTRE') THEN '✅ Valide'
    WHEN secteur IS NULL OR TRIM(secteur) = '' THEN '⚠️ Vide (sera mis à AUTRE)'
    ELSE '❌ Invalide (sera mis à AUTRE)'
  END as statut
FROM prospects
GROUP BY secteur
ORDER BY nombre_prospects DESC;

-- Lister les prospects avec secteur invalide
SELECT 
  id,
  raison_sociale,
  secteur,
  '→ AUTRE' as nouvelle_valeur
FROM prospects
WHERE secteur NOT IN ('GROSSISTE PHARM', 'GROSSISTE PARA', 'PARA SUPER GROS', 'LABO PROD', 'AUTRE')
   OR secteur IS NULL 
   OR TRIM(secteur) = '';

-- Résumé
DO $$
DECLARE
  total_prospects INTEGER;
  valides INTEGER;
  a_corriger INTEGER;
BEGIN
  SELECT COUNT(*) INTO total_prospects FROM prospects;
  
  SELECT COUNT(*) INTO valides 
  FROM prospects 
  WHERE secteur IN ('GROSSISTE PHARM', 'GROSSISTE PARA', 'PARA SUPER GROS', 'LABO PROD', 'AUTRE');
  
  SELECT COUNT(*) INTO a_corriger 
  FROM prospects 
  WHERE secteur NOT IN ('GROSSISTE PHARM', 'GROSSISTE PARA', 'PARA SUPER GROS', 'LABO PROD', 'AUTRE')
     OR secteur IS NULL 
     OR TRIM(secteur) = '';
  
  RAISE NOTICE '📊 RÉSUMÉ';
  RAISE NOTICE '══════════════════════════════';
  RAISE NOTICE 'Total prospects: %', total_prospects;
  RAISE NOTICE 'Secteurs valides: %', valides;
  RAISE NOTICE 'À corriger: %', a_corriger;
  RAISE NOTICE '';
  
  IF a_corriger > 0 THEN
    RAISE NOTICE '⚠️ % prospects seront mis à jour avec secteur = AUTRE', a_corriger;
    RAISE NOTICE '💡 Exécutez le script supabase_update_secteur.sql pour appliquer les corrections';
  ELSE
    RAISE NOTICE '✅ Tous les secteurs sont valides!';
    RAISE NOTICE '💡 Vous pouvez exécuter supabase_update_secteur.sql en toute sécurité';
  END IF;
END $$;
