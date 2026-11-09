# PLAN.md — S Pen Destekli Flutter Çizim Modülü Uygulama Planı

Bu plan, **Samsung Galaxy Tab S10 FE (S Pen)** üzerinde çalışacak ve tamamlandığında **Skynotes** (Android + Windows) projesine tek bir klasör olarak taşınacak el yazısı/çizim çekirdeğini adım adım inşa etmek için hazırlanmıştır.

---

## 1. Paket ve Mimari Tercihi (Neden Bu Yapı?)

- **Çizim Motoru (`CustomPainter` + `Listener` + `perfect_freehand` paketi):**
  - *Neden sadece düz `CustomPainter` değil?* Ham `CustomPainter` ile iki nokta arasına düz çizgi (`drawLine`) çekildiğinde S Pen'in **basınç (pressure)** bilgisini çizgi boyunca akıcı şekilde inceltip kalınlaştırmak çok zordur; çizgiler köşeli veya kesik kesik görünür.
  - *Neden `perfect_freehand`?* Basınç verisini (`pressure`) alıp gerçek mürekkep hissi veren pürüzsüz (smooth) dış hatlara (polygon path) dönüştüren, dış bağımlılığı olmayan çok hafif ve saf Dart bir pakettir. Hem Android (S Pen) hem Windows'ta sorunsuz çalışır.
- **Dosya Kayıt (`path_provider` + `dart:convert`):**
  - Çizimleri tabletin yerel depolama alanına JSON dosyası olarak kaydetmek için yalnızca resmi `path_provider` paketi kullanılacaktır.
- **State Management (Paket Yok):**
  - `StatefulWidget` ve `setState` bu modül için fazlasıyla yeterlidir. Ekstra paket karmaşası sıfırdır.

---

## 2. Önerilen Klasör ve Dosya Yapısı

Proje oluştuğunda dosya yapısı aşağıdaki gibi olacaktır. `lib/drawing/` klasörü **Skynotes'a kopyalanacak bağımsız modüldür**:

```text
skybook_drawing_test/
├── AGENTS.md                         # Kodlama ajanının her adımda uyacağı kurallar.
├── PLAN.md                           # Bu uygulama planı.
├── pubspec.yaml                      # Paket tanımları (perfect_freehand, path_provider).
└── lib/
    ├── main.dart                     # Sadece test amaçlı başlangıç dosyası (DrawingPage'i açar).
    └── drawing/                      # BAĞIMSIZ ÇİZİM MODÜLÜ
        ├── drawing_page.dart         # Dışarıdan çağrılan ana ekran widget'ı; tuvali ve araç çubuğunu birleştirir.
        ├── drawing_canvas.dart       # S Pen olaylarını yakalayan (Listener) ve ekrana çizen (CustomPainter) tuval.
        ├── drawing_toolbar.dart      # Renk, kalınlık, silgi, geri al/ileri al ve kaydet/yükle butonlarının olduğu bar.
        ├── stroke_model.dart         # Tek bir noktayı (StrokePoint) ve çizgiyi (Stroke) tutan veri modelleri.
        └── stroke_storage.dart       # Çizimi JSON formatında dosyaya kaydeden ve dosyadan okuyan sınıf.
```

---

## 3. Adım Adım Uygulama Planı

### Ön Hazırlık (Senin Çalıştıracağın Komutlar)
Ajana geçmeden önce terminali açıp bu klasörde (`d:\Skybook`) sıfır bir Flutter projesi oluşturmak istersen şu komutları çalıştırabilirsin (eğer proje henüz oluşturulmadıysa):

```powershell
flutter create --org com.skynotes .
git init
git add .
git commit -m "chore: initial flutter project"
```
> **Not:** `AGENTS.md` ve `PLAN.md` dosyaları zaten kök dizindedir. Her adımda ajana `"Önce AGENTS.md dosyasını oku, sonra aşağıdaki görevi yap"` diyerek ilgili adımın promptunu yapıştır.

---

### Adım 1: Boş Tuval Üzerinde S Pen ile Çizgi Çizme (Basınç Okuma Dahil)

