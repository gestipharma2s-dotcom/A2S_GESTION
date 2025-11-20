# ⚡ Rôles Valides - Référence Rapide

## Les 5 Rôles Valides (Obligatoires)

### Copier/Coller Exactement:

```
super_admin
admin
technicien
commercial
support
```

## ❌ À NE PAS FAIRE

```
❌ Super Admin      (majuscules + espace)
❌ SuperAdmin       (majuscule sans espace)
❌ super-admin      (tiret au lieu underscore)
❌ super_administrateur  (nom complet)
❌ Administrateur   (français, majuscule)
❌ Admin            (majuscule)
❌ TECHNICIEN       (majuscules)
❌ technician       (anglais)
❌ whatever else    (n'importe quoi d'autre)
```

## ✅ Correct

```
✅ super_admin      (minuscules, underscore)
✅ admin            (minuscules)
✅ technicien       (minuscules)
✅ commercial       (minuscules)
✅ support          (minuscules)
```

## 📊 Matrice d'Accès

| Rôle | Pages | Gérer Users | Gérer Rôles | Voir Tout |
|------|-------|-------------|-------------|-----------|
| super_admin | 11/11 | ✅ Tous | ✅ | ✅ |
| admin | 10/11 | ✅ Sauf super_admin | ❌ | ✅ |
| technicien | 5/11 | ❌ | ❌ | ❌ |
| commercial | 6/11 | ❌ | ❌ | ❌ |
| support | 4/11 | ❌ | ❌ | ❌ |

## 🔧 Si Vous Recevez: "violates check constraint users_role_check"

**Cause**: Le rôle n'est pas dans la liste ci-dessus

**Solution**: Utiliser EXACTEMENT un des 5 rôles valides

---

**Sauvegardez cette page pour référence rapide!**
