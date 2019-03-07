/*
--#########################################################################
--
-- Script Name          :  $Workfile:   $
-- Header               :  $Header:   $
-- Revision             :  $Revision: $
--
---------------------------------------------------------------------------
--
-- Description:
--      Reporting script for isis migration
--
-- Modification History         :     $Log:   $
--
--#########################################################################*/

set pagesize 0;
set linesize 32767;
set trimspool on;
set feedback off;
set termout off;
set serveroutput on;
set serveroutput on size 1000000;
DBMS_OUTPUT.ENABLE(2000000);
spool migration_report.csv;

DECLARE

v_customer_number           VARCHAR2(20);
ignore                      number;

CURSOR c_customer IS
(
    SELECT DISTINCT value AS customer_number
    FROM fif_isis_req_params
    WHERE PARAM='CUSTOMER_NUMBER'
);

FUNCTION writeCustomerReport
    (customer_number_in IN VARCHAR2)
RETURN number
AS
    CURSOR c_contract IS
    SELECT r.transaction_id, r.status, p.value AS contract_number
    FROM fif_isis_req_params p, fif_isis_req r
    WHERE p.transaction_id IN
    (SELECT transaction_id
     FROM fif_isis_req_params
     WHERE param='CUSTOMER_NUMBER'
     AND value=customer_number_in)
    AND r.transaction_id=p.transaction_id;

    cont_transid        VARCHAR2(30);
    cont_status         VARCHAR2(30);
    cont_number         VARCHAR2(30);

    cont_success        NUMBER;
    cont_num_success    VARCHAR2(10000);
    cont_num_failure    VARCHAR2(10000);


BEGIN
  cont_success := 1;

  OPEN c_contract;

  LOOP
    FETCH c_contract INTO cont_transid, cont_status, cont_number;
    EXIT WHEN c_contract%NOTFOUND;

    IF (cont_status != 'COMPLETED')
    THEN
      cont_success := 0;
/*      if (cont_num_failure = '')
      THEN
        cont_num_failure := cont_number;
      ELSE
        cont_num_failure := (cont_num_failure || ' ' || cont_number);
      END IF;*/
    END IF;

/*    IF (cont_status = 'COMPLETED')
    THEN
      if (cont_num_success = '')
      THEN
        cont_num_success := cont_number;
      ELSE
        cont_num_success := (cont_num_success || ' ' || cont_number);
      END IF;
    END IF;*/

  END LOOP;

  IF (cont_success != 0)
  THEN
    DBMS_OUTPUT.PUT_LINE(customer_number_in || ';COMPLETED;' || cont_num_success || ';' || cont_num_failure);
  ELSE
    DBMS_OUTPUT.PUT_LINE(customer_number_in || ';FAILED;' || cont_num_success || ';' || cont_num_failure);
  END IF;

  CLOSE c_contract;

  RETURN cont_success;
END writeCustomerReport;

BEGIN
   DBMS_OUTPUT.PUT_LINE('CUSTOMER_NUMBER;MIGRATION_RESULT;SUCCESS_CONTRACT_NUMBERS;FAILURE_CONTRACT_NUMBERS');
   FOR i IN c_customer
   LOOP
     ignore := writeCustomerReport(i.customer_number);
   END LOOP;
END;
/
