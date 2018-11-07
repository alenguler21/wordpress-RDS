# wordpress-RDS
Bir Wordpress sayfasını RDS database ile entegre bir şekilde ayağa kaldırma amaçlı bir proje.

Kullanılan teknolojiler:
1. İki adet AWS EC2
2. Bir adet AWS RDS
3. Wordpress (Docker olarak ayağa kaldırıldı. Script kullanılarak run edildi, script de dosyalar arasında paylaşılacaktır. Docker, normal wordpress kullanımına göre daha lightweight ve daha kolay manage edilebilir bir seçenek olduğu için seçildi. Ayrıca kullanılan docker imajı Wordpress'in yanında Apache WebServerve PHP de barındırıyor. Bu sebepten WebServer olarak apache kullanıldı. )
4. AWS ELB
5. CloudWatch (LoadBalancer'da bulunan instanceların unhealthy durumunu gözlemleyebilmek adına kullanıldı.)




1. AWS üzerinden bir RDS oluşturma:

* Servisler arasından RDS seçilir ve "create database" butonuna tıklanır. Açılan sayfada "engine options" kısmından engine seçilir. 
Not:Ben MariaDB kullandım, kullanımı daha kolay ve daha performanslı bir DB seçeneği olduğunu düşünüyorum.

* Free-tier kullanım için Dev/Test - MariaDB seçilir. 

* "Only enable options eligible for RDS Free Usage Tier" tiklenir ve sadece Settings bölümü istenildiği şekilde ayarlanır.
Bu sayfa da geçilince, diğer sayfada public access kapatılabilir (güvenlik sebebi ile kapatılmasını öneririm) database ismi de girilir ve database oluşturulur.

2. EC2 oluşturma:

* Servisler arasından EC2 seçilir ve "launch instance" butonuna tıklanır. AMI olarak Ubuntu "Server 16.04 LTS" seçilir (Ubuntu 16.04 sunulan tercihler arasında olduğu ve ubuntu kullanımın aşina olduğum için bu AMI kullanıldı). t2.micro seçilir ve next'e basılır. Step 3'te herhangi bir değişikliğe gerek yoktur (En azından bu proje için). Step 4 de geçilebilir. Step 5'de Key olarak Name ve Monitor parametreleri verilebilir. Security group'ta 22, 80 ve 8080 portlarına izin verilmelidir.

* Son aşama da tamamlanıp launch edildikten sonra Key pair oluşturmamız gerekiyor. Oluşturulan key pair'i bilgisayarımıza indirmeli ve kaybetmemeliyiz, çünkü bu key pair'e bir daha ulaşma imkanımız olmuyor.
