/*
--#########################################################################
--
-- Script Name          :  $Workfile:    $ 
-- Header               :  $Header:     $ 
-- Revision             :  $Revision:    $
-- 
---------------------------------------------------------------------------
--
-- Description:
--
-- Script to create fif_request: terminateProductSubscriptionMobile
-- The transaction_id is contructed as 'PPM129392-' string and product_subscription_id.
-- The fif_request are created with status ON_HOLD and due date equal to the sysdate
--
-- Modification History         :     $Log:    $
--
--
--
--#########################################################################*/




---------------------------------------------------------     

insert into fif_request (                                    
TRANSACTION_ID,
TARGET_CLIENT,
STATUS,
ACTION_NAME,
DUE_DATE,
PRIORITY,
CREATION_DATE,
AUDIT_UPDATE_USER_ID,
EXTERNAL_SYSTEM_ID)                                        
select distinct 
'PPM129392-'||ps0.product_subscription_id, 
'SLSw',
'ON_HOLD',
'terminateProductSubscriptionMobile',
trunc(sysdate),
0,
sysdate,
'PPM129392',
ps0.customer_number
from 
product_subscription ps0, service_subscription ss0
where 1=1 
and ss0.state_rd='SUBSCRIBED'
and ss0.service_code='V8000'
and ss0.product_subscription_id =ps0.product_subscription_id
and (
  ps0.product_commitment_number in (select ofpc0.product_commitment_number from order_form_product_commit ofpc0
  where ofpc0.pricing_structure_code in ('V8000','V8001','V8002','V8003','V8004','V8005','V8006','V8007','V8008','V8011','V8012','V8013','V8017','V8019','V8020')
  and ofpc0.effective_status='ACTIVE'
  and ofpc0.effective_date in (select max(ofpc00.effective_date) from order_form_product_commit ofpc00
     where ofpc00.product_commitment_number=ofpc0.product_commitment_number))
or     
  ps0.product_commitment_number in (select sdpc0.product_commitment_number from serv_deliv_cont_product_commit sdpc0
  where sdpc0.pricing_structure_code in ('V8000','V8001','V8002','V8003','V8004','V8005','V8006','V8007','V8008','V8011','V8012','V8013','V8017','V8019','V8020')
  and sdpc0.effective_status='ACTIVE'
  and sdpc0.effective_date in (select max(sdpc00.effective_date) from order_form_product_commit sdpc00
     where sdpc00.product_commitment_number=sdpc0.product_commitment_number))
)
and ps0.customer_number in (
select customer_number as cn from ( 
select  ps.customer_number,sum(1) as counter from service_subscription ss, product_subscription ps, contract_customer cc
where 1=1
and ss.service_code='V8000'
and ss.state_rd='SUBSCRIBED'
and ps.product_subscription_id = ss.product_subscription_id
and cc.customer_number = ps.customer_number
and cc.effective_status='ACTIVE'
and 0 = (select count(1) from contract_customer cc1
    where cc1.customer_number = cc.customer_number
   and cc1.contract_number = cc.contract_number
   and cc1.effective_date > cc.effective_date)   
group by ps.customer_number
)  where counter=1);  

---------------------------------------------------------------

insert into fif_request_param (                                    
TRANSACTION_ID,
PARAM,
VALUE)
select distinct
'PPM129392-'||ps0.product_subscription_id,  
'SERVICE_SUBSCRIPTION_ID',
ss0.service_subscription_id
from 
product_subscription ps0, service_subscription ss0
where 1=1 
and ss0.state_rd='SUBSCRIBED'
and ss0.service_code='V8000'
and ss0.product_subscription_id =ps0.product_subscription_id
and (
  ps0.product_commitment_number in (select ofpc0.product_commitment_number from order_form_product_commit ofpc0
  where ofpc0.pricing_structure_code in ('V8000','V8001','V8002','V8003','V8004','V8005','V8006','V8007','V8008','V8011','V8012','V8013','V8017','V8019','V8020')
  and ofpc0.effective_status='ACTIVE'
  and ofpc0.effective_date in (select max(ofpc00.effective_date) from order_form_product_commit ofpc00
     where ofpc00.product_commitment_number=ofpc0.product_commitment_number))
or     
  ps0.product_commitment_number in (select sdpc0.product_commitment_number from serv_deliv_cont_product_commit sdpc0
  where sdpc0.pricing_structure_code in ('V8000','V8001','V8002','V8003','V8004','V8005','V8006','V8007','V8008','V8011','V8012','V8013','V8017','V8019','V8020')
  and sdpc0.effective_status='ACTIVE'
  and sdpc0.effective_date in (select max(sdpc00.effective_date) from order_form_product_commit sdpc00
     where sdpc00.product_commitment_number=sdpc0.product_commitment_number))
)
and ps0.customer_number in (
select customer_number as cn from ( 
select  ps.customer_number,sum(1) as counter from service_subscription ss, product_subscription ps, contract_customer cc
where 1=1
and ss.service_code='V8000'
and ss.state_rd='SUBSCRIBED'
and ps.product_subscription_id = ss.product_subscription_id
and cc.customer_number = ps.customer_number
and cc.effective_status='ACTIVE'
and 0 = (select count(1) from contract_customer cc1
    where cc1.customer_number = cc.customer_number
   and cc1.contract_number = cc.contract_number
   and cc1.effective_date > cc.effective_date)   
group by ps.customer_number
)  where counter=1);  
