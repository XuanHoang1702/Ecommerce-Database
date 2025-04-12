SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[TASK_Create] 
	@p_TASK_NAME nvarchar(max),
	@p_ADMIN_ID nvarchar (20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	begin transaction
	begin try
		declare @p_ROLE_RESULT nvarchar(10)
		exec [dbo].[CHECK_ROLE] @p_ADMIN_ID = @p_ADMIN_ID, @p_RESULT = @p_ROLE_RESULT output

		if @p_ROLE_RESULT != 'OK'
		begin
			rollback transaction
			select N'Không đủ quyền' as RESULT,
					403 as CODE
			return
		end

		insert into TASK(TASK_NAME, CREATED_AT, UPDATED_AT, TASK_STATUS, MAKED_ID)
		values(@p_TASK_NAME, getdate(), getdate(), 'ON GOING', @p_ADMIN_ID)

		if @@ROWCOUNT <> 0
		begin
			commit transaction
			select N'Tạo nhiệm vụ thành công' as RESULT,
					201 as CODE
		end
	end try
	begin catch
		rollback transaction
		select ERROR_MESSAGE() as RESULT,
				ERROR_NUMBER() as CODE
		return
	end catch
END
GO