USE [CANCER_HOSPITAL]
GO
/****** Object:  Trigger [dbo].[Trg_Generate_Reg_Bill]    Script Date: 02/20/2019 12:58:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Trigger [dbo].[Trg_Generate_Reg_Bill]
on [dbo].[M_REGISTRATION_OUT_DOOR]
for insert
as
begin 
	declare @reg_no bigint
	declare @bill_no bigint
	declare @Record_id int
	Select @Record_id=Record_No from inserted
	Select @reg_no = MAX(reg_no),@bill_no=max(BILL_NO) from M_REGISTRATION_OUT_DOOR
	if(@reg_no is null)
	begin
		set @reg_no=1
	end
	else
	begin	
		set @reg_no=@reg_no+1
	end
	if(@bill_no is null)
	begin
		set @bill_no=1
	end
	else
	begin	
		set @bill_no=@bill_no+1
	end
	
	print @record_id
	update M_REGISTRATION_OUT_DOOR set REG_NO=@reg_no,BILL_NO=@bill_no where RECORD_NO=@Record_id 
end
