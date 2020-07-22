# Otomatik Komutçu 
Sözde yapay zekâ [b]Oto Komut[/b], oyun esnasında komutçunun olmadığı durumda komutçu gelene dek otomatik aktifleşerek mahkûmlara çeşitli oyunlar oynatır. Eklentiyi ayrıcalıklı kılan en önemli özellikleri özgün oyunlar sunması ve oto komut esnasında mahkûmlar için oyunun bir amacı olmasıdır. Oyunun amacından kastım bir mahkûm neden sona kalmak istesin?  Klasik jailbreak modunda amaç olarak 2 seçenek verilmektedir. Komutları dinleyip sona kal düello at veya isyan yap. Bizim geliştirdiğimiz eklentide ise amaç olarak sona kalan oyuncuya düello atma hakkı verilmiştir. Peki, olmayan gardiyanlarla mı atacak? – Hayır, sona kalan mahkûm seçtiği bir başka mahkûmla düello atabilecek.
Mahkumla duello atılabilmesi için [b]oto komut eklentisiyle birlikte aşağıda paylaşılan düello (lr) eklentisinin kullanılması gerekmektedir. [/b]

## Oyunlar

### Deve Cüce Tavşan
Jailbreak modunda alışılagelmiş bir oyundur. Tek fark komutların sistem tarafından verilmesidir. Oyuncuların; cüce komutunda eğilmesi, tavşan komutunda zıplaması, deve komutunda ve şaşırtmaca komutlarda ise hiçbir şey yapmaması gerekir. Sahte komutlardan kasıt “Cüce” yerine “Cüc” veya “Cüre” gibi örneklendirilebilir. Tüm bu komutların sadece bir defa yapılması yeterlidir. Oyun gittikçe hızlanmaktadır ve yanlış bir hareket yapan oyuncu otomatik öldürülür ve sona kalan oyuncu oyunu kazanır.

### Hunger Games
Sadece dark haritasında tanımlanan yerlerde rastgele kutular oluşturulur. Oyuncular oyun başladığında silahsız bir şekilde belirli süre havada kalırlar. Sürenin bitiminin ardından yere inip kutu arayıp silah bulmaya çalışırlar. Buldukları silahlarla çatışırlar ve sona kalan kazanır. Oyun süresi uzadıkça oyuncuların meydana yaklaşması gerekir aksi taktirde zehirli gaz sayesinde canları azalır.

### T-Sustum Deagle
Sistem tarafından belirlenen kelime gruplarını yazan ilk oyuncunun önüne yaşayan mahkûmların listesi gelir. 15 saniye içerisinde birini seçmelidir aksi taktirde kendisi ölür. Eğer birini seçerse seçtiği kişiyi deagle silahıyla vurup öldürmüş gibi görünür ve bu son mahkum kalana kadar devam eder.   
Eklenti ile birlikte 33 farklı kelime gelmektedir.  Sistem bu 33 kelime arasından rastgele 3 kelime seçerek kelime grupları oluşturur. 33 kelimeden de toplam 5,456 farklı kelime oluşturulabilir. Bu da yazılan kelime gruplarının her seferinde farklı olma olasılığının yüzdesini çok yüksek tutmaktadır.

### Tavuğu Bul
Sadece dark haritasında tanımlanan yerlerin rastgele birinde bir tavuk oluşturulur. Tavuğu bulup dokunan ilk kişi oyunu kazanır. Oyunu kolaylaştırmak amacıyla tavuğa yaklaşan oyuncunun ekranı gittikçe kırmızılaşır.

### Gömülen Ölür
Belirli bir saniyede bir oyuncular gömülür. Oyunun zorlanması açısından süre gittikçe azalmaktadır. Oyunun adından da anlaşılacağı üzere gömülen oyuncular otomatik olarak öldürülür ve bu ölümlerin ardından sonra kalan oyuncu oyunu kazanır.

### Sarkaç https://forum.csduragi.com/eklentiler-pluginler/sarkac-oyunu-t32142.html

Eklentide ayrıca Aref, Freezelenen Ölür, FF Çeşitleri, Vatan Haini, Sayıyı Bilen Kazanır oyunları da bulunmaktadır.

## Komutlar
/oyun , !oyun, .oyun, oyunadi, simdikioyun : Aktif oyunun adını belirtir.

## Cvar Ayarları

amx_cvar otokomut_hud 1 ; Radar altında oto komut bilgileri paylaşılır. (Aktif oyun vs.)
amx_cvar otokomut_hostname 1 ; Oto Komut açıldığında host adına belirtilen ön etiketi ekler. (OTO KOMUT - KAOS GAMING)


[color=#FF0000][b]Sabitler - Düzenlenecek Yerler[/b][/color] :
[code]
#define semiclip_cvaraktif
//amx_cvar semiclip ayari olmayan semiclip eklentisi kullaniyorsaniz veya paneldeki semiclip eklentisini kullaniyorsaniz bu satiri silin. 
#define MAX_OYUN_SURESI 5.0 // 5 dk içerisinde kimse oyunu kazanamasa herkes olur. 
#define BEKLEME_SURESI 20.0 // 20 sn içinde CT Gelmezse Oto Komut başlar
new const HOSTTAG[] = "OTO KOMUT | ";
new const SERVERISMI[] = "KaoSCommunity.com";
new const KISATAG[] = "KaoS";
[/code]

## Geliştirciler için API

### Oto Komut açık/kapalı Kontrol

native otoKomutAktif(); // oto komut aktif mi?
otoKomutAKtif() -> return (true | false)

## Aktif Oyun Adı
new name[32];
getAktifOyun(name, charsmax(name));
client_print(0, print_chat," Aktif Oyun : %s", name);

## Oyuncu Revle

[code]
native otoKomutRevle(id); //oyuncu revle
otoKomutRevle(index);

