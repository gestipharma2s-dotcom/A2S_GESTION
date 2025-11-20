# 🔐 Système Complet de Contrôle d'Accès

## 📋 Vue d'ensemble

Le système implémente un contrôle d'accès complet basé sur:
- **Rôles** (super_admin, admin, technicien, commercial, support)
- **Permissions** (créer, modifier, supprimer utilisateurs)
- **Pages Visibles** (accès aux différentes pages de l'application)

---

## 🎯 Hiérarchie des Rôles

```
Super Admin (👑)
    ↓
Admin (🔐)
    ↓
Technicien (🔧) | Commercial (💼) | Support (🎧)
```

---

## 📄 Pages Disponibles

```
1. dashboard          - Tableau de bord principal
2. prospects          - Gestion des prospects
3. clients            - Gestion des clients
4. installations      - Gestion des installations
5. abonnements        - Gestion des abonnements
6. paiements          - Paiements et historique
7. support            - Support technique
8. interventions      - Interventions et journal
9. applications       - Gestion des applications
10. utilisateurs      - Gestion des utilisateurs
```

---

## 🔑 Accès par Rôle

### Super Admin (👑)
**Pages:** ✅ TOUTES
```
✅ dashboard
✅ prospects
✅ clients
✅ installations
✅ abonnements
✅ paiements
✅ support
✅ interventions
✅ applications
✅ utilisateurs
```

### Admin (🔐)
**Pages:** ✅ TOUTES
```
✅ dashboard
✅ prospects
✅ clients
✅ installations
✅ abonnements
✅ paiements
✅ support
✅ interventions
✅ applications
✅ utilisateurs
```

### Technicien (🔧)
**Pages par défaut:**
```
✅ dashboard
✅ installations
✅ abonnements
✅ support
✅ interventions
❌ prospects
❌ clients
❌ paiements
❌ applications
❌ utilisateurs
```

### Commercial (💼)
**Pages par défaut:**
```
✅ dashboard
✅ prospects
✅ clients
✅ installations
✅ abonnements
✅ paiements
✅ alertes/notifications
❌ support
❌ interventions
❌ applications
❌ utilisateurs
```

### Support (🎧)
**Pages par défaut:**
```
✅ dashboard
✅ support
✅ interventions
✅ clients
❌ prospects
❌ installations
❌ abonnements
❌ paiements
❌ applications
❌ utilisateurs
```

---

## 🛡️ Contrôle d'Accès aux Actions

### Créer un Utilisateur
```
✅ Super Admin: OUI
✅ Admin: OUI
❌ Technicien: NON
❌ Commercial: NON
❌ Support: NON
```

### Modifier un Utilisateur
```
✅ Super Admin: OUI (n'importe qui)
✅ Admin: OUI (sauf Super Admin)
❌ Technicien: NON
❌ Commercial: NON
❌ Support: NON
```

### Supprimer un Utilisateur
```
✅ Super Admin: OUI (n'importe qui)
✅ Admin: OUI (sauf Super Admin)
❌ Technicien: NON
❌ Commercial: NON
❌ Support: NON
```

---

## 🔄 Flux de Vérification d'Accès

### 1. **Authentification**
```
Utilisateur se connecte
    ↓
AuthContext charge le profil
    ↓
Profil inclut: nom, email, rôle, pages_visibles
```

### 2. **Affichage du Menu**
```
Sidebar charge tous les éléments de menu
    ↓
Filtre chaque élément via hasAccess(pageId)
    ↓
Affiche seulement les pages autorisées
```

### 3. **Accès à une Page**
```
Utilisateur clique sur une page
    ↓
ProtectedRoute vérifie hasAccess(requiredPage)
    ↓
✅ Si autorisé: affiche la page
❌ Si refusé: affiche message "Accès Refusé"
```

### 4. **Actions sur les Données**
```
Utilisateur clique sur "Créer", "Modifier", "Supprimer"
    ↓
Composant vérifie canManageUsers()
    ↓
Service vérifie canCreate() / canUpdate() / canDelete()
    ↓
✅ Si autorisé: effectue l'action
❌ Si refusé: affiche message d'erreur
```

---

## 🎨 Interface Utilisateur

### Menu Sidebar (Filtré)
- ✅ Affiche seulement les pages accessibles
- ✅ Cache les pages non autorisées
- ✅ Dynamique selon le rôle de l'utilisateur

### Boutons d'Action (Protégés)
- ✅ "Créer" désactivé si pas de permission
- ✅ "Modifier" masqué si pas de permission
- ✅ "Supprimer" bloqué avec confirmation

### Messages d'Erreur (Explicites)
```
🔒 Vous n'avez pas la permission de...
🔒 Seul un Super Admin peut...
⚠️ ATTENTION: Action irréversible!
```

---

## 📊 Matrice d'Accès Complète

| Action/Page | Super Admin | Admin | Technicien | Commercial | Support |
|---|:---:|:---:|:---:|:---:|:---:|
| **Créer Utilisateur** | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Modifier Utilisateur** | ✅ | ⚠️ | ❌ | ❌ | ❌ |
| **Supprimer Utilisateur** | ✅ | ⚠️ | ❌ | ❌ | ❌ |
| **Dashboard** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Prospects** | ✅ | ✅ | ❌ | ✅ | ❌ |
| **Clients** | ✅ | ✅ | ❌ | ✅ | ✅ |
| **Installations** | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Abonnements** | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Paiements** | ✅ | ✅ | ❌ | ✅ | ❌ |
| **Support** | ✅ | ✅ | ✅ | ❌ | ✅ |
| **Interventions** | ✅ | ✅ | ✅ | ❌ | ✅ |
| **Applications** | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Utilisateurs** | ✅ | ✅ | ❌ | ❌ | ❌ |

**Légende:**
- ✅ Accès complet
- ⚠️ Accès limité (restrictions appliquées)
- ❌ Pas d'accès

---

## 🔧 Implémentation Technique

### Services
**userService.js**
- `canCreate(profile)` - Vérifier permission créer
- `canUpdate(profile, userId)` - Vérifier permission modifier
- `canDelete(profile, userId)` - Vérifier permission supprimer
- `create(userData, profile)` - Créer avec vérification
- `update(userId, userData, profile)` - Modifier avec vérification
- `delete(userId, profile)` - Supprimer avec vérification

### Contexte
**AuthContext.jsx**
- `hasAccess(pageName)` - Vérifier accès à une page
- `canManageUsers()` - Vérifier permission gestionnaire
- `canManageRoles()` - Vérifier gestion des rôles
- `hasPermission(permission)` - Vérifier permission générique

### Composants
**Sidebar.jsx**
- Filtre les éléments de menu via `hasAccess()`
- Affiche seulement les pages autorisées

**ProtectedRoute.jsx**
- Bloque l'accès aux pages non autorisées
- Affiche un message "Accès Refusé" clair

**UsersList.jsx**
- Vérifie `canManageUsers()` avant chaque action
- Passe le profil utilisateur aux appels service
- Affiche messages d'erreur de permission

---

## 🚨 Cas de Sécurité Critiques

### 1. Suppression de Super Admin
```
✅ Seul Super Admin peut supprimer un Super Admin
❌ Admin ne peut pas supprimer Super Admin
❌ Autres rôles ne peuvent rien supprimer
```

### 2. Modification de Rôle
```
✅ Super Admin peut modifier n'importe qui
✅ Admin peut modifier (sauf Super Admin)
❌ Autres rôles ne peuvent rien modifier
```

### 3. Accès aux Pages
```
✅ Les pages sont filtrées en temps réel
✅ URL directe bloquée par ProtectedRoute
✅ Backend valide les permissions
```

---

## 📝 Notes de Développement

### Ajouter une nouvelle page
1. Ajouter dans `PAGES` (constants.js)
2. Ajouter dans `allMenuItems` (Sidebar.jsx)
3. Ajouter dans `defaultPages` de chaque rôle (constants.js)
4. Créer le composant de page
5. Ajouter la route avec `<ProtectedRoute requiredPage={PAGES.NOUVELLE}>`

### Modifier les permissions d'un rôle
1. Modifier `ROLE_PERMISSIONS` (constants.js)
2. Mettre à jour `defaultPages`
3. Tester chaque rôle

### Tester le contrôle d'accès
1. Créer un utilisateur pour chaque rôle
2. Se connecter avec chaque utilisateur
3. Vérifier:
   - Quelles pages apparaissent dans le menu
   - Quels boutons sont visibles
   - Quels messages d'erreur s'affichent

---

## ✅ Résumé

✅ Système de rôles complet (5 rôles)
✅ Permissions granulaires (créer, modifier, supprimer)
✅ Contrôle d'accès par page (10 pages)
✅ Vérification côté client (interface)
✅ Vérification côté service (données)
✅ Messages d'erreur explicites
✅ Protections spéciales (Super Admin)
✅ Menu dynamique selon permissions
✅ Routes protégées

---

**Dernière mise à jour:** 19 novembre 2025  
**Version:** 2.0  
**Statut:** ✅ En production
