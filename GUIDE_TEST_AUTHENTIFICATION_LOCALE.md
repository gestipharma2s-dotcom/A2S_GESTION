# 🧪 Guide de Test - Authentification Locale

## ✅ Checklist Pré-Test

- [ ] Script `CREER_AUTHENTIFICATION_LOCALE.sql` exécuté dans Supabase
- [ ] Aucune erreur SQL lors de l'exécution
- [ ] Application compilée avec `npm run build` (0 erreurs)
- [ ] Application lancée avec `npm run dev`

---

## 🔍 TEST 1: Vérifier la création de la table users_auth

**Objectif**: Confirmer que la table users_auth a été créée avec succès

**Étapes**:
1. Allez sur Supabase → SQL Editor
2. Exécutez cette requête:

```sql
-- Vérifier la structure de la table users_auth
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'users_auth'
ORDER BY ordinal_position;
```

**Résultat attendu**:
```
Column          | Type      | Nullable
id              | uuid      | false
email           | text      | false
password_hash   | text      | false
created_at      | timestamp | false
updated_at      | timestamp | false
last_login      | timestamp | true
is_active       | boolean   | true
```

---

## 🔍 TEST 2: Vérifier la colonne auth_id sur users

**Objectif**: Confirmer que la colonne auth_id a été ajoutée

**Étapes**:
1. Dans SQL Editor, exécutez:

```sql
-- Vérifier que auth_id existe sur users
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'users' AND column_name = 'auth_id';
```

**Résultat attendu**:
```
Column  | Type | Nullable
auth_id | uuid | true
```

---

## 🔍 TEST 3: Vérifier que les fonctions SQL existent

**Étapes**:
1. Dans SQL Editor, exécutez:

```sql
-- Lister les fonctions créées
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public' AND routine_name LIKE 'create_user_%' OR routine_name LIKE 'verify_%' OR routine_name LIKE 'update_%';
```

**Résultat attendu**:
```
Fonction                 | Type
create_user_local       | FUNCTION
verify_user_password    | FUNCTION
update_last_login       | FUNCTION
```

---

## 🧪 TEST 4: Créer un utilisateur via SQL (Premier Test)

**Objectif**: Tester la fonction create_user_local() directement

**Étapes**:
1. Dans SQL Editor, exécutez:

```sql
-- Test 1: Créer un utilisateur admin
SELECT create_user_local(
  'admin-test@exemple.com',
  'AdminTest123456!',
  'Admin Testeur',
  'admin',
  ARRAY['dashboard', 'utilisateurs']
);
```

**Résultat attendu**:
```
id         | email                    | nom           | role  | message
<uuid>     | admin-test@exemple.com   | Admin Testeur | admin | User created successfully
```

**Vérification supplémentaire**:
```sql
-- Vérifier que l'utilisateur a été créé dans les deux tables
SELECT id, email, role FROM users WHERE email = 'admin-test@exemple.com';
SELECT id, email, is_active FROM users_auth WHERE email = 'admin-test@exemple.com';
```

Résultat attendu: **2 enregistrements** (un dans users, un dans users_auth)

---

## 🧪 TEST 5: Vérifier le mot de passe via SQL

**Objectif**: Tester la fonction verify_user_password()

**Étapes**:
1. Correct password test:

```sql
-- Test avec le bon mot de passe
SELECT * FROM verify_user_password(
  'admin-test@exemple.com',
  'AdminTest123456!'
);
```

**Résultat attendu**:
```
user_id    | email                   | nom           | role  | is_valid
<uuid>     | admin-test@exemple.com  | Admin Testeur | admin | true
```

2. Incorrect password test:

```sql
-- Test avec un mauvais mot de passe
SELECT * FROM verify_user_password(
  'admin-test@exemple.com',
  'MauvaisMotDePasse'
);
```

**Résultat attendu**:
```
user_id | email | nom | role | is_valid
NULL    | NULL  | NULL| NULL | false
```

---

## 🧪 TEST 6: Créer un utilisateur via l'Application

**Objectif**: Tester la création d'utilisateur depuis l'interface web

**Étapes**:
1. Lancez l'application: `npm run dev`
2. Connectez-vous avec un compte admin existant
3. Allez sur **Utilisateurs** → **Ajouter un utilisateur**
4. Remplissez le formulaire:
   - **Email**: `tech-app@exemple.com`
   - **Nom**: `Technicien App Test`
   - **Rôle**: `technicien`
   - **Mot de passe**: `TechApp123456!`
   - **Pages visibles**: Cochez "interventions" et "installations"
5. Cliquez **Ajouter**

**Résultat attendu**:
- ✅ Message de succès
- ✅ L'utilisateur apparaît dans la liste
- ✅ Pas d'erreur dans la console

**Vérification dans SQL**:
```sql
SELECT id, email, nom, role FROM users WHERE email = 'tech-app@exemple.com';
SELECT email, is_active, created_at FROM users_auth WHERE email = 'tech-app@exemple.com';
```

---

## 🧪 TEST 7: Login avec le nouvel utilisateur

**Objectif**: Tester la connexion avec authentification locale

**Étapes**:
1. **Déconnectez-vous** (cliquez sur votre profil → Déconnexion)
   - Ou ouvrez une **fenêtre incognito**
2. Dans la page de login, entrez:
   - **Email**: `tech-app@exemple.com`
   - **Mot de passe**: `TechApp123456!`
