# SpendWise — Step 2.2 son kontrol ve teslim

22 Kasım 2026. Ekip kodu `git pull --ff-only` ile `7c57f07895b9c5f8df3bce71aef74cea45cb7785` commit'ine getirildi. Son çalışma branch'i: `feat/step22-dashboard-integration`.

**Teknik durum:** Uygulama ve entegrasyon tamamlandı; kod `fca6342`, bütünleşme testleri `1dd535a` commit'inde. Bu belge teknik kontrol raporu ve teslim prosedürüdür. Yayımlanan son sürüm GitHub main üzerinden, SUCourse teslimi ise platformdaki teslim durumu üzerinden doğrulanır. Step 2.1 yeniden teslim edilmeyecek.

## Ekip işlerinin kontrolü

| Kişi | Gelen çalışma | Git kanıtı | Son bağlantı / düzeltme |
| --- | --- | --- | --- |
| Khalil Khalilli | Login, Sign-up, inline doğrulama, parola görünürlüğü, MainShell geçişi | `49c749c`, `df43bb7`, `3549118` | Auth testindeki yüklenmemiş Provider düzeltildi; ortak tema ve wireframe logosu bağlandı. |
| Akif Şentürk | Add/Edit doğrulama, başarı diyaloğu, tek kayıt koruması, responsive form | `59d53e8`, `b5d9c15`, `1ab241d` | Para birimi bağlandı; form aralıkları iyileştirildi; iki Cancel düğmesini karıştıran test seçicileri düzeltildi. |
| Atilla Mammadzada | Ay/kategori hesapları ve Summary grafiği | `fcb78bf` | Hesaplama Dashboard ile paylaşıldı; sıralama/insight eklendi; toplam, ay kontrolü ve para metni ortak widget oldu. |
| Harun Can Yurdagül | Settings, para tercihi, tema, font, yerel/network görsel | `6b5a82a`, `422beeb`, `6a308e2` | Başlangıç tercihi ve tema uygulama köküne bağlandı; tüm tutarlar ortak tercihi izliyor. |
| Berat Can Satır | Dashboard, Card listesi, silme, son entegrasyon | `fca6342`, `1dd535a` | Ay/toplam/insight, sıralama, menü ve swipe ile edit/delete, silme onayı, entegrasyon testleri, README ve teslim hazırlığı. |

Arkadaşların mevcut commit'leri ve yazarları korundu. Atilla'nın Summary işi tek anlamlı geliştirme commit'inde; resmi şart belirli bir commit sayısı değil, düzenli ve somut kişisel katkı. Geçmişi yeniden yazmak veya sırf sayı için boş commit eklemek gerekmiyor.

## Gereklilik durumu

Kaynak: `CS310_Project_Step2_Final.pdf`, Step 2.2 UI Implementation ve Evaluation. Ekran kapsamı: teslim edildiği bildirilen `CS310_Group2_Step2.1.pdf`, sayfa 6–9. Ayrı TA geri bildirimi doğrulanamadı.