- **Amaç:** Veri modellerini (`StrokePoint`, `Stroke`) oluşturmak, `Listener` ile S Pen hareketlerini ve basınç (`event.pressure`) değerini yakalayıp ekranda ilk çizgileri göstermek.
- **Dokunulacak dosyalar:**
  - `lib/main.dart`
  - `lib/drawing/stroke_model.dart` (yeni)
  - `lib/drawing/drawing_canvas.dart` (yeni)
  - `lib/drawing/drawing_page.dart` (yeni)
- **Dokunulmayacak dosyalar:**
  - `pubspec.yaml` (Bu adımda paket eklenmeyecek)
- **Ajana Verilecek Prompt:**
  ```text
  Önce kök dizindeki AGENTS.md dosyasını oku ve kurallara uy.
  Sadece PLAN.md içindeki Adım 1'i yap:

  1. `lib/drawing/stroke_model.dart` dosyasını oluştur:
     - `StrokePoint` sınıfı: `double x`, `double y`, `double pressure` alanlarını tutsun.
     - `Stroke` sınıfı: `List<StrokePoint> points`, `Color color`, `double size` alanlarını tutsun.
  2. `lib/drawing/drawing_canvas.dart` dosyasını oluştur:
     - `Listener` widget'ı kullanarak `onPointerDown`, `onPointerMove`, `onPointerUp` olaylarını yakala.
     - `PointerEvent` içinden `localPosition.dx`, `localPosition.dy` ve `pressure` (eğer 0 veya desteklenmiyorsa varsayılan 0.5) değerlerini oku.
     - `CustomPainter` ile noktalar arasına çizgi çiz. Basınç etkisini görmek için şimdilik çizgi kalınlığını `stroke.size * point.pressure` olarak uygula.
  3. `lib/drawing/drawing_page.dart` dosyasını oluştur:
     - Tam ekran beyaz arka planlı bir `Scaffold` içinde `DrawingCanvas` widget'ını göster.
     - Ekranın sağ üst köşesine geçici olarak son okunan basınç değerini (`Basınç: 0.xx`) yazdıran küçük bir `Text` koy ki S Pen basıncının çalıştığını doğrulayabilelim.
  4. `lib/main.dart` dosyasını sadece `DrawingPage` açacak şekilde sadeleştir.

  Başka hiçbir özellik veya paket ekleme.
  ```
- **Doğrulama Maddesi:** Tablette `flutter run` çalıştırdığında bembeyaz bir ekran açılmalı. S Pen ile ekrana bastırarak çizdiğinde siyah çizgiler oluşmalı, sağ üstteki basınç sayısı kalemi bastırma gücüne göre `0.10` ile `1.00` arasında değişmeli ve çok bastırdığında çizgi kalınlaşmalı.
- **Git Commit Önerisi:**
  ```powershell
  git add .
  git commit -m "feat: step 1 - basic s-pen drawing and pressure capture"
  ```

---

### Adım 2: Çizgilerin Pürüzsüz Görünmesi (Smoothing)

- **Amaç:** Köşeli ve kesik çizgileri `perfect_freehand` paketiyle gerçek kalem/mürekkep gibi pürüzsüz ve basınca duyarlı hale getirmek.
- **Dokunulacak dosyalar:**
  - `pubspec.yaml`
  - `lib/drawing/drawing_canvas.dart`
- **Dokunulmayacak dosyalar:**
  - `lib/main.dart`
  - `lib/drawing/stroke_model.dart`
  - `lib/drawing/drawing_page.dart`
- **Ajana Verilecek Prompt:**
  ```text
  Önce AGENTS.md dosyasını oku. Sadece Adım 2'yi yap:

  1. `pubspec.yaml` dosyasına `perfect_freehand: ^2.3.1` paketini ekle (onayım var).
  2. Sadece `lib/drawing/drawing_canvas.dart` içindeki `CustomPainter` (`paint` metodu) kısmını güncelle:
     - `StrokePoint` listesini `perfect_freehand` paketinin `PointVector(p.x, p.y, p.pressure)` listesine çevir.
     - `getStroke()` fonksiyonunu kullanarak pürüzsüz dış hat (outline) noktalarını hesapla (`simulatePressure: false` yap çünkü gerçek S Pen basıncı kullanıyoruz).
     - Dönen noktaları `Path` nesnesine çevirip `canvas.drawPath` ve `PaintingStyle.fill` ile ekrana çiz.

  `lib/main.dart`, `stroke_model.dart` ve `drawing_page.dart` dosyalarına dokunma.
  ```
