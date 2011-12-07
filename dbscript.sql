-- Database: mango_test

-- DROP DATABASE mango_test;

CREATE DATABASE mango_test
  WITH OWNER = myao
       ENCODING = 'UTF8'
       LC_COLLATE = 'en_US.utf8'
       LC_CTYPE = 'en_US.utf8'
       CONNECTION LIMIT = -1;

-- Schema: "data_hive"

-- DROP SCHEMA data_hive;

CREATE SCHEMA data_hive
  AUTHORIZATION postgres;

-- Table: data_hive.uri_downloaded

-- DROP TABLE data_hive.uri_downloaded;

CREATE TABLE data_hive.uri_downloaded
(
  uri character varying(1024) NOT NULL,
  downloaded_dtm timestamp without time zone,
  CONSTRAINT uri_downloaded_pkey PRIMARY KEY (uri)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE data_hive.uri_downloaded OWNER TO postgres;

-- Table: data_hive.uri_queue

-- DROP TABLE data_hive.uri_queue;

CREATE TABLE data_hive.uri_queue
(
  uri character varying(1024) NOT NULL,
  last_modified_date timestamp without time zone,
  CONSTRAINT "PK" PRIMARY KEY (uri)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE data_hive.uri_queue OWNER TO postgres;

-- Index: data_hive.last_modified_idx

-- DROP INDEX data_hive.last_modified_idx;

CREATE INDEX last_modified_idx
  ON data_hive.uri_queue
  USING btree
  (last_modified_date DESC NULLS LAST);

-- Schema: "geo_ca"

-- DROP SCHEMA geo_ca;

CREATE SCHEMA geo_ca
  AUTHORIZATION myao;

CREATE TABLE geo_ca.address_nca (
    addr_id         varchar(30) PRIMARY KEY,  
    unit_num	    varchar(30),
    st_num          varchar(30),
    st_dir	    varchar(30),
    st_name         varchar(30),
    st_type	    varchar(30),
    city	    varchar(30),
    zip		    varchar(10),
    county	    varchar(10),
    location	    point,
    created_dtm     timestamp,
    update_dtm      timestamp
    
);

CREATE TABLE geo_ca.city (
    city_id             varchar(30) PRIMARY KEY,  
    center		point,
    city_name		varchar(30),
    county_id   	varchar(30),
    state_id		varchar(30)
    );

CREATE TABLE geo_ca.city_zip (
    city_id           varchar(30),  
    zip_code 	      varchar(30),
    PRIMARY KEY (city_id, zip_code)
    );

CREATE TABLE geo_ca.community (
    comm_id           varchar(30) PRIMARY KEY,  
    comm_name		varchar(30)
    );

CREATE TABLE geo_ca.county (
    county_id           varchar(30) PRIMARY KEY,  
    center		point,
    city_name		varchar(30),
    state_id		varchar(30)
    );

CREATE TABLE geo_ca.metro (
    metro_id           varchar(30) PRIMARY KEY,  
    metro_name		varchar(30)
    );

CREATE TABLE geo_ca.metro_city (
    city_id           varchar(30),  
    metro_id 	      varchar(30),
    PRIMARY KEY (city_id, metro_id)
    );

CREATE TABLE geo_ca.state (
    state_id           varchar(30) PRIMARY KEY,  
    center		point,
    state_name		varchar(30)
    );

CREATE TABLE geo_ca.zipcode (
    zipcode          varchar(30),  
    center 	     point,
    PRIMARY KEY (zipcode)
    );

-- Schema: "mls_sb_ca"

-- DROP SCHEMA mls_sb_ca;

CREATE SCHEMA mls_sb_ca
  AUTHORIZATION myao;



CREATE TABLE mls_sb_ca.mls_listing_nca (
    lid             varchar(30) PRIMARY KEY,  
    feed_id         varchar(30),   
    source          int,           
    addr_id	    varchar(30),
    bed		    int,
    bath	    int,
    half_bath       int,
    sqft	    int,
    lot_size	    int,
    prop_type	    varchar(30),
    style	    varchar(30),
    stories         int,
    year_built      int,
    prop_view       varchar(30),
    community	    varchar(50),
    status	    varchar(30),
    dom		    int,
    public_cmt      varchar(4096),
    photo_num	    int,
    list_date	    date,
    list_price      int,
    sold_date       date,
    sold_price      int,
    created_dtm     timestamp,
    update_dtm      timestamp
    
);

CREATE TABLE mls_sb_ca.mls_listing_feature_nca (
    lid             varchar(30) PRIMARY KEY,  
    feature_name    varchar(30),
    feature_value   varchar(255),
    created_dtm     timestamp,
    update_dtm      timestamp
);

CREATE TABLE mls_sb_ca.mls_listing_open_house_nca (
    lid             varchar(30) PRIMARY KEY,  
    open_date       date,
    open_hour_start int,
    open_hour_end   int,
    created_dtm     timestamp,
    update_dtm      timestamp
);

