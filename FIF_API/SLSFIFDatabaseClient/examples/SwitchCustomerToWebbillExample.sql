-- Example db insert example for switching a customer to webBill
INSERT INTO FIF_REQUEST VALUES ('TESTID-006', 'SLS', 'NOT_STARTED', 'switchCustomerToWebbill', '', SYSDATE, 0, SYSDATE, NULL, NULL, 'testuser', NULL);
INSERT INTO FIF_REQUEST_PARAM VALUES ('TESTID-006', 'ACCOUNT_NUMBER', 'TESTID001');
INSERT INTO FIF_REQUEST_PARAM VALUES ('TESTID-006', 'CUSTOMER_NUMBER', '123456789012');
INSERT INTO FIF_REQUEST_PARAM VALUES ('TESTID-006', 'CATEGORY_RD', 'TESTCAT');
INSERT INTO FIF_REQUEST_PARAM VALUES ('TESTID-006', 'EFFECTIVE_DATE', '2004.11.24 12:00:00');
INSERT INTO FIF_REQUEST_PARAM VALUES ('TESTID-006', 'DATA_SOURCE', 'KSC');
INSERT INTO FIF_REQUEST_PARAM VALUES ('TESTID-006', 'DOCUMENT_TEMPLATE_NAME', 'TESTDT');