- **Doğrulama Maddesi:** Uygulamayı çalıştırıp S Pen ile hızlıca yuvarlaklar ve el yazısı yazdığında kırık köşeler tamamen kaybolmalı; çizgiler tıpkı GoodNotes'taki dolma kalem/keçeli kalem gibi uçları incelen, kıvrımları pürüzsüz çizgilere dönüşmeli.
- **Git Commit Önerisi:**
  ```powershell
  git add .
  git commit -m "feat: step 2 - smooth pressure-sensitive strokes with perfect_freehand"
  ```

---

### Adım 3: Kalem Rengi ve Kalınlık Seçimi

- **Amaç:** Üst kısma basit bir araç çubuğu (`DrawingToolbar`) ekleyerek 5 temel renk ve 3 farklı kalem kalınlığı seçebilmek.
- **Dokunulacak dosyalar:**
  - `lib/drawing/drawing_toolbar.dart` (yeni)
  - `lib/drawing/drawing_page.dart`
  - `lib/drawing/drawing_canvas.dart`
- **Dokunulmayacak dosyalar:**
  - `lib/main.dart`
  - `lib/drawing/stroke_model.dart`
  - `pubspec.yaml`
- **Ajana Verilecek Prompt:**
  ```text
  Önce AGENTS.md dosyasını oku. Sadece Adım 3'ü yap:

  1. `lib/drawing/drawing_toolbar.dart` dosyasını oluştur:
     - Seçili rengi (`selectedColor`) ve seçili kalınlığı (`selectedSize`) dışarıdan parametre olarak alan, değiştiğinde callback (`onColorChanged`, `onSizeChanged`) tetikleyen bir `StatelessWidget` yaz.
     - Renk seçenekleri: Siyah, Mavi, Kırmızı, Yeşil, Turuncu (yuvarlak renk butonları, seçili olanın etrafında çerçeve olsun).
     - Kalınlık seçenekleri: İnce (`3.0`), Orta (`6.0`), Kalın (`12.0`) olarak 3 buton koy.
  2. `lib/drawing/drawing_page.dart` içinde seçili renk ve kalınlığı state olarak tut. Üste `DrawingToolbar` ekle ve seçilen değerleri `DrawingCanvas` widget'ına aktar.
  3. `lib/drawing/drawing_canvas.dart` içinde yeni başlayan her çizginin (`Stroke`) o anki seçili renk ve kalınlığı almasını sağla. Önceki çizilmiş çizgilerin rengi ve kalınlığı değişmesin.

  `main.dart` ve `stroke_model.dart` dosyalarına dokunma.
  ```
- **Doğrulama Maddesi:** Ekranın üstünde renk topları ve İnce/Orta/Kalın butonları görünmeli. Mavi ve Kalın seçip çizdiğinde mavi kalın çizgi, ardından Kırmızı ve İnce seçip çizdiğinde kırmızı ince çizgi çizilmeli (eski mavi çizgi olduğu gibi kalmalı).
- **Git Commit Önerisi:**
  ```powershell
  git add .
  git commit -m "feat: step 3 - add toolbar with color and stroke size selection"
  ```

---

### Adım 4: Silgi (Eraser)

- **Amaç:** Araç çubuğuna bir Silgi butonu eklemek. (Not uygulamalarında en temiz yöntem olan "dokunulan çizgiyi silen vektörel silgi" veya "beyaz/tuval rengi silgi" yerine, kullanımı en pratik ve sonraki kayıtlarda sorun çıkarmayan **dokunulan çizgiyi silme (stroke eraser)** yöntemi kullanılacaktır).
- **Dokunulacak dosyalar:**
  - `lib/drawing/drawing_toolbar.dart`
  - `lib/drawing/drawing_page.dart`
  - `lib/drawing/drawing_canvas.dart`
- **Dokunulmayacak dosyalar:**
  - `lib/main.dart`
  - `lib/drawing/stroke_model.dart`
  - `pubspec.yaml`
