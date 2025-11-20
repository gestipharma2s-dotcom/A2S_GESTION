# 🔬 INSTRUCTIONS POUR LE DÉVELOPPEUR/TESTEUR

## 🎯 Objectif
Valider que le fix d'email fonctionne correctement et tester le système complet de permissions.

---

## 📋 Checklist Avant Démarrage

- [ ] Repository à jour (`git pull`)
- [ ] Node.js 16+ installé (`node --version`)
- [ ] `npm install` exécuté (si besoin)
- [ ] Supabase credentials configurées
- [ ] Dev server arrêté (`Ctrl+C` dans terminal)

---

## 🛠️ Phase 1: Préparation

### 1.1 Vérifier le Code Modifié

```bash
# Voir les changements dans userService.js
cat src/services/userService.js | grep -A 10 "const timestamp"

# Résultat attendu:
# const timestamp = Date.now();
# const random = Math.floor(Math.random() * 1000000);
# const authEmail = `temp.user+${timestamp}.${random}@a2sgestion.fr`;
```

### 1.2 Compiler le Projet

```bash
npm run build

# Output attendu:
# ✓ 2187 modules transformed
# built in X.XXs ✅ SUCCÈS
```

### 1.3 Démarrer le Dev Server

```bash
npm run dev

# Output attendu:
# ➜ Local: http://localhost:3000/ 
# ➜ ready in XXXms ✅ PRÊT
```

### 1.4 Ouvrir le Navigateur

```
http://localhost:3000/
Attendre le chargement complet
```

---

## 🧪 Phase 2: Test Email Temporaire

### 2.1 Se Connecter en tant qu'Admin

```
Email: admin@a2sgestion.fr  (ou votre admin)
Mot de passe: (votre mot de passe)
Bouton: Se connecter
```

**Résultat attendu:**
- ✅ Page charge
- ✅ Menu visible avec "Utilisateurs"
- ✅ Aucune erreur en console (F12)

### 2.2 Naviguer vers Utilisateurs

```
Menu → Utilisateurs
ou
URL: http://localhost:3000/#/utilisateurs
```

**Résultat attendu:**
- ✅ Liste des utilisateurs charge
- ✅ Tableau visible avec colonnes (Nom, Email, Rôle)
- ✅ Bouton "Créer Utilisateur" visible

### 2.3 Créer Premier Utilisateur Test

```
Cliquer: "Créer Utilisateur"
Formulaire s'ouvre ✅

Remplir:
├─ Nom: Jean Technicien
├─ Email: jean.tech@a2s.dz  ← IMPORTANT: Domaine .dz
├─ Mot de passe: Test123!
├─ Rôle: Technicien
└─ Pages: ☑ Dashboard, ☑ Installations, ☑ Abonnements, ☑ Support, ☑ Interventions

Cliquer: Créer
```

**Résultat Attendu:**
- ✅ Message: "Utilisateur créé avec succès"
- ✅ ❌ ERREUR: "Email is invalid" → FIX NE MARCHE PAS
- ✅ Nouveau user dans liste
- ✅ Email affiché: jean.tech@a2s.dz

**Si Erreur "Email is invalid":**
```
1. F12 → Console → Copier le message d'erreur
2. Vérifier que le code a changé (Ctrl+Shift+R)
3. Vérifier la compilation (npm run build)
4. Contacter pour assistance
```

### 2.4 Vérifier la Création dans Supabase

```
Aller à: https://supabase.com/dashboard
Projet → Authentication → Users
Chercher: "jean" ou "1719234"
Voir: email = temp.user+1719234567.123456@a2sgestion.fr ✅

Aller à: Projet → SQL Editor
Exécuter:
SELECT id, nom, email, role FROM users 
WHERE nom = 'Jean Technicien';

Voir: email = jean.tech@a2s.dz ✅
```

---

## 🔐 Phase 3: Test Permissions

### 3.1 Créer Autres Utilisateurs Test

Répéter le processus pour:

