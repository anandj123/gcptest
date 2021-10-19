create volatile table ZZRF04, no fallback, no log(
	SKU_KEY	INTEGER, 
	GODWFLAG6_1	INTEGER, 
	GODWFLAG8_1	INTEGER)
primary index (SKU_KEY) on commit preserve rows

;insert into ZZRF04 
select	/* From MSTR Environment: Dev; Project : DW ; Report= 376B6E7341A57BAB92272DBA8B6477C8 ; User=BC74445 */ distinct r11.SKU_KEY  SKU_KEY,
	(Case when r11.CHAIN_STATUS in ('A', 'I') then 1 else 0 end)  GODWFLAG6_1,
	(Case when r11.CHAIN_STATUS in ('D', 'N') then 1 else 0 end)  GODWFLAG8_1
from	DWPSKULU	r11
where	(r11.CHAIN_STATUS in ('A', 'I')
 or r11.CHAIN_STATUS in ('D', 'N'))

create volatile table ZZMD05, no fallback, no log(
	SKU_KEY	INTEGER, 
	WJXBFS1	INTEGER)
primary index (SKU_KEY) on commit preserve rows
