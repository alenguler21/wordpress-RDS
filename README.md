# wordpress-RDS
Bir Wordpress sayfasını RDS database ile entegre bir şekilde ayağa kaldırma amaçlı bir proje.


1. AWS üzerinden bir RDS oluşturma.

Servisler arasından RDS seçilir ve "create database" butonuna tıklanır. Açılan sayfada "engine options" kısmından engine seçilir. 
Not:Ben MariaDB kullandım, kullanımı daha kolay ve daha performanslı bir DB seçeneği olduğunu düşünüyorum.

Free-tier kullanım için Dev/Test - MariaDB seçilir. 

"Only enable options eligible for RDS Free Usage Tier" tiklenir ve sadece Settings bölümü istenildiği şekilde ayarlanır.
Bu sayfa da geçilince, diğer sayfada public access kapatılabilir (güvenlik sebebi ile kapatılmasını öneririm) database ismi de girilir ve database oluşturulur.

