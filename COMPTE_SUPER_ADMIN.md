# 👑 Guide: Créer le Compte Super Admin

## 🎯 Objectif

Créer le **premier compte administrateur** (`super_admin`) pour gérer l'application A2S Gestion.

## ⚠️ Prérequis

- Accès à la console Supabase (https://app.supabase.com)
- Accès à la base de données PostgreSQL
- Droits administrateur Supabase

## 📋 Option 1: Via Supabase Console (Recommandée - Plus Simple)

### Étape 1: Créer l'utilisateur en Auth

1. Aller à: **Supabase Console → Authentication → Users**
2. Cliquer sur le bouton **"Add user"** (vert, en haut à droite)
3. Remplir le formulaire:
   ```
   Email: admin@a2sgestion.fr
   Password: AdminPass123!@#Secure
   Auto confirm user: [OUI] ← IMPORTANT!
   ```
4. Cliquer **"Create user"**
5. ✅ Utilisateur créé dans auth.users
6. **Copier l'ID utilisateur** (UUID format: `550e8400-e29b-41d4-a716...`)

### Étape 2: Créer le profil en Base de Données

1. Aller à: **Supabase Console → SQL Editor**
2. Créer une **nouvelle requête** (New query)
3. Coller ce script:

```sql
INSERT INTO users (id, nom, email, role, pages_visibles)
VALUES (
  '550e8400-e29b-41d4-a716-...',  -- ← COLLER L'UUID COPIÉ
  'Administrateur Super',
  'admin@a2sgestion.fr',
  'super_admin',
  '["dashboard", "prospects", "clients", "installations", "abonnements", "paiements", "support", "interventions", "alertes", "applications", "utilisateurs"]'::jsonb
);
```

4. Remplacer `550e8400-e29b-41d4-a716-...` par **l'UUID réel**
5. Cliquer **"Run"** (Ctrl+Enter)
6. ✅ Résultat: `Execute completed: 1 row inserted`

### Étape 3: Vérifier

Exécuter cette requête:

```sql
SELECT id, nom, email, role FROM users WHERE role = 'super_admin';
```

Résultat attendu:
```
id                                    | nom                    | email               | role
--------------------------------------+------------------------+---------------------+-----------
550e8400-e29b-41d4-a716-...          | Administrateur Super   | admin@a2sgestion.fr | super_admin
```

## 📋 Option 2: Utiliser le Script SQL

Si vous préférez tout faire en SQL:

1. Ouvrir: **Supabase Console → SQL Editor**
2. Créer **nouvelle requête**
3. Ouvrir le fichier: `init_super_admin.sql`
4. Copier **tout le contenu**
5. Coller dans l'éditeur SQL
6. Modifier les valeurs (email, mot de passe) en haut
7. Exécuter le script complet
8. Vérifier les résultats

## 🔑 Tester la Connexion

### Étape 1: Ouvrir l'App

```
URL: http://localhost:3000
(ou votre URL de production)
```

### Étape 2: Page de Connexion

```
Email: admin@a2sgestion.fr
Mot de passe: AdminPass123!@#Secure
Cliquer: "Se Connecter"
```

### Étape 3: Vérifier

- ✅ Redirection vers Dashboard
- ✅ Menu affiche "Utilisateurs"
- ✅ Profil affiche: "Administrateur Super"

## ⚠️ Problèmes Courants et Solutions

### ❌ "Invalid login credentials"

**Cause:** Email ou mot de passe incorrect

**Solution:**
1. Vérifier l'email en Supabase Console
2. Vérifier la casse (majuscules/minuscules)
3. Vérifier le mot de passe exact

### ❌ "Auth session missing"

**Cause:** Utilisateur existe en Auth mais pas en table `users`

**Solution:**
```sql
-- Vérifier que le profil existe:
SELECT * FROM users WHERE email = 'admin@a2sgestion.fr';

-- Si absent, créer le profil (Étape 2 Option 1)
```

### ❌ "User not found" ou "Email does not exist"

**Cause:** Utilisateur pas créé en Supabase Auth

**Solution:**
1. Console → Authentication → Users
2. Chercher l'email
3. Si absent, créer via "Add user"
4. Suivre Option 1 complet

### ❌ "UUID already exists"

**Cause:** Profil déjà créé avec ce UUID

**Solution:**
```sql
DELETE FROM users WHERE id = 'uuid-ici';
-- Puis réexécuter l'INSERT
```

## 🔄 Changer le Mot de Passe

### Depuis Supabase Console

1. Console → Authentication → Users
2. Cliquer sur l'utilisateur admin
3. Aller à "Password" section
4. Cliquer "Reset password"
5. Supabase envoie email

## 📊 Permissions du Super Admin

```
✅ Dashboard              (Accès complet)
✅ Prospects              (Accès complet)
✅ Clients                (Accès complet)
✅ Installations          (Accès complet)
✅ Abonnements            (Accès complet)
✅ Paiements              (Accès complet)
✅ Support                (Accès complet)
✅ Interventions          (Accès complet)
✅ Alertes                (Accès complet)
✅ Applications           (Accès complet)
✅ Utilisateurs           (Accès complet)
```

## 🆘 Dépannage Avancé

### Vérifier Que l'Utilisateur Existe

```sql
-- En Auth:
SELECT id, email FROM auth.users 
WHERE email = 'admin@a2sgestion.fr';

-- En users table:
SELECT id, nom, email, role FROM users 
WHERE role = 'super_admin';
```

### Réinitialiser Complètement

```sql
-- Supprimer le profil:
DELETE FROM users WHERE email = 'admin@a2sgestion.fr';

-- Puis recréer depuis Supabase Console
-- (l'utilisateur Auth restera intouché)
```

## ✅ Checklist Finale

- [ ] Utilisateur créé en Supabase Auth
- [ ] Email confirmé
- [ ] UUID copié
- [ ] Profil créé dans table users
- [ ] Role = 'super_admin'
- [ ] pages_visibles rempli
- [ ] Test de connexion réussi
- [ ] Dashboard visible
- [ ] Menu "Utilisateurs" visible
- [ ] Mot de passe changé (sécurité)

## 💡 Conseils de Sécurité

1. **Mot de passe fort:** 12+ caractères, majuscules, minuscules, chiffres, spéciaux
2. **Email professionnel:** Pour notifications critiques
3. **2e Super Admin:** En créer un 2e comme backup
4. **Accès limité:** Ne donner Supabase que aux admins système

---

**Status**: ✅ Prêt pour production  
**Dernière mise à jour**: 19 novembre 2025
````
