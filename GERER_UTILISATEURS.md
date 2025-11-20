# 🔧 GÉRER LES UTILISATEURS - Guide Complet

## 🎯 Objectif

Gérer les utilisateurs (créer, modifier, supprimer) avec validation des rôles et permissions.

## ❌ Erreur Rencontrée

**Erreur**: `users_role_check - new row for relation "users" violates check constraint`

**Cause**: Rôle invalide ou malformé envoyé à la base de données

**Solution**: Validation stricte des rôles dans le code

---

## ✅ Rôles Valides

Vous DEVEZ utiliser EXACTEMENT ces rôles (minuscules, tirets bas):

| Code | Nom | Accès Pages | Permissions |
|------|-----|-------------|-------------|
| `super_admin` | 👑 Super Admin | 11/11 | TOUT |
| `admin` | 🔐 Administrateur | 10/11 | TOUT sauf super_admin |
| `technicien` | 🔧 Technicien | 5/11 | Clients, Installations, Support, Interventions, Alertes |
| `commercial` | 💼 Commercial | 6/11 | Prospects, Clients, Installations, Abonnements, Paiements, Alertes |
| `support` | 🎧 Support | 4/11 | Support, Interventions, Clients, Alertes |

⚠️ **NE PAS UTILISER:**
- ❌ `Technicien` (majuscule)
- ❌ `technicien ` (espace)
- ❌ `technician` (anglais)
- ❌ Anything else

---

## 📋 Créer un Utilisateur

### Via Interface

1. **Menu** → **Utilisateurs**
2. Cliquer **Créer Utilisateur**
3. Remplir formulaire:
   ```
   Nom: Jean Dupont
   Email: jean@a2s.dz
   Mot de passe: MotdePasse123!@#
   Rôle: technicien ← Sélectionner dans dropdown
   Pages visibles: (auto-remplies selon rôle)
   ```
4. Cliquer **Créer**

### Résultat Attendu

```
✅ Utilisateur créé avec succès
✅ Email: jean@a2s.dz (réel)
✅ Supabase Auth: no-reply+user.xxx@gmail.com (si domaine rejeté)
✅ Role: technicien
✅ Pages: dashboard, installations, support, ...
```

---

## ✏️ Modifier un Utilisateur

### Via Interface

1. **Menu** → **Utilisateurs**
2. Trouver utilisateur
3. Cliquer **Modifier** (crayon)
4. Modifier champs:
   ```
   Nom: (peut changer)
   Email: (peut changer)
   Mot de passe: (laisser vide - utilisateur change lui-même)
   Rôle: technicien → admin (par exemple)
   Pages visibles: (auto-mises à jour)
   ```
5. Cliquer **Modifier**

### Points Importants

- **Rôle DOIT être valide**: `super_admin`, `admin`, `technicien`, `commercial`, `support`
- **Email DOIT être unique** (sauf si pas changé)
- **Mot de passe**: Laisser VIDE (utilisateur change lui-même via reset)
- **Pages visibles**: Auto-remplies selon rôle

---

## 🗑️ Supprimer un Utilisateur

### Via Interface

1. **Menu** → **Utilisateurs**
2. Trouver utilisateur
3. Cliquer **Supprimer** (corbeille)
4. Confirmer suppression
5. ⚠️ **IRRÉVERSIBLE!**

### Restrictions

- **Super Admin**: Seul super_admin peut supprimer super_admin
- **Admin**: Peut supprimer admin, technicien, commercial, support (PAS super_admin)
- **Autres**: Ne peuvent supprimer personne

---

## ⚠️ Erreurs Courantes

### Erreur: "violates check constraint users_role_check"

**Cause**: Rôle invalide

**Solution**: Vérifier exactement:
```javascript
// ✅ VALIDES (minuscules, underscore)
super_admin
admin
technicien
commercial
support

// ❌ INVALIDES
SuperAdmin      // Majuscules
Super Admin      // Espace
super-admin      // Tiret au lieu de underscore
technician       // Anglais
adminstrator     // Typo
```

### Erreur: "Rôle invalide"

**Cause**: Le code n'accepte que les 5 rôles définis

**Solution**: Utiliser EXACTEMENT un des 5 rôles ci-dessus

### Erreur: "Email already exists"

**Cause**: Email déjà utilisé par un autre utilisateur

**Solution**: Choisir email différent ou supprimer l'ancien utilisateur

### Erreur: "PERMISSION_DENIED"

**Cause**: Vous n'avez pas les permissions

**Solution**: 
- Seul `super_admin` peut créer/modifier/supprimer tous
- `admin` ne peut pas gérer `super_admin`
- Les autres rôles ne peuvent rien gérer

