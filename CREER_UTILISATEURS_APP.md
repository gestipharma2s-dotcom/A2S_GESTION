# 👥 Créer les Utilisateurs depuis l'Application

## ✅ Vue d'ensemble

Vous pouvez créer les utilisateurs **directement depuis l'application** sans passer par SQL ou Supabase Console.

### Fonctionnement:

1. **L'application crée automatiquement:**
   - ✅ Compte Supabase Auth
   - ✅ Profil utilisateur en BD
   - ✅ Rôle et permissions

2. **Fonctionnalité email intelligente:**
   - 📧 Essaie le domaine réel (admin@a2s.dz)
   - 🔄 Fallback automatique à Gmail si rejeté
   - 💾 Email réel toujours stocké en BD

---

## 🚀 Étapes: Créer un utilisateur

### Prérequis:
- ✅ Vous êtes connecté
- ✅ Vous avez le rôle `super_admin` ou `admin`
- ✅ La permission "Gestion des utilisateurs"

### Processus:

#### **ÉTAPE 1: Aller à la page Utilisateurs**

```
Menu Principal → Utilisateurs (👥)
```

Vous verrez la liste des utilisateurs actuels.

#### **ÉTAPE 2: Cliquer "Créer Utilisateur"**

```
Bouton "➕ Créer Utilisateur" (en haut à droite)
```

#### **ÉTAPE 3: Remplir le formulaire**

```
Nom Complet:           Administrateur Super
Email:                 admin@a2sgestion.fr
Mot de Passe:          AdminPass123!@#Secure
Rôle:                  👑 Super Administrateur
Pages (optionnel):     (ignoré pour admin/super_admin)
```

**Champs obligatoires:**
- ✅ Nom Complet: 2-100 caractères
- ✅ Email: Format valide (ex: test@example.com)
- ✅ Mot de Passe: 8+ caractères
- ✅ Rôle: 1 des 5 rôles valides

#### **ÉTAPE 4: Sélectionner le Rôle**

Cliquer sur dropdown "Rôle" et choisir:

```
👑 Super Administrateur  ← Accès complet
🔐 Administrateur        ← Presque tout accès
🔧 Technicien            ← Opérations techniques
💼 Commercial            ← Gestion commerciale
🎧 Support              ← Support utilisateurs
```

La permission affichée change selon le rôle.

#### **ÉTAPE 5: Sélectionner Pages (si rôle non-admin)**

Pour les rôles autre que `super_admin`/`admin`:

```
☑️ Tableau de Bord
☑️ Prospects
☑️ Clients
☑️ Installations
☑️ Abonnements
☑️ Paiements
☑️ Support
☑️ Interventions
☑️ Alertes
☑️ Applications
☑️ Utilisateurs (selon permission)
```

**Minimum 1 page** requise.

#### **ÉTAPE 6: Cliquer "Créer"**

```
Bouton "Créer" (en bas à droite)
```

**Résultat:**
- ✅ Utilisateur créé
- ✅ Email envoyé (confirmation)
- ✅ Redirection vers liste utilisateurs

---

## 🧪 Exemple: Créer Super Admin depuis l'App

### Formulaire:

```
Nom Complet:           Administrateur Super
Email:                 admin@a2sgestion.fr
Mot de Passe:          AdminPass123!@#Secure
Rôle:                  👑 Super Administrateur
Pages Accessibles:     (N/A - accès complet automatique)
```

### Résultat immédiat:

✅ Super admin créé et accessible dans la liste

```
Administrateur Super  | admin@a2sgestion.fr | 👑 Super Administrateur | Créé à 14:32
```

### Utilisation:

L'utilisateur peut se connecter avec:
```
Email:    admin@a2sgestion.fr
Password: AdminPass123!@#Secure
```

---

## 👤 Les 5 Rôles & Leurs Pages

### 1️⃣ Super Administrateur (`super_admin`)

**Accès:** Toutes les pages + Toutes les fonctionnalités

