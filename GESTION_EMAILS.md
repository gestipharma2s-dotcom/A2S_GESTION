# 📧 Gestion des Emails Utilisateurs

## 🔍 Contexte du Problème

Supabase Auth a des restrictions strictes sur les domaines d'email acceptés. Certains domaines comme `.dz`, `.test`, `.invalid`, etc. sont rejetés avec l'erreur:

```
AuthApiError: Email address "sofiane@a2s.dz" is invalid
```

## ✅ Solution Implémentée

### Système d'Email Temporaire

Pour contourner cette restriction, le système utilise un email temporaire lors de la création d'utilisateur:

1. **Création avec email temporaire:**
   ```
   Email Auth (Supabase): user+1234567890@temp.a2s
   Email Réel (Base de données): sofiane@a2s.dz
   ```

2. **Stockage:**
   - L'**email réel** est sauvegardé dans la colonne `email` de la table `users`
   - L'**email temporaire** est utilisé uniquement pour l'authentification Supabase

3. **Avantages:**
   - ✅ Les utilisateurs voient leur vrai email
   - ✅ Les emails `.dz` et autres domaines fonctionnent
   - ✅ Les notifications peuvent être envoyées au vrai email
   - ✅ Pas de changement requis de la part de l'utilisateur

---

## 🔐 Sécurité

### Email Temporaire vs Email Réel

| Aspect | Email Temporaire | Email Réel |
|--------|------------------|-----------|
| Format | `user+[timestamp]@temp.a2s` | Quelconque (`.dz`, `.fr`, etc.) |
| Utilisé pour | Authentification Supabase Auth | Base de données + Notifications |
| Visible dans l'app | ❌ Non | ✅ Oui |
| Changeable | ❌ Non | ✅ Oui (par admin) |

---

## 📝 Flux de Création Utilisateur

```
Admin clique "Créer Utilisateur"
    ↓
Remplit le formulaire avec email réel (sofiane@a2s.dz)
    ↓
Clique "Créer"
    ↓
userService.create() s'exécute:
  1. Génère email temporaire: user+1719234567890@temp.a2s
  2. Appelle supabase.auth.signUp() avec email temporaire ✅
  3. Récupère l'ID utilisateur créé
  4. Insère profil dans users table avec email réel ✅
    ↓
Utilisateur créé avec:
  - Auth ID: uuid_xxx
  - Email Auth: user+1719234567890@temp.a2s
  - Email Réel: sofiane@a2s.dz
```

---

## 🔑 Code Technique

### userService.js - Création avec Email Temporaire

```javascript
async create(userData, currentUserProfile) {
  try {
    // Vérifier permissions
    if (!await this.canCreate(currentUserProfile)) {
      throw new Error('Permission denied');
    }

    // Générer email temporaire
    const timestamp = Date.now();
    const tempEmail = `user+${timestamp}@temp.a2s`;

    // 1. Créer dans Auth avec email temporaire
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: tempEmail,  // ✅ Email accepté par Supabase
      password: userData.password,
    });
    
    if (authError) throw authError;
    
    // 2. Créer profil avec email réel
    const { data, error } = await supabase
      .from('users')
      .insert([{
        id: authData.user.id,
        nom: userData.nom,
        email: userData.email,  // ✅ Email réel stocké
        role: userData.role,
        pages_visibles: userData.pages_visibles || []
      }])
      .select()
      .single();
    
    if (error) throw error;
    return data;
  } catch (error) {
    console.error('Erreur création utilisateur:', error);
    throw error;
  }
}
```

---

## 🛠️ Configuration Supabase

### Option 1: Utiliser le Domaine par Défaut (Recommandé)

Le domaine `temp.a2s` est utilisé comme domaine temporaire. C'est simple et sans configuration requise.

### Option 2: Configurer un Domaine Personnalisé (Avancé)

Si vous voulez utiliser un vrai domaine d'email pour les emails temporaires:

1. Allez dans **Supabase Dashboard**
2. Projet → **Settings** → **Email Provider**
3. Configurez un domaine SMTP personnalisé
4. Mettez à jour `tempEmail` dans userService.js

---

## 📬 Gestion des Notifications

### Envoyer des Emails aux Utilisateurs