- **Ajana Verilecek Prompt:**
  ```text
  Önce AGENTS.md dosyasını oku. Sadece Adım 4'ü yap:

  1. `lib/drawing/drawing_toolbar.dart` içine bir "Kalem / Silgi" geçiş butonu (`isEraserMode` bool ve `onEraserToggled` callback) ekle. Silgi aktifken buton belirgin görünsün. Renklerden birini seçince otomatik olarak kalem moduna geri dönsün.
  2. `lib/drawing/drawing_page.dart` içinde `isEraserMode` durumunu tut ve `DrawingCanvas`'a ilet.
  3. `lib/drawing/drawing_canvas.dart` içinde:
     - Eğer `isEraserMode == true` ise yeni çizgi ekleme.
     - Bunun yerine kalemin dokunduğu/sürüklendiği koordinata (`localPosition`) `20.0` piksel mesafeden daha yakın noktası bulunan mevcut `Stroke` nesnelerini listeden sil (çizgi silgisi).

  `main.dart` ve `stroke_model.dart` dosyalarına dokunma.
  ```
- **Doğrulama Maddesi:** Birkaç çizgi çizdikten sonra araç çubuğundan Silgi ikonuna bas. S Pen'i mevcut bir çizginin üzerinden geçirdiğinde o çizgi anında silinmeli. Tekrar bir renge bastığında normal çizime devam etmeli.
- **Git Commit Önerisi:**
  ```powershell
  git add .
  git commit -m "feat: step 4 - add stroke eraser mode"
  ```

---

### Adım 5: Geri Al / İleri Al (Undo / Redo)

- **Amaç:** Yanlış çizilen veya yanlışlıkla silinen çizgileri geri alabilmek (`Undo`) ve tekrar ileri alabilmek (`Redo`).
- **Dokunulacak dosyalar:**
  - `lib/drawing/drawing_toolbar.dart`
  - `lib/drawing/drawing_page.dart`
  - `lib/drawing/drawing_canvas.dart`
- **Dokunulmayacak dosyalar:**
  - `lib/main.dart`
  - `lib/drawing/stroke_model.dart`
  - `pubspec.yaml`
- **Ajana Verilecek Prompt:**
  ```text
  Önce AGENTS.md dosyasını oku. Sadece Adım 5'i yap:

  1. Çizgi listesini (`List<Stroke> strokes`) ve geri alınan işlemler için geçmiş yığınını (`List<List<Stroke>> undoStack` ve `redoStack`) `lib/drawing/drawing_page.dart` içinde yönet (veya mevcut yapıya uygun şekilde `DrawingPage` üzerinden kontrol et).
  2. Her yeni çizgi tamamlandığında veya silgiyle bir çizgi silindiğinde önceki durumu `undoStack` içine kopyala (`List<Stroke>.from(strokes)`) ve `redoStack`'i temizle.
  3. `lib/drawing/drawing_toolbar.dart` içine Undo (Geri Al) ve Redo (İleri Al) ikon butonları ekle. Yığın boşsa ilgili buton pasif (`null`) olsun.
  4. `main.dart` ve `stroke_model.dart` dosyalarına dokunma.
  ```
- **Doğrulama Maddesi:** Ekrana 3 ayrı çizgi çiz. Undo butonuna 2 kez bastığında son 2 çizgi sırayla kaybolmalı. Redo butonuna 1 kez bastığında geri alınan çizgilerden biri tekrar ekrana gelmeli.
- **Git Commit Önerisi:**
  ```powershell
  git add .
  git commit -m "feat: step 5 - add undo and redo support"
  ```

---

### Adım 6: Parmakla Çizmeyi Kapatma / Sadece S Pen (Avuç İçi Reddi)

- **Amaç:** Galaxy Tab S10 FE ekranına elini/avucunu koyarak yazarken parmak ve avuç dokunuşlarının çizim yapmasını engellemek; yalnızca S Pen (`PointerDeviceKind.stylus` ve `invertedStylus`) ile çizim yapılmasını sağlamak.
- **Dokunulacak dosyalar:**
  - `lib/drawing/drawing_toolbar.dart`
  - `lib/drawing/drawing_page.dart`
  - `lib/drawing/drawing_canvas.dart`
- **Dokunulmayacak dosyalar:**
  - `lib/main.dart`
  - `lib/drawing/stroke_model.dart`
  - `pubspec.yaml`
