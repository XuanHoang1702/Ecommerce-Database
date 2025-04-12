SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[TASK_Complete]
	@p_ADMIN_ID nvarchar(20),
	@p_TASK_ID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	begin transaction
	begin try
		if not exists (select 1 from ADMIN where ADMIN_ID = @p_ADMIN_ID)
		begin
			rollback transaction
			select N'Bạn không phải quản trị viên' as RESULT,
					403 as CODE
			return
		end

		update TASK
		set TASK_STATUS = 'COMPLETE'
		where ID = @p_TASK_ID

		if @@ROWCOUNT <> 0
		begin
			commit transaction
			select N'Đã hoàn thành nhiệm vụ' as RESULT,
					200 as CODE
		end
	end try
	begin catch
		rollback transaction
		select	ERROR_MESSAGE() as RESULT,
				ERROR_NUMBER() as CODE
		return
	end catch
END
GO