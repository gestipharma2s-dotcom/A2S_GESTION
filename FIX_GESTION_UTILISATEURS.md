# 🔧 FIX: Gestion des Utilisateurs - Validation des Rôles

## ✅ Problème Résolu

**Erreur rencontrée:**
```
PATCH /rest/v1/users → 400 Bad Request
users_role_check - new row for relation "users" violates check constraint
```

**Cause Root:**
- Rôle invalide ou malformé envoyé à la BD
- Pas de validation du rôle dans le code
- Contrainte CHECK en BD rejette les rôles invalides

**Solution:**
- Validation stricte des rôles dans `userService.js`
- Messages d'erreur clairs
- Documentation complète

---

## 🔧 Modifications Code

### Fichier: `src/services/userService.js`

**Ajout:**
1. Import des ROLES constants
2. Validation stricte dans `create()`
3. Validation stricte dans `update()`

**Avant:**
```javascript
// Pas de validation du rôle
const { data, error } = await supabase
  .from(TABLES.USERS)
  .update(dataToUpdate)  // ❌ Peut avoir rôle invalide
  .eq('id', id);
```

**Après:**
```javascript
// Validation stricte
const validRoles = Object.values(ROLES);
if (userData.role && !validRoles.includes(userData.role)) {
  const error = new Error(`Rôle invalide: "${userData.role}". Rôles valides: ${validRoles.join(', ')}`);
  error.code = 'INVALID_ROLE';
  throw error;
}
```

---

## 📋 Les 5 Rôles Valides

**DOIT utiliser EXACTEMENT ces valeurs:**

```
super_admin     ← 👑 Super Administrateur
admin           ← 🔐 Administrateur
technicien      ← 🔧 Technicien
commercial      ← 💼 Commercial
support         ← 🎧 Support
```

**❌ NE PAS UTILISER:**
- Majuscules: `Super_Admin`, `ADMIN`
- Tirets: `super-admin` (doit être `super_admin`)
- Anglais: `administrator`, `technician`
- Noms complets: `super_administrateur`

---

## 🧪 Test

### Créer Utilisateur (Correct)

```
Nom: Test User
Email: test@a2s.dz
Rôle: technicien ← Valide ✅
```

Résultat: **✅ Créé avec succès**

### Modifier Utilisateur (Correct)

```
Rôle: admin ← Valide ✅
```

Résultat: **✅ Modifié avec succès**

### Créer avec Rôle Invalide (Avant Fix)

```
Rôle: Technicien ← Invalide ❌ (majuscule)
```

Résultat: **❌ violates check constraint**

### Créer avec Rôle Invalide (Après Fix)

```
Rôle: Technicien ← Invalide ❌
```

Résultat: **✅ Erreur claire: "Rôle invalide: Technicien. Rôles valides: super_admin, admin, ..."**

---

## 📊 Permissions par Rôle

| Rôle | Créer | Modifier | Supprimer | Pages |
|------|-------|----------|-----------|-------|
| super_admin | ✅ Tous | ✅ Tous | ✅ Tous | 11/11 |
| admin | ✅ Sauf super_admin | ✅ Sauf super_admin | ✅ Sauf super_admin | 10/11 |
| technicien | ❌ | ❌ | ❌ | 5/11 |
| commercial | ❌ | ❌ | ❌ | 6/11 |
| support | ❌ | ❌ | ❌ | 4/11 |

---

## 🚀 Utilisation

### Créer Utilisateur

```
1. Menu → Utilisateurs
2. Cliquer "Créer Utilisateur"
3. Remplir formulaire
4. Sélectionner rôle: technicien / admin / super_admin / commercial / support
5. Cliquer "Créer"
```

### Modifier Utilisateur

```
1. Menu → Utilisateurs
2. Cliquer "Modifier" (crayon)
3. Changer rôle si nécessaire
4. Cliquer "Modifier"
```

### Supprimer Utilisateur

```
1. Menu → Utilisateurs
2. Cliquer "Supprimer" (corbeille)
3. Confirmer
```

---

## 📖 Documentation

**Pour plus de détails:**
- `GERER_UTILISATEURS.md` - Guide complet gestion utilisateurs
- `ROLES_VALIDES.md` - Référence rapide rôles
- `GESTION_ROLES_PERMISSIONS.md` - Détails permissions
- `QUICK_START_SETUP.md` - Setup initial

---

## ✅ Checklist

- [x] Import ROLES constants
- [x] Validation create()
- [x] Validation update()
- [x] Messages d'erreur clairs
- [x] Documentation complète
- [x] Tests validés
- [x] Code compilé sans erreurs

---

## 🔍 Détails Techniques

### Validation Implementation

**Location:** `src/services/userService.js`

**Functions:**
- `create()` - Lines 128-145 (validation)
- `update()` - Lines 193-210 (validation)

**Constants:**
- `ROLES` - Imported from `utils/constants.js`

**Error Handling:**
- Code: `INVALID_ROLE`
- Message: `Rôle invalide: "{value}". Rôles valides: {list}`

---

## 🎓 Erreurs Courantes & Solutions

### Erreur: "violates check constraint users_role_check"

**Cause:** Rôle invalide en BD

**Solution:** 
1. Utiliser un des 5 rôles valides
2. Vérifier exactement: minuscules, underscore
3. Voir `ROLES_VALIDES.md`

### Erreur: "Rôle invalide: Technicien"

**Cause:** Majuscule au lieu de minuscule

**Solution:** Utiliser `technicien` (minuscules)

### Erreur: "Rôle invalide: super-admin"

**Cause:** Tiret au lieu d'underscore

**Solution:** Utiliser `super_admin` (underscore)

---

## 📞 Support

Si erreur persiste:
1. Vérifier console (F12 → Console)
2. Consulter `GERER_UTILISATEURS.md`
3. Vérifier rôle exactement
4. Contacter support

---

**Status:** ✅ COMPLÈTEMENT RÉSOLU  
**Sécurité:** ✅ Validation stricte  
**Production:** ✅ Prêt  

**Date:** 19 novembre 2025
