﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[TASK_Update]
	@p_TASK_ID int,
	@p_ADMIN_ID nvarchar(20),
	@p_TASK_NAME nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	begin transaction
	begin try
		declare @p_ROLE_RESULT nvarchar(10)
		exec [dbo].[CHECK_ROLE] @p_ADMIN_ID = @p_ADMIN_ID, @p_RESULT = @p_ROLE_RESULT output

		IF @p_ROLE_RESULT <> 1
		begin
			rollback transaction
			select N'Không đủ quyền' as RESULT,
					403 as CODE
			return
		end

		if @p_TASK_NAME is null or @p_TASK_NAME = ''
		begin
			rollback transaction
			select	 N'Tên nhiệm vụ không được để trống' as RESULT,
					422 as CODE
			return
		end

		update TASK
		set TASK_NAME = isnull(@p_TASK_NAME, TASK_NAME),
			MAKED_ID = isnull(@p_ADMIN_ID, MAKED_ID),
			UPDATED_AT = getdate()
		where ID = @p_TASK_ID

		if @@ROWCOUNT <> 0
		begin
			commit transaction
			select	 N'Cập nhật nhiệm vụ thành công' as RESULT,
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