--------------------------------------------------------
--  File created - Tuesday-October-10-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table TEMP_RESERVE_RATIO
--------------------------------------------------------

  CREATE TABLE "CUSTOM"."TEMP_RESERVE_RATIO" 
   (	"TRAN_DATE" VARCHAR2(20 BYTE), 
	"MMK_CURRENTACC_BAL" VARCHAR2(30 BYTE), 
	"USD_CURRENTACC_BAL" VARCHAR2(20 BYTE), 
	"RUNNING_MMKAMT" VARCHAR2(30 BYTE), 
	"RUNNING_USDAMT" VARCHAR2(30 BYTE), 
	"ID" NUMBER(20,0), 
	"AVG_CURRENTAMT" VARCHAR2(20 BYTE), 
	"DOBAL" VARCHAR2(20 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 16384 NEXT 16384 MINEXTENTS 1 MAXEXTENTS 505
  PCTINCREASE 50 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "SYSTEM" ;
