-- Example db insert example for changing the DSL bandwidth
INSERT INTO FIF_REQUEST VALUES ('TESTID-003', 'SLS', 'NOT_STARTED', 'changeDSLBandwidth', '', SYSDATE, 0, SYSDATE, NULL, NULL, 'testuser', NULL);
INSERT INTO FIF_REQUEST_PARAM VALUES ('TESTID-003', 'ACCESS_NUMBER', '49;173;55555');
INSERT INTO FIF_REQUEST_PARAM VALUES ('TESTID-003', 'CONTRACT_NUMBER', '123456789012');
INSERT INTO FIF_REQUEST_PARAM VALUES ('TESTID-003', 'CUSTOMER_NUMBER', '000123456789');
INSERT INTO FIF_REQUEST_PARAM VALUES ('TESTID-003', 'DESIRED_DATE', '2004.12.01 00:00:00');
INSERT INTO FIF_REQUEST_PARAM VALUES ('TESTID-003', 'OMTS_ORDER_ID', 'IDIDID');
INSERT INTO FIF_REQUEST_PARAM VALUES ('TESTID-003', 'NEW_DSL_BANDWIDTH', 'DSL 2000');
INSERT INTO FIF_REQUEST_PARAM VALUES ('TESTID-003', 'USER_NAME', 'testuser');
INSERT INTO FIF_REQUEST_PARAM VALUES ('TESTID-003', 'NEW_UPSTREAM_BANDWIDTH', '384');
INSERT INTO FIF_REQUEST_PARAM VALUES ('TESTID-003', 'OLD_UPSTREAM_BANDWIDTH', '128');
INSERT INTO FIF_REQUEST_PARAM VALUES ('TESTID-003', 'OLD_DSL_BANDWIDTH', 'DSL 1000');
