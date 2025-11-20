# 🚀 QUICK START: Mettre en Place l'App

## ⚡ En 5 Minutes

### 1. Créer le Compte Super Admin

**Choix rapide:**

**Option A (2 minutes - Console Supabase)**
```
1. Aller: https://app.supabase.com → Authentication → Users
2. Cliquer "Add user"
3. Email: admin@a2sgestion.fr
   Password: AdminPass123!@#Secure
   Auto confirm: OUI
4. Copier l'UUID généré
5. Aller: SQL Editor → Nouvelle requête
6. Exécuter: (voir ci-dessous)
```

SQL à exécuter:
```sql
INSERT INTO users (id, nom, email, role, pages_visibles)
VALUES (
  'UUID-COPIÉ',  -- ← Coller l'UUID
  'Admin',
  'admin@a2sgestion.fr',
  'super_admin',
  '["dashboard", "prospects", "clients", "installations", "abonnements", "paiements", "support", "interventions", "alertes", "applications", "utilisateurs"]'::jsonb
);
```

**Option B (1 minute - Script SQL)**
```
1. Supabase Console → SQL Editor → New Query
2. Ouvrir fichier: create_super_admin_simple.sql
3. Copier le contenu entier
4. Coller dans l'éditeur
5. Modifier email/password en haut du script
6. Cliquer "Run"
```

### 2. Tester la Connexion

```
1. Ouvrir: http://localhost:3000
2. Email: admin@a2sgestion.fr
3. Mot de passe: AdminPass123!@#Secure
4. Cliquer "Se Connecter"
5. ✅ Si ça marche: Dashboard s'affiche
6. ❌ Si erreur: Lire TROUBLESHOOT_LOGIN.md
```

### 3. Créer d'Autres Utilisateurs

Connecté en tant qu'admin:
```
1. Menu → Utilisateurs
2. Cliquer "Créer Utilisateur"
3. Remplir formulaire:
   - Nom: Jean Dupont
   - Email: jean@a2s.dz (n'importe quel domaine!)
   - Mot de passe: Test123!
   - Rôle: technicien
4. Cliquer "Créer"
5. ✅ Utilisateur créé!
```

## 📚 Documentation Complète

| Guide | Contenu |
|-------|---------|
| **COMPTE_SUPER_ADMIN.md** | Créer le super admin (détaillé) |
| **TROUBLESHOOT_LOGIN.md** | Résoudre erreurs de connexion |
| **GUIDE_EMAIL_LOGIN_FINAL.md** | Système email (n'importe quel domaine) |
| **GESTION_ROLES_PERMISSIONS.md** | Système de permissions |
| **INDEX.md** | Vue d'ensemble complète |

## 🔑 Identifiants de Test

```
Email: admin@a2sgestion.fr
Mot de passe: AdminPass123!@#Secure
Rôle: super_admin
```

⚠️ **À CHANGER APRÈS LE PREMIER LOGIN**

## ✅ Checklist de Déploiement

### Phase 1: Setup Initial
- [ ] Créer compte super_admin
- [ ] Tester connexion
- [ ] Créer 2e compte admin (backup)
- [ ] Changer mot de passe par défaut

### Phase 2: Utilisateurs
- [ ] Créer utilisateurs technicien
- [ ] Créer utilisateurs commercial
- [ ] Tester leur accès (permissions)
- [ ] Vérifier pages visibles

### Phase 3: Données
- [ ] Importer prospects/clients
- [ ] Importer installations
- [ ] Vérifier abonnements
- [ ] Tester paiements

### Phase 4: Sécurité
- [ ] Vérifier HTTPS en production
- [ ] Configurer domaine custom
- [ ] Configurer email (si disponible)
- [ ] Faire sauvegardes

## 🎯 Après le Setup

### Accès Admin
```
https://votre-domaine.com
→ Email: admin@a2sgestion.fr
→ Mot de passe: (votre mot de passe fort)
```

### Pages Accessibles

**Super Admin (Toutes les pages):**
- ✅ Dashboard
- ✅ Prospects
- ✅ Clients
- ✅ Installations
- ✅ Abonnements
- ✅ Paiements
- ✅ Support
- ✅ Interventions
- ✅ Alertes
- ✅ Applications
- ✅ Utilisateurs (gestion)

**Admin:**
- ✅ Tout sauf "Utilisateurs"

**Technicien:**
- ✅ Dashboard
- ✅ Clients
- ✅ Installations
- ✅ Support
- ✅ Interventions
- ✅ Alertes

**Commercial:**
- ✅ Dashboard
- ✅ Prospects
- ✅ Clients
- ✅ Abonnements
- ✅ Paiements
- ✅ Alertes

**Support:**
- ✅ Dashboard
- ✅ Support
- ✅ Interventions
- ✅ Clients
- ✅ Alertes

## 🔧 Configuration Recommandée

### Développement Local
```
URL: http://localhost:3000
Supabase: Projet test
Email notifications: Désactivé
```

### Production
```
URL: https://votre-domaine.com
Supabase: Projet production
Email: Configuré
HTTPS: Obligatoire
```

## ⚠️ Problèmes Courants

### "Invalid login credentials"
→ Voir: **TROUBLESHOOT_LOGIN.md**

### "Auth session missing"
→ Créer le profil users (Étape 1, Option A, Étape 5)

### "User not found"
→ Créer l'utilisateur en Auth d'abord (Supabase Console)

### Permissions ne fonctionnent pas
→ Vérifier `role` en table users
→ Vérifier `pages_visibles` est rempli

## 📞 Support

```
1. Lire la doc correspondante
2. Vérifier les logs (F12 → Console)
3. Vérifier la base de données (SQL)
4. Consulter Supabase docs
5. Contacter équipe A2S
```

## 🚀 Prochain Pas

Une fois le setup complété:

1. **Créer utilisateurs**: Menu → Utilisateurs → Créer
2. **Importer données**: Selon vos besoins
3. **Tester fonctionnalités**: Dashboard, Prospects, etc.
4. **Configurer intégrations**: Email, SMS (optionnel)
5. **Déployer**: En production

---

**Temps estimé setup**: 5-10 minutes  
**Difficulté**: ⭐ Facile  
**Status**: ✅ Production-ready