- **Ajana Verilecek Prompt:**
  ```text
  Önce AGENTS.md dosyasını oku. Sadece Adım 6'yı yap:

  1. `lib/drawing/drawing_page.dart` içine `bool stylusOnly = true` (varsayılan olarak açık) durumu ekle.
  2. `lib/drawing/drawing_toolbar.dart` içine "Sadece Kalem" (Stylus Only) açma/kapama butonu ekle (aktifken mavi/belirgin olsun).
  3. `lib/drawing/drawing_canvas.dart` içindeki `onPointerDown`, `onPointerMove`, `onPointerUp` olaylarında:
     - Eğer `stylusOnly == true` ise gelen olayın `event.kind` değerini kontrol et (`import 'dart:ui';`).
     - Sadece `event.kind == PointerDeviceKind.stylus` veya `event.kind == PointerDeviceKind.invertedStylus` ise çizim/silme işlemine izin ver. Parmak (`touch`) dokunuşlarını tamamen yoksay.
     - Eğer `stylusOnly == false` ise hem parmak hem kalem çizebilsin (emülatörde veya fareyle test kolaylığı için).

  `main.dart` ve `stroke_model.dart` dosyalarına dokunma.
  ```
- **Doğrulama Maddesi:** Tablette "Sadece Kalem" butonu açıkken parmağınla ekrana çizmeye çalış; **hiçbir şey çizilmemeli**. Avucunu ekrana yaslayıp S Pen ile yaz; sadece S Pen yazmalı. Butonu kapattığında parmağınla da çizebilmelisin.
- **Git Commit Önerisi:**
  ```powershell
  git add .
  git commit -m "feat: step 6 - add palm rejection and stylus-only mode"
  ```

---

### Adım 7: Çizimi Dosyaya Kaydetme ve Geri Yükleme

- **Amaç:** Ekrandaki çizimleri JSON formatında cihaz hafızasına kaydetmek ve tek tuşla geri yükleyebilmek.
- **Dokunulacak dosyalar:**
  - `pubspec.yaml`
  - `lib/drawing/stroke_model.dart`
  - `lib/drawing/stroke_storage.dart` (yeni)
  - `lib/drawing/drawing_toolbar.dart`
  - `lib/drawing/drawing_page.dart`
- **Dokunulmayacak dosyalar:**
  - `lib/main.dart`
  - `lib/drawing/drawing_canvas.dart`
- **Ajana Verilecek Prompt:**
  ```text
  Önce AGENTS.md dosyasını oku. Sadece Adım 7'yi yap:

  1. `pubspec.yaml` dosyasına `path_provider: ^2.1.2` paketini ekle (onayım var).
  2. `lib/drawing/stroke_model.dart` içindeki `StrokePoint` ve `Stroke` sınıflarına `toJson()` ve `factory ...fromJson(Map<String, dynamic> json)` metotlarını ekle (`Color` değerini `color.value` integer olarak kaydet).
  3. `lib/drawing/stroke_storage.dart` dosyasını oluştur:
     - `saveStrokes(List<Stroke> strokes, {String fileName = 'drawing_test.json'})` metodu: `getApplicationDocumentsDirectory()` altına JSON olarak kaydetsin.
     - `loadStrokes({String fileName = 'drawing_test.json'})` metodu: Dosya varsa okuyup `List<Stroke>` döndürsün, yoksa boş liste döndürsün.
  4. `lib/drawing/drawing_toolbar.dart` içine "Kaydet" (Save) ve "Yükle" (Load) ile "Temizle" (Clear) butonları ekle.
  5. `lib/drawing/drawing_page.dart` içinde bu butonları `StrokeStorage` ile bağla. Kaydedildiğinde veya yüklendiğinde altta kısa bir `SnackBar` mesajı göster ("Çizim kaydedildi", "Çizim yüklendi").

  `main.dart` ve `drawing_canvas.dart` dosyalarına dokunma.
  ```
- **Doğrulama Maddesi:** Ekrana S Pen ile bir şeyler yazıp **Kaydet** butonuna bas ("Çizim kaydedildi" mesajını gör). Ardından **Temizle** butonuna basıp ekranı sıfırla (veya uygulamayı tamamen kapatıp yeniden aç). **Yükle** butonuna bastığında az önceki çizimin renkleri ve kalınlıklarıyla eksiksiz geri gelmeli.
- **Git Commit Önerisi:**
  ```powershell
  git add .
  git commit -m "feat: step 7 - save and load drawing as json file"
  ```

---

### Adım 8: Skynotes'a Entegre Edilebilecek Şekilde Tek Bir Widget Olarak Paketlenmesi

