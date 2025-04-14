SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MENU_Delete] 
	@p_MENU_DATA_JSON nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    begin transaction
	begin try
		declare	 @p_ADMIN_ID varchar(20),
				 @p_ID int
		select	 @p_ADMIN_ID = ADMIN_ID,
				 @p_ID = Id
		from openjson(@p_MENU_DATA_JSON)
		with(
			ADMIN_ID nvarchar(20) '$.ADMIN_ID',
			ID INT '$.ID'
		)

		declare @p_ROLE_RESULT nvarchar(10)
		exec [dbo].[CHECK_ROLE] @p_ADMIN_ID = @p_ADMIN_ID, @p_RESULT = @p_ROLE_RESULT output

		IF @p_ROLE_RESULT <> 1
		begin
			rollback transaction
			select N'Không đủ quyền' as RESULT,
					403 as CODE
			return
		end

		delete 
		from MENU
		where ID = @p_ID

		if @@ROWCOUNT <> 0
		begin 
			commit transaction
			select 'Xóa thành công' as RESULT
		end
	end try
	begin catch
		rollback transaction
		select ERROR_MESSAGE() as RESULT
		return
	end catch
END
GO