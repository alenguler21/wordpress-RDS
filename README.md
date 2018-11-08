# wordpress-RDS

Bir Wordpress sayfasını RDS ile entegre bir şekilde ayağa kaldırma amaçlı bir proje.

Kullanılan Teknolojiler:

1. İki adet AWS EC2
2. Bir adet AWS RDS
3. Wordpress (Docker olarak ayağa kaldırıldı. Script kullanılarak run edildi, script dosyası da dosyalar arasında paylaşılacaktır. Docker, normal Wordpress kullanımına göre daha lightweight ve daha kolay manage edilebilir bir seçenek olduğu için seçildi. Ayrıca kullanılan docker imajı Wordpress'in yanında Apache WebServer ve PHP de barındırıyor. Bu sebepten WebServer olarak apache kullanıldı)
4. AWS ELB
5. CloudWatch (LoadBalancer'da bulunan instanceların unhealthy durumunu gözlemleyebilmek adına kullanıldı)




1. AWS üzerinden bir RDS oluşturma:

* Servisler arasından RDS seçilir ve "create database" butonuna tıklanır. Açılan sayfada "engine options" kısmından engine seçilir. 
Not:Ben MariaDB kullandım, kullanımı daha kolay ve daha performanslı bir DB seçeneği olduğunu düşünüyorum.

* Free-tier kullanım için Dev/Test - MariaDB seçilir. 

* "Only enable options eligible for RDS Free Usage Tier" tiklenir ve sadece settings bölümü istenildiği şekilde ayarlanır.
Bu sayfa da geçilince, diğer sayfada public access kapatılabilir (güvenlik sebebi ile kapatılmasını öneririm) database ismi de girilir ve database oluşturulur.



2. EC2 instance oluşturma:

* Servisler arasından EC2 seçilir ve "launch instance" butonuna tıklanır. AMI olarak Ubuntu "Server 16.04 LTS" seçilir (Ubuntu 16.04 sunulan tercihler arasında olduğu ve ubuntu kullanımına aşina olduğum için bu AMI kullanıldı). t2.micro seçilir ve next'e basılır. Step 3'te herhangi bir değişikliğe gerek yoktur (En azından bu proje için). Step 4 de geçilebilir. Step 5'te Key olarak Name ve Monitor parametreleri verilebilir. Security group'ta 22, 80 ve 8080 portlarına izin verilmelidir.

* Son aşama da tamamlanıp launch edildikten sonra Key pair oluşturmamız gerekiyor. Oluşturulan key pair'i bilgisayarımıza indirmeli ve kaybetmemeliyiz, çünkü bu key pair'e bir daha ulaşma imkanımız olmuyor ve bu key pair'e ulaşamazsak oluşturduğumuz instance'a ulaşamıyoruz.

Not: ben iki adet instance oluşturdum. Bunun sebebi; ilerde oluşturacağımız load balancer'a bu iki makineyi ekleyince yük dağılımı yapabilecek olmamız ve bu sayede instance'a fazla yük bindirmeyecek olmamızdır.


3. Docker ile Wordpress oluşturma (localiimde ubuntu kıullandığım için anlatım ona göre yapılmıştır):

* Öncelikle, oluşturduğumuz EC2 instanceına erişebilmek için indirdiğimiz key pair'ın permissionunu "chmod 400" komutu ile değiştirmeliyiz. Sonra "ssh -i "xxx.pem" ubuntu@"Public-DNS-of-instance"" şeklinde bir komut ile makineye bağlanırız.

* Makinede aşağıda bulunan komutlar ile docker-ce kurarız.

"""""""""""""""""""
sudo apt-get update

sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
    
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
  
sudo apt-get update

sudo apt-get install docker-ce

"""""""""""""""""""


* Bu komutlar uygulandıktan sonra docker kurulmuş olacaktır. Bunun kontrolü için "sudo docker run hello-world" komutu koşulabilir.

* Docker kurulduktan sonra, gitHub içerisinde paylaşılan run.sh dosyası, instance içinde çalıştırılarak wordpress ayağa kaldırılır.

Not: run.sh'ın içerisinde bulunan " WORDPRESS_DB_HOST, WORDPRESS_DB_USER, WORDPRESS_DB_PASSWORD"  bilgilerini doldurmamız gerekmektedir. password ve username bilgilerini RDS'i oluştururken girdiğimiz bilgiler ile aynı şekilde doldurmalı, host bilgisini de konsoldan oluşturduğumuz RDS'e girip, endpoint bilgisi ile aynı şekilde doldurmalıyız.

"Makinenin public ipsi:8080" bilgilerini, local makinenizde bulunan browsera yazınca wordpress'in görülmesi ve bu sayede wordpressin sağlıklı bir şekilde kurulduğunu anlayabiliriz.



4. Load Balancer ayarlamaları:

* AWS'de EC2 servisine girilir ve target group sekmesi açılır. "create target group" butonuna basılır. target group name ve port bilgisi (run.sh'ın içinde belirtilen port ile aynı olmalıdır.) girilmelidir. diğer bilgiler ihtiyaca göre değiştirilebilir ama default kullanılması şu aşamada bir sıkıntı çıkartmayacaktır.

* Target group'ta "Targets" sekmesine tıklanır. "Edit" butonuna basıp oluşturduğumuz instanceları seçip "Add to registered" butonu ile target group'a eklenir ve save butonuna basılır. Bir süre geçtikten sonra makinelerin healthy olarak gözüktüğünü gözlemlemiş olacağız.

* Target group oluşturulduktan sonra load balancer sekmesine girilir. "create load balancer" butonuna basılır. application load balancer seçilir. Step 1'de load balancer ismi ve ad bilgileri seçilir (daha verimli bir load balancer deneyimi için bütün azler seçilebilir). Step 3'te security group bilgisi ayarlanır. Step 4'te, önceden oluşturduğumuz target group seçilir ve devam edilir son olarak ilerleyip load balancer oluşturulmuş olur.


5. CloudWatch ile alarm oluşturulması:

* Herhangi bir unhealthy durumunda alarm gelmesi için şu işlemler yapılabilir.

* Oluşturduğumuz target group açılr. Monitoring seçeneğinde create alarm butonuna basılır. "Average of Unhealthy Hosts" şeklinde ayarlandıktan sonra istenilen şekilde ayarlamalar yapılıp alarm üretilir.
