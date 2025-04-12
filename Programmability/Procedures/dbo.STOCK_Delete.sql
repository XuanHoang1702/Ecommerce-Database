SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[STOCK_Delete] 
	@p_ADMIN_ID nvarchar(20),
	@p_STOCK_ID int
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

		delete from STOCK where ID = @p_STOCK_ID

		if @@ROWCOUNT <> 0
		begin
			commit transaction
			select	N'Xóa sản phẩm tỏng kho thành công' as RESULT,
					200 as CODE
		end
	end try
	begin catch
		rollback transaction
		select	 ERROR_MESSAGE() as RESULT,
				ERROR_NUMBER() as CODE
	end catch
END
GO