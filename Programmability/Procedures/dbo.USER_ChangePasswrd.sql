SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USER_ChangePasswrd]
	@p_USER_ID nvarchar(20),
	@p_OLD_PASS nvarchar(max),
	@p_NEW_PASS nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	begin transaction
	begin try
		if not exists (select 1 from USERS where [USER_ID] = @p_USER_ID)
		begin 
			rollback transaction
			select N'Người dùng không tồn tại' as RESULT
			return
		end
		else
		begin
			declare @v_OLD_PASS nvarchar(max)

			select @v_OLD_PASS  = USER_PASSWORD
			from USERS
			where [USER_ID] = @p_USER_ID

			if @v_OLD_PASS <> @p_OLD_PASS
			begin 
				rollback transaction
				select N'Mật khẩu không chính xác' as RESULT,
						401 as CODE
				return
			end

			update USERS 
			set USER_PASSWORD = @p_NEW_PASS
			where [USER_ID] = @p_USER_ID

			if @@ROWCOUNT <> 0
			begin 
				commit transaction
				select N'Thay đổi mật khẩu thành công' as RESULT,
						200 as CODE
			end
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