**User 2: Commercial**
```
Nom: Marie Commerciale
Email: marie.commercial@a2s.dz
Rôle: Commercial
Pages: Dashboard, Prospects, Clients, Installations, Abonnements, Paiements
```

**User 3: Support**
```
Nom: Pierre Support
Email: pierre.support@a2s.dz
Rôle: Support
Pages: Dashboard, Support, Interventions, Clients
```

**Résultat:** 3 users créés sans erreur ✅

### 3.2 Tester Menu Filtering

**Se déconnecter et se connecter avec Technicien:**
```
Logout
Email: jean.tech@a2s.dz
Password: Test123!
Login
```

**Vérifier le Menu (Sidebar):**
```
✅ DOIT VOIR:
├─ Dashboard
├─ Installations
├─ Abonnements
├─ Support
└─ Interventions

❌ NE DOIT PAS VOIR:
├─ Prospects
├─ Clients
├─ Paiements
├─ Applications
└─ Utilisateurs
```

**Si Menu incorrect:**
```
1. F12 → Network → Disable cache
2. Ctrl+Shift+R (hard refresh)
3. Vérifier Sidebar.jsx filtre correctement
```

### 3.3 Tester Accès Page

**Technicien essaie d'accéder à une page non autorisée:**
```
1. URL: http://localhost:3000/#/prospects
2. Voir: Écran "Accès Refusé" 🔒
3. Lire: "Vous n'avez pas accès à cette page"
4. Cliquer: "Retour au Tableau de Bord"
```

**Résultat attendu:**
- ✅ Page refusée avec message clair
- ✅ Bouton retour fonctionne
- ✅ Pas d'erreur en console

### 3.4 Tester Gestion Utilisateurs

**Technicien essaie de gérer utilisateurs:**
```
1. Menu → Utilisateurs
2. Voir: Écran "Accès Refusé" 🔒
3. Pas de bouton "Créer Utilisateur"
```

**Admin peut gérer:**
```
1. Se déconnecter
2. Se connecter avec Admin
3. Menu → Utilisateurs
4. ✅ Liste visible
5. ✅ Bouton "Créer" visible
```

---

## 📊 Phase 4: Test Matrice Complète

### 4.1 Tableau de Test

| Utilisateur | Dashboard | Prospects | Clients | Utilisateurs |
|-------------|-----------|-----------|---------|--------------|
| **Jean (Tech)** | ✅ VOIR | ❌ REFUSÉ | ❌ REFUSÉ | ❌ REFUSÉ |
| **Marie (Comm)** | ✅ VOIR | ✅ VOIR | ✅ VOIR | ❌ REFUSÉ |
| **Pierre (Support)** | ✅ VOIR | ❌ REFUSÉ | ✅ VOIR | ❌ REFUSÉ |
| **Admin** | ✅ VOIR | ✅ VOIR | ✅ VOIR | ✅ GÉRER |

### 4.2 Exécuter Test

```bash
# Pour chaque utilisateur:
1. Se connecter
2. Vérifier le menu (items visibles)
3. Cliquer sur chaque page accessible
4. Essayer accès URL à page non autorisée
5. Vérifier les boutons (créer, modifier, supprimer)
6. Se déconnecter
```

---

## 🧮 Phase 5: Vérification Données

### 5.1 Vérifier Base de Données

```sql
-- SQL Editor dans Supabase

-- 1. Voir tous les utilisateurs
SELECT id, nom, email, role FROM users ORDER BY created_at DESC;

-- Résultat:
-- jean.tech@a2s.dz | Technicien
-- marie.commercial@a2s.dz | Commercial  
-- pierre.support@a2s.dz | Support

-- 2. Vérifier les permissions
SELECT role, pages_visibles FROM users WHERE nom = 'Jean Technicien';

-- Résultat:
-- technicien | ["dashboard", "installations", "abonnements", "support", "interventions"]

-- 3. Vérifier auth emails
SELECT email FROM auth.users WHERE raw_user_meta_data->>'email' LIKE '%@a2s.dz';

-- Résultat:
-- temp.user+1719234567.123456@a2sgestion.fr (email temporaire)
```

### 5.2 Vérifier Supabase Console

