# ProFFessorTest

*Türk akademisinde gerçek ölçüt arayan bir platform.*
Akademisyeni yalnızca yayın/proje kriterine göre değil, daha kapsamlı değerlendiren gerçekci bir platform !

---

## Türkçe

Türkiye'de akademik yükselme sistemi uzun süredir aynı soruyu doğuruyordu: yayın sayısı mı, yoksa gerçek etki mi? ProFFessorTest bu soruyu ciddiye alarak başladı.

Platform, bir akademisyeni değerlendirmek için hocadan tek satır bilgi almıyor. Bunun yerine OpenAlex akademik veritabanından H-indeksi, atıf sayısı, uluslararası işbirliği ve son yayın aktivitesini otomatik çekiyor. ORCID'den etkinlik, proje, ödül ve hakemlik kayıtlarını alıyor. Öğrenci ve mezun değerlendirmeleri ağırlıklı bir puanlama sistemiyle işleniyor ve her yorum admin onayından geçiyor.

Sonuçta ortaya çıkan şey tek bir sayı değil: mevcut unvana yeterlilik, bir üst kademeye uzaklık, eksik kriterler ve tahmini süre. Yüksek puan alan hoca övgü almıyor, düşük puan alan ceza almıyor. Sistem sadece olduğu hali gösteriyor.

Şu an beta aşamasında. Kurumsal kullanım ve gerçek veri entegrasyonu için yol haritası devam ediyor.

**Teknik yapı:** Tek HTML dosyası, sıfır framework. Veri katmanı için Supabase (isteğe bağlı), akademik veri için OpenAlex ve ORCID API (ücretsiz, anahtarsız). Puan, açık ve sabit bir formülle tarayıcıda hesaplanır; ücretli bir AI servisi kullanılmaz.

---

## English

The Turkish academic promotion system has long produced the same question: does publication count actually mean anything? ProFFessorTest started by taking that question seriously.

The platform never asks the academic to input anything. Instead, it pulls H-index, citation count, international collaboration rate, and recent publication activity directly from the OpenAlex database. It pulls activities, projects, awards and peer-review records from ORCID. Student and alumni reviews go through a weighted scoring system, with every submission requiring admin approval before it affects the score.

What comes out isn't a single verdict. The platform shows how well a person fits their current title, how far they are from the next level, what's missing, and roughly how long it might take to close the gap. High scores don't earn praise. Low scores don't trigger punishment. The system just shows what's there.

Currently in beta. Roadmap includes institutional deployment and direct integration with formal academic registries.

**Stack:** Single HTML file, no framework. Optional Supabase for persistent storage, OpenAlex and ORCID APIs (free, no key) for academic data. Scores come from a fixed, transparent formula computed in the browser; no paid AI service.

---

*ProFFessorTest — because a title should mean something.*
