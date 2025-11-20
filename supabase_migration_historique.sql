-- ========================================
-- Migration: Ajouter le champ historique_actions
-- ========================================
-- Ce script ajoute un champ JSON pour stocker l'historique des actions
-- directement dans la table prospects
-- L'historique est CONSERVÉ même après conversion en client actif
-- ========================================

-- Ajouter la colonne historique_actions si elle n'existe pas
ALTER TABLE prospects 
ADD COLUMN IF NOT EXISTS historique_actions JSONB DEFAULT '[]'::jsonb;

-- Créer un index pour améliorer les performances des requêtes
CREATE INDEX IF NOT EXISTS idx_prospects_historique 
ON prospects USING GIN (historique_actions);

-- Ajouter un commentaire pour la documentation
COMMENT ON COLUMN prospects.historique_actions IS 
'Historique complet des actions de suivi effectuées sur ce prospect. Conservé après conversion en client actif.';

-- ========================================
-- Migration des données existantes (si prospect_history existe)
-- ========================================
-- Cette section migre les données de l'ancienne table prospect_history
-- vers le nouveau champ JSON (à exécuter si la table existe)
-- ========================================

-- Commenter ou décommenter selon si la table prospect_history existe

/*
DO $$
DECLARE
  r RECORD;
  historique_array JSONB;
BEGIN
  -- Pour chaque prospect
  FOR r IN SELECT id FROM prospects LOOP
    -- Récupérer toutes les actions de l'historique
    SELECT COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'action', action,
          'details', details,
          'created_at', created_at
        ) ORDER BY created_at ASC
      ),
      '[]'::jsonb
    ) INTO historique_array
    FROM prospect_history
    WHERE prospect_id = r.id;
    
    -- Mettre à jour le prospect avec l'historique
    UPDATE prospects
    SET historique_actions = historique_array
    WHERE id = r.id;
  END LOOP;
  
  RAISE NOTICE 'Migration de l''historique terminée';
END $$;
*/

-- ========================================
-- Fonction helper pour ajouter une action
-- ========================================
-- Cette fonction peut être appelée depuis l'API pour ajouter une action
-- ========================================

CREATE OR REPLACE FUNCTION add_prospect_action(
  p_prospect_id UUID,
  p_action TEXT,
  p_details TEXT,
  p_metadata JSONB DEFAULT '{}'::jsonb
)
RETURNS VOID AS $$
BEGIN
  UPDATE prospects
  SET historique_actions = historique_actions || 
    jsonb_build_array(
      jsonb_build_object(
        'action', p_action,
        'details', p_details,
        'created_at', NOW(),
        'metadata', p_metadata
      )
    )
  WHERE id = p_prospect_id;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- Fonction pour récupérer l'historique filtré
-- ========================================

CREATE OR REPLACE FUNCTION get_prospect_history(
  p_prospect_id UUID,
  p_before_date TIMESTAMP DEFAULT NULL
)
RETURNS TABLE (
  action TEXT,
  details TEXT,
  created_at TIMESTAMP,
  metadata JSONB
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    (elem->>'action')::TEXT,
    (elem->>'details')::TEXT,
    (elem->>'created_at')::TIMESTAMP,
    (elem->'metadata')::JSONB
  FROM prospects,
       jsonb_array_elements(historique_actions) AS elem
  WHERE prospects.id = p_prospect_id
    AND (p_before_date IS NULL OR (elem->>'created_at')::TIMESTAMP < p_before_date)
  ORDER BY (elem->>'created_at')::TIMESTAMP DESC;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- Trigger pour ajouter automatiquement l'action de création
-- ========================================

CREATE OR REPLACE FUNCTION init_prospect_historique()
RETURNS TRIGGER AS $$
BEGIN
  -- Initialiser l'historique avec l'action de création
  IF NEW.historique_actions IS NULL OR NEW.historique_actions = '[]'::jsonb THEN
    NEW.historique_actions = jsonb_build_array(
      jsonb_build_object(
        'action', 'creation',
        'details', 'Prospect créé',
        'created_at', NOW()
      )
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Créer le trigger
DROP TRIGGER IF EXISTS trg_init_prospect_historique ON prospects;
CREATE TRIGGER trg_init_prospect_historique
  BEFORE INSERT ON prospects
  FOR EACH ROW
  EXECUTE FUNCTION init_prospect_historique();

-- ========================================
-- Vérification
-- ========================================
-- Vérifier que tout est en place
-- ========================================

SELECT 
  column_name, 
  data_type, 
  column_default,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'prospects' 
  AND column_name = 'historique_actions';

-- Message de confirmation
DO $$
BEGIN
  RAISE NOTICE '✅ Migration terminée avec succès!';
  RAISE NOTICE '✅ Le champ historique_actions a été ajouté à la table prospects';
  RAISE NOTICE '✅ L''historique sera conservé même après conversion en client actif';
  RAISE NOTICE '';
  RAISE NOTICE 'Pour migrer les données existantes de prospect_history:';
  RAISE NOTICE '1. Décommenter la section "Migration des données existantes"';
  RAISE NOTICE '2. Exécuter à nouveau le script';
END $$;