| Gereklilik | Durum | Kanıt |
| --- | --- | --- |
| Login / Sign-up ve çalışan navigasyon | DONE | `lib/screens/auth/`, `lib/screens/main_shell.dart`, auth ve signup akış testleri |
| Dashboard: ay, toplam, güncel kartlar, insight | DONE | `lib/widgets/expenses.dart`, `lib/utils/monthly_summary.dart` |
| Model listesi, Card ve çalışan remove | DONE | `lib/models/expense.dart`, `lib/widgets/expenses_list/`; menü ve swipe onay/iptal testleri |
| En az iki alanlı form, inline hatalar, başarı diyaloğu | DONE | `lib/widgets/new_expense.dart`; Add/Edit ve geçersiz tutar testleri |
| Ay ve kategori özeti / grafik | DONE | `lib/screens/summary_screen.dart`; aynı ay/yıl filtresi ve ortak hesaplama |
| Settings / para tercihi | DONE | `lib/screens/setting_screen.dart`, `lib/settings/currency_preferences.dart`; tercih ve kilit testleri |
| Yerel görsel, network görsel, özel font | DONE | `assets/`, `pubspec.yaml`; Settings'te iki görsel gerçek tarayıcıda görüldü; RobotoMono başlıklarda |
| Ortak renk, stil, spacing ve tekrar kullanılabilir widget | DONE | `lib/theme/app_theme.dart`, `lib/widgets/shared/`, ortak parola alanı ve Add/Edit formu |
| Küçük/büyük portre, klavye, taşma | DONE | 320×568 / 430×932 widget testleri ve tarayıcı kontrolü; ana ekranlarda %130 yazı testi |
| README ve kullanılan Flutter sürümü | DONE | `README.md`: Flutter 3.47.6 / Dart 3.13.5, kurulum ve çalıştırma |
| Android emulator / iOS simulator ile flutter run | DONE | Android API 37.0 arm64 üzerinde debug APK kuruldu ve Dart VM hizmetiyle açıldı; iOS denenmedi |
| Aynı public GitHub deposu | DONE | GitHub metadata: `cansatir/cs310-project`, public |
| Son kodun GitHub'a push edilmesi | Yayın adımı | Bu raporla aynı değişiklik grubunun PR/main geçmişinden doğrulanır |
| Etiketli ekranlar, repo linki, Member Contributions içeren PDF | Teslim adımı | Yayınlanan son SHA ile aşağıdaki üretim komutu çalıştırılır |
| Son PDF'nin SUCourse'a yüklenmesi | MISSING | Bu oturumda yükleme yapılmadı |
| TA geri bildirimi ve bireysel TA toplantısı | NOT VERIFIED | Katılım veya geri bildirim belgesi mevcut değil |

Wireframe'deki tek-seçimli para menüsü aynı davranışı sunan ChoiceChip'lerle uygulanıyor. Summary'de kategori tutarları ayrı tekrar liste yerine doğrudan barların yanında. Bu yerleşim farkları işlevi koruyor; TA'nın ayrıca istediği bir değişiklik varsa son kontrol gerekir. Step 1'de önerilen SQLite/Hive yerine mevcut SharedPreferences korundu; Step 2.1 de bu mevcut depolamayı açıkça belgeliyor. Firebase, bütçe, OCR, dışa aktarım veya yeni veri tabanı bu aşamaya eklenmedi.

## Gerçekte çalıştırılan kontroller

- `flutter --version`: Flutter 3.47.6 stable, Dart 3.13.5.
- `flutter analyze`: **No issues found**.
- `dart format --output=none --set-exit-if-changed lib test` ve `git diff --check`: başarılı.
- `flutter test`: **46 test geçti**. İlk çekilen ekip kodunda 3 test başarısızdı; test kurulumları/seçiciler düzeltildi, testler kaldırılmadı.
- `flutter run -d emulator-5554 --no-pub`: Android debug derlemesi, APK kurulumu ve uygulama başlangıcı başarılı. Son değişiklikler hot restart ile yüklendi.
- `flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8765 --no-pub`: görsel inceleme ve gerçek ekran görüntüleri.
- Tarayıcıda 430×932 ve 320×568: Login/Sign-up, Add/Edit, inline hatalar, başarı diyaloğu, Dashboard, Summary, Settings, kaydırma ve silmeden vazgeçme kontrol edildi. Yerel logo ve network grafik görseli yüklendi.
- Tam silme ve ardından Settings kilidinin açılması; para tercihinin tüm ekranlara yansıması; geçerli Sign-up ve geri dönüş davranışı otomatik widget akış testlerinde doğrulandı.

**Sınırlar:** Android için build/launch doğrulaması yapıldı; ekran görüntüleri Android'den değil, Flutter web telefon görünümünden alındı. iOS, fiziksel cihaz ve release mağaza dağıtımı test edilmedi. Tarayıcı erişilebilirliği açıkken Flutter'ın macOS bottom-sheet route etiketi için uyarı görüldü; SDK `bottom_sheet.dart` macOS/iOS için boş route label döndürüyor. Bu uyarı testlerde veya Android başlangıcında çalışma hatası üretmedi. Mevcut SharedPreferences yazmaları kullanıcıya yazma hatası bildirmiyor; gelecekteki persistence çalışmasına bırakıldı.

