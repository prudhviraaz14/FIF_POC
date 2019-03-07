-- PL/SQL script for inserting batch data in the XML_REQUEST table.  Used for performance testing.

BEGIN
    FOR loopindex in 1 .. 5000
    LOOP
        BEGIN
            insert into xml_request values (loopindex, loopindex, 'FIF', 100, 'addServiceSubscriptionLocalPreselection', '', SYSDATE, 1, SYSDATE, NULL, NULL);
            insert into xml_request_value values (loopindex, 'SERVICE_CODE_LOCAL_PRESEL', 'V0008');
            insert into xml_request_value values (loopindex, 'SERVICE_CODE_WECHSEL', 'V0000');
            insert into xml_request_value values (loopindex, 'CUSTOMER_NUMBER', '0101010101010');
            insert into xml_request_value values (loopindex, 'ACCESS_NUMBER', '1;1111;12233;112');

            EXCEPTION
            WHEN OTHERS
            THEN
                ROLLBACK;
                raise_application_error (-20100, SUBSTR (SQLERRM (SQLCODE), 1, 200) );
        END;

        COMMIT;
    END LOOP;
END;
