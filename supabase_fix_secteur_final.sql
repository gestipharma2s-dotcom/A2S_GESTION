-- ========================================
-- Migration FINALE: Correctif Secteur + Historique
-- ========================================
-- Ce script corrige le champ secteur et ajoute historique_actions
-- ========================================

-- Étape 1: Supprimer l'ancienne contrainte si elle existe
ALTER TABLE prospects DROP CONSTRAINT IF EXISTS prospects_secteur_check;

-- Étape 2: Modifier le type de colonne secteur (au cas où)
ALTER TABLE prospects ALTER COLUMN secteur TYPE TEXT;

-- Étape 3: Mettre à jour TOUTES les valeurs existantes en AUTRE temporairement
UPDATE prospects 
SET secteur = 'AUTRE' 
WHERE secteur IS NULL 
   OR TRIM(secteur) = '' 
   OR secteur NOT IN ('GROSSISTE PHARM', 'GROSSISTE PARA', 'PARA SUPER GROS', 'LABO PROD', 'AUTRE');

-- Étape 4: Ajouter la contrainte CHECK pour les 5 valeurs possibles
ALTER TABLE prospects 
ADD CONSTRAINT prospects_secteur_check 
CHECK (secteur IN (
  'GROSSISTE PHARM',
  'GROSSISTE PARA', 
  'PARA SUPER GROS',
  'LABO PROD',
  'AUTRE'
));

-- Étape 5: Définir une valeur par défaut
ALTER TABLE prospects ALTER COLUMN secteur SET DEFAULT 'AUTRE';

-- Étape 6: Rendre le champ NON NULL
ALTER TABLE prospects ALTER COLUMN secteur SET NOT NULL;

-- Étape 7: Ajouter colonne historique_actions (JSONB) si n'existe pas
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'prospects' AND column_name = 'historique_actions'
  ) THEN
    ALTER TABLE prospects ADD COLUMN historique_actions JSONB DEFAULT '[]'::jsonb;
    RAISE NOTICE '✅ Colonne historique_actions créée';
  ELSE
    RAISE NOTICE 'ℹ️  Colonne historique_actions existe déjà';
  END IF;
END $$;

-- Étape 8: Initialiser l'historique pour les prospects existants sans historique
UPDATE prospects 
SET historique_actions = jsonb_build_array(
  jsonb_build_object(
    'action', 'creation',
    'details', 'Prospect créé (migration)',
    'created_at', COALESCE(created_at, NOW())::text,
    'created_by', 'system'
  )
)
WHERE historique_actions IS NULL OR historique_actions = '[]'::jsonb;

-- Étape 9: Créer un index sur historique_actions pour les performances
CREATE INDEX IF NOT EXISTS idx_prospects_historique ON prospects USING GIN (historique_actions);

-- Étape 10: Fonction pour ajouter une action à l'historique
CREATE OR REPLACE FUNCTION add_prospect_action(
  p_prospect_id UUID,
  p_action TEXT,
  p_details TEXT,
  p_created_by TEXT DEFAULT 'system'
)
RETURNS VOID AS $$
BEGIN
  UPDATE prospects
  SET historique_actions = historique_actions || jsonb_build_array(
    jsonb_build_object(
      'action', p_action,
      'details', p_details,
      'created_at', NOW()::text,
      'created_by', p_created_by
    )
  )
  WHERE id = p_prospect_id;
END;
$$ LANGUAGE plpgsql;

-- Étape 7: Ajouter un commentaire
COMMENT ON COLUMN prospects.secteur IS 
'Secteur d''activité: GROSSISTE PHARM | GROSSISTE PARA | PARA SUPER GROS | LABO PROD | AUTRE';

-- Vérification finale
DO $$
DECLARE
  total_count INTEGER;
  invalid_count INTEGER;
  secteur_stats TEXT;
  avec_historique INTEGER;
BEGIN
  -- Compter le total
  SELECT COUNT(*) INTO total_count FROM prospects;
  
  -- Compter les invalides (devrait être 0)
  SELECT COUNT(*) INTO invalid_count 
  FROM prospects 
  WHERE secteur NOT IN ('GROSSISTE PHARM', 'GROSSISTE PARA', 'PARA SUPER GROS', 'LABO PROD', 'AUTRE');
  
  -- Compter ceux avec historique
  SELECT COUNT(*) INTO avec_historique
  FROM prospects
  WHERE historique_actions IS NOT NULL AND historique_actions != '[]'::jsonb;
  
  -- Statistiques par secteur
  SELECT string_agg(secteur || ': ' || count::text, ', ')
  INTO secteur_stats
  FROM (
    SELECT secteur, COUNT(*) as count
    FROM prospects
    GROUP BY secteur
    ORDER BY count DESC
  ) t;
  
  RAISE NOTICE '';
  RAISE NOTICE '✅ ========================================';
  RAISE NOTICE '✅ MIGRATION SECTEUR + HISTORIQUE TERMINÉE';
  RAISE NOTICE '✅ ========================================';
  RAISE NOTICE '';
  RAISE NOTICE '📊 Total prospects: %', total_count;
  RAISE NOTICE '📊 Prospects invalides: % (devrait être 0)', invalid_count;
  RAISE NOTICE '📊 Prospects avec historique: %', avec_historique;
  RAISE NOTICE '';
  RAISE NOTICE '📈 Répartition par secteur:';
  RAISE NOTICE '   %', secteur_stats;
  RAISE NOTICE '';
  RAISE NOTICE 'ℹ️  Valeurs possibles:';
  RAISE NOTICE '   • GROSSISTE PHARM';
  RAISE NOTICE '   • GROSSISTE PARA';
  RAISE NOTICE '   • PARA SUPER GROS';
  RAISE NOTICE '   • LABO PROD';
  RAISE NOTICE '   • AUTRE (défaut)';
  RAISE NOTICE '';
  
  IF invalid_count > 0 THEN
    RAISE WARNING '⚠️  ATTENTION: % prospects ont encore un secteur invalide!', invalid_count;
  ELSE
    RAISE NOTICE '✅ Tous les secteurs sont conformes!';
  END IF;
  
  IF avec_historique = total_count THEN
    RAISE NOTICE '✅ Tous les prospects ont un historique!';
  ELSE
    RAISE WARNING '⚠️  % prospects sans historique', total_count - avec_historique;
  END IF;
  
  RAISE NOTICE '';
  RAISE NOTICE '💡 Utilisez add_prospect_action() pour ajouter des actions:';
  RAISE NOTICE '   SELECT add_prospect_action(''uuid'', ''appel'', ''Contact téléphonique'', ''user@email'');';
  RAISE NOTICE '';
END $$;
