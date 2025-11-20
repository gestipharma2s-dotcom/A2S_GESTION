-- ========================================
-- 🔧 CORRECTION FINALE - TABLE PROSPECTS
-- ========================================
-- Ajoute: 
-- 1. Colonne SECTEUR avec 5 choix fixes
-- 2. Colonne HISTORIQUE_ACTIONS (JSON)
-- 3. Migrations des données existantes
-- ========================================

-- ✅ 1. AJOUTER LA COLONNE SECTEUR (si elle n'existe pas)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'prospects' AND column_name = 'secteur'
  ) THEN
    ALTER TABLE prospects 
    ADD COLUMN secteur TEXT DEFAULT 'AUTRE';
    
    RAISE NOTICE '✅ Colonne secteur ajoutée';
  ELSE
    RAISE NOTICE 'ℹ️ Colonne secteur existe déjà';
  END IF;
END $$;

-- ✅ 2. AJOUTER LA CONTRAINTE CHECK pour SECTEUR (5 choix fixes)
DO $$ 
BEGIN
  -- Supprimer l'ancienne contrainte si elle existe
  IF EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE table_name = 'prospects' AND constraint_name = 'prospects_secteur_check'
  ) THEN
    ALTER TABLE prospects DROP CONSTRAINT prospects_secteur_check;
    RAISE NOTICE 'ℹ️ Ancienne contrainte secteur supprimée';
  END IF;
  
  -- Ajouter la nouvelle contrainte avec les 5 secteurs
  ALTER TABLE prospects 
  ADD CONSTRAINT prospects_secteur_check 
  CHECK (secteur IN ('GROSSISTE PHARM', 'GROSSISTE PARA', 'PARA SUPER GROS', 'LABO PROD', 'AUTRE'));
  
  RAISE NOTICE '✅ Contrainte secteur créée avec 5 choix';
END $$;

-- ✅ 3. METTRE À JOUR LES VALEURS EXISTANTES (migration intelligente)
UPDATE prospects 
SET secteur = CASE
  WHEN secteur ILIKE '%pharmacie%' OR secteur ILIKE '%pharm%' THEN 'GROSSISTE PHARM'
  WHEN secteur ILIKE '%parapharmacie%' OR secteur ILIKE '%para%' THEN 'GROSSISTE PARA'
  WHEN secteur ILIKE '%super%' OR secteur ILIKE '%gros%' THEN 'PARA SUPER GROS'
  WHEN secteur ILIKE '%labo%' OR secteur ILIKE '%prod%' THEN 'LABO PROD'
  ELSE 'AUTRE'
END
WHERE secteur IS NULL 
   OR secteur NOT IN ('GROSSISTE PHARM', 'GROSSISTE PARA', 'PARA SUPER GROS', 'LABO PROD', 'AUTRE');

-- ✅ 4. AJOUTER LA COLONNE HISTORIQUE_ACTIONS (si elle n'existe pas)
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'prospects' AND column_name = 'historique_actions'
  ) THEN
    ALTER TABLE prospects 
    ADD COLUMN historique_actions JSONB DEFAULT '[]'::jsonb;
    
    RAISE NOTICE '✅ Colonne historique_actions ajoutée';
  ELSE
    RAISE NOTICE 'ℹ️ Colonne historique_actions existe déjà';
  END IF;
END $$;

-- ✅ 5. INITIALISER L'HISTORIQUE POUR LES PROSPECTS EXISTANTS
UPDATE prospects 
SET historique_actions = jsonb_build_array(
  jsonb_build_object(
    'action', 'creation',
    'details', 'Prospect créé (migration)',
    'created_at', COALESCE(date_creation, NOW())::text,
    'created_by', 'system'
  )
)
WHERE historique_actions = '[]'::jsonb 
   OR historique_actions IS NULL;

-- ✅ 6. CRÉER UN INDEX SUR SECTEUR (performance)
CREATE INDEX IF NOT EXISTS idx_prospects_secteur 
ON prospects(secteur);

-- ✅ 7. CRÉER UN INDEX SUR HISTORIQUE_ACTIONS (performance)
CREATE INDEX IF NOT EXISTS idx_prospects_historique 
ON prospects USING GIN (historique_actions);

-- ✅ 8. AFFICHER LES STATISTIQUES
DO $$ 
DECLARE
  total_count INT;
  grossiste_pharm_count INT;
  grossiste_para_count INT;
  para_super_count INT;
  labo_count INT;
  autre_count INT;
  historique_count INT;
BEGIN
  SELECT COUNT(*) INTO total_count FROM prospects;
  SELECT COUNT(*) INTO grossiste_pharm_count FROM prospects WHERE secteur = 'GROSSISTE PHARM';
  SELECT COUNT(*) INTO grossiste_para_count FROM prospects WHERE secteur = 'GROSSISTE PARA';
  SELECT COUNT(*) INTO para_super_count FROM prospects WHERE secteur = 'PARA SUPER GROS';
  SELECT COUNT(*) INTO labo_count FROM prospects WHERE secteur = 'LABO PROD';
  SELECT COUNT(*) INTO autre_count FROM prospects WHERE secteur = 'AUTRE';
  SELECT COUNT(*) INTO historique_count 
  FROM prospects 
  WHERE historique_actions IS NOT NULL 
    AND historique_actions != '[]'::jsonb;
  
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '📊 STATISTIQUES PROSPECTS';
  RAISE NOTICE '========================================';
  RAISE NOTICE 'Total prospects: %', total_count;
  RAISE NOTICE 'GROSSISTE PHARM: %', grossiste_pharm_count;
  RAISE NOTICE 'GROSSISTE PARA: %', grossiste_para_count;
  RAISE NOTICE 'PARA SUPER GROS: %', para_super_count;
  RAISE NOTICE 'LABO PROD: %', labo_count;
  RAISE NOTICE 'AUTRE: %', autre_count;
  RAISE NOTICE 'Avec historique: %', historique_count;
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE '✅ MIGRATION TERMINÉE AVEC SUCCÈS!';
  RAISE NOTICE '';
END $$;

-- ✅ 9. POLITIQUE RLS (Row Level Security) - Optionnel
-- Activer RLS si nécessaire
-- ALTER TABLE prospects ENABLE ROW LEVEL SECURITY;

-- ✅ 10. VÉRIFICATION FINALE
SELECT 
  'Colonne secteur' as verification,
  CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'prospects' AND column_name = 'secteur'
  ) THEN '✅ OK' ELSE '❌ MANQUANTE' END as statut
UNION ALL
SELECT 
  'Colonne historique_actions',
  CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'prospects' AND column_name = 'historique_actions'
  ) THEN '✅ OK' ELSE '❌ MANQUANTE' END
UNION ALL
SELECT 
  'Contrainte secteur',
  CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE table_name = 'prospects' AND constraint_name = 'prospects_secteur_check'
  ) THEN '✅ OK' ELSE '❌ MANQUANTE' END;
