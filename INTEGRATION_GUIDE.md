# 🔄 INTEGRATION GUIDE - Mengubah Pages ke Database

## 📋 File-file yang perlu diupdate:

1. ✅ `auth_service.dart` - Already partially done, perlu complete
2. ✅ `dashboard.dart` - Main file perlu major update
3. ✅ `tambah_resep.dart` - Update untuk store to database
4. ✅ `recipe_detail_page.dart` - Real-time comments & ratings
5. ✅ `login.dart` - Create user profile saat register
6. ✅ `register.dart` - Create user profile saat register
7. ✅ `private_recipes_page.dart` - Filter private recipes
8. ✅ `trending_page.dart` - Filter by likes/ratings

---

## 🔄 Update Pattern

### Pattern 1: Replace SharedPreferences dengan Database

**SEBELUM (Local Storage):**
```dart
Future<void> _saveAllData() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> recipeJsonList = recipeList.map((r) => jsonEncode(r.toJson())).toList();
  await prefs.setStringList("saved_recipes", recipeJsonList);
}
```

**SESUDAH (Database):**
```dart
final recipeService = RecipeService();

Future<void> _loadRecipes() async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user != null) {
    final recipes = await recipeService.getPublicRecipes();
    setState(() => recipeList = recipes);
  }
}
```

### Pattern 2: Real-time Updates

**Gunakan StreamBuilder untuk auto-update:**
```dart
StreamBuilder<List<Recipe>>(
  stream: recipeService.subscribeToPublicRecipes(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      return buildGrid(snapshot.data!);
    }
    return const Center(child: CircularProgressIndicator());
  },
)
```

### Pattern 3: User-specific Data

**Get current user ID:**
```dart
final user = Supabase.instance.client.auth.currentUser;
final userId = user?.id;

if (userId != null) {
  final favorites = await favoriteService.getUserFavorites(userId);
  final userRecipes = await recipeService.getUserRecipes(userId);
}
```

---

## 📝 Priority Update Order

### Priority 1: Authentication (CRITICAL)
- `auth_service.dart` - Complete login/register flow
- `register.dart` - Create user_profile saat register
- `login.dart` - Load user data setelah login

### Priority 2: Recipe Management
- `tambah_resep.dart` - Upload ke database + storage
- `dashboard.dart` - Load public recipes dari database
- `recipe_detail_page.dart` - Real-time comments & ratings

### Priority 3: Features
- `private_recipes_page.dart` - Filter private recipes
- `trending_page.dart` - Sort by ratings/popularity

---

## 💡 Implementation Tips

1. **Always get current user:**
   ```dart
   final user = Supabase.instance.client.auth.currentUser;
   final userId = user?.id ?? '';
   ```

2. **Handle null values:**
   ```dart
   try {
     // operation
   } catch (e) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Error: $e')),
     );
   }
   ```

3. **Use loading states:**
   ```dart
   bool isLoading = false;
   setState(() => isLoading = true);
   try {
     // async operation
   } finally {
     setState(() => isLoading = false);
   }
   ```

4. **For real-time data:**
   ```dart
   @override
   void initState() {
     super.initState();
     _subscription = recipeService.subscribeToPublicRecipes().listen((recipes) {
       setState(() => recipeList = recipes);
     });
   }
   
   @override
   void dispose() {
     _subscription?.cancel();
     super.dispose();
   }
   ```

---

## 🚨 Testing Checklist

- [ ] Login berhasil → user profile tersimpan
- [ ] Upload resep → gambar di storage, data di database
- [ ] Comment realtime → muncul di device lain instantly
- [ ] Rating realtime → average rating update instantly
- [ ] Favorite toggle → update instantly
- [ ] Delete resep → cascade delete comments & ratings
- [ ] Private recipes → hanya bisa diakses owner

---

Mari kita mulai update file demi file! Siapa yang duluan? 🚀
