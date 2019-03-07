-- Example db insert example for changing the DSL bandwidth
INSERT INTO FIF_REQUEST VALUES ('TESTID-004', 'SLS', 'NOT_STARTED', 'modifySelectedDestinations', '', SYSDATE, 0, SYSDATE, NULL, NULL, 'testuser', NULL);
INSERT INTO FIF_REQUEST_PARAM VALUES ('TESTID-004', 'PRODUCT_SUBSCRIPTION_ID', 'PS010101010');

INSERT INTO FIF_REQUEST_PARAM_LIST VALUES ('TESTID-004', 'SELECTED_DESTINATIONS_LIST', 'BEGIN_NUMBER' , '49;12345678900', '1');
INSERT INTO FIF_REQUEST_PARAM_LIST VALUES ('TESTID-004', 'SELECTED_DESTINATIONS_LIST', 'END_NUMBER' , '49;12345678909', '1');
INSERT INTO FIF_REQUEST_PARAM_LIST VALUES ('TESTID-004', 'SELECTED_DESTINATIONS_LIST', 'BEGIN_NUMBER' , '49;98724546400', '2');
INSERT INTO FIF_REQUEST_PARAM_LIST VALUES ('TESTID-004', 'SELECTED_DESTINATIONS_LIST', 'END_NUMBER' , '49;98724546409', '2');

INSERT INTO FIF_REQUEST_PARAM VALUES ('TESTID-004', 'CREATE_CONTACT', 'Y');
INSERT INTO FIF_REQUEST_PARAM VALUES ('TESTID-004', 'CUSTOMER_NUMBER', '000123456789');
