# 🔧 DEBUG: Problème Création Utilisateurs

## 📋 Erreur Rencontrée

```
Error: new row for relation "users" violates check constraint "users_role_check"
```

## 🔍 Cause Root

Le rôle envoyé à la BD ne correspond pas aux 5 rôles valides:
- `super_admin`
- `admin`
- `technicien`
- `commercial`
- `support`

## 🛠️ Corrections Appliquées

### 1. **Normalisation du Rôle**

**Avant:**
```javascript
if (!userData.role || !validRoles.includes(userData.role)) {
  throw new Error(`Rôle invalide...`);
}
```

**Après:**
```javascript
const trimmedRole = userData.role?.trim().toLowerCase();
if (!trimmedRole || !validRoles.includes(trimmedRole)) {
  throw new Error(`Rôle invalide...`);
}
userData.role = trimmedRole;  // ← Utiliser le rôle nettoyé
```

**Impact:**
- ✅ Supprime espaces inutiles
- ✅ Convertit en minuscules
- ✅ Valide strictement

### 2. **Normalisation des Pages**

**Avant:**
```javascript
pages_visibles: userData.pages_visibles || []
```

**Après:**
```javascript
pages_visibles: Array.isArray(userData.pages_visibles) ? userData.pages_visibles : []
```

**Impact:**
- ✅ S'assure que c'est un tableau
- ✅ Éite les objets malformés

## ✅ Valeurs Acceptées Maintenant

### Rôles (Exact Match):
```
✅ super_admin   (minuscules, underscore)
✅ admin
✅ technicien
✅ commercial
✅ support

❌ Super_Admin    (majuscule)
❌ super-admin    (tiret)
❌ "super_admin " (espace)
❌ SUPER_ADMIN    (majuscules)
```

## 🧪 Test: Créer un Utilisateur

### Formulaire:

```
Nom:      Test User
Email:    test@a2sgestion.fr
Password: TestPass123!
Rôle:     technicien  ← Exact!
Pages:    ☑️ Dashboard
          ☑️ Installations
```

### Attendu:

```
✅ Utilisateur créé
✅ Email: test@a2sgestion.fr
✅ Rôle: technicien (validé)
```

### Si Erreur:

```
❌ Erreur: "new row for relation users violates check constraint users_role_check"
```

Vérifier:
1. ✅ Le rôle est l'un des 5 valides
2. ✅ Le rôle est en MINUSCULES
3. ✅ Pas d'espaces avant/après
4. ✅ Pas de tirets (utiliser underscore)

## 📊 Code Changes Summary

**File:** `src/services/userService.js`

**Lines 128-145 (create method):**
- ✅ Ajout trim() et toLowerCase()
- ✅ Validation stricte du rôle
- ✅ Assignment du rôle nettoyé

**Lines 215-230 (update method):**
- ✅ Même logique pour les mises à jour
- ✅ Validation + normalisation

**Lines 185-195 (insert data):**
- ✅ Normalisation des pages_visibles

## 🚀 Prochaines Étapes

1. ✅ Corrections appliquées
2. ➜ Recharger l'app (F5 si en dev)
3. ➜ Essayer créer un utilisateur avec un des 5 rôles
4. ➜ Vérifier que ça fonctionne

## 📞 Si Toujours en Erreur

Vérifier en console (F12):
```javascript
// Tester la validation
const ROLES = {
  SUPER_ADMIN: 'super_admin',
  ADMIN: 'admin',
  TECHNICIEN: 'technicien',
  COMMERCIAL: 'commercial',
  SUPPORT: 'support'
};

const validRoles = Object.values(ROLES);
console.log('Rôles valides:', validRoles);
// ['super_admin', 'admin', 'technicien', 'commercial', 'support']

const testRole = "technicien";
console.log('Test inclus?', validRoles.includes(testRole));
// true ✅
```

---

**Status:** ✅ Corrections appliquées  
**Test:** À faire depuis l'app  
**Date:** 19 novembre 2025