```
1. Aller à: Authentication → Users
2. Voir les 3+ utilisateurs créés
3. Chaque user a email temporaire
4. Status: Listed (ou selon votre config)
```

---

## 🐛 Phase 6: Troubleshooting

### Problème: "Email is invalid" encore

**Diagnostic:**
```bash
# 1. Vérifier le code est changé
grep -n "temp.user+" src/services/userService.js
# Output: devrait avoir la ligne avec temp.user+

# 2. Recompiler
npm run build
# Output: "built in X.XXs" ✅

# 3. Redémarrer dev server
# Ctrl+C, puis npm run dev

# 4. Hard refresh
# Ctrl+Shift+R dans navigateur
```

**Si toujours erreur:**
```
1. F12 → Application → Clear all
2. F12 → Network → Disable cache
3. Ctrl+Shift+R
4. Essayer à nouveau
```

### Problème: Menu ne filtre pas

**Diagnostic:**
```bash
# 1. Vérifier Sidebar.jsx
grep -A 2 "const menuItems" src/components/layout/Sidebar.jsx
# Output: devrait avoir .filter(item => hasAccess(item.id))

# 2. Console check
# F12 → Console
# Taper: localStorage
# Voir 'currentUser' avec le profil correct

# 3. Check AuthContext
grep -n "hasAccess" src/context/AuthContext.jsx
# Output: devrait avoir la fonction
```

### Problème: Utilisateur vu dans Supabase Auth mais pas en base

**Solution:**
```sql
-- Vérifier qu'il y a bien une ligne dans la table users
SELECT * FROM users WHERE id = '[user_id]';

-- Si vide: le profil n'a pas été créé
-- Solution: Insérer manuellement
INSERT INTO users (id, nom, email, role, pages_visibles)
VALUES ('[user_id]', 'Nom', 'email@a2s.dz', 'technicien', '["dashboard"]'::jsonb);
```

---

## ✅ Checklist Test Complet

- [ ] Code modifié ✅
- [ ] Compilation réussie ✅
- [ ] Dev server lancé ✅
- [ ] Premier user créé (domaine .dz) ✅
- [ ] 2e user créé (commercial) ✅
- [ ] 3e user créé (support) ✅
- [ ] Menu filtre pour Technicien ✅
- [ ] Page "Accès Refusé" fonctionne ✅
- [ ] Boutons masqués si pas permission ✅
- [ ] Tous les utilisateurs en base de données ✅
- [ ] Emails temporaires en Supabase Auth ✅
- [ ] Emails réels dans table users ✅
- [ ] Aucune erreur console ✅

---

## 📝 Rapport de Test

Créer un rapport avec:

```
Date: 19 novembre 2025
Testeur: [Votre nom]
Environnement: Windows/Mac, Chrome/Firefox

EMAIL FIX:
- [ ] Email .dz accepté: OUI/NON
- [ ] Email réel sauvegardé: OUI/NON
- [ ] Email temporaire généré: OUI/NON
- [ ] Aucune erreur: OUI/NON

PERMISSIONS:
- [ ] Menu filtre correctement: OUI/NON
- [ ] Accès refusé fonctionne: OUI/NON
- [ ] Boutons masqués: OUI/NON
- [ ] Services valident: OUI/NON

GÉNÉRAL:
- [ ] Compilation OK: OUI/NON
- [ ] Aucune erreur console: OUI/NON
- [ ] Performance acceptable: OUI/NON
- [ ] Prêt pour production: OUI/NON

Remarques:
[Ajouter toute observation]
```

---

## 🎉 Si Tout Fonctionne

```
✅ Email temporaire génère correctement
✅ Email réel sauvegardé en base
✅ Toutes les pages filtrées selon rôle
✅ Accès refusé affiche correctement
✅ Aucune erreur en console
✅ Permissions respectées partout

RÉSULTAT: 🟢 PRÊT POUR PRODUCTION
```

---

**Document:** Instructions Testeur  
**Version:** 1.0  
**Date:** 19 novembre 2025  
**Status:** ✅ Prêt à utiliser
