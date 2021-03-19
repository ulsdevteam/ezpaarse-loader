CREATE TABLE EZPAARSE_RESULTS (
  "recordid" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
  "loadid" NCHAR(128) NOT NULL,
  "rc" VARCHAR2(10),
  "dept" VARCHAR2(10),
  "datetime" TIMESTAMP WITH TIME ZONE,
  "date" DATE,
  "login" VARCHAR2(8),
  "platform" NVARCHAR2(64),
  "platform_name" NVARCHAR2(128),
  "publisher_name" NVARCHAR2(128),
  "rtype" NCHAR(24),
  "mime" NCHAR(16),
  "print_identifier" NVARCHAR2(32),
  "online_identifier" NVARCHAR2(32),
  "title_id" NVARCHAR2(256),
  "doi" NVARCHAR2(256),
  "publication_title" NVARCHAR2(256),
  "publication_date" NCHAR(10),
  "unitid" NVARCHAR2(1024),
  "domain" NVARCHAR2(128),
  "on_campus" NCHAR(1),
  "log_id" NVARCHAR2(64),
  "ezpaarse_version" NVARCHAR2(64),
  "ezpaarse_date" DATE,
  "middlewares_version" NCHAR(7),
  "middlewares_date" DATE,
  "platforms_version" NCHAR(7),
  "platforms_date" DATE,
  "middlewares" NVARCHAR2(256),
  "title" NVARCHAR2(1024),
  "type" NCHAR(32),
  "subject" NVARCHAR2(512),
  "geoip_country" NCHAR(2),
  "geoip_latitude" NUMBER(7,4),
  "geoip_longitude" NUMBER(7,4),
  "host" NCHAR(15),
  "ezproxy_session" NCHAR(15),
  "url" NVARCHAR2(1024),
  "status" NUMBER(3),
  "size" NUMBER(10),
  CONSTRAINT EZP_PK PRIMARY KEY (recordid)
);

CREATE INDEX EZPR_LOADID ON EZPAARSE_RESULTS ("loadid");

CREATE INDEX EZPR_LOGIN ON EZPAARSE_RESULTS ("login");

CREATE INDEX EZPR_DATETIME ON EZPAARSE_RESULTS ("datetime");

/

EXIT