## Can için yayın ve teslim prosedürü

1. Değişiklikleri incele. Kullanıcı 22 Kasım 2026 tarihinde commit, push ve main'e birleştirmeyi onayladı.
2. Can'ın kendi Git kimliğiyle 2–3 anlamlı commit oluştur: Dashboard/list/remove; tema/para entegrasyonu ve test düzeltmeleri; dokümantasyon/teslim görüntüleri. Birbirine bağlı dosyaları eksik bırakma; her ara commit derlenebilsin. Bölünemeyen bağlantıları aynı commit'te tut.
3. `feat/step22-dashboard-integration` branch'ini push et, PR'ı kontrol et, onayla main'e birleştir. Arkadaşların geçmişini squash/rebase ile yeniden yazma. Son durumu PR ve main commit geçmişinden doğrula.
4. Son main üzerinde `flutter analyze`, `flutter test` ve emulator açılışını doğrula. `git rev-parse HEAD` ile **GitHub'da bulunan** teslim SHA'sını al.
5. PDF taslağındaki bekleyen commit alanını bu SHA ile doldur ve dosyayı **CS310_Group2_Step2.2.pdf** adıyla üret. Görsellerin aynı uygulama sürümünü gösterdiğini kontrol et. PDF'yi commit'lemek zorunlu değil; kod SHA'sı alındıktan sonra PDF'yi ayrı teslim etmek SHA döngüsünü önler.
6. PDF'de repo linki, son commit, etiketli çekimler ve beş kişilik Member Contributions bulunduğunu kontrol et. Taslak ibaresi kalmamalı.
7. Grubu temsilen bir kişi SUCourse'a son PDF'yi yüklesin; teslim alındısı/durumu görülsün. Step 2.1'i yeniden yüklemeyin.
8. Her kişi TA toplantısında kendi kodunu anlatabilsin; toplantı ve varsa geri bildirim durumunu ekip olarak teyit edin.

### Teslim edenin son kontrol listesi

- [x] Ekip branch'leri çekildi ve gerçek kod incelendi.
- [x] Can'ın Dashboard/silme/entegrasyon işi tamamlandı.
- [x] Ortak para birimi, tema, font ve görseller bağlandı.
- [x] README gerçek sürüm ve run komutlarını içeriyor.
- [x] 46 test ve analiz başarılı; Android uygulaması açıldı.
- [x] Çekimler gerçek uygulamadan alındı; boyut/kaynak bilgileri açık.
- [ ] GitHub main'de Can'ın üç commit'i ve son PR birleşimi görülüyor.
- [ ] PDF'de final main SHA ve doğru dosya adı var.
- [ ] PDF son kez gözden geçirildi ve SUCourse teslimi doğrulandı.
- [ ] TA geri bildirimi/toplantı durumu teyit edildi.

## PDF'yi yeniden üretmek

`tools/build_step22_pdf.py`, `docs/screenshots/` altındaki gerçek çekimleri kullanır. Python ve `reportlab` gerektirir; uygulamanın Flutter bağımlılıklarını değiştirmez. Arial (macOS) veya DejaVu Sans (Linux) ile Türkçe kişi adlarını doğru basar.

```bash
# İnceleme taslağı; final commit alanı beklemede kalır.
python3 tools/build_step22_pdf.py

# Yalnızca son kod commit edilip GitHub'da doğrulandıktan sonra:
python3 tools/build_step22_pdf.py --commit <full-published-commit-sha>
```

Çıktı `output/pdf/` içindedir (Git tarafından izlenmez). Son komut, verilen commit'in yerel HEAD olduğunu ve izlenen uygulama dosyalarında kaydedilmemiş değişiklik kalmadığını kontrol eder; GitHub'a yayımlanmış olmasını ayrıca doğrulamak gerekir. Taslak 7 sayfa olarak render edilip görsel kontrol edildi.
