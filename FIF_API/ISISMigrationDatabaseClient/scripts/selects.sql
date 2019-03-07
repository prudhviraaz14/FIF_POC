select * from fif_isis_req order by creation_date, transaction_id;
select status, count(1) from fif_isis_req group by status;
select * from fif_isis_req where error_text is not null order by creation_date, transaction_id;



All contract numbers for a specific error message:
--------------------------------------------------
select value as contract_number from fif_isis_req_params where param='CONTRACT_NUMBER' and transaction_id in
(select transaction_id from fif_isis_req where error_text like '%CCM2090%')
order by value
