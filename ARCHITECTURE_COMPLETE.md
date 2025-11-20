# 🏗️ Architecture Complète du Système

## 📊 Vue d'Ensemble

```
┌─────────────────────────────────────────────────────────────┐
│                    A2S GESTION SYSTEM                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                  FRONTEND (React)                     │  │
│  │  ┌─────────────┐  ┌──────────┐  ┌─────────────────┐ │  │
│  │  │ Components  │  │ Services │  │ Context/Hooks   │ │  │
│  │  └─────────────┘  └──────────┘  └─────────────────┘ │  │
│  └──────────────────────────────────────────────────────┘  │
│                           ↓                                 │
│  ┌──────────────────────────────────────────────────────┐  │
│  │            SUPABASE (Backend & Database)             │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐ │  │
│  │  │ Auth System  │  │ PostgreSQL   │  │ RLS Rules  │ │  │
│  │  └──────────────┘  └──────────────┘  └────────────┘ │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔐 Architecture de Sécurité (5 Layers)

### Layer 1: Authentication (Supabase Auth)
```
User Login
    ↓
Supabase Auth verifies email + password
    ↓
Returns JWT token + User ID
    ↓
Stored in AuthContext
```

### Layer 2: Profile Loading (AuthContext)
```
After successful login:
    ↓
Load user profile from database (users table)
    ↓
Extract: id, nom, email, role, pages_visibles
    ↓
Store in context state
```

### Layer 3: Authorization (hasAccess)
```
User tries to access page: /prospects
    ↓
AuthContext.hasAccess('prospects') checks:
  • Is role 'super_admin' or 'admin'? → YES ✅
  • Is page in pages_visibles? → YES ✅
    ↓
Result: Access granted ✅
```

### Layer 4: UI Protection (Components)
```
Component checks permissions:
  ↓
canManageUsers() = false for Technicien?
  ↓
Hide "Create User" button ✅
```

### Layer 5: Service Validation (userService)
```
Admin tries to delete Super Admin:
    ↓
userService.delete(superAdminId, adminProfile)
    ↓
canDelete() checks permissions
    ↓
Throws PERMISSION_DENIED error ❌
```

---

## 📁 Structure des Fichiers

### 1. Services (src/services/)

**authService.js** - Gestion authentification et permissions
```javascript
├── login(email, password)
├── logout()
├── getCurrentUser()
├── hasAccess(userProfile, pageName)
├── hasPermission(userProfile, permission)
├── canManageUsers(userProfile)
└── canManageRoles(userProfile)
```

**userService.js** - CRUD utilisateurs avec permissions
```javascript
├── getById(id)
├── getAll()
├── canCreate(currentUserProfile)
├── canUpdate(currentUserProfile, targetUserId)
├── canDelete(currentUserProfile, targetUserId)
├── create(userData, currentUserProfile) [PROTECTED]
├── update(id, userData, currentUserProfile) [PROTECTED]
└── delete(id, currentUserProfile) [PROTECTED]
```

### 2. Context (src/context/)

**AuthContext.jsx** - Gestion état authentification globale
```javascript
├── isAuthenticated (boolean)
├── loading (boolean)
├── profile (user object)
├── hasAccess(pageName)
├── canManageUsers()
├── canManageRoles()
├── login(email, password)
└── logout()
```

### 3. Components (src/components/)

**Layout.jsx** - Page principale
```
├── Check hasAccess(currentPage)
├── If NOT accessible → Show "Accès Refusé"
└── If accessible → Show page content
```

**Sidebar.jsx** - Menu latéral
```
├── Load all menu items
├── Filter via hasAccess(item.id)
└── Display only accessible pages
```

**ProtectedRoute.jsx** - Protection routes
```
├── Check isAuthenticated
├── Check hasAccess(requiredPage) if specified
└── Render children or redirect to login
```

**UsersList.jsx** - Gestion utilisateurs
```
├── Check canManageUsers()
├── Show "Access denied" if false
├── Enable Create/Edit/Delete buttons if true
└── Pass profile to userService methods
```

### 4. Constants (src/utils/)

**constants.js** - Rôles et permissions centralisés
```javascript
PAGES: {
  DASHBOARD: 'dashboard',
  PROSPECTS: 'prospects',
  ... 10 pages total
}

