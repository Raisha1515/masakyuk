# 🚀 COMPLETE SETUP CHECKLIST - MasaKyuk

Ikuti langkah-langkah ini untuk setup aplikasi dari nol.

---

## STEP 1: Setup Supabase Database ✅

### 1.1 Buka Supabase SQL Editor
- Go to: `https://supabase.com/dashboard`
- Pilih project Anda
- Click **SQL Editor** di sidebar kiri
- Click **New Query**

### 1.2 Jalankan SQL Schema
- Buka file `supabase_schema.sql`
- Copy-paste semua SQL ke editor
- Click **RUN** (ctrl+enter)

Expected output:
```
✅ CREATE TABLE "public"."user_profiles" successfully
✅ CREATE TABLE "public"."recipes" successfully
✅ CREATE TABLE "public"."comments" successfully
✅ CREATE TABLE "public"."ratings" successfully
✅ CREATE TABLE "public"."favorites" successfully
✅ CREATE INDEX successfully (multiple times)
✅ ALTER TABLE successfully (multiple times)
✅ CREATE POLICY successfully (multiple times)
```

### 1.3 Verify Tables
- Click **Tables** di sidebar
- Seharusnya ada 5 tables:
  - `user_profiles`
  - `recipes`
  - `comments`
  - `ratings`
  - `favorites`

---

## STEP 2: Setup Storage Buckets 📦

### 2.1 Buat Bucket 1: recipe-images
- Go to **Storage** → **Buckets**
- Click **Create new bucket**
- Name: `recipe-images`
- **Uncheck** "Private bucket" (harus Public)
- Click **Create bucket**

### 2.2 Buat Bucket 2: user-avatars
- Click **Create new bucket** lagi
- Name: `user-avatars`
- **Uncheck** "Private bucket" (harus Public)
- Click **Create bucket**

### 2.3 Verify Buckets
- Seharusnya ada 2 buckets:
  - ✅ recipe-images (Public)
  - ✅ user-avatars (Public)

---

## STEP 3: Verify Supabase Config ⚙️

File: `lib/core/supabase_config.dart`

✅ Sudah ada URL dan Key:
```dart
static const String supabaseUrl = 'https://usaegxsptywnnkrnfysn.supabase.co';
static const String supabaseAnonKey = 'eyJhbGc...';
```

**Note**: Jangan share keys ini ke public/GitHub!

---

## STEP 4: Install Dependencies 📚

Semua dependencies sudah ada di `pubspec.yaml`:
- ✅ `supabase_flutter: ^2.12.4`
- ✅ `image_picker: ^1.0.7`
- ✅ `permission_handler: 12.0.1`
- ✅ `shared_preferences: ^2.2.2`

Run: `flutter pub get`

---

## STEP 5: Test Application 🧪

### 5.1 Run App
```bash
flutter run
```

### 5.2 Test Registration
1. Klik "Daftar"
2. Isi: username, password, confirm password
3. Klik "Daftar"
4. **Should**: Success → redirect ke Login

### 5.3 Check Database
- Go to Supabase → Table `user_profiles`
- **Should**: Ada 1 row baru dengan data user Anda

### 5.4 Test Login
1. Klik "Masuk"
2. Isi: username (email), password
3. Klik "Selanjutnya"
4. **Should**: Berhasil login → Dashboard

### 5.5 Test Add Recipe
1. Klik **+** button (Add)
2. Upload foto
3. Isi: Nama, Kategori, Bahan, Langkah
4. Klik "Tambahkan Resep"
5. **Should**: Kembali ke Dashboard, recipe muncul

### 5.6 Check Storage
- Go to Supabase → Storage → `recipe-images`
- **Should**: Ada file gambar dengan nama: `recipe_[ID]_[TIMESTAMP].jpg`

### 5.7 Test Comments & Ratings
1. Buka recipe detail (klik card)
2. Scroll ke bawah → Rating section
3. Klik bintang → Kirim Rating
4. **Should**: Rating tersimpan, muncul di database

5. Di section Komentar:
6. Ketik komentar → Send
7. **Should**: Komentar muncul di list, tersimpan di database

### 5.8 Test Favorites
1. Di Dashboard, klik ❤️ icon di recipe card
2. **Should**: Icon berubah jadi ❤️ merah
3. Go to Supabase → Table `favorites`
4. **Should**: Ada 1 row baru

