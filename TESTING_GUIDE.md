# 🧪 TESTING & VERIFICATION GUIDE - MasaKyuk

## ⚠️ PENTING: SETUP DATABASE DULU!

Sebelum testing, jalankan SQL schema di Supabase Dashboard:

### Step 1: Buka Supabase SQL Editor
```
https://supabase.com/dashboard/project/[PROJECT_ID]/sql
```

### Step 2: Jalankan SQL Schema
Copy-paste semua kode dari `supabase_schema.sql` ke SQL Editor, kemudian click **RUN**

Seharusnya hasilnya:
```
✅ CREATE TABLE success
✅ CREATE INDEX success
✅ ALTER TABLE success
✅ CREATE POLICY success
```

### Step 3: Buat Storage Buckets
1. Go to **Storage**
2. Buat 2 buckets dengan setting **Public**:
   - `recipe-images`
   - `user-avatars`

---

## ✅ Testing Checklist

### A. AUTH TESTING

**Test 1: Register User**
- [ ] Buka app → Klik "Daftar"
- [ ] Isi form: username, password
- [ ] Klik "Daftar"
- [ ] **✓ Harus berhasil** → redirect ke Login
- [ ] **Cek Database**: Go to Supabase → Table `user_profiles`
  - Harus ada 1 row baru dengan username & email

**Test 2: Login User**
- [ ] Isi email & password di Login page
- [ ] Klik "Selanjutnya"
- [ ] **✓ Harus masuk ke Dashboard** → Nama user muncul di top
- [ ] **Cek**: User berhasil ter-authenticate (session aktif)

**Test 3: Logout**
- [ ] Di Dashboard → Klik Profile icon (kanan atas)
- [ ] Klik "Keluar Akun"
- [ ] **✓ Harus redirect ke Login page**

---

### B. RECIPE TESTING

**Test 4: Create Recipe (dengan Image)**
- [ ] Login
- [ ] Klik + (Add button) di bottom
- [ ] Upload foto dari galeri
- [ ] Isi: Nama, Kategori, Bahan, Langkah-langkah
- [ ] Klik "Tambahkan Resep"
- [ ] **✓ Harus kembali ke Dashboard** → Recipe muncul di list
- [ ] **Cek Database**: 
  ```
  Supabase → Table recipes
  - Baru ada 1 row dengan title, user_id, image_url
  
  Supabase → Storage → recipe-images
  - File gambar tersimpan dengan nama: recipe_[ID]_[TIMESTAMP].jpg
  ```

**Test 5: View Recipe Detail**
- [ ] Di Dashboard, klik card resep
- [ ] **✓ Harus terbuka halaman detail** → Lihat foto, bahan, langkah
- [ ] Scroll ke bawah → Lihat Rating & Comment section

**Test 6: Add Rating**
- [ ] Di Recipe Detail, klik bintang (1-5)
- [ ] Klik "Kirim Rating"
- [ ] **✓ Rating harus tersimpan** → Tampil di halaman
- [ ] **Cek Database**:
  ```
  Supabase → Table ratings
  - Baru ada 1 row: recipe_id, user_id, stars, created_at
  ```

**Test 7: Add Comment**
- [ ] Di Recipe Detail, ketik komentar
- [ ] Klik send icon
- [ ] **✓ Komentar harus muncul** di list bawah
- [ ] **Cek Database**:
  ```
  Supabase → Table comments
  - Baru ada 1 row: recipe_id, user_id, text, created_at
  ```

---

### C. FAVORITE TESTING

**Test 8: Add to Favorites**
- [ ] Di Dashboard, klik ❤️ icon di recipe card
- [ ] **✓ Icon harus berubah jadi ❤️ merah**
- [ ] **Cek Database**:
  ```
  Supabase → Table favorites
  - Baru ada 1 row: user_id, recipe_id, created_at
  ```

**Test 9: View Favorites**
- [ ] Di bottom navbar, klik ❤️ icon
- [ ] **✓ Hanya favorited recipes yang muncul**
- [ ] Klik ❤️ lagi untuk remove → Hilang dari list
- [ ] **Cek Database**:
  ```
  Supabase → Table favorites
  - Row tadi harus terhapus
  ```

---

### D. REAL-TIME TESTING

**Test 10: Real-time Comments**
- [ ] Buka app di 2 tab/device berbeda
- [ ] Login dengan user yang sama
- [ ] Di Tab A: Buka recipe detail
- [ ] Di Tab B: Buka recipe yang SAMA
- [ ] Di Tab A: Tambah komentar
- [ ] **✓ Tab B harus langsung melihat komentar** (tanpa refresh)

**Test 11: Real-time Ratings**
- [ ] Sama seperti test 10, tapi dengan rating
- [ ] Di Tab A: Tambah rating
- [ ] **✓ Tab B harus langsung update average rating**

---

### E. USER PROFILE TESTING

**Test 12: Update Profile**
- [ ] Di Dashboard → Profile (icon kanan atas)
- [ ] Edit "Nama" → ketik nama baru
- [ ] Klik "Simpan Perubahan"
- [ ] **✓ Nama harus update** di Dashboard home
- [ ] **Cek Database**:
  ```
  Supabase → Table user_profiles
  - Column username harus ter-update
  ```

---

## 🔍 Cara Cek Database di Supabase

### Method 1: Supabase Dashboard (Mudah)

