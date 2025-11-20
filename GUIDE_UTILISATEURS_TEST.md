# 👥 Guide: Créer des Utilisateurs de Test

## 🎯 Objectif

Créer des comptes de test pour chaque rôle afin de vérifier le système de permissions.

---

## 📋 Utilisateurs à Créer

### 1️⃣ Super Admin (👑)
```
Nom: Administrateur Super
Email: super@a2s.dz
Mot de passe: SuperAdmin123!
Rôle: Super Admin
Pages: (toutes automatiquement)
Permissions: ✅ Tout (créer, modifier, supprimer users)
```

### 2️⃣ Admin (🔐)
```
Nom: Administrateur Principal
Email: admin@a2s.dz
Mot de passe: Admin123!
Rôle: Admin
Pages: (toutes automatiquement)
Permissions: ✅ Créer/modifier users (sauf Super Admin)
            ✅ Peut supprimer autres admins
```

### 3️⃣ Technicien (🔧)
```
Nom: Jean Technicien
Email: jean.tech@a2s.dz
Mot de passe: Technicien123!
Rôle: Technicien
Pages: Dashboard, Installations, Abonnements, Support, Interventions
Permissions: ❌ Gestion users
            ✅ Voir installations et supports
```

### 4️⃣ Commercial (💼)
```
Nom: Marie Commerciale
Email: marie.commercial@a2s.dz
Mot de passe: Commercial123!
Rôle: Commercial
Pages: Dashboard, Prospects, Clients, Installations, Abonnements, Paiements
Permissions: ❌ Gestion users
            ✅ Voir prospects et clients
```

### 5️⃣ Support (🎧)
```
Nom: Pierre Support
Email: pierre.support@a2s.dz
Mot de passe: Support123!
Rôle: Support
Pages: Dashboard, Support, Interventions, Clients
Permissions: ❌ Gestion users
            ✅ Gérer tickets et interventions
```

---

## 🛠️ Étapes de Création

### Via l'Interface (Recommandé)

1. **Se connecter en tant que Super Admin ou Admin**
   ```
   Email: super@a2s.dz
   Mot de passe: SuperAdmin123!
   ```

2. **Aller à la page "Utilisateurs"**
   - Clic sur menu → "Utilisateurs"
   - Ou URL directe: `/utilisateurs`

3. **Cliquer sur "Créer un Utilisateur"**
   - Bouton "Créer Utilisateur" en haut à droite

4. **Remplir le formulaire**
   ```
   Nom: Jean Technicien
   Email: jean.tech@a2s.dz
   Mot de passe: Technicien123!
   Rôle: Technicien
   Pages: (cocher Dashboard, Installations, Abonnements, Support, Interventions)
   ```

5. **Cliquer "Créer"**
   - Attendre confirmation
   - Utilisateur créé ✅

### Via SQL (Pour Administrateurs BD)

```sql
-- 1. Super Admin
INSERT INTO users (id, nom, email, role, pages_visibles)
VALUES (
  'uuid-super-admin',  -- Générer via SQL: SELECT gen_random_uuid()
  'Administrateur Super',
  'super@a2s.dz',
  'super_admin',
  '["dashboard", "prospects", "clients", "installations", "abonnements", "paiements", "support", "interventions", "alertes", "applications", "utilisateurs"]'::jsonb
);

-- 2. Admin
INSERT INTO users (id, nom, email, role, pages_visibles)
VALUES (
  'uuid-admin',
  'Administrateur Principal',
  'admin@a2s.dz',
  'admin',
  '["dashboard", "prospects", "clients", "installations", "abonnements", "paiements", "support", "interventions", "alertes", "applications", "utilisateurs"]'::jsonb
);

-- 3. Technicien
INSERT INTO users (id, nom, email, role, pages_visibles)
VALUES (
  'uuid-tech',
  'Jean Technicien',
  'jean.tech@a2s.dz',
  'technicien',
  '["dashboard", "installations", "abonnements", "support", "interventions"]'::jsonb
);

-- 4. Commercial
INSERT INTO users (id, nom, email, role, pages_visibles)
VALUES (
  'uuid-commercial',
  'Marie Commerciale',
  'marie.commercial@a2s.dz',
  'commercial',
  '["dashboard", "prospects", "clients", "installations", "abonnements", "paiements"]'::jsonb
);

-- 5. Support
INSERT INTO users (id, nom, email, role, pages_visibles)
VALUES (
  'uuid-support',
  'Pierre Support',
  'pierre.support@a2s.dz',
  'support',
  '["dashboard", "support", "interventions", "clients"]'::jsonb
);
```

---

## ✅ Vérification Après Création

### Dans l'Interface
1. Aller à "Utilisateurs"
2. Vérifier que chaque utilisateur apparaît
3. Vérifier le rôle et les pages assignées

### Dans Supabase Dashboard
1. Aller à **Authentication** → **Users**
2. Vérifier que les emails temporaires sont créés:
   ```
   user+1719234567890@temp.a2s
   user+1719234567891@temp.a2s
   user+1719234567892@temp.a2s
   ... etc
   ```

### Dans la Base de Données
```sql
SELECT id, nom, email, role, pages_visibles FROM users 
ORDER BY created_at DESC 
LIMIT 5;
```