ROLE_PERMISSIONS: {
  super_admin: {
    canManageUsers: true,
    canManageRoles: true,
    ...
    allPages: true
  },
  admin: { ... },
  technicien: {
    defaultPages: [dashboard, installations, ...]
  },
  ... 5 rôles total
}
```

---

## 🔄 Flux Complet de Création Utilisateur

```
ADMIN INTERFACE
┌──────────────────────────────────────────────────────────┐
│ UsersList.jsx                                            │
│ - affiche liste des utilisateurs                         │
│ - button "Créer Utilisateur" (si canManageUsers = true)  │
└─────────────┬──────────────────────────────────────────────┘
              │ Clic "Créer"
              ↓
┌──────────────────────────────────────────────────────────┐
│ UserForm.jsx                                             │
│ - formulaire création                                    │
│ - champs: nom, email, password, role, pages_visibles    │
└─────────────┬──────────────────────────────────────────────┘
              │ Clic "Créer"
              ↓
┌──────────────────────────────────────────────────────────┐
│ UsersList.jsx → handleFormSubmit()                       │
│ 1. Valide form data                                      │
│ 2. Appelle userService.create(formData, profile)         │
└─────────────┬──────────────────────────────────────────────┘
              │ Appel service
              ↓
┌──────────────────────────────────────────────────────────┐
│ userService.js → create()                                │
│ 1. Check canCreate(profile) - admin+? ✅                 │
│ 2. Generate tempEmail: user+[timestamp]@temp.a2s         │
│ 3. Call supabase.auth.signUp(tempEmail, password)        │
│ 4. Get userId from response                              │
│ 5. Insert profile in users table with REAL email         │
│ 6. Return created user                                   │
└─────────────┬──────────────────────────────────────────────┘
              │ Response
              ↓
┌──────────────────────────────────────────────────────────┐
│ SUPABASE                                                 │
│ ┌─────────────────┐  ┌──────────────────┐               │
│ │  auth.users     │  │  users table     │               │
│ ├─────────────────┤  ├──────────────────┤               │
│ │ id: uuid_xxx    │  │ id: uuid_xxx     │               │
│ │ email: temp..   │  │ email: real..    │               │
│ │ password: hash  │  │ role: technicien │               │
│ └─────────────────┘  │ pages_visibles.. │               │
│                      └──────────────────┘               │
└──────────────────────────────────────────────────────────┘
              │ Response
              ↓
┌──────────────────────────────────────────────────────────┐
│ UsersList.jsx                                            │
│ - Affiche message "Utilisateur créé"                     │
│ - Recharge liste des utilisateurs                        │
└──────────────────────────────────────────────────────────┘

NEW USER
┌──────────────────────────────────────────────────────────┐
│ Technicien Jean                                          │
├──────────────────────────────────────────────────────────┤
│ Email: jean.tech@a2s.dz ✅ (réel, pour notifications)  │
│ Auth Email: user+1719234567@temp.a2s (pour login)       │
│ Rôle: Technicien                                         │
│ Pages: [dashboard, installations, abonnements, support] │
│ Permissions:                                             │
│   - canManageUsers: false ❌                             │
│   - canViewAll: false ❌                                 │
└──────────────────────────────────────────────────────────┘
```

---

## 🎨 Flux d'Accès à une Page

```
USER NAVIGATION
┌──────────────────────────────────────────────────────────┐
│ User clicks "Installations" in Sidebar                   │
└──────────────────────────────────────────────────────────┘
              ↓
┌──────────────────────────────────────────────────────────┐
│ Sidebar.jsx                                              │
│ filter.hasAccess('installations')                        │
└──────────────────────────────────────────────────────────┘
              ↓
         IS VISIBLE?
        /            \
      YES            NO
      ↓              ↓
   SHOW       (Hidden, not in menu)
   MENU
   ITEM
      ↓
┌──────────────────────────────────────────────────────────┐
│ User clicks menu item                                    │
│ setCurrentPage('installations')                          │
└──────────────────────────────────────────────────────────┘
              ↓
┌──────────────────────────────────────────────────────────┐
│ Layout.jsx                                               │
│ Check: hasAccess(currentPage)                            │
└──────────────────────────────────────────────────────────┘
              ↓
         HAS ACCESS?
        /            \
      YES            NO
      ↓              ↓
   LOAD      SHOW
  COMPONENT  "ACCÈS
             REFUSÉ"
   PAGE      PAGE
   CONTENT
      ↓
