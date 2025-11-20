-- ========================================
-- 🔧 FONCTION SIMPLIFIÉE - Sans pages_visibles complexe
-- ========================================

DROP FUNCTION IF EXISTS create_user_local(text, text, text, text, text[]) CASCADE;

CREATE OR REPLACE FUNCTION create_user_local(
  p_email TEXT,
  p_password TEXT,
  p_nom TEXT,
  p_role TEXT,
  p_pages_visibles TEXT[] DEFAULT NULL
)
RETURNS TABLE (
  user_id UUID,
  email TEXT,
  nom TEXT,
  role TEXT,
  message TEXT
) AS $$
DECLARE
  v_auth_id UUID;
  v_user_id UUID;
  v_pages_jsonb JSONB;
BEGIN
  -- Vérifier si l'email existe déjà dans users_auth
  IF EXISTS (SELECT 1 FROM users_auth WHERE LOWER(users_auth.email) = LOWER(p_email)) THEN
    RETURN QUERY SELECT 
      NULL::UUID, 
      p_email::TEXT, 
      NULL::TEXT,
      NULL::TEXT,
      'Email déjà utilisé'::TEXT;
    RETURN;
  END IF;

  -- Convertir le tableau TEXT[] en JSONB
  IF p_pages_visibles IS NOT NULL AND array_length(p_pages_visibles, 1) > 0 THEN
    v_pages_jsonb := to_jsonb(p_pages_visibles);
  ELSE
    v_pages_jsonb := '[]'::JSONB;
  END IF;

  -- Créer l'enregistrement d'authentification avec password hashé
  INSERT INTO users_auth (email, password_hash)
  VALUES (LOWER(p_email), crypt(p_password, gen_salt('bf')))
  RETURNING id INTO v_auth_id;

  -- Créer l'utilisateur dans la table users
  INSERT INTO users (
    id,
    email,
    nom,
    role,
    pages_visibles,
    auth_id
  ) VALUES (
    gen_random_uuid(),
    LOWER(p_email),
    p_nom,
    LOWER(TRIM(p_role)),
    v_pages_jsonb,
    v_auth_id
  )
  RETURNING users.id INTO v_user_id;

  -- Retourner le résultat
  RETURN QUERY SELECT 
    v_user_id::UUID,
    LOWER(p_email)::TEXT,
    p_nom::TEXT,
    LOWER(TRIM(p_role))::TEXT,
    'Utilisateur créé avec succès'::TEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- TEST
-- ========================================

SELECT * FROM create_user_local(
  'test-app@meilleur.fr',
  'Test123456!',
  'Test App',
  'commercial',
  NULL
);
