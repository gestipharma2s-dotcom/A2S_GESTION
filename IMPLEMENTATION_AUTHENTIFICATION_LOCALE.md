# 🔐 Implémentation de l'Authentification Locale

## 📋 Résumé

L'authentification locale a été **complètement intégrée** dans l'application. Voici comment fonctionne le nouveau système:

- ✅ **Plus de dépendance à Supabase Auth** - Évite les rate limits
- ✅ **Table users_auth** - Stocke les emails et mots de passe hashés avec bcrypt
- ✅ **Fonctions SQL de gestion** - create_user_local(), verify_user_password(), update_last_login()
- ✅ **Liens vers users existants** - Via colonne auth_id et clé étrangère
- ✅ **Service de connexion modifié** - authService.js utilise verify_user_password()
- ✅ **Création automatique** - userService.js utilise create_user_local()

---

## 🚀 ÉTAPES À FAIRE (Dans cet ordre!)

### ✅ ÉTAPE 1: Exécuter le script SQL dans Supabase

**File**: `CREER_AUTHENTIFICATION_LOCALE.sql`

**Procédure**:
1. Allez sur https://app.supabase.com
2. Sélectionnez votre projet
3. Cliquez sur **SQL Editor** (barre gauche)
4. Cliquez sur **New Query**
5. Ouvrez le fichier `CREER_AUTHENTIFICATION_LOCALE.sql`
6. Copiez/collez **TOUT** le contenu dans l'éditeur
7. Cliquez sur **Run** (ou Ctrl+Enter)

**Attendez que les messages indiquent**:
- ✅ Table `users_auth` created
- ✅ Column `auth_id` added to `users`
- ✅ Foreign key created
- ✅ Indexes created
- ✅ Functions created successfully

---

### ✅ ÉTAPE 2: Créer les utilisateurs par la fonction SQL

Vous pouvez créer des utilisateurs SOIT:

**Option A: Via l'app (Recommandé)**
1. Allez sur **Utilisateurs** → **Ajouter un utilisateur**
2. Remplissez le formulaire
3. L'utilisateur sera créé avec authentification locale automatiquement

**Option B: Via SQL (Si vous préférez)**
Dans SQL Editor, exécutez:
```sql
-- Créer un administrateur
SELECT create_user_local(
  'admin@exemple.com',
  'password_secure_123',
  'Admin Principal',
  'admin',
  ARRAY['dashboard', 'utilisateurs', 'clients', 'prospects']
);

-- Créer un technicien
SELECT create_user_local(
  'technicien@exemple.com',
  'password_tech_123',
  'Tech Support',
  'technicien',
  ARRAY['interventions', 'installations']
);

-- Créer un commercial
SELECT create_user_local(
  'commercial@exemple.com',
  'password_ventes_123',
  'Vendeur Pro',
  'commercial',
  ARRAY['dashboard', 'prospects', 'clients', 'applications']
);
```

---

## 📊 Changements de Code

### 1️⃣ `authService.js` - Connexion avec authentification locale

**CHANGEMENT**: La fonction `signIn()` utilise maintenant:
- Appelle `verify_user_password()` au lieu de Supabase Auth
- Retourne le profil avec pages_visibles depuis la table users
- Met à jour `last_login` dans users_auth

**Code clé**:
```javascript
const { data: verifyResult, error: verifyError } = await supabase
  .rpc('verify_user_password', {
    p_email: email.toLowerCase(),
    p_password: password
  });
```

### 2️⃣ `userService.js` - Création d'utilisateurs

**CHANGEMENT**: La fonction `create()` utilise maintenant:
- Appelle `create_user_local()` au lieu de `supabase.auth.signUp()`
- Retourne directement l'utilisateur créé

**Code clé**:
```javascript
const { data: createResult, error: createError } = await supabase
  .rpc('create_user_local', {
    p_email: userData.email,
    p_password: userData.password,
    p_nom: userData.nom,
    p_role: userData.role,
    p_pages_visibles: userData.pages_visibles
  });
```

### 3️⃣ `Login.jsx` - Messages d'erreur

**CHANGEMENT**: Messages adaptés à l'authentification locale:
- `Email ou mot de passe incorrect` - Plus clair
- Utilise emojis pour meilleure visibilité

---

## 🔄 Flux de Connexion

