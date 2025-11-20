# 🔧 Résoudre: "Invalid login credentials"

## 🎯 Le Problème

Quand vous essayez de vous connecter, vous obtenez l'erreur:
```
❌ AuthApiError: Invalid login credentials
```

Cela signifie que **l'utilisateur n'existe pas en Supabase Auth** ou que les identifiants sont incorrects.

## 📋 Étapes de Dépannage

### 1️⃣ Vérifier que l'utilisateur existe en Supabase Auth

#### A. Via Supabase Console

1. Aller à: **https://app.supabase.com**
2. Sélectionner votre projet
3. Aller à: **Authentication → Users**
4. Chercher l'email que vous essayez d'utiliser (ex: `admin@a2sgestion.fr`)

**Si l'utilisateur est visible:**
```
Email: admin@a2sgestion.fr
✅ L'utilisateur existe en Auth
```

**Si l'utilisateur est ABSENT:**
```
❌ L'utilisateur n'existe pas!
→ Aller à section "Créer l'Utilisateur" ci-dessous
```

#### B. Via SQL

Exécuter cette requête:

```sql
SELECT id, email, email_confirmed_at 
FROM auth.users 
WHERE email = 'admin@a2sgestion.fr';
```

**Résultat attendu:**
```
id                                    | email               | email_confirmed_at
--------------------------------------+---------------------+--------------------
550e8400-e29b-41d4-a716-...          | admin@a2sgestion.fr | 2025-11-19 15:00:00
```

**Si vide = utilisateur n'existe pas**

### 2️⃣ Vérifier que l'email est confirmé

L'utilisateur doit avoir `email_confirmed_at NOT NULL`

```sql
SELECT 
  email,
  email_confirmed_at,
  CASE WHEN email_confirmed_at IS NULL THEN '❌ NON CONFIRMÉ'
       ELSE '✅ CONFIRMÉ' END as status
FROM auth.users 
WHERE email = 'admin@a2sgestion.fr';
```

**Si `email_confirmed_at IS NULL`:**
```sql
-- Confirmer l'email:
UPDATE auth.users 
SET email_confirmed_at = now()
WHERE email = 'admin@a2sgestion.fr';
```

### 3️⃣ Vérifier que le profil existe en table users

```sql
SELECT id, email, role 
FROM users 
WHERE email = 'admin@a2sgestion.fr';
```

**Si vide = créer le profil**

Trouver l'UUID de l'utilisateur Auth:

```sql
SELECT id FROM auth.users WHERE email = 'admin@a2sgestion.fr';
```

Puis créer le profil:

```sql
INSERT INTO users (id, email, nom, role, pages_visibles)
VALUES (
  'UUID-COPIÉ-ICI',  -- ← Remplacer par l'UUID
  'admin@a2sgestion.fr',
  'Administrateur Super',
  'super_admin',
  '["dashboard", "prospects", "clients", "installations", "abonnements", "paiements", "support", "interventions", "alertes", "applications", "utilisateurs"]'::jsonb
);
```

### 4️⃣ Tester avec le bon email ET mot de passe

**⚠️ Attention à:**
- Majuscules/minuscules: `Admin@test.fr` ≠ `admin@test.fr`
- Espaces: `admin @test.fr` ≠ `admin@test.fr`
- Caractères spéciaux: ` admin@tëst.fr` ≠ `admin@test.fr`

**Tester la connexion:**

1. Aller à: http://localhost:3000 (ou votre URL)
2. Entrer exactement l'email d'Auth:
   ```
   Email: admin@a2sgestion.fr  (copier/coller de SQL si possible)
   Mot de passe: AdminPass123!@#Secure
   ```
3. Cliquer "Se Connecter"

## 🆘 Si Ça Ne Marche Toujours Pas

### Option A: Réinitialiser le Mot de Passe

```sql
-- Générer un nouveau mot de passe hashé
UPDATE auth.users 
SET encrypted_password = crypt('NewPassword123!@#', gen_salt('bf'))
WHERE email = 'admin@a2sgestion.fr';
```

Puis se connecter avec le nouveau mot de passe:
```
Email: admin@a2sgestion.fr
Mot de passe: NewPassword123!@#
```

### Option B: Recréer Complètement l'Utilisateur

#### 1. Supprimer l'ancien profil
```sql
DELETE FROM users WHERE email = 'admin@a2sgestion.fr';
```

#### 2. Supprimer l'utilisateur Auth
```sql
-- Via Console: Authentication → Users → Cliquer l'utilisateur → Delete
-- OU via SQL:
DELETE FROM auth.users WHERE email = 'admin@a2sgestion.fr';
```

#### 3. Recréer depuis zéro
Utiliser le script: `create_super_admin_simple.sql`

## 📊 Checklist de Dépannage

- [ ] Utilisateur visible en `auth.users`?
- [ ] Email est confirmé (`email_confirmed_at NOT NULL`)?
- [ ] Profil visible en table `users`?
- [ ] Email correct (majuscules, espaces, caractères)?
- [ ] Mot de passe correct?
- [ ] Role est `super_admin`?
- [ ] pages_visibles remplies?

## ✅ Test Complet

Une fois que tout est vérifié:

```sql
-- Vérifier Auth
SELECT id, email, email_confirmed_at FROM auth.users 
WHERE email = 'admin@a2sgestion.fr';

-- Vérifier Profile
SELECT id, email, role FROM users 
WHERE email = 'admin@a2sgestion.fr';
```

Résultat attendu:
```
2 lignes (1 Auth, 1 Profile)
Email identique
UUID identique
Role = super_admin
```

Puis tester login:
```
Page: http://localhost:3000
Email: admin@a2sgestion.fr
Mot de passe: AdminPass123!@#Secure
Résultat attendu: ✅ Redirection Dashboard
```

## 🚨 Erreurs Courantes

### "Email already exists"

**Cause:** Email existe en Auth mais aussi en profil users

**Solution:**
```sql
-- Vérifier combien de fois existe l'email
SELECT COUNT(*) FROM auth.users WHERE email = 'admin@a2sgestion.fr';
SELECT COUNT(*) FROM users WHERE email = 'admin@a2sgestion.fr';

-- Si >1 en users, supprimer les doublons
DELETE FROM users WHERE email = 'admin@a2sgestion.fr' 
AND id NOT IN (SELECT id FROM auth.users WHERE email = 'admin@a2sgestion.fr');
```

### "UUID already exists"

**Cause:** UUID existe déjà (impossible normalement)

**Solution:**
```sql
-- Vérifier les UUID doublons
SELECT id, COUNT(*) FROM users GROUP BY id HAVING COUNT(*) > 1;

-- Supprimer les doublons manuellement
```

### "Role 'super_admin' does not exist"

**Cause:** Le role super_admin n'est pas reconnu (rare)

**Solution:**
```sql
-- Vérifier les rôles disponibles
SELECT DISTINCT role FROM users;

-- Utiliser 'admin' à la place si super_admin n'existe pas
UPDATE users SET role = 'admin' WHERE email = 'admin@a2sgestion.fr';
```

## 📞 Besoin d'Aide?

1. Lire cette doc complètement
2. Vérifier chaque point de la checklist
3. Consulter `COMPTE_SUPER_ADMIN.md` pour créer depuis zéro
4. Vérifier les logs console (F12 → Console)
5. Contacter support A2S

---

**Status**: ✅ Guide complet  
**Dernière mise à jour**: 19 novembre 2025