3. Cliquez **Se connecter**

**Résultat attendu**:
- ✅ Connexion réussie
- ✅ Redirection vers le dashboard
- ✅ Pages visibles correctes (interventions, installations)
- ✅ Pas d'erreur "Email ou mot de passe incorrect"

**Vérification dans SQL**:
```sql
-- Vérifier que last_login a été mis à jour
SELECT email, last_login FROM users_auth WHERE email = 'tech-app@exemple.com';
```

**Résultat attendu**: last_login doit être **très récent** (dans les dernières secondes)

---

## 🧪 TEST 8: Test d'erreur - Mauvais mot de passe

**Objectif**: Vérifier que le système rejette les mauvais mots de passe

**Étapes**:
1. Dans la page de login, entrez:
   - **Email**: `tech-app@exemple.com`
   - **Mot de passe**: `MauvaisMotDePasse`
2. Cliquez **Se connecter**

**Résultat attendu**:
- ❌ Message d'erreur: "Email ou mot de passe incorrect"
- ❌ Connexion refusée
- Utiliser pas de redirection

---

## 🧪 TEST 9: Test d'erreur - Email non existant

**Objectif**: Vérifier que le système rejette les emails inexistants

**Étapes**:
1. Dans la page de login, entrez:
   - **Email**: `utilisateur-fantome@exemple.com`
   - **Mot de passe**: `N'importeQuoi123`
2. Cliquez **Se connecter**

**Résultat attendu**:
- ❌ Message d'erreur: "Email ou mot de passe incorrect"
- ❌ Connexion refusée

---

## 🧪 TEST 10: Test d'erreur - Email dupliqué

**Objectif**: Vérifier que le système empêche les doublons

**Étapes**:
1. Connectez-vous comme admin
2. Allez sur **Utilisateurs** → **Ajouter un utilisateur**
3. Entrez:
   - **Email**: `tech-app@exemple.com` (déjà existant!)
   - **Nom**: `Autre nom`
   - **Rôle**: `commercial`
4. Cliquez **Ajouter**

**Résultat attendu**:
- ❌ Message d'erreur: "Un utilisateur avec l'email tech-app@exemple.com existe déjà"
- ❌ L'utilisateur n'est pas créé (pas de doublon)

---

## 🧪 TEST 11: Suppression d'utilisateur

**Objectif**: Vérifier que la suppression fonctionne correctement

**Étapes**:
1. Connectez-vous comme admin
2. Allez sur **Utilisateurs**
3. Trouvez `tech-app@exemple.com`
4. Cliquez **Supprimer**
5. Confirmez la suppression

**Résultat attendu**:
- ✅ Message de succès
- ✅ L'utilisateur disparaît de la liste
- ✅ Pas d'erreur dans la console

**Vérification dans SQL**:
```sql
-- L'utilisateur ne devrait plus exister
SELECT COUNT(*) FROM users WHERE email = 'tech-app@exemple.com';
SELECT COUNT(*) FROM users_auth WHERE email = 'tech-app@exemple.com';
```

**Résultat attendu**: **0** pour les deux requêtes (records supprimés)

---

## 📊 Tableau de Synthèse des Tests

| Test | Description | Résultat |
|------|-------------|----------|
| 1 | Table users_auth créée | ✅ / ❌ |
| 2 | Colonne auth_id existe | ✅ / ❌ |
| 3 | Fonctions SQL existent | ✅ / ❌ |
| 4 | Créer via SQL | ✅ / ❌ |
| 5 | Vérifier password | ✅ / ❌ |
| 6 | Créer via app | ✅ / ❌ |
| 7 | Login réussi | ✅ / ❌ |
| 8 | Rejeter mauvais password | ✅ / ❌ |
| 9 | Rejeter email inexistant | ✅ / ❌ |
| 10 | Empêcher doublon email | ✅ / ❌ |
| 11 | Supprimer utilisateur | ✅ / ❌ |

---

## 🐛 Troubleshooting Pendant les Tests

### "Fonction create_user_local not found"
→ Le script SQL n'a pas été exécuté. Retourner à ÉTAPE 1 du guide principal.

### "Email ou mot de passe incorrect" lors du login
→ Vérifiez:
1. L'email exact (sensible à la casse)
2. Le mot de passe exact
3. Que l'utilisateur a été créé dans users_auth

### "Erreur: Constraint violation"
→ L'utilisateur existe peut-être déjà. Utilisez un email différent.

### "Pas de réaction au click Ajouter"
→ Vérifiez la console (F12 → Console) pour voir l'erreur exacte

### "last_login n'est pas mis à jour"
→ Vérifiez que update_last_login() s'exécute dans authService.js

---

## ✅ Validation Finale

Tous les tests doivent être **✅ OK**:

- [ ] Table structure correcte
- [ ] Fonctions SQL existent
- [ ] Création SQL fonctionne
- [ ] Vérification password fonctionne
- [ ] Création via app fonctionne
- [ ] Login fonctionne
- [ ] Erreurs gérées correctement
- [ ] Suppression fonctionne
- [ ] Pas d'erreurs console

**Si tout est ✅**: Authentification locale est **PRÊTE EN PRODUCTION**!

---

## 📝 Notes

- Tests 1-5: Validation infrastructure SQL
- Tests 6-7: Validation application
- Tests 8-11: Validation cas d'erreur

---

**Bonne chance avec les tests! 🚀**
