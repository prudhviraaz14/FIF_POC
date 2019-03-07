-- SQL script for inserting test data for the OPMFIFDatabaseClient

insert into xml_request values ('1', '1', 'FIF', 100, 'addServiceSubscriptionLocalPreselection', '', SYSDATE, 1, SYSDATE, NULL, NULL);
insert into xml_request_value values ('1', 'SERVICE_CODE_LOCAL_PRESEL', 'V0008');
insert into xml_request_value values ('1', 'SERVICE_CODE_WECHSEL', 'V0000');
insert into xml_request_value values ('1', 'CUSTOMER_NUMBER', '0101010101010');
insert into xml_request_value values ('1', 'ACCESS_NUMBER', '49;201;12345678');
insert into xml_request_value values ('1', 'BARCODE', '0101010101077');
insert into xml_request_value values ('1', 'AUFTRAGSPOSITION_ID', '1234567890');

insert into xml_request values ('2', '2', 'FIF', 100, 'addServiceSubscriptionLocalPreselection', '', SYSDATE, 1, SYSDATE, NULL, NULL);
insert into xml_request_value values ('2', 'SERVICE_CODE_LOCAL_PRESEL', 'V0008');
insert into xml_request_value values ('2', 'SERVICE_CODE_WECHSEL', 'V0000');
insert into xml_request_value values ('2', 'CUSTOMER_NUMBER', '0101010101010');
insert into xml_request_value values ('2', 'ACCESS_NUMBER', '49;201;12345678');
insert into xml_request_value values ('2', 'BARCODE', '0101010101077');
insert into xml_request_value values ('2', 'AUFTRAGSPOSITION_ID', '1234567890');

insert into xml_request values ('3', '3', 'FIF', 100, 'addServiceSubscriptionLocalPreselection', '', SYSDATE, 1, SYSDATE, NULL, NULL);
insert into xml_request_value values ('3', 'SERVICE_CODE_LOCAL_PRESEL', 'V0008');
insert into xml_request_value values ('3', 'SERVICE_CODE_WECHSEL', 'V0000');
insert into xml_request_value values ('3', 'CUSTOMER_NUMBER', '0101010101010');
insert into xml_request_value values ('3', 'ACCESS_NUMBER', '49;201;12345678');
insert into xml_request_value values ('3', 'BARCODE', '0101010101077');
insert into xml_request_value values ('3', 'AUFTRAGSPOSITION_ID', '1234567890');

insert into xml_request values ('4', '4', 'FIF', 100, 'addServiceSubscriptionLocalPreselection', '', SYSDATE, 1, SYSDATE, NULL, NULL);
insert into xml_request_value values ('4', 'SERVICE_CODE_LOCAL_PRESEL', 'V0008');
insert into xml_request_value values ('4', 'SERVICE_CODE_WECHSEL', 'V0000');
insert into xml_request_value values ('4', 'CUSTOMER_NUMBER', '0101010101010');
insert into xml_request_value values ('4', 'ACCESS_NUMBER', '49;201;12345678');
insert into xml_request_value values ('4', 'BARCODE', '0101010101077');
insert into xml_request_value values ('4', 'AUFTRAGSPOSITION_ID', '1234567890');


insert into xml_request values ('5', '5', 'FIF', 100, 'addServiceSubscriptionLocalPreselection', '', SYSDATE, 1, SYSDATE, NULL, NULL);
insert into xml_request_value values ('5', 'SERVICE_CODE_LOCAL_PRESEL', 'V0008');
insert into xml_request_value values ('5', 'SERVICE_CODE_WECHSEL', 'V0000');
insert into xml_request_value values ('5', 'CUSTOMER_NUMBER', '0101010101010');
insert into xml_request_value values ('5', 'ACCESS_NUMBER', '49;201;12345678');
insert into xml_request_value values ('5', 'BARCODE', '0101010101077');
insert into xml_request_value values ('5', 'AUFTRAGSPOSITION_ID', '1234567890');

insert into xml_request values ('6', '6', 'FIF', 100, 'addServiceSubscriptionLocalPreselection', '', SYSDATE, 1, SYSDATE, NULL, NULL);
insert into xml_request_value values ('6', 'SERVICE_CODE_LOCAL_PRESEL', 'V0005');
insert into xml_request_value values ('6', 'SERVICE_CODE_WECHSEL', 'V0000');
insert into xml_request_value values ('6', 'CUSTOMER_NUMBER', '000000070589');
insert into xml_request_value values ('6', 'ACCESS_NUMBER', '49;201;379222801');
insert into xml_request_value values ('6', 'BARCODE', '0101010101077');
insert into xml_request_value values ('6', 'AUFTRAGSPOSITION_ID', '1234567890');

commit;


