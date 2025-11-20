# 📋 Gestion des Rôles et Permissions

## Vue d'ensemble

Le système de gestion des utilisateurs implémente un système robuste de rôles et permissions avec les niveaux suivants :

## 🎭 Rôles Disponibles

### 1. 👑 Super Administrateur (`super_admin`)
**Permissions complètes**
- ✅ Accès à toutes les pages
- ✅ Gestion complète des utilisateurs et des rôles
- ✅ Gestion des applications
- ✅ Voir toutes les données
- ✅ Éditer toutes les données
- ✅ Supprimer toutes les données
- ✅ Seul à pouvoir supprimer d'autres Super Admins

### 2. 🔐 Administrateur (`admin`)
**Permissions administratives**
- ✅ Accès à toutes les pages
- ✅ Gestion des utilisateurs (mais pas des rôles)
- ✅ Gestion des applications
- ✅ Voir toutes les données
- ✅ Éditer toutes les données
- ✅ Supprimer toutes les données
- ❌ Ne peut pas créer/modifier les rôles
- ❌ Ne peut pas supprimer un Super Admin

### 3. 🔧 Technicien (`technicien`)
**Permissions limitées au support technique**
- Pages par défaut:
  - Dashboard
  - Installations
  - Abonnements
  - Support
  - Interventions
- ✅ Voir et modifier les interventions
- ✅ Gérer le support technique
- ❌ Accès limité à d'autres pages
- ❌ Pas de gestion d'utilisateurs

### 4. 💼 Commercial (`commercial`)
**Permissions limitées à la vente et gestion clients**
- Pages par défaut:
  - Dashboard
  - Prospects
  - Clients
  - Installations
  - Abonnements
  - Paiements
  - Alertes
- ✅ Gérer les prospects et clients
- ✅ Enregistrer les installations
- ✅ Enregistrer les paiements
- ❌ Accès limité au support
- ❌ Pas de gestion d'utilisateurs

### 5. 🎧 Support (`support`)
**Permissions limitées au support client**
- Pages par défaut:
  - Dashboard
  - Support
  - Interventions
  - Clients
- ✅ Voir et gérer les interventions
- ✅ Communiquer avec les clients
- ❌ Pas d'accès aux prospects ou paiements
- ❌ Pas de gestion d'utilisateurs

## 🔑 Système de Permissions

### Structure des Permissions

```javascript
ROLE_PERMISSIONS = {
  [role]: {
    label: 'Nom du rôle',
    canManageUsers: boolean,      // Créer/modifier/supprimer utilisateurs
    canManageRoles: boolean,      // Assigner/modifier les rôles
    canManageApplications: boolean, // Gérer les applications
    canViewAll: boolean,          // Voir toutes les données
    canEditAll: boolean,          // Éditer toutes les données
    canDeleteAll: boolean,        // Supprimer toutes les données
    allPages: boolean,            // Accès à toutes les pages (admin only)
    defaultPages: [...]           // Pages accessibles par défaut
  }
}
```

## 🛡️ Vérification des Permissions

### Dans le Contexte d'Authentification

```javascript
const { canManageUsers, canManageRoles, hasPermission, hasAccess } = useAuth();

// Vérifier une permission spécifique
if (canManageUsers()) {
  // Afficher le bouton de création
}

// Vérifier l'accès à une page
if (hasAccess('dashboard')) {
  // Afficher la page
}

// Vérifier une permission générique
if (hasPermission('canDeleteAll')) {
  // Autoriser la suppression
}
```

### Dans les Composants

```javascript
import { useAuth } from '@/context/AuthContext';

function MyComponent() {
  const { canManageUsers, profile } = useAuth();

  if (!canManageUsers()) {
    return <div>Accès refusé</div>;
  }

  return <div>Gestion des utilisateurs</div>;
}
```

## 👥 Gestion des Utilisateurs

### Créer un Utilisateur
1. Accès: Seuls les administrateurs peuvent créer des utilisateurs
2. Le rôle détermine les permissions
3. Les pages accessibles peuvent être personnalisées (sauf pour les admins)

### Modifier un Utilisateur
1. Accès: Seuls les administrateurs
2. Protection: Un admin ne peut pas modifier un Super Admin
3. Le mot de passe peut être changé optionnellement

### Supprimer un Utilisateur
1. Accès: Seuls les administrateurs
2. Protection spéciale:
   - Un Super Admin ne peut être supprimé que par un Super Admin
   - Un Admin ne peut pas supprimer un Super Admin

