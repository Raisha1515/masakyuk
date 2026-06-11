# ⚡ QUICK START - MasaKyuk

Panduan cepat untuk mulai menggunakan aplikasi!

---

## 🚀 3 Langkah Setup (5 Menit)

### Langkah 1: Setup Database (2 menit)

1. Buka: https://supabase.com/dashboard/project/[YOUR_PROJECT_ID]/sql

2. Klik **New Query**

3. Copy-paste semua isi dari file: `supabase_schema.sql`

4. Klik **RUN** (atau ctrl+enter)

**Tunggu sampai semua selesai** ✅

---

### Langkah 2: Setup Storage (2 menit)

1. Go to **Storage** di Supabase dashboard

2. Buat 2 buckets (klik **Create new bucket** 2x):
   - Name: `recipe-images` → **Uncheck** "Private"
   - Name: `user-avatars` → **Uncheck** "Private"

**Done!** ✅

---

### Langkah 3: Run App (1 menit)

```bash
flutter pub get
flutter run
```

**Aplikasi siap digunakan!** ✅

---

## 🎮 Testing Flow

1. **Register** → Isi username, password, confirm password
2. **Login** → Gunakan credentials yang sama
3. **Add Recipe** → Upload foto, isi form, submit
4. **View Recipe** → Klik card, lihat detail
5. **Add Rating** → Klik bintang, submit
6. **Add Comment** → Ketik komentar, send
7. **Add Favorite** → Klik ❤️ icon
8. **Check Database** → Go to Supabase, lihat tables terisi

---

## 🔍 Cara Cek Database

### Via Supabase Dashboard

1. Go to: https://supabase.com/dashboard
2. Klik **Tables** di sidebar
3. Lihat ada 5 tables:
   - ✅ `user_profiles` - Users
   - ✅ `recipes` - Recipes
   - ✅ `comments` - Comments
   - ✅ `ratings` - Ratings
   - ✅ `favorites` - Favorites

### Lihat Row Data

- Klik nama table
- Lihat data yang tersimpan
- Klik row untuk detail

---

## 📸 Cek Storage

1. Go to **Storage** di Supabase
2. Klik bucket `recipe-images`
3. **Should see**: Files dengan nama `recipe_[ID]_[TIMESTAMP].jpg`

---

## ✨ Features Ready to Use

- ✅ Register & Login
- ✅ Create Recipe (dengan image)
- ✅ View Recipe Detail
- ✅ Add Comments (real-time)
- ✅ Add Ratings (real-time)
- ✅ Add to Favorites (real-time)
- ✅ Update Profile
- ✅ Filter by Category
- ✅ Real-time sync across devices

---

## 🚨 Troubleshooting

**Q: Database kosong setelah register?**
- A: SQL schema belum di-run. Run `supabase_schema.sql` di SQL Editor.

**Q: Error saat upload image?**
- A: Storage buckets belum dibuat atau tidak PUBLIC. Check Step 2.

**Q: Realtime tidak sync?**
- A: Enable realtime di Supabase Settings. Usually auto-enabled.

**Q: Login gagal?**
- A: Register dulu, gunakan email & password yang sama saat login.

---

## 📂 Important Files

- `supabase_schema.sql` - Database schema (run di SQL Editor)
- `lib/services/` - Semua logic bisnis
- `COMPLETE_SETUP.md` - Setup detail
- `TESTING_GUIDE.md` - Testing checklist
- `IMPLEMENTATION_SUMMARY.md` - Apa yang sudah di-buat

---

## 📱 Testing dengan 2 Device

Untuk test real-time features:

1. Run app di device 1
2. Run app di device 2 lain
3. Login dengan user yang SAMA di kedua device
4. Di device 1: Tambah comment
5. **Di device 2: Comment muncul otomatis** ✅ (real-time)

---

## 🎯 Success Checklist

Kalau semua ini berhasil, aplikasi sudah production-ready:

- [ ] Register berhasil → user_profile created
- [ ] Login berhasil → masuk dashboard
- [ ] Add recipe berhasil → data tersimpan
- [ ] Image upload berhasil → lihat di Storage
- [ ] Comment real-time → sync 2 device
- [ ] Rating real-time → average update
- [ ] Favorite toggle → instant
- [ ] Logout berhasil → back to login

---

## 🎉 Done!

Aplikasi siap digunakan. Mulai buat resep! 👨‍🍳

Untuk detail lebih lanjut, baca:
- `COMPLETE_SETUP.md` - Setup lengkap
- `TESTING_GUIDE.md` - Testing detail
- `IMPLEMENTATION_SUMMARY.md` - Summary

---

**Happy Cooking!** 🍽️