1. **Buka Supabase Dashboard**
   ```
   https://supabase.com/dashboard
   ```

2. **Pilih project** → Klik **Tables** di sidebar

3. **Lihat setiap table:**

   **`user_profiles`** - User data
   ```
   Columns: id, username, email, created_at, updated_at
   ```

   **`recipes`** - Recipe data
   ```
   Columns: id, user_id, title, description, steps, 
            category, image_url, is_public, created_at
   ```

   **`comments`** - Comments data
   ```
   Columns: id, recipe_id, user_id, text, created_at
   ```

   **`ratings`** - Ratings data
   ```
   Columns: id, recipe_id, user_id, stars, created_at
   ```

   **`favorites`** - Favorites data
   ```
   Columns: id, user_id, recipe_id, created_at
   ```

### Method 2: SQL Query (Advanced)

Di Supabase → **SQL Editor**, jalankan query ini:

```sql
-- Lihat semua users
SELECT id, username, email, created_at FROM user_profiles;

-- Lihat semua recipes
SELECT id, title, user_id, category, image_url, is_public, created_at FROM recipes;

-- Lihat semua comments beserta user
SELECT c.id, c.text, up.username, c.created_at 
FROM comments c
JOIN user_profiles up ON c.user_id = up.id
ORDER BY c.created_at DESC;

-- Lihat semua ratings dengan statistik
SELECT 
  r.recipe_id,
  COUNT(*) as total_ratings,
  AVG(r.stars) as avg_rating,
  MAX(r.stars) as max_rating,
  MIN(r.stars) as min_rating
FROM ratings r
GROUP BY r.recipe_id;

-- Lihat semua favorites
SELECT 
  f.user_id, 
  up.username, 
  r.title,
  f.created_at
FROM favorites f
JOIN user_profiles up ON f.user_id = up.id
JOIN recipes r ON f.recipe_id = r.id
ORDER BY f.created_at DESC;
```

---

## 🔒 Cara Cek Storage (Images)

1. **Buka Supabase Dashboard**
2. **Go to Storage** → Klik bucket `recipe-images`
3. **Lihat file yang ter-upload:**
   - Format: `recipe_[RECIPE_ID]_[TIMESTAMP].jpg`
   - Click file → Lihat **Public URL** (untuk NetworkImage)

---

## 🚨 Troubleshooting

### Problem 1: Database kosong setelah register
❌ **Penyebab**: SQL schema belum di-run
✅ **Solusi**: 
- Go to Supabase → SQL Editor
- Run `supabase_schema.sql` sepenuhnya

### Problem 2: Error saat upload image
❌ **Penyebab**: Storage bucket belum dibuat atau permission error
✅ **Solusi**:
- Pastikan 2 buckets sudah dibuat: `recipe-images`, `user-avatars`
- Pastikan bucket setting: **Public** (bukan Private)

### Problem 3: Real-time tidak jalan
❌ **Penyebab**: Supabase realtime belum aktif atau subscription error
✅ **Solusi**:
- Check di Supabase Dashboard → Settings → Replication
- Pastikan table punya **Enable realtime** ✓

### Problem 4: Favorit tidak sync
❌ **Penyebab**: Favorite service gagal query
✅ **Solusi**:
- Check Supabase logs: Dashboard → Logs
- Verify RLS policy untuk favorites table sudah benar

---

## 📊 Contoh Data yang Harus Ada

Setelah semua test berhasil, database Anda harus seperti ini:

**user_profiles table** (minimal 1 row):
```
| id | username | email | created_at |
|----|----------|-------|-----------|
| abc123 | rayya123 | rayya@email.com | 2024-06-04... |
```

**recipes table** (minimal 1 row):
```
| id | user_id | title | category | image_url | is_public | created_at |
|----|---------|-------|----------|-----------|-----------|-----------|
| recipe_xyz | abc123 | Nasi Goreng | Makan Siang | https://... | true | 2024-06-04... |
```

**ratings table** (minimal 1 row):
```
| id | recipe_id | user_id | stars | created_at |
|----|-----------|---------|-------|-----------|
| rating_1 | recipe_xyz | abc123 | 5 | 2024-06-04... |
```

**comments table** (minimal 1 row):
```
| id | recipe_id | user_id | text | created_at |
|----|-----------|---------|------|-----------|
| comment_1 | recipe_xyz | abc123 | Enak sekali! | 2024-06-04... |
```

**favorites table** (minimal 1 row):
```
| id | user_id | recipe_id | created_at |
|----|---------|-----------|-----------|
| fav_1 | abc123 | recipe_xyz | 2024-06-04... |
```

---

## ✨ Testing Tips

1. **Test dengan 2 device/tab** untuk real-time features
2. **Refresh Supabase dashboard** untuk lihat data terbaru
3. **Check console error** di browser DevTools (F12)
4. **Enable RLS** di Supabase untuk security
5. **Backup data** sebelum testing destructive operations

---

## 🎯 Success Criteria

Semua test berhasil jika:
- ✅ Data tersimpan di database setelah setiap aksi
- ✅ Real-time update terlihat di multiple devices
- ✅ Images ter-upload ke Storage
- ✅ RLS policies melindungi data user
- ✅ Comments & Ratings ter-sync instantly
- ✅ Favorit bisa add/remove dengan instant UI update

Jika semua ✅, **aplikasi siap production!** 🚀
