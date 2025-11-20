-- ========================================
-- 🔧 CORRIGER update_last_login - Sans updated_at
-- ========================================

DROP FUNCTION IF EXISTS update_last_login(text) CASCADE;

CREATE OR REPLACE FUNCTION update_last_login(p_email TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  v_count INTEGER;
BEGIN
  UPDATE users_auth
  SET last_login = NOW()
  WHERE email = LOWER(p_email);
  
  -- Retourner TRUE si une ligne a été mise à jour
  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count > 0;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- TEST
SELECT update_last_login('admin@meilleur-a2s.fr');
