-- ========================================
-- CORRECTION FINALE TABLE PROSPECTS
-- ========================================
-- Objectif: Ajouter historique_actions et created_at
-- Date: 2025-11-15
-- ========================================

-- 1️⃣ Ajouter la colonne created_at si elle n'existe pas
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'prospects' 
        AND column_name = 'created_at'
    ) THEN
        ALTER TABLE prospects 
        ADD COLUMN created_at TIMESTAMPTZ DEFAULT NOW();
        
        RAISE NOTICE '✅ Colonne created_at ajoutée';
    ELSE
        RAISE NOTICE 'ℹ️ Colonne created_at existe déjà';
    END IF;
END $$;

-- 2️⃣ Ajouter la colonne historique_actions (JSON) si elle n'existe pas
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'prospects' 
        AND column_name = 'historique_actions'
    ) THEN
        ALTER TABLE prospects 
        ADD COLUMN historique_actions JSONB DEFAULT '[]'::jsonb;
        
        RAISE NOTICE '✅ Colonne historique_actions ajoutée';
    ELSE
        RAISE NOTICE 'ℹ️ Colonne historique_actions existe déjà';
    END IF;
END $$;

-- 3️⃣ Mettre à jour la contrainte secteur pour les 5 valeurs
ALTER TABLE prospects
DROP CONSTRAINT IF EXISTS prospects_secteur_check;

ALTER TABLE prospects
ADD CONSTRAINT prospects_secteur_check 
CHECK (secteur IN ('GROSSISTE PHARM', 'GROSSISTE PARA', 'PARA SUPER GROS', 'LABO PROD', 'AUTRE'));

-- 4️⃣ Mettre à jour les secteurs invalides
UPDATE prospects
SET secteur = 'AUTRE'
WHERE secteur NOT IN ('GROSSISTE PHARM', 'GROSSISTE PARA', 'PARA SUPER GROS', 'LABO PROD', 'AUTRE')
   OR secteur IS NULL;

-- 5️⃣ Initialiser l'historique pour les prospects existants
UPDATE prospects
SET historique_actions = jsonb_build_array(
    jsonb_build_object(
        'action', 'creation',
        'details', 'Prospect créé (migration)',
        'created_at', COALESCE(created_at, NOW())::text,
        'created_by', 'system'
    )
)
WHERE historique_actions IS NULL 
   OR historique_actions = '[]'::jsonb;

-- 6️⃣ Ajouter un index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_prospects_historique 
ON prospects USING gin (historique_actions);

CREATE INDEX IF NOT EXISTS idx_prospects_created_at 
ON prospects (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_prospects_secteur 
ON prospects (secteur);

-- ✅ RÉSUMÉ
DO $$ 
DECLARE
    total_prospects INT;
    avec_historique INT;
BEGIN
    SELECT COUNT(*) INTO total_prospects FROM prospects;
    SELECT COUNT(*) INTO avec_historique FROM prospects WHERE historique_actions IS NOT NULL AND historique_actions != '[]'::jsonb;
    
    RAISE NOTICE '========================================';
    RAISE NOTICE '✅ MIGRATION TERMINÉE';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Total prospects: %', total_prospects;
    RAISE NOTICE 'Avec historique: %', avec_historique;
    RAISE NOTICE '========================================';
END $$;
