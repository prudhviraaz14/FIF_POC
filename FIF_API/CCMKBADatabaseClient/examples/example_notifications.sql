-- Working request for contact

delete from ccm_external_notification where transaction_id='TEST-0001';
delete from ccm_external_notification_parm where transaction_id='TEST-0001';

insert into ccm_external_notification 
    (TRANSACTION_ID, PROCESSED_INDICATOR, START_DATE, CREATION_DATE, ACTION_NAME, TARGET_SYSTEM, UPDATE_NUMBER, AUDIT_UPDATE_USER_ID, AUDIT_UPDATE_DATE_TIME)
values
    ('TEST-0001', 'N', SYSDATE, SYSDATE, 'createKBANotification', 'KBA', 1, 'ogoethal', SYSDATE); 
    
insert into ccm_external_notification_parm 
    (TRANSACTION_ID, PARAM, VALUE, UPDATE_NUMBER, AUDIT_UPDATE_USER_ID, AUDIT_UPDATE_DATE_TIME)
values
    ('TEST-0001', 'CUSTOMER_NUMBER', '000070072183', 1, 'ogoethal', SYSDATE); 
    
insert into ccm_external_notification_parm 
    (TRANSACTION_ID, PARAM, VALUE, UPDATE_NUMBER, AUDIT_UPDATE_USER_ID, AUDIT_UPDATE_DATE_TIME)
values
    ('TEST-0001', 'TYPE', 'CONTACT', 1, 'ogoethal', SYSDATE); 
    
insert into ccm_external_notification_parm 
    (TRANSACTION_ID, PARAM, VALUE, UPDATE_NUMBER, AUDIT_UPDATE_USER_ID, AUDIT_UPDATE_DATE_TIME)
values
    ('TEST-0001', 'CATEGORY', 'Adjustment', 1, 'ogoethal', SYSDATE); 
    
insert into ccm_external_notification_parm 
    (TRANSACTION_ID, PARAM, VALUE, UPDATE_NUMBER, AUDIT_UPDATE_USER_ID, AUDIT_UPDATE_DATE_TIME)
values
    ('TEST-0001', 'USER_NAME', 'ogoethal', 1, 'ogoethal', SYSDATE); 
    
insert into ccm_external_notification_parm 
    (TRANSACTION_ID, PARAM, VALUE, UPDATE_NUMBER, AUDIT_UPDATE_USER_ID, AUDIT_UPDATE_DATE_TIME)
values
    ('TEST-0001', 'WORK_DATE', '2004.11.28 00:00:00', 1, 'ogoethal', SYSDATE); 
    
insert into ccm_external_notification_parm 
    (TRANSACTION_ID, PARAM, VALUE, UPDATE_NUMBER, AUDIT_UPDATE_USER_ID, AUDIT_UPDATE_DATE_TIME)
values
    ('TEST-0001', 'TEXT', 'This is a test adjustment contact for KBA.  More info on <a href=''http://www.arcor.net''>the Arcor website</a>.', 1, 'ogoethal', SYSDATE); 


-- Working request for process

delete from ccm_external_notification where transaction_id='TEST-0003';
delete from ccm_external_notification_parm where transaction_id='TEST-0003';

insert into ccm_external_notification 
    (TRANSACTION_ID, PROCESSED_INDICATOR, START_DATE, CREATION_DATE, ACTION_NAME, TARGET_SYSTEM, UPDATE_NUMBER, AUDIT_UPDATE_USER_ID, AUDIT_UPDATE_DATE_TIME)
values
    ('TEST-0003', 'N', SYSDATE, SYSDATE, 'createKBANotification', 'KBA', 1, 'ogoethal', SYSDATE); 
    
insert into ccm_external_notification_parm 
    (TRANSACTION_ID, PARAM, VALUE, UPDATE_NUMBER, AUDIT_UPDATE_USER_ID, AUDIT_UPDATE_DATE_TIME)
values
    ('TEST-0003', 'CUSTOMER_NUMBER', '002035165831', 1, 'ogoethal', SYSDATE); 
    
insert into ccm_external_notification_parm 
    (TRANSACTION_ID, PARAM, VALUE, UPDATE_NUMBER, AUDIT_UPDATE_USER_ID, AUDIT_UPDATE_DATE_TIME)
values
    ('TEST-0003', 'TYPE', 'PROCESS', 1, 'ogoethal', SYSDATE); 
    
insert into ccm_external_notification_parm 
    (TRANSACTION_ID, PARAM, VALUE, UPDATE_NUMBER, AUDIT_UPDATE_USER_ID, AUDIT_UPDATE_DATE_TIME)
values
    ('TEST-0003', 'CATEGORY', 'Adjustment', 1, 'ogoethal', SYSDATE); 
    
insert into ccm_external_notification_parm 
    (TRANSACTION_ID, PARAM, VALUE, UPDATE_NUMBER, AUDIT_UPDATE_USER_ID, AUDIT_UPDATE_DATE_TIME)
values
    ('TEST-0003', 'RECEIVER_HINT', 'GL', 1, 'ogoethal', SYSDATE); 
    
insert into ccm_external_notification_parm 
    (TRANSACTION_ID, PARAM, VALUE, UPDATE_NUMBER, AUDIT_UPDATE_USER_ID, AUDIT_UPDATE_DATE_TIME)
values
    ('TEST-0003', 'USER_NAME', 'ogoethal', 1, 'ogoethal', SYSDATE); 
    
insert into ccm_external_notification_parm 
    (TRANSACTION_ID, PARAM, VALUE, UPDATE_NUMBER, AUDIT_UPDATE_USER_ID, AUDIT_UPDATE_DATE_TIME)
values
    ('TEST-0003', 'WORK_DATE', '2004.11.28 00:00:00', 1, 'ogoethal', SYSDATE); 
    
insert into ccm_external_notification_parm 
    (TRANSACTION_ID, PARAM, VALUE, UPDATE_NUMBER, AUDIT_UPDATE_USER_ID, AUDIT_UPDATE_DATE_TIME)
values
    ('TEST-0003', 'TEXT', 'This is a test process for KBA.', 1, 'ogoethal', SYSDATE); 
