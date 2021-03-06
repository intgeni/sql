# ASM disk groups

## list new asm diskgroups
sqlplus / as sysasm <<ESQL
select unique
        regexp_replace(path,
          '^/dev/mapper/asm.*_([A-Z]+)_(D01|DATA|FRA)(p1|\d+)?',
          '\1_\2',
          1,0,'i') AS dg
  from v\$asm_disk
 where header_status in ('CANDIDATE','FORMER')
order by 1;
exit
ESQL

## vyzkouset vytvoreni ASM diskgroupy pres asmca -silent
asmcmd lsdsk --suppressheader --candidate

asmcmd lsdsk --suppressheader --candidate | \
  grep -Poi '([A-Z]+)_(D0\d|DATA|FRA)' | uniq

DG=COLD_DATA
AU_SIZE=4
COMPATIBLE="12.1"
asmca -silent -createDiskGroup \
  -diskGroupName COLD_DATA \
    -diskList '/dev/mapper/asm_*COLD_DATA' \
  -redundancy EXTERNAL -au_size ${AU_SIZE} \
  -compatible.asm ${COMPATIBLE} -compatible.rdbms ${COMPATIBLE}

## asmcmd compatible

compatible.asm
compatible.rdbms

for each in SEAD_D01 SEAD_FRA
do
  asmcmd lsattr -l -G $each
  asmcmd setattr -G $each compatible.asm 12.1
  asmcmd setattr -G $each compatible.rdbms 12.1
done

## asmcmd mkdg
AU_SIZE=4M
COMPATIBLE="12.1"

cat >
<dg name="data" redundancy="normal">
     <fg name="fg1">
          <dsk string="/dev/disk1"/>
          <dsk string="/dev/disk2"/>
     </fg>
     <fg name="fg2">
          <dsk string="/dev/disk3"/>
          <dsk string="/dev/disk4"/>
     </fg>

     <a name="compatible.asm" value="11.2" />
     <a name="compatible.rdbms" value="11.2" />
     <a name="compatible.advm" value="11.2" />
</dg>


## create ASM diskgroup
AU_SIZE=4M
COMPATIBLE="12.1"
sqlplus -s / as sysasm <<ESQL
SET heading off verify off feed off trims on pages 0 lines 32767
define au_size=${AU_SIZE}
define compatible=${COMPATIBLE}
spool asm_create_dg.sql
-- nazev DG je vytvo�en p�es regexp
-- '^/dev/(mapper/(\w+_){3}|rlvo)([a-zA-Z]+)[_]?(D01|d01|DATA|data|FRA|fra)(p1|\d+)','\3_\4'
-- AIX /dev/rlvo
-- Linux /dev/mapper
-- /dev/mapper/asm_srdf-metro_01CA_RTOZA_D01p1
SELECT
  'CREATE DISKGROUP ' || dg
    ||' EXTERNAL REDUNDANCY '||chr(10)|| 'DISK'||CHR(10)
    || disk||chr(10)
    || 'ATTRIBUTE ''AU_SIZE''=''&au_size'', ''compatible.asm''=''&compatible'',''compatible.rdbms''=''&compatible'';'
  as cmd
FROM
   (
    SELECT
      regexp_replace(path,
        '^/dev/mapper/asm.*_([A-Z]+)_(D0\d|DATA|FRA)(p1|\d)?',
        '\1_\2',
        1,0,'i') AS dg,
      LISTAGG(''''||path||'''', ','||chr(10)) WITHIN GROUP (ORDER BY path) disk
    FROM V\$ASM_DISK
    WHERE
      header_status in ('CANDIDATE','FORMER')
      --and path like '%CLMT%'
    GROUP BY
       regexp_replace(path,
        '^/dev/mapper/asm.*_([A-Z]+)_(D0\d|DATA|FRA)(p1|\d)?',
        '\1_\2',
        1,0,'i')
  )
/

prompt exit

spool off;
ESQL

sqlplus / as sysasm @asm_create_dg.sql

## list ASM diskgroups and compatibility
sqlplus / as sysasm <<ESQL
set lines 180
col name for a10
col type for a6
col COMPATIBILITY for a15
col DATABASE_COMPATIBILITY for a15
select name, TYPE, TOTAL_MB, FREE_MB, ALLOCATION_UNIT_SIZE/1048576 AU_SIZE, COMPATIBILITY, DATABASE_COMPATIBILITY
  from v\$asm_diskgroup
ORDER by NAME;
ESQL


## RAC: mount asm dg na v�ech nodech
for dg in $(asmcmd lsdg --suppressheader | awk '{print $NF}' | tr -d '/')
do
  srvctl start diskgroup -diskgroup $dg
done

crs
