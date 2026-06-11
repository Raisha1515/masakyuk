# 📚 SETUP SUPABASE - MASAKYUK

## ⚡ Step 1: Buat Storage Buckets

1. **Login ke Supabase Dashboard** → Go to **Storage**
2. **Buat 2 buckets baru:**
   - Nama: `recipe-images` (Public)
   - Nama: `user-avatars` (Public)

**Untuk setiap bucket:**
- Click "New bucket"
- Pilih "Public bucket"
- Click "Create bucket"

---

## 🗄️ Step 2: Jalankan SQL Schema

1. **Login ke Supabase Dashboard** → Go to **SQL Editor**
2. **Click "New query"**
3. **Copy-paste semua SQL dari file `supabase_schema.sql`**
4. **Click "Run"**

> ✅ Semua tables, indexes, dan RLS policies akan dibuat otomatis

---

## 🔑 Step 3: Update Supabase Config

✅ Sudah ada di: `lib/core/supabase_config.dart`

Jika perlu update:
- URL dan Key sudah tersedia di Supabase Dashboard
- Go to: **Settings** → **API**

---

## 🚀 Step 4: Key Features dari Services

### **UserService**
```dart
- getCurrentUser() → Get logged-in user
- createUserProfile() → Create new user profile saat register
- updateUserProfile() → Update username, bio, avatar
- getUserProfile() → Get user data by ID
```

### **RecipeService** 
```dart
- getPublicRecipes() → Fetch all public recipes
- getUserRecipes() → Fetch user's own recipes
- getRecipeById() → Get single recipe with comments & ratings
- createRecipe() → Create new recipe
- updateRecipe() → Update recipe data
- deleteRecipe() → Delete recipe
- subscribeToPublicRecipes() → REAL-TIME all public recipes
- subscribeToRecipe() → REAL-TIME single recipe
```

### **CommentService**
```dart
- getRecipeComments() → Fetch comments for a recipe
- addComment() → Add new comment
- deleteComment() → Delete comment
- subscribeToRecipeComments() → REAL-TIME comments update
```

### **RatingService**
```dart
- getRecipeRatings() → Fetch all ratings
- getAverageRating() → Calculate average rating
- getUserRating() → Get user's specific rating
- addOrUpdateRating() → Add or update user's rating
- deleteRating() → Delete rating
- subscribeToRecipeRatings() → REAL-TIME ratings update
```

### **FavoriteService**
```dart
- getUserFavorites() → Get user's favorite recipes
- isFavorited() → Check if recipe is favorited
- addFavorite() → Add to favorites
- removeFavorite() → Remove from favorites
- toggleFavorite() → Toggle favorite status
- subscribeToUserFavorites() → REAL-TIME favorites update
```

### **StorageService**
```dart
- uploadRecipeImage() → Upload recipe image (web & mobile)
- uploadUserAvatar() → Upload user avatar
- deleteRecipeImage() → Delete recipe image
- deleteUserAvatar() → Delete user avatar
```

---

## 📱 Step 5: Integration Flow

### **pada Login:**
```dart
1. AuthService → sign in user
2. UserService → get current user profile
3. RecipeService → fetch public recipes
```

### **pada Create Recipe:**
```dart
1. StorageService → upload image → get imageUrl
2. RecipeService → create recipe with imageUrl
3. Dashboard → refresh recipes list
```

### **pada Add Comment/Rating:**
```dart
1. CommentService.addComment() / RatingService.addOrUpdateRating()
2. Stream listener → automatic UI update (REAL-TIME)
```

### **pada Add/Remove Favorite:**
```dart
1. FavoriteService.toggleFavorite()
2. Stream listener → automatic UI update
```

---

## 🔒 Security Notes

✅ RLS (Row Level Security) sudah enabled:
- Hanya user bisa edit/delete recipe mereka
- Komentar hanya bisa dibuat oleh authenticated user
- Rating one user per recipe
- Favorites private untuk setiap user

---

## 🎯 Next Steps

1. **Run SQL schema** di Supabase Dashboard
2. **Create Storage buckets** (recipe-images & user-avatars)
3. **Update Dashboard & Pages** untuk gunakan services
4. **Test Real-time features** dengan 2 devices/tabs

Mari mulai integration ke pages! 🚀