- **Amaç:** `DrawingPage` widget'ını Skynotes içinden çağrıldığında belirli bir notun dosya adıyla açılacak ve çıkarken kaydedilmiş veriyi verebilecek şekilde temiz bir API'ye kavuşturmak.
- **Dokunulacak dosyalar:**
  - `lib/drawing/drawing_page.dart`
  - `lib/main.dart`
- **Dokunulmayacak dosyalar:**
  - `lib/drawing/drawing_canvas.dart`
  - `lib/drawing/drawing_toolbar.dart`
  - `lib/drawing/stroke_model.dart`
  - `lib/drawing/stroke_storage.dart`
- **Ajana Verilecek Prompt:**
  ```text
  Önce AGENTS.md dosyasını oku. Sadece Adım 8'i yap:

  1. `lib/drawing/drawing_page.dart` dosyasındaki `DrawingPage` widget'ına şu opsiyonel parametreleri ekle:
     - `final String fileName;` (varsayılan: `'default_note.json'`) — Hangi dosya adıyla kaydedip yükleneceğini belirler.
     - `final List<Stroke>? initialStrokes;` — Dışarıdan hazır çizgi listesi verilirse onunla başlar, verilmezse `initState` içinde `fileName` dosyasını otomatik yükler.
     - `final ValueChanged<List<Stroke>>? onSaved;` — Kaydet butonuna basıldığında dış dünyaya (Skynotes'a) güncel çizgi listesini haber verir.
  2. `lib/main.dart` içinde `DrawingPage(fileName: 'test_note_1.json')` şeklinde örnek kullanımı göster.

  Diğer dosyalara dokunma.
  ```
- **Doğrulama Maddesi:** Uygulamayı çalıştır, bir çizim yapıp **Kaydet**'e bas. Uygulamayı kapatıp tekrar açtığında (`initState` otomatik yükleme yaptığı için) hiçbir tuşa basmadan son çizimin doğrudan ekranda açılmalı. Artık `lib/drawing/` klasörünü olduğu gibi kopyalayıp Skynotes projesinin `lib/` klasörüne yapıştırabilirsin!
- **Git Commit Önerisi:**
  ```powershell
  git add .
  git commit -m "feat: step 8 - make DrawingPage self-contained for Skynotes integration"
  ```

---

## 4. B Planı: Çizim Gecikmesi (Latency) Yüksek Çıkarsa Ne Yapılacak?

Galaxy Tab S10 FE (90Hz ekran + S Pen) üzerinde yukarıdaki Flutter yapısı çoğu senaryoda gayet akıcı çalışır. Ancak çok hızlı el yazısında kalem ucuyla çizgi arasında gözle görülür bir boşluk (gecikme) hissedersen **ana mimariyi hiç bozmadan** şu iki aşamalı B planını uygulayabilirsin:

### Aşama B1 (En Kolay - Saf Flutter Optimizasyonu)
Çizilen eski yüzlerce çizgiyi her milisaniyede tekrar tekrar boyamak gecikme yaratır.
- **Çözüm:** `drawing_canvas.dart` içinde **Aktif Çizgi** ile **Bitmiş Çizgileri** iki ayrı `CustomPaint` katmanına ayırmak ve bitmiş çizgilerin olduğu alt katmanı `RepaintBoundary` içine almak. Böylece S Pen hareket ederken Flutter geçmişteki 500 çizgiyi değil, **sadece o an çizilen tek çizgiyi** boyar. Gecikmeyi %70 oranında düşürür.

### Aşama B2 (İleri Seviye - Sadece Tuvali Native Android'e Almak)
Eğer Samsung Notes seviyesinde sıfır gecikme (donanım hızlandırmalı ön-tahmin / front-buffered rendering) istersen:
- **Çözüm:** `stroke_model.dart`, `drawing_toolbar.dart`, `stroke_storage.dart` ve `drawing_page.dart` **olduğu gibi Flutter'da kalır**. Sadece `drawing_canvas.dart` içindeki `CustomPaint` yerine Android tarafında `androidx.ink` (Google'ın yeni resmi düşük gecikmeli Stylus kütüphanesi) veya `MotionEvent` yakalayan küçük bir Kotlin `PlatformView` (`AndroidView`) bağlanır.
- Windows (Skynotes masaüstü) tarafında ise mevcut `CustomPainter` çalışmaya devam eder (`Platform.isAndroid` kontrolü ile).