Résultat attendu:
```
id                   | nom                    | email                      | role        | pages_visibles
---------------------|------------------------|----------------------------|-------------|----------------------------------
uuid-support         | Pierre Support         | pierre.support@a2s.dz      | support     | [...4 pages...]
uuid-commercial      | Marie Commerciale      | marie.commercial@a2s.dz    | commercial  | [...6 pages...]
uuid-tech            | Jean Technicien        | jean.tech@a2s.dz           | technicien  | [...5 pages...]
uuid-admin           | Administrateur Princ.. | admin@a2s.dz               | admin       | [...11 pages...]
uuid-super-admin     | Administrateur Super   | super@a2s.dz               | super_admin | [...11 pages...]
```

---

## 🧪 Scénarios de Test

### Scénario 1: Vérifier Accès Menu
```
Connecté: Jean Technicien (jean.tech@a2s.dz)
Étape 1: Aller à la page principale
Étape 2: Vérifier le menu latéral

Menu doit afficher:
✅ Tableau de Bord
✅ Installations
✅ Abonnements
✅ Support
✅ Interventions

Menu doit masquer:
❌ Prospects
❌ Clients
❌ Paiements
❌ Applications
❌ Utilisateurs
```

### Scénario 2: Vérifier Accès Restreint
```
Connecté: Jean Technicien
Étape 1: Cliquer sur "Prospects" dans menu
Résultat: ❌ "Accès Refusé"

Étape 2: Accès direct URL: /prospects
Résultat: ❌ "Accès Refusé"

Étape 3: Accès direct URL: /installations
Résultat: ✅ Page charge
```

### Scénario 3: Vérifier Gestion Users
```
Connecté: Jean Technicien
Étape 1: Aller à "Utilisateurs"
Résultat: ❌ "Accès Refusé"

Connecté: Admin
Étape 1: Aller à "Utilisateurs"
Résultat: ✅ Liste visible

Étape 2: Cliquer "Créer Utilisateur"
Résultat: ✅ Formulaire s'ouvre

Étape 3: Remplir et créer nouvel utilisateur
Résultat: ✅ Utilisateur créé
```

### Scénario 4: Vérifier Protection Super Admin
```
Connecté: Admin
Étape 1: Aller à "Utilisateurs"
Étape 2: Cliquer sur Super Admin
Étape 3: Cliquer "Supprimer"
Résultat: ❌ Erreur "Seul un Super Admin peut supprimer un Super Admin"

Connecté: Super Admin
Étape 1: Aller à "Utilisateurs"
Étape 2: Cliquer sur Admin
Étape 3: Cliquer "Supprimer"
Étape 4: Entrer "SUPPRIMER" pour confirmer
Résultat: ✅ Admin supprimé
```

---

## 🔑 Identifiants Rapides

```
┌─────────────┬──────────────────────┬──────────────────────┐
│ Rôle        │ Email                │ Mot de passe         │
├─────────────┼──────────────────────┼──────────────────────┤
│ Super Admin │ super@a2s.dz         │ SuperAdmin123!       │
│ Admin       │ admin@a2s.dz         │ Admin123!            │
│ Technicien  │ jean.tech@a2s.dz     │ Technicien123!       │
│ Commercial  │ marie.commercial...  │ Commercial123!       │
│ Support     │ pierre.support@a2s.. │ Support123!          │
└─────────────┴──────────────────────┴──────────────────────┘
```

---

## 📝 Notes Importantes

1. **Emails Temporaires**
   - Les emails temporaires `user+xxx@temp.a2s` sont créés automatiquement
   - Les utilisateurs voient leur email réel (`sofiane@a2s.dz`)
   - Les emails réels acceptent tous les domaines

2. **Mots de Passe**
   - Minimum 6 caractères
   - À donner en toute sécurité
   - Les utilisateurs peuvent les changer après connexion

3. **Rôles et Pages**
   - Super Admin + Admin → accès à TOUTES les pages
   - Autres rôles → accès seulement aux pages assignées
   - Les pages assignées s'affichent dans le menu
   - L'accès direct à URL non autorisée affiche "Accès Refusé"

4. **Permissions**
   - Seul Super Admin ou Admin peut créer des utilisateurs
   - Seul Super Admin peut supprimer un autre Super Admin
   - Admin ne peut pas modifier/supprimer Super Admin
   - Autres rôles ne peuvent pas gérer d'utilisateurs

---

## 🆘 Troubleshooting

### Erreur: "Email address X is invalid"
**Cause:** Email à domaine rejeté
**Solution:** Utiliser un domaine standard (.dz, .fr, etc.)

### Erreur: "User already exists"
**Cause:** Email déjà utilisé
**Solution:** Changer l'email ou utiliser un nouveau compte

### Menu ne se filtre pas
**Cause:** Cache navigateur ou context non mis à jour
**Solution:** Rafraîchir la page ou vider le cache

### Utilisateur ne voit pas les pages
**Cause:** pages_visibles non correctement défini
**Solution:** Vérifier dans la DB et corriger si nécessaire

---

## ✅ Checklist Finale

Avant de considérer les tests comme réussis:
- [ ] 5 utilisateurs créés (1 per rôle)
- [ ] Chaque utilisateur peut se connecter
- [ ] Menu filtre correctement les pages
- [ ] Accès direct à pages non autorisées → "Accès Refusé"
- [ ] Admin peut créer/modifier/supprimer (sauf Super Admin)
- [ ] Technicien/Commercial/Support ne voient pas menu "Utilisateurs"
- [ ] Boutons "Créer/Modifier/Supprimer" visibles selon permissions
- [ ] Tous les tests de scénarios passent

---

**Créé:** 19 novembre 2025  
**Version:** 1.0  
**Statut:** ✅ Prêt pour tests
