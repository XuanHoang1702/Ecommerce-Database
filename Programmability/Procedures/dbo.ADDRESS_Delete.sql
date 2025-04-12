SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ADDRESS_Delete] 
	@p_ADDRESS_DATA_JSON nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	begin transaction
	begin try
		declare	 @p_USER_ID nvarchar(50),
				 @p_ID int

		select	 @p_USER_ID = UserId,
				 @p_ID = Id
		from openjson(@p_ADDRESS_DATA_JSON)
		with(
			UserId nvarchar(50) '$.USER_ID',
			Id int '$.ID'
		)

		if not exists (select 1 from ADDRESSES where ID = @p_ID)
		begin 
			rollback transaction
			select 'Địa chỉ không tồn tại' as RESULT,
					404 as CODE
			return
		end

		if not exists (select 1 from [USERS] where [USER_ID] = @p_USER_ID)
		begin
			rollback transaction
			select N'Người dùng không tồn tại' as RESULT,
					404 as CODE
			return
		end

		if exists (select 1 from ORDERS where [USER_ID] = @p_USER_ID and ADDRESS_ID = @p_ID)
		begin
			rollback transaction
			select N'Có đơn hàng đang giao đến địa chỉ này' as RESULT,
					409 as CODE
			return
		end

		delete from ADDRESSES where ID = @p_ID

		if @@ROWCOUNT = 1
		begin
			commit transaction
			select N'Xóa địa chỉ thành công' AS RESULT,
					200 as CODE
		end
	end try
	begin catch
		rollback transaction
		select ERROR_MESSAGE() as ERROR,
			   ERROR_NUMBER() as CODE
		return
	end catch
END
GO