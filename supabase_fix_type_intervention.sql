-- ========================================
-- Migration: Fixer les valeurs type_intervention
-- ========================================
-- Ce script corrige les valeurs du type d'intervention
-- pour correspondre à la nouvelle liste de types
-- ========================================

-- Étape 0: Supprimer l'ancienne contrainte SI elle existe (avant de mettre à jour les données)
ALTER TABLE interventions DROP CONSTRAINT IF EXISTS interventions_type_intervention_check;

-- Étape 1: Mettre à jour les valeurs anciennes vers les nouvelles
-- Mappe les valeurs existantes aux types valides
UPDATE interventions
SET type_intervention = CASE
  WHEN type_intervention IN ('maintenance', 'Maintenance', 'MAINTENANCE') THEN 'correction'
  WHEN type_intervention IN ('formation', 'Formation', 'FORMATION') THEN 'formation'
  WHEN type_intervention IN ('correction', 'Correction', 'CORRECTION') THEN 'correction'
  WHEN type_intervention IN ('assistance', 'Assistance', 'ASSISTANCE') THEN 'assistance'
  WHEN type_intervention IN ('support', 'Support', 'SUPPORT') THEN 'assistance'
  WHEN type_intervention IN ('accompagnement', 'Accompagnement', 'ACCOMPAGNEMENT') THEN 'accompagnement'
  WHEN type_intervention IN ('blocage', 'Blocage', 'BLOCAGE', 'BLOCAGE DU SYSTEM') THEN 'blocage'
  WHEN type_intervention IN ('autre', 'Autre', 'AUTRE', '', 'ACHAT RECEPTON DIFF TYPE DE FACTURES') THEN 'suivi'
  WHEN type_intervention IS NULL THEN 'suivi'
  ELSE 'suivi' -- Par défaut, les valeurs inconnues deviennent 'suivi'
END;

-- Étape 2: Normaliser les valeurs existantes en minuscules (au cas où)
UPDATE interventions
SET type_intervention = LOWER(type_intervention)
WHERE type_intervention != LOWER(type_intervention);

-- Étape 4: Ajouter la nouvelle contrainte CHECK avec toutes les valeurs autorisées
ALTER TABLE interventions
ADD CONSTRAINT interventions_type_intervention_check
CHECK (type_intervention IN (
  'accompagnement',
  'adaptation',
  'assistance',
  'blocage',
  'correction',
  'fonctionnalite',
  'erreur',
  'formation',
  'integration',
  'mise_a_jour',
  'parametrage',
  'impression',
  'reseau',
  'question',
  'suivi'
));

-- Étape 5: Vérification
DO $$
DECLARE
  intervention_count INTEGER;
  invalid_count INTEGER;
BEGIN
  -- Compter le nombre total d'interventions
  SELECT COUNT(*) INTO intervention_count FROM interventions;
  
  -- Compter les interventions avec type invalide (devrait être 0)
  SELECT COUNT(*) INTO invalid_count 
  FROM interventions 
  WHERE type_intervention NOT IN (
    'accompagnement', 'adaptation', 'assistance', 'blocage', 'correction',
    'fonctionnalite', 'erreur', 'formation', 'integration', 'mise_a_jour',
    'parametrage', 'impression', 'reseau', 'question', 'suivi'
  ) OR type_intervention IS NULL;
  
  RAISE NOTICE '✅ Migration terminée avec succès!';
  RAISE NOTICE '📊 Total interventions: %', intervention_count;
  RAISE NOTICE '📊 Interventions avec type invalide: %', invalid_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Valeurs possibles:';
  RAISE NOTICE '  - accompagnement, adaptation, assistance, blocage, correction';
  RAISE NOTICE '  - fonctionnalite, erreur, formation, integration, mise_a_jour';
  RAISE NOTICE '  - parametrage, impression, reseau, question, suivi';
  
  IF invalid_count > 0 THEN
    RAISE WARNING '⚠️ Attention: % interventions ont encore un type invalide!', invalid_count;
  END IF;
END $$;

-- ========================================
-- Commentaire pour la documentation
-- ========================================
COMMENT ON COLUMN interventions.type_intervention IS 
'Type d''intervention: accompagnement, adaptation, assistance, blocage, correction, fonctionnalite, erreur, formation, integration, mise_a_jour, parametrage, impression, reseau, question, suivi';