---

## STEP 6: File Structure ✨

Struktur folder setelah setup:

```
lib/
├── core/
│   └── supabase_config.dart          ✅ (Ada, jangan edit)
├── models/
│   ├── recipe_model.dart             ✅ (Updated)
│   └── user_model.dart               ✅ (New)
├── services/
│   ├── auth_service.dart             ✅ (Updated)
│   ├── recipe_service.dart           ✅ (Updated)
│   ├── comment_service.dart          ✅ (New)
│   ├── rating_service.dart           ✅ (New)
│   ├── favorite_service.dart         ✅ (New)
│   ├── storage_service.dart          ✅ (New)
│   └── user_service.dart             ✅ (New)
├── main.dart                          ✅ (Updated)
├── auth_gate.dart
├── login.dart                         ✅ (Updated)
├── register.dart                      ✅ (Updated)
├── dashboard.dart                     ✅ (Updated)
├── tambah_resep.dart                  ✅ (Updated)
├── recipe_detail_page.dart            ✅ (Updated)
├── recipe_detail_page.dart
├── private_recipes_page.dart
├── trending_page.dart
└── forgot_password.dart
```

---

## STEP 7: Common Issues & Fixes 🔧

### Issue 1: "No tables found" di Supabase
- **Fix**: Run SQL schema from `supabase_schema.sql`

### Issue 2: Image upload fails
- **Fix**: Check if `recipe-images` bucket exists and is PUBLIC

### Issue 3: Real-time not working
- **Fix**: Check Supabase → Settings → Replication → Enable realtime for tables

### Issue 4: Login error "Invalid credentials"
- **Fix**: Make sure you registered first, use correct email/password

### Issue 5: User profile not showing
- **Fix**: User profile created automatically when registering, check `user_profiles` table

---

## STEP 8: Deployment Ready Checklist ✅

Sebelum go live:

- [ ] SQL schema ter-run di Supabase
- [ ] 2 storage buckets dibuat (PUBLIC)
- [ ] All services di `lib/services/` ada
- [ ] Models updated dengan `userId` dan `imageUrl`
- [ ] Dashboard menggunakan services (bukan SharedPreferences)
- [ ] Login/Register menggunakan AuthService
- [ ] Recipe upload ke database + Storage
- [ ] Comments & Ratings bisa ditambah
- [ ] Favorites bisa ditoggle
- [ ] Real-time updates work (test di 2 tab)
- [ ] User profile bisa di-update
- [ ] Logout berjalan sempurna

---

## STEP 9: Production Checklist 🎯

- [ ] Enable RLS policies di ALL tables
- [ ] Setup Supabase backup
- [ ] Monitor database usage
- [ ] Optimize images sebelum upload (sudah ada: `imageQuality: 85`)
- [ ] Add error handling untuk network failures
- [ ] Test app di iOS & Android (jika development)
- [ ] Setup analytics (optional)
- [ ] Plan for data maintenance

---

## NEXT FEATURES (Optional) 🚀

Jika mau tambah fitur:

1. **Search Recipes**
   - Add search functionality
   - Filter by category, rating, date

2. **Follow Users**
   - Add follow/unfollow
   - Show user's recipes

3. **Recipe Collections**
   - Organize favorites into collections
   - Share collections with others

4. **Notifications**
   - Push notifications untuk new comments
   - Like/follow notifications

5. **Recipe Scaling**
   - Scale ingredients berdasarkan serving size

---

## SUPPORT & DEBUGGING

### Enable Console Logs
```dart
// Di services, logs sudah ada:
print('Error creating recipe: $e');
print('Loading recipes...');
```

### Check Supabase Logs
- Dashboard → Logs → Check for errors

### Debug Real-time
- Subscribe ke changes:
```dart
recipeService.subscribeToRecipe(recipeId).listen((recipe) {
  print('Recipe updated: ${recipe?.name}');
});
```

---

## 🎉 Selesai!

Aplikasi siap digunakan. Nikmati! 🎊

Untuk testing detail, lihat: `TESTING_GUIDE.md`
Untuk integration guide, lihat: `INTEGRATION_GUIDE.md`
