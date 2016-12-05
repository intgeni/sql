CREATE OR REPLACE PROCEDURE SYS.CRM_ADD_MONTHLY_TABLESPACE(
      i_month_range integer DEFAULT 6,
      i_debug BOOLEAN DEFAULT FALSE)
IS
  ------------
  --
  --  Version: 1.0
  --
  --  OVERVIEW
  --
  --  The procedure add MONTHLY tablespaces for CRM databases
  --  
  --   - i_month_range - range of months to add tablespaces
  --   - i_debug - TRUE = only send output to terminal
  --
  --  jiri.srba@s-itsolutions.cz
  --
  ------------
  DEBUG                   BOOLEAN := i_debug;
  TYPE t_tablespace_prefix_tab IS TABLE OF VARCHAR2 (20);
  v_tablespace_prefix t_tablespace_prefix_tab := t_tablespace_prefix_tab('SIEBSA_DATA_');
  v_tablespace_max_size   integer := 65;      -- size in GB
  v_sql                   varchar2(500);
--  
BEGIN
  -- pro vsechny prefixovane TABLESPACES
  FOR i IN v_tablespace_prefix.FIRST .. v_tablespace_prefix.LAST LOOP
    FOR REC in (
      -- vyber N i_month_range mesicu zpet, 1 mesic DOPREDU
      SELECT v_tablespace_prefix(i)||
        to_char(ADD_MONTHS (sysdate, LEVEL - i_month_range - 1), 'YYYYMM') tablespace_name
      FROM DUAL CONNECT BY LEVEL <= i_month_range + 2
      -- mimo jiz vytvorene tablespaces
      MINUS
      SELECT tablespace_name FROM dba_tablespaces
      )
    LOOP
      v_sql := 'CREATE BIGFILE tablespace '||rec.tablespace_name||
        ' datafile size 512M autoextend on next 512M maxsize '||
        v_tablespace_max_size||'G'||
        ' EXTENT MANAGEMENT LOCAL UNIFORM SIZE 2M';
      -- execute SQL
      IF ( DEBUG = TRUE ) THEN
        dbms_output.put_line (v_sql);
      ELSE
        execute immediate v_sql;
      END IF;
    
      -- SIEBSA quota unlimited  
      v_sql := 'ALTER USER SIEBSA QUOTA UNLIMITED ON '||rec.tablespace_name;
        IF ( DEBUG = TRUE ) THEN
        dbms_output.put_line (v_sql);
      ELSE
        execute immediate v_sql;
      END IF;
    END LOOP;
  END LOOP;  
--
END;
/

set serveroutput on
exec CRM_ADD_MONTHLY_TABLESPACE(14, FALSE);

ALTER SESSION Set TIME_ZONE = 'EUROPE/PRAGUE'; 
alter session set NLS_TERRITORY = 'CZECH REPUBLIC'; 
-- scheduler job CRM_ADD_MONTHLY_TBS
-- freq=daily during MAINTENANCE_WINDOW_GROUP
begin
  dbms_scheduler.create_job(
     job_name => 'SYS.CRM_ADD_MONTHLY_TBS',
     job_type => 'PLSQL_BLOCK',
     job_action => 'BEGIN SYS.CRM_ADD_MONTHLY_TABLESPACE(6); END;',
     -- start_date => sysdate,
     -- repeat_interval => 'FREQ=DAILY;byhour=2',
     schedule_name => 'SYS.MAINTENANCE_WINDOW_GROUP',
     auto_drop => FALSE,
     enabled => TRUE);
END;
/

select * from dba_scheduler_jobs
 where owner = 'SYS' and job_name like 'CRM_ADD_MONTHLY_TBS';
 
SELECT cast(to_timestamp_tz(log_date) at local as date) log_date_local,
    owner,
    JOB_NAME,
    status,
    error#
  FROM DBA_SCHEDULER_JOB_RUN_DETAILS
  WHERE job_name LIKE 'CRM_ADD_MONTHLY_TBS'
--    AND status <> 'SUCCEEDED'
  ORDER BY log_date DESC; 
 
select tablespace_name from dba_tablespaces
 where TABLESPACE_NAME like 'SIEBSA_DATA_%'
order by 1;

-- 6 m�s�c� zp�t, 1 nav�c
SELECT 'SIEBSA_DATA_'|| to_char(ADD_MONTHS (sysdate, LEVEL - 7), 'YYYYMM') tablespace_name
FROM DUAL CONNECT BY LEVEL <=8 --(N+1)
MINUS
SELECT tablespace_name FROM dba_tablespaces
;

select * from dba_scheduler_windows;