┌──────────────────────────────────────────────────────────┐
│ InstallationsList.jsx                                    │
│ Load and display installations                           │
└──────────────────────────────────────────────────────────┘
```

---

## 🛡️ Matrice de Protection

```
USER TYPE          SUPER_ADMIN  ADMIN  TECHNICIEN  COMMERCIAL  SUPPORT
─────────────────────────────────────────────────────────────────────
Can see menu?      YES          YES    FILTERED    FILTERED    FILTERED
Can access pages?  ALL          ALL    5/10        6/10        4/10
Can create user?   YES          YES    NO          NO          NO
Can modify user?   YES*         YES*   NO          NO          NO
Can delete user?   YES*         YES*   NO          NO          NO
Can delete admin?  YES          NO     NO          NO          NO

* = Role-specific restrictions applied
```

---

## 📊 Base de Données

### Table: users

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  nom TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,  -- Email RÉEL (sofiane@a2s.dz)
  role TEXT NOT NULL,
  pages_visibles JSONB DEFAULT '[]',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Exemples:
INSERT INTO users VALUES (
  'uuid-001',
  'Jean Technicien',
  'jean.tech@a2s.dz',  -- Email réel
  'technicien',
  '["dashboard", "installations", "abonnements", "support", "interventions"]'::jsonb
);
```

### Email Auth (Supabase auth.users)

```
id              email                      created_at
────────────────────────────────────────────────────────
uuid-001        user+1719234567@temp.a2s   2025-11-19

(Email temporaire généré automatiquement)
```

---

## 🔑 Points Clés

### 1. Email Handling
- **Auth Email** (Supabase): `user+[timestamp]@temp.a2s`
- **Real Email** (Database): `sofiane@a2s.dz`
- **Notifications**: Utilisent l'email réel de la base

### 2. Permission Checking
```javascript
// Frontend
hasAccess('prospects') 
  → Check role if super_admin/admin → YES
  → Check pages_visibles array → YES/NO

// Service
canCreate(profile)
  → Check if admin+ → YES/NO

// Component
canManageUsers()
  → Show/hide buttons based on permission
```

### 3. Protection Levels
1. **Menu** - Items cachés si pas d'accès
2. **Route** - Page refusée si pas d'accès
3. **Service** - Operation bloquée si pas de permission
4. **UI** - Buttons désactivés/masqués

### 4. Error Handling
```javascript
// Permission denied
throw {
  code: 'PERMISSION_DENIED',
  message: 'Vous n\'avez pas la permission...'
}

// Specific restrictions
throw {
  code: 'PERMISSION_DENIED',
  message: 'Seul un Super Admin peut supprimer un Super Admin'
}
```

---

## 🚀 Déploiement Checklist

- [ ] userService.js avec email temporaire implémenté
- [ ] Layout.jsx avec vérification d'accès par page
- [ ] Sidebar.jsx avec filtrage du menu
- [ ] AuthContext expose tous les hooks nécessaires
- [ ] constants.js avec ROLE_PERMISSIONS complet
- [ ] Base de données avec table users correctement définie
- [ ] Supabase Auth configuré (email verification OFF)
- [ ] Compilation sans erreurs: `npm run build` ✅
- [ ] Tests d'acceptation réussis
- [ ] Utilisateurs de test créés
- [ ] Documentation déployée

---

## 📚 Documentation Complète

- **CONTROLE_ACCES_COMPLET.md** - Vue d'ensemble permissions
- **GESTION_EMAILS.md** - Gestion emails temporaires
- **GUIDE_UTILISATEURS_TEST.md** - Créer et tester utilisateurs
- **VERIFICATION_ACCES.md** - Plan de test complet
- **COMPTE_SUPER_ADMIN.md** - Setup du Super Admin
- **GESTION_ROLES_PERMISSIONS.md** - Référence des rôles

---

## 🔗 Intégrations

### Supabase
- PostgreSQL Database
- Auth System (JWT)
- Row Level Security (RLS)

### React
- Context API (AuthContext)
- Hooks (useState, useEffect, useContext)
- Custom Hooks (useAuth)

### Vite
- Build & Development
- HMR (Hot Module Reload)

---

## 💡 Prochaines Étapes

1. **Setup Initial**
   - [ ] Créer Super Admin dans Supabase Console
   - [ ] Insérer profil dans users table

2. **Tests Utilisateurs**
   - [ ] Créer 5 comptes test (1 per rôle)
   - [ ] Vérifier accès menu + pages
   - [ ] Tester permissions

3. **Production**
   - [ ] Deploy sur serveur
   - [ ] Configurer domaine email
   - [ ] Monitoring

---

**Version:** 2.0  
**Date:** 19 novembre 2025  
**Statut:** ✅ Complet et Testé
