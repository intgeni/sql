-- David Mann
-- http://ba6.us
-- 24-JUL-2012

-- Archived Log Heat Map for past 31 Days
-- Requires access to v$archived_log
-- Spool output to file and view with browser 
-- or use SQL Developer PL/SQL DBMS_OUTPUT report type

-- I tried to use a scripted stylesheet but SQL Dev wouldn't cooperate so
-- that is my excuse for all of the ugly inline CSS. For now :) 

--SET SERVEROUTPUT ON
DECLARE
  myMax NUMBER;
  myDBName VARCHAR2(16);

  -- dec2hex Function from http://www.orafaq.com/wiki/Hexadecimal
  FUNCTION dec2hex (N in number) RETURN varchar2 IS
    hexval varchar2(64);
    N2     number := N;
    digit  number;
    hexdigit  char;
  BEGIN
    while ( N2 > 0 ) loop
       digit := mod(N2, 16);
       if digit > 9 then 
         hexdigit := chr(ascii('A') + digit - 10);
       else
         hexdigit := to_char(digit);
       end if;
       hexval := hexdigit || hexval;
       N2 := trunc( N2 / 16 );
    end loop;
    return hexval;
  END dec2hex;

  FUNCTION DataCell ( P_Value NUMBER, P_Max NUMBER) RETURN VARCHAR2 IS
   myReturn VARCHAR2(128);
   myColorVal NUMBER;
   myColorHex VARCHAR2(16);
  BEGIN

    myColorVal := ROUND( 255-FLOOR(255 * (P_VALUE / P_MAX)));
    myColorHex := LPAD(TRIM(dec2hex(myColorVal)) ,2,'0');
    
    IF P_Value = P_Max THEN
      myColorHex := '00';
    END IF;
    

    myReturn := '<TD STYLE="background-color: #FF'||
                myColorHex||
                myColorHex||
                '; font-family: monospace">'||P_Value||'</TD>';


    RETURN myReturn;
  END DataCell;

BEGIN

  DBMS_OUTPUT.ENABLE(100000);

  SELECT ROUND(MAX(COUNT(*)))
    INTO myMax
    FROM v$log_history 
  WHERE trunc(FIRST_TIME) >= trunc(sysdate - 31)
  GROUP BY TO_CHAR(first_time,'YYYY-MM-DD HH24');
  
  SELECT NAME INTO myDBName FROM V$DATABASE;

  DBMS_OUTPUT.PUT_LINE('<HTML>');
  DBMS_OUTPUT.PUT_LINE('<H1>Archived Log Heat Map - '||myDBName||'  - Past 31 days</H1>');
  DBMS_OUTPUT.PUT_LINE('<TABLE>');
  DBMS_OUTPUT.PUT_LINE('<TR>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">Date / Hour</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">00</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">01</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">02</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">03</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">04</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">05</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">06</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">07</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">08</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">09</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">10</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">11</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">12</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">13</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">14</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">15</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">16</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">17</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">18</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">19</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">20</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">21</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">22</TD>');
  DBMS_OUTPUT.PUT_LINE('<TD STYLE="font-family: monospace; font-weight: bold; background-color:#DEDEDE">23</TD>');
  DBMS_OUTPUT.PUT_LINE('<TR>');

  FOR cur IN (

    select trunc(first_time) AS Day,
    sum(DECODE(to_char(first_time, 'HH24'), '00', 1, 0)) AS "00",
    sum(DECODE(to_char(first_time, 'HH24'), '01', 1, 0)) AS "01",
    sum(DECODE(to_char(first_time, 'HH24'), '02', 1, 0)) AS "02",
    sum(DECODE(to_char(first_time, 'HH24'), '03', 1, 0)) AS "03",
    sum(DECODE(to_char(first_time, 'HH24'), '04', 1, 0)) AS "04",
    sum(DECODE(to_char(first_time, 'HH24'), '05', 1, 0)) AS "05",
    sum(DECODE(to_char(first_time, 'HH24'), '06', 1, 0)) AS "06",
    sum(DECODE(to_char(first_time, 'HH24'), '07', 1, 0)) AS "07",
    sum(DECODE(to_char(first_time, 'HH24'), '08', 1, 0)) AS "08",
    sum(DECODE(to_char(first_time, 'HH24'), '09', 1, 0)) AS "09",
    sum(DECODE(to_char(first_time, 'HH24'), '10', 1, 0)) AS "10",
    sum(DECODE(to_char(first_time, 'HH24'), '11', 1, 0)) AS "11",
    sum(DECODE(to_char(first_time, 'HH24'), '12', 1, 0)) AS "12",
    sum(DECODE(to_char(first_time, 'HH24'), '13', 1, 0)) AS "13",
    sum(DECODE(to_char(first_time, 'HH24'), '14', 1, 0)) AS "14",
    sum(DECODE(to_char(first_time, 'HH24'), '15', 1, 0)) AS "15",
    sum(DECODE(to_char(first_time, 'HH24'), '16', 1, 0)) AS "16",
    sum(DECODE(to_char(first_time, 'HH24'), '17', 1, 0)) AS "17",
    sum(DECODE(to_char(first_time, 'HH24'), '18', 1, 0)) AS "18",
    sum(DECODE(to_char(first_time, 'HH24'), '19', 1, 0)) AS "19",
    sum(DECODE(to_char(first_time, 'HH24'), '20', 1, 0)) AS "20",
    sum(DECODE(to_char(first_time, 'HH24'), '21', 1, 0)) AS "21",
    sum(DECODE(to_char(first_time, 'HH24'), '22', 1, 0)) AS "22",
    sum(DECODE(to_char(first_time, 'HH24'), '23', 1, 0)) AS "23"
    FROM v$log_history
    WHERE trunc(FIRST_TIME) >= trunc(sysdate - 31)
    GROUP BY trunc(first_time)
    ORDER BY TRUNC(FIRST_TIME)
  )
  LOOP
    DBMS_OUTPUT.PUT_LINE('<TR>');
    DBMS_OUTPUT.PUT_LINE('<TD style="font-family: monospace; font-weight: bold; background-color:#DEDEDE">'||TO_CHAR(cur.Day,'DD-MON-YYYY')||'<EM></TD>');
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."00", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."01", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."02", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."03", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."04", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."05", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."06", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."07", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."08", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."09", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."10", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."11", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."12", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."13", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."14", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."15", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."16", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."17", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."18", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."19", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."20", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."21", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."22", myMax) );
    DBMS_OUTPUT.PUT_LINE( DataCell(cur."23", myMax) );
    DBMS_OUTPUT.PUT_LINE('</TR>');
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('</TABLE>');
  DBMS_OUTPUT.PUT_LINE('</HTML>');


END;