```
Pages: 11/11
├── Dashboard
├── Prospects
├── Clients
├── Installations
├── Abonnements
├── Paiements
├── Support
├── Interventions
├── Alertes
├── Applications
└── Utilisateurs (CRUD complet)

Actions: Créer ✅ | Modifier ✅ | Supprimer ✅
```

### 2️⃣ Administrateur (`admin`)

**Accès:** Presque tout sauf super_admin

```
Pages: 10/11 (tout sauf utilisateurs)
├── Dashboard
├── Prospects
├── Clients
├── Installations
├── Abonnements
├── Paiements
├── Support
├── Interventions
├── Alertes
└── Applications

Actions: Créer ✅ | Modifier ✅ | Supprimer ✅
Limite: Ne peut pas modifier les super_admins
```

### 3️⃣ Technicien (`technicien`)

**Accès:** Opérations techniques

```
Pages: 5/11
├── Dashboard
├── Clients
├── Installations
├── Interventions
└── Alertes

Actions: Lire ✅ | Créer ✅ | Modifier ✅
Limite: Pas de suppression
```

### 4️⃣ Commercial (`commercial`)

**Accès:** Gestion commerciale

```
Pages: 6/11
├── Dashboard
├── Prospects
├── Clients
├── Abonnements
├── Paiements
└── Applications

Actions: Lire ✅ | Créer ✅ | Modifier ✅
Limite: Pas de suppression
```

### 5️⃣ Support (`support`)

**Accès:** Support utilisateurs

```
Pages: 4/11
├── Dashboard
├── Clients (lecture)
├── Support
└── Alertes

Actions: Lire ✅ | Répondre ✅
Limite: Pas de création/suppression
```

---

## ⚠️ Erreurs Courantes & Solutions

### ❌ "Vous n'avez pas la permission..."

**Cause:** Votre rôle n'a pas accès à la gestion des utilisateurs

**Solution:**
- Super admin ou admin peut créer des utilisateurs
- Autres rôles: Contactez un admin

### ❌ "Email invalide"

**Cause:** Format email incorrect

**Solution:**
```
✅ Valide:  admin@a2sgestion.fr
✅ Valide:  test.user@example.com
✅ Valide:  user+tag@domain.dz
❌ Invalide: admin@
❌ Invalide: @example.com
```

### ❌ "Mot de passe faible"

**Cause:** Mot de passe < 8 caractères ou pas assez complexe

**Solution:**
```
✅ Valide:     AdminPass123!@#Secure
✅ Valide:     MySecure2025Pass
❌ Invalide:   12345678 (nombre seulement)
❌ Invalide:   password (trop commun)
```

### ❌ "Rôle invalide: Technicien"

**Cause:** Majuscule au lieu de minuscule

**Solution:**
```
✅ Valide:   technicien (minuscules)
✅ Valide:   super_admin (underscore)
❌ Invalide: Technicien (majuscule)
❌ Invalide: super-admin (tiret)
```

### ❌ "Email domaine rejeté"

**Cause:** Supabase rejette certains domaines

**Solution automatique:**
- L'app essaie le domaine réel (ex: .dz)
- Si rejeté: fallback à Gmail (`no-reply+user...@gmail.com`)
- Email réel toujours stocké en BD

**Résultat:** L'utilisateur reçoit les emails de confirmation

---

## 🔧 Modifier un Utilisateur

### Depuis la liste:

```
1. Aller à: Menu → Utilisateurs
2. Cliquer l'icône "✏️ Modifier"
3. Changer les données
4. Cliquer "Modifier"
```

**Can modify:**
- ✏️ Nom
- ✏️ Rôle
- ✏️ Pages Accessibles
- ✏️ Email (lecture seule - impossible via app)

**Cannot modify:**
- ❌ Mot de passe (via app)
- ❌ ID utilisateur

### Mot de passe:

Pour changer le mot de passe:
```
Option 1: Utilisateur clique "Mot de passe oublié" (reset email)
Option 2: Admin supprime l'utilisateur et le recrée
Option 3: Admin utilise Supabase Console (reset direct)
```

---

## 🗑️ Supprimer un Utilisateur