## 📄 Pages et Accès

### Pages Disponibles

```
- dashboard: Tableau de bord
- prospects: Gestion des prospects
- clients: Gestion des clients
- installations: Gestion des installations
- abonnements: Gestion des abonnements
- paiements: Historique et enregistrement des paiements
- support: Support technique
- interventions: Interventions et journal
- alertes: Alertes d'abonnements
- applications: Gestion des applications
- utilisateurs: Gestion des utilisateurs
```

### Accès par Rôle

| Page | Super Admin | Admin | Technicien | Commercial | Support |
|------|:---:|:---:|:---:|:---:|:---:|
| Dashboard | ✅ | ✅ | ✅ | ✅ | ✅ |
| Prospects | ✅ | ✅ | ❌ | ✅ | ❌ |
| Clients | ✅ | ✅ | ❌ | ✅ | ✅ |
| Installations | ✅ | ✅ | ✅ | ✅ | ❌ |
| Abonnements | ✅ | ✅ | ✅ | ✅ | ❌ |
| Paiements | ✅ | ✅ | ❌ | ✅ | ❌ |
| Support | ✅ | ✅ | ✅ | ❌ | ✅ |
| Interventions | ✅ | ✅ | ✅ | ❌ | ✅ |
| Alertes | ✅ | ✅ | ❌ | ✅ | ❌ |
| Applications | ✅ | ✅ | ❌ | ❌ | ❌ |
| Utilisateurs | ✅ | ✅ | ❌ | ❌ | ❌ |

## 🚀 Cas d'Usage Pratiques

### Cas 1: Créer un nouveau technicien
1. Se connecter en tant qu'Admin
2. Aller dans Utilisateurs → Ajouter Utilisateur
3. Sélectionner le rôle "Technicien"
4. Les pages par défaut s'appliquent automatiquement
5. Créer l'utilisateur

### Cas 2: Personnaliser les accès d'un commercial
1. Se connecter en tant qu'Admin
2. Aller dans Utilisateurs → Modifier l'utilisateur
3. Rôle: Commercial (pages par défaut sélectionnées)
4. Personnaliser les pages accessibles au besoin
5. Enregistrer

### Cas 3: Bloquer un utilisateur de créer des utilisateurs
1. S'assurer que l'utilisateur ne pas un rôle d'Admin
2. Les permissions canManageUsers et canManageRoles seront false
3. Les boutons de gestion d'utilisateurs seront cachés ou désactivés
4. Les tentatives d'accès seront bloquées

## ⚠️ Mesures de Sécurité

1. **Protection des Super Admins**: 
   - Seul un Super Admin peut supprimer un autre Super Admin

2. **Vérification côté serveur**: 
   - Les permissions sont vérifiées avant chaque action

3. **Affichage contextuel**: 
   - Les boutons d'action sont masqués pour les utilisateurs sans permission

4. **Messages d'erreur clairs**: 
   - Les utilisateurs savent pourquoi une action est refusée

5. **Audit des logs**: 
   - Les actions de gestion d'utilisateurs peuvent être loggées

## 🔄 Flux d'Authentification

```
1. Utilisateur se connecte
2. AuthService.signIn() vérifie les identifiants
3. Profil utilisateur chargé depuis la base de données
4. AuthContext stocke les permissions
5. Composants vérifient hasAccess() et hasPermission()
6. UI adaptée en fonction des permissions
7. Actions backend vérifiées avec les permissions
```

## 📝 Notes de Développement

### Ajouter une nouvelle permission

1. Ajouter la permission dans `ROLE_PERMISSIONS` en constants
2. Ajouter la méthode correspondante dans `authService`
3. Exposer la méthode dans `AuthContext`
4. Utiliser dans les composants via `useAuth()`

### Ajouter un nouveau rôle

1. Ajouter le rôle dans `ROLES` en constants
2. Ajouter la configuration dans `ROLE_PERMISSIONS`
3. Ajouter les options de rôle dans `UserForm`
4. Ajouter les filtres et statistiques dans `UsersList`
5. Ajouter les couleurs et emojis correspondants dans `UserCard`

## 🎯 Prochaines Étapes

- [ ] Implémenter l'audit des actions
- [ ] Ajouter les logs d'accès
- [ ] Implémenter les restrictions temporaires d'accès
- [ ] Ajouter les groupes de permissions
- [ ] Implémenter l'authentification à deux facteurs

---

**Dernière mise à jour**: 19 novembre 2025
**Version**: 1.0