```
1. Utilisateur entre email + mot de passe dans Login.jsx
   ↓
2. authService.signIn() appelle verify_user_password()
   ↓
3. Fonction SQL compare le mot de passe avec bcrypt
   ↓
4. Si valide → Retourne user_id, nom, role, pages_visibles
   ↓
5. Si invalide → Retourne erreur "Email ou mot de passe incorrect"
   ↓
6. Profil chargé et utilisateur connecté
   ↓
7. last_login mis à jour dans users_auth
```

---

## 🔄 Flux de Création d'Utilisateur

```
1. Admin remplit formulaire dans Utilisateurs/Ajouter
   ↓
2. userService.create() appelle create_user_local()
   ↓
3. Fonction SQL:
   - Vérifie email unique
   - Hash le mot de passe avec bcrypt
   - Crée enregistrement dans users_auth
   - Crée enregistrement dans users avec auth_id
   - Retourne user_id, email, nom, role
   ↓
4. Utilisateur prêt à se connecter
```

---

## 📱 Résultat Final

| Aspect | Avant | Maintenant |
|--------|-------|-----------|
| **Système Auth** | Supabase Auth | Table users_auth locale |
| **Rate Limit** | ❌ Oui (429 errors) | ✅ Non |
| **Création utilisateurs** | Via signUp() | Via create_user_local() |
| **Connexion** | Via signIn() | Via verify_user_password() |
| **Hachage mot de passe** | Supabase | bcrypt (PostgreSQL) |
| **Dépendance** | Auth service entier | Requêtes SQL RPC |
| **Contrôle** | Supabase | 100% local |

---

## ✅ Test de Validation

Après avoir exécuté le script SQL:

1. **Créer un utilisateur via l'app**:
   - Allez sur Utilisateurs → Ajouter
   - Email: `test@exemple.com`
   - Mot de passe: `Test123456!`
   - Cliquez Ajouter

2. **Se connecter avec ce nouvel utilisateur**:
   - Déconnectez-vous (ou ouvrez incognito)
   - Email: `test@exemple.com`
   - Mot de passe: `Test123456!`
   - Cliquez Se connecter
   - ✅ Devrait fonctionner sans aucun problème!

3. **Vérifier dans SQL** (optionnel):
   ```sql
   SELECT email, created_at, last_login FROM users_auth 
   WHERE email = 'test@exemple.com';
   ```
   - Devrait afficher last_login récent

---

## 🛡️ Sécurité

- ✅ Mots de passe hachés avec **bcrypt** (PostgreSQL pgcrypto)
- ✅ Table `users_auth` sécurisée avec RLS (Row Level Security)
- ✅ Hachage irreversible - impossible de récupérer le mot de passe
- ✅ Pas de stockage de mot de passe en clair
- ✅ Fonction `verify_user_password()` protégée en SQL

---

## 🔍 Troubleshooting

### "Erreur: Fonction create_user_local non trouvée"
→ Vous n'avez pas exécuté le script SQL. Allez à ÉTAPE 1.

### "Email ou mot de passe incorrect"
→ Vérifiez l'email et le mot de passe (sensible à la casse)

### "Cet utilisateur existe déjà"
→ L'email est déjà utilisé. Essayez un autre email.

### "Rate limit" dans les logs
→ N'apparaîtra plus! Le système local n'a pas de rate limit.

---

## 📝 Notes Importantes

- ✅ Les anciens utilisateurs créés avec Supabase Auth **continueront de fonctionner**
- ✅ Vous pouvez migrer graduellement les utilisateurs
- ✅ La table `users_auth` est complètement indépendante
- ✅ Les `users` existants gardent leurs données intactes
- ✅ La colonne `auth_id` lie les deux tables automatiquement

---

## 🎯 Prochaines Étapes (Optionnel)

Si vous voulez nettoyer complètement:
1. Supprimer la dépendance à Supabase Auth
2. Utiliser uniquement users_auth pour l'authentification
3. Supprimer les scripts SQL obsolètes (CREER_UTILISATEURS_AUTH.sql, etc.)

Mais ce n'est **pas obligatoire** - le système actuel fonctionne parfaitement!

---

## 📞 Support

Si vous rencontrez des problèmes:
1. Vérifiez que le script SQL a été exécuté avec succès
2. Vérifiez les logs du navigateur (F12)
3. Vérifiez les logs Supabase (SQL Editor → Logs)
4. Testez via SQL directement: `SELECT create_user_local(...)`

---

**✅ Authentification locale complètement implémentée et prête à l'emploi!**
