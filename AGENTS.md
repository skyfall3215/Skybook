# AGENTS.md — S Pen Çizim Modülü Kodlama Kuralları

> **ÖNEMLİ:** Bu dosyayı her adımdan önce baştan sona oku ve buradaki kuralların dışına **asla** çıkma.

## 1. Proje Tanımı ve Hedef Cihaz
Bu proje, **Samsung Galaxy Tab S10 FE (Android, S Pen destekli)** için geliştirilen, daha sonra **Skynotes** uygulamasına tek bir widget olarak entegre edilecek bağımsız bir Flutter el yazısı ve çizim modülüdür.

## 2. Klasör ve Dosya Yapısı
Tüm çizim modülü `lib/drawing/` klasörü altında yaşar. Kök `lib/main.dart` sadece bu modülü ekranda göstermek içindir.

```text
lib/
├── main.dart                     # Sadece uygulamayı başlatır ve DrawingPage'i açar (Skynotes'a geçerken atılacak).
└── drawing/                      # Bağımsız çizim modülü (Skynotes'a olduğu gibi kopyalanacak klasör).
    ├── drawing_page.dart         # Araç çubuğu ve tuvali birleştiren, dışarıdan çağrılan tek ana ekran widget'ı.
    ├── drawing_canvas.dart       # Kalem dokunuşlarını (Listener) yakalayan ve çizimi ekrana basan (CustomPainter) widget.
    ├── drawing_toolbar.dart      # Renk, kalınlık, silgi, undo/redo, kaydet/yükle butonlarını barındıran üst/alt bar.
    ├── stroke_model.dart         # Nokta (StrokePoint) ve çizgi (Stroke) veri sınıfları + JSON dönüşümleri (toJson/fromJson).
    └── stroke_storage.dart       # Çizgileri JSON olarak yerel dosyaya kaydeden ve geri okuyan yardımcı sınıf.
```

## 3. Kesin Çalışma Kuralları (Kırmızı Çizgiler)
1. **Aynı anda yalnızca istenen adımı yap:** Sana hangi adım söylendiyse sadece onu tamamla. Sonraki adımların kodunu "şimdiden hazırlayayım" diyerek yazma.
2. **İstenmeyen özellik ekleme:** Görevde yazmayan menü, animasyon, ekstra buton, yakınlaştırma (zoom) veya arka plan deseni ekleme.
3. **İstenmeyen dosyaya dokunma:** Prompt içinde "Dokunulmayacak dosyalar" listesinde yer alan hiçbir dosyayı değiştirme.
4. **Her şeyi `main.dart` içine doldurma:** `main.dart` sadece `MaterialApp` ve `DrawingPage()` çağrısı içermelidir. Çizim mantığı `lib/drawing/` altındaki ilgili dosyalarda durmalıdır.
5. **State management paketi ekleme:** `provider`, `riverpod`, `bloc`, `getx` gibi paketler **kesinlikle yasaktır**. Sadece Flutter'ın kendi `StatefulWidget` ve `setState` yapısını kullan.
6. **Mevcut çalışan kodu gereksiz yere yeniden yazma:** Bir önceki adımda çalışan fonksiyonları veya sınıfları baştan aşağı değiştirme; sadece o adımın gerektirdiği eklemeyi yap.
7. **Yeni paket eklemeden önce sor:** `pubspec.yaml` dosyasına benden habersiz paket ekleme. Paket gerekiyorsa önce bana sor ve onayımı bekle.
8. **Tahmin etme, soru sor:** Emin olmadığın, belirsiz kalan bir detay varsa kafana göre varsayım yapıp kod yazma; dur ve bana sor.

## 4. Kodlama Stili
- **Dil:** Dart (Flutter).
- **Fonksiyonlar:** Kısa, tek bir iş yapan fonksiyonlar yaz.
- **İsimlendirme:** Dosya, sınıf ve değişken adları **İngilizce** ve anlaşılır olsun (`StrokePoint`, `isStylusOnly`, `undoLastStroke` gibi).
- **Yorum Satırları:** Kritik hesaplamaların (örneğin S Pen algılama, basınç hesabı, pürüzsüzleştirme, JSON kayıt) hemen üstüne **Türkçe kısa yorum** ekle.

## 5. Her Adımın Sonunda Raporlama Formatı
İstenen adımı bitirdiğinde cevabının sonunda mutlaka şu 3 maddeyi yaz:
1. **Ne değişti:** Hangi dosyaları oluşturduğunu veya güncellediğini 1-2 cümleyle özetle.
2. **Nasıl çalıştırılır:** Test etmem için çalıştırmam gereken tam komutu yaz (örn. `flutter run`).
3. **Durum / Hata:** Kodda bildiğin bir eksik, uyarı veya hata varsa gizlemeden dürüstçe belirt.

# Karpathy rules

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

Bu projede test dosyası yazma. Doğrulamayı PLAN.md'deki doğrulama maddesine göre ben elle yapacağım.