-- Create script for the XML_REQUEST and XML_REQUEST_VALUE table

CREATE TABLE XML_REQUEST (
       EXT_SYS_WO_ID        VARCHAR2(80) NOT NULL,
       WO_ID                VARCHAR2(80) NOT NULL,
       EXT_SYS_ID           VARCHAR2(128) NOT NULL,
       WO_STATUS            NUMBER(22) NOT NULL,
       ACTION_NAME          VARCHAR2(80) NOT NULL,
       ERROR_TEXT           VARCHAR2(4000) NULL,
       DUE_DATE             DATE NOT NULL,
       PRIORITY             NUMBER(22) NULL,
       CREATION_DATE        DATE NOT NULL,
       INTERFACE_START_DATE DATE NULL,
       INTERFACE_END_DATE   DATE NULL
);

COMMENT ON COLUMN XML_REQUEST.EXT_SYS_WO_ID IS 'ID, as who the WO is known in the EXT_SYS (Unique Key).
FIF/CCM does not need this column (?)';
COMMENT ON COLUMN XML_REQUEST.WO_ID IS 'Is the same SO_ID in the service_orders table';
COMMENT ON COLUMN XML_REQUEST.EXT_SYS_ID IS 'External System like FIF, KBA';
COMMENT ON COLUMN XML_REQUEST.WO_STATUS IS 'A WO can have following states:
-	Ready for pick up by ext. system  100
-	start_up  102
-	complete  104
-	failure  253';
COMMENT ON COLUMN XML_REQUEST.ACTION_NAME IS 'Used to define uniquely the action for the transaction, which is  is required by the external system';
COMMENT ON COLUMN XML_REQUEST.ERROR_TEXT IS 'Defined
Field for responses during handling of the WO';
COMMENT ON COLUMN XML_REQUEST.DUE_DATE IS 'Defined Why in two separate columns? One date column should be enough';
COMMENT ON COLUMN XML_REQUEST.PRIORITY IS 'Used only if it is required by the external system';
COMMENT ON COLUMN XML_REQUEST.CREATION_DATE IS 'Timestamp, when the upstream system created the INTERFACE_REQUEST';
COMMENT ON COLUMN XML_REQUEST.INTERFACE_START_DATE IS 'Timestamp, when INTERFACE picked up the INTERFACE_REQUEST';
COMMENT ON COLUMN XML_REQUEST.INTERFACE_END_DATE IS 'Timestamp, when INTERFACE finished the INTERFACE_REQUEST';


CREATE TABLE XML_REQUEST_VALUE (
       EXT_SYS_WO_ID        VARCHAR2(80) NOT NULL,
       PARAM                VARCHAR2(80) NOT NULL,
       VALUE                VARCHAR2(4000) NOT NULL
);

COMMENT ON COLUMN XML_REQUEST_VALUE.EXT_SYS_WO_ID IS 'ID, as who the WO is known in the EXT_SYS (Unique Key).
FIF/CCM does not need this column (?)';
COMMENT ON COLUMN XML_REQUEST_VALUE.PARAM IS 'Each action requires some paramter/attributes';
COMMENT ON COLUMN XML_REQUEST_VALUE.VALUE IS 'This column contains the value, under which the PARAM will be used in the FIF';

CREATE TABLE XML_REQUEST_RESULT (
    EXT_SYS_WO_ID        VARCHAR2(80) NOT NULL,
    RETURN_PARAM         VARCHAR2(80) NOT NULL,
    RETURN_VALUE         VARCHAR2(4000) NOT NULL
);

COMMENT ON COLUMN XML_REQUEST_RESULT.EXT_SYS_WO_ID IS
    'The transaction ID of the FIF request.';
COMMENT ON COLUMN XML_REQUEST_RESULT.RETURN_PARAM IS
    'The name of the returned parameter.';
COMMENT ON COLUMN XML_REQUEST_RESULT.RETURN_VALUE IS
    'The value of the returned parameter.';
