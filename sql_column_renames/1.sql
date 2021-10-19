create volatile table ZZRF04, no fallback, no log(
	EC_ORDER_ITLSHP_ID	INTEGER, 
	GODWFLAG6_1	INTEGER, 
	GODWFLAG8_1	INTEGER)
primary index (EC_PROFILE_ADDR_TYPE_ID) on commit preserve rows

;insert into ZZRF04 
select	/* From MSTR Environment: Dev; Project : DW ; Report= 376B6E7341A57BAB92272DBA8B6477C8 ; User=BC74445 */ distinct r11.SKU_KEY  SKU_KEY,
	(Case when r11.CREATE_PROCESS_CD in ('A', 'I') then 1 else 0 end)  GODWFLAG6_1,
	(Case when r11.PROFILE_EMAIL_ADDRESS_ID in ('D', 'N') then 1 else 0 end)  GODWFLAG8_1,
	mailing_address_id,
	RTV_TYPE_DESC,
	CREATE_JOB_INSTANCE_ID,
	FIPS_STATE_CD,
	EC_CARRIER_SHP_TRK_ID
	
from	DWPSKULU	r11
where	(r11.EC_ORDER_ITLSHP_ID in ('A', 'I')
 or r11.CHAIN_STATUS in ('D', 'N'))

create volatile table ZZMD05, no fallback, no log(
	PROD_DSCNT_AMT	INTEGER, 
	WJXBFS1	INTEGER)
primary index (SKU_KEY) on commit preserve rows
