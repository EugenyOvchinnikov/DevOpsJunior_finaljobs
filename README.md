Финальная работа по курсу Системное администрирование для начинающих

Вся необходимая инфраструктура создаётся в Yandex Cloud с помощью скриптов и deb-пакетов:
#
Поднятие инстансов:
#
[Скрипт создания ВМ ca-server](https://github.com/EugenyOvchinnikov/DevOpsJunior_finaljobs/blob/main/ca_server_create.sh)\
[Скрипт создания ВМ vpn-server](https://github.com/EugenyOvchinnikov/DevOpsJunior_finaljobs/blob/main/vpn_server_create.sh)\
[Скрипт создания ВМ prometheus-server](https://github.com/EugenyOvchinnikov/DevOpsJunior_finaljobs/blob/main/prometheus_server_create.sh)
###
Копирование скриптов и deb-пакетов:
#
[Скрипт копирования файлов на ВМ ca-server](https://github.com/EugenyOvchinnikov/DevOpsJunior_finaljobs/blob/main/ca_server_copy_deb.sh)\
[deb-пакет easy-rsa](https://github.com/EugenyOvchinnikov/DevOpsJunior_finaljobs/blob/main/easy-rsa_0.1-1_all.deb)\
[deb-пакет easy-rsa-vars](https://github.com/EugenyOvchinnikov/DevOpsJunior_finaljobs/blob/main/easy-rsa-vars_0.1-1_all.deb)\
[Скрипт копирования файлов на ВМ vpn-server](https://github.com/EugenyOvchinnikov/DevOpsJunior_finaljobs/blob/main/vpn_server_copy_deb.sh)\
[Скрипт копирования файлов на ВМ prometheus-server](https://github.com/EugenyOvchinnikov/DevOpsJunior_finaljobs/blob/main/prometheus_server_copy_deb.sh)
#
Установка и настройка пакетов:
#
[Скрипт установки easy-rsa](https://github.com/EugenyOvchinnikov/DevOpsJunior_finaljobs/blob/main/easy_rsa_install.sh)\
[Скрипт установки openvpn](https://github.com/EugenyOvchinnikov/DevOpsJunior_finaljobs/blob/main/openvpn_install.sh)\
[Скрипт генерации ключей и файла настройки клиента](https://github.com/EugenyOvchinnikov/DevOpsJunior_finaljobs/blob/main/make_client_keys.sh)\
[Скрипт получения файла настройки клиента](https://github.com/EugenyOvchinnikov/DevOpsJunior_finaljobs/blob/main/vpn_server_get_files.sh)\
[Скрипт установки prometheus](https://github.com/EugenyOvchinnikov/DevOpsJunior_finaljobs/blob/main/prometheus_install.sh)\
[Скрипт установки openvpn exporter](https://github.com/EugenyOvchinnikov/DevOpsJunior_finaljobs/blob/main/openvpn_exporter_install.sh)
#
Отчеты:
#
[Скрин vpn-server](<https://github.com/EugenyOvchinnikov/DevOpsJunior_finaljobs/blob/main/Screenshot vpn-server.png>)\
[Скрин vpn client connections](<https://github.com/EugenyOvchinnikov/DevOpsJunior_finaljobs/blob/main/Screenshot connections.png>)\
[Скрин мониторинга](https://github.com/EugenyOvchinnikov/DevOpsJunior_finaljobs/blob/main/monitoring.png)\
[Скрин grafana](https://github.com/EugenyOvchinnikov/DevOpsJunior_finaljobs/blob/main/grafana.png)
#
Документация:
#
[Проектирование мониторинга](https://docs.google.com/document/d/1jHEk8t-O3ZF9vD5kUsSxjNUz1Dszor3eZijkLTRT5YQ/edit?usp=drive_link)\
[Описание процесса бэкапа](https://docs.google.com/document/d/18RFXr3zhLXGZ0urspIa9CuO0QNFs_LMU8aAwGtFHeok/edit?usp=drive_link)\
[Руководство пользоватя VPN](https://docs.google.com/document/d/1RV5g1p_XXhTb0QPyZk_APcpgHcxSG04NO0CAycdix9U/edit?usp=drive_link)\
[Схема инфраструктуры](https://drive.google.com/file/d/1z7vOaWu_cPa4dP8ewzRjW_NA3pfkfH4T/view?usp=drive_link)\
[Схема потоков данных](https://docs.google.com/document/d/1AouvUztkxfAIaj5EpImorZs8qNTeh-lbNX3m8bXjaEI/edit?usp=drive_link)\
[Руководство системного администратора](https://docs.google.com/document/d/1TFv9O4SEeBTnqVplQjDGRAKb5jxrFexMgDtqs_nifOM/edit?usp=drive_link)\
[Доработка инфраструктуры](https://docs.google.com/document/d/12VapLd_2KCRm4p7yqOJuZKg0x5vopB-ux6bbExakvvM/edit?usp=drive_link)
