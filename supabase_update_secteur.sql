-- ========================================
-- Migration: Ajouter contrainte secteur
-- ========================================
-- Ce script ajoute une contrainte CHECK sur le champ secteur
-- pour limiter les valeurs possibles
-- ========================================

-- Étape 1: Mettre à jour les valeurs existantes non conformes
UPDATE prospects 
SET secteur = 'AUTRE' 
WHERE secteur IS NOT NULL 
  AND secteur NOT IN ('GROSSISTE PHARM', 'GROSSISTE PARA', 'PARA SUPER GROS', 'LABO PROD', 'AUTRE')
  AND TRIM(secteur) != '';

-- Étape 2: Remplacer les NULL et les chaînes vides par 'AUTRE'
UPDATE prospects 
SET secteur = 'AUTRE' 
WHERE secteur IS NULL OR TRIM(secteur) = '';

-- Étape 3: Supprimer l'ancienne contrainte si elle existe
ALTER TABLE prospects DROP CONSTRAINT IF EXISTS prospects_secteur_check;

-- Étape 4: Ajouter la contrainte CHECK pour le secteur
ALTER TABLE prospects 
ADD CONSTRAINT prospects_secteur_check 
CHECK (secteur IN (
  'GROSSISTE PHARM',
  'GROSSISTE PARA', 
  'PARA SUPER GROS',
  'LABO PROD',
  'AUTRE'
));

-- Étape 5: Ajouter un commentaire
COMMENT ON COLUMN prospects.secteur IS 
'Secteur d''activité du prospect: GROSSISTE PHARM, GROSSISTE PARA, PARA SUPER GROS, LABO PROD, AUTRE';

-- Étape 6: Vérification
DO $$
DECLARE
  prospect_count INTEGER;
  invalid_count INTEGER;
BEGIN
  -- Compter le nombre total de prospects
  SELECT COUNT(*) INTO prospect_count FROM prospects;
  
  -- Compter les prospects avec secteur non conforme (devrait être 0)
  SELECT COUNT(*) INTO invalid_count 
  FROM prospects 
  WHERE secteur NOT IN ('GROSSISTE PHARM', 'GROSSISTE PARA', 'PARA SUPER GROS', 'LABO PROD', 'AUTRE');
  
  RAISE NOTICE '✅ Migration terminée avec succès!';
  RAISE NOTICE '📊 Total prospects: %', prospect_count;
  RAISE NOTICE '📊 Prospects avec secteur invalide: %', invalid_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Valeurs possibles: GROSSISTE PHARM, GROSSISTE PARA, PARA SUPER GROS, LABO PROD, AUTRE';
  
  IF invalid_count > 0 THEN
    RAISE WARNING '⚠️ Attention: % prospects ont encore un secteur invalide!', invalid_count;
  END IF;
END $$;
