SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MENU_Update]
	@p_MENU_DATA_JSON nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	begin transaction
	begin try
		declare	 @p_ADMIN_ID nvarchar(20),
				 @p_ID int,
				 @p_MENU_NAME nvarchar(50),
				 @p_MENU_LINK nvarchar(50),
				 @p_PARENT_ID int,
				 @p_MENU_STATUS nvarchar(10)

		select	 @p_ADMIN_ID = ADMIN_ID,
				 @p_ID = ID,
				 @p_MENU_NAME = MenuName,
				 @p_MENU_LINK = MenuLink,
				 @p_PARENT_ID = ParentId,
				 @p_MENU_STATUS = MenuStatus
		from openjson(@p_MENU_DATA_JSON)
		with(
			ADMIN_ID nvarchar(20) '$.ADMIN_ID',
			ID int '$.ID',
			MenuName nvarchar(50) '$.MENU_NAME',
			MenuLink nvarchar(50) '$.MENU_LINK',
			ParentId int '$.PARENT_ID',
			MenuStatus nvarchar(10) '$.MENU_STATUS'
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

		if not exists(select 1 from MENU where ID = @p_ID)
		begin
			rollback transaction
			select N'Menu không tồn tại ' as RESULT,
					404 as CODE
			return
		end

		UPDATE MENU
		SET 
			MENU_NAME = ISNULL(@p_MENU_NAME, MENU_NAME),
			MENU_LINK = ISNULL(@p_MENU_LINK, MENU_LINK),
			PARENT_ID = ISNULL(@p_PARENT_ID, PARENT_ID),
			MENU_STATUS = ISNULL(@p_MENU_STATUS, MENU_STATUS),
			UPDATED_AT = GETDATE()
		WHERE ID = @p_ID

		if @@ROWCOUNT <> 0
		begin
		commit transaction
			select N'Cập nhật menu thành công' as RESULT,
					200 as CODE
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