# 🚨 URGENT: Erreur "Invalid login credentials"

## ❌ Erreur

```
AuthApiError: Invalid login credentials
POST https://...supabase.co/auth/v1/token?grant_type=password 400 (Bad Request)
```

**Cause:** Les emails ne sont pas confirmés dans Supabase

---

## ✅ SOLUTION (2 minutes)

### **Étape 1: Ouvrir Supabase**
```
https://app.supabase.com
→ Votre Projet
→ "SQL Editor" (en bas à gauche)
```

### **Étape 2: Exécuter le Script**
1. Cliquez **"New Query"**
2. Ouvrez le fichier: `URGENT_CONFIRMER_EMAILS.sql`
3. **Copiez TOUT** le contenu
4. **Collez** dans le SQL Editor
5. Cliquez **"Run"** (Ctrl+Enter)

### **Étape 3: Vérifier**
```
✅ Les emails sont confirmés
✅ Tous les utilisateurs sont actifs
```

### **Étape 4: Tester la Connexion**
```
Email:    admin@a2sgestion.fr
Password: AdminPass123!@#Secure
```

**Résultat attendu:** ✅ Connexion réussie!

---

## 📋 Résumé du Script SQL

```sql
-- 1. Voir les emails NON confirmés
SELECT id, email, email_confirmed_at 
FROM auth.users 
WHERE email_confirmed_at IS NULL;

-- 2. Confirmer TOUS les emails
UPDATE auth.users
SET email_confirmed_at = NOW()
WHERE email_confirmed_at IS NULL;

-- 3. Vérifier le résultat
SELECT id, email, email_confirmed_at 
FROM auth.users;
```

---

## 🎯 Actions Immédiates

- [ ] Ouvrir Supabase SQL Editor
- [ ] Exécuter le script URGENT_CONFIRMER_EMAILS.sql
- [ ] Vérifier que tous les emails sont confirmés
- [ ] Tester connexion avec admin@a2sgestion.fr
- [ ] Tester connexion avec autres utilisateurs

---

## ❓ Si ça ne marche pas

**Problème:** Le script s'exécute mais connexion ne marche pas

**Solution:**
1. Vérifier l'email exact dans Supabase
2. Vérifier le password exact
3. Vérifier que email_confirmed_at n'est plus NULL

---

**Status:** 🚨 ACTION REQUISE  
**Urgence:** ÉLEVÉE  
**Temps:** 2 minutes  
**Date:** 19 novembre 2025
