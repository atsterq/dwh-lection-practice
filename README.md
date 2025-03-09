# Лекция 1: Практическое задание 
## Задание первое
Подготовить сравнительную таблицу по архитектурным подходам к построению хранилищ данных.
Описать: плюсы подхода, минусы подхода, критерий для выбора.  

## Реализация
Cравнительня таблица по архитектурным подходам к построению хранилищ данных:

| подход         | плюсы                                                                                                                                                                         | минусы                                                                                                                                                                                 | критерий для выбора                                                                                                         |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| Data Warehouse | - транзакционность и консистентность;<br>- высокие аналитические возможности;<br>                                                                                             | - может хранить только структурированные данные;<br>- необходимы предварительные преобразования (ETL);<br>- требования должны быть известны заранее;<br>- дорогое масштабирование;<br> | - необходимы большие аналитические возможности;<br>- хорошо подходит для отчетности;                                        |
| Data Lake      | - масштабируемость;<br>- данные любых типов;<br>- преобразования по желанию, после появления в хранилище;<br>- требования могут прорабатываться по ходу реализации хранилища; | - нет транзакционности и консистентности;<br>- не получится выдать таблицы напрямую;<br>- есть вероятность получить болото данных;<br>- сложное управление;                            | - нужно быстро положить данные;<br>- данные разнообразны (структурированные / полуструктурированные / неструктурированные); |
| Lake House     | - масштабируемость;<br>- высокие аналитические возможности;<br>- транзакционность и консистентность;<br>- возможность логировать все изменения на физическом уровне;          | - высокие требования к расходуемым ресурсам;<br>- высокаясложность реализации;                                                                                                         | - необходима хорошая масштабируемость и большие аналитические возможности;                                                  |
| Data Mesh      | - домены имеют собственные выделенные модели данных;<br>- домены имеют собственные внешние интерфейсы;                                                                        | - очень высокая сложность реализации;                                                                                                                                                  | - необходима микросервисная архитектура;<br>                                                                                |
# Лекция 2: Практическое задание 
## Задание первое 
Осуществите подключение к кластеру ADB. Опишите системные таблицы и представления кластера в схемах arenadata_toolkit и gp_toolkit (только представления) по правилу: наименование – какую информацию содержит – для чего применяется. Используйте в ответах материалы из документации. Формат ответа: таблица с перечнем объектов, xls
## Реализация
1. Устанока и настройка openvpn на ubuntu 22.04: https://community.openvpn.net/openvpn/wiki/OpenVPN3Linux
2. Подключние к кластеру Arenadata и создание БД:  

![alt text](<attachments/Pasted image 20250222212408.png>)

3. Системные таблицы и представления кластера в схемах arenadata_toolkit и gp_toolkit
### arenadata_toolkit таблицы
При установке кластера ADB в базе данных автоматически создается [схема](https://docs.arenadata.io/ru/ADB/current/concept/data-model/db-schemas/schemas.html) `arenadata_toolkit`. Эта схема предназначена для сбора информации о работе кластера.

| наименование      | какую информацию содержит                                                                                                                                                                                                                                                                                                      | для чего применяется                                                     |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------ |
| daily_operation   | Содержит информацию об операциях `VACUUM` и `ANALYZE`, проводимых над таблицами базы данных автоматически по расписанию.                                                                                                                                                                                                       | Мониторинг автоопераций по обслуживанию                                  |
| db_files_current  | Содержит актуальную на момент последнего запуска скрипта [collect_table_stats](https://docs.arenadata.io/ru/ADB/current/how-to/manage-cluster/toolkit.html#script-purpose) информацию о файлах БД на всех сегментах кластера с привязкой к таблицам, индексам и другим объектам БД (при возможности определения таких связей). | Анализ текущего распределения данных, оптимизация дискового пространства |
| db_files_history  | Хранит историю изменений файлов БД на всех сегментах кластера с привязкой к таблицам, индексам и другим объектам БД (при возможности определения таких связей)                                                                                                                                                                 | Может быть полезна для отслеживания динамики изменения размера БД.       |
| operation_exclude | Содержит информацию о схемах БД, к которым не требуется применять операции `VACUUM` и `ANALYZE` при запуске соответствующих скриптов [vacuum и analyze](https://docs.arenadata.io/ru/ADB/current/how-to/manage-cluster/toolkit.html#script-purpose).                                                                           | Управление исключениями для автоматических операций                      |
### gp_toolkit представления

| наименование                           | какую информацию содержит                                                              | для чего применяется                                                          |
| -------------------------------------- | -------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| __gp_fullname                          | Полные имена объектов (схема + имя) в формате OID.                                     | Точная идентификация объектов БД через их OID.                                |
| __gp_is_append_only                    | Статус таблиц: является ли таблица append-only (AO) или нет.                           | Определение типа хранения таблиц для оптимизации операций (например, VACUUM). |
| __gp_number_of_segments                | Количество сегментов в кластере Greenplum.                                             | Проверка масштаба кластера и распределения данных.                            |
| __gp_user_data_tables                  | Список пользовательских таблиц с базовой информацией (OID, имя, схема).                | Инвентаризация пользовательских таблиц.                                       |
| __gp_user_data_tables_readable         | Список пользовательских таблиц с правами доступа для текущего пользователя.            | Проверка доступных таблиц для текущего пользователя.                          |
| __gp_user_namespaces                   | Информация о схемах (namespaces), доступных пользователю.                              | Анализ структуры схем в БД.                                                   |
| __gp_user_tables                       | Список таблиц, принадлежащих текущему пользователю.                                    | Управление таблицами в рамках текущей сессии.                                 |
| gp_bloat_diag                          | Диагностика «раздувания» (bloat) таблиц и индексов (ожидаемый vs фактический размер).  | Выявление таблиц, требующих VACUUM или REINDEX.                               |
| gp_bloat_expected_pages                | Ожидаемое и фактическое количество страниц для таблиц/индексов.                        | Оценка степени фрагментации данных.                                           |
| gp_locks_on_relation                   | Текущие блокировки на таблицах (отношениях).                                           | Выявление конфликтов блокировок и зависших транзакций.                        |
| gp_locks_on_resqueue                   | Блокировки, связанные с очередями ресурсов (resource queues).                          | Мониторинг использования ресурсов и очередей.                                 |
| gp_log_command_timings                 | Время выполнения команд (SQL-запросов) в логах.                                        | Анализ производительности запросов.                                           |
| gp_log_database                        | Логи операций, связанных с базами данных.                                              | Аудит изменений БД (создание, удаление, изменение).                           |
| gp_log_master_concise                  | Краткие логи мастер-ноды.                                                              | Быстрый анализ событий на мастер-ноде.                                        |
| gp_log_system                          | Системные логи (например, запуск/остановка кластера).                                  | Диагностика системных сбоев.                                                  |
| gp_param_settings_seg_value_diffs      | Различия в параметрах конфигурации между сегментами.                                   | Проверка согласованности настроек кластера.                                   |
| gp_pgdatabase_invalid                  | Сегменты с некорректным состоянием в каталоге `pg_database`.                           | Выявление проблемных сегментов.                                               |
| gp_resgroup_config                     | Конфигурация ресурсных групп (лимиты CPU, память и т.д.).                              | Управление ресурсными группами и их настройками.                              |
| gp_resgroup_status                     | Текущий статус ресурсных групп (использование CPU, памяти, активные запросы).          | Мониторинг нагрузки на ресурсные группы.                                      |
| gp_resgroup_status_per_host            | Статус ресурсных групп с разбивкой по хостам.                                          | Анализ распределения ресурсов между серверами.                                |
| gp_resgroup_status_per_segment         | Статус ресурсных групп с разбивкой по сегментам.                                       | Поиск перегруженных сегментов.                                                |
| gp_resq_activity                       | Активные запросы и их статус в очередях ресурсов.                                      | Мониторинг выполнения запросов в реальном времени.                            |
| gp_resq_activity_by_queue              | Активность по очередям ресурсов (количество запросов, время выполнения).               | Анализ загрузки очередей.                                                     |
| gp_resq_priority_backend               | Приоритеты backend-процессов в ресурсных очередях.                                     | Управление приоритезацией задач.                                              |
| gp_resq_priority_statement             | Приоритеты SQL-запросов в ресурсных очередях.                                          | Настройка приоритетов выполнения запросов.                                    |
| gp_resq_role                           | Роли, связанные с ресурсными очередями.                                                | Управление правами доступа к очередям.                                        |
| gp_resqueue_status                     | Текущее состояние очередей ресурсов (активные запросы, лимиты).                        | Мониторинг и настройка распределения ресурсов.                                |
| gp_roles_assigned                      | Назначенные роли пользователям и группам.                                              | Аудит прав доступа.                                                           |
| gp_size_of_all_table_indexes           | Общий размер всех индексов для таблиц.                                                 | Оценка использования дискового пространства индексами.                        |
| gp_size_of_database                    | Размер базы данных на диске.                                                           | Планирование ресурсов хранения.                                               |
| gp_size_of_index                       | Размер конкретного индекса.                                                            | Оптимизация индексов (например, удаление неиспользуемых).                     |
| gp_size_of_partition_and_indexes_disk  | Размер партиций и их индексов на диске.                                                | Анализ партиционированных таблиц.                                             |
| gp_size_of_schema_disk                 | Размер всех объектов схемы на диске.                                                   | Оценка нагрузки на схему.                                                     |
| gp_size_of_table_and_indexes_disk      | Размер таблицы и ее индексов на диске.                                                 | Полная оценка занимаемого места таблицей.                                     |
| gp_size_of_table_and_indexes_licensing | Размер таблицы и индексов для целей лицензирования.                                    | Контроль лицензионных ограничений.                                            |
| gp_size_of_table_disk                  | Размер таблицы на диске (без индексов).                                                | Базовый анализ использования диска.                                           |
| gp_size_of_table_uncompressed          | Размер таблицы в несжатом виде.                                                        | Сравнение эффективности сжатия.                                               |
| gp_skew_coefficients                   | Коэффициенты перекоса данных между сегментами (0 = равномерно, 1 = максимум перекоса). | Выявление неравномерного распределения данных.                                |
| gp_skew_idle_fractions                 | Доля «простаивающих» сегментов из-за перекоса данных.                                  | Оптимизация распределения данных и запросов.                                  |
| gp_stats_missing                       | Таблицы, для которых отсутствует статистика (не выполнено ANALYZE).                    | Планирование задач сбора статистики для оптимизатора.                         |
| gp_table_indexes                       | Индексы, связанные с таблицами.                                                        | Управление индексами (создание/удаление).                                     |
| gp_workfile_entries                    | Информация о временных рабочих файлах (workfiles), созданных запросами.                | Мониторинг использования временных файлов.                                    |
| gp_workfile_mgr_used_diskspace         | Общий объем дискового пространства, занятого рабочими файлами.                         | Контроль за использованием диска временными файлами.                          |
| gp_workfile_usage_per_query            | Использование рабочих файлов для каждого запроса.                                      | Выявление «тяжелых» запросов, потребляющих много ресурсов.                    |
| gp_workfile_usage_per_segment          | Использование рабочих файлов на каждом сегменте.                                       | Поиск сегментов с высокой нагрузкой из-за временных файлов.                   |

# Лекция 3, 4 airflow: Практическое задание 
## Задание
Необходимо написать DAG который будет выполнять следующие задачи:
1. С помощью PythonOperator необходимо сгенерировать тестовые данные и записать их в файл в 
каталог /tmp/data.csv ( для простоты можно взять 2 колонки id, value )
2. С помощью BashOperator переместить файл в каталог /tmp/processed_data
3. C помощью PythonOperator нужно загрузить данные из файла в таблицу в Postgres ( таблицу 
можно предварительно создать )
4. После записи данных в таблицу последним таском выведите в логах сообщение о количестве 
загруженных данных.
С помощью XCom необходимо:
Передать путь до файла из п.1 в оператор в п.2.
Передать количество записей из п.3 в п.4

## Реализация
![alt text](<attachments/Screenshot_1-3-2025_164424_10.10.144.35.jpeg>)
- [ссылка на код дага](airflow/dwh_4_t1_oguschin.py)

# Лекция 5: Практическое задание 
## Задание R5.1
Скопируйте в GreenPlum таблицу payments из базы t1_dwh_potok3_datasandbox в собственную базу 
и схему, созданные ранее. Создайте две копии таблицы payments_compressed_row и 
payments_compressed_columnar. Таблица payments_compressed_columnar должна иметь тип сжатия 
RLE, уровень сжатия 4 и колоночный тип хранения. Таблица payments_compressed_row должна 
иметь тип сжатия ZTSD, уровень сжатия 7 и строчный тип хранения. Используйте документацию при 
построении таблиц.  
Формат ответа: SQL-скрипты в текстовом документе и таблицы в вашей схеме в базе. Планы 
выполнения запросов и ваш вывод по эффективности выполненных преобразований над 
таблицами.  
## Реализация
- [sql script](<sql scripts/practice_5.sql>)  

Explain analyze payments  
![](attachments/Pasted%20image%2020250307212255.png)

Explain analyze payments_compressed_row  
![](attachments/Pasted%20image%2020250307212415.png)

Explain analyze payments_compressed_columnar  
![](attachments/Pasted%20image%2020250307212432.png)

Сравнение размера:

![](attachments/Pasted%20image%2020250307205906.png)

![](attachments/Pasted%20image%2020250307205933.png)

#### Выводы:
payments:
- Среднее время выполнения из-за отсутствия оптимизаций.
- Высокий I/O и нагрузка на сеть (из-за DISTRIBUTED RANDOMLY).
- Подходит для небольших данных, но неэффективна для аналитики.

payments_compressed_row(ZSTD):
- Быстрее оригинальной таблицы для точечных запросов.
- Уменьшение размера на ~30-50%, но распаковка замедляет агрегации.
- Оптимальна для OLTP-сценариев с частыми вставками/обновлениями.

payments_compressed_columnar(RLE):
- В 2-3 раза быстрее для аналитических запросов.
- Максимальное уменьшение размера (до 70%) благодаря RLE.
- Идеальна для OLAP-нагрузок и агрегаций.
## Задание R5.2
Опишите индексы, которые встречаются в PostgreSQL и GreenPlum. Отдельно выделите индексы, 
которые присутствуют только в GreenPlum.  
Формат ответа: Текстовый документ.  
## Реализация
### Индексы в PostgreSQL и Greenplum  
| Название | Описание                                                                | Особенности в PostgreSQL                                                                        | Особенности в Greenplum                                                         |
| -------- | ----------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| B-Tree   | Стандартный индекс для равенства и диапазонных запросов.                | Оптимизирован для сортировки, уникальных значений, частичных индексов.                          | Менее эффективен из-за распределения данных по сегментам.                       |
| Hash     | Для операций равенств.                                                  | Быстрее B-Tree для простых равенств, но не поддерживает диапазоны.                              | Редко используется из-за накладных расходов в распределенной среде.             |
| GiST     | Для сложных типов данных: геоданные, полнотекстовый поиск.              | Поддерживает пользовательские методы индексирования (например, для геопространственных данных). | Требует осторожности при распределении данных между сегментами.                 |
| GIN      | Для составных данных: массивы, JSON, полнотекстовый поиск.              | Эффективен для поиска множества значений в одном поле.                                          | Затратный при создании из-за распределенной архитектуры.                        |
| BRIN     | Блочный индекс для больших таблиц с упорядоченными данными.             | Экономит место, подходит для временных рядов.                                                   | Полезен для аналитических нагрузок, но требует аккуратной настройки диапазонов. |
| SP-GiST  | Для нерегулярных структур (например, деревья, пространственные данные). | Оптимизирован для неоднородных данных.                                                          | Используется редко из-за сложностей с распределением данных.                    |

### Уникальные индексы в Greenplum  
| Название          | Описание                                                                                                                                                         | Особенности                                                                              |
| ----------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| Bitmap            | Создает битовые карты для ускорения запросов с условиями AND/OR.                                                                                                 | Оптимизирован для распределенной среды, уменьшает сетевой трафик между сегментами.       |
| Columnstore       | Индекс для колоночного хранения данных.                                                                                                                          | Улучшает производительность аналитических запросов за счет сжатия и векторной обработки. |
| Distributed Index | Не является отдельным типом индекса в классическом понимании, но в Greenplum логика распределения данных (DISTRIBUTED BY) тесно связана с оптимизацией запросов. | Позволяет минимизировать перемещение данных между узлами при выполнении JOIN.            |