---

## 🔐 Permissions d'Accès

### Qui Peut Créer des Utilisateurs?

```
✅ super_admin  → Peut créer N'IMPORTE QUEL rôle
✅ admin        → Peut créer admin, technicien, commercial, support (pas super_admin)
❌ Autres       → Ne peuvent pas créer
```

### Qui Peut Modifier?

```
✅ super_admin  → Peut modifier TOUT (y compris super_admin)
✅ admin        → Peut modifier admin, technicien, commercial, support (pas super_admin)
❌ Autres       → Ne peuvent pas modifier
```

### Qui Peut Supprimer?

```
✅ super_admin  → Peut supprimer TOUT
✅ admin        → Peut supprimer admin, technicien, commercial, support (pas super_admin)
❌ Autres       → Ne peuvent pas supprimer
```

---

## 📊 Pages Visibles Par Rôle

### Super Admin

```
✅ Toutes les 11 pages (automatique)
```

### Admin

```
✅ 10 pages (toutes sauf Utilisateurs)
```

### Technicien

```
✅ Dashboard
✅ Clients
✅ Installations
✅ Support
✅ Interventions
✅ Alertes
```

### Commercial

```
✅ Dashboard
✅ Prospects
✅ Clients
✅ Installations
✅ Abonnements
✅ Paiements
✅ Alertes
```

### Support

```
✅ Dashboard
✅ Support
✅ Interventions
✅ Clients
✅ Alertes
```

---

## 💾 Format Données Correctes

### CREATE

```javascript
{
  nom: "Jean Dupont",              // String, obligatoire
  email: "jean@a2s.dz",            // String, obligatoire
  password: "SecurePass123!@#",    // String, obligatoire
  role: "technicien",              // String, DOIT être valide
  pages_visibles: ["dashboard", "installations"]  // Array (optionnel)
}
```

### UPDATE

```javascript
{
  nom: "Jean Dupont",              // Peut changer
  email: "jean@a2s.dz",            // Peut changer
  password: "",                    // LAISSER VIDE (utilisateur change lui-même)
  role: "admin",                   // DOIT être valide
  pages_visibles: ["dashboard"]    // Peut changer
}
```

---

## 🧪 Test Complet

### 1. Créer utilisateur

```
Formulaire:
├─ Nom: Test User
├─ Email: test@a2s.dz
├─ Mot de passe: Test123!@#
└─ Rôle: technicien

Résultat attendu: ✅ Créé
```

### 2. Vérifier en base

```sql
SELECT nom, email, role, pages_visibles 
FROM users 
WHERE email = 'test@a2s.dz';

-- Résultat attendu:
-- nom: Test User
-- email: test@a2s.dz
-- role: technicien
-- pages_visibles: [...]
```

### 3. Modifier utilisateur

```
Cliquer Modifier:
├─ Nom: Test User 2 (change)
├─ Rôle: admin (change)
└─ Cliquer Modifier

Résultat attendu: ✅ Modifié
```

### 4. Vérifier modification

```sql
SELECT nom, role FROM users WHERE email = 'test@a2s.dz';

-- Résultat attendu:
-- nom: Test User 2
-- role: admin
```

### 5. Supprimer utilisateur

```
Cliquer Supprimer:
└─ Confirmer

Résultat attendu: ✅ Supprimé
```

### 6. Vérifier suppression

```sql
SELECT COUNT(*) FROM users WHERE email = 'test@a2s.dz';

-- Résultat attendu: 0
```

---

## 📋 Checklist

- [ ] Vous êtes super_admin ou admin?
- [ ] Rôle à assigner est valide?
- [ ] Email n'existe pas déjà?
- [ ] Mot de passe fort (création)?
- [ ] Pages visibles correctes?
- [ ] Modification terminée?
- [ ] Utilisateur peut se connecter?

---

## 🆘 Si Ça Ne Marche Pas

1. **Vérifier console** (F12 → Console)
2. **Vérifier erreur exacte** (message d'erreur)
3. **Vérifier BD** (SQL query)
4. **Vérifier permissions** (qui peut faire quoi)
5. **Contacter support** si besoin

---

## 📚 Références

- GESTION_ROLES_PERMISSIONS.md - Permissions détaillées
- QUICK_START_SETUP.md - Setup utilisateurs
- TROUBLESHOOT_LOGIN.md - Problèmes login

---

**Status**: ✅ Validation stricte implémentée  
**Sécurité**: ✅ Rôles vérifiés  
**Production**: ✅ Prêt