### Depuis la liste:

```
1. Menu → Utilisateurs
2. Cliquer l'icône "🗑️ Supprimer"
3. Confirmer "Oui, supprimer"
```

**Résultat:**
- ❌ Utilisateur supprimé de la BD
- ❌ Compte Supabase Auth supprimé
- ⚠️ Données associées conservées (projets, etc)

**Permissions:**
- ✅ Super admin: Peut supprimer TOUS
- ✅ Admin: Peut supprimer tout SAUF super_admin
- ❌ Autres: Impossible

---

## 📊 Tableau Récapitulatif: Créer vs Modifier

| Opération | Champ | Créer | Modifier |
|-----------|-------|-------|----------|
| Nom | Obligatoire | ✅ | ✅ |
| Email | Obligatoire | ✅ | 🔒 (lecture) |
| Mot de passe | Obligatoire | ✅ | ❌ (reset via email) |
| Rôle | Obligatoire | ✅ | ✅ |
| Pages | Optionnel | ✅ | ✅ |

---

## 🎯 Scénario Complet: Créer Équipe

### Situation:
Créer une équipe de 3 utilisateurs: Admin, Technicien, Commercial

### ÉTAPE 1: Créer Admin

```
Nom:       Jean Dupont
Email:     jean@a2sgestion.fr
Password:  JeanPass123!Secure
Rôle:      🔐 Administrateur
```

➜ ✅ Créé. Jean reçoit email de confirmation.

### ÉTAPE 2: Créer Technicien

```
Nom:       Marc Martin
Email:     marc@a2sgestion.fr
Password:  MarcPass123!Secure
Rôle:      🔧 Technicien
Pages:     ☑️ Dashboard
            ☑️ Clients
            ☑️ Installations
            ☑️ Interventions
            ☑️ Alertes
```

➜ ✅ Créé. Marc accès seulement pages technique.

### ÉTAPE 3: Créer Commercial

```
Nom:       Sophie Bernard
Email:     sophie@a2sgestion.fr
Password:  SophiePass123!Secure
Rôle:      💼 Commercial
Pages:     ☑️ Dashboard
            ☑️ Prospects
            ☑️ Clients
            ☑️ Abonnements
            ☑️ Paiements
            ☑️ Applications
```

➜ ✅ Créé. Sophie accès pages commerciales.

### Résultat:

```
Liste Utilisateurs:
─────────────────────────────────────────
Jean Dupont        | Admin       | ✅
Marc Martin        | Technicien  | ✅
Sophie Bernard     | Commercial  | ✅
```

Chaque utilisateur:
- ✅ Reçoit email de confirmation
- ✅ Crée compte + profil automatiquement
- ✅ Peut se connecter immédiatement
- ✅ Voit seulement ses pages

---

## 🔐 Sécurité

### Email Intelligent:

```
Étape 1: Essayer email réel
         admin@a2s.dz
         ↓
         ✅ Accepté → Utiliser cet email
         ❌ Rejeté  → Aller à Étape 2

Étape 2: Fallback à Gmail
         no-reply+user.XXX@gmail.com
         ↓
         ✅ Accepté → Utiliser ce email
         ❌ Rejeté  → Erreur (domaine invalide)

BD (toujours):
         Email réel stocké = admin@a2s.dz
```

### Mot de passe:

```
Créé avec: bcrypt (Supabase Auth)
Longueur: 8+ caractères
Complexité: Recommandé (maj, min, chiffre, special)
Changement: Email reset ou admin via Console
```

---

## 📞 Support

**Si vous avez des problèmes:**

1. ✅ Vérifier que vous êtes `super_admin` ou `admin`
2. ✅ Vérifier format email et mot de passe
3. ✅ Vérifier rôle (minuscules!)
4. ✅ Voir console (F12 → Console) pour erreurs détaillées
5. ✅ Consulter `GERER_UTILISATEURS.md` pour plus de détails

---

**Status:** ✅ Système production-ready  
**Sécurité:** ✅ Validations strictes  
**Date:** 19 novembre 2025
