LOAD DATA
APPEND
INTO TABLE EZPAARSE_RESULTS
FIELDS CSV WITH EMBEDDED
TERMINATED BY ';' OPTIONALLY ENCLOSED BY '"'
TIMESTAMP WITH TIME ZONE 'YYYY-MM-DD"T"HH24:MI:SS+TZH:TZM'
DATE FORMAT 'YYYY-MM-DD'
(
  "loadid" CHAR(128),
  "datetime" TIMESTAMP WITH TIME ZONE,
  "date" DATE,
  "login" CHAR(17) "RTRIM(REPLACE(:\"login\", '@pitt.edu', ''))",
  "platform" CHAR(64),
  "platform_name" CHAR(128),
  "publisher_name" CHAR(128),
  "rtype" CHAR(24),
  "mime" CHAR(16),
  "print_identifier" CHAR(32),
  "online_identifier" CHAR(32),
  "title_id" CHAR(256),
  "doi" CHAR(256),
  "publication_title" CHAR(8192) "SUBSTR(:\"publication_title\", 1, 256)",
  "publication_date" CHAR(10),
  "unitid" CHAR(8192) "SUBSTR(:\"unitid\", 1, 1024)",
  "domain" CHAR(128),
  "on_campus" CHAR(1),
  "log_id" CHAR(64),
  "ezpaarse_version" CHAR(64),
  "ezpaarse_date" DATE,
  "middlewares_version" CHAR(7),
  "middlewares_date" DATE,
  "platforms_version" CHAR(7),
  "platforms_date" DATE,
  "middlewares" CHAR(256),
  "title" CHAR(8192) "SUBSTR(:\"title\", 1, 1024)",
  "type" CHAR(32),
  "subject" CHAR(512),
  "geoip_country" CHAR(2),
  "geoip_latitude" CHAR,
  "geoip_longitude" CHAR,
  "host" CHAR(15),
  "ezproxy_session" CHAR(15),
  "url" CHAR(8192) "SUBSTR(:\"url\", 1, 1024)",
  "status" CHAR,
  "size" CHAR
)
