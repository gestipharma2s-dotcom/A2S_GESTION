-- ========================================
-- 🔧 CORRIGER update_last_login
-- ========================================

DROP FUNCTION IF EXISTS update_last_login(text) CASCADE;

CREATE OR REPLACE FUNCTION update_last_login(p_email TEXT)
RETURNS VOID AS $$
BEGIN
  UPDATE users_auth
  SET last_login = NOW(), updated_at = NOW()
  WHERE LOWER(users_auth.email) = LOWER(p_email);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- TEST
SELECT update_last_login('admin@meilleur-a2s.fr');