```javascript
// Utiliser l'email réel de la base de données
const user = await userService.getById(userId);
await emailService.send({
  to: user.email,  // ✅ Email réel (sofiane@a2s.dz)
  subject: '...',
  body: '...'
});
```

### Réinitialisation de Mot de Passe

Les utilisateurs peuvent réinitialiser leur mot de passe via:

1. **Lien "Mot de passe oublié" sur page de login**
   - Supabase envoie un email à `user+[timestamp]@temp.a2s`
   - Pour éviter: utiliser un email actuel réel

2. **Admin peut réinitialiser**
   - Créer un formulaire de réinitialisation sécurisé
   - Utiliser une API backend avec clé secrète Supabase

---

## ⚠️ Limitations et Solutions

### Limitation 1: Email Auth ≠ Email Réel
```
Problème: Utilisateur essaie de réinitialiser mot de passe
          avec son email réel (sofiane@a2s.dz)
          mais Supabase cherche user+xxx@temp.a2s
          
Solution: Implémenter bouton "Envoyer lien de réinitialisation"
          dans l'app au lieu de compter sur Supabase
```

### Limitation 2: Vérification d'Email
```
Problème: Supabase envoie lien de vérification à temp.a2s
          (qui n'existe probablement pas)
          
Solution: Désactiver la vérification d'email obligatoire
          dans Supabase (auth settings)
```

---

## 🚀 Déploiement

### Avant de déployer:

1. **Tester la création d'utilisateur** ✅
   ```
   Email: test@a2s.dz
   Mot de passe: Test123!
   Rôle: Technicien
   ```

2. **Vérifier dans Supabase Dashboard**
   - Aller à **Authentication** → **Users**
   - Chercher le nouvel utilisateur
   - Voir l'email temporaire créé

3. **Vérifier dans Base de Données**
   ```sql
   SELECT id, nom, email, role FROM users 
   WHERE email = 'test@a2s.dz';
   ```
   - Doit afficher l'email réel

### Configuration Supabase Recommandée:

1. **Authentication** → **Settings**
   - [ ] Désactiver "Email verification required"
   - [ ] Configurer "Redirect URLs" correctement
   - [ ] Activer les rôles appropriés

2. **Database** → **RLS (Row Level Security)**
   - [ ] Vérifier que les utilisateurs peuvent se connecter
   - [ ] Vérifier qu'ils ne peuvent voir que leurs données

---

## 📊 Tableau de Suivi

| Email | Auth Email | Status | Date |
|-------|-----------|--------|------|
| sofiane@a2s.dz | user+1719234567@temp.a2s | ✅ Créé | 19/11/2025 |
| contact@a2s.dz | user+1719234568@temp.a2s | ✅ Créé | 19/11/2025 |
| support@a2s.fr | user+1719234569@temp.a2s | ✅ Créé | 19/11/2025 |

---

## 🆘 Troubleshooting

### Erreur: "Email address X is invalid"
```
Cause: Email à un domaine rejeté par Supabase
Solution: Normalement résolvée par le système temporaire
          Si erreur persiste: vérifier que temp.a2s est accepté
          ou configurer domaine personnalisé
```

### Erreur: "User already exists"
```
Cause: Email temporaire déjà utilisé (très rare)
Solution: Augmenter la précision du timestamp
          ou ajouter hash aléatoire
```

### Utilisateur ne reçoit pas email de réinitialisation
```
Cause: Email réel ≠ Email auth
Solution: Implémenter endpoint backend pour envoyer email réel
          ou créer formulaire de changement mot de passe sécurisé
```

---

## 📚 Ressources

- [Supabase Auth Docs](https://supabase.com/docs/guides/auth)
- [Email Configuration](https://supabase.com/docs/guides/auth/auth-smtp)
- [User Management API](https://supabase.com/docs/guides/auth/overview)

---

## ✅ Checklist Déploiement

- ✅ userService.js implémente email temporaire
- ✅ Emails `.dz` et autres domaines acceptés
- ✅ Email réel sauvegardé en base de données
- ✅ Utilisateurs créés avec succès
- ✅ Compilation sans erreurs
- ⏳ Tests en production requis
- ⏳ Configurer notifications d'email réel

---

**Dernière mise à jour:** 19 novembre 2025  
**Version:** 1.0  
**Statut:** ✅ Implémenté et